import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { AuthProvider, useAuth } from './context/AuthContext';
import Login from './components/Login';
import PanelRecepcion from './components/PanelRecepcion';
import PanelTecnico from './components/PanelTecnico';
import Seguimiento from './components/Seguimiento';

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
    <div style={{ padding: '20px' }}>
      <div style={{ display: 'flex', justifyContent: 'space-between' }}>
        <h1>Panel interno</h1>
        <div>
          <span>Hola, {usuario.nombre} ({usuario.rol}) </span>
          <button onClick={logout}>Cerrar sesión</button>
        </div>
      </div>

      {/* Por ahora solo recepcion tiene vista construida.
          El panel de tecnico lo agregamos en el siguiente paso. */}
      {(usuario.rol === 'recepcion' || usuario.rol === 'admin') && <PanelRecepcion />}
      {usuario.rol === 'tecnico' && <PanelTecnico />}
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
