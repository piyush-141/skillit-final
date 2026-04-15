const fs = require('fs');
const path = require('path');

exports.getCompanies = (req, res) => {
  try {
    const dataPath = path.join(__dirname, '../data/companies.json');
    
    if (!fs.existsSync(dataPath)) {
      console.error("❌ Companies file not found at:", dataPath);
      return res.status(404).json({ error: true, message: "Companies data file missing" });
    }

    res.sendFile(dataPath);
    console.log("✅ Companies delivered successfully");
  } catch (err) {
    console.error("❌ Error delivering companies:", err);
    res.status(500).json({ error: true, message: "Internal Server Error" });
  }
};
