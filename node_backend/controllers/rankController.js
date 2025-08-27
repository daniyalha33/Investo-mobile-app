import User from "../models/User.models.js";

export const updateAllUserRanks = async () => {
  try {
    const users = await User.find();

    let bulkUpdates = [];

    for (const user of users) {
      let newRank = "Starter"; // Default rank

      if (user.directUsers >= 3 || user.investedTokens >= 30) {
        newRank = "Gold";
      } else if (user.directUsers >= 2 || user.investedTokens >= 20) {
        newRank = "Silver";
      } else if (user.directUsers >= 1 || user.investedTokens >= 10) {
        newRank = "Silver";
      }

      if (newRank !== user.rank) {
        bulkUpdates.push({
          updateOne: {
            filter: { _id: user._id },
            update: { $set: { rank: newRank } }
          }
        });
      }
    }

    if (bulkUpdates.length > 0) {
      await User.bulkWrite(bulkUpdates);
      console.log(`✅ Updated ranks for ${bulkUpdates.length} users`);
    } else {
      console.log("ℹ️ No rank updates needed");
    }
  } catch (error) {
    console.error("❌ Error updating ranks:", error);
  }
};
