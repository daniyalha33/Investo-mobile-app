// routes/analyticsRoutes.js
import express from 'express';
import User from '../models/User.models.js';

const router = express.Router();

router.get('/users-by-rank', async (req, res) => {
  try {
    const result = await User.aggregate([
      {
        $group: {
          _id: "$rank",
          count: { $sum: 1 },
          totalPersonalDeposit: { $sum: "$personalDeposit" },
          totalInvestedTokens: { $sum: "$investedTokens" }
        }
      }
    ]);
    res.json(result);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});
// Get personal deposit by user
router.get('/personal-deposit-by-user', async (req, res) => {
  try {
    const users = await User.find({}, 'name personalDeposit'); // Only fetch name and personalDeposit
    res.json(users);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});


export default router;
