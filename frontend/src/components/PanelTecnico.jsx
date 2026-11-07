import { useState, useEffect, useCallback, useRef } from 'react';
import { apiFetch } from '../api';
import { formatearEstado } from '../utils/textoUI';
import HistorialOrden from './HistorialOrden';
import EditorRepuestos from './EditorRepuestos';
import CambioEstadoAdmin from './CambioEstadoAdmin';
import OrdenAcordeon from './OrdenAcordeon';
import MenuAcciones from './MenuAcciones';
import { abrirWhatsapp, textoSeguimiento, ENLACE_UBICACION, ENLACE_INSTAGRAM } from '../utils/whatsapp';
import { descargarFacturaOrden } from '../utils/pdf';
import ControlesListaOrdenes from './ControlesListaOrdenes';

// Transiciones simples (via cambiar_estado.php) que no requieren formulario extra
const TRANSICIONES_SIMPLES = {
  esperando_abono: ['en_reparacion'],
  en_reparacion: ['esperando_repuesto', 'finalizado_tecnico'],
  esperando_repuesto: ['en_reparacion'],
  finalizado_tecnico: ['en_revision_recepcion'],
};

function antiguedadEstado(fecha) {
  if (!fecha) return null;
  const horas = Math.max(0, Math.floor((Date.now() - parsearFechaBogota(fecha).getTime()) / 3600000));
  return { horas, clase: horas >= 48 ? 'alert-danger' : horas >= 24 ? 'alert-warning' : 'alert-success' };
}

function mostrarFecha(fecha) {
  return fecha ? parsearFechaBogota(fecha).toLocaleString('es-CO', { timeZone: 'America/Bogota' }) : 'sin fecha';
}

function parsearFechaBogota(fecha) {
  let fechaNormalizada = String(fecha).trim();
  fechaNormalizada = fechaNormalizada.includes('T') ? fechaNormalizada : fechaNormalizada.replace(' ', 'T');
  fechaNormalizada = fechaNormalizada.replace(/([+-]\d{2})(\d{2})$/, '$1:$2');
  if (/([+-]\d{2})$/.test(fechaNormalizada)) fechaNormalizada += ':00';
  const tieneZonaHoraria = /(?:Z|[+-]\d{2}:\d{2})$/i.test(fechaNormalizada);
  return new Date(tieneZonaHoraria ? fechaNormalizada : `${fechaNormalizada}-05:00`);
}

function fechaEstado(orden) {
  return orden.estado_desde || orden.fecha_ingreso;
}

function antiguedadIngreso(fecha) {
  if (!fecha) return null;
  const dias = Math.max(0, Math.floor((Date.now() - parsearFechaBogota(fecha).getTime()) / 86400000));
  return {
    dias,
    clase: dias >= 28 ? 'antiguedad-roja' : dias >= 14 ? 'antiguedad-naranja' : dias >= 7 ? 'antiguedad-amarilla' : '',
  };
}

// Estados desde los que ya existe una cotización registrada y por lo tanto
// se pueden editar sus repuestos (agregar uno nuevo, corregir cantidades, etc.)
const ESTADOS_CON_COTIZACION = [
  'cotizado', 'esperando_respuesta', 'esperando_abono', 'esperando_tecnico',
  'en_reparacion', 'esperando_repuesto', 'finalizado_tecnico', 'en_revision_recepcion', 'listo_para_entregar',
];

// Precio sugerido de mano de obra por tipo de artículo. Falta definir los valores
// reales por tipo de máquina; mientras tanto queda en blanco para que el técnico lo digite.
const PRECIO_MANO_OBRA_POR_TIPO = {};

function repuestoManoObraInicial(tipoArticulo) {
  return {
    referencia: 'Mano de obra',
    cantidad: 1,
    montoUnitario: PRECIO_MANO_OBRA_POR_TIPO[tipoArticulo] ?? 1,
    descripcion: '',
  };
}

