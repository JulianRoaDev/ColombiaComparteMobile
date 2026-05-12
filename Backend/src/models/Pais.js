const mongoose = require('mongoose');

// Schema definition for the "Pais" model
const paisSchema = new mongoose.Schema({
  nombre: { type: String, required: true },  // Colombia | Chile | Ecuador
  codigo: { type: String, required: true },  // CO | CL | EC
  activo: { type: Boolean, default: true }
});

module.exports = mongoose.model('Pais', paisSchema);