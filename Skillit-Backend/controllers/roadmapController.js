const fs = require('fs');
const path = require('path');

exports.getRoadmaps = (req, res) => {
  try {
    const dataPath = path.join(__dirname, '../data/roadmaps.json');
    
    // Check if file exists first to provide better error
    if (!fs.existsSync(dataPath)) {
      console.error("❌ Roadmap file not found at:", dataPath);
      return res.status(404).json({ error: true, message: "Roadmap data file missing" });
    }

    res.sendFile(dataPath);
    console.log("✅ Roadmaps delivered successfully");
  } catch (err) {
    console.error("❌ Error delivering roadmaps:", err);
    res.status(500).json({ error: true, message: "Internal Server Error" });
  }
};
