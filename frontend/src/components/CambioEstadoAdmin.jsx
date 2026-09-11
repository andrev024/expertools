import { useState } from 'react';
import { useAuth } from '../context/authContextValue';
import { apiFetch } from '../api';
import { formatearEstado } from '../utils/textoUI';

// Lista completa de estados del flujo, para que el admin pueda corregir
// una orden que quedó en el estado equivocado sin seguir la secuencia normal.
const TODOS_LOS_ESTADOS = [
  'recibido', 'en_diagnostico', 'chatarra', 'cotizado', 'esperando_abono',
  'esperando_tecnico', 'esperando_respuesta', 'sin_respuesta', 'en_reparacion',
  'esperando_repuesto', 'finalizado_tecnico', 'en_revision_recepcion',
  'listo_para_entregar', 'entregado', 'no_autorizado',
];

// Visible solo para admin: permite forzar el estado de una orden a cualquier
// valor del flujo, para corregir errores operativos sin pasar por cada paso.
function CambioEstadoAdmin({ ordenId, estadoActual, onCambiado }) {
  const { usuario } = useAuth() || {};
  const [estadoElegido, setEstadoElegido] = useState('');
  const [guardando, setGuardando] = useState(false);
  const [error, setError] = useState('');

  if (usuario?.rol !== 'admin') {
    return null;
  }

  async function aplicar() {
    if (!estadoElegido || estadoElegido === estadoActual) return;
    setError('');
    setGuardando(true);
    try {
      await apiFetch('cambiar_estado.php', {
        method: 'POST',
        body: JSON.stringify({ orden_id: ordenId, estado: estadoElegido, comentario: 'Cambio manual (admin)' }),
      });
      setEstadoElegido('');
      onCambiado?.();
    } catch (err) {
      setError(err.message);
    } finally {
      setGuardando(false);
    }
  }

  return (
    <div className="cambio-estado-admin d-flex align-items-center gap-2 mt-2 flex-wrap">
      <select className="form-select form-select-sm w-auto" value={estadoElegido} onChange={(e) => setEstadoElegido(e.target.value)}>
        <option value="">Forzar estado (admin)...</option>
        {TODOS_LOS_ESTADOS.filter((estado) => estado !== estadoActual).map((estado) => (
          <option key={estado} value={estado}>{formatearEstado(estado)}</option>
        ))}
      </select>
      <button type="button" className="button button-secondary btn btn-outline-secondary btn-sm" disabled={!estadoElegido || guardando} onClick={aplicar}>
        {guardando ? 'Aplicando...' : 'Aplicar'}
      </button>
      {error && <span className="text-danger small">{error}</span>}
    </div>
  );
}

export default CambioEstadoAdmin;
