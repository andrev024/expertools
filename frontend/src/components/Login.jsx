import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../context/authContextValue';
import Seguimiento from './Seguimiento';

function Login() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const { login } = useAuth();
  const navigate = useNavigate();

  async function manejarSubmit(e) {
    e.preventDefault();
    setError('');

    try {
      await login(email, password);
      navigate('/panel');
    } catch (err) {
      setError(err.message);
    }
  }

  return (
    <div className="auth-page bg-light min-vh-100">
      <div className="auth-brand d-flex align-items-center"><img className="auth-logo" src="/logo-expertools.png" alt="Expertools" /></div>
      <div className="auth-layout container">
        <section className="auth-hero">
          <span className="eyebrow text-uppercase fw-semibold">Plataforma empresarial</span>
          <h1 className="display-4 fw-semibold">Tu operación, en movimiento.</h1>
          <p className="text-secondary">Una vista clara para coordinar servicios, clientes y equipos con la confianza de tener todo bajo control.</p>
        </section>
        <section className="auth-card card shadow-sm rounded-3 border-0">
          <div className="card-body p-4">
          <span className="eyebrow text-uppercase fw-semibold">Acceso interno</span>
          <h2 className="h3 mt-2">Iniciar sesión</h2>
          <p className="muted text-secondary">Ingresa con tus credenciales para continuar.</p>
          <form onSubmit={manejarSubmit}>
            <div className="field mb-3">
              <label className="form-label fw-semibold">Email</label>
          <input
            className="form-control"
            type="email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
          />
            </div>
            <div className="field mb-3">
          <label className="form-label fw-semibold">Contraseña</label>
          <input
            className="form-control"
            type="password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
          />
            </div>
            {error && <p className="message error alert alert-danger">{error}</p>}
            <button className="button button-primary button-wide btn btn-primary" type="submit">Entrar al panel <span aria-hidden="true">→</span></button>
          </form>

          </div>
        </section>
      </div>
      <section className="tracking-login-card card shadow-sm rounded-3 border-0">
        <div className="card-body p-4">
          <Seguimiento embebido />
        </div>
      </section>
    </div>
  );
}

export default Login;
