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
    <div style={{ border: '1px dashed #888', padding: '12px', marginBottom: '16px' }}>
      <h3>1. Buscar cliente</h3>
      <div>
        <input
          type="text"
          placeholder="Nombre o teléfono del cliente"
          value={busqueda}
          onChange={(e) => setBusqueda(e.target.value)}
          style={{ width: '60%', marginRight: '8px' }}
        />
        <button type="button" onClick={buscarClientes}>Buscar</button>
      </div>

      {error && <p style={{ color: 'red' }}>{error}</p>}

      {clientes.length > 0 && (
        <ul>
          {clientes.map((c) => (
            <li key={c.id}>
              {c.nombre} ({c.telefono}){' '}
              <button type="button" onClick={() => seleccionarCliente(c)}>Seleccionar</button>
            </li>
          ))}
        </ul>
      )}

      <button type="button" onClick={() => setCreandoNuevo(true)} style={{ marginTop: '8px' }}>
        Cliente nuevo (no encontrado)
      </button>

      {clienteSeleccionado && !creandoNuevo && (
        <div style={{ marginTop: '16px' }}>
          <h3>2. Artículos de {clienteSeleccionado.nombre}</h3>
          {articulos.length === 0 && <p>Este cliente no tiene artículos registrados aún.</p>}
          <ul>
            {articulos.map((a) => (
              <li key={a.id}>
                {a.tipo} {a.marca} {a.modelo}{' '}
                <button
                  type="button"
                  onClick={() => onArticuloSeleccionado(a.id, `${a.tipo} ${a.marca} - ${clienteSeleccionado.nombre}`)}
                >
                  Usar este artículo
                </button>
              </li>
            ))}
          </ul>
          <button type="button" onClick={() => setCreandoNuevo(true)}>Agregar artículo nuevo para este cliente</button>
        </div>
      )}

      {creandoNuevo && (
        <div style={{ marginTop: '16px' }}>
          <h3>Datos nuevos</h3>
          {!clienteSeleccionado && (
            <>
              <input
                placeholder="Nombre del cliente"
                value={nuevoCliente.nombre}
                onChange={(e) => setNuevoCliente({ ...nuevoCliente, nombre: e.target.value })}
                style={{ display: 'block', marginBottom: '6px', width: '100%' }}
              />
              <input
                placeholder="Teléfono"
                value={nuevoCliente.telefono}
                onChange={(e) => setNuevoCliente({ ...nuevoCliente, telefono: e.target.value })}
                style={{ display: 'block', marginBottom: '6px', width: '100%' }}
              />
            </>
          )}
          <input
            placeholder="Tipo (taladro, pulidora...)"
            value={nuevoArticulo.tipo}
            onChange={(e) => setNuevoArticulo({ ...nuevoArticulo, tipo: e.target.value })}
            style={{ display: 'block', marginBottom: '6px', width: '100%' }}
          />
          <input
            placeholder="Marca"
            value={nuevoArticulo.marca}
            onChange={(e) => setNuevoArticulo({ ...nuevoArticulo, marca: e.target.value })}
            style={{ display: 'block', marginBottom: '6px', width: '100%' }}
          />
          <input
            placeholder="Modelo"
            value={nuevoArticulo.modelo}
            onChange={(e) => setNuevoArticulo({ ...nuevoArticulo, modelo: e.target.value })}
            style={{ display: 'block', marginBottom: '6px', width: '100%' }}
          />
          <input
            placeholder="Serial"
            value={nuevoArticulo.serial}
            onChange={(e) => setNuevoArticulo({ ...nuevoArticulo, serial: e.target.value })}
            style={{ display: 'block', marginBottom: '6px', width: '100%' }}
          />
          <button type="button" onClick={crearClienteYArticulo}>
            {clienteSeleccionado ? 'Crear artículo' : 'Crear cliente y artículo'}
          </button>
        </div>
      )}
    </div>
  );
}

export default ClienteArticuloPicker;
