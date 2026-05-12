const mongoose = require('mongoose');

// Schema for Noticia
const noticiaSchema = new mongoose.Schema({
  titulo:        { type: String, required: true },
  resumen:       { type: String, required: true },
  contenido:     { type: String, required: true },
  autor:         { type: String, required: true },
  imagen_url:    { type: String, default: null },
  pais:          { type: mongoose.Schema.Types.ObjectId, ref: 'Pais', required: true },
  estado: {
    type: String,
    enum: ['borrador', 'publicado'],
    default: 'borrador'
  },
  fecha_creacion: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Noticia', noticiaSchema);