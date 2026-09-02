import { useState, useEffect } from 'react';
import { apiFetch } from '../api';
import ClienteArticuloPicker from './ClienteArticuloPicker';

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
    cargarOrdenes();
  }, []);

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
    <div>
      <h2>Crear nueva orden</h2>
      <form onSubmit={crearOrden} style={{ marginBottom: '24px' }}>
        <ClienteArticuloPicker
          onArticuloSeleccionado={(id, descripcion) => {
            setArticuloId(id);
            setArticuloDescripcion(descripcion);
          }}
        />

        {articuloId && (
          <p style={{ color: 'lightgreen' }}>Artículo seleccionado: {articuloDescripcion}</p>
        )}

        <div>
          <label>Tipo</label>
          <select
            value={tipo}
            onChange={(e) => setTipo(e.target.value)}
            style={{ display: 'block', marginBottom: '8px' }}
          >
            <option value="mantenimiento">Mantenimiento</option>
            <option value="garantia">Garantía</option>
          </select>
        </div>
        <button type="submit" disabled={!articuloId}>Crear orden</button>
      </form>

      {mensajeExito && <p style={{ color: 'green' }}>{mensajeExito}</p>}
      {error && <p style={{ color: 'red' }}>{error}</p>}

      <h2>Acciones pendientes (entrega)</h2>
      {ordenes
        .filter((o) => ACCIONES_RECEPCION[o.estado_actual])
        .map((orden) => (
          <div
            key={orden.id}
            style={{ border: '1px solid #ccc', padding: '12px', margin: '8px 0', borderRadius: '6px' }}
          >
            <h3>{orden.codigo_seguimiento}</h3>
            <p>Cliente: {orden.cliente_nombre} — Estado: <strong>{orden.estado_actual}</strong></p>
            <input
              type="text"
              placeholder="Comentario"
              value={comentarios[orden.id] || ''}
              onChange={(e) => setComentarios({ ...comentarios, [orden.id]: e.target.value })}
              style={{ display: 'block', marginBottom: '8px', width: '100%' }}
            />
            {ACCIONES_RECEPCION[orden.estado_actual].map((siguienteEstado) => (
              <button
                key={siguienteEstado}
                onClick={() => cambiarEstado(orden.id, siguienteEstado)}
                style={{ marginRight: '8px' }}
              >
                Pasar a: {siguienteEstado}
              </button>
            ))}
          </div>
        ))}

      <h2>Todas las órdenes</h2>
      {cargando ? (
        <p>Cargando...</p>
      ) : (
        <table border="1" cellPadding="8" style={{ borderCollapse: 'collapse', width: '100%' }}>
          <thead>
            <tr>
              <th>Código</th>
              <th>Artículo</th>
              <th>Cliente</th>
              <th>Estado</th>
              <th>Tipo</th>
            </tr>
          </thead>
          <tbody>
            {ordenes.map((orden) => (
              <tr key={orden.id}>
                <td>{orden.codigo_seguimiento}</td>
                <td>{orden.articulo_tipo} {orden.marca}</td>
                <td>{orden.cliente_nombre}</td>
                <td>{orden.estado_actual}</td>
                <td>{orden.tipo}</td>
              </tr>
            ))}
          </tbody>
        </table>
      )}
    </div>
  );
}

export default PanelRecepcion;
