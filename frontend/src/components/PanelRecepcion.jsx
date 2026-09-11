import { useState, useEffect, useMemo } from 'react';
import { apiFetch } from '../api';
import ClienteArticuloPicker from './ClienteArticuloPicker';
import HistorialOrden from './HistorialOrden';
import EditorRepuestos from './EditorRepuestos';
import CambioEstadoAdmin from './CambioEstadoAdmin';
import { formatearEstado, formatearTipoOrden, normalizarEstado } from '../utils/textoUI';
import { abrirWhatsapp, enlaceSeguimiento } from '../utils/whatsapp';

function antiguedadEstado(fecha) {
  if (!fecha) return null;
  const horas = Math.max(0, Math.floor((Date.now() - parsearFechaBogota(fecha).getTime()) / 3600000));
  const dias = Math.floor(horas / 24);
  return {
    horas,
    dias,
    clase: dias >= 28 ? 'antiguedad-roja' : dias >= 14 ? 'antiguedad-naranja' : dias >= 7 ? 'antiguedad-amarilla' : '',
  };
}

function mostrarFecha(fecha) {
  return fecha ? parsearFechaBogota(fecha).toLocaleString('es-CO', { timeZone: 'America/Bogota' }) : 'sin fecha';
}

function parsearFechaBogota(fecha) {
  return new Date(`${fecha.replace(' ', 'T')}-05:00`);
}

function formatearAccesorios(accesorios) {
  if (Array.isArray(accesorios)) {
    return accesorios
      .map((accesorio) => `- ${accesorio.nombre}${accesorio.descripcion ? `: ${accesorio.descripcion}` : ''}`)
      .join('\n');
  }
  return accesorios || '';
}

function fechaEstado(orden) {
  return orden.estado_desde || orden.fecha_ingreso;
}

// Cubre estados finales y variantes historicas migradas en mayusculas
// (ENTREGADA, ENTREGADO Y PAGADO, CHATARRA, NO AUTORIZADO, etc.)
function esEstadoFinalizado(estado) {
  return /ENTREGAD|CHATARRA|CANCELAD|NO.?AUTORIZAD/.test((estado || '').toUpperCase());
}

function esOrdenEstancada(orden) {
  return !esEstadoFinalizado(orden.estado_actual)
    && (antiguedadEstado(fechaEstado(orden))?.dias || 0) > 28;
}

function esOrdenPendiente(orden) {
  return !esEstadoFinalizado(orden.estado_actual) && !esOrdenEstancada(orden);
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

function coincideFiltroAntiguedad(fecha, filtro) {
  if (filtro === 'todas') return true;
  const dias = antiguedadEstado(fecha)?.dias || 0;
  if (filtro === 'una_semana') return dias >= 7;
  if (filtro === 'dos_tres_semanas') return dias >= 14 && dias < 28;
  return dias >= 28;
}

function coincideTextoBusqueda(orden, texto) {
  const buscado = texto.trim().toLowerCase();
  if (!buscado) return true;
  const campos = [
    orden.codigo_seguimiento,
    orden.cliente_nombre,
    orden.cliente_empresa,
    orden.cliente_telefono,
    orden.cliente_correo,
    orden.cliente_cedula,
    orden.articulo_tipo,
    orden.marca,
    orden.modelo,
  ];
  return campos.some((campo) => String(campo || '').toLowerCase().includes(buscado));
}

// En v2, recepcion ya NO cotiza -- solo recibe y hace la entrega final.
const ACCIONES_RECEPCION = {
  esperando_abono: ['esperando_tecnico'],
  en_revision_recepcion: ['listo_para_entregar'],
  listo_para_entregar: ['entregado'],
};

function PanelRecepcion() {
  const [ordenes, setOrdenes] = useState([]);
  const [cargando, setCargando] = useState(true);
  const [error, setError] = useState('');
  const [comentarios, setComentarios] = useState({});

  const [articuloId, setArticuloId] = useState(null);
  const [articuloDescripcion, setArticuloDescripcion] = useState('');
  const [reinicioPicker, setReinicioPicker] = useState(0);
  const [tipo, setTipo] = useState('reparacion');
  const [ubicacionInicial, setUbicacionInicial] = useState('');
  const [mensajeExito, setMensajeExito] = useState('');
  const [filtroAntiguedad, setFiltroAntiguedad] = useState('todas');
  const [busquedaTexto, setBusquedaTexto] = useState('');
  const [filtroEstado, setFiltroEstado] = useState('todos');
  const [filtroTipo, setFiltroTipo] = useState('todos');
  const [filtroUbicacion, setFiltroUbicacion] = useState('todas');
  const [filtroResumen, setFiltroResumen] = useState('todas');
  const [ordenCodigo, setOrdenCodigo] = useState('desc');
  const [editandoUbicacion, setEditandoUbicacion] = useState(null);
  const [ubicaciones, setUbicaciones] = useState({});

  async function cargarOrdenes() {
    try {
      const datos = await apiFetch('ordenes.php');
      setOrdenes(datos);
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

  function abrirAvisoEntrega(orden) {
    const mensaje = [
      ` Hola ${orden.cliente_nombre || orden.cliente_empresa || 'cliente'}, te contactamos desde Expertools.`,
      ' Tu equipo ya está listo para entregar.',
      '',
      `-  Código de seguimiento: ${orden.codigo_seguimiento}`,
      `- Artículo: ${orden.articulo_tipo}${orden.marca ? ` ${orden.marca}` : ''}${orden.modelo ? ` ${orden.modelo}` : ''}`,
      '',
      'Gracias por confiar en ExperTools. Por favor, acércate a nuestras instalaciones para recoger tu equipo.',
      '',
      ` Consulta el seguimiento de tu orden aquí: ${enlaceSeguimiento(orden.codigo_seguimiento)}`,
      '',
      'Instagram: https://www.instagram.com/expertools_herramientas',
      'Ubicación: https://www.google.com/maps/search/?api=1&query=ExperTools%20Reparaci%C3%B3n%20Mantenimiento%20y%20Venta%20de%20Herramientas%2C%20Bogot%C3%A1',
    ].join('\n');

    abrirWhatsapp(window.open('', '_blank'), orden.cliente_telefono, mensaje);
  }

  // Al crear la orden, el cliente recibe de inmediato un WhatsApp con la
  // información de recepción y el link para hacerle seguimiento.
  function abrirAvisoCreacion(orden, ventanaWhatsapp) {
    const mensaje = [
      ` Hola ${orden.cliente_nombre || orden.cliente_empresa || 'cliente'}, te contactamos desde Expertools.`,
      ' Registramos el ingreso de tu equipo para servicio técnico.',
      '',
      `- Código de seguimiento: ${orden.codigo_seguimiento}`,
      `- Tipo de servicio: ${formatearTipoOrden(orden.tipo)}`,
      `- Artículo: ${orden.articulo_tipo}${orden.marca ? ` ${orden.marca}` : ''}${orden.modelo ? ` ${orden.modelo}` : ''}`,
      orden.accesorios?.length ? `- Accesorios recibidos:\n${formatearAccesorios(orden.accesorios)}` : '',
      '',
      ' Te avisaremos por este medio cuando tengamos el diagnóstico y la cotización.',
      '',
      ` Consulta el seguimiento de tu orden en cualquier momento aquí: ${enlaceSeguimiento(orden.codigo_seguimiento)}`,
      '',
      'Instagram: https://www.instagram.com/expertools_herramientas',
      'Ubicación: https://www.google.com/maps/search/?api=1&query=ExperTools%20Reparaci%C3%B3n%20Mantenimiento%20y%20Venta%20de%20Herramientas%2C%20Bogot%C3%A1',
    ].filter(Boolean).join('\n');

    abrirWhatsapp(ventanaWhatsapp, orden.cliente_telefono, mensaje);
  }

  async function cambiarEstado(ordenId, nuevoEstado) {
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
      if (nuevoEstado === 'listo_para_entregar') {
        const orden = ordenes.find((item) => item.id === ordenId);
        if (orden) abrirAvisoEntrega(orden);
      }
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

  async function responderCotizacion(ordenId, respuesta) {
    setError('');
    try {
      await apiFetch('cotizacion.php', {
        method: 'PATCH',
        body: JSON.stringify({
          orden_id: ordenId,
          respuesta,
          comentario: comentarios[ordenId] || '',
        }),
      });
      cargarOrdenes();
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
        body: JSON.stringify({ articulo_id: articuloId, tipo, ubicacion: ubicacionInicial }),
      });

      setMensajeExito(`Orden creada: ${resultado.codigo_seguimiento}`);
      setArticuloId(null);
      setArticuloDescripcion('');
      setReinicioPicker((valor) => valor + 1);
      setTipo('reparacion');
      setUbicacionInicial('');

      // Recargamos para obtener los datos completos (cliente, artículo, accesorios)
      // de la orden recién creada y así poder avisarle por WhatsApp con toda la info.
      const listaActualizada = await apiFetch('ordenes.php');
      setOrdenes(listaActualizada);
      const ordenCreada = listaActualizada.find((o) => String(o.id) === String(resultado.id));
      if (ordenCreada) {
        abrirAvisoCreacion(ordenCreada, ventanaWhatsapp);
      } else if (ventanaWhatsapp) {
        ventanaWhatsapp.close();
      }
    } catch (err) {
      if (ventanaWhatsapp) ventanaWhatsapp.close();
      setError(err.message);
    }
  }

  const estadosDisponibles = useMemo(() => {
    const claves = new Set(ordenes.map((o) => normalizarEstado(o.estado_actual)));
    return Array.from(claves).sort((a, b) => formatearEstado(a).localeCompare(formatearEstado(b)));
  }, [ordenes]);
  const tiposDisponibles = useMemo(
    () => Array.from(new Set(ordenes.map((o) => o.tipo).filter(Boolean))),
    [ordenes]
  );
  const ubicacionesDisponibles = useMemo(
    () => Array.from(new Set(ordenes.map((o) => o.ubicacion).filter((u) => u && u.trim()))),
    [ordenes]
  );

  // Resumen: se calcula sobre todas las ordenes cargadas, sin filtros aplicados.
  const totalOrdenes = ordenes.length;
  const pendientesCount = ordenes.filter(esOrdenPendiente).length;
  const estancadasCount = ordenes.filter(esOrdenEstancada).length;
  const esperandoAbonoCount = ordenes.filter((o) => o.estado_actual === 'esperando_abono').length;

  function aplicarFiltroResumen(filtro) {
    setFiltroResumen(filtro);
    setFiltroAntiguedad('todas');
    setBusquedaTexto('');
    setFiltroEstado('todos');
    setFiltroTipo('todos');
    setFiltroUbicacion('todas');
  }

  const ordenesTabla = ordenes
    .filter((orden) => (
      filtroResumen === 'todas'
      || (filtroResumen === 'pendientes' && esOrdenPendiente(orden))
      || (filtroResumen === 'estancadas' && esOrdenEstancada(orden))
      || (filtroResumen === 'esperando_abono' && orden.estado_actual === 'esperando_abono')
    ))
    .filter((orden) => coincideFiltroAntiguedad(orden.fecha_ingreso, filtroAntiguedad))
    .filter((orden) => coincideTextoBusqueda(orden, busquedaTexto))
    .filter((orden) => filtroEstado === 'todos' || normalizarEstado(orden.estado_actual) === filtroEstado)
    .filter((orden) => filtroTipo === 'todos' || orden.tipo === filtroTipo)
    .filter((orden) => filtroUbicacion === 'todas' || orden.ubicacion === filtroUbicacion)
    .sort((a, b) => {
      if (ordenCodigo) {
        const comparacion = String(a.codigo_seguimiento || '').localeCompare(String(b.codigo_seguimiento || ''), undefined, { numeric: true, sensitivity: 'base' });
        return ordenCodigo === 'asc' ? comparacion : -comparacion;
      }
      return 0;
    });

  return (
    <div className="operations-panel">
      <h2 className="h4 border-start border-4 ps-3">Crear nueva orden</h2>
      <form onSubmit={crearOrden} className="card card-body shadow-sm rounded-3 border-0 mb-4">
        <ClienteArticuloPicker
          key={reinicioPicker}
          onArticuloSeleccionado={(id, descripcion) => {
            setArticuloId(id);
            setArticuloDescripcion(descripcion);
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

      <h2 className="h4 border-start border-4 ps-3">Cotizaciones por confirmar</h2>
      {ordenes.filter((orden) => ['cotizado', 'esperando_respuesta'].includes(orden.estado_actual)).map((orden) => (
        <div key={`cotizacion-${orden.id}`} className="order-card card shadow-sm rounded-3 border-0">
          <div className="order-card-header">
            <div>
              <span className="order-kicker">Respuesta del cliente</span>
              <h3 className="h5">{orden.codigo_seguimiento}</h3>
            </div>
            <strong className="status-badge">{formatearEstado(orden.estado_actual)}</strong>
          </div>
          {antiguedadEstado(orden.fecha_ingreso)?.dias >= 7 && (
            <p className={`alert antiguedad-aviso py-2 mb-2 ${antiguedadEstado(orden.fecha_ingreso).clase}`}>
              Orden ingresada hace {antiguedadEstado(orden.fecha_ingreso).dias} días
            </p>
          )}
          <p className="order-meta">{orden.cliente_nombre || orden.cliente_empresa || 'Cliente sin nombre'} · {orden.articulo_tipo} {orden.marca || ''}</p>
          <input
            type="text"
            placeholder="Nota de la respuesta (opcional)"
            value={comentarios[orden.id] || ''}
            onChange={(e) => setComentarios({ ...comentarios, [orden.id]: e.target.value })}
            style={{ display: 'block', marginBottom: '8px', width: '100%' }}
          />
          <button className="button button-primary btn btn-primary me-2" onClick={() => responderCotizacion(orden.id, 'aprobada')}>Cliente aprobó</button>
          <button className="button button-danger btn btn-outline-danger" onClick={() => responderCotizacion(orden.id, 'rechazada')}>Cliente no aprobó</button>
        </div>
      ))}

      <h2 className="h4 border-start border-4 ps-3">Acciones pendientes </h2>
      {ordenes
        .filter((o) => ACCIONES_RECEPCION[o.estado_actual])
        .map((orden) => (
          <div key={orden.id} className="order-card card shadow-sm rounded-3 border-0">
            <div className="order-card-header">
              <div>
                <span className="order-kicker">Orden pendiente</span>
                <h3 className="h5">{orden.codigo_seguimiento}</h3>
              </div>
              <strong className="status-badge">{formatearEstado(orden.estado_actual)}</strong>
            </div>
            <p className="order-meta">{orden.cliente_nombre || orden.cliente_empresa || 'Cliente sin nombre'} · {orden.articulo_tipo} {orden.marca || ''}</p>
            <p className="small text-secondary">Estado desde: {mostrarFecha(fechaEstado(orden))}</p>
            {orden.accesorios && <p className="small text-secondary">Accesorios: {orden.accesorios}</p>}
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
            <input
              type="text"
              placeholder="Comentario"
              value={comentarios[orden.id] || ''}
              onChange={(e) => setComentarios({ ...comentarios, [orden.id]: e.target.value })}
              style={{ display: 'block', marginBottom: '8px', width: '100%' }}
            />
            {ACCIONES_RECEPCION[orden.estado_actual].map((siguienteEstado) => (
              <button
                className="button button-primary btn btn-primary"
                key={siguienteEstado}
                onClick={() => cambiarEstado(orden.id, siguienteEstado)}
                style={{ marginRight: '8px' }}
              >
                Pasar a: {formatearEstado(siguienteEstado)}
              </button>
            ))}
            <EditorRepuestos ordenId={orden.id} onGuardado={cargarOrdenes} />
            <CambioEstadoAdmin ordenId={orden.id} estadoActual={orden.estado_actual} onCambiado={cargarOrdenes} />
            <HistorialOrden ordenId={orden.id} />
          </div>
        ))}

      <h2 className="h4 border-start border-4 ps-3">Todas las órdenes</h2>
      <div className="resumen-ordenes" aria-label="Resumen de órdenes">
        <button type="button" className="resumen-chip resumen-chip-button" onClick={() => aplicarFiltroResumen('todas')}>
          <strong>{totalOrdenes}</strong> Todas
        </button>
        <button
          type="button"
          className="resumen-chip resumen-chip-button"
          title=" Órdenes que todavía no han terminado su proceso."
          aria-label={`Pendientes: ${pendientesCount}. Órdenes que todavía no han terminado su proceso.`}
          onClick={() => aplicarFiltroResumen('pendientes')}
        >
          <strong>{pendientesCount}</strong> Pendientes
        </button>
        <button
          type="button"
          className="resumen-chip resumen-chip-button resumen-chip-alerta"
          title="Órdenes que todavía no han terminado su proceso y que llevan 28 días o más en algún proceso quietas."
          aria-label={`Estancadas: ${estancadasCount}. Órdenes que todavía no han terminado su proceso y que llevan 28 días o más en algún proceso.`}
          onClick={() => aplicarFiltroResumen('estancadas')}
        >
          <strong>{estancadasCount}</strong> Estancadas
        </button>
        <button type="button" className="resumen-chip resumen-chip-button" onClick={() => aplicarFiltroResumen('esperando_abono')}>
          <strong>{esperandoAbonoCount}</strong> Esperando abono
        </button>
      </div>
      <div className="filtros-bar">
        <div className="filtro-campo">
          <label htmlFor="filtro-antiguedad-recepcion">Antigüedad</label>
          <select id="filtro-antiguedad-recepcion" className="form-select" value={filtroAntiguedad} onChange={(e) => setFiltroAntiguedad(e.target.value)}>
            <option value="todas">Todas las órdenes</option>
            <option value="una_semana">1 semana o más</option>
            <option value="dos_tres_semanas">2 a 3 semanas</option>
            <option value="cuatro_semanas">4 semanas o más</option>
          </select>
        </div>
        <div className="filtro-campo">
          <label htmlFor="filtro-estado-recepcion">Estado</label>
          <select id="filtro-estado-recepcion" className="form-select" value={filtroEstado} onChange={(e) => setFiltroEstado(e.target.value)}>
            <option value="todos">Todos los estados</option>
            {estadosDisponibles.map((estado) => (
              <option key={estado} value={estado}>{formatearEstado(estado)}</option>
            ))}
          </select>
        </div>
        <div className="filtro-campo">
          <label htmlFor="filtro-tipo-recepcion">Tipo</label>
          <select id="filtro-tipo-recepcion" className="form-select" value={filtroTipo} onChange={(e) => setFiltroTipo(e.target.value)}>
            <option value="todos">Todos los tipos</option>
            {tiposDisponibles.map((tipoOrden) => (
              <option key={tipoOrden} value={tipoOrden}>{formatearTipoOrden(tipoOrden)}</option>
            ))}
          </select>
        </div>
        <div className="filtro-campo">
          <label htmlFor="filtro-ubicacion-recepcion">Ubicación</label>
          <select id="filtro-ubicacion-recepcion" className="form-select" value={filtroUbicacion} onChange={(e) => setFiltroUbicacion(e.target.value)}>
            <option value="todas">Todas las ubicaciones</option>
            {ubicacionesDisponibles.map((ubicacion) => (
              <option key={ubicacion} value={ubicacion}>{ubicacion}</option>
            ))}
          </select>
        </div>
        <div className="filtro-campo">
          <label htmlFor="busqueda-texto-recepcion">Buscar</label>
          <input
            id="busqueda-texto-recepcion"
            className="form-control"
            type="text"
            placeholder="Código, cliente, teléfono o artículo"
            value={busquedaTexto}
            onChange={(e) => setBusquedaTexto(e.target.value)}
          />
        </div>
      </div>
      <div className="antiguedad-leyenda" aria-label="Leyenda de antigüedad">
        <span><i className="leyenda-color antiguedad-amarilla" /> 1 semana</span>
        <span><i className="leyenda-color antiguedad-naranja" /> 2 a 3 semanas</span>
        <span><i className="leyenda-color antiguedad-roja" /> 4 semanas o más</span>
      </div>
      {cargando ? (
        <p>Cargando...</p>
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
              {ordenesTabla.map((orden) => (
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
                    <CambioEstadoAdmin ordenId={orden.id} estadoActual={orden.estado_actual} onCambiado={cargarOrdenes} />
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}

export default PanelRecepcion;
