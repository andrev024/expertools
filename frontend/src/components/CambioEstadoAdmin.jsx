import { useState } from 'react';
import { useAuth } from '../context/authContextValue';
import { apiFetch } from '../api';
import { formatearEstado, formatearTipoOrden } from '../utils/textoUI';
import { abrirWhatsapp, enlaceSeguimiento, ENLACE_UBICACION, ENLACE_INSTAGRAM, formatearAccesorios } from '../utils/whatsapp';

// Lista completa de estados del flujo, para que el admin pueda corregir
// una orden que quedó en el estado equivocado sin seguir la secuencia normal.
const TODOS_LOS_ESTADOS = [
  'recibido', 'en_diagnostico', 'chatarra', 'cotizado', 'esperando_abono',
  'esperando_tecnico', 'esperando_respuesta', 'sin_respuesta', 'en_reparacion',
  'esperando_repuesto', 'finalizado_tecnico', 'en_revision_recepcion',
  'listo_para_entregar', 'entregado', 'no_autorizado',
];

// Estados cuya transición normal dispara un WhatsApp al cliente; si el admin
// fuerza una orden hacia uno de estos, se le ofrece reenviar ese mismo aviso
// (por ejemplo, si el mensaje original no se envió o se necesita reenviar).
const ESTADOS_CON_MENSAJE = ['recibido', 'cotizado', 'listo_para_entregar'];

function mensajeAvisoCreacion(orden) {
  return [
    `Hola ${orden.cliente_nombre || orden.cliente_empresa || 'cliente'}, te contactamos desde Expertools.`,
    'Registramos el ingreso de tu equipo para servicio técnico.',
    '',
    `- Código de seguimiento: ${orden.codigo_seguimiento}`,
    `- Tipo de servicio: ${formatearTipoOrden(orden.tipo)}`,
    `- Artículo: ${orden.articulo_tipo}${orden.marca ? ` ${orden.marca}` : ''}${orden.modelo ? ` ${orden.modelo}` : ''}`,
    orden.accesorios?.length ? `- Accesorios recibidos:\n${formatearAccesorios(orden.accesorios)}` : '',
    '',
    'Te avisaremos por este medio cuando tengamos el diagnóstico y la cotización.',
    '',
    `Consulta el seguimiento de tu orden en cualquier momento aquí: ${enlaceSeguimiento(orden.codigo_seguimiento)}`,
    '',
    `Instagram: ${ENLACE_INSTAGRAM}`,
    `Ubicación: ${ENLACE_UBICACION}`,
  ].filter(Boolean).join('\n');
}

function mensajeAvisoEntrega(orden) {
  return [
    `Hola ${orden.cliente_nombre || orden.cliente_empresa || 'cliente'}, te contactamos desde Expertools.`,
    'Tu equipo ya está listo para entregar.',
    '',
    `- Código de seguimiento: ${orden.codigo_seguimiento}`,
    `- Artículo: ${orden.articulo_tipo}${orden.marca ? ` ${orden.marca}` : ''}${orden.modelo ? ` ${orden.modelo}` : ''}`,
    '',
    'Gracias por confiar en ExperTools. Por favor, acércate a nuestras instalaciones para recoger tu equipo.',
    '',
    `Consulta el seguimiento de tu orden aquí: ${enlaceSeguimiento(orden.codigo_seguimiento)}`,
    '',
    `Instagram: ${ENLACE_INSTAGRAM}`,
    `Ubicación: ${ENLACE_UBICACION}`,
  ].join('\n');
}

function mensajeCotizacion(orden, cotizacion) {
  const repuestos = Array.isArray(cotizacion.repuestos) ? cotizacion.repuestos : [];
  return [
    `Hola ${orden.cliente_nombre || orden.cliente_empresa || 'cliente'}, te contactamos desde Expertools.`,
    '*Cotización de servicio:*',
    '',
    `- Código: ${orden.codigo_seguimiento}`,
    `- Artículo: ${orden.articulo_tipo}${orden.marca ? ` ${orden.marca}` : ''}${orden.modelo ? ` ${orden.modelo}` : ''}`,
    `- Diagnóstico: ${cotizacion.dictamen || ''}`,
    '- Repuestos:',
    ...(repuestos.length
      ? repuestos.map((repuesto) => `  - ${repuesto.referencia} (x${repuesto.cantidad})${repuesto.descripcion ? ` - ${repuesto.descripcion}` : ''}: $${(Number(repuesto.cantidad) * Number(repuesto.montoUnitario)).toLocaleString('es-CO')}`)
      : ['  - No requiere repuestos']),
    `- Total: $${Number(cotizacion.monto || 0).toLocaleString('es-CO')}`,
    Number(cotizacion.abono || 0) > 0 ? `- Abono requerido: $${Number(cotizacion.abono).toLocaleString('es-CO')}` : '',
    '',
    'Por favor confírmanos por este medio si autorizas la reparación, recuerda que la reparacion no inicia si no se recibe el abono en caso de que lo requiera.',
    '',
    `Sigue tu orden en tiempo real aquí: ${enlaceSeguimiento(orden.codigo_seguimiento)}`,
    '',
    `Instagram: ${ENLACE_INSTAGRAM}`,
    `Ubicación: ${ENLACE_UBICACION}`,
  ].filter(Boolean).join('\n');
}

