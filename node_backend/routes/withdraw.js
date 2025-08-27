import express from "express";
import Web3 from "web3";
import Transaction from "../models/Transaction.js";

const router = express.Router();
const web3 = new Web3(process.env.RPC_URL);
const contract = new web3.eth.Contract(contractABI, process.env.CONTRACT_ADDRESS);

router.post("/withdraw", async (req, res) => {
  const { userId, amount } = req.body;

  try {
    // Call the smart contract withdrawal function
    const user = await User.findById(userId);
    const tx = await contract.methods.withdraw(web3.utils.toWei(amount.toString(), "ether"))
      .send({ from: user.walletAddress });

    const newTransaction = new Transaction({
      userId,
      type: "withdrawal",
      amount,
      status: "pending", // Set to completed after confirmation
      txnHash: tx.transactionHash,
    });

    await newTransaction.save();
    res.json({ success: true, message: "Withdrawal initiated.", txnHash: tx.transactionHash });

  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

export default router;
