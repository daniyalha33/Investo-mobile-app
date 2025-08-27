import mongoose from "mongoose";

const userSchema = new mongoose.Schema(
  {
    name: String,
    email: { type: String, unique: true, index: true },
    password: String,
    role: { type: String, enum: ["admin", "user"], default: "user" },
    
    referralCode: { type: String, unique: true },
    sponsorId: { type: mongoose.Schema.Types.ObjectId, ref: "User" },
    referrals: [{ type: mongoose.Schema.Types.ObjectId, ref: "User" }],

    rank: { type: String, enum: ["Starter", "Silver", "Gold", "Diamond"], default: "Starter" },
    tokens: { type: Number, default: 0 },
    personalDeposit: { type: Number, default: 100 },
    investedTokens: { type: Number, default: 0 },

    directUsers: { type: Number, default: 0 },
    teamSales: { type: Number, default: 0 },
    teamTokens: { type: Number, default: 0 },

    rewards: { type: Array, default: [] },
    residualIncome: { type: Number, default: 0 },

    lastActivity: { type: Date, default: Date.now },
    lastRewarded: { type: Date, default: null },

    block: { type: Boolean, default: false }, // Block attribute
  },
  { timestamps: true }
);

export default mongoose.model("User", userSchema);


