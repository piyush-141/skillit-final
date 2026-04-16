const Company = require('../models/Company');

exports.getCompanies = async (req, res) => {
  try {
    const companies = await Company.find();
    res.json(companies);
    console.log("✅ Companies delivered from DB");
  } catch (err) {
    console.error("❌ Error delivering companies:", err);
    res.status(500).json({ error: true, message: "Internal Server Error" });
  }
};
