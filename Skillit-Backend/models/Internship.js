const mongoose = require('mongoose');

const InternshipSchema = new mongoose.Schema({
  title: { type: String, required: true },
  company: { type: String, required: true },
  location: String,
  type: String, // Full-time, Remote, etc.
  duration: String,
  stipend: String,
  skills: [String],
  link: String,
  posted: String
});

// For text search
InternshipSchema.index({ title: 'text', company: 'text', skills: 'text' });

module.exports = mongoose.model('Internship', InternshipSchema);
