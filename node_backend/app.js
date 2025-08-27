import express from "express";
import cors from "cors";
import cron from "node-cron";
import dotenv from "dotenv";
import dbConnect from "./config/dbConnect.js";
import adminRoutes from "./routes/adminRoutes.js";
import authRoutes from "./routes/authRoutes.js";
import userRoutes from "./routes/userRoutes.js";
import calculateProfits, { updateTeamSales } from "./utils/calculateProfit.js";
import updateRanks from "./utils/updateRanks.js";
import geminiRoutes from "./routes/gemini.js";
import analyticsRoutes from './routes/analyticsRoutes.js';
//import distributeSalary from "./utils/distributeSalary.js"; // ✅ Import Fixed

dotenv.config();

const app = express();
const PORT = process.env.PORT || 5000;

// 🔍 Verify Environment
console.log("🔍 Environment Port:", process.env.PORT);

app.use(cors({
  origin: ["http://localhost:5173", "http://127.0.0.1:5173","http://localhost:52993"],
  credentials: true
}));
app.use(express.json());

// ✅ Register Routes Before Starting the Server
app.use("/admin", adminRoutes);
app.use("/auth", authRoutes);
app.use("/user", geminiRoutes);
app.use("/user", userRoutes);
app.use('/analytics', analyticsRoutes);

// ✅ Connect to Database First, Then Start Server
dbConnect()
  .then(() => {
    app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Server running at http://0.0.0.0:${PORT}`);
});

  })
  .catch((err) => {
    console.error("❌ Database connection failed:", err);
  });



// ✅ Run Profit Calculation & Rank Update Daily
cron.schedule("0 0 * * *", async () => {
  console.log("⏳ Running daily profit and rank updates...");
  try {
    await updateTeamSales();
    await calculateProfits();
    await updateRanks();
    console.log("✅ Updates completed.");
  } catch (error) {
    console.error("❌ Error in scheduled tasks:", error);
  }
});

// ✅ Weekly Salary Distribution
cron.schedule("0 0 * * 0", async () => {
  console.log("⏳ Running weekly salary distribution...");
  try {
    await distributeSalary();
    console.log("✅ Weekly salary distribution completed.");
  } catch (error) {
    console.error("❌ Error in weekly salary distribution:", error);
  }
});

export default app;
