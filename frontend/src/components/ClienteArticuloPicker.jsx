import { useState } from 'react';
import { apiFetch } from '../api';

// Este componente le devuelve al padre un articulo_id ya resuelto,
// via la funcion onArticuloSeleccionado que recibe como prop.
//
// IMPORTANTE: este componente vive DENTRO de otro <form> (el de crearOrden
// en PanelRecepcion), asi que aqui NUNCA usamos <form>/onSubmit -- los
// formularios anidados son invalidos en HTML y el navegador los "aplana",
// haciendo que los botones internos disparen el submit del formulario externo
// por error. En su lugar, usamos <div> + botones type="button" con onClick.
function ClienteArticuloPicker({ onArticuloSeleccionado }) {
  const [busqueda, setBusqueda] = useState('');
  const [clientes, setClientes] = useState([]);
  const [clienteSeleccionado, setClienteSeleccionado] = useState(null);
  const [articulos, setArticulos] = useState([]);
  const [error, setError] = useState('');

  const [creandoNuevo, setCreandoNuevo] = useState(false);
  const [nuevoCliente, setNuevoCliente] = useState({ nombre: '', telefono: '' });
  const [nuevoArticulo, setNuevoArticulo] = useState({ tipo: '', marca: '', modelo: '', serial: '' });

  async function buscarClientes() {
    setError('');
    try {
      const datos = await apiFetch(`clientes.php?buscar=${encodeURIComponent(busqueda)}`);
      setClientes(datos);
    } catch (err) {
      setError(err.message);
    }
  }

  async function seleccionarCliente(cliente) {
    setClienteSeleccionado(cliente);
    setCreandoNuevo(false);
    try {
      const datos = await apiFetch(`articulos.php?cliente_id=${cliente.id}`);
      setArticulos(datos);
    } catch (err) {
      setError(err.message);
    }
  }

  async function crearClienteYArticulo() {
    setError('');

    if (!clienteSeleccionado && (!nuevoCliente.nombre || !nuevoCliente.telefono)) {
      setError('Nombre y teléfono del cliente son requeridos');
      return;
    }
    if (!nuevoArticulo.tipo) {
      setError('El tipo de artículo es requerido');
      return;
    }

    try {
      let clienteId = clienteSeleccionado?.id;

      if (!clienteId) {
        const cliente = await apiFetch('clientes.php', {
          method: 'POST',
          body: JSON.stringify(nuevoCliente),
        });
        clienteId = cliente.id;
      }

      const articulo = await apiFetch('articulos.php', {
        method: 'POST',
        body: JSON.stringify({ ...nuevoArticulo, cliente_id: clienteId }),
      });

      const nombreClienteMostrar = clienteSeleccionado?.nombre || nuevoCliente.nombre;
      onArticuloSeleccionado(articulo.id, `${nuevoArticulo.tipo} ${nuevoArticulo.marca} - ${nombreClienteMostrar}`);
    } catch (err) {
      setError(err.message);
    }
  }

  return (
    <div className="picker-card card shadow-sm rounded-3 border-0">
      <div className="card-body p-4">
      <h3 className="h5 border-start border-4 ps-3">1. Buscar cliente</h3>
      <div className="input-group mb-3">
        <input
          className="form-control"
          type="text"
          placeholder="Nombre o teléfono del cliente"
          value={busqueda}
          onChange={(e) => setBusqueda(e.target.value)}
          style={{ width: '60%', marginRight: '8px' }}
        />
        <button className="btn btn-primary" type="button" onClick={buscarClientes}>Buscar</button>
      </div>

      {error && <p className="alert alert-danger">{error}</p>}

      {clientes.length > 0 && (
        <ul className="list-group list-group-flush mb-3">
          {clientes.map((c) => (
            <li className="list-group-item px-0 d-flex justify-content-between align-items-center" key={c.id}>
              {c.nombre} ({c.telefono}){' '}
              <button className="btn btn-outline-primary btn-sm" type="button" onClick={() => seleccionarCliente(c)}>Seleccionar</button>
            </li>
          ))}
        </ul>
      )}

      <button className="btn btn-outline-secondary mt-2" type="button" onClick={() => setCreandoNuevo(true)}>
        Cliente nuevo (no encontrado)
      </button>

      {clienteSeleccionado && !creandoNuevo && (
        <div className="mt-4">
          <h3 className="h5 border-start border-4 ps-3">2. Artículos de {clienteSeleccionado.nombre}</h3>
          {articulos.length === 0 && <p>Este cliente no tiene artículos registrados aún.</p>}
          <ul className="list-group list-group-flush mb-3">
            {articulos.map((a) => (
              <li className="list-group-item px-0 d-flex justify-content-between align-items-center" key={a.id}>
                {a.tipo} {a.marca} {a.modelo}{' '}
                <button
                  className="btn btn-outline-primary btn-sm"
                  type="button"
                  onClick={() => onArticuloSeleccionado(a.id, `${a.tipo} ${a.marca} - ${clienteSeleccionado.nombre}`)}
                >
                  Usar este artículo
                </button>
              </li>
            ))}
          </ul>
          <button className="btn btn-outline-secondary" type="button" onClick={() => setCreandoNuevo(true)}>Agregar artículo nuevo para este cliente</button>
        </div>
      )}

      {creandoNuevo && (
        <div className="mt-4">
          <h3 className="h5 border-start border-4 ps-3">Datos nuevos</h3>
          {!clienteSeleccionado && (
            <>
              <input
                className="form-control mb-2"
                placeholder="Nombre del cliente"
                value={nuevoCliente.nombre}
                onChange={(e) => setNuevoCliente({ ...nuevoCliente, nombre: e.target.value })}
                style={{ display: 'block', marginBottom: '6px', width: '100%' }}
              />
              <input
                className="form-control mb-2"
                placeholder="Teléfono"
                value={nuevoCliente.telefono}
                onChange={(e) => setNuevoCliente({ ...nuevoCliente, telefono: e.target.value })}
                style={{ display: 'block', marginBottom: '6px', width: '100%' }}
              />
            </>
          )}
          <input
            className="form-control mb-2"
            placeholder="Tipo (taladro, pulidora...)"
            value={nuevoArticulo.tipo}
            onChange={(e) => setNuevoArticulo({ ...nuevoArticulo, tipo: e.target.value })}
            style={{ display: 'block', marginBottom: '6px', width: '100%' }}
          />
          <input
            className="form-control mb-2"
            placeholder="Marca"
            value={nuevoArticulo.marca}
            onChange={(e) => setNuevoArticulo({ ...nuevoArticulo, marca: e.target.value })}
            style={{ display: 'block', marginBottom: '6px', width: '100%' }}
          />
          <input
            className="form-control mb-2"
            placeholder="Modelo"
            value={nuevoArticulo.modelo}
            onChange={(e) => setNuevoArticulo({ ...nuevoArticulo, modelo: e.target.value })}
            style={{ display: 'block', marginBottom: '6px', width: '100%' }}
          />
          <input
            className="form-control mb-2"
            placeholder="Serial"
            value={nuevoArticulo.serial}
            onChange={(e) => setNuevoArticulo({ ...nuevoArticulo, serial: e.target.value })}
            style={{ display: 'block', marginBottom: '6px', width: '100%' }}
          />
          <button className="btn btn-primary" type="button" onClick={crearClienteYArticulo}>
            {clienteSeleccionado ? 'Crear artículo' : 'Crear cliente y artículo'}
          </button>
        </div>
      )}
      </div>
    </div>
  );
}

export default ClienteArticuloPicker;
