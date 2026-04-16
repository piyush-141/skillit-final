const express = require("express");
const router = express.Router();
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const User = require("../models/User");
const auth = require("../middleware/authMiddleware");
const authController = require("../controllers/authController");
const userController = require("../controllers/userController");

// ✅ REGISTER ROUTE
router.post("/register", authController.register);

// ✅ LOGIN ROUTE
router.post("/login", authController.login);

// ✅ PROTECTED USER ROUTES
router.get("/profile", auth, userController.getUserProfile);
router.post("/toggle-saved", auth, userController.toggleSavedItem);
router.post("/roadmap-progress", auth, userController.updateRoadmapProgress);
router.put("/update-profile", auth, userController.updateProfile);

module.exports = router;