const Roadmap = require('../models/Roadmap');

exports.getRoadmaps = async (req, res) => {
  try {
    const roadmaps = await Roadmap.find();
    
    // Transform back to the structure the app expects { app, version, fields }
    const response = {
      app: "Skillit",
      version: "1.0.0",
      fields: roadmaps.map(r => ({
        id: r.roadmapId,
        label: r.label,
        badge: r.badge,
        tagline: r.tagline,
        content: r.content,
        roadmap: r.roadmapSteps,
        resources: r.resources
      }))
    };

    res.json(response);
    console.log("✅ Roadmaps delivered from DB");
  } catch (err) {
    console.error("❌ Error delivering roadmaps:", err);
    res.status(500).json({ error: true, message: "Internal Server Error" });
  }
};
