const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");
require("dotenv").config();

const app = express();

// Middleware
app.use(cors());
app.use(express.json());

// In-memory store for rate limiting (reset on server restart)
const loginAttempts = new Map();

// Rate limiter middleware for login attempts
const loginRateLimiter = (req, res, next) => {
  // Only apply to POST /login (the actual path reached after /api/auth prefix is '/')
  if (req.method === "POST" && (req.path === "/login" || req.path === "/")) {
    const ip = req.ip || req.connection.remoteAddress;
    const now = Date.now();
    const attempts = loginAttempts.get(ip) || [];
    
    // Filter attempts within the last 10 seconds
    const recentAttempts = attempts.filter(t => now - t < 10000);
    
    if (recentAttempts.length >= 3) {
      return res.status(429).json({ 
        message: "Too many login attempts. Rate limiter kicks in after 3 attempts. Please try again later." 
      });
    }
    
    recentAttempts.push(now);
    loginAttempts.set(ip, recentAttempts);
  }
  next();
};

// Routes
app.use("/api/auth", loginRateLimiter, require("./routes/authRoutes"));
app.use("/api/internships", require("./routes/internshipRoutes"));
app.use("/api/hackathons", require("./routes/hackathonRoutes"));
app.use("/api/roadmaps", require("./routes/roadmapRoutes"));
app.use("/api/companies", require("./routes/companyRoutes"));
app.use("/api/projects", require("./routes/projectRoutes"));
app.use("/api/search", require("./routes/searchRoutes"));

// MongoDB Connection (Atlas) - Runs in background
mongoose
  .connect(process.env.MONGO_URI)
  .then(() => console.log("✅ MongoDB Connected"))
  .catch((err) => console.log("❌ MongoDB Error:", err));

// Start server IMMEDIATELY
const PORT = 5000;
app.listen(PORT, "0.0.0.0", () => {
  console.log(`🚀 Server running on port ${PORT}`);
  console.log(`🔗 Local link: http://localhost:${PORT}/api/roadmaps`);
});

