import { useState, useEffect } from 'react';
import { apiFetch } from '../api';
import ClienteArticuloPicker from './ClienteArticuloPicker';
import HistorialOrden from './HistorialOrden';
import { formatearEstado, formatearTipoOrden } from '../utils/textoUI';

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

function fechaEstado(orden) {
  return orden.estado_desde || orden.fecha_ingreso;
}

function coincideFiltroAntiguedad(fecha, filtro) {
  if (filtro === 'todas') return true;
  const dias = antiguedadEstado(fecha)?.dias || 0;
  if (filtro === 'una_semana') return dias >= 7;
  if (filtro === 'dos_tres_semanas') return dias >= 14 && dias < 28;
  return dias >= 28;
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
  const [tipo, setTipo] = useState('reparacion');
  const [ubicacionInicial, setUbicacionInicial] = useState('');
  const [mensajeExito, setMensajeExito] = useState('');
  const [filtroAntiguedad, setFiltroAntiguedad] = useState('todas');
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
    const telefono = String(orden.cliente_telefono || '').replace(/\D/g, '');
    const telefonoWhatsapp = telefono.length === 10 && telefono.startsWith('3') ? `57${telefono}` : telefono;
    const mensaje = [
      ` Hola ${orden.cliente_nombre}, te contactamos desde Expertools.`,
      ' Tu equipo ya está listo para entregar.',
      '',
      `-  Código de seguimiento: ${orden.codigo_seguimiento}`,
      `- Artículo: ${orden.articulo_tipo}${orden.marca ? ` ${orden.marca}` : ''}${orden.modelo ? ` ${orden.modelo}` : ''}`,
      '',
      ' Por favor, acércate a Expertools para recoger tu equipo.',
      '',
      'Instagram: https://www.instagram.com/expertools_herramientas',
      'Ubicación: https://www.google.com/maps/search/?api=1&query=ExperTools%20Reparaci%C3%B3n%20Mantenimiento%20y%20Venta%20de%20Herramientas%2C%20Bogot%C3%A1',
    ].join('\n');

    const ventanaWhatsapp = window.open('', '_blank');
    const urlWhatsapp = `https://wa.me/${telefonoWhatsapp}?text=${encodeURIComponent(mensaje)}`;
    if (ventanaWhatsapp) {
      ventanaWhatsapp.location.href = urlWhatsapp;
    } else {
      window.location.assign(urlWhatsapp);
    }
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

    try {
      const resultado = await apiFetch('ordenes.php', {
        method: 'POST',
        body: JSON.stringify({ articulo_id: articuloId, tipo, ubicacion: ubicacionInicial }),
      });

      setMensajeExito(`Orden creada: ${resultado.codigo_seguimiento}`);
      setArticuloId(null);
      setArticuloDescripcion('');
      setUbicacionInicial('');
      cargarOrdenes();
    } catch (err) {
      setError(err.message);
    }
  }

  return (
    <div className="operations-panel">
      <h2 className="h4 border-start border-4 ps-3">Crear nueva orden</h2>
      <form onSubmit={crearOrden} className="card card-body shadow-sm rounded-3 border-0 mb-4">
        <ClienteArticuloPicker
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
          <p className="order-meta">{orden.cliente_nombre} · {orden.articulo_tipo} {orden.marca || ''}</p>
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
            <p className="order-meta">{orden.cliente_nombre} · {orden.articulo_tipo} {orden.marca || ''}</p>
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
            <HistorialOrden ordenId={orden.id} />
          </div>
        ))}

      <h2 className="h4 border-start border-4 ps-3">Todas las órdenes</h2>
      <div className="d-flex align-items-center gap-2 mb-3">
        <label className="fw-semibold" htmlFor="filtro-antiguedad-recepcion">Filtrar por antigüedad</label>
        <select id="filtro-antiguedad-recepcion" className="form-select" style={{ maxWidth: '280px' }} value={filtroAntiguedad} onChange={(e) => setFiltroAntiguedad(e.target.value)}>
          <option value="todas">Todas las órdenes</option>
          <option value="una_semana">1 semana o más</option>
          <option value="dos_tres_semanas">2 a 3 semanas</option>
          <option value="cuatro_semanas">4 semanas o más</option>
        </select>
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
          <table className="orders-table table table-hover table-striped align-middle">
            <thead>
              <tr>
                <th className="fw-semibold">Código</th>
                <th className="fw-semibold">Artículo</th>
                <th className="fw-semibold">Cliente</th>
                <th className="fw-semibold">Ubicación</th>
                <th className="fw-semibold">Estado</th>
                <th className="fw-semibold">Tipo</th>
                <th className="fw-semibold">Detalle</th>
              </tr>
            </thead>
            <tbody>
              {ordenes.filter((orden) => coincideFiltroAntiguedad(orden.fecha_ingreso, filtroAntiguedad)).map((orden) => (
                <tr key={orden.id} className={antiguedadEstado(orden.fecha_ingreso)?.clase}>
                  <td data-label="Código">{orden.codigo_seguimiento}</td>
                  <td data-label="Artículo">{orden.articulo_tipo} {orden.marca}</td>
                  <td data-label="Cliente">{orden.cliente_nombre}</td>
                  <td data-label="Ubicación">
                    <strong>{orden.ubicacion || 'Sin ubicación'}</strong>
                    {editandoUbicacion === orden.id ? (
                      <div className="mt-2">
                        <input className="form-control" type="text" value={ubicaciones[orden.id] ?? orden.ubicacion ?? ''} onChange={(e) => setUbicaciones({ ...ubicaciones, [orden.id]: e.target.value })} />
                        <button type="button" className="button button-primary btn btn-primary btn-sm mt-2 me-1" onClick={() => guardarUbicacion(orden.id)}>Guardar</button>
                        <button type="button" className="button button-secondary btn btn-outline-secondary btn-sm mt-2" onClick={() => setEditandoUbicacion(null)}>Cancelar</button>
                      </div>
                    ) : (
                      <button type="button" className="button button-quiet d-block" onClick={() => { setUbicaciones({ ...ubicaciones, [orden.id]: orden.ubicacion || '' }); setEditandoUbicacion(orden.id); }}>Cambiar</button>
                    )}
                  </td>
                  <td data-label="Estado"><span className="status-badge">{formatearEstado(orden.estado_actual)}</span><small className="d-block mt-1">Desde {mostrarFecha(fechaEstado(orden))}</small><small className="d-block">Ingresada hace {antiguedadEstado(orden.fecha_ingreso)?.dias || 0} días</small>{antiguedadEstado(fechaEstado(orden))?.horas >= 24 && <small className="d-block">{antiguedadEstado(fechaEstado(orden)).horas} h pendiente en este estado</small>}</td>
                  <td data-label="Tipo">{formatearTipoOrden(orden.tipo)}</td>
                  <td data-label="Historial"><HistorialOrden ordenId={orden.id} /></td>
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
