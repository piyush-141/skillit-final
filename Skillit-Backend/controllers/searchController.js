const Internship = require('../models/Internship');
const Hackathon = require('../models/Hackathon');
const Company = require('../models/Company');
const Roadmap = require('../models/Roadmap');
const Project = require('../models/Project');

exports.globalSearch = async (req, res) => {
  const query = req.query.q;
  
  if (!query || query.length < 2) {
    return res.json({
      internships: [],
      hackathons: [],
      companies: [],
      roadmaps: [],
      projects: []
    });
  }

  try {
    const searchRegex = new RegExp(query, 'i');

    // Parallel search across all collections
    const [internships, hackathons, companies, roadmaps, projects] = await Promise.all([
      Internship.find({
        $or: [
          { title: searchRegex },
          { company: searchRegex },
          { skills: searchRegex }
        ]
      }).limit(5),
      
      Hackathon.find({
        $or: [
          { title: searchRegex },
          { organizer: searchRegex },
          { tags: searchRegex }
        ]
      }).limit(5),
      
      Company.find({
        $or: [
          { name: searchRegex },
          { industry: searchRegex },
          { tags: searchRegex }
        ]
      }).limit(5),

      Roadmap.find({
        $or: [
          { label: searchRegex },
          { tagline: searchRegex }
        ]
      }).limit(5),

      Project.find({
        $or: [
          { title: searchRegex },
          { tagline: searchRegex },
          { skills_gained: searchRegex }
        ]
      }).limit(5)
    ]);

    res.json({
      internships,
      hackathons,
      companies,
      roadmaps,
      projects
    });
    
    console.log(`🔎 Global search: "${query}" - Returned ${internships.length + hackathons.length + companies.length + roadmaps.length + projects.length} results`);

  } catch (err) {
    console.error("❌ Search Error:", err);
    res.status(500).json({ error: true, message: "Search failed" });
  }
};
