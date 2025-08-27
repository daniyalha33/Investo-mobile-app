import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
import User from "../models/User.models.js";

export const registerUser = async (req, res) => {
  try {
    console.log("📩 Received registration request with data:", req.body);

    const { name, email, password, sponsoredBy, referralCode } = req.body;

    // 🛠 Validate input
    if (!name || !email || !password || !sponsoredBy || !referralCode) {
      console.error("❌ Missing required fields:", { name, email, password, sponsoredBy, referralCode });
      return res.status(400).json({ error: "All fields are required" });
    }

    console.log("🔍 Checking if sponsor exists...");
    const sponsor = await User.findOne({ referralCode: sponsoredBy });

    if (!sponsor) {
      console.error("❌ Invalid referral code, no sponsor found for:", sponsoredBy);
      return res.status(400).json({ error: "Invalid referral code" });
    }

    console.log("🛠 Sponsor found:", sponsor.email);

    console.log("🔍 Checking if email is already registered...");
    const existingUser = await User.findOne({ email });

    if (existingUser) {
      console.error("❌ Email already registered:", email);
      return res.status(400).json({ error: "Email is already registered" });
    }

    console.log("🔍 Checking if referralCode is already used...");
    const existingReferral = await User.findOne({ referralCode });

    if (existingReferral) {
      console.error("❌ Referral code already in use:", referralCode);
      return res.status(400).json({ error: "Referral code is already in use" });
    }

    console.log("🔒 Hashing password...");
    const hashedPassword = await bcrypt.hash(password, 10);
    console.log("✅ Password hashed successfully");

    console.log("🛠 Creating new user...");
    const newUser = new User({
      name,
      email: email.toLowerCase(),
      password: hashedPassword,
      sponsorId: sponsor._id,
      referralCode: referralCode.toLowerCase(),
      rank: "Starter",
      tokens: 0,
      personalDeposit: 100,
      directUsers: 0,
      teamSales: 0,
      teamTokens: 0,
      rewards: [],
      residualIncome: 0,
      leadershipBonus: 0,
      lastActivity: new Date(),  // 🆕 Set lastActivity at registration
      lastRewarded: null,        // 🆕 Initially null, updated later
    });

    console.log("📌 Adding user to sponsor's referral list...");
    sponsor.referrals.push(newUser._id);
    sponsor.directUsers += 1;

    console.log("💾 Saving user and updating sponsor...");
    await Promise.all([newUser.save(), sponsor.save()]);

    console.log(`✅ User ${email} registered under sponsor ${sponsor.email}`);
    res.status(201).json({ message: "User registered successfully", user: newUser });
  } catch (error) {
    console.error("❌ Registration error:", error.message || error);
    res.status(500).json({ error: "Server error", details: error.message });
  }
};

export const login = async (req, res) => {
  try {
    const { referralCode, password } = req.body;

    // 🛠 Validate input
    if (!referralCode || !password) {
      return res.status(400).json({ error: "Referral code and password are required" });
    }

    // Convert referralCode to lowercase
    const normalizedReferralCode = referralCode.toLowerCase();

    console.log("🔍 Searching for user with referralCode:", normalizedReferralCode);

    // Find user with case-insensitive referralCode
    const user = await User.findOne({ referralCode: { $regex: new RegExp(`^${normalizedReferralCode}$`, "i") } });

    // 🛠 Check if user exists
    if (!user) {
      console.log("❌ User not found");
      return res.status(404).json({ error: "User not found" });
    }

    // 🛠 Compare passwords
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      console.log("❌ Invalid credentials");
      return res.status(401).json({ error: "Invalid credentials" });
    }

    // 🆕 Update lastActivity on login
    user.lastActivity = new Date();
    await user.save();

    // 🛠 Generate JWT token
    const token = jwt.sign(
      { userId: user._id, referralCode: user.referralCode },
      process.env.JWT_SECRET,
      { expiresIn: "5h" }
    );

    console.log("✅ Login successful, Token generated:", token);

    // 🛠 Send response with token
    res.status(200).json({ message: "Login successful", token });

  } catch (error) {
    console.error("❌ Login Error:", error);
    res.status(500).json({ error: "Server error" });
  }
};











const rankRequirements = [
  { name: "Starter", minDeposit: 0, minDirects: 0, minTeamSales: 0 },
  { name: "Associate", minDeposit: 100, minDirects: 2, minTeamSales: 500 },
  { name: "Builder", minDeposit: 200, minDirects: 5, minTeamSales: 2000 },
  { name: "Leader", minDeposit: 500, minDirects: 10, minTeamSales: 5000 },
  { name: "Bronze", minDeposit: 1000, minDirects: 15, minTeamSales: 10000 },
  { name: "Silver", minDeposit: 2000, minDirects: 20, minTeamSales: 20000 },
  { name: "Gold", minDeposit: 5000, minDirects: 30, minTeamSales: 50000 },
  { name: "Platinum", minDeposit: 10000, minDirects: 40, minTeamSales: 100000 },
];

export const updateUserRank = async (userId) => {
  let user = await User.findById(userId);
  if (!user) return;

  for (let i = rankRequirements.length - 1; i >= 0; i--) {
    const { name, minDeposit, minDirects, minTeamSales } = rankRequirements[i];
    if (user.personalDeposit >= minDeposit && user.directUsers >= minDirects && user.teamSales >= minTeamSales) {
      user.rank = name;
      break;
    }
  }
  await user.save();
};
export const distributeCommissions = async (userId, amount) => {
  let user = await User.findById(userId);
  if (!user) return;

  let currentSponsor = user.sponsorId;
  let level = 1;
  let commissionPercentages = [10, 8, 7, 6, 5, 4, 3, 2, 1]; // Adjust as needed

  while (currentSponsor && level <= commissionPercentages.length) {
    let sponsor = await User.findById(currentSponsor);
    if (!sponsor) break;

    let commission = (amount * commissionPercentages[level - 1]) / 100;
    sponsor.teamSales += commission;
    await sponsor.save();

    currentSponsor = sponsor.sponsorId;
    level++;
  }
};
