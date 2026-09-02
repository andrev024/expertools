import { useState } from 'react';
import { apiFetch } from '../api';

function Seguimiento() {
  const [codigo, setCodigo] = useState('');
  const [resultado, setResultado] = useState(null);
  const [error, setError] = useState('');
  const [cargando, setCargando] = useState(false);

  async function buscarOrden(e) {
    e.preventDefault();
    setError('');
    setResultado(null);
    setCargando(true);

    try {
      const datos = await apiFetch(`seguimiento.php?codigo=${encodeURIComponent(codigo)}`);
      setResultado(datos);
    } catch (err) {
      setError(err.message);
    } finally {
      setCargando(false);
    }
  }

  return (
    <div style={{ maxWidth: '500px', margin: '60px auto', padding: '0 20px' }}>
      <h1>Seguimiento de tu reparación</h1>
      <p>Ingresa el código que te dieron en recepción para ver el estado de tu artículo.</p>

      <form onSubmit={buscarOrden} style={{ marginBottom: '24px' }}>
        <input
          type="text"
          placeholder="Ej: TAL-3F6DB0"
          value={codigo}
          onChange={(e) => setCodigo(e.target.value)}
          required
          style={{ padding: '8px', width: '60%', marginRight: '8px' }}
        />
        <button type="submit">Consultar</button>
      </form>

      {cargando && <p>Buscando...</p>}
      {error && <p style={{ color: 'red' }}>{error}</p>}

      {resultado && (
        <div style={{ border: '1px solid #ccc', padding: '16px', borderRadius: '8px' }}>
          <h2>{resultado.codigo_seguimiento}</h2>
          <p>
            Estado actual: <strong>{resultado.estado_actual}</strong>
          </p>

          <h3>Línea de tiempo</h3>
          <ul>
            {resultado.linea_tiempo.map((paso, index) => (
              // Usamos el índice como key aquí porque estos pasos no tienen
              // un id único propio, y la lista no se reordena ni edita.
              <li key={index}>
                {paso.estado} — {paso.fecha}
              </li>
            ))}
          </ul>
        </div>
      )}
    </div>
  );
}

export default Seguimiento;
