const Solicitud = require('../models/Solicitud');
const { buildPaisFilter } = require('../utils/queryHelper');

// GET /solicitudes — list with optional filters (estado, pais)
const listar = async (req, res) => {
  try {
    const { estado, pais } = req.query;
    let filtro = buildPaisFilter(req.user);

    if (estado) filtro.estado = estado;

    // only superadmin can filter by pais, admin_pais and editor are already filtered by their assigned country
    if (pais && req.user.rol === 'superadmin') filtro.pais = pais;

    const solicitudes = await Solicitud.find(filtro)
      .populate('pais', 'nombre codigo')
      .sort({ fecha_creacion: -1 });

    return res.status(200).json(solicitudes);
  } catch (error) {
    console.error('Error listando solicitudes:', error);
    return res.status(500).json({ message: 'Error interno del servidor' });
  }
};

// GET /solicitudes/:id — complete details
const detalle = async (req, res) => {
  try {
    const solicitud = await Solicitud.findById(req.params.id)
      .populate('pais', 'nombre codigo');

    if (!solicitud) {
      return res.status(404).json({ message: 'Solicitud no encontrada' });
    }

    // Verify that admin_pais and editor can only access details of their assigned country
    if (req.user.rol !== 'superadmin') {
      const paisId = req.user.pais_asignado?._id?.toString() || req.user.pais_asignado?.toString();
      if (solicitud.pais._id.toString() !== paisId) {
        return res.status(403).json({ message: 'Acceso denegado' });
      }
    }

    return res.status(200).json(solicitud);
  } catch (error) {
    return res.status(500).json({ message: 'Error interno del servidor' });
  }
};

// PATCH /solicitudes/:id/estado — change state
const cambiarEstado = async (req, res) => {
  try {
    const { estado } = req.body;
    const estadosValidos = ['pendiente', 'gestionada', 'respondida'];

    if (!estadosValidos.includes(estado)) {
      return res.status(400).json({ message: 'Estado no válido' });
    }

    const solicitud = await Solicitud.findByIdAndUpdate(
      req.params.id,
      { estado },
      { new: true }
    ).populate('pais', 'nombre codigo');

    if (!solicitud) {
      return res.status(404).json({ message: 'Solicitud no encontrada' });
    }

    return res.status(200).json(solicitud);
  } catch (error) {
    return res.status(500).json({ message: 'Error interno del servidor' });
  }
};

// DELETE /solicitudes/:id
const eliminar = async (req, res) => {
  try {
    const solicitud = await Solicitud.findById(req.params.id);

    if (!solicitud) {
      return res.status(404).json({ message: 'Solicitud no encontrada' });
    }

    // Verify that admin_pais and editor can only delete solicitudes of their assigned country
    if (req.user.rol !== 'superadmin') {
      const paisId = req.user.pais_asignado?._id?.toString() || req.user.pais_asignado?.toString();
      if (solicitud.pais.toString() !== paisId) {
        return res.status(403).json({ message: 'No puedes eliminar solicitudes de otro país' });
      }
    }

    await Solicitud.findByIdAndDelete(req.params.id);
    return res.status(200).json({ message: 'Solicitud eliminada correctamente' });
  } catch (error) {
    return res.status(500).json({ message: 'Error interno del servidor' });
  }
};

// POST /solicitudes — público (sin auth), for creating new solicitudes from the website
const crear = async (req, res) => {
  try {
    const { nombre, correo, telefono, finalidad, pais } = req.body;

    if (!nombre || !correo || !telefono || !finalidad || !pais) {
      return res.status(400).json({ message: 'Todos los campos son requeridos' });
    }

    const nueva = await Solicitud.create({ nombre, correo, telefono, finalidad, pais });
    return res.status(201).json(nueva);
  } catch (error) {
    return res.status(500).json({ message: 'Error interno del servidor' });
  }
};

module.exports = { listar, detalle, cambiarEstado, eliminar, crear };