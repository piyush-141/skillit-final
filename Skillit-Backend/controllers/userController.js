const User = require("../models/User");

// ✅ GET USER PROFILE
exports.getUserProfile = async (req, res) => {
  try {
    const user = await User.findById(req.user.id).select("-password");
    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }
    res.json(user);
  } catch (err) {
    console.error("Get Profile Error:", err);
    res.status(500).json({ message: "Server error fetching profile" });
  }
};

// ✅ TOGGLE SAVED ITEM (Internship or Hackathon)
exports.toggleSavedItem = async (req, res) => {
  try {
    const { type, itemId, action } = req.body; // type: 'internship' | 'hackathon', action: 'add' | 'remove'

    if (!['internship', 'hackathon'].includes(type) || !['add', 'remove'].includes(action)) {
      return res.status(400).json({ message: "Invalid type or action" });
    }

    const field = type === 'internship' ? 'savedInternships' : 'savedHackathons';
    const operator = action === 'add' ? '$addToSet' : '$pull';

    const user = await User.findByIdAndUpdate(
      req.user.id,
      { [operator]: { [field]: itemId } },
      { new: true }
    ).select("-password");

    res.json({ message: `Successfully ${action}ed ${type}`, user });
  } catch (err) {
    console.error("Toggle Saved Item Error:", err);
    res.status(500).json({ message: "Server error toggling saved item" });
  }
};

// ✅ UPDATE ROADMAP PROGRESS
exports.updateRoadmapProgress = async (req, res) => {
  try {
    const { nodeId, completed } = req.body;

    const operator = completed ? '$addToSet' : '$pull';

    const user = await User.findByIdAndUpdate(
      req.user.id,
      { [operator]: { completedNodes: nodeId } },
      { new: true }
    ).select("-password");

    res.json({ message: "Roadmap progress updated", user });
  } catch (err) {
    console.error("Update Roadmap Error:", err);
    res.status(500).json({ message: "Server error updating roadmap progress" });
  }
};

// ✅ UPDATE USER PROFILE
exports.updateProfile = async (req, res) => {
  console.log("🔵 Incoming Update Profile Request for User:", req.user.id);
  try {
    const { name, domain, newPassword } = req.body;
    console.log("📦 Request Body:", { name, domain, passwordProvided: !!newPassword });
    const userId = req.user.id;

    const updateData = {};
    if (name) updateData.name = name;
    if (domain) updateData.domain = domain;

    // Handle password change
    if (newPassword) {
      const passwordRegex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{6,}$/;
      if (!passwordRegex.test(newPassword)) {
        return res.status(400).json({ msg: "New password does not meet complexity requirements." });
      }
      const salt = await require("bcryptjs").genSalt(10);
      updateData.password = await require("bcryptjs").hash(newPassword, salt);
    }

    const user = await User.findByIdAndUpdate(
      userId,
      { $set: updateData },
      { new: true }
    ).select("-password");

    console.log("✅ Profile updated in DB for User:", userId);
    res.json({ message: "Profile updated successfully", user });
  } catch (err) {
    console.error("Update Profile Error:", err);
    res.status(500).json({ message: "Server error updating profile" });
  }
};
