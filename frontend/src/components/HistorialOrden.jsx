import { useState } from 'react';
import { apiFetch } from '../api';
import { formatearEstado } from '../utils/textoUI';

function HistorialOrden({ ordenId, compacto = false }) {
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

  const contenido = (
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
  );

  return (
    <div className={compacto ? 'order-history order-history-compacta' : 'order-history'}>
      <button
        type="button"
        className={compacto ? 'history-toggle history-toggle-compacta' : 'history-toggle'}
        onClick={alternarHistorial}
        title="Ver detalle de la orden"
      >
        <span aria-hidden="true">{abierto ? '−' : '+'}</span>
        {compacto
          ? (abierto ? 'Ocultar' : 'Ver orden')
          : (abierto ? 'Ocultar historial' : 'Ver historial y comentarios')}
      </button>

      {/* En modo compacto (tabla) el panel se abre en un modal: dentro de la
          celda quedaba cortado por el ancho de columna y el scroll horizontal. */}
      {abierto && !compacto && contenido}

      {abierto && compacto && (
        <div className="history-modal-overlay" onClick={() => setAbierto(false)}>
          <div className="history-modal" role="dialog" aria-label="Historial de la orden" onClick={(e) => e.stopPropagation()}>
            <div className="history-modal-header">
              <strong>Historial y comentarios</strong>
              <button type="button" className="history-modal-close" onClick={() => setAbierto(false)} aria-label="Cerrar">×</button>
            </div>
            {contenido}
          </div>
        </div>
      )}
    </div>
  );
}

export default HistorialOrden;