// Visible solo para admin: permite forzar el estado de una orden a cualquier
// valor del flujo, para corregir errores operativos sin pasar por cada paso.
function CambioEstadoAdmin({ orden, onCambiado }) {
  const { usuario } = useAuth() || {};
  const [estadoElegido, setEstadoElegido] = useState('');
  const [reenviarMensaje, setReenviarMensaje] = useState(false);
  const [guardando, setGuardando] = useState(false);
  const [error, setError] = useState('');

  if (usuario?.rol !== 'admin') {
    return null;
  }

  const estadoActual = orden.estado_actual;
  const puedeReenviarMensaje = ESTADOS_CON_MENSAJE.includes(estadoElegido);

  async function aplicar() {
    if (!estadoElegido || estadoElegido === estadoActual) return;
    setError('');
    setGuardando(true);
    // La ventana se abre antes del await para que el navegador no bloquee el popup.
    const ventanaWhatsapp = reenviarMensaje && puedeReenviarMensaje ? window.open('', '_blank') : null;
    try {
      await apiFetch('cambiar_estado.php', {
        method: 'POST',
        body: JSON.stringify({ orden_id: orden.id, estado: estadoElegido, comentario: 'Cambio manual (admin)' }),
      });

      if (ventanaWhatsapp) {
        if (estadoElegido === 'recibido') {
          abrirWhatsapp(ventanaWhatsapp, orden.cliente_telefono, mensajeAvisoCreacion(orden));
        } else if (estadoElegido === 'listo_para_entregar') {
          abrirWhatsapp(ventanaWhatsapp, orden.cliente_telefono, mensajeAvisoEntrega(orden));
        } else if (estadoElegido === 'cotizado') {
          const cotizacion = await apiFetch(`cotizacion.php?orden_id=${orden.id}`);
          abrirWhatsapp(ventanaWhatsapp, orden.cliente_telefono, mensajeCotizacion(orden, cotizacion));
        }
      }

      setEstadoElegido('');
      setReenviarMensaje(false);
      onCambiado?.();
    } catch (err) {
      if (ventanaWhatsapp) ventanaWhatsapp.close();
      setError(err.message);
    } finally {
      setGuardando(false);
    }
  }

  return (
    <div className="cambio-estado-admin d-flex align-items-center gap-2 mt-2 flex-wrap">
      <select
        className="form-select form-select-sm w-auto"
        value={estadoElegido}
        onChange={(e) => setEstadoElegido(e.target.value)}
      >
        <option value="">Forzar estado (admin)...</option>
        {TODOS_LOS_ESTADOS.filter((estado) => estado !== estadoActual).map((estado) => (
          <option key={estado} value={estado}>{formatearEstado(estado)}</option>
        ))}
      </select>
      {puedeReenviarMensaje && (
        <div className="form-check form-check-inline">
          <input
            className="form-check-input"
            type="checkbox"
            id={`reenviar-mensaje-${orden.id}`}
            checked={reenviarMensaje}
            onChange={(e) => setReenviarMensaje(e.target.checked)}
          />
          <label className="form-check-label small" htmlFor={`reenviar-mensaje-${orden.id}`}>
            Reenviar mensaje de WhatsApp al cliente
          </label>
        </div>
      )}
      <button type="button" className="button button-secondary btn btn-outline-secondary btn-sm" disabled={!estadoElegido || guardando} onClick={aplicar}>
        {guardando ? 'Aplicando...' : 'Aplicar'}
      </button>
      {error && <span className="text-danger small">{error}</span>}
    </div>
  );
}

export default CambioEstadoAdmin;

