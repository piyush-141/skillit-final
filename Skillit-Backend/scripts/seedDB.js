const mongoose = require('mongoose');
const fs = require('fs');
const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '../.env') });

const Internship = require('../models/Internship');
const Hackathon = require('../models/Hackathon');
const Company = require('../models/Company');
const Roadmap = require('../models/Roadmap');
const Project = require('../models/Project');

const seedData = async () => {
  try {
    await mongoose.connect(process.env.MONGO_URI);
    console.log('✅ Connected to MongoDB for seeding');

    // 1. Clear existing data
    await Internship.deleteMany({});
    await Hackathon.deleteMany({});
    await Company.deleteMany({});
    await Roadmap.deleteMany({});
    await Project.deleteMany({});
    console.log('🗑️ Cleared existing collections');

    // 2. Load and Seed Companies
    const companiesData = JSON.parse(fs.readFileSync(path.join(__dirname, '../data/companies.json'), 'utf8'));
    await Company.insertMany(companiesData);
    console.log(`🏢 Seeded ${companiesData.length} companies`);

    // 3. Load and Seed Roadmaps
    const roadmapsData = JSON.parse(fs.readFileSync(path.join(__dirname, '../data/roadmaps.json'), 'utf8'));
    const roadmapsToInsert = roadmapsData.fields.map(field => ({
      roadmapId: field.id,
      label: field.label,
      badge: field.badge,
      tagline: field.tagline,
      content: field.content,
      roadmapSteps: field.roadmap,
      resources: field.resources
    }));
    await Roadmap.insertMany(roadmapsToInsert);
    console.log(`🗺️ Seeded ${roadmapsToInsert.length} roadmaps`);

    // 4. Load and Seed Projects
    const projectsData = JSON.parse(fs.readFileSync(path.join(__dirname, '../data/projects.json'), 'utf8'));
    const projectsToInsert = [];
    projectsData.domains.forEach(domain => {
      domain.projects.forEach(proj => {
        projectsToInsert.push({
          domainId: domain.domain_id,
          domainLabel: domain.domain_label,
          ...proj
        });
      });
    });
    await Project.insertMany(projectsToInsert);
    console.log(`🚀 Seeded ${projectsToInsert.length} projects`);

    // 5. Seed Internships
    const { realisticInternships } = require('../controllers/internshipController');
    await Internship.insertMany(realisticInternships);
    console.log(`💼 Seeded ${realisticInternships.length} internships`);

    // 6. Seed Hackathons
    const { realisticHackathons } = require('../controllers/hackathonController');
    await Hackathon.insertMany(realisticHackathons);
    console.log(`🏆 Seeded ${realisticHackathons.length} hackathons`);
    
    console.log('✨ Database fully migrated and seeded!');
    
    process.exit();
  } catch (err) {
    console.error('❌ Seeding error:', err);
    process.exit(1);
  }
};

seedData();
