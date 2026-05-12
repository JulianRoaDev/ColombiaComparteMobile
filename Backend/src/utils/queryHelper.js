// Build a filter for 'pais' based on the user's role and assigned country.
// superadmin can filter optionally by 'pais', while admin_pais and editor are restricted to their assigned country.
const buildPaisFilter = (user, extraFilters = {}) => {
  const query = { ...extraFilters };

  if (user.rol === 'admin_pais' || user.rol === 'editor') {
    const paisId = user.pais_asignado?._id || user.pais_asignado;
    query.pais = paisId;
  }

  return query;
};

module.exports = { buildPaisFilter };