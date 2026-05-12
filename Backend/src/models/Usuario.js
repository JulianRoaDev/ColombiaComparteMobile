const mongoose = require('mongoose');

// Schema definition for the "Usuario" model
const usuarioSchema = new mongoose.Schema(
  {
    nombre: { type: String, required: true },
    correo: { type: String, required: true, unique: true },
    password_hash: { type: String, required: true },
    rol: {
      type: String,
      enum: ['superadmin', 'admin_pais', 'editor'],
      required: true
    },
    pais_asignado: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Pais',
      default: null   // null when rol is 'superadmin'
    }
  },
  { timestamps: true }
);

module.exports = mongoose.model('Usuario', usuarioSchema);