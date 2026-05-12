const mongoose = require('mongoose');

// Schema for Testimonio
const testimonioSchema = new mongoose.Schema({
  nombre:        { type: String, required: true },
  foto_url:      { type: String, required: true },
  testimonio:    { type: String, required: true },
  pais:          { type: mongoose.Schema.Types.ObjectId, ref: 'Pais', required: true },
  instagram_url: { type: String, default: null },
  facebook_url:  { type: String, default: null },
  estado: {
    type: String,
    enum: ['borrador', 'publicado', 'despublicado'],
    default: 'borrador'
  },
  fecha_creacion: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Testimonio', testimonioSchema);