import { createContext, useContext, useState } from 'react';
import { apiFetch } from '../api';

// Creamos el "canal" de contexto. Cualquier componente hijo de AuthProvider
// va a poder leer estos datos con el hook useAuth() de abajo.
const AuthContext = createContext(null);

export function AuthProvider({ children }) {
  // Al cargar la app, revisamos si ya había una sesión guardada
  // (para que no se pierda el login al recargar la página).
  const [usuario, setUsuario] = useState(() => {
    const guardado = localStorage.getItem('usuario');
    return guardado ? JSON.parse(guardado) : null;
  });

  async function login(email, password) {
    const respuesta = await apiFetch('login.php', {
      method: 'POST',
      body: JSON.stringify({ email, password }),
    });

    localStorage.setItem('token', respuesta.token);
    localStorage.setItem('usuario', JSON.stringify(respuesta.usuario));
    setUsuario(respuesta.usuario);
  }

  function logout() {
    localStorage.removeItem('token');
    localStorage.removeItem('usuario');
    setUsuario(null);
  }

  return (
    <AuthContext.Provider value={{ usuario, login, logout }}>
      {children}
    </AuthContext.Provider>
  );
}

// Hook personalizado para usar el contexto fácilmente desde cualquier componente:
// const { usuario, login, logout } = useAuth();
export function useAuth() {
  return useContext(AuthContext);
}
