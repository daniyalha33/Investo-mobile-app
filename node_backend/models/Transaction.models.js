import mongoose from "mongoose";

const transactionSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
  type: { type: String, required: true }, // e.g., "buy", "sell"
  amount: { type: Number, required: true },
  txnHash: { type: String }, // Remove unique: true
});

const Transaction = mongoose.model("Transaction", transactionSchema);

export default Transaction
