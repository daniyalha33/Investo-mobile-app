import User from "../models/User.models.js";
import Rank from "../models/Ranks.models.js";

const updateRanks = async () => {
  try {
    const users = await User.find();
    const ranks = await Rank.find();

    for (let user of users) {
      const highestRank = ranks
        .filter(rank => user.tokens >= rank.requiredInvestment) // Changed investedTokens to tokens
        .sort((a, b) => b.requiredInvestment - a.requiredInvestment)[0];

      if (highestRank && user.rank !== highestRank.name) {
        user.rank = highestRank.name;
        await user.save();
      }
    }
  } catch (error) {
    console.error("Error updating ranks:", error);
  }
};

export default updateRanks;
