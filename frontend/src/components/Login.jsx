import { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';

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
    <div style={{ maxWidth: '300px', margin: '80px auto' }}>
      <h2>Iniciar sesión</h2>
      <form onSubmit={manejarSubmit}>
        <div>
          <label>Email</label>
          <input
            type="email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            style={{ display: 'block', width: '100%', marginBottom: '10px' }}
          />
        </div>
        <div>
          <label>Contraseña</label>
          <input
            type="password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            style={{ display: 'block', width: '100%', marginBottom: '10px' }}
          />
        </div>
        {error && <p style={{ color: 'red' }}>{error}</p>}
        <button type="submit">Entrar</button>
      </form>

      <hr style={{ margin: '24px 0' }} />

      <p style={{ textAlign: 'center' }}>
        ¿Eres cliente y quieres ver el estado de tu reparación?<br />
        <Link to="/seguimiento">Consulta aquí con tu código</Link>
      </p>
    </div>
  );
}

export default Login;
