import { useState, useEffect } from 'react';
import { apiFetch } from '../api';
import { formatearEstado } from '../utils/textoUI';

// Transiciones simples (via cambiar_estado.php) que no requieren formulario extra
const TRANSICIONES_SIMPLES = {
  en_reparacion: ['esperando_repuesto', 'finalizado_tecnico'],
  esperando_repuesto: ['en_reparacion'],
  finalizado_tecnico: ['en_revision_recepcion'],
};

// Estados donde el tecnico tiene algo que hacer, en cualquiera de las 3 formas:
// tomar la orden, diagnosticar/cotizar, responder por el cliente, o transicion simple.
const ESTADOS_ACCIONABLES = [
  'recibido',
  'sin_respuesta',
  'en_diagnostico',
  'cotizado',
  'esperando_respuesta',
  'en_reparacion',
  'esperando_repuesto',
  'finalizado_tecnico',
];

function PanelTecnico() {
  const [ordenes, setOrdenes] = useState([]);
  const [cargando, setCargando] = useState(true);
  const [error, setError] = useState('');
  const [comentarios, setComentarios] = useState({});

  // Formularios de cotizacion, uno por orden: { ordenId: {repuestos, dictamen, monto} }
  const [formsCotizacion, setFormsCotizacion] = useState({});
  async function cargarOrdenes() {
    try {
      const datos = await apiFetch('ordenes.php');
      setOrdenes(datos.filter((o) => ESTADOS_ACCIONABLES.includes(o.estado_actual)));
    } catch (err) {
      setError(err.message);
    } finally {
      setCargando(false);
    }
  }

  useEffect(() => {
    const temporizador = setTimeout(() => cargarOrdenes(), 0);
    return () => clearTimeout(temporizador);
  }, []);

  async function cambiarEstadoSimple(ordenId, nuevoEstado) {
    setError('');
    try {
      await apiFetch('cambiar_estado.php', {
        method: 'POST',
        body: JSON.stringify({
          orden_id: ordenId,
          estado: nuevoEstado,
          comentario: comentarios[ordenId] || '',
        }),
      });
      cargarOrdenes();
    } catch (err) {
      setError(err.message);
    }
  }

  // Retoma una orden recibida o sin respuesta para iniciar el diagnóstico.
  function tomarOrden(ordenId) {
    cambiarEstadoSimple(ordenId, 'en_diagnostico');
  }

  function marcarChatarra(ordenId) {
    cambiarEstadoSimple(ordenId, 'chatarra');
  }

  function actualizarFormCotizacion(ordenId, campo, valor) {
    setFormsCotizacion({
      ...formsCotizacion,
      [ordenId]: { ...formsCotizacion[ordenId], [campo]: valor },
    });
  }

  function obtenerRepuestos(ordenId) {
    return formsCotizacion[ordenId]?.repuestos || [{ referencia: '', cantidad: 1, montoUnitario: '', descripcion: '' }];
  }

  function actualizarRepuesto(ordenId, indice, campo, valor) {
    const repuestos = obtenerRepuestos(ordenId).map((repuesto, posicion) => (
      posicion === indice ? { ...repuesto, [campo]: valor } : repuesto
    ));
    actualizarFormCotizacion(ordenId, 'repuestos', repuestos);
  }

  function agregarRepuesto(ordenId) {
    actualizarFormCotizacion(ordenId, 'repuestos', [
      ...obtenerRepuestos(ordenId),
      { referencia: '', cantidad: 1, montoUnitario: '', descripcion: '' },
    ]);
  }

  function quitarRepuesto(ordenId, indice) {
    const repuestos = obtenerRepuestos(ordenId).filter((_, posicion) => posicion !== indice);
    actualizarFormCotizacion(ordenId, 'repuestos', repuestos.length ? repuestos : [{ referencia: '', cantidad: 1, montoUnitario: '', descripcion: '' }]);
  }

  async function enviarCotizacion(ordenId) {
    setError('');
    const form = formsCotizacion[ordenId] || {};
    const orden = ordenes.find((item) => item.id === ordenId);
    const repuestos = (form.repuestos || []).filter((repuesto) => repuesto.referencia.trim());
    if (!form.dictamen || repuestos.some((repuesto) => !repuesto.cantidad || !repuesto.montoUnitario)) {
      setError('El dictamen y los datos completos de cada repuesto son requeridos');
      return;
    }

    const montoTotal = repuestos.reduce(
      (total, repuesto) => total + (Number(repuesto.cantidad) * Number(repuesto.montoUnitario)),
      0,
    );

    try {
      await apiFetch('cotizacion.php', {
        method: 'POST',
        body: JSON.stringify({
          orden_id: ordenId,
          repuestos: JSON.stringify(repuestos),
          dictamen: form.dictamen,
          monto: montoTotal,
        }),
      });
      const telefono = String(orden?.cliente_telefono || '').replace(/\D/g, '');
      const telefonoWhatsapp = telefono.length === 10 && telefono.startsWith('3') ? `57${telefono}` : telefono;
      const mensaje = [
        `\uD83D\uDC4B Hola ${orden?.cliente_nombre || 'cliente'}, te contactamos desde Expertools.`,
        '\uD83E\uDDFE Te enviamos la cotización de tu servicio:',
        '',
        `\uD83D\uDD16 Código de seguimiento: ${orden?.codigo_seguimiento || ordenId}`,
        `\uD83D\uDD27 Artículo: ${orden?.articulo_tipo || ''}${orden?.marca ? ` ${orden.marca}` : ''}${orden?.modelo ? ` ${orden.modelo}` : ''}`,
        `\uD83D\uDD0D Diagnóstico: ${form.dictamen}`,
        `\uD83E\uDDE9 Repuestos: ${form.repuestos?.filter((repuesto) => repuesto.referencia.trim()).map((repuesto) => `${repuesto.referencia} (x${repuesto.cantidad})${repuesto.descripcion ? `: ${repuesto.descripcion}` : ''}`).join(', ') || 'No requiere repuestos'}`,
        `\uD83D\uDCB0 Valor total: $${montoTotal.toLocaleString('es-CO')}`,
        '',
        '\u2705 Por favor confírmanos si autorizas la reparación.',
      ].join('\n');
      window.open(`https://wa.me/${telefonoWhatsapp}?text=${encodeURIComponent(mensaje)}`, '_blank', 'noopener,noreferrer');
      cargarOrdenes();
    } catch (err) {
      setError(err.message);
    }
  }

  async function responderCliente(ordenId, respuesta) {
    setError('');
    try {
      await apiFetch('cotizacion.php', {
        method: 'PATCH',
        body: JSON.stringify({
          orden_id: ordenId,
          respuesta,
        }),
      });
      cargarOrdenes();
    } catch (err) {
      setError(err.message);
    }
  }

  if (cargando) return <p>Cargando...</p>;

  return (
    <div className="operations-panel">
      <h2 className="h4 border-start border-4 ps-3">Órdenes por atender (orden de llegada)</h2>
      {error && <p className="alert alert-danger">{error}</p>}
      {ordenes.length === 0 && <p className="alert alert-light border">No hay órdenes pendientes por ahora.</p>}

      {ordenes.map((orden) => (
        <div key={orden.id} className="order-card card shadow-sm rounded-3 border-0">
          <h3 className="h5">{orden.codigo_seguimiento}</h3>
          <p>Cliente: {orden.cliente_nombre} ({orden.cliente_telefono})</p>
          <p>Artículo: {orden.articulo_tipo} {orden.marca}</p>
          <p>Estado actual: <strong className="badge rounded-pill bg-success-subtle text-success">{formatearEstado(orden.estado_actual)}</strong></p>

          {/* Estado: recibido -> boton para tomar la orden */}
          {(orden.estado_actual === 'recibido' || orden.estado_actual === 'sin_respuesta') && (
            <button className="button button-primary btn btn-primary" onClick={() => tomarOrden(orden.id)}>Tomar orden (empezar diagnóstico)</button>
          )}

          {/* Estado: en_diagnostico -> formulario de cotizacion + opcion chatarra */}
          {orden.estado_actual === 'en_diagnostico' && (
            <div>
              <textarea
                className="form-control mb-2"
                placeholder="Dictamen (qué falló y por qué)"
                value={formsCotizacion[orden.id]?.dictamen || ''}
                onChange={(e) => actualizarFormCotizacion(orden.id, 'dictamen', e.target.value)}
                style={{ display: 'block', width: '100%', marginBottom: '6px' }}
              />
              <div className="mb-2">
                <p className="mb-1"><strong>Repuestos</strong></p>
                {obtenerRepuestos(orden.id).map((repuesto, indice) => (
                  <div className="row g-2 mb-2" key={`${orden.id}-repuesto-${indice}`}>
                    <div className="col-md-3">
                      <input
                        className="form-control"
                        placeholder="Referencia"
                        value={repuesto.referencia}
                        onChange={(e) => actualizarRepuesto(orden.id, indice, 'referencia', e.target.value)}
                      />
                    </div>
                    <div className="col-md-2">
                      <input
                        className="form-control"
                        type="number"
                        min="1"
                        placeholder="Cantidad"
                        value={repuesto.cantidad}
                        onChange={(e) => actualizarRepuesto(orden.id, indice, 'cantidad', e.target.value)}
                      />
                    </div>
                    <div className="col-md-2">
                      <input
                        className="form-control"
                        type="number"
                        min="0"
                        step="0.01"
                        placeholder="Valor unitario"
                        value={repuesto.montoUnitario}
                        onChange={(e) => actualizarRepuesto(orden.id, indice, 'montoUnitario', e.target.value)}
                      />
                      <small className="text-muted">
                        Total: ${(Number(repuesto.cantidad || 0) * Number(repuesto.montoUnitario || 0)).toLocaleString('es-CO')}
                      </small>
                    </div>
                    <div className="col-md-2">
                      <input
                        className="form-control"
                        placeholder="Descripción (opcional)"
                        value={repuesto.descripcion}
                        onChange={(e) => actualizarRepuesto(orden.id, indice, 'descripcion', e.target.value)}
                      />
                    </div>
                    <div className="col-md-2">
                      <button type="button" className="button button-secondary btn btn-outline-secondary w-100" onClick={() => quitarRepuesto(orden.id, indice)}>
                        Quitar
                      </button>
                    </div>
                  </div>
                ))}
                <p className="fw-semibold">
                  Total cotizado: ${(obtenerRepuestos(orden.id)
                    .filter((repuesto) => repuesto.referencia.trim())
                    .reduce((total, repuesto) => total + (Number(repuesto.cantidad || 0) * Number(repuesto.montoUnitario || 0)), 0))
                    .toLocaleString('es-CO')}
                </p>
                <button type="button" className="button button-secondary btn btn-outline-secondary" onClick={() => agregarRepuesto(orden.id)}>
                  Agregar repuesto
                </button>
              </div>
              <button className="button button-primary btn btn-primary" onClick={() => enviarCotizacion(orden.id)}>Enviar cotización</button>{' '}
              <button className="button button-danger btn btn-outline-danger" onClick={() => marcarChatarra(orden.id)} style={{ color: 'red' }}>
                Marcar como chatarra (irreparable)
              </button>
            </div>
          )}

          {/* Estado: cotizado -> registrar la respuesta del cliente */}
          {(orden.estado_actual === 'cotizado' || orden.estado_actual === 'esperando_respuesta') && (
            <div>
              <button className="button button-primary btn btn-primary" onClick={() => responderCliente(orden.id, 'aprobada')}>Cliente aprobó</button>{' '}
              <button className="button button-danger btn btn-outline-danger" onClick={() => responderCliente(orden.id, 'rechazada')}>Cliente no aprobó</button>{' '}
              <button className="button button-secondary btn btn-outline-secondary" onClick={() => responderCliente(orden.id, 'en_espera')}>
                En espera de respuesta
              </button>
            </div>
          )}

          {/* Estados con transicion simple */}
          {TRANSICIONES_SIMPLES[orden.estado_actual] && (
            <div>
              <input
                className="form-control mb-2"
                type="text"
                placeholder="Comentario (opcional)"
                value={comentarios[orden.id] || ''}
                onChange={(e) => setComentarios({ ...comentarios, [orden.id]: e.target.value })}
                style={{ display: 'block', marginBottom: '6px', width: '100%' }}
              />
              {TRANSICIONES_SIMPLES[orden.estado_actual].map((siguiente) => (
                <button className="button button-secondary btn btn-outline-secondary" key={siguiente} onClick={() => cambiarEstadoSimple(orden.id, siguiente)} style={{ marginRight: '8px' }}>
                  Pasar a: {formatearEstado(siguiente)}
                </button>
              ))}
            </div>
          )}
        </div>
      ))}
    </div>
  );
}

export default PanelTecnico;
