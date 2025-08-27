import express from "express";
import { adminLogin, blockUser, createRootAdmin, getAdminDetails, getAllUsersWithDetails, getTotalTeamTokens } from "../controllers/createAdmin.js";
import adminAuth from "../middlewares/adminMiddleware.js";

const router = express.Router();

router.post("/create-admin", createRootAdmin); // Define Route
router.post("/login",adminLogin)
router.get("/admin-dashboard",adminAuth,getAdminDetails)
router.get("/team-sales",adminAuth,getTotalTeamTokens)
router.get("/admin-dashboard",adminAuth,getAdminDetails)
router.get("/all-users",getAllUsersWithDetails)
router.post("/block",adminAuth,blockUser)


export default router;
