import { useEffect, useState } from 'react';
import { apiFetch, apiFetchBlob, apiFetchForm } from '../api';

const MARCA_VACIA = { nombre_comercial: '', telefono: '', direccion: '' };

function MarcaFerreteria() {
  const [marca, setMarca] = useState(MARCA_VACIA);
  const [logoUrl, setLogoUrl] = useState('');
  const [archivo, setArchivo] = useState(null);
  const [cargando, setCargando] = useState(true);
  const [guardando, setGuardando] = useState(false);
  const [error, setError] = useState('');
  const [aviso, setAviso] = useState('');
  const [recarga, setRecarga] = useState(0);

  useEffect(() => {
    let vigente = true;
    let urlTemporal = '';

    async function cargarMarca() {
      setCargando(true);
      setError('');
      setLogoUrl('');
      try {
        const datos = await apiFetch('marca.php');
        if (!vigente) return;
        setMarca({
          nombre_comercial: datos.nombre_comercial || '',
          telefono: datos.telefono || '',
          direccion: datos.direccion || '',
        });
        if (datos.tiene_logo) {
          const imagen = await apiFetchBlob('marca_logo.php');
          if (!vigente) return;
          urlTemporal = URL.createObjectURL(imagen);
          setLogoUrl(urlTemporal);
        } else {
          setLogoUrl('');
        }
      } catch (err) {
        if (vigente) setError(err.message);
      } finally {
        if (vigente) setCargando(false);
      }
    }

    cargarMarca();
    return () => {
      vigente = false;
      if (urlTemporal) URL.revokeObjectURL(urlTemporal);
    };
  }, [recarga]);

  function cambiarCampo(campo, valor) {
    setMarca((anterior) => ({ ...anterior, [campo]: valor }));
  }

  async function guardarDatos(evento) {
    evento.preventDefault();
    setError('');
    setAviso('');
    setGuardando(true);
    try {
      await apiFetch('marca.php', { method: 'PUT', body: JSON.stringify(marca) });
      setAviso('Los datos del negocio se guardaron.');
    } catch (err) {
      setError(err.message);
    } finally {
      setGuardando(false);
    }
  }

  async function subirLogo(evento) {
    evento.preventDefault();
    if (!archivo) {
      setError('Selecciona un archivo PNG o JPEG.');
      return;
    }

    setError('');
    setAviso('');
    setGuardando(true);
    try {
      const datos = new FormData();
      datos.append('logo', archivo);
      const respuesta = await apiFetchForm('marca_logo.php', datos);
      setAviso(respuesta.aviso || 'El logo se actualizó.');
      setArchivo(null);
      setRecarga((valor) => valor + 1);
    } catch (err) {
      setError(err.message);
    } finally {
      setGuardando(false);
    }
  }

  async function quitarLogo() {
    if (!window.confirm('¿Quitar el logo de los comprobantes de esta ferretería?')) return;
    setError('');
    setAviso('');
    setGuardando(true);
    try {
      const respuesta = await apiFetch('marca_logo.php', { method: 'DELETE' });
      setAviso(respuesta.aviso || 'Se quitó el logo.');
      setRecarga((valor) => valor + 1);
    } catch (err) {
      setError(err.message);
    } finally {
      setGuardando(false);
    }
  }

  return (
    <section className="user-management">
      <h2 className="h4 border-start border-4 ps-3">Marca de la ferretería</h2>
      <p className="text-secondary">Estos datos y el logo aparecerán en los comprobantes PDF del negocio.</p>
      {error && <p className="alert alert-danger" role="alert">{error}</p>}
      {aviso && <p className="alert alert-success" role="status">{aviso}</p>}
      {cargando ? <p role="status">Cargando configuración…</p> : (
        <>
          <form onSubmit={guardarDatos} className="card card-body shadow-sm border-0 mb-3">
            <div className="mb-3">
              <label className="form-label fw-semibold" htmlFor="nombre-comercial">Nombre comercial</label>
              <input
                id="nombre-comercial"
                className="form-control"
                value={marca.nombre_comercial}
                maxLength={150}
                onChange={(evento) => cambiarCampo('nombre_comercial', evento.target.value)}
                required
              />
            </div>
            <div className="mb-3">
              <label className="form-label fw-semibold" htmlFor="telefono-comercial">Teléfono</label>
              <input
                id="telefono-comercial"
                className="form-control"
                value={marca.telefono}
                maxLength={60}
                onChange={(evento) => cambiarCampo('telefono', evento.target.value)}
              />
            </div>
            <div className="mb-3">
              <label className="form-label fw-semibold" htmlFor="direccion-comercial">Dirección</label>
              <input
                id="direccion-comercial"
                className="form-control"
                value={marca.direccion}
                maxLength={255}
                onChange={(evento) => cambiarCampo('direccion', evento.target.value)}
              />
            </div>
            <button className="btn btn-primary align-self-start" type="submit" disabled={guardando}>
              Guardar datos
            </button>
          </form>

          <div className="card card-body shadow-sm border-0">
            <h3 className="h5">Logo para los PDF</h3>
            {logoUrl && <img src={logoUrl} alt={`Logo de ${marca.nombre_comercial}`} style={{ maxWidth: '240px', maxHeight: '120px', objectFit: 'contain' }} />}
            <form onSubmit={subirLogo} className="mt-3">
              <label className="form-label fw-semibold" htmlFor="logo-ferreteria">Archivo PNG o JPEG (máximo 2 MB)</label>
              <input
                id="logo-ferreteria"
                key={recarga}
                className="form-control mb-3"
                type="file"
                accept="image/png,image/jpeg"
                onChange={(evento) => setArchivo(evento.target.files?.[0] || null)}
              />
              <button className="btn btn-primary me-2" type="submit" disabled={guardando || !archivo}>
                {logoUrl ? 'Reemplazar logo' : 'Subir logo'}
              </button>
              {logoUrl && (
                <button className="btn btn-outline-danger" type="button" onClick={quitarLogo} disabled={guardando}>
                  Quitar logo
                </button>
              )}
            </form>
          </div>
        </>
      )}
    </section>
  );
}

export default MarcaFerreteria;
