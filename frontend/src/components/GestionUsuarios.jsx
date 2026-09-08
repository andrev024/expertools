import { useEffect, useState } from 'react';
import { apiFetch } from '../api';
import { formatearRol } from '../utils/textoUI';

const FORMULARIO_VACIO = { nombre: '', email: '', rol: 'recepcion', password: '' };

function GestionUsuarios() {
  const [usuarios, setUsuarios] = useState([]);
  const [formulario, setFormulario] = useState(FORMULARIO_VACIO);
  const [editando, setEditando] = useState(null);
  const [error, setError] = useState('');

  async function cargarUsuarios() {
    try { setUsuarios(await apiFetch('usuarios.php')); } catch (err) { setError(err.message); }
  }
  useEffect(() => {
    const temporizador = setTimeout(() => cargarUsuarios(), 0);
    return () => clearTimeout(temporizador);
  }, []);

  function cambiarCampo(campo, valor) { setFormulario({ ...formulario, [campo]: valor }); }
  function editar(usuario) { setEditando(usuario.id); setFormulario({ ...usuario, password: '' }); }
  function cancelar() { setEditando(null); setFormulario(FORMULARIO_VACIO); }

  async function guardar(e) {
    e.preventDefault();
    setError('');
    try {
      await apiFetch('usuarios.php', { method: editando ? 'PUT' : 'POST', body: JSON.stringify({ ...formulario, id: editando }) });
      cancelar();
      cargarUsuarios();
    } catch (err) { setError(err.message); }
  }

  async function eliminar(id) {
    if (!window.confirm('¿Eliminar este usuario?')) return;
    try { await apiFetch(`usuarios.php?id=${id}`, { method: 'DELETE' }); cargarUsuarios(); } catch (err) { setError(err.message); }
  }

  return (
    <section className="user-management">
      <h2 className="h4 border-start border-4 ps-3">Usuarios</h2>
      {error && <p className="alert alert-danger">{error}</p>}
      <form onSubmit={guardar} className="card card-body shadow-sm border-0 mb-3">
        <div className="row g-2">
          <div className="col-md-3"><input className="form-control" placeholder="Nombre" value={formulario.nombre} onChange={(e) => cambiarCampo('nombre', e.target.value)} required /></div>
          <div className="col-md-3"><input className="form-control" type="email" placeholder="Email" value={formulario.email} onChange={(e) => cambiarCampo('email', e.target.value)} required /></div>
          <div className="col-md-2"><select className="form-select" value={formulario.rol} onChange={(e) => cambiarCampo('rol', e.target.value)}><option value="recepcion">Recepción</option><option value="tecnico">Técnico</option><option value="admin">Administrador</option></select></div>
          <div className="col-md-2"><input className="form-control" type="password" placeholder={editando ? 'Nueva contraseña' : 'Contraseña'} value={formulario.password} onChange={(e) => cambiarCampo('password', e.target.value)} required={!editando} /></div>
          <div className="col-md-2"><button className="btn btn-primary w-100" type="submit">{editando ? 'Actualizar' : 'Agregar'}</button></div>
        </div>
        {editando && <button type="button" className="button button-quiet mt-2" onClick={cancelar}>Cancelar edición</button>}
      </form>
      <div className="orders-table-wrapper"><table className="orders-table table table-hover align-middle"><thead><tr><th>Nombre</th><th>Email</th><th>Rol</th><th>Acciones</th></tr></thead><tbody>{usuarios.map((usuario) => <tr key={usuario.id}><td>{usuario.nombre}</td><td>{usuario.email}</td><td>{formatearRol(usuario.rol)}</td><td><button className="btn btn-outline-secondary btn-sm me-2" onClick={() => editar(usuario)}>Editar</button><button className="btn btn-outline-danger btn-sm" onClick={() => eliminar(usuario.id)}>Eliminar</button></td></tr>)}</tbody></table></div>
    </section>
  );
}

export default GestionUsuarios;
