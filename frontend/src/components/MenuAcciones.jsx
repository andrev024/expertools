import { useState } from 'react';

// Menu "..." para esconder acciones secundarias (editar repuestos, forzar estado,
// cambiar ubicacion) que se usan ocasionalmente y no necesitan estar siempre visibles.
function MenuAcciones({ etiqueta = 'Más acciones', children }) {
  const [abierto, setAbierto] = useState(false);

  return (
    <div className="menu-acciones">
      <button
        type="button"
        className="menu-acciones-boton"
        onClick={() => setAbierto((valor) => !valor)}
        aria-haspopup="true"
        aria-expanded={abierto}
        title={etiqueta}
      >
        ⋯
      </button>
      {abierto && (
        <>
          <div className="menu-acciones-backdrop" onClick={() => setAbierto(false)} />
          <div className="menu-acciones-panel" onClick={() => setAbierto(false)}>
            {children}
          </div>
        </>
      )}
    </div>
  );
}

export default MenuAcciones;
