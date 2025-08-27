import mongoose from "mongoose";

const rankSchema = new mongoose.Schema({
  name: String,
  requiredInvestment: Number,
  requiredDirectUsers: Number,
  teamSales: Number,
  profitPercentage: Number, // Profit percentage per rank
});

export default mongoose.model("Rank", rankSchema);
