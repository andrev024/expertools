const ETIQUETAS_ESTADO = {
  recibido: 'Recibido',
  en_diagnostico: 'En diagnóstico',
  cotizado: 'Cotizado',
  esperando_abono: 'Esperando abono',
  esperando_tecnico: 'Esperando técnico',
  esperando_respuesta: 'En espera de respuesta',
  en_reparacion: 'En reparación',
  esperando_repuesto: 'Esperando repuesto',
  finalizado_tecnico: 'Finalizado por técnico',
  en_revision_recepcion: 'En revisión de recepción',
  listo_para_entregar: 'Listo para entregar',
  entregado: 'Entregado',
  chatarra: 'Chatarra',
  no_autorizado: 'No autorizado',
  historico: 'Histórico / otro',
};

// Ordenes migradas traen decenas de variantes de estado en mayusculas y con errores de
// tipeo (ENTREGADA, ENTREGADA Y PAGADA, ETREGADA Y PGDA, COT ENV, NO JUSTIFICA, etc.).
// Se agrupan por patrón para no saturar los filtros con cada variante como una opción distinta.
const GRUPOS_ESTADO_HISTORICO = [
  { clave: 'entregado', patron: /ENTREGAD/ },
  { clave: 'chatarra', patron: /CHATARRA/ },
  { clave: 'no_autorizado', patron: /NO.?AUTORIZAD|NO.?JUSTIFIC/ },
  { clave: 'cotizado', patron: /COT/ },
  { clave: 'recibido', patron: /INGRESO/ },
];

// Devuelve la clave canonica de un estado, agrupando variantes historicas desconocidas
// bajo 'historico' para que el filtro de estado no muestre decenas de opciones.
export function normalizarEstado(estado) {
  const valor = (estado || '').trim();
  if (ETIQUETAS_ESTADO[valor]) return valor;
  const mayus = valor.toUpperCase();
  const grupo = GRUPOS_ESTADO_HISTORICO.find((g) => g.patron.test(mayus));
  return grupo ? grupo.clave : 'historico';
}

const ETIQUETAS_ROL = {
  admin: 'Administrador',
  recepcion: 'Recepción',
  tecnico: 'Técnico',
};

const ETIQUETAS_TIPO_ORDEN = {
  reparacion: 'Reparación',
  mantenimiento: 'Reparación',
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
