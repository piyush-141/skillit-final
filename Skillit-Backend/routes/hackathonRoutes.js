const express = require("express");
const router = express.Router();
const axios = require("axios");

router.get("/", async (req, res) => {
  try {
    const response = await axios.get(
      "https://api.devfolio.co/api/hackathons"
    );

    const hackathons = response.data.data.map((h) => ({
      title: h.name || "Untitled Hackathon",
      location: h.city || "Online",
      mode: h.is_online ? "Online" : "Offline",
      description: h.tagline || h.description || "Exciting hackathon ahead!",
      startDate: h.starts_at ? new Date(h.starts_at).toLocaleDateString('en-US', {
        month: 'short',
        day: 'numeric',
        year: 'numeric'
      }) : "",
      endDate: h.ends_at ? new Date(h.ends_at).toLocaleDateString('en-US', {
        month: 'short',
        day: 'numeric',
        year: 'numeric'
      }) : "",
      link: `https://devfolio.co/${h.slug}`,
    }));

    res.json(hackathons);
  } catch (err) {
    console.error("❌ Error fetching hackathons:", err.message);
    res.status(500).json({ 
      error: "Failed to fetch hackathons",
      details: err.message 
    });
  }
});

module.exports = router;