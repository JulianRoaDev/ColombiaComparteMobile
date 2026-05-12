const Noticia = require('../models/Noticia');
const { buildPaisFilter } = require('../utils/queryHelper');

const listar = async (req, res) => {
  try {
    const { pais, estado } = req.query;
    let filtro = buildPaisFilter(req.user);
    if (pais && req.user.rol === 'superadmin') filtro.pais = pais;
    if (estado) filtro.estado = estado;

    const noticias = await Noticia.find(filtro)
      .populate('pais', 'nombre codigo')
      .sort({ fecha_creacion: -1 });

    return res.status(200).json(noticias);
  } catch (error) {
    return res.status(500).json({ message: 'Error interno del servidor' });
  }
};

const crear = async (req, res) => {
  try {
    const { titulo, resumen, contenido, autor, imagen_url, pais, estado } = req.body;

    if (!titulo || !resumen || !contenido || !autor || !pais) {
      return res.status(400).json({ message: 'Título, resumen, contenido, autor y país son requeridos' });
    }

    if (req.user.rol !== 'superadmin') {
      const paisId = req.user.pais_asignado?._id?.toString() || req.user.pais_asignado?.toString();
      if (pais !== paisId) {
        return res.status(403).json({ message: 'Solo puedes crear noticias de tu país' });
      }
    }

    const nueva = await Noticia.create({
      titulo, resumen, contenido, autor,
      imagen_url: imagen_url || null,
      pais,
      estado: estado || 'borrador'
    });

    return res.status(201).json(nueva);
  } catch (error) {
    return res.status(500).json({ message: 'Error interno del servidor' });
  }
};

const actualizar = async (req, res) => {
  try {
    const noticia = await Noticia.findByIdAndUpdate(
      req.params.id,
      req.body,
      { new: true, runValidators: true }
    ).populate('pais', 'nombre codigo');

    if (!noticia) return res.status(404).json({ message: 'Noticia no encontrada' });
    return res.status(200).json(noticia);
  } catch (error) {
    return res.status(500).json({ message: 'Error interno del servidor' });
  }
};

const cambiarEstado = async (req, res) => {
  try {
    const { estado } = req.body;
    if (!['borrador', 'publicado'].includes(estado)) {
      return res.status(400).json({ message: 'Estado no válido' });
    }

    const noticia = await Noticia.findByIdAndUpdate(
      req.params.id,
      { estado },
      { new: true }
    ).populate('pais', 'nombre codigo');

    if (!noticia) return res.status(404).json({ message: 'Noticia no encontrada' });
    return res.status(200).json(noticia);
  } catch (error) {
    return res.status(500).json({ message: 'Error interno del servidor' });
  }
};

const eliminar = async (req, res) => {
  try {
    const noticia = await Noticia.findById(req.params.id);
    if (!noticia) return res.status(404).json({ message: 'Noticia no encontrada' });

    if (req.user.rol !== 'superadmin') {
      const paisId = req.user.pais_asignado?._id?.toString() || req.user.pais_asignado?.toString();
      if (noticia.pais.toString() !== paisId) {
        return res.status(403).json({ message: 'No puedes eliminar noticias de otro país' });
      }
    }

    await Noticia.findByIdAndDelete(req.params.id);
    return res.status(200).json({ message: 'Noticia eliminada correctamente' });
  } catch (error) {
    return res.status(500).json({ message: 'Error interno del servidor' });
  }
};

module.exports = { listar, crear, actualizar, cambiarEstado, eliminar };