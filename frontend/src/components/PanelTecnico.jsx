import { useState, useEffect } from 'react';
import { apiFetch } from '../api';
import { formatearEstado } from '../utils/textoUI';

// Transiciones simples (via cambiar_estado.php) que no requieren formulario extra
const TRANSICIONES_SIMPLES = {
  en_reparacion: ['esperando_repuesto', 'finalizado_tecnico'],
  esperando_repuesto: ['en_reparacion'],
  finalizado_tecnico: ['en_revision_recepcion'],
};

// Estados donde el tecnico tiene algo que hacer, en cualquiera de las 3 formas:
// tomar la orden, diagnosticar/cotizar, responder por el cliente, o transicion simple.
const ESTADOS_ACCIONABLES = [
  'recibido',
  'en_diagnostico',
  'cotizado',
  'en_reparacion',
  'esperando_repuesto',
  'finalizado_tecnico',
];

function PanelTecnico() {
  const [ordenes, setOrdenes] = useState([]);
  const [cargando, setCargando] = useState(true);
  const [error, setError] = useState('');
  const [comentarios, setComentarios] = useState({});

  // Formularios de cotizacion, uno por orden: { ordenId: {repuestos, dictamen, monto} }
  const [formsCotizacion, setFormsCotizacion] = useState({});
  const [canales, setCanales] = useState({}); // { ordenId: 'presencial' | 'whatsapp' }

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
    cargarOrdenes();
  }, []);

  async function cambiarEstadoSimple(ordenId, nuevoEstado) {
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

  // "Tomar" una orden recibida: pasa a en_diagnostico
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

  async function enviarCotizacion(ordenId) {
    setError('');
    const form = formsCotizacion[ordenId] || {};
    if (!form.dictamen || !form.monto) {
      setError('Dictamen y monto son requeridos');
      return;
    }

    try {
      await apiFetch('cotizacion.php', {
        method: 'POST',
        body: JSON.stringify({
          orden_id: ordenId,
          repuestos: form.repuestos || '',
          dictamen: form.dictamen,
          monto: Number(form.monto),
        }),
      });
      cargarOrdenes();
    } catch (err) {
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
          canal: canales[ordenId] || 'presencial',
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
      {error && <p className="alert alert-danger">{error}</p>}
      {ordenes.length === 0 && <p className="alert alert-light border">No hay órdenes pendientes por ahora.</p>}

      {ordenes.map((orden) => (
        <div key={orden.id} className="order-card card shadow-sm rounded-3 border-0">
          <h3 className="h5">{orden.codigo_seguimiento}</h3>
          <p>Cliente: {orden.cliente_nombre} ({orden.cliente_telefono})</p>
          <p>Artículo: {orden.articulo_tipo} {orden.marca}</p>
          <p>Estado actual: <strong className="badge rounded-pill bg-success-subtle text-success">{formatearEstado(orden.estado_actual)}</strong></p>

          {/* Estado: recibido -> boton para tomar la orden */}
          {orden.estado_actual === 'recibido' && (
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
              <input
                className="form-control mb-2"
                placeholder="Repuestos (referencia, cantidad, descripción)"
                value={formsCotizacion[orden.id]?.repuestos || ''}
                onChange={(e) => actualizarFormCotizacion(orden.id, 'repuestos', e.target.value)}
                style={{ display: 'block', width: '100%', marginBottom: '6px' }}
              />
              <input
                className="form-control mb-2"
                type="number"
                placeholder="Monto cotizado"
                value={formsCotizacion[orden.id]?.monto || ''}
                onChange={(e) => actualizarFormCotizacion(orden.id, 'monto', e.target.value)}
                style={{ display: 'block', width: '100%', marginBottom: '6px' }}
              />
              <button className="button button-primary btn btn-primary" onClick={() => enviarCotizacion(orden.id)}>Enviar cotización</button>{' '}
              <button className="button button-danger btn btn-outline-danger" onClick={() => marcarChatarra(orden.id)} style={{ color: 'red' }}>
                Marcar como chatarra (irreparable)
              </button>
            </div>
          )}

          {/* Estado: cotizado -> registrar la respuesta del cliente */}
          {orden.estado_actual === 'cotizado' && (
            <div>
              <p>Intentos de contacto: {orden.intentos_contacto_cliente} / 3</p>
              <select
                className="form-select mb-2"
                value={canales[orden.id] || 'presencial'}
                onChange={(e) => setCanales({ ...canales, [orden.id]: e.target.value })}
                style={{ display: 'block', marginBottom: '6px' }}
              >
                <option value="presencial">Presencial</option>
                <option value="whatsapp">WhatsApp</option>
              </select>
              <button className="button button-primary btn btn-primary" onClick={() => responderCliente(orden.id, 'aprobada')}>Cliente aprobó</button>{' '}
              <button className="button button-danger btn btn-outline-danger" onClick={() => responderCliente(orden.id, 'rechazada')}>Cliente rechazó</button>{' '}
              <button className="button button-secondary btn btn-outline-secondary" onClick={() => responderCliente(orden.id, 'intento_fallido')}>
                Intento sin respuesta
              </button>
            </div>
          )}

          {/* Estados con transicion simple */}
          {TRANSICIONES_SIMPLES[orden.estado_actual] && (
            <div>
              <input
                className="form-control mb-2"
                type="text"
                placeholder="Comentario (opcional)"
                value={comentarios[orden.id] || ''}
                onChange={(e) => setComentarios({ ...comentarios, [orden.id]: e.target.value })}
                style={{ display: 'block', marginBottom: '6px', width: '100%' }}
              />
              {TRANSICIONES_SIMPLES[orden.estado_actual].map((siguiente) => (
                <button className="button button-secondary btn btn-outline-secondary" key={siguiente} onClick={() => cambiarEstadoSimple(orden.id, siguiente)} style={{ marginRight: '8px' }}>
                  Pasar a: {formatearEstado(siguiente)}
                </button>
              ))}
            </div>
          )}
        </div>
      ))}
    </div>
  );
}

export default PanelTecnico;
