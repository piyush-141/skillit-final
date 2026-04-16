const mongoose = require('mongoose');

const ProjectSchema = new mongoose.Schema({
  domainId: String,
  domainLabel: String,
  level: String,
  title: { type: String, required: true },
  tagline: String,
  overview: String,
  skills_gained: [String],
  trending_technologies: [String]
});

ProjectSchema.index({ title: 'text', tagline: 'text', overview: 'text', skills_gained: 'text' });

module.exports = mongoose.model('Project', ProjectSchema);
