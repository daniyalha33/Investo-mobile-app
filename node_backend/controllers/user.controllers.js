
import User from "../models/User.models.js";
import Transaction from "../models/Transaction.models.js";



import crypto from "crypto"; // Make sure to import crypto

export const buyTokens = async (req, res) => {
  try {
    console.log("📢 Received Buy Tokens Request", req.body);
   
    
    const amount = Number(req.body.amount);
    const { txnHash } = req.body;
    const userId = req.userId;

    if (!userId || isNaN(amount) || amount <= 0) {
      console.log("❌ Invalid userId or amount:", { userId, amount });
      return res.status(400).json({ message: "User ID and valid amount are required" });
    }

    const user = await User.findById(userId);
    const admin = await User.findOne({ role: "admin" });

    if (!user || !admin) return res.status(404).json({ message: "User or Admin not found" });

    console.log("Before Update:", { userTokens: user.tokens, adminTokens: admin.tokens });

    // Atomic update to prevent multiple modifications
    await User.updateOne({ _id: userId }, { $inc: { tokens: amount, personalDeposit: -amount } });
    await User.updateOne({ role: "admin" }, { $inc: { tokens: -amount, personalDeposit: amount } });

    console.log("After Update:", { userTokens: user.tokens, adminTokens: admin.tokens });

    // Check for duplicate transactions
    const existingTxn = await Transaction.findOne({ txnHash });
    if (existingTxn) return res.status(400).json({ message: "Duplicate transaction" });

    const transaction = new Transaction({ userId, type: "buy", amount, txnHash });
    await transaction.save();

    console.log("✅ Database updated for buy transaction:", { userId, amount, txnHash });

    res.json({ success: true, message: "Tokens purchased successfully", txnHash });

  } catch (error) {
    console.error("❌ Error in buyTokens:", error.message);
    res.status(500).json({ success: false, error: error.message });
  }
};



export const sellTokens = async (req, res) => {
  try {
    console.log("📢 Received Sell Tokens Request", req.body);

    const amount = Number(req.body.amount);
    const { txnHash } = req.body;
    const userId = req.userId;

    if (!userId || isNaN(amount) || amount <= 0) {
      console.log("❌ Invalid userId or amount:", { userId, amount });
      return res.status(400).json({ message: "User ID and valid token amount are required" });
    }

    const user = await User.findById(userId);
    const admin = await User.findOne({ role: "admin" });

    if (!user || !admin) return res.status(404).json({ message: "User or Admin not found" });

    // 🛑 Ensure the user has enough tokens to sell
    if (user.tokens < amount) {
      console.log("❌ User has insufficient tokens:", { userTokens: user.tokens, amount });
      return res.status(400).json({ message: "Insufficient tokens" });
    }

    console.log("Before Update:", { userTokens: user.tokens, adminTokens: admin.tokens });

    // 🛑 Check for duplicate transactions
    const existingTxn = await Transaction.findOne({ txnHash });
    if (existingTxn) return res.status(400).json({ message: "Duplicate transaction" });

    // 🔄 Use atomic updates to ensure consistency
    await User.updateOne({ _id: userId }, { $inc: { tokens: -amount, personalDeposit: amount } });
    await User.updateOne({ role: "admin" }, { $inc: { tokens: amount, personalDeposit: -amount } });

    console.log("After Update:", { userTokens: user.tokens, adminTokens: admin.tokens });

    // 📌 Save transaction
    const transaction = new Transaction({ userId, type: "sell", amount, txnHash });
    await transaction.save();

    console.log("✅ Database updated for sell transaction:", { userId, amount, txnHash });

    res.json({ success: true, message: "Tokens sold successfully", txnHash });

  } catch (error) {
    console.error("❌ Error in sellTokens:", error.message);
    res.status(500).json({ success: false, error: error.message });
  }
};







export const getUserDetails = async (req, res) => {
  try {
    // Extract user ID from middleware
    const userId = req.userId;

    console.log("🔍 Fetching details for user ID:", userId);

    // Find user by ID (excluding password for security)
    const user = await User.findById(userId).select("-password");

    // 🛠 Check if user exists
    if (!user) {
      console.log("❌ User not found");
      return res.status(404).json({ success: false, message: "User not found" });
    }

    // 🛠 Return user details with lastActivity and lastRewarded
    res.status(200).json({
      success: true,
      user: {
        id: user._id,
        referralCode: user.referralCode,
        rank: user.rank,
        personalDeposit: user.personalDeposit,
        directUsers: user.directUsers,
        teamSales: user.teamSales,
        rewards: user.rewards,
        tokens: user.tokens,
        investedTokens:user.investedTokens,
        lastActivity: user.lastActivity,  // 🆕 Include lastActivity
        lastRewarded: user.lastRewarded, // 🆕 Include lastRewarded
      },
    });

  } catch (error) {
    console.error("❌ Error fetching user details:", error);
    res.status(500).json({ success: false, message: "Server error" });
  }
};

