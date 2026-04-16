const Project = require('../models/Project');

exports.getProjects = async (req, res) => {
  try {
    const projects = await Project.find();
    
    // Group back into the structure the Flutter app expects: { "domains": [...] }
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
      
      const projObj = proj.toObject();
      delete projObj.domainId;
      delete projObj.domainLabel;
      domainsMap[dId].projects.push(projObj);
    });
    
    res.json({ domains: Object.values(domainsMap) });
    console.log("✅ Projects delivered from DB");
  } catch (err) {
    console.error("❌ Error delivering projects:", err);
    res.status(500).json({ error: true, message: "Internal Server Error" });
  }
};