function PanelTecnico() {
  const [ordenes, setOrdenes] = useState([]);
  const [listaMeta, setListaMeta] = useState(null);
  const [cargando, setCargando] = useState(true);
  const [error, setError] = useState('');
  const [editandoUbicacion, setEditandoUbicacion] = useState(null);
  const [ubicaciones, setUbicaciones] = useState({});
  const [filtroAntiguedad, setFiltroAntiguedad] = useState('todas');
  const [filtroEstadoTecnico, setFiltroEstadoTecnico] = useState('todos');
  const [busqueda, setBusqueda] = useState('');
  const [pagina, setPagina] = useState(1);
  const [porPagina, setPorPagina] = useState(10);
  const [modoVista, setModoVista] = useState(() => localStorage.getItem('expertools-vista-tecnico') || 'tarjetas');
  const [ordenExpandida, setOrdenExpandida] = useState(null);
  const solicitudActual = useRef(0);

  // Formularios de cotizacion, uno por orden: { ordenId: {repuestos, dictamen, monto} }
  const [formsCotizacion, setFormsCotizacion] = useState({});
  const cargarOrdenes = useCallback(async () => {
    const solicitud = ++solicitudActual.current;
    try {
      const parametros = new URLSearchParams({
        modo: 'lista',
        vista: 'tecnico',
        pagina: String(pagina),
        por_pagina: String(porPagina),
        buscar: busqueda,
        estado: filtroEstadoTecnico,
        antiguedad: filtroAntiguedad,
      });
      const datos = await apiFetch(`ordenes.php?${parametros.toString()}`);
      if (solicitud !== solicitudActual.current) return;
      setOrdenes(datos.ordenes);
      setListaMeta(datos);
      setError('');
    } catch (err) {
      if (solicitud === solicitudActual.current) setError(err.message);
    } finally {
      if (solicitud === solicitudActual.current) setCargando(false);
    }
  }, [busqueda, filtroAntiguedad, filtroEstadoTecnico, pagina, porPagina]);

  useEffect(() => {
    const temporizador = setTimeout(cargarOrdenes, 200);
    return () => clearTimeout(temporizador);
  }, [cargarOrdenes]);

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

  // Retoma una orden: si viene de esperando_tecnico la cotizacion ya fue aprobada,
  // asi que pasa directo a reparacion; si no, inicia el diagnostico.
  function tomarOrden(ordenId, estadoActual) {
    const nuevoEstado = estadoActual === 'esperando_tecnico' ? 'en_reparacion' : 'en_diagnostico';
    cambiarEstadoSimple(ordenId, nuevoEstado);
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
    if (formsCotizacion[ordenId]?.repuestos) return formsCotizacion[ordenId].repuestos;
    const orden = ordenes.find((item) => item.id === ordenId);
    return [repuestoManoObraInicial(orden?.articulo_tipo)];
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
    const orden = ordenes.find((item) => item.id === ordenId);
    actualizarFormCotizacion(ordenId, 'repuestos', repuestos.length ? repuestos : [repuestoManoObraInicial(orden?.articulo_tipo)]);
  }

  async function enviarCotizacion(ordenId) {
    setError('');
    const form = formsCotizacion[ordenId] || {};
    const orden = ordenes.find((item) => item.id === ordenId);
    const repuestos = obtenerRepuestos(ordenId)
      .filter((repuesto) => String(repuesto.referencia || '').trim())
      .map((repuesto) => ({
        ...repuesto,
        referencia: String(repuesto.referencia || '').trim(),
        cantidad: Number(repuesto.cantidad),
        montoUnitario: Number(repuesto.montoUnitario),
      }));
    if (!form.dictamen?.trim()) {
      setError('El dictamen es requerido');
      return;
    }
    const repuestoIncompleto = repuestos.find((repuesto) => !repuesto.cantidad || !repuesto.montoUnitario);
    if (repuestoIncompleto) {
      setError(`Falta cantidad y/o valor unitario en el repuesto "${repuestoIncompleto.referencia}"`);
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
      if (orden) {
        const cotizacion = { dictamen: form.dictamen, repuestos, monto: montoTotal, abono: Number(form.abono || 0) };
        await descargarFacturaOrden({ orden, cotizacion, sufijo: 'cotizacion' });
      }
      const mensaje = [
        `Hola ${orden?.cliente_nombre || 'cliente'}, te contactamos desde Expertools.`,
        '*Cotización de servicio:*',
        '',
        `- Código: ${orden?.codigo_seguimiento || ordenId}`,
        `- Artículo: ${orden?.articulo_tipo || ''}${orden?.marca ? ` ${orden.marca}` : ''}${orden?.modelo ? ` ${orden.modelo}` : ''}`,
        `- Diagnóstico: ${form.dictamen}`,
        '- Repuestos:',
        ...(repuestos.length
          ? repuestos.map((repuesto) => `  - ${repuesto.referencia} (x${repuesto.cantidad})${repuesto.descripcion ? ` - ${repuesto.descripcion}` : ''}: $${(Number(repuesto.cantidad) * Number(repuesto.montoUnitario)).toLocaleString('es-CO')}`)
          : ['  - No requiere repuestos']),
        `- Total: $${montoTotal.toLocaleString('es-CO')}`,
        Number(form.abono || 0) > 0 ? `- Abono requerido: $${Number(form.abono).toLocaleString('es-CO')}` : '',
        '',
        'Por favor confírmanos por este medio si autorizas la reparación, recuerda que la reparacion no inicia si no se recibe el abono en caso de que lo requiera.',
        '',
        textoSeguimiento(orden?.codigo_seguimiento),
        '',
        `Instagram: ${ENLACE_INSTAGRAM}`,
        `Ubicación: ${ENLACE_UBICACION}`,
      ].join('\n');
      abrirWhatsapp(ventanaWhatsapp, orden?.cliente_telefono, mensaje);
      cargarOrdenes();
    } catch (err) {
      if (ventanaWhatsapp) ventanaWhatsapp.close();
      setError(err.message);
    }
  }

  async function responderCliente(ordenId, respuesta) {
    setError('');
    const orden = ordenes.find((item) => item.id === ordenId);
    // La ventana se abre antes del await para que el navegador no bloquee el popup.
    const ventanaWhatsapp = respuesta === 'aprobada' ? window.open('', '_blank') : null;
    try {
      await apiFetch('cotizacion.php', {
        method: 'PATCH',
        body: JSON.stringify({
          orden_id: ordenId,
          respuesta,
        }),
      });
      if (respuesta === 'aprobada' && orden) {
        if (ventanaWhatsapp) {
          const mensaje = [
            `Hola ${orden.cliente_nombre || orden.cliente_empresa || 'cliente'}, te contactamos desde Expertools.`,
            'Confirmamos que autorizaste la reparación. Ya estamos trabajando en tu equipo.',
            '',
            `- Código: ${orden.codigo_seguimiento}`,
            textoSeguimiento(orden.codigo_seguimiento),
          ].join('\n');
          abrirWhatsapp(ventanaWhatsapp, orden.cliente_telefono, mensaje);
        }
      } else if (ventanaWhatsapp) {
        ventanaWhatsapp.close();
      }
      cargarOrdenes();
    } catch (err) {
      if (ventanaWhatsapp) ventanaWhatsapp.close();
      setError(err.message);
    }
  }

  if (cargando) return <p>Cargando...</p>;

  function alternarExpandida(ordenId) {
    setOrdenExpandida((actual) => (actual === ordenId ? null : ordenId));
  }

  const ordenesFiltradas = ordenes;
  const conteosEstado = listaMeta?.conteos_estado || {};
  const gruposEstadoTecnico = [
    { key: 'recibido', label: 'Recibido', estados: ['recibido', 'sin_respuesta'] },
    { key: 'cotizado', label: 'Cotizado', estados: ['cotizado'] },
    { key: 'esperando_respuesta', label: 'En espera de respuesta', estados: ['esperando_respuesta'] },
    { key: 'esperando_abono', label: 'Esperando abono', estados: ['esperando_abono'] },
    { key: 'en_reparacion', label: 'En reparación', estados: ['en_diagnostico', 'esperando_tecnico', 'en_reparacion', 'esperando_repuesto', 'finalizado_tecnico'] },
  ];

  return (
    <div className={`operations-panel modo-lista-${modoVista}`}>
      <h2 className="h4 border-start border-4 ps-3">Órdenes por atender (orden de llegada)</h2>
      <div className="d-flex align-items-center gap-2 mb-3">
        <label className="fw-semibold" htmlFor="filtro-antiguedad-tecnico">Filtrar por antigüedad</label>
        <select id="filtro-antiguedad-tecnico" className="form-select" style={{ maxWidth: '280px' }} value={filtroAntiguedad} onChange={(e) => { setFiltroAntiguedad(e.target.value); setPagina(1); }}>
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
      <div className="tabs-filtro-estado" role="tablist" aria-label="Filtrar por estado">
        <button type="button" className={`resumen-chip resumen-chip-button ${filtroEstadoTecnico === 'todos' ? 'activo' : ''}`} onClick={() => { setFiltroEstadoTecnico('todos'); setPagina(1); }}>
          <strong>{conteosEstado && Object.values(conteosEstado).reduce((total, cantidad) => total + cantidad, 0)}</strong> Todos
        </button>
        {gruposEstadoTecnico.map(({ key, label, estados }) => {
          const cantidad = estados.reduce((total, estado) => total + (conteosEstado[estado] || 0), 0);
          return (
          <button type="button" key={key} className={`resumen-chip resumen-chip-button ${filtroEstadoTecnico === key ? 'activo' : ''}`} onClick={() => { setFiltroEstadoTecnico(key); setPagina(1); }}>
            <strong>{cantidad}</strong> {label}
          </button>
          );
        })}
      </div>
      <ControlesListaOrdenes
        busqueda={busqueda}
        onBusqueda={(valor) => { setBusqueda(valor); setPagina(1); }}
        pagina={listaMeta?.pagina || pagina}
        onPagina={setPagina}
        totalPaginas={listaMeta?.total_paginas || 1}
        total={listaMeta?.total || 0}
        porPagina={porPagina}
        onPorPagina={(valor) => { setPorPagina(valor); setPagina(1); }}
        modoVista={modoVista}
        onModoVista={(modo) => {
          setModoVista(modo);
          localStorage.setItem('expertools-vista-tecnico', modo);
        }}
      />
      {error && <p className="alert alert-danger">{error}</p>}
      {listaMeta?.total === 0 && <p className="alert alert-light border">{busqueda ? 'No hay órdenes que coincidan con la búsqueda y los filtros.' : 'No hay órdenes pendientes por ahora.'}</p>}

      {ordenesFiltradas.map((orden) => (
        <OrdenAcordeon
          key={orden.id}
          orden={orden}
          kicker="Trabajo en cola"
          claseExtra={`${antiguedadIngreso(orden.fecha_ingreso)?.clase || ''} ${modoVista === 'compacto' ? 'orden-acordeon-compacto' : ''}`}
          expandido={ordenExpandida === orden.id}
          onToggle={() => alternarExpandida(orden.id)}
        >
          {antiguedadEstado(fechaEstado(orden))?.horas >= 24 && <p className={`alert ${antiguedadEstado(fechaEstado(orden)).clase} py-2`}>Pendiente hace {antiguedadEstado(fechaEstado(orden)).horas} h</p>}
          <p className="small text-secondary">Estado desde: {mostrarFecha(fechaEstado(orden))}</p>
          {antiguedadIngreso(orden.fecha_ingreso)?.dias >= 7 && <p className={`alert antiguedad-aviso py-2 mb-2 ${antiguedadIngreso(orden.fecha_ingreso).clase}`}>Orden ingresada hace {antiguedadIngreso(orden.fecha_ingreso).dias} días</p>}
          <p className="order-location mb-3">
            <strong>Ubicación:</strong> {orden.ubicacion || 'Sin ubicación registrada'}
            {editandoUbicacion === orden.id && (
              <span className="d-flex gap-2 mt-2">
                <input className="form-control" type="text" placeholder="Ej. Repisa A-3" value={ubicaciones[orden.id] ?? orden.ubicacion ?? ''} onChange={(e) => setUbicaciones({ ...ubicaciones, [orden.id]: e.target.value })} />
                <button type="button" className="button button-primary btn btn-primary" onClick={() => guardarUbicacion(orden.id)}>Guardar</button>
                <button type="button" className="button button-secondary btn btn-outline-secondary" onClick={() => setEditandoUbicacion(null)}>Cancelar</button>
              </span>
            )}
          </p>
          <div className="order-summary-grid">
            <p><span>Cliente</span>{orden.cliente_nombre || orden.cliente_empresa || 'Cliente sin nombre'} <small>{orden.cliente_telefono || 'sin teléfono'}</small></p>
            <p><span>Artículo</span>{orden.articulo_tipo} {orden.marca || ''} {orden.modelo || ''}</p>
            {Array.isArray(orden.accesorios) && orden.accesorios.length > 0 && (
              <p>
                <span>Accesorios</span>
                {orden.accesorios.map((accesorio) => accesorio.nombre || accesorio.descripcion).filter(Boolean).join(', ')}
              </p>
            )}
          </div>

          {/* Estado: recibido -> boton para tomar la orden */}
          {(orden.estado_actual === 'recibido' || orden.estado_actual === 'sin_respuesta' || orden.estado_actual === 'esperando_tecnico') && (
            <div className="acciones-principales">
              <button className="button button-primary btn btn-primary" onClick={() => tomarOrden(orden.id, orden.estado_actual)}>
                {orden.estado_actual === 'esperando_tecnico' ? 'Tomar orden (iniciar reparación)' : 'Tomar orden (empezar diagnóstico)'}
              </button>
            </div>
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
                  Total: ${(obtenerRepuestos(orden.id)
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
              <div className="acciones-principales">
                <button className="button button-primary btn btn-primary" onClick={() => enviarCotizacion(orden.id)}>Enviar cotización</button>
                <button className="button button-danger btn btn-outline-danger" onClick={() => marcarChatarra(orden.id)} style={{ color: 'red' }}>
                  Marcar como chatarra (irreparable)
                </button>
              </div>
            </div>
          )}

          {/* Estado: cotizado -> registrar la respuesta del cliente */}
          {(orden.estado_actual === 'cotizado' || orden.estado_actual === 'esperando_respuesta') && (
            <div className="acciones-principales">
              <button className="button button-primary btn btn-primary" onClick={() => responderCliente(orden.id, 'aprobada')}>Cliente aprobó</button>
              <button className="button button-danger btn btn-outline-danger" onClick={() => responderCliente(orden.id, 'rechazada')}>Cliente no aprobó</button>
              <button className="button button-secondary btn btn-outline-secondary" onClick={() => responderCliente(orden.id, 'en_espera')}>
                En espera de respuesta
              </button>
            </div>
          )}

          {/* Estados con transicion simple */}
          {TRANSICIONES_SIMPLES[orden.estado_actual] && (
            <div className="acciones-principales">
              {TRANSICIONES_SIMPLES[orden.estado_actual].map((siguiente) => (
                <button className="button button-secondary btn btn-outline-secondary" key={siguiente} onClick={() => cambiarEstadoSimple(orden.id, siguiente)}>
                  Pasar a: {formatearEstado(siguiente)}
                </button>
              ))}
            </div>
          )}

          <div className="d-flex align-items-center justify-content-between flex-wrap gap-2 mt-2">
            <HistorialOrden ordenId={orden.id} />
            <MenuAcciones etiqueta="Más acciones">
              <button
                type="button"
                className="button button-quiet"
                onClick={() => { setUbicaciones({ ...ubicaciones, [orden.id]: orden.ubicacion || '' }); setEditandoUbicacion(orden.id); }}
              >
                Cambiar ubicación
              </button>
              {ESTADOS_CON_COTIZACION.includes(orden.estado_actual) && (
                <EditorRepuestos ordenId={orden.id} onGuardado={cargarOrdenes} />
              )}
              <CambioEstadoAdmin orden={orden} onCambiado={cargarOrdenes} />
            </MenuAcciones>
          </div>
        </OrdenAcordeon>
      ))}
    </div>
  );
}

export default PanelTecnico;
