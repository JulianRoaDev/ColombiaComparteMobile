const express = require('express');
const router  = express.Router();
const { verifyToken, requireRol } = require('../middleware/auth');
const { listarPaises }            = require('../controllers/paises.controller');

// Público — for anyone to see the list of countries, for dropdowns in forms
router.get('/publico', listarPaises);

// Protegido — only for superadmins to manage countries
router.get('/', verifyToken, requireRol('superadmin'), listarPaises);

module.exports = router;