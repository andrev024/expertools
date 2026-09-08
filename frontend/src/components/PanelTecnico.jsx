import { useState, useEffect } from 'react';
import { apiFetch } from '../api';
import { formatearEstado } from '../utils/textoUI';
import HistorialOrden from './HistorialOrden';

// Transiciones simples (via cambiar_estado.php) que no requieren formulario extra
const TRANSICIONES_SIMPLES = {
  esperando_abono: ['en_reparacion'],
  en_reparacion: ['esperando_repuesto', 'finalizado_tecnico'],
  esperando_repuesto: ['en_reparacion'],
  finalizado_tecnico: ['en_revision_recepcion'],
};

function antiguedadEstado(fecha) {
  if (!fecha) return null;
  const horas = Math.max(0, Math.floor((Date.now() - new Date(fecha.replace(' ', 'T')).getTime()) / 3600000));
  return { horas, clase: horas >= 48 ? 'alert-danger' : horas >= 24 ? 'alert-warning' : 'alert-success' };
}

function mostrarFecha(fecha) {
  return fecha ? new Date(fecha.replace(' ', 'T')).toLocaleString('es-CO') : 'sin fecha';
}

function fechaEstado(orden) {
  return orden.estado_desde || orden.fecha_ingreso;
}

function antiguedadIngreso(fecha) {
  if (!fecha) return null;
  const dias = Math.max(0, Math.floor((Date.now() - new Date(fecha.replace(' ', 'T')).getTime()) / 86400000));
  return {
    dias,
    clase: dias >= 28 ? 'antiguedad-roja' : dias >= 14 ? 'antiguedad-naranja' : dias >= 7 ? 'antiguedad-amarilla' : '',
  };
}

function coincideFiltroAntiguedad(fecha, filtro) {
  if (filtro === 'todas') return true;
  const dias = antiguedadIngreso(fecha)?.dias || 0;
  if (filtro === 'una_semana') return dias >= 7;
  if (filtro === 'dos_tres_semanas') return dias >= 14 && dias < 28;
  return dias >= 28;
}

// Estados donde el tecnico tiene algo que hacer, en cualquiera de las 3 formas:
// tomar la orden, diagnosticar/cotizar, responder por el cliente, o transicion simple.
const ESTADOS_ACCIONABLES = [
  'recibido',
  'sin_respuesta',
  'en_diagnostico',
  'cotizado',
  'esperando_respuesta',
  'esperando_abono',
  'esperando_tecnico',
  'en_reparacion',
  'esperando_repuesto',
  'finalizado_tecnico',
];

