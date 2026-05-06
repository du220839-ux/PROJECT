const express = require('express');
const { getSearchSuggestions, getSmartProductSearch } = require('../controllers/aiController');

const router = express.Router();

// AI-powered search suggestions
router.post('/search-suggestions', getSearchSuggestions);

// AI-powered smart product search
router.post('/smart-search', getSmartProductSearch);

module.exports = router;
