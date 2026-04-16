const express = require('express');
const router = express.Router();
const projectController = require('../controllers/projectController');

// GET /api/projects
router.get('/', projectController.getProjects);

module.exports = router;
