const Solicitud  = require('../models/Solicitud');
const Testimonio = require('../models/Testimonio');
const Noticia    = require('../models/Noticia');
const Pais       = require('../models/Pais');

const getStats = async (req, res) => {
  try {
    const { rol, pais_asignado } = req.user;

    // ── SUPERADMIN: metrics for each country ──────────────────────────
    if (rol === 'superadmin') {
      const paises = await Pais.find({ activo: true });

      const statsPorPais = await Promise.all(
        paises.map(async (pais) => {
          const [solicitudesPendientes, testimoniosPublicados, noticiasActivas] =
            await Promise.all([
              Solicitud.countDocuments({ pais: pais._id, estado: 'pendiente' }),
              Testimonio.countDocuments({ pais: pais._id, estado: 'publicado' }),
              Noticia.countDocuments({ pais: pais._id, estado: 'publicado' })
            ]);

          return {
            pais: { _id: pais._id, nombre: pais.nombre, codigo: pais.codigo },
            solicitudesPendientes,
            testimoniosPublicados,
            noticiasActivas
          };
        })
      );

      return res.status(200).json({ rol: 'superadmin', stats: statsPorPais });
    }

    // ── ADMIN_PAIS / EDITOR: Only the assignment country ──────────────────────────
    if (!pais_asignado) {
      return res.status(400).json({ message: 'Usuario sin país asignado' });
    }

    // pais_asignado can arrive like an obj {_id, nombre, codigo} or only the _id
    const paisId = pais_asignado._id || pais_asignado;

    const [solicitudesPendientes, testimoniosPublicados, noticiasActivas] =
      await Promise.all([
        Solicitud.countDocuments({ pais: paisId, estado: 'pendiente' }),
        Testimonio.countDocuments({ pais: paisId, estado: 'publicado' }),
        Noticia.countDocuments({ pais: paisId, estado: 'publicado' })
      ]);

    return res.status(200).json({
      rol,
      stats: {
        pais: pais_asignado,
        solicitudesPendientes,
        testimoniosPublicados,
        noticiasActivas
      }
    });

  } catch (error) {
    console.error('Error en dashboard stats:', error);
    return res.status(500).json({ message: 'Error interno del servidor' });
  }
};

module.exports = { getStats };