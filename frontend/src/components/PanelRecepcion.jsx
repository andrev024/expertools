import { useState, useEffect, useCallback, useRef } from 'react';
import { apiFetch } from '../api';
import ClienteArticuloPicker from './ClienteArticuloPicker';
import HistorialOrden from './HistorialOrden';
import EditorRepuestos from './EditorRepuestos';
import CambioEstadoAdmin from './CambioEstadoAdmin';
import OrdenAcordeon from './OrdenAcordeon';
import MenuAcciones from './MenuAcciones';
import { formatearEstado, formatearTipoOrden } from '../utils/textoUI';
import { abrirWhatsapp, textoSeguimiento, ENLACE_UBICACION, ENLACE_INSTAGRAM, formatearAccesorios } from '../utils/whatsapp';
import { descargarFacturaOrden, obtenerCotizacionOrden } from '../utils/pdf';
import ControlesListaOrdenes from './ControlesListaOrdenes';

function antiguedadEstado(fecha) {
  if (!fecha) return null;
  const fechaParseada = parsearFechaBogota(fecha);
  if (!fechaParseada || Number.isNaN(fechaParseada.getTime())) return null;
  const horas = Math.max(0, Math.floor((Date.now() - fechaParseada.getTime()) / 3600000));
  const dias = Math.floor(horas / 24);
  return {
    horas,
    dias,
    clase: dias >= 28 ? 'antiguedad-roja' : dias >= 14 ? 'antiguedad-naranja' : dias >= 7 ? 'antiguedad-amarilla' : '',
  };
}

function mostrarFecha(fecha) {
  const fechaParseada = parsearFechaBogota(fecha);
  return fechaParseada && !Number.isNaN(fechaParseada.getTime())
    ? fechaParseada.toLocaleString('es-CO', { timeZone: 'America/Bogota' })
    : 'sin fecha';
}

