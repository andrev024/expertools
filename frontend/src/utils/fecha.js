export function parsearFechaBogota(fecha) {
  if (fecha == null || String(fecha).trim() === '') return null;

  let valor = String(fecha).trim();
  valor = valor.includes('T') ? valor : valor.replace(' ', 'T');
  const tieneZonaHoraria = /(?:Z|[+-]\d{2}(?::?\d{2})?)$/i.test(valor);

  if (tieneZonaHoraria) {
    valor = valor
      .replace(/([+-]\d{2})(\d{2})$/, '$1:$2')
      .replace(/([+-]\d{2})$/, '$1:00');
  } else if (/^\d{4}-\d{2}-\d{2}$/.test(valor)) {
    valor += 'T00:00:00-05:00';
  } else {
    valor += '-05:00';
  }

  const fechaParseada = new Date(valor);
  return Number.isNaN(fechaParseada.getTime()) ? null : fechaParseada;
}

export function formatearFechaBogota(fecha) {
  const fechaParseada = parsearFechaBogota(fecha);
  return fechaParseada
    ? fechaParseada.toLocaleString('es-CO', { timeZone: 'America/Bogota' })
    : 'sin fecha';
}
