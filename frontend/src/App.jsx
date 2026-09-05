import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { AuthProvider, useAuth } from './context/AuthContext';
import Login from './components/Login';
import PanelRecepcion from './components/PanelRecepcion';
import PanelTecnico from './components/PanelTecnico';
import Seguimiento from './components/Seguimiento';

function Marca() {
  return (
    <div className="brand" aria-label="Expertools">
      <img className="brand-logo" src="/logo-expertools.png" alt="Expertools" />
    </div>
  );
}

function Encabezado({ usuario, logout }) {
  return (
    <header className="site-header container-fluid bg-white border-bottom">
      <Marca />
      <div className="header-actions">
        {usuario ? (
          <>
            <div className="user-chip">
              <span className="user-avatar">{usuario.nombre?.charAt(0).toUpperCase()}</span>
              <span><b>{usuario.nombre}</b><small>{usuario.rol}</small></span>
            </div>
            <button className="button button-quiet btn btn-link" onClick={logout}>Cerrar sesión</button>
          </>
        ) : (
          <span className="header-note">Plataforma empresarial</span>
        )}
      </div>
    </header>
  );
}

// Componente "guardián": si no hay usuario logueado, redirige a /login.
function RutaProtegida({ children }) {
  const { usuario } = useAuth();
  if (!usuario) {
    return <Navigate to="/login" />;
  }
  return children;
}

function Panel() {
  const { usuario, logout } = useAuth();

  return (
    <div className="app-shell">
      <Encabezado usuario={usuario} logout={logout} />
      <main className="page-content container">
        <div className="page-intro">
          <span className="eyebrow text-uppercase fw-semibold">Expertools / {usuario.rol.toUpperCase()}</span>
          <h1 className="display-5 fw-semibold">Panel de operaciones</h1>
          <p className="page-lead text-secondary">Gestiona cada servicio con claridad, desde la recepción hasta la entrega.</p>
        </div>

      {/* Por ahora solo recepcion tiene vista construida.
          El panel de tecnico lo agregamos en el siguiente paso. */}
      {(usuario.rol === 'recepcion' || usuario.rol === 'admin') && <PanelRecepcion />}
      {usuario.rol === 'tecnico' && <PanelTecnico />}
      </main>
    </div>
  );
}

function App() {
  return (
    <AuthProvider>
      <BrowserRouter>
        <Routes>
          <Route path="/login" element={<Login />} />
          <Route path="/seguimiento" element={<Seguimiento />} />
          <Route
            path="/panel"
            element={
              <RutaProtegida>
                <Panel />
              </RutaProtegida>
            }
          />
          <Route path="/" element={<Navigate to="/panel" />} />
        </Routes>
      </BrowserRouter>
    </AuthProvider>
  );
}

export default App;
