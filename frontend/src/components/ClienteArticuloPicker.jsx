import { Fragment, useState } from 'react';
import { apiFetch } from '../api';
import { CATALOGO_ARTICULOS, TIPOS_DISPONIBLES } from '../catalogoArticulos';

function normalizarTexto(valor) {
  return String(valor || '').trim().toLowerCase().replace(/\s+/g, ' ');
}

function clientesUnicos(clientes) {
  const vistos = new Set();
  return clientes.filter((cliente) => {
    const identidad = [
      normalizarTexto(cliente.nombre),
      normalizarTexto(cliente.empresa),
      normalizarTexto(cliente.correo),
      normalizarTexto(cliente.telefono),
      normalizarTexto(cliente.telefono_2),
      normalizarTexto(cliente.cedula),
    ].join('|');
    const clave = identidad.replace(/^\|+$/, '') || `id:${cliente.id}`;
    if (vistos.has(clave)) return false;
    vistos.add(clave);
    return true;
  });
}

function normalizarAccesorios(accesorios) {
  if (Array.isArray(accesorios)) return accesorios;
  if (typeof accesorios !== 'string' || !accesorios.trim()) return [];
  try {
    const datos = JSON.parse(accesorios);
    return Array.isArray(datos) ? datos : [];
  } catch {
    return [];
  }
}

function articulosUnicos(articulos) {
  const vistos = new Set();
  return articulos.filter((articulo) => {
    const clave = [articulo.tipo, articulo.marca, articulo.modelo, articulo.serial]
      .map((valor) => normalizarTexto(valor))
      .join('|');
    if (vistos.has(clave)) return false;
    vistos.add(clave);
    return true;
  });
}

