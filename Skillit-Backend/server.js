const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");
require("dotenv").config();

const app = express();

// Middleware
app.use(cors());
app.use(express.json());

// Routes
app.use("/api/auth", require("./routes/authRoutes"));
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

