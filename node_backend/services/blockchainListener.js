import Web3 from "web3";
import User from "../models/User.js";
import { distributeCommissions, updateUserRank } from "./mlmFunctions.js";

const web3 = new Web3("https://your_rpc_url");
const contractAddress = "0xYourSmartContractAddress";
const contractABI = [/* ABI JSON here */];
const contract = new web3.eth.Contract(contractABI, contractAddress);

contract.events.Deposit({ fromBlock: "latest" })
  .on("data", async (event) => {
    const { userAddress, amount } = event.returnValues;

    let user = await User.findOne({ walletAddress: userAddress });
    if (!user) return;

    user.personalDeposit += parseFloat(web3.utils.fromWei(amount, "ether"));
    await user.save();

    await updateUserRank(user._id);
    await distributeCommissions(user._id, parseFloat(web3.utils.fromWei(amount, "ether")));
  })
  .on("error", console.error);