function ClienteArticuloPicker({ onArticuloSeleccionado }) {
  const [busqueda, setBusqueda] = useState('');
  const [clientes, setClientes] = useState([]);
  const [paginaClientes, setPaginaClientes] = useState(1);
  const [clienteSeleccionado, setClienteSeleccionado] = useState(null);
  const [articulos, setArticulos] = useState([]);
  const [paginaArticulos, setPaginaArticulos] = useState(1);
  const [articuloSeleccionado, setArticuloSeleccionado] = useState(null);
  const [articuloEditandoId, setArticuloEditandoId] = useState(null);
  const [articuloEditado, setArticuloEditado] = useState(null);
  const [error, setError] = useState('');
  const [clienteEditandoId, setClienteEditandoId] = useState(null);
  const [clienteEditado, setClienteEditado] = useState(null);
  const [guardandoCliente, setGuardandoCliente] = useState(false);

  const [creandoNuevo, setCreandoNuevo] = useState(false);
  const [nuevoCliente, setNuevoCliente] = useState({ nombre: '', empresa: '', correo: '', telefono: '', telefono_2: '', direccion: '', cedula: '' });

  // Estado del formulario de articulo, ahora con seleccion en cascada
  const [tipoSeleccionado, setTipoSeleccionado] = useState('');
  const [marcaSeleccionada, setMarcaSeleccionada] = useState('');
  const [modeloSeleccionado, setModeloSeleccionado] = useState('');
  const [serial, setSerial] = useState('');

  // Campos de texto libre, solo visibles si se elige "Otro" en tipo/marca/modelo
  const [tipoLibre, setTipoLibre] = useState('');
  const [marcaLibre, setMarcaLibre] = useState('');
  const [modeloLibre, setModeloLibre] = useState('');
  const [accesorios, setAccesorios] = useState([{ nombre: '', descripcion: '' }]);

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
      setClientes(clientesUnicos(datos));
      setPaginaClientes(1);
    } catch (err) {
      setError(err.message);
    }
  }

  function iniciarEdicionCliente(cliente) {
    setClienteEditandoId(cliente.id);
    setClienteEditado({ ...cliente });
    setError('');
  }

  function cancelarEdicionCliente() {
    setClienteEditandoId(null);
    setClienteEditado(null);
  }

  const [eliminandoClienteId, setEliminandoClienteId] = useState(null);

  async function eliminarCliente(cliente) {
    const nombreMostrar = cliente.nombre || cliente.empresa || 'este cliente';
    if (!window.confirm(`¿Eliminar a ${nombreMostrar}? Esta acción no se puede deshacer.`)) return;
    setError('');
    setEliminandoClienteId(cliente.id);
    try {
      await apiFetch(`clientes.php?cliente_id=${cliente.id}`, { method: 'DELETE' });
      setClientes((clientesActuales) => clientesActuales.filter((c) => String(c.id) !== String(cliente.id)));
      if (String(clienteEditandoId) === String(cliente.id)) {
        cancelarEdicionCliente();
      }
      if (String(clienteSeleccionado?.id) === String(cliente.id)) {
        cambiarCliente();
      }
    } catch (err) {
      setError(err.message);
    } finally {
      setEliminandoClienteId(null);
    }
  }

  async function guardarClienteDesdeTabla() {
    if (!clienteEditado) return;
    setError('');
    setGuardandoCliente(true);
    try {
      const clienteActualizado = await apiFetch('clientes.php', {
        method: 'PATCH',
        body: JSON.stringify({ ...clienteEditado, cliente_id: clienteEditado.id, operacion: 'actualizar' }),
      });
      const idConfirmado = clienteActualizado?.id
        ?? clienteActualizado?.cliente_id
        ?? clienteActualizado?.cliente?.id;
      if (idConfirmado && String(idConfirmado) !== String(clienteEditado.id)) {
        throw new Error('El servidor no confirmó la actualización del cliente');
      }
      const datosRespuesta = clienteActualizado && !Array.isArray(clienteActualizado)
        ? clienteActualizado.cliente || clienteActualizado
        : {};
      const clienteVisible = { ...clienteEditado, ...datosRespuesta, id: clienteEditado.id };
      setClientes((clientesActuales) => clientesActuales.map((cliente) => (
        String(cliente.id) === String(clienteVisible.id) ? clienteVisible : cliente
      )));
      if (String(clienteSeleccionado?.id) === String(clienteVisible.id)) {
        setClienteSeleccionado(clienteVisible);
      }
      cancelarEdicionCliente();
    } catch (err) {
      setError(err.message);
    } finally {
      setGuardandoCliente(false);
    }
  }

  async function seleccionarCliente(cliente) {
    setClienteSeleccionado(cliente);
    setCreandoNuevo(false);
    setArticuloSeleccionado(null);
    setPaginaArticulos(1);
    try {
      const datos = await apiFetch(`articulos.php?cliente_id=${cliente.id}`);
      setArticulos(articulosUnicos(datos));
    } catch (err) {
      setError(err.message);
    }
  }

  function seleccionarArticulo(articulo) {
    setArticuloSeleccionado(articulo);
    setSerial(articulo.serial || '');
    const accesoriosArticulo = normalizarAccesorios(articulo.accesorios);
    setAccesorios(accesoriosArticulo.length ? accesoriosArticulo : [{ nombre: '', descripcion: '' }]);
    const descripcion = `${articulo.tipo} ${articulo.marca || ''} - ${clienteSeleccionado?.nombre || clienteSeleccionado?.empresa || 'Cliente'}`;
    onArticuloSeleccionado(articulo.id, descripcion, {
      cliente: clienteSeleccionado,
    });
  }

  function iniciarEdicionArticulo(articulo) {
    const accesoriosArticulo = normalizarAccesorios(articulo.accesorios);
    setArticuloEditandoId(articulo.id);
    setArticuloEditado({
      ...articulo,
      accesorios: accesoriosArticulo.length ? accesoriosArticulo : [{ nombre: '', descripcion: '' }],
    });
    setError('');
  }

  function cancelarEdicionArticulo() {
    setArticuloEditandoId(null);
    setArticuloEditado(null);
  }

  function guardarArticuloDesdeModal() {
    if (!articuloEditado) return;
    setArticuloSeleccionado(articuloEditado);
    setArticulos((articulosActuales) => articulosActuales.map((articulo) => (
      String(articulo.id) === String(articuloEditado.id) ? articuloEditado : articulo
    )));
    const descripcion = `${articuloEditado.tipo} ${articuloEditado.marca || ''} - ${clienteSeleccionado?.nombre || clienteSeleccionado?.empresa || 'Cliente'}`;
    onArticuloSeleccionado(articuloEditado.id, descripcion, {
      cliente: clienteSeleccionado,
      articulo: articuloEditado,
    });
    cancelarEdicionArticulo();
  }

  function cambiarDatoCliente(campo, valor) {
    const clienteActualizado = { ...clienteSeleccionado, [campo]: valor };
    setClienteSeleccionado(clienteActualizado);
    if (articuloSeleccionado) {
      const descripcion = `${articuloSeleccionado.tipo} ${articuloSeleccionado.marca || ''} - ${clienteActualizado.nombre || clienteActualizado.empresa || 'Cliente'}`;
      onArticuloSeleccionado(articuloSeleccionado.id, descripcion, {
        cliente: clienteActualizado,
        articulo: articuloSeleccionado,
      });
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
          accesorios: accesorios.filter((accesorio) => accesorio.nombre.trim()),
        }),
      });

      const nombreClienteMostrar = clienteSeleccionado?.nombre || nuevoCliente.nombre;
      onArticuloSeleccionado(articulo.id, `${tipoFinal} ${marcaFinal} - ${nombreClienteMostrar}`, {
        cliente: clienteSeleccionado,
      });
    } catch (err) {
      setError(err.message);
    }
  }

  const clientesPorPagina = 4;
  const totalPaginasClientes = Math.max(1, Math.ceil(clientes.length / clientesPorPagina));
  const clientesVisibles = clientes.slice((paginaClientes - 1) * clientesPorPagina, paginaClientes * clientesPorPagina);
  const totalPaginasArticulos = Math.max(1, Math.ceil(articulos.length / clientesPorPagina));
  const articulosVisibles = articulos.slice((paginaArticulos - 1) * clientesPorPagina, paginaArticulos * clientesPorPagina);

  function iniciarClienteNuevo() {
    setClienteSeleccionado(null);
    setArticuloSeleccionado(null);
    setArticulos([]);
    setClientes([]);
    setBusqueda('');
    setNuevoCliente({ nombre: '', empresa: '', correo: '', telefono: '', telefono_2: '', direccion: '', cedula: '' });
    setCreandoNuevo(true);
  }

  // Vuelve a la búsqueda de cliente desde cero (limpia selección y resultados previos).
  function cambiarCliente() {
    setClienteSeleccionado(null);
    setArticulos([]);
    setArticuloSeleccionado(null);
    setCreandoNuevo(false);
    setClientes([]);
    setBusqueda('');
    onArticuloSeleccionado(null, '', {});
  }

  // Deja de usar el artículo elegido, para poder escoger otro del mismo cliente.
  function cambiarArticulo() {
    setArticuloSeleccionado(null);
    onArticuloSeleccionado(null, '', {});
  }

  function cancelarCreacion() {
    setCreandoNuevo(false);
  }

  return (
    <div style={{ border: '1px dashed #888', padding: '12px', marginBottom: '16px' }}>
      {error && <p style={{ color: 'red' }}>{error}</p>}

      {!clienteSeleccionado && !creandoNuevo && (
      <>
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

      {clientes.length > 0 && (
        <div className="orders-table-wrapper clientes-resultados-wrapper">
          <table className="orders-table clientes-resultados">
            <thead>
              <tr>
                <th scope="col">Cliente</th>
                <th scope="col">Correo</th>
                <th scope="col">Teléfono</th>
                <th scope="col">Acción</th>
              </tr>
            </thead>
            <tbody>
              {clientesVisibles.map((c) => (
                <Fragment key={c.id}>
                  <tr>
                    <td data-label="Cliente">
                      <strong className="cliente-nombre">{c.nombre || c.empresa || 'Cliente sin nombre'}</strong>
                    </td>
                    <td data-label="Correo" title={c.correo || ''}>
                      {c.correo || 'Sin correo'}
                    </td>
                    <td data-label="Teléfono">
                      {[c.telefono, c.telefono_2].filter(Boolean).join(' · ') || 'Sin teléfono'}
                    </td>
                    <td data-label="Acción" className="clientes-acciones">
                      <button type="button" onClick={() => seleccionarCliente(c)}>Seleccionar</button>
                      <button type="button" className="button-quiet" onClick={() => iniciarEdicionCliente(c)}>Editar</button>
                    </td>
                  </tr>
                </Fragment>
              ))}
            </tbody>
          </table>
          {totalPaginasClientes > 1 && (
            <div className="clientes-paginacion">
              <button type="button" className="button-quiet" disabled={paginaClientes === 1} onClick={() => setPaginaClientes((pagina) => pagina - 1)}>Anterior</button>
              <span>Página {paginaClientes} de {totalPaginasClientes}</span>
              <button type="button" className="button-quiet" disabled={paginaClientes === totalPaginasClientes} onClick={() => setPaginaClientes((pagina) => pagina + 1)}>Siguiente</button>
            </div>
          )}
          {clienteEditandoId && clienteEditado && (
            <div className="history-modal-overlay" onClick={cancelarEdicionCliente}>
              <div className="history-modal cliente-edicion-modal" role="dialog" aria-label="Editar cliente" onClick={(e) => e.stopPropagation()}>
                <div className="history-modal-header">
                  <strong>Editar datos del cliente</strong>
                  <button type="button" className="history-modal-close" onClick={cancelarEdicionCliente} aria-label="Cerrar">×</button>
                </div>
                <div className="cliente-edicion cliente-edicion-tabla">
                  {['nombre', 'empresa', 'correo', 'telefono', 'telefono_2', 'direccion', 'cedula'].map((campo) => (
                    <input
                      key={campo}
                      placeholder={campo === 'telefono_2' ? 'Teléfono 2' : campo.charAt(0).toUpperCase() + campo.slice(1)}
                      value={clienteEditado[campo] || ''}
                      onChange={(e) => setClienteEditado({ ...clienteEditado, [campo]: e.target.value })}
                    />
                  ))}
                  <div className="cliente-edicion-acciones">
                    <button type="button" onClick={guardarClienteDesdeTabla} disabled={guardandoCliente}>
                      {guardandoCliente ? 'Guardando...' : 'Guardar'}
                    </button>
                    <button type="button" className="button-quiet" onClick={cancelarEdicionCliente}>Cancelar</button>
                    <button
                      type="button"
                      className="button-quiet button-danger"
                      onClick={() => eliminarCliente(clienteEditado)}
                      disabled={eliminandoClienteId === clienteEditado.id}
                    >
                      {eliminandoClienteId === clienteEditado.id ? 'Eliminando...' : 'Eliminar'}
                    </button>
                  </div>
                </div>
              </div>
            </div>
          )}
        </div>
      )}

      <button type="button" onClick={iniciarClienteNuevo} style={{ marginTop: '8px' }}>
        Cliente nuevo (no encontrado)
      </button>
      </>
      )}

      {clienteSeleccionado && (
        <div className="cliente-seleccionado-resumen">
          <span>
            Cliente: <strong>{clienteSeleccionado.nombre || clienteSeleccionado.empresa}</strong>
            {clienteSeleccionado.telefono ? ` · ${clienteSeleccionado.telefono}` : ''}
          </span>
          <button type="button" className="button-quiet" onClick={cambiarCliente}>Cambiar cliente</button>
        </div>
      )}

      {clienteSeleccionado && !creandoNuevo && (
        <div style={{ marginTop: '16px' }}>
          <h3>2. Artículos de {clienteSeleccionado.nombre}</h3>
          {articulos.length === 0 && <p>Este cliente no tiene artículos registrados aún.</p>}
          {articuloSeleccionado && (
            <div className="cliente-seleccionado-resumen">
              <span>
                Artículo: <strong>{articuloSeleccionado.tipo} {articuloSeleccionado.marca || ''}</strong>
              </span>
              <button type="button" className="button-quiet" onClick={cambiarArticulo}>Cambiar artículo</button>
            </div>
          )}
          {!articuloSeleccionado && articulos.length > 0 && <div className="orders-table-wrapper articulos-cliente-wrapper">
            <table className="orders-table articulos-cliente">
              <thead>
                <tr>
                  <th scope="col">Artículo</th>
                  <th scope="col">Marca / modelo</th>
                  <th scope="col">Accesorios</th>
                  <th scope="col">Serial</th>
                  <th scope="col">Acción</th>
                </tr>
              </thead>
              <tbody>
            {articulosVisibles.map((a) => (
              <tr key={a.id}>
                <td data-label="Artículo"><strong>{a.tipo || 'Sin tipo'}</strong></td>
                <td data-label="Marca / modelo">{[a.marca, a.modelo].filter(Boolean).join(' ') || 'Sin información'}</td>
                <td data-label="Accesorios" className="articulo-accesorios-celda" title={normalizarAccesorios(a.accesorios).map((acc) => acc.nombre).filter(Boolean).join(', ')}>
                  {normalizarAccesorios(a.accesorios).map((acc) => acc.nombre).filter(Boolean).join(', ') || 'Sin accesorios'}
                </td>
                <td data-label="Serial">{a.serial || 'Sin serial'}</td>
                <td data-label="Acción">
                  <button type="button" onClick={() => seleccionarArticulo(a)}>Usar este artículo</button>
                  <button type="button" className="button-quiet" onClick={() => iniciarEdicionArticulo(a)}>Editar</button>
                </td>
              </tr>
            ))}
              </tbody>
            </table>
            {totalPaginasArticulos > 1 && (
              <div className="clientes-paginacion">
                <button type="button" className="button-quiet" disabled={paginaArticulos === 1} onClick={() => setPaginaArticulos((pagina) => pagina - 1)}>Anterior</button>
                <span>Página {paginaArticulos} de {totalPaginasArticulos}</span>
                <button type="button" className="button-quiet" disabled={paginaArticulos === totalPaginasArticulos} onClick={() => setPaginaArticulos((pagina) => pagina + 1)}>Siguiente</button>
              </div>
            )}
          </div>}
          {articuloEditandoId && articuloEditado && (
            <div className="history-modal-overlay" onClick={cancelarEdicionArticulo}>
              <div className="history-modal articulo-edicion-modal" role="dialog" aria-label="Editar artículo" onClick={(e) => e.stopPropagation()}>
                <div className="history-modal-header">
                  <strong>Editar artículo</strong>
                  <button type="button" className="history-modal-close" onClick={cancelarEdicionArticulo} aria-label="Cerrar">×</button>
                </div>
                <p>{articuloEditado.tipo} {articuloEditado.marca || ''} {articuloEditado.modelo || ''}</p>
                <label>Serial</label>
                <input
                  placeholder="Serial (opcional)"
                  value={articuloEditado.serial || ''}
                  onChange={(e) => setArticuloEditado({ ...articuloEditado, serial: e.target.value })}
                />
                <label>Accesorios recibidos</label>
                {(articuloEditado.accesorios || []).map((accesorio, indice) => (
                  <div key={`accesorio-edicion-${indice}`} className="articulo-accesorio-edicion">
                    <input
                      placeholder="Nombre del accesorio"
                      value={accesorio.nombre || ''}
                      onChange={(e) => setArticuloEditado({
                        ...articuloEditado,
                        accesorios: articuloEditado.accesorios.map((item, posicion) => posicion === indice ? { ...item, nombre: e.target.value } : item),
                      })}
                    />
                    <input
                      placeholder="Detalle opcional"
                      value={accesorio.descripcion || ''}
                      onChange={(e) => setArticuloEditado({
                        ...articuloEditado,
                        accesorios: articuloEditado.accesorios.map((item, posicion) => posicion === indice ? { ...item, descripcion: e.target.value } : item),
                      })}
                    />
                    <button type="button" className="button-quiet" onClick={() => setArticuloEditado({
                      ...articuloEditado,
                      accesorios: articuloEditado.accesorios.filter((_, posicion) => posicion !== indice),
                    })}>Quitar</button>
                  </div>
                ))}
                <div className="articulo-edicion-acciones">
                  <button type="button" className="button-quiet" onClick={() => setArticuloEditado({
                    ...articuloEditado,
                    accesorios: [...(articuloEditado.accesorios || []), { nombre: '', descripcion: '' }],
                  })}>Agregar accesorio</button>
                  <button type="button" onClick={guardarArticuloDesdeModal}>Guardar</button>
                  <button type="button" className="button-quiet" onClick={cancelarEdicionArticulo}>Cancelar</button>
                </div>
              </div>
            </div>
          )}
          <button type="button" onClick={() => setCreandoNuevo(true)}>Agregar artículo nuevo para este cliente</button>
        </div>
      )}

      {creandoNuevo && (
        <div style={{ marginTop: '16px' }}>
          <h3>Datos nuevos</h3>
          {!clienteSeleccionado && (
            <>
              {['nombre', 'empresa', 'correo', 'telefono', 'telefono_2', 'direccion', 'cedula'].map((campo) => (
                <input
                  key={campo}
                  placeholder={campo === 'telefono_2' ? 'Teléfono 2 (opcional)' : campo.charAt(0).toUpperCase() + campo.slice(1)}
                  value={nuevoCliente[campo]}
                  onChange={(e) => setNuevoCliente({ ...nuevoCliente, [campo]: e.target.value })}
                  style={{ display: 'block', marginBottom: '6px', width: '100%' }}
                />
              ))}
            </>
          )}
          {clienteSeleccionado && (
            <>
              <label>Teléfono del cliente</label>
              <input
                placeholder="Teléfono"
                value={clienteSeleccionado.telefono || ''}
                onChange={(e) => cambiarDatoCliente('telefono', e.target.value)}
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

          <label>Accesorios recibidos</label>
          {accesorios.map((accesorio, indice) => (
            <div key={`accesorio-${indice}`} style={{ display: 'flex', gap: '8px', marginBottom: '6px' }}>
              <input
                placeholder="Ej. cargador, estuche, batería"
                value={accesorio.nombre}
                onChange={(e) => setAccesorios(accesorios.map((item, posicion) => posicion === indice ? { ...item, nombre: e.target.value } : item))}
                style={{ flex: 1 }}
              />
              <input
                placeholder="Detalle opcional"
                value={accesorio.descripcion}
                onChange={(e) => setAccesorios(accesorios.map((item, posicion) => posicion === indice ? { ...item, descripcion: e.target.value } : item))}
                style={{ flex: 1 }}
              />
              <button type="button" onClick={() => setAccesorios(accesorios.filter((_, posicion) => posicion !== indice))}>Quitar</button>
            </div>
          ))}
          <button type="button" onClick={() => setAccesorios([...accesorios, { nombre: '', descripcion: '' }])}>Agregar accesorio</button>
          <div style={{ marginTop: '12px' }}> </div>
          <button type="button" onClick={crearClienteYArticulo}>
            {clienteSeleccionado ? 'Crear artículo' : 'Crear cliente y artículo'}
          </button>
          <button type="button" className="button-quiet" onClick={cancelarCreacion} style={{ marginLeft: '8px' }}>
            Cancelar
          </button>
        </div>
      )}
    </div>
  );
}

export default ClienteArticuloPicker;
