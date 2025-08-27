import jwt from "jsonwebtoken";

export const authUser = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization; // Get Authorization header
    console.log(authHeader)

    if (!authHeader || !authHeader.startsWith("Bearer ")) {
      console.log("❌ No token provided");
      return res.status(401).json({ success: false, message: "Unauthorized, please log in" });
    }

    const token = authHeader.split(" ")[1]; // Extract token
    console.log("🔑 Received Token:", token);

    const decodedToken = jwt.verify(token, process.env.JWT_SECRET);
    console.log("✅ Decoded Token:", decodedToken);

    req.userId = decodedToken.userId; // Attach userId to request
    next();
  } catch (error) {
    console.error("❌ Authentication Error:", error.message);
    return res.status(403).json({ success: false, message: "Invalid or expired token" });
  }
};
