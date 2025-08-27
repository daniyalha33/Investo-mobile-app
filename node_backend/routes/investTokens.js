import express from "express";
import User from "../models/User.js";
import Transaction from "../models/Transaction.js";

router.post("/", async (req, res) => {
  const userId = req.body.userId;
  const amount = Number(req.body.amount); // Ensure amount is a number

  try {
    const user = await User.findById(userId);
    if (!user) return res.status(404).json({ message: "User not found" });

    if (user.personalDeposit < amount)
      return res.status(400).json({ message: "Insufficient tokens" });

    user.personalDeposit -= amount;
    user.investedTokens += amount; // Make sure this is a Number

    await user.save();

    const transaction = new Transaction({ userId, type: "invest", amount });
    await transaction.save();

    res.json({ success: true, message: "Investment successful", investedTokens: user.investedTokens });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});


export default router;