export const getUserDownlineTeamSales = async (req, res) => {
  try {
    const userId = req.user.id; // Extract user ID from middleware

    if (!userId) {
      return res.status(401).json({ message: "Unauthorized. No user ID provided." });
    }

    // Function to get all downline user IDs
    const getDownlineUserIds = async (sponsorIds) => {
      let downlineUsers = await User.find({ sponsorId: { $in: sponsorIds } }).select("_id tokens");
      if (downlineUsers.length === 0) return downlineUsers;

      const nextLevelIds = downlineUsers.map(user => user._id);
      return downlineUsers.concat(await getDownlineUserIds(nextLevelIds));
    };

    // Get full downline
    const downlineUsers = await getDownlineUserIds([userId]);

    // Sum all personal deposits
    const totalTeamSales = downlineUsers.reduce((sum, user) => sum + user.tokens, 0);

    res.status(200).json({ totalTeamSales });
  } catch (error) {
    console.error("❌ Error fetching user downline team sales:", error);
    res.status(500).json({ message: "Server error", error: error.message });
  }
};

export const rewardActiveUsers = async (req, res) => {
  try {
    const userId = req.userId;

    console.log("🔍 Checking activity for user ID:", userId);

    // Find the user
    const user = await User.findById(userId);
    if (!user) {
      console.log("❌ User not found");
      return res.status(404).json({ success: false, message: "User not found" });
    }

    const now = new Date();
    const oneWeekAgo = new Date(now);
    oneWeekAgo.setDate(oneWeekAgo.getDate() - 7);

    // Check if the user has been active in the last week
    if (user.lastActivity && user.lastActivity >= oneWeekAgo) {
      // Check if they have already been rewarded in the last week
      if (!user.lastRewarded || user.lastRewarded < oneWeekAgo) {
        // Reward user with 20 tokens
        user.tokens += 20;
        user.lastRewarded = now; // Update last rewarded date

        await user.save();

        console.log(`🎉 User ${user.email} rewarded with 20 tokens.`);
        return res.status(200).json({ success: true, message: "User rewarded with 20 tokens." });
      } else {
        console.log(`⏳ User ${user.email} has already been rewarded this week.`);
        return res.status(200).json({ success: false, message: "User has already been rewarded this week." });
      }
    } else {
      console.log(`🚫 User ${user.email} was not active in the last week.`);
      return res.status(200).json({ success: false, message: "User was not active in the last week." });
    }
  } catch (error) {
    console.error("❌ Error rewarding user:", error);
    res.status(500).json({ success: false, message: "Server error" });
  }
};

export const investTokens = async (req, res) => {
  try {
    const {  txnHash } = req.body;
  const amount = Number(req.body.amount); 
    console.log(amount);
    const userId = req.userId;

    if (!userId || !amount || amount <= 0) {
      return res.status(400).json({ error: "Invalid request data" });
    }

    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ error: "User not found" });
    }

    if (user.tokens < amount) {
      return res.status(400).json({ error: "Insufficient tokens" });
    }

    // Deduct tokens from user and add to invested tokens
    user.tokens -= amount;
    user.investedTokens += amount;
    await user.save();

    let totalDistributed = 0;
    let sponsor = await User.findById(user.sponsorId);

    // Function to find the next eligible ancestor
    const getNextEligibleAncestor = async (currentSponsor) => {
      while (currentSponsor && currentSponsor.block === true) {
        currentSponsor = await User.findById(currentSponsor.sponsorId);
      }
      return currentSponsor; // Returns the next eligible ancestor or null
    };

    // An ancestor is eligible if they have no `block` field or `block: false`
    const isEligible = (user) => user && (user.block === undefined || user.block === false);

    let parent = isEligible(sponsor) ? sponsor : await getNextEligibleAncestor(sponsor);
    let grandparent = parent ? (isEligible(await User.findById(parent.sponsorId)) ? await User.findById(parent.sponsorId) : await getNextEligibleAncestor(await User.findById(parent.sponsorId))) : null;
    let greatGrandparent = grandparent ? (isEligible(await User.findById(grandparent.sponsorId)) ? await User.findById(grandparent.sponsorId) : await getNextEligibleAncestor(await User.findById(grandparent.sponsorId))) : null;

    // Distribute profits to eligible ancestors
    if (parent) {
      let parentShare = amount * 0.1; // 10% to parent
      parent.tokens += parentShare;
      totalDistributed += parentShare;
      await parent.save();
    }

    if (grandparent) {
      let grandparentShare = amount * 0.15; // 15% to grandparent
      grandparent.tokens += grandparentShare;
      totalDistributed += grandparentShare;
      await grandparent.save();
    }

    if (greatGrandparent) {
      let greatGrandparentShare = amount * 0.2; // 20% to great-grandparent
      greatGrandparent.tokens += greatGrandparentShare;
      totalDistributed += greatGrandparentShare;
      await greatGrandparent.save();
    }

    // Remaining amount goes to admin
    const admin = await User.findOne({ role: "admin" });
    if (admin) {
      let adminShare = amount - totalDistributed;
      admin.tokens += adminShare;
      await admin.save();
    }

    // Save transaction record
    const transaction = new Transaction({ userId, type: "invest", amount, txnHash });
    await transaction.save();

    return res.status(200).json({ message: "Tokens invested successfully", user });
  } catch (error) {
    console.error("Investment Error:", error);
    return res.status(500).json({ error: "Server error" });
  }
};



