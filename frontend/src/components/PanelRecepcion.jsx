import { useState, useEffect } from 'react';
import { apiFetch } from '../api';
import ClienteArticuloPicker from './ClienteArticuloPicker';
import { formatearEstado, formatearTipoOrden } from '../utils/textoUI';

// En v2, recepcion ya NO cotiza -- solo recibe y hace la entrega final.
const ACCIONES_RECEPCION = {
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
  const [tipo, setTipo] = useState('mantenimiento');
  const [mensajeExito, setMensajeExito] = useState('');
  const emoji = (codigo) => String.fromCodePoint(codigo);

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
      `${emoji(0x1f44b)} Hola ${orden.cliente_nombre}, te contactamos desde Expertools.`,
      `${emoji(0x1f389)} ¡Tu equipo ya está listo para entregar!`,
      '',
      `${emoji(0x1f516)} Código de seguimiento: ${orden.codigo_seguimiento}`,
      `${emoji(0x1f527)} Artículo: ${orden.articulo_tipo}${orden.marca ? ` ${orden.marca}` : ''}${orden.modelo ? ` ${orden.modelo}` : ''}`,
      '',
      `${emoji(0x1f4cd)} Puedes acercarte a recepción para recogerlo.`,
      `¡Te esperamos! ${emoji(0x1f60a)}`,
    ].join('\n');

    window.open(`https://wa.me/${telefonoWhatsapp}?text=${encodeURIComponent(mensaje)}`, '_blank', 'noopener,noreferrer');
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
        body: JSON.stringify({ articulo_id: articuloId, tipo }),
      });

      setMensajeExito(`Orden creada: ${resultado.codigo_seguimiento}`);
      setArticuloId(null);
      setArticuloDescripcion('');
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
            <option value="mantenimiento">Mantenimiento</option>
            <option value="garantia">Garantía</option>
          </select>
        </div>
        <button className="button button-primary btn btn-primary" type="submit" disabled={!articuloId}>Crear orden</button>
      </form>

      {mensajeExito && <p className="alert alert-success">{mensajeExito}</p>}
      {error && <p className="alert alert-danger">{error}</p>}

      <h2 className="h4 border-start border-4 ps-3">Acciones pendientes (entrega)</h2>
      {ordenes
        .filter((o) => ACCIONES_RECEPCION[o.estado_actual])
        .map((orden) => (
          <div key={orden.id} className="order-card card shadow-sm rounded-3 border-0">
            <h3 className="h5">{orden.codigo_seguimiento}</h3>
            <p>Cliente: {orden.cliente_nombre} — Estado: <strong className="badge rounded-pill bg-success-subtle text-success">{formatearEstado(orden.estado_actual)}</strong></p>
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
          </div>
        ))}

      <h2 className="h4 border-start border-4 ps-3">Todas las órdenes</h2>
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
                <th className="fw-semibold">Estado</th>
                <th className="fw-semibold">Tipo</th>
              </tr>
            </thead>
            <tbody>
              {ordenes.map((orden) => (
                <tr key={orden.id}>
                  <td data-label="Código">{orden.codigo_seguimiento}</td>
                  <td data-label="Artículo">{orden.articulo_tipo} {orden.marca}</td>
                  <td data-label="Cliente">{orden.cliente_nombre}</td>
                  <td data-label="Estado"><span className="badge rounded-pill bg-success-subtle text-success">{formatearEstado(orden.estado_actual)}</span></td>
                  <td data-label="Tipo">{formatearTipoOrden(orden.tipo)}</td>
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
