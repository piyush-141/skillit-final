const jwt = require("jsonwebtoken");

module.exports = function (req, res, next) {
  const token = req.header("Authorization");

  if (!token) return res.status(401).json({ msg: "No token, access denied" });

  try {
    console.log("🔑 Verifying token for request...");
    const verified = jwt.verify(token, process.env.JWT_SECRET);
    req.user = verified;
    console.log("✅ Token verified for User ID:", verified.id);
    next();
  } catch (err) {
    console.log("❌ Token verification failed:", err.message);
    res.status(400).json({ msg: "Invalid token" });
  }
};