const express = require("express");
const router = express.Router();
const { getInternships } = require("../controllers/internshipController");

router.get("/", getInternships);

module.exports = router;