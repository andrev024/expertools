function ControlesListaOrdenes({
  busqueda,
  onBusqueda,
  pagina,
  onPagina,
  totalPaginas,
  total,
  porPagina,
  onPorPagina,
  modoVista,
  onModoVista,
}) {
  return (
    <div className="lista-ordenes-controles">
      <label className="filtro-campo lista-busqueda">
        <span>Buscar en esta lista</span>
        <input
          className="form-control"
          type="search"
          maxLength="120"
          placeholder="Código, cliente, teléfono o artículo"
          value={busqueda}
          onChange={(event) => onBusqueda(event.target.value)}
        />
      </label>
      <label className="filtro-campo lista-tamano">
        <span>Mostrar</span>
        <select className="form-select" value={porPagina} onChange={(event) => onPorPagina(Number(event.target.value))}>
          <option value="10">10</option>
          <option value="15">15</option>
          <option value="25">25</option>
        </select>
      </label>
      <div className="lista-vista-control" role="group" aria-label="Modo de visualización">
        <button
          type="button"
          className={`button-quiet ${modoVista === 'tarjetas' ? 'activo' : ''}`}
          aria-pressed={modoVista === 'tarjetas'}
          onClick={() => onModoVista('tarjetas')}
        >
          Tarjetas
        </button>
        <button
          type="button"
          className={`button-quiet ${modoVista === 'compacto' ? 'activo' : ''}`}
          aria-pressed={modoVista === 'compacto'}
          onClick={() => onModoVista('compacto')}
        >
          Compacto
        </button>
      </div>
      <div className="lista-paginacion" aria-label="Paginación">
        <span>{total === 0 ? 0 : (pagina - 1) * porPagina + 1}–{Math.min(pagina * porPagina, total)} de {total}</span>
        <button type="button" className="button-quiet" disabled={pagina <= 1} onClick={() => onPagina(pagina - 1)}>
          Anterior
        </button>
        <span>Página {pagina} de {totalPaginas}</span>
        <button type="button" className="button-quiet" disabled={pagina >= totalPaginas} onClick={() => onPagina(pagina + 1)}>
          Siguiente
        </button>
      </div>
    </div>
  );
}

export default ControlesListaOrdenes;
