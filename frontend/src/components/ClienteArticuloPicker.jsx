import { useState } from 'react';
import { apiFetch } from '../api';
import { CATALOGO_ARTICULOS, TIPOS_DISPONIBLES } from '../catalogoArticulos';

function ClienteArticuloPicker({ onArticuloSeleccionado }) {
  const [busqueda, setBusqueda] = useState('');
  const [clientes, setClientes] = useState([]);
  const [clienteSeleccionado, setClienteSeleccionado] = useState(null);
  const [articulos, setArticulos] = useState([]);
  const [error, setError] = useState('');

  const [creandoNuevo, setCreandoNuevo] = useState(false);
  const [nuevoCliente, setNuevoCliente] = useState({ nombre: '', telefono: '' });

  // Estado del formulario de articulo, ahora con seleccion en cascada
  const [tipoSeleccionado, setTipoSeleccionado] = useState('');
  const [marcaSeleccionada, setMarcaSeleccionada] = useState('');
  const [modeloSeleccionado, setModeloSeleccionado] = useState('');
  const [serial, setSerial] = useState('');

  // Campos de texto libre, solo visibles si se elige "Otro" en tipo/marca/modelo
  const [tipoLibre, setTipoLibre] = useState('');
  const [marcaLibre, setMarcaLibre] = useState('');
  const [modeloLibre, setModeloLibre] = useState('');

  // Marcas disponibles dependen del tipo elegido (mas la opcion "Otra")
  const marcasDisponibles = tipoSeleccionado && CATALOGO_ARTICULOS[tipoSeleccionado]
    ? [...Object.keys(CATALOGO_ARTICULOS[tipoSeleccionado]), 'Otra']
    : ['Otra'];

  // Modelos disponibles dependen del tipo Y la marca elegidos
  const modelosDisponibles = tipoSeleccionado && marcaSeleccionada && CATALOGO_ARTICULOS[tipoSeleccionado]?.[marcaSeleccionada]
    ? [...CATALOGO_ARTICULOS[tipoSeleccionado][marcaSeleccionada], 'Otro']
    : ['Otro'];

  function manejarCambioTipo(valor) {
    setTipoSeleccionado(valor);
    // Al cambiar el tipo, reseteamos marca y modelo (ya no son validos para el nuevo tipo)
    setMarcaSeleccionada('');
    setModeloSeleccionado('');
    setMarcaLibre('');
    setModeloLibre('');
  }

  function manejarCambioMarca(valor) {
    setMarcaSeleccionada(valor);
    setModeloSeleccionado('');
    setModeloLibre('');
  }

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

    const tipoFinal = tipoSeleccionado === 'Otro' ? tipoLibre : tipoSeleccionado;
    const marcaFinal = marcaSeleccionada === 'Otra' ? marcaLibre : marcaSeleccionada;
    const modeloFinal = modeloSeleccionado === 'Otro' ? modeloLibre : modeloSeleccionado;

    if (!clienteSeleccionado && (!nuevoCliente.nombre || !nuevoCliente.telefono)) {
      setError('Nombre y teléfono del cliente son requeridos');
      return;
    }
    if (!tipoFinal) {
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
        body: JSON.stringify({
          cliente_id: clienteId,
          tipo: tipoFinal,
          marca: marcaFinal,
          modelo: modeloFinal,
          serial,
        }),
      });

      const nombreClienteMostrar = clienteSeleccionado?.nombre || nuevoCliente.nombre;
      onArticuloSeleccionado(articulo.id, `${tipoFinal} ${marcaFinal} - ${nombreClienteMostrar}`);
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

          {/* Selector de TIPO */}
          <label>Tipo de artículo</label>
          <select
            value={tipoSeleccionado}
            onChange={(e) => manejarCambioTipo(e.target.value)}
            style={{ display: 'block', marginBottom: '6px', width: '100%' }}
          >
            <option value="">-- Selecciona --</option>
            {TIPOS_DISPONIBLES.map((t) => (
              <option key={t} value={t}>{t}</option>
            ))}
          </select>
          {tipoSeleccionado === 'Otro' && (
            <input
              placeholder="Especifica el tipo"
              value={tipoLibre}
              onChange={(e) => setTipoLibre(e.target.value)}
              style={{ display: 'block', marginBottom: '6px', width: '100%' }}
            />
          )}

          {/* Selector de MARCA -- solo aparece si ya se eligio un tipo */}
          {tipoSeleccionado && (
            <>
              <label>Marca</label>
              <select
                value={marcaSeleccionada}
                onChange={(e) => manejarCambioMarca(e.target.value)}
                style={{ display: 'block', marginBottom: '6px', width: '100%' }}
              >
                <option value="">-- Selecciona --</option>
                {marcasDisponibles.map((m) => (
                  <option key={m} value={m}>{m}</option>
                ))}
              </select>
              {marcaSeleccionada === 'Otra' && (
                <input
                  placeholder="Especifica la marca"
                  value={marcaLibre}
                  onChange={(e) => setMarcaLibre(e.target.value)}
                  style={{ display: 'block', marginBottom: '6px', width: '100%' }}
                />
              )}
            </>
          )}

          {/* Selector de MODELO -- solo aparece si ya se eligio marca */}
          {marcaSeleccionada && (
            <>
              <label>Modelo</label>
              <select
                value={modeloSeleccionado}
                onChange={(e) => setModeloSeleccionado(e.target.value)}
                style={{ display: 'block', marginBottom: '6px', width: '100%' }}
              >
                <option value="">-- Selecciona --</option>
                {modelosDisponibles.map((m) => (
                  <option key={m} value={m}>{m}</option>
                ))}
              </select>
              {modeloSeleccionado === 'Otro' && (
                <input
                  placeholder="Especifica el modelo"
                  value={modeloLibre}
                  onChange={(e) => setModeloLibre(e.target.value)}
                  style={{ display: 'block', marginBottom: '6px', width: '100%' }}
                />
              )}
            </>
          )}

          <input
            placeholder="Serial (opcional)"
            value={serial}
            onChange={(e) => setSerial(e.target.value)}
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