import mongoose from "mongoose";

export const distributeSalary = async () => {
  const session = await mongoose.startSession();
  session.startTransaction();

  try {
    const admin = await User.findOne({ role: "admin" }).session(session);

    const salaryPerUser = 50;
    
    // Include users who don't have the "block" field or have "block: false"
    const users = await User.find({
      role: "user",
      $or: [{ block: false }, { block: { $exists: false } }]
    })
      .populate("sponsorId")
      .session(session);

    const totalTokensNeeded = users.length * salaryPerUser;

    if (!admin || admin.tokens < totalTokensNeeded) {
      console.error("❌ Admin has insufficient tokens for salary distribution.");
      await session.abortTransaction();
      session.endSession();
      return;
    }

    let bulkUpdates = [];
    let totalDistributed = 0;

    for (const user of users) {
      let salary = salaryPerUser;
      let sponsor = user.sponsorId;

      // Function to find next eligible ancestor (not blocked or missing block field)
      const getNextEligibleAncestor = (sponsor) => {
        while (sponsor && sponsor.block === true) {
          sponsor = sponsor.sponsorId;
        }
        return sponsor;
      };

      let parent = getNextEligibleAncestor(sponsor);
      let grandparent = getNextEligibleAncestor(parent?.sponsorId);
      let greatGrandparent = getNextEligibleAncestor(grandparent?.sponsorId);

      let parentShare = parent ? salary * 0.1 : 0;
      let grandparentShare = grandparent ? salary * 0.15 : 0;
      let greatGrandparentShare = greatGrandparent ? salary * 0.2 : 0;
      let remainingSalary = salary - (parentShare + grandparentShare + greatGrandparentShare);

      totalDistributed += salary;

      // Distribute remaining salary to the user
      bulkUpdates.push({
        updateOne: {
          filter: { _id: user._id },
          update: { $inc: { tokens: remainingSalary } }
        }
      });

      // Distribute shares to eligible ancestors
      if (parent) {
        bulkUpdates.push({
          updateOne: {
            filter: { _id: parent._id },
            update: { $inc: { tokens: parentShare } }
          }
        });
      }

      if (grandparent) {
        bulkUpdates.push({
          updateOne: {
            filter: { _id: grandparent._id },
            update: { $inc: { tokens: grandparentShare } }
          }
        });
      }

      if (greatGrandparent) {
        bulkUpdates.push({
          updateOne: {
            filter: { _id: greatGrandparent._id },
            update: { $inc: { tokens: greatGrandparentShare } }
          }
        });
      }
    }

    // Deduct distributed tokens from admin
    bulkUpdates.push({
      updateOne: {
        filter: { _id: admin._id },
        update: { $inc: { tokens: -totalDistributed } }
      }
    });

    await User.bulkWrite(bulkUpdates, { session });
    await session.commitTransaction();
    session.endSession();

    console.log("✅ Weekly salary distribution completed successfully.");
  } catch (error) {
    console.error("❌ Salary Distribution Error:", error);
    await session.abortTransaction();
    session.endSession();
  }
};





