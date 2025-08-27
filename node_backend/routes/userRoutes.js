import express from "express";
import { buyTokens, distributeSalary, getUserDetails, getUserDownlineTeamSales, investTokens, sellTokens } from "../controllers/user.controllers.js";
import { authUser } from "../middlewares/authUser.js";
import { updateAllUserRanks } from "../controllers/rankController.js";
const router = express.Router();
router.post("/buy-tokens",authUser, buyTokens); // Define Route
router.post("/sell-tokens",authUser, sellTokens);
router.get("/get-details",authUser,getUserDetails)
router.get("/get-totalInvestment",authUser,getUserDownlineTeamSales)
router.post("/invest-tokens",authUser,investTokens)
router.post("/distribute-salary",distributeSalary)
router.post("/update-ranks",updateAllUserRanks)

export default router;
