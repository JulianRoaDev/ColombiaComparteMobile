const express = require('express');
const router = express.Router();
const { verifyToken } = require('../middleware/auth');
const { getStats } = require('../controllers/dashboard.controller');

// GET /dashboard/stats — protected by JWT, for every role (superadmin, admin_pais, editor)
router.get('/stats', verifyToken, getStats);

module.exports = router;