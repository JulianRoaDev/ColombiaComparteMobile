const Testimonio = require('../models/Testimonio');
const { buildPaisFilter } = require('../utils/queryHelper');

const listar = async (req, res) => {
  try {
    const { pais } = req.query;
    let filtro = buildPaisFilter(req.user);
    if (pais && req.user.rol === 'superadmin') filtro.pais = pais;

    const testimonios = await Testimonio.find(filtro)
      .populate('pais', 'nombre codigo')
      .sort({ fecha_creacion: -1 });

    return res.status(200).json(testimonios);
  } catch (error) {
    return res.status(500).json({ message: 'Error interno del servidor' });
  }
};

const crear = async (req, res) => {
  try {
    const { nombre, foto_url, testimonio, pais, instagram_url, facebook_url, estado } = req.body;

    if (!nombre || !foto_url || !testimonio || !pais) {
      return res.status(400).json({ message: 'Nombre, foto, testimonio y país son requeridos' });
    }

    // admin_pais and editor can only create testimonios for their assigned country
    if (req.user.rol !== 'superadmin') {
      const paisId = req.user.pais_asignado?._id?.toString() || req.user.pais_asignado?.toString();
      if (pais !== paisId) {
        return res.status(403).json({ message: 'Solo puedes crear testimonios de tu país' });
      }
    }

    const nuevo = await Testimonio.create({
      nombre, foto_url, testimonio, pais,
      instagram_url: instagram_url || null,
      facebook_url: facebook_url || null,
      estado: estado || 'borrador'
    });

    return res.status(201).json(nuevo);
  } catch (error) {
    return res.status(500).json({ message: 'Error interno del servidor' });
  }
};

const actualizar = async (req, res) => {
  try {
    const testimonio = await Testimonio.findByIdAndUpdate(
      req.params.id,
      req.body,
      { new: true, runValidators: true }
    ).populate('pais', 'nombre codigo');

    if (!testimonio) return res.status(404).json({ message: 'Testimonio no encontrado' });
    return res.status(200).json(testimonio);
  } catch (error) {
    return res.status(500).json({ message: 'Error interno del servidor' });
  }
};

const cambiarEstado = async (req, res) => {
  try {
    const { estado } = req.body;
    const estadosValidos = ['borrador', 'publicado', 'despublicado'];

    if (!estadosValidos.includes(estado)) {
      return res.status(400).json({ message: 'Estado no válido' });
    }

    const testimonio = await Testimonio.findByIdAndUpdate(
      req.params.id,
      { estado },
      { new: true }
    ).populate('pais', 'nombre codigo');

    if (!testimonio) return res.status(404).json({ message: 'Testimonio no encontrado' });
    return res.status(200).json(testimonio);
  } catch (error) {
    return res.status(500).json({ message: 'Error interno del servidor' });
  }
};

const eliminar = async (req, res) => {
  try {
    const testimonio = await Testimonio.findById(req.params.id);
    if (!testimonio) return res.status(404).json({ message: 'Testimonio no encontrado' });

    if (req.user.rol !== 'superadmin') {
      const paisId = req.user.pais_asignado?._id?.toString() || req.user.pais_asignado?.toString();
      if (testimonio.pais.toString() !== paisId) {
        return res.status(403).json({ message: 'No puedes eliminar testimonios de otro país' });
      }
    }

    await Testimonio.findByIdAndDelete(req.params.id);
    return res.status(200).json({ message: 'Testimonio eliminado correctamente' });
  } catch (error) {
    return res.status(500).json({ message: 'Error interno del servidor' });
  }
};

module.exports = { listar, crear, actualizar, cambiarEstado, eliminar };