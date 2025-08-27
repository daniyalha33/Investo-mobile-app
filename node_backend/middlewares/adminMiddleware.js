import jwt from 'jsonwebtoken';
import User from '../models/User.models.js';
import dotenv from 'dotenv';

dotenv.config();

const adminAuth = async (req, res, next) => {
  try {
    const token = req.header('Authorization')?.replace('Bearer ', '');

    if (!token) {
      return res.status(401).json({ message: 'Access denied. No token provided.' });
    }

    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    const admin = await User.findById(decoded.id);

    if (!admin || admin.role !== 'admin') {
      return res.status(403).json({ message: 'Unauthorized. Admin access required.' });
    }

    req.admin = {
      id: admin._id,  // Explicitly adding Admin ID
      email: admin.email,
      role: admin.role,
    };

    next();
  } catch (error) {
    res.status(401).json({ message: 'Invalid token. Please log in again.' });
  }
};

export default adminAuth;
