import express from "express";
import Transaction from "../models/Transaction.js";

const router = express.Router();

router.post("/deposit", async (req, res) => {
  const { userId, amount, txnHash } = req.body;

  try {
    const newTransaction = new Transaction({
      userId,
      type: "deposit",
      amount,
      status: "completed",
      txnHash,
    });

    await newTransaction.save();
    res.json({ success: true, message: "Deposit recorded." });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

export default router;
