const Pais = require('../models/Pais');

const listarPaises = async (req, res) => {
  try {
    const paises = await Pais.find({});
    return res.status(200).json(paises);
  } catch (error) {
    console.error('Error listando países:', error);
    return res.status(500).json({ message: 'Error interno del servidor' });
  }
};

module.exports = { listarPaises };