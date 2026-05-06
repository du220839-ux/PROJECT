const express = require('express');
const auth = require('../middleware/auth');
const adminOnly = require('../middleware/admin');
const { createReport, getReports, updateReportStatus } = require('../controllers/reportController');

const router = express.Router();

router.post('/', auth, createReport);
router.get('/', auth, adminOnly, getReports);
router.patch('/:id/status', auth, adminOnly, updateReportStatus);

module.exports = router;