function parsearFechaBogota(fecha) {
  if (!fecha) return null;
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

// Cubre estados finales y variantes historicas migradas en mayusculas
// (ENTREGADA, ENTREGADO Y PAGADO, CHATARRA, NO AUTORIZADO, etc.)
function esEstadoFinalizado(estado) {
  return /ENTREGAD|CHATARRA|CANCELAD|NO.?AUTORIZAD/.test((estado || '').toUpperCase());
}

// Color del indicador de estado: reutiliza el mismo calculo de antiguedad
// que ya existia (dias en el estado actual) para decidir la severidad.
function claseColorEstado(orden) {
  if (esEstadoFinalizado(orden.estado_actual)) {
    return /ENTREGAD/i.test(orden.estado_actual || '') ? 'estado-punto-verde' : 'estado-punto-gris';
  }
  const dias = antiguedadEstado(fechaEstado(orden))?.dias || 0;
  if (dias >= 28) return 'estado-punto-rojo';
  if (dias >= 14) return 'estado-punto-naranja';
  if (dias >= 7) return 'estado-punto-amarillo';
  return 'estado-punto-azul';
}

function formatearDias(dias) {
  return !dias ? 'Hoy' : `${dias} día${dias === 1 ? '' : 's'}`;
}

// En v2, recepcion ya NO cotiza -- solo recibe y hace la entrega final.
const ACCIONES_RECEPCION = {
  esperando_abono: ['esperando_tecnico'],
  en_revision_recepcion: ['listo_para_entregar'],
  listo_para_entregar: ['entregado'],
};

function PanelRecepcion() {
  const [ordenes, setOrdenes] = useState([]);
  const [listaMeta, setListaMeta] = useState(null);
  const [cargando, setCargando] = useState(true);
  const [error, setError] = useState('');
  const [comentarios, setComentarios] = useState({});

  const [articuloId, setArticuloId] = useState(null);
  const [datosOrdenPendientes, setDatosOrdenPendientes] = useState({});
  const [articuloDescripcion, setArticuloDescripcion] = useState('');
  const [reinicioPicker, setReinicioPicker] = useState(0);
  const [tipo, setTipo] = useState('reparacion');
  const [ubicacionInicial, setUbicacionInicial] = useState('');
  const [mensajeExito, setMensajeExito] = useState('');
  const [filtroAntiguedad, setFiltroAntiguedad] = useState('todas');
  const [filtroEstado, setFiltroEstado] = useState('todos');
  const [filtroTipo, setFiltroTipo] = useState('todos');
  const [filtroUbicacion, setFiltroUbicacion] = useState('todas');
  const [filtroResumen, setFiltroResumen] = useState('todas');
  const [ordenCodigo, setOrdenCodigo] = useState('desc');
  const [editandoUbicacion, setEditandoUbicacion] = useState(null);
  const [ubicaciones, setUbicaciones] = useState({});
  const [ordenExpandidaCotizacion, setOrdenExpandidaCotizacion] = useState(null);
  const [filtroEstadoCotizacion, setFiltroEstadoCotizacion] = useState('todos');
  const [ordenExpandidaAccion, setOrdenExpandidaAccion] = useState(null);
  const [filtroEstadoAccion, setFiltroEstadoAccion] = useState('todos');
  const [seccionActiva, setSeccionActiva] = useState('todas');
  const [paginas, setPaginas] = useState({ todas: 1, cotizaciones: 1, acciones: 1 });
  const [tamanosPagina, setTamanosPagina] = useState({ todas: 10, cotizaciones: 10, acciones: 10 });
  const [busquedas, setBusquedas] = useState({ todas: '', cotizaciones: '', acciones: '' });
  const [modoVista, setModoVista] = useState(() => localStorage.getItem('expertools-vista-recepcion') || 'tarjetas');
  const solicitudActual = useRef(0);

  const cargarOrdenes = useCallback(async () => {
    const solicitud = ++solicitudActual.current;
    try {
      setCargando(true);
      const parametros = new URLSearchParams({
        modo: 'lista',
        vista: 'recepcion',
        seccion: seccionActiva,
        pagina: String(paginas[seccionActiva]),
        por_pagina: String(tamanosPagina[seccionActiva]),
        buscar: busquedas[seccionActiva],
        estado: seccionActiva === 'todas'
          ? filtroEstado
          : seccionActiva === 'cotizaciones' ? filtroEstadoCotizacion : filtroEstadoAccion,
        antiguedad: seccionActiva === 'todas' ? filtroAntiguedad : 'todas',
        tipo: seccionActiva === 'todas' ? filtroTipo : 'todos',
        ubicacion: seccionActiva === 'todas' ? filtroUbicacion : 'todas',
        resumen: seccionActiva === 'todas' ? filtroResumen : 'todas',
        orden: ordenCodigo,
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
  }, [
    busquedas, filtroAntiguedad, filtroEstado, filtroEstadoAccion, filtroEstadoCotizacion,
    filtroResumen, filtroTipo, filtroUbicacion, ordenCodigo, paginas, seccionActiva, tamanosPagina,
  ]);

  useEffect(() => {
    const temporizador = setTimeout(cargarOrdenes, 200);
    return () => clearTimeout(temporizador);
  }, [cargarOrdenes]);

  function abrirAvisoEntrega(orden, ventanaWhatsapp) {
    const mensaje = [
      `Hola ${orden.cliente_nombre || orden.cliente_empresa || 'cliente'}, te contactamos desde Expertools.`,
      'Tu equipo ya está listo para entregar.',
      '',
      `- Código de seguimiento: ${orden.codigo_seguimiento}`,
      `- Artículo: ${orden.articulo_tipo}${orden.marca ? ` ${orden.marca}` : ''}${orden.modelo ? ` ${orden.modelo}` : ''}`,
      '',
      'Gracias por confiar en ExperTools. Por favor, acércate a nuestras instalaciones para recoger tu equipo.',
      '',
      textoSeguimiento(orden.codigo_seguimiento),
      '',
      `Instagram: ${ENLACE_INSTAGRAM}`,
      `Ubicación: ${ENLACE_UBICACION}`,
    ].join('\n');

    abrirWhatsapp(ventanaWhatsapp, orden.cliente_telefono, mensaje);
  }

  // Al crear la orden, el cliente recibe de inmediato un WhatsApp con la
  // información de recepción y el link para hacerle seguimiento.
  function abrirAvisoCreacion(orden, ventanaWhatsapp) {
    const mensaje = [
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
      textoSeguimiento(orden.codigo_seguimiento),
      '',
      `Instagram: ${ENLACE_INSTAGRAM}`,
      `Ubicación: ${ENLACE_UBICACION}`,
    ].filter(Boolean).join('\n');

    abrirWhatsapp(ventanaWhatsapp, orden.cliente_telefono, mensaje);
  }

  async function cambiarEstado(ordenId, nuevoEstado) {
    setError('');
    // La ventana se abre antes del await para que el navegador no bloquee el popup.
    const ventanaWhatsapp = nuevoEstado === 'listo_para_entregar' ? window.open('', '_blank') : null;
    try {
      await apiFetch('cambiar_estado.php', {
        method: 'POST',
        body: JSON.stringify({
          orden_id: ordenId,
          estado: nuevoEstado,
          comentario: comentarios[ordenId] || '',
        }),
      });
      if (nuevoEstado === 'listo_para_entregar') {
        const orden = ordenes.find((item) => item.id === ordenId);
        if (orden) {
          abrirAvisoEntrega(orden, ventanaWhatsapp);
        } else if (ventanaWhatsapp) {
          ventanaWhatsapp.close();
        }
      }
      cargarOrdenes();
    } catch (err) {
      if (ventanaWhatsapp) ventanaWhatsapp.close();
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

  async function responderCotizacion(ordenId, respuesta) {
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
          comentario: comentarios[ordenId] || '',
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

  // Regenera la factura de una orden en su estado actual (con cotización si ya existe).
  async function generarPdfOrden(orden) {
    setError('');
    try {
      const cotizacion = await obtenerCotizacionOrden(orden.id);
      await descargarFacturaOrden({ orden, cotizacion, sufijo: 'factura' });
    } catch (err) {
      setError(err.message);
    }
  }

  async function crearOrden(e) {
    e.preventDefault();
    setError('');
    setMensajeExito('');

    if (!articuloId) {
      setError('Selecciona o crea un artículo primero');
      return;
    }

    const ventanaWhatsapp = window.open('', '_blank');

    try {
      const resultado = await apiFetch('ordenes.php', {
        method: 'POST',
        body: JSON.stringify({ articulo_id: articuloId, tipo, ubicacion: ubicacionInicial, ...datosOrdenPendientes }),
      });

      setMensajeExito(`Orden creada: ${resultado.codigo_seguimiento}`);
      setArticuloId(null);
      setDatosOrdenPendientes({});
      setArticuloDescripcion('');
      setReinicioPicker((valor) => valor + 1);
      setTipo('reparacion');
      setUbicacionInicial('');

      // Recargamos para obtener los datos completos (cliente, artículo, accesorios)
      // de la orden recién creada y así poder avisarle por WhatsApp con toda la info.
      const ordenCreada = await apiFetch(`ordenes.php?detalle_id=${encodeURIComponent(resultado.id)}`);
      if (ordenCreada) {
        abrirAvisoCreacion(ordenCreada, ventanaWhatsapp);
        setPaginas((actuales) => ({ ...actuales, todas: 1 }));
        setSeccionActiva('todas');
        setFiltroResumen('todas');
        setBusquedas((actuales) => ({ ...actuales, todas: '' }));
        // Primera factura: datos de ingreso, aún sin cotización.
        descargarFacturaOrden({ orden: ordenCreada, sufijo: 'ingreso' }).catch((err) => {
          setError(`La orden se creó, pero no se pudo generar su comprobante: ${err.message}`);
        });
      } else if (ventanaWhatsapp) {
        ventanaWhatsapp.close();
      }
    } catch (err) {
      if (ventanaWhatsapp) ventanaWhatsapp.close();
      setError(err.message);
    }
  }

  const conteosEstado = listaMeta?.conteos_estado || {};
  const estadosDisponibles = Object.keys(conteosEstado).sort((a, b) => formatearEstado(a).localeCompare(formatearEstado(b)));
  const tiposDisponibles = listaMeta?.tipos || [];
  const ubicacionesDisponibles = listaMeta?.ubicaciones || [];
  const resumen = listaMeta?.resumen || {};

  function aplicarFiltroResumen(filtro) {
    setFiltroResumen(filtro);
    setFiltroAntiguedad('todas');
    setBusquedas((actuales) => ({ ...actuales, todas: '' }));
    setFiltroEstado('todos');
    setFiltroTipo('todos');
    setFiltroUbicacion('todas');
    setPaginas((actuales) => ({ ...actuales, todas: 1 }));
  }

  const ordenesVisibles = ordenes;
  const paginaActual = listaMeta?.pagina || paginas[seccionActiva];
  const totalPaginas = listaMeta?.total_paginas || 1;
  const totalActual = listaMeta?.total || 0;

  return (
    <div className={`operations-panel modo-lista-${modoVista}`}>
      <h2 className="h4 border-start border-4 ps-3">Crear nueva orden</h2>
      <form onSubmit={crearOrden} className="card card-body shadow-sm rounded-3 border-0 mb-4">
        <ClienteArticuloPicker
          key={reinicioPicker}
          onArticuloSeleccionado={(id, descripcion, datosPendientes = {}) => {
            setArticuloId(id);
            setArticuloDescripcion(descripcion);
            setDatosOrdenPendientes(datosPendientes);
          }}
        />

        {articuloId && (
          <p className="alert alert-success py-2">Artículo seleccionado: {articuloDescripcion}</p>
        )}

        <div>
          <label className="form-label fw-semibold">Tipo</label>
          <select
            className="form-select mb-3"
            value={tipo}
            onChange={(e) => setTipo(e.target.value)}
            style={{ display: 'block', marginBottom: '8px' }}
          >
            <option value="reparacion">Reparación</option>
            <option value="garantia">Garantía</option>
          </select>
        </div>
        <label className="form-label fw-semibold" htmlFor="ubicacion-inicial">Stand o ubicación donde se deja</label>
        <input
          id="ubicacion-inicial"
          className="form-control mb-3"
          type="text"
          placeholder="Ej. Repisa A-3"
          value={ubicacionInicial}
          onChange={(e) => setUbicacionInicial(e.target.value)}
        />
        <button className="button button-primary btn btn-primary" type="submit" disabled={!articuloId}>Crear orden</button>
      </form>

      {mensajeExito && <p className="alert alert-success">{mensajeExito}</p>}
      {error && <p className="alert alert-danger">{error}</p>}

      <div className="tabs-panel-operaciones" role="tablist" aria-label="Secciones de órdenes">
        <button type="button" role="tab" aria-selected={seccionActiva === 'todas'} className={`resumen-chip resumen-chip-button ${seccionActiva === 'todas' ? 'activo' : ''}`} onClick={() => setSeccionActiva('todas')}>
          Todas las órdenes <strong>{resumen.todas || 0}</strong>
        </button>
        <button type="button" role="tab" aria-selected={seccionActiva === 'cotizaciones'} className={`resumen-chip resumen-chip-button ${seccionActiva === 'cotizaciones' ? 'activo' : ''}`} onClick={() => setSeccionActiva('cotizaciones')}>
          Cotizaciones <strong>{listaMeta?.secciones?.cotizaciones || 0}</strong>
        </button>
        <button type="button" role="tab" aria-selected={seccionActiva === 'acciones'} className={`resumen-chip resumen-chip-button ${seccionActiva === 'acciones' ? 'activo' : ''}`} onClick={() => setSeccionActiva('acciones')}>
          Acciones pendientes <strong>{listaMeta?.secciones?.acciones || 0}</strong>
        </button>
      </div>

      <section hidden={seccionActiva !== 'cotizaciones'} aria-label="Cotizaciones por confirmar">
      <h2 className="h4 border-start border-4 ps-3">Cotizaciones por confirmar</h2>
      {(() => {
        const ordenesCotizacion = ordenes.filter((orden) => ['cotizado', 'esperando_respuesta'].includes(orden.estado_actual));
        const estadosCotizacion = ['cotizado', 'esperando_respuesta'].filter((estado) => (conteosEstado[estado] || 0) > 0);
        const ordenesCotizacionFiltradas = ordenesCotizacion.filter((orden) => filtroEstadoCotizacion === 'todos' || orden.estado_actual === filtroEstadoCotizacion);
        return (
          <>
            <ControlesListaOrdenes
              busqueda={busquedas.cotizaciones}
              onBusqueda={(valor) => { setBusquedas((actuales) => ({ ...actuales, cotizaciones: valor })); setPaginas((actuales) => ({ ...actuales, cotizaciones: 1 })); }}
              pagina={paginaActual}
              onPagina={(valor) => setPaginas((actuales) => ({ ...actuales, cotizaciones: valor }))}
              totalPaginas={totalPaginas}
              total={totalActual}
              porPagina={tamanosPagina.cotizaciones}
              onPorPagina={(valor) => { setTamanosPagina((actuales) => ({ ...actuales, cotizaciones: valor })); setPaginas((actuales) => ({ ...actuales, cotizaciones: 1 })); }}
              modoVista={modoVista}
              onModoVista={(modo) => { setModoVista(modo); localStorage.setItem('expertools-vista-recepcion', modo); }}
            />
            {estadosCotizacion.length > 0 && (
              <div className="tabs-filtro-estado" role="tablist" aria-label="Filtrar cotizaciones por estado">
                <button type="button" className={`resumen-chip resumen-chip-button ${filtroEstadoCotizacion === 'todos' ? 'activo' : ''}`} onClick={() => { setFiltroEstadoCotizacion('todos'); setPaginas((actuales) => ({ ...actuales, cotizaciones: 1 })); }}>
                  Todas <strong>{(conteosEstado.cotizado || 0) + (conteosEstado.esperando_respuesta || 0)}</strong>
                </button>
                {estadosCotizacion.map((estado) => (
                  <button type="button" key={estado} className={`resumen-chip resumen-chip-button ${filtroEstadoCotizacion === estado ? 'activo' : ''}`} onClick={() => { setFiltroEstadoCotizacion(estado); setPaginas((actuales) => ({ ...actuales, cotizaciones: 1 })); }}>
                    {formatearEstado(estado)} <strong>{conteosEstado[estado] || 0}</strong>
                  </button>
                ))}
              </div>
            )}
            {cargando && <p className="alert alert-light border">Cargando cotizaciones...</p>}
            {!cargando && totalActual === 0 && <p className="alert alert-light border">{busquedas.cotizaciones ? 'No hay cotizaciones que coincidan con la búsqueda.' : 'No hay cotizaciones pendientes por confirmar.'}</p>}
            {!cargando && ordenesCotizacionFiltradas.map((orden) => (
              <OrdenAcordeon
                key={`cotizacion-${orden.id}`}
                orden={orden}
                kicker="Respuesta del cliente"
                claseExtra={modoVista === 'compacto' ? 'orden-acordeon-compacto' : ''}
                expandido={ordenExpandidaCotizacion === orden.id}
                onToggle={() => setOrdenExpandidaCotizacion((actual) => (actual === orden.id ? null : orden.id))}
              >
                {antiguedadEstado(orden.fecha_ingreso)?.dias >= 7 && (
                  <p className={`alert antiguedad-aviso py-2 mb-2 ${antiguedadEstado(orden.fecha_ingreso).clase}`}>
                    Orden ingresada hace {antiguedadEstado(orden.fecha_ingreso).dias} días
                  </p>
                )}
                <input
                  type="text"
                  placeholder="Nota de la respuesta (opcional)"
                  value={comentarios[orden.id] || ''}
                  onChange={(e) => setComentarios({ ...comentarios, [orden.id]: e.target.value })}
                  style={{ display: 'block', marginBottom: '8px', width: '100%' }}
                />
                <div className="acciones-principales">
                  <button className="button button-primary btn btn-primary" onClick={() => responderCotizacion(orden.id, 'aprobada')}>Cliente aprobó</button>
                  <button className="button button-danger btn btn-outline-danger" onClick={() => responderCotizacion(orden.id, 'rechazada')}>Cliente no aprobó</button>
                </div>
                <HistorialOrden ordenId={orden.id} />
              </OrdenAcordeon>
            ))}
          </>
        );
      })()}
      </section>

      <section hidden={seccionActiva !== 'acciones'} aria-label="Acciones pendientes">
      <h2 className="h4 border-start border-4 ps-3">Acciones pendientes </h2>
      {(() => {
        const ordenesAccion = ordenes.filter((o) => ACCIONES_RECEPCION[o.estado_actual]);
        const estadosAccion = Object.keys(ACCIONES_RECEPCION).filter((estado) => (conteosEstado[estado] || 0) > 0);
        const ordenesAccionFiltradas = ordenesAccion.filter((orden) => filtroEstadoAccion === 'todos' || orden.estado_actual === filtroEstadoAccion);
        return (
          <>
            <ControlesListaOrdenes
              busqueda={busquedas.acciones}
              onBusqueda={(valor) => { setBusquedas((actuales) => ({ ...actuales, acciones: valor })); setPaginas((actuales) => ({ ...actuales, acciones: 1 })); }}
              pagina={paginaActual}
              onPagina={(valor) => setPaginas((actuales) => ({ ...actuales, acciones: valor }))}
              totalPaginas={totalPaginas}
              total={totalActual}
              porPagina={tamanosPagina.acciones}
              onPorPagina={(valor) => { setTamanosPagina((actuales) => ({ ...actuales, acciones: valor })); setPaginas((actuales) => ({ ...actuales, acciones: 1 })); }}
              modoVista={modoVista}
              onModoVista={(modo) => { setModoVista(modo); localStorage.setItem('expertools-vista-recepcion', modo); }}
            />
            {estadosAccion.length > 0 && (
              <div className="tabs-filtro-estado" role="tablist" aria-label="Filtrar acciones pendientes por estado">
                <button type="button" className={`resumen-chip resumen-chip-button ${filtroEstadoAccion === 'todos' ? 'activo' : ''}`} onClick={() => { setFiltroEstadoAccion('todos'); setPaginas((actuales) => ({ ...actuales, acciones: 1 })); }}>
                  Todas <strong>{Object.keys(ACCIONES_RECEPCION).reduce((total, estado) => total + (conteosEstado[estado] || 0), 0)}</strong>
                </button>
                {estadosAccion.map((estado) => (
                  <button type="button" key={estado} className={`resumen-chip resumen-chip-button ${filtroEstadoAccion === estado ? 'activo' : ''}`} onClick={() => { setFiltroEstadoAccion(estado); setPaginas((actuales) => ({ ...actuales, acciones: 1 })); }}>
                    {formatearEstado(estado)} <strong>{conteosEstado[estado] || 0}</strong>
                  </button>
                ))}
              </div>
            )}
            {cargando && <p className="alert alert-light border">Cargando acciones...</p>}
            {!cargando && totalActual === 0 && <p className="alert alert-light border">{busquedas.acciones ? 'No hay acciones que coincidan con la búsqueda.' : 'No hay acciones pendientes por ahora.'}</p>}
            {!cargando && ordenesAccionFiltradas.map((orden) => (
              <OrdenAcordeon
                key={orden.id}
                orden={orden}
                kicker="Orden pendiente"
                claseExtra={modoVista === 'compacto' ? 'orden-acordeon-compacto' : ''}
                expandido={ordenExpandidaAccion === orden.id}
                onToggle={() => setOrdenExpandidaAccion((actual) => (actual === orden.id ? null : orden.id))}
              >
                <p className="small text-secondary">Estado desde: {mostrarFecha(fechaEstado(orden))}</p>
                {orden.accesorios?.length > 0 && <p className="small text-secondary">Accesorios: {formatearAccesorios(orden.accesorios)}</p>}
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
                <input
                  type="text"
                  placeholder="Comentario"
                  value={comentarios[orden.id] || ''}
                  onChange={(e) => setComentarios({ ...comentarios, [orden.id]: e.target.value })}
                  style={{ display: 'block', marginBottom: '8px', width: '100%' }}
                />
                <div className="acciones-principales">
                  {ACCIONES_RECEPCION[orden.estado_actual].map((siguienteEstado) => (
                    <button
                      className="button button-primary btn btn-primary"
                      key={siguienteEstado}
                      onClick={() => cambiarEstado(orden.id, siguienteEstado)}
                    >
                      Pasar a: {formatearEstado(siguienteEstado)}
                    </button>
                  ))}
                </div>
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
                    <EditorRepuestos ordenId={orden.id} onGuardado={cargarOrdenes} />
                    <CambioEstadoAdmin orden={orden} onCambiado={cargarOrdenes} />
                  </MenuAcciones>
                </div>
              </OrdenAcordeon>
            ))}
          </>
        );
      })()}
      </section>

      <section hidden={seccionActiva !== 'todas'} aria-label="Todas las órdenes">
      <h2 className="h4 border-start border-4 ps-3">Todas las órdenes</h2>
      <div className="resumen-ordenes" aria-label="Resumen de órdenes">
        <button type="button" className="resumen-chip resumen-chip-button" onClick={() => aplicarFiltroResumen('todas')}>
          <strong>{resumen.todas || 0}</strong> Todas
        </button>
        <button
          type="button"
          className="resumen-chip resumen-chip-button"
          title=" Órdenes que todavía no han terminado su proceso."
          aria-label={`Pendientes: ${resumen.pendientes || 0}. Órdenes que todavía no han terminado su proceso.`}
          onClick={() => aplicarFiltroResumen('pendientes')}
        >
          <strong>{resumen.pendientes || 0}</strong> Pendientes
        </button>
        <button
          type="button"
          className="resumen-chip resumen-chip-button resumen-chip-alerta"
          title="Órdenes que todavía no han terminado su proceso y que llevan 28 días o más en algún proceso quietas."
          aria-label={`Estancadas: ${resumen.estancadas || 0}. Órdenes que todavía no han terminado su proceso y que llevan 28 días o más en algún proceso.`}
          onClick={() => aplicarFiltroResumen('estancadas')}
        >
          <strong>{resumen.estancadas || 0}</strong> Estancadas
        </button>
        <button type="button" className="resumen-chip resumen-chip-button" onClick={() => aplicarFiltroResumen('esperando_abono')}>
          <strong>{resumen.esperando_abono || 0}</strong> Esperando abono
        </button>
      </div>
      <div className="filtros-bar">
        <div className="filtro-campo">
          <label htmlFor="filtro-antiguedad-recepcion">Antigüedad</label>
          <select id="filtro-antiguedad-recepcion" className="form-select" value={filtroAntiguedad} onChange={(e) => { setFiltroAntiguedad(e.target.value); setPaginas((actuales) => ({ ...actuales, todas: 1 })); }}>
            <option value="todas">Todas las órdenes</option>
            <option value="una_semana">1 semana o más</option>
            <option value="dos_tres_semanas">2 a 3 semanas</option>
            <option value="cuatro_semanas">4 semanas o más</option>
          </select>
        </div>
        <div className="filtro-campo">
          <label htmlFor="filtro-estado-recepcion">Estado</label>
          <select id="filtro-estado-recepcion" className="form-select" value={filtroEstado} onChange={(e) => { setFiltroEstado(e.target.value); setPaginas((actuales) => ({ ...actuales, todas: 1 })); }}>
            <option value="todos">Todos los estados</option>
            {estadosDisponibles.map((estado) => (
              <option key={estado} value={estado}>{formatearEstado(estado)}</option>
            ))}
          </select>
        </div>
        <div className="filtro-campo">
          <label htmlFor="filtro-tipo-recepcion">Tipo</label>
          <select id="filtro-tipo-recepcion" className="form-select" value={filtroTipo} onChange={(e) => { setFiltroTipo(e.target.value); setPaginas((actuales) => ({ ...actuales, todas: 1 })); }}>
            <option value="todos">Todos los tipos</option>
            {tiposDisponibles.map((tipoOrden) => (
              <option key={tipoOrden} value={tipoOrden}>{formatearTipoOrden(tipoOrden)}</option>
            ))}
          </select>
        </div>
        <div className="filtro-campo">
          <label htmlFor="filtro-ubicacion-recepcion">Ubicación</label>
          <select id="filtro-ubicacion-recepcion" className="form-select" value={filtroUbicacion} onChange={(e) => { setFiltroUbicacion(e.target.value); setPaginas((actuales) => ({ ...actuales, todas: 1 })); }}>
            <option value="todas">Todas las ubicaciones</option>
            {ubicacionesDisponibles.map((ubicacion) => (
              <option key={ubicacion} value={ubicacion}>{ubicacion}</option>
            ))}
          </select>
        </div>
      </div>
      <ControlesListaOrdenes
        busqueda={busquedas.todas}
        onBusqueda={(valor) => { setBusquedas((actuales) => ({ ...actuales, todas: valor })); setPaginas((actuales) => ({ ...actuales, todas: 1 })); }}
        pagina={paginaActual}
        onPagina={(valor) => setPaginas((actuales) => ({ ...actuales, todas: valor }))}
        totalPaginas={totalPaginas}
        total={totalActual}
        porPagina={tamanosPagina.todas}
        onPorPagina={(valor) => { setTamanosPagina((actuales) => ({ ...actuales, todas: valor })); setPaginas((actuales) => ({ ...actuales, todas: 1 })); }}
        modoVista={modoVista}
        onModoVista={(modo) => { setModoVista(modo); localStorage.setItem('expertools-vista-recepcion', modo); }}
      />
      <div className="antiguedad-leyenda" aria-label="Leyenda de antigüedad">
        <span><i className="leyenda-color antiguedad-amarilla" /> 1 semana</span>
        <span><i className="leyenda-color antiguedad-naranja" /> 2 a 3 semanas</span>
        <span><i className="leyenda-color antiguedad-roja" /> 4 semanas o más</span>
      </div>
      {cargando ? (
        <p className="alert alert-light border">Cargando órdenes…</p>
      ) : totalActual === 0 ? (
        <p className="alert alert-light border">{busquedas.todas ? 'No hay órdenes que coincidan con la búsqueda y los filtros.' : 'No hay órdenes para mostrar.'}</p>
      ) : modoVista === 'tarjetas' ? (
        <div className="lista-ordenes-tarjetas">
          {ordenesVisibles.map((orden) => (
            <OrdenAcordeon
              key={orden.id}
              orden={orden}
              kicker={formatearTipoOrden(orden.tipo)}
              expandido={ordenExpandidaAccion === `todas-${orden.id}`}
              onToggle={() => setOrdenExpandidaAccion((actual) => (actual === `todas-${orden.id}` ? null : `todas-${orden.id}`))}
              claseExtra={antiguedadEstado(orden.fecha_ingreso)?.clase || ''}
            >
              <p><strong>Estado:</strong> {formatearEstado(orden.estado_actual)} · {formatearDias(antiguedadEstado(fechaEstado(orden))?.dias)} en este estado</p>
              <p><strong>Artículo:</strong> {orden.articulo_tipo} {orden.marca || ''} {orden.modelo || ''}</p>
              <p><strong>Cliente:</strong> {orden.cliente_nombre || orden.cliente_empresa || 'Cliente sin nombre'} · {orden.cliente_telefono || 'sin teléfono'}</p>
              <p><strong>Ubicación:</strong> {orden.ubicacion || 'Sin ubicación'}</p>
              <p className="small text-secondary">Estado desde: {mostrarFecha(fechaEstado(orden))}</p>
              <div className="d-flex flex-wrap gap-2 align-items-center">
                <button type="button" className="button-quiet" onClick={() => generarPdfOrden(orden)}>Generar PDF</button>
                <HistorialOrden ordenId={orden.id} compacto />
                <EditorRepuestos ordenId={orden.id} onGuardado={cargarOrdenes} />
                <CambioEstadoAdmin orden={orden} onCambiado={cargarOrdenes} />
                <button type="button" className="button-quiet" onClick={() => { setUbicaciones({ ...ubicaciones, [orden.id]: orden.ubicacion || '' }); setEditandoUbicacion(orden.id); }}>
                  Cambiar ubicación
                </button>
              </div>
              {editandoUbicacion === orden.id && (
                <div className="d-flex flex-wrap gap-2 mt-2">
                  <input className="form-control" type="text" value={ubicaciones[orden.id] ?? orden.ubicacion ?? ''} onChange={(event) => setUbicaciones({ ...ubicaciones, [orden.id]: event.target.value })} />
                  <button type="button" className="button button-primary" onClick={() => guardarUbicacion(orden.id)}>Guardar</button>
                  <button type="button" className="button button-quiet" onClick={() => setEditandoUbicacion(null)}>Cancelar</button>
                </div>
              )}
            </OrdenAcordeon>
          ))}
        </div>
      ) : (
        <div className="orders-table-wrapper">
          <table className="orders-table ordenes-tabla table table-hover table-striped align-middle">
            <thead>
              <tr>
                <th className="fw-semibold th-ordenable">
                  <button
                    type="button"
                    className="button-quiet th-sort-btn"
                    onClick={() => setOrdenCodigo((actual) => (actual === 'asc' ? 'desc' : 'asc'))}
                  >
                    Código {ordenCodigo === 'asc' ? '↑' : ordenCodigo === 'desc' ? '↓' : ''}
                  </button>
                </th>
                <th className="fw-semibold">Artículo</th>
                <th className="fw-semibold">Cliente</th>
                <th className="fw-semibold">Ubicación</th>
                <th className="fw-semibold">Estado</th>
                <th className="fw-semibold">Antigüedad</th>
                <th className="fw-semibold">Tipo</th>
                <th className="fw-semibold">Acciones</th>
              </tr>
            </thead>
            <tbody>
              {ordenesVisibles.map((orden) => (
                <tr key={orden.id}>
                  <td data-label="Código"><span className="codigo-badge">{orden.codigo_seguimiento}</span></td>
                  <td data-label="Artículo">
                    <div className="celda-contenido">
                      <strong className="articulo-nombre d-block">{orden.articulo_tipo}</strong>
                      {orden.marca && <small className="articulo-marca d-block">{orden.marca}</small>}
                    </div>
                  </td>
                  <td data-label="Cliente">
                    <div className="celda-contenido">
                      <strong className="cliente-nombre d-block">{orden.cliente_nombre || orden.cliente_empresa || 'Cliente sin nombre'}</strong>
                      {orden.cliente_empresa && orden.cliente_nombre && <small className="cliente-secundario d-block">{orden.cliente_empresa}</small>}
                      {orden.cliente_telefono && <small className="cliente-secundario d-block">Tel: {orden.cliente_telefono}</small>}
                      {orden.cliente_correo && <small className="cliente-secundario d-block">{orden.cliente_correo}</small>}
                      {orden.cliente_cedula && <small className="cliente-secundario d-block">CC: {orden.cliente_cedula}</small>}
                    </div>
                  </td>
                  <td data-label="Ubicación">
                    <div className="celda-contenido">
                      <span className={`ubicacion-chip d-block${orden.ubicacion ? '' : ' ubicacion-vacia'}`}>
                        <span aria-hidden="true">📍</span> {orden.ubicacion || 'Sin ubicación'}
                      </span>
                      {editandoUbicacion === orden.id ? (
                        <div className="mt-2">
                          <input className="form-control" type="text" value={ubicaciones[orden.id] ?? orden.ubicacion ?? ''} onChange={(e) => setUbicaciones({ ...ubicaciones, [orden.id]: e.target.value })} />
                          <button type="button" className="button button-primary btn btn-primary btn-sm mt-2 me-1" onClick={() => guardarUbicacion(orden.id)}>Guardar</button>
                          <button type="button" className="button button-secondary btn btn-outline-secondary btn-sm mt-2" onClick={() => setEditandoUbicacion(null)}>Cancelar</button>
                        </div>
                      ) : (
                        <button type="button" className="button-quiet link-button" onClick={() => { setUbicaciones({ ...ubicaciones, [orden.id]: orden.ubicacion || '' }); setEditandoUbicacion(orden.id); }}>Cambiar</button>
                      )}
                    </div>
                  </td>
                  <td data-label="Estado">
                    <div className="celda-contenido">
                      <span className="estado-chip">
                        <i className={`estado-punto ${claseColorEstado(orden)}`} aria-hidden="true" />
                        <span className="estado-nombre">{formatearEstado(orden.estado_actual)}</span>
                      </span>
                      {!esEstadoFinalizado(orden.estado_actual) && (
                        <small className="estado-tiempo d-block mt-1">{formatearDias(antiguedadEstado(fechaEstado(orden))?.dias)} en este estado</small>
                      )}
                      <small className="estado-fecha d-block">Desde {mostrarFecha(fechaEstado(orden))}</small>
                      <button type="button" className="button-quiet link-button d-block mt-1" onClick={() => generarPdfOrden(orden)}>Generar PDF</button>
                    </div>
                  </td>
                  <td data-label="Antigüedad">
                    <span className={`antiguedad-valor ${antiguedadEstado(orden.fecha_ingreso)?.clase || ''}`}>
                      {formatearDias(antiguedadEstado(orden.fecha_ingreso)?.dias)}
                    </span>
                  </td>
                  <td data-label="Tipo">{formatearTipoOrden(orden.tipo)}</td>
                  <td data-label="Acciones">
                    <HistorialOrden ordenId={orden.id} compacto />
                    <EditorRepuestos ordenId={orden.id} onGuardado={cargarOrdenes} />
                    <CambioEstadoAdmin orden={orden} onCambiado={cargarOrdenes} />
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
      </section>
    </div>
  );
}

export default PanelRecepcion;
