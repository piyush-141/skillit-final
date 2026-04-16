const Project = require('../models/Project');
const fs = require('fs');
const path = require('path');

exports.getProjects = async (req, res) => {
  try {
    // 1. Try to get from Database first
    const projects = await Project.find();
    
    if (projects && projects.length > 0) {
      const domainsMap = {};
      projects.forEach(proj => {
        const dId = proj.domainId;
        if (!domainsMap[dId]) {
          domainsMap[dId] = {
            domain_id: dId,
            domain_label: proj.domainLabel,
            projects: []
          };
        }
        domainsMap[dId].projects.push(proj.toObject());
      });
      console.log("✅ Projects delivered from DB");
      return res.json({ domains: Object.values(domainsMap) });
    }

    // 2. Fallback to projects.json if DB is empty (Source of Truth)
    const jsonPath = path.join(__dirname, '../data/projects.json');
    if (fs.existsSync(jsonPath)) {
      const fileData = fs.readFileSync(jsonPath, 'utf8');
      const jsonData = JSON.parse(fileData);
      console.log("✅ Projects delivered from projects.json (Fallback)");
      return res.json({ domains: jsonData.domains });
    }

    res.json({ domains: [] });
  } catch (err) {
    console.error("❌ Error delivering projects:", err);
    res.status(500).json({ error: true, message: "Internal Server Error" });
  }
};
