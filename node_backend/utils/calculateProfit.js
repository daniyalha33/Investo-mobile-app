import User from "../models/User.models.js";
import Rank from "../models/Ranks.models.js";
import Transaction from "../models/Transaction.models.js";

const calculateProfits = async () => {
  try {
    const users = await User.find();
    const ranks = await Rank.find();

    for (let user of users) {
      if (user.tokens > 0) { // Changed investedTokens to tokens
        const rank = ranks.find(r => r.name === user.rank);
        if (!rank) continue;

        const profit = (user.tokens * rank.profitPercentage) / 100; // Calculate profit
        user.personalDeposit += profit; // Add profit to personalDeposit

        const transaction = new Transaction({
          userId: user._id,
          type: "profit",
          amount: profit,
        });

        await transaction.save();
        await user.save();
      }
    }
  } catch (error) {
    console.error("Error calculating profits:", error);
  }
};
export const updateTeamSales = async (userId, depositAmount) => {
  try {
    let user = await User.findById(userId);
    if (!user) return;

    let currentUser = user;
    let level = 1;
    let percentage = [10, 5, 3, 2, 1]; // Residual income percentage per level

    while (currentUser.sponsorId && level <= percentage.length) {
      let sponsor = await User.findById(currentUser.sponsorId);
      if (!sponsor) break;

      // 🎯 Increase team sales (only from downline, excluding personal deposit)
      sponsor.teamSales += depositAmount; // ✅ Uses lower node tokens (from downline)
      sponsor.teamTokens += depositAmount;

      // 🎯 Add residual income based on level percentage
      let residualBonus = (depositAmount * percentage[level - 1]) / 100;
      sponsor.residualIncome += residualBonus;

      // 🎯 Check for rank upgrade based on team sales (downline tokens only)
      if (sponsor.teamSales >= 5000) sponsor.rank = "Silver";
      if (sponsor.teamSales >= 10000) sponsor.rank = "Gold";
      if (sponsor.teamSales >= 20000) sponsor.rank = "Diamond";

      await sponsor.save();
      currentUser = sponsor;
      level++;
    }
  } catch (error) {
    console.error("❌ Error updating team sales:", error);
  }
};

export default calculateProfits;
