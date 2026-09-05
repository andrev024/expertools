import { useState } from 'react';
import { Link } from 'react-router-dom';
import { apiFetch } from '../api';

function Seguimiento({ embebido = false }) {
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
    <div className={embebido ? 'tracking-embedded' : 'tracking-page min-vh-100 bg-light'}>
      {!embebido && (
        <header className="public-header container-fluid border-bottom bg-white">
          <Link to="/login" className="brand d-flex align-items-center text-decoration-none"><img className="brand-logo" src="/logo-expertools.png" alt="Expertools" /></Link>
          <Link to="/login" className="text-link fw-semibold">Acceso interno →</Link>
        </header>
      )}
      <main className={embebido ? 'tracking-main tracking-main-embedded container-fluid p-0' : 'tracking-main container py-5'}>
        <div className="row justify-content-center">
          <div className="col-12">
            <span className="eyebrow text-uppercase fw-semibold">Seguimiento en tiempo real</span>
            <h1 className="display-5 fw-semibold mt-2 mb-3">Seguimiento de tu reparación</h1>
            <p className="page-lead text-secondary mb-4">Ingresa el código que te dieron en recepción para conocer el estado de tu artículo.</p>

            <form onSubmit={buscarOrden} className="tracking-form input-group mb-4">
              <input
                className="form-control"
                type="text"
                placeholder="Ej: TAL-3F6DB0"
                value={codigo}
                onChange={(e) => setCodigo(e.target.value)}
                required
              />
              <button className="btn btn-primary px-4" type="submit">Consultar</button>
            </form>

            {cargando && <p className="muted text-secondary">Buscando...</p>}
            {error && <p className="message error alert alert-danger" role="alert">{error}</p>}

            {resultado && (
              <div className="tracking-result card shadow-sm rounded-3 border-0">
                <div className="card-body p-4">
                  <div className="d-flex flex-wrap justify-content-between align-items-center gap-3 mb-4">
                    <div>
                      <span className="small text-uppercase text-secondary fw-semibold">Código de seguimiento</span>
                      <h2 className="h4 mb-0 mt-1">{resultado.codigo_seguimiento}</h2>
                    </div>
                    <p className="mb-0">
                      <span className="text-secondary me-2">Estado actual:</span>
                      <strong className="badge rounded-pill bg-success-subtle text-success">{resultado.estado_actual}</strong>
                    </p>
                  </div>

                  <h3 className="h6 text-uppercase text-secondary fw-semibold mb-3">Línea de tiempo</h3>
                  <ul className="list-group list-group-flush">
                    {resultado.linea_tiempo.map((paso, index) => (
                      // Usamos el índice como key aquí porque estos pasos no tienen
                      // un id único propio, y la lista no se reordena ni edita.
                      <li key={index} className="list-group-item px-0 py-3 d-flex justify-content-between align-items-center gap-3">
                        <span className="fw-medium">{paso.estado}</span>
                        <time className="small text-secondary text-nowrap">{paso.fecha}</time>
                      </li>
                    ))}
                  </ul>
                </div>
              </div>
            )}
          </div>
        </div>
      </main>
    </div>
  );
}

export default Seguimiento;