function PanelTecnico() {
  const [ordenes, setOrdenes] = useState([]);
  const [cargando, setCargando] = useState(true);
  const [error, setError] = useState('');
  const [editandoUbicacion, setEditandoUbicacion] = useState(null);
  const [ubicaciones, setUbicaciones] = useState({});
  const [filtroAntiguedad, setFiltroAntiguedad] = useState('todas');

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
        }),
      });
      cargarOrdenes();
    } catch (err) {
      setError(err.message);
    }
  }

  async function guardarUbicacion(ordenId) {
    const ubicacion = (ubicaciones[ordenId] || '').trim();
    if (!ubicacion) return;
    setError('');
    try {
      await apiFetch('ordenes.php', {
        method: 'PATCH',
        body: JSON.stringify({ orden_id: ordenId, ubicacion }),
      });
      setEditandoUbicacion(null);
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
    if (Number(form.abono || 0) > montoTotal) {
      setError('El abono no puede ser mayor que el total cotizado');
      return;
    }
    const ventanaWhatsapp = window.open('', '_blank');

    try {
      await apiFetch('cotizacion.php', {
        method: 'POST',
        body: JSON.stringify({
          orden_id: ordenId,
          repuestos: JSON.stringify(repuestos),
          dictamen: form.dictamen,
          monto: montoTotal,
          abono: Number(form.abono || 0),
        }),
      });
      const telefono = String(orden?.cliente_telefono || '').replace(/\D/g, '');
      const telefonoWhatsapp = telefono.length === 10 && telefono.startsWith('3') ? `57${telefono}` : telefono;
      const mensaje = [
        `Hola ${orden?.cliente_nombre || 'cliente'}, te contactamos desde Expertools.`,
        '✅ Cotización de servicio:',
        '',
        `Código: ${orden?.codigo_seguimiento || ordenId}`,
        `Artículo: ${orden?.articulo_tipo || ''}${orden?.marca ? ` ${orden.marca}` : ''}${orden?.modelo ? ` ${orden.modelo}` : ''}`,
        `Diagnóstico: ${form.dictamen}`,
        `Repuestos: ${form.repuestos?.filter((repuesto) => repuesto.referencia.trim()).map((repuesto) => `${repuesto.referencia} (x${repuesto.cantidad})${repuesto.descripcion ? `: ${repuesto.descripcion}` : ''}`).join(', ') || 'No requiere repuestos'}`,
        `Total: $${montoTotal.toLocaleString('es-CO')}`,
        Number(form.abono || 0) > 0 ? `Abono requerido: $${Number(form.abono).toLocaleString('es-CO')}` : '',
        '',
        'Por favor confírmanos por este medio si autorizas la reparación. El técnico registrará tu respuesta.',
      ].join('\n');
      const urlWhatsapp = `https://wa.me/${telefonoWhatsapp}?text=${encodeURIComponent(mensaje)}`;
      if (ventanaWhatsapp) {
        ventanaWhatsapp.location.href = urlWhatsapp;
      } else {
        window.location.href = urlWhatsapp;
      }
      cargarOrdenes();
    } catch (err) {
      if (ventanaWhatsapp) ventanaWhatsapp.close();
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
      <div className="d-flex align-items-center gap-2 mb-3">
        <label className="fw-semibold" htmlFor="filtro-antiguedad-tecnico">Filtrar por antigüedad</label>
        <select id="filtro-antiguedad-tecnico" className="form-select" style={{ maxWidth: '280px' }} value={filtroAntiguedad} onChange={(e) => setFiltroAntiguedad(e.target.value)}>
          <option value="todas">Todas las órdenes</option>
          <option value="una_semana">1 semana o más</option>
          <option value="dos_tres_semanas">2 a 3 semanas</option>
          <option value="cuatro_semanas">4 semanas o más</option>
        </select>
      </div>
      <div className="antiguedad-leyenda" aria-label="Leyenda de antigüedad de órdenes">
        <span><i className="leyenda-color antiguedad-amarilla" /> 1 semana</span>
        <span><i className="leyenda-color antiguedad-naranja" /> 2 a 3 semanas</span>
        <span><i className="leyenda-color antiguedad-roja" /> 4 semanas o más</span>
      </div>
      {error && <p className="alert alert-danger">{error}</p>}
      {ordenes.length === 0 && <p className="alert alert-light border">No hay órdenes pendientes por ahora.</p>}

      {ordenes.filter((orden) => coincideFiltroAntiguedad(orden.fecha_ingreso, filtroAntiguedad)).map((orden) => (
        <div key={orden.id} className={`order-card card shadow-sm rounded-3 border-0 ${antiguedadIngreso(orden.fecha_ingreso)?.clase || ''}`}>
          <div className="order-card-header">
            <div>
              <span className="order-kicker">Trabajo en cola</span>
              <h3 className="h5">{orden.codigo_seguimiento}</h3>
            </div>
            <strong className="status-badge">{formatearEstado(orden.estado_actual)}</strong>
          </div>
          {antiguedadEstado(fechaEstado(orden))?.horas >= 24 && <p className={`alert ${antiguedadEstado(fechaEstado(orden)).clase} py-2`}>Pendiente hace {antiguedadEstado(fechaEstado(orden)).horas} h</p>}
          <p className="small text-secondary">Estado desde: {mostrarFecha(fechaEstado(orden))}</p>
          {antiguedadIngreso(orden.fecha_ingreso)?.dias >= 7 && <p className={`alert antiguedad-aviso py-2 mb-2 ${antiguedadIngreso(orden.fecha_ingreso).clase}`}>Orden ingresada hace {antiguedadIngreso(orden.fecha_ingreso).dias} días</p>}
          <div className="order-location mb-3">
            <strong>Ubicación:</strong> {orden.ubicacion || 'Sin ubicación registrada'}
            {editandoUbicacion === orden.id ? (
              <div className="d-flex gap-2 mt-2">
                <input className="form-control" type="text" placeholder="Ej. Repisa A-3" value={ubicaciones[orden.id] ?? orden.ubicacion ?? ''} onChange={(e) => setUbicaciones({ ...ubicaciones, [orden.id]: e.target.value })} />
                <button type="button" className="button button-primary btn btn-primary" onClick={() => guardarUbicacion(orden.id)}>Guardar</button>
                <button type="button" className="button button-secondary btn btn-outline-secondary" onClick={() => setEditandoUbicacion(null)}>Cancelar</button>
              </div>
            ) : (
              <button type="button" className="button button-quiet ms-2" onClick={() => { setUbicaciones({ ...ubicaciones, [orden.id]: orden.ubicacion || '' }); setEditandoUbicacion(orden.id); }}>Cambiar ubicación</button>
            )}
          </div>
          <div className="order-summary-grid">
            <p><span>Cliente</span>{orden.cliente_nombre} <small>{orden.cliente_telefono}</small></p>
            <p><span>Artículo</span>{orden.articulo_tipo} {orden.marca || ''} {orden.modelo || ''}</p>
            {orden.accesorios && <p><span>Accesorios</span>{orden.accesorios}</p>}
          </div>

          {/* Estado: recibido -> boton para tomar la orden */}
          {(orden.estado_actual === 'recibido' || orden.estado_actual === 'sin_respuesta' || orden.estado_actual === 'esperando_tecnico') && (
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
                        placeholder="Nombre"
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
                        placeholder="Referencia (opcional)"
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
                <input
                  className="form-control mb-2"
                  type="number"
                  min="0"
                  step="0.01"
                  placeholder="Abono requerido (opcional)"
                  value={formsCotizacion[orden.id]?.abono || ''}
                  onChange={(e) => actualizarFormCotizacion(orden.id, 'abono', e.target.value)}
                />
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
              {TRANSICIONES_SIMPLES[orden.estado_actual].map((siguiente) => (
                <button className="button button-secondary btn btn-outline-secondary" key={siguiente} onClick={() => cambiarEstadoSimple(orden.id, siguiente)} style={{ marginRight: '8px' }}>
                  Pasar a: {formatearEstado(siguiente)}
                </button>
              ))}
            </div>
          )}
          <HistorialOrden ordenId={orden.id} />
        </div>
      ))}
    </div>
  );
}

export default PanelTecnico;
