const mongoose = require('mongoose');

// Schema for the "Solicitud" collection
const solicitudSchema = new mongoose.Schema({
  nombre:        { type: String, required: true },
  correo:        { type: String, required: true },
  telefono:      { type: String, required: true },
  finalidad:     { type: String, required: true },
  pais:          { type: mongoose.Schema.Types.ObjectId, ref: 'Pais', required: true },
  estado: {
    type: String,
    enum: ['pendiente', 'gestionada', 'respondida'],
    default: 'pendiente'
  },
  fecha_creacion: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Solicitud', solicitudSchema);