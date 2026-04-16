const mongoose = require('mongoose');

const RoadmapSchema = new mongoose.Schema({
  roadmapId: { type: String, required: true, unique: true }, // 'frontend', 'backend'
  label: { type: String, required: true },
  badge: String,
  tagline: String,
  content: mongoose.Schema.Types.Mixed,
  roadmapSteps: [mongoose.Schema.Types.Mixed],
  resources: [mongoose.Schema.Types.Mixed]
});

RoadmapSchema.index({ label: 'text', tagline: 'text' });

module.exports = mongoose.model('Roadmap', RoadmapSchema);
