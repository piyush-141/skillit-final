const mongoose = require('mongoose');

const HackathonSchema = new mongoose.Schema({
  title: { type: String, required: true },
  organizer: { type: String, required: true },
  prize: String,
  mode: String,
  deadline: String,
  tags: [String],
  link: String,
  difficulty: String,
  featured: { type: Boolean, default: false }
});

HackathonSchema.index({ title: 'text', organizer: 'text', tags: 'text' });

module.exports = mongoose.model('Hackathon', HackathonSchema);
