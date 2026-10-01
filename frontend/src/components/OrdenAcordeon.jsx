import { formatearEstado } from '../utils/textoUI';

// Fila resumen colapsada (codigo + cliente + articulo + estado) que se expande
// al hacer click para revelar el resto del contenido de la orden (children).
// Solo presentacion: no toca llamadas a la API ni logica de negocio.
function OrdenAcordeon({ orden, kicker, expandido, onToggle, claseExtra = '', children }) {
  return (
    <div className={`orden-acordeon card shadow-sm rounded-3 border-0 ${claseExtra}`.trim()}>
      <button
        type="button"
        className="orden-acordeon-resumen button-quiet"
        onClick={onToggle}
        aria-expanded={expandido}
      >
        <span className="orden-acordeon-chevron" aria-hidden="true">{expandido ? '▾' : '▸'}</span>
        <span className="orden-acordeon-codigo">{orden.codigo_seguimiento}</span>
        <span className="orden-acordeon-cliente">{orden.cliente_nombre || orden.cliente_empresa || 'Cliente sin nombre'}</span>
        <span className="orden-acordeon-articulo">{orden.articulo_tipo} {orden.marca || ''}</span>
        {kicker && <span className="orden-acordeon-kicker">{kicker}</span>}
        <strong className="status-badge orden-acordeon-badge">{formatearEstado(orden.estado_actual)}</strong>
      </button>
      {expandido && <div className="orden-acordeon-body">{children}</div>}
    </div>
  );
}

export default OrdenAcordeon;
