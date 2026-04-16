const mongoose = require('mongoose');

const CompanySchema = new mongoose.Schema({
  name: { type: String, required: true },
  main_url: String,
  logo: String,
  industry: String,
  description: String,
  headquarters: String,
  tags: [String],
  internships: [mongoose.Schema.Types.Mixed] // Store nested for detail view
});

CompanySchema.index({ name: 'text', industry: 'text', description: 'text', tags: 'text' });

module.exports = mongoose.model('Company', CompanySchema);
