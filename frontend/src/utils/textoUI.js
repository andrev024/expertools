const ETIQUETAS_ESTADO = {
  recibido: 'Recibido',
  en_diagnostico: 'En diagnóstico',
  cotizado: 'Cotizado',
  en_reparacion: 'En reparación',
  esperando_repuesto: 'Esperando repuesto',
  finalizado_tecnico: 'Finalizado por técnico',
  en_revision_recepcion: 'En revisión de recepción',
  listo_para_entregar: 'Listo para entregar',
  entregado: 'Entregado',
  chatarra: 'Chatarra',
};

const ETIQUETAS_ROL = {
  admin: 'Administrador',
  recepcion: 'Recepción',
  tecnico: 'Técnico',
};

const ETIQUETAS_TIPO_ORDEN = {
  mantenimiento: 'Mantenimiento',
  garantia: 'Garantía',
};

export function formatearEstado(estado) {
  return ETIQUETAS_ESTADO[estado] || formatearTexto(estado);
}

export function formatearRol(rol) {
  return ETIQUETAS_ROL[rol] || formatearTexto(rol);
}

export function formatearTipoOrden(tipo) {
  return ETIQUETAS_TIPO_ORDEN[tipo] || formatearTexto(tipo);
}

function formatearTexto(valor = '') {
  return valor
    .replaceAll('_', ' ')
    .replace(/(^|\s)\S/g, (letra) => letra.toUpperCase());
}
