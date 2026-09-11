import { useState } from 'react';
import { apiFetch } from '../api';

// Permite agregar/editar los repuestos de una cotización ya registrada,
// por ejemplo cuando aparece un repuesto adicional durante la reparación.
function EditorRepuestos({ ordenId, onGuardado }) {
  const [abierto, setAbierto] = useState(false);
  const [cargando, setCargando] = useState(false);
  const [guardando, setGuardando] = useState(false);
  const [error, setError] = useState('');
  const [repuestos, setRepuestos] = useState([]);

  async function abrir() {
    if (abierto) {
      setAbierto(false);
      return;
    }
    setAbierto(true);
    setError('');
    setCargando(true);
    try {
      const datos = await apiFetch(`cotizacion.php?orden_id=${ordenId}`);
      setRepuestos(
        datos.repuestos.length
          ? datos.repuestos.map((r) => ({ referencia: r.referencia || '', cantidad: r.cantidad || 1, montoUnitario: r.montoUnitario || '', descripcion: r.descripcion || '' }))
          : [{ referencia: '', cantidad: 1, montoUnitario: '', descripcion: '' }]
      );
    } catch (err) {
      setError(err.message);
    } finally {
      setCargando(false);
    }
  }

  function actualizarRepuesto(indice, campo, valor) {
    setRepuestos((actuales) => actuales.map((r, i) => (i === indice ? { ...r, [campo]: valor } : r)));
  }

  function agregarRepuesto() {
    setRepuestos((actuales) => [...actuales, { referencia: '', cantidad: 1, montoUnitario: '', descripcion: '' }]);
  }

  function quitarRepuesto(indice) {
    setRepuestos((actuales) => {
      const restantes = actuales.filter((_, i) => i !== indice);
      return restantes.length ? restantes : [{ referencia: '', cantidad: 1, montoUnitario: '', descripcion: '' }];
    });
  }

  async function guardar() {
    setError('');
    const limpios = repuestos
      .filter((r) => String(r.referencia || '').trim())
      .map((r) => ({
        ...r,
        referencia: String(r.referencia).trim(),
        cantidad: Number(r.cantidad),
        montoUnitario: Number(r.montoUnitario),
      }));
    if (limpios.some((r) => !r.cantidad || !r.montoUnitario)) {
      setError('Cantidad y valor unitario son requeridos en cada repuesto');
      return;
    }
    setGuardando(true);
    try {
      await apiFetch('cotizacion.php', {
        method: 'PUT',
        body: JSON.stringify({ orden_id: ordenId, repuestos: JSON.stringify(limpios) }),
      });
      setAbierto(false);
      onGuardado?.();
    } catch (err) {
      setError(err.message);
    } finally {
      setGuardando(false);
    }
  }

  const total = repuestos.reduce((acc, r) => acc + (Number(r.cantidad || 0) * Number(r.montoUnitario || 0)), 0);

  return (
    <div className="editor-repuestos mt-2">
      <button type="button" className="button button-quiet" onClick={abrir}>
        {abierto ? 'Cerrar edición de repuestos' : 'Editar repuestos'}
      </button>
      {abierto && (
        <div className="history-modal-overlay" onClick={() => setAbierto(false)}>
          <div className="history-modal history-modal-repuestos" role="dialog" aria-modal="true" aria-label="Editar repuestos" onClick={(e) => e.stopPropagation()}>
            <div className="history-modal-header">
              <strong>Editar repuestos</strong>
              <button type="button" className="history-modal-close" onClick={() => setAbierto(false)} aria-label="Cerrar">×</button>
            </div>
            {cargando && <p className="mb-0">Cargando repuestos...</p>}
            {error && <p className="alert alert-danger py-2">{error}</p>}
            {!cargando && (
              <>
                {repuestos.map((repuesto, indice) => (
                  <div className="row g-2 mb-2" key={`repuesto-editor-${indice}`}>
                    <div className="col-md-3">
                      <input className="form-control" placeholder="Nombre" value={repuesto.referencia} onChange={(e) => actualizarRepuesto(indice, 'referencia', e.target.value)} />
                    </div>
                    <div className="col-md-2">
                      <input className="form-control" type="number" min="1" placeholder="Cantidad" value={repuesto.cantidad} onChange={(e) => actualizarRepuesto(indice, 'cantidad', e.target.value)} />
                    </div>
                    <div className="col-md-2">
                      <input className="form-control" type="number" min="0" step="0.01" placeholder="Valor unitario" value={repuesto.montoUnitario} onChange={(e) => actualizarRepuesto(indice, 'montoUnitario', e.target.value)} />
                      <small className="text-muted">Total: ${(Number(repuesto.cantidad || 0) * Number(repuesto.montoUnitario || 0)).toLocaleString('es-CO')}</small>
                    </div>
                    <div className="col-md-3">
                      <input className="form-control" placeholder="Referencia (opcional)" value={repuesto.descripcion} onChange={(e) => actualizarRepuesto(indice, 'descripcion', e.target.value)} />
                    </div>
                    <div className="col-md-2">
                      <button type="button" className="button button-secondary btn btn-outline-secondary w-100" onClick={() => quitarRepuesto(indice)}>Quitar</button>
                    </div>
                  </div>
                ))}
                <p className="fw-semibold">Total: ${total.toLocaleString('es-CO')}</p>
                <div className="d-flex gap-2">
                  <button type="button" className="button button-secondary btn btn-outline-secondary" onClick={agregarRepuesto}>Agregar repuesto</button>
                  <button type="button" className="button button-primary btn btn-primary" onClick={guardar} disabled={guardando}>
                    {guardando ? 'Guardando...' : 'Guardar repuestos'}
                  </button>
                </div>
              </>
            )}
          </div>
        </div>
      )}
    </div>
  );
}

export default EditorRepuestos;
