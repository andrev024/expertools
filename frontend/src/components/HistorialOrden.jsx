import { useState } from 'react';
import { apiFetch } from '../api';
import { formatearEstado } from '../utils/textoUI';

function HistorialOrden({ ordenId }) {
  const [abierto, setAbierto] = useState(false);
  const [cargando, setCargando] = useState(false);
  const [historial, setHistorial] = useState([]);
  const [error, setError] = useState('');

  async function alternarHistorial() {
    if (abierto) {
      setAbierto(false);
      return;
    }

    setAbierto(true);
    if (historial.length > 0) return;

    setCargando(true);
    setError('');
    try {
      const datos = await apiFetch(`historial.php?orden_id=${ordenId}`);
      setHistorial(datos);
    } catch (err) {
      setError(err.message);
    } finally {
      setCargando(false);
    }
  }

  return (
    <div className="order-history">
      <button type="button" className="history-toggle" onClick={alternarHistorial}>
        <span aria-hidden="true">{abierto ? '−' : '+'}</span>
        {abierto ? 'Ocultar historial' : 'Ver historial y comentarios'}
      </button>

      {abierto && (
        <div className="history-panel">
          {cargando && <p className="muted mb-0">Cargando historial...</p>}
          {error && <p className="message error mb-0">{error}</p>}
          {!cargando && !error && historial.length === 0 && (
            <p className="muted mb-0">Esta orden todavía no tiene movimientos.</p>
          )}
          {!cargando && !error && historial.length > 0 && (
            <ol className="history-list">
              {historial.map((paso, index) => (
                <li key={`${paso.fecha}-${index}`}>
                  <div className="history-item-head">
                    <strong>{formatearEstado(paso.estado)}</strong>
                    <time>{paso.fecha}</time>
                  </div>
                  {paso.comentario && <p>{paso.comentario}</p>}
                  {paso.usuario_nombre && <small>Registrado por {paso.usuario_nombre}</small>}
                </li>
              ))}
            </ol>
          )}
        </div>
      )}
    </div>
  );
}

export default HistorialOrden;