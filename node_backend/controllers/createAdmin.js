import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import User from '../models/User.models.js';
import dotenv from 'dotenv';

dotenv.config();

export const createRootAdmin = async (req, res) => {
  try {
    const { email, password, referralCode } = req.body; // Get data from request

    // Check if admin already exists
    const existingAdmin = await User.findOne({ role: "admin" });
    if (existingAdmin) {
      return res.status(400).json({ message: "Admin already exists" });
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(password, 10);

    // Create new admin
    const admin = new User({
      name: "Admin",
      email,
      password: hashedPassword,
      role: "admin",
      referralCode: referralCode.toLowerCase(),
      sponsorId: null, // Root user, no sponsor
      tokens: 1000000, // Admin starts with 1,000,000 tokens
      teamTokens: 0, // Total tokens of the team
      rewards: [],
      residualIncome: 0, // Earnings from downline profits
      leadershipBonus: 0, 
      // Earnings based on rank and team sales
    });

    await admin.save();
    return res.status(201).json({
      message: "Admin created successfully",
      referralCode: admin.referralCode,
    });
  } catch (error) {
    console.error("Error creating admin:", error);
    return res.status(500).json({ message: "Internal server error" });
  }
};

export const adminLogin = async (req, res) => {
  try {
    console.log("🛠 Admin Login Attempt:", req.body); // Log request body

    const { email, password } = req.body;
    if (!email || !password) {
      console.log("❌ Missing email or password");
      return res.status(400).json({ message: "Email and password are required" });
    }

    const admin = await User.findOne({ email, role: "admin" });
    console.log("🔍 Admin Found in DB:", admin);

    if (!admin) {
      console.log("❌ Admin Not Found");
      return res.status(404).json({ message: "Admin not found" });
    }

    const isMatch = await bcrypt.compare(password, admin.password);
    console.log("🔑 Password Match:", isMatch);

    if (!isMatch) {
      console.log("❌ Invalid Credentials");
      return res.status(400).json({ message: "Invalid credentials" });
    }

    const token = jwt.sign(
      { id: admin._id, role: admin.role },
      process.env.JWT_SECRET,
      { expiresIn: "7d" }
    );

    console.log("✅ Token Generated:", token);

    res.status(200).json({ message: "Admin login successful", token });
  } catch (error) {
    console.error("❌ Server Error:", error);
    res.status(500).json({ message: "Server error", error: error.message });
  }
};

export const getAdminDetails = async (req, res) => {
  try {
    // ✅ Get Admin ID from middleware
    const adminId = req.admin.id;

    if (!adminId) {
      return res.status(401).json({ message: "Unauthorized. No admin ID provided." });
    }

    // ✅ Fetch Admin Data
    const admin = await User.findById(adminId).select(
      "name role email referralCode directUsers teamSales tokens rank teamTokens rewards personalDeposit lastActivity"
    );

    if (!admin) {
      return res.status(404).json({ message: "Admin not found" });
    }

    // ✅ Return Admin Data
    res.status(200).json({
      email: admin.email,
      name:admin.name,
      role:admin.role,
      referralCode: admin.referralCode,
      directUsers: admin.directUsers || 0,
      teamSales: admin.teamSales || 0,
      tokens: admin.tokens || 0,
      rank: admin.rank || "Starter",
      teamTokens: admin.teamTokens || 0,
      rewards: admin.rewards || [],
      personalDeposit: admin.personalDeposit || 0,
      lastActivity: admin.lastActivity || 0,
    });
  } catch (error) {
    console.error("❌ Error fetching admin details:", error);
    res.status(500).json({ message: "Server error", error: error.message });
  }
};
export const getTotalTeamTokens = async (req, res) => {
  try {
    const adminId = req.admin.id;

    if (!adminId) {
      return res.status(401).json({ message: "Unauthorized. No admin ID provided." });
    }

    // Function to get all downline user IDs
    const getDownlineUserIds = async (sponsorIds) => {
      let downlineUsers = await User.find({ sponsorId: { $in: sponsorIds } }).select("_id tokens");
      if (downlineUsers.length === 0) return downlineUsers;

      const nextLevelIds = downlineUsers.map(user => user._id);
      return downlineUsers.concat(await getDownlineUserIds(nextLevelIds));
    };

    // Get full downline
    const downlineUsers = await getDownlineUserIds([adminId]);

    // Sum all tokens
    const totalTeamTokens = downlineUsers.reduce((sum, user) => sum + user.tokens, 0);

    res.status(200).json({ totalTeamTokens });
  } catch (error) {
    console.error("❌ Error fetching total team tokens:", error);
    res.status(500).json({ message: "Server error", error: error.message });
  }
};
export const getAllUsersWithDetails = async (req, res) => {
  try {
    const users = await User.find({}, "name referralCode rank tokens"); // Selecting only required fields

    res.json({
      success: true,
      totalUsers: users.length,
      users
    });
  } catch (error) {
    console.error("❌ Error fetching users:", error);
    res.status(500).json({
      success: false,
      message: "Server error",
      error
    });
  }
};
export const blockUser = async (req,res) => {
  try {
    const { email, status } = req.body;
    console.log(email)
    console.log(status)

    const booleanStatus = status === "true" || status === true; // Ensure it's a boolean

    const user = await User.findOneAndUpdate(
      { email },
      { $set: { block: booleanStatus } }, // Ensure block is a boolean
      { new: true }
    );

    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    res.json({ message: `User ${booleanStatus ? "blocked" : "unblocked"} successfully`, user });
  } catch (error) {
    console.error("Error updating user block status:", error);
    res.status(500).json({ message: "Internal server error" });
  }
};

