import { useState } from 'react';

function OrdenCard({ codigo, estado, cliente }) {
  const [expandido, setExpandido] = useState(false);

  return (
    <div style={{ border: '1px solid #ccc', padding: '12px', margin: '8px', borderRadius: '6px' }}>
      <h3>{codigo}</h3>
      <p>Cliente: {cliente}</p>
      <p>Estado: {estado}</p>

      <button onClick={() => setExpandido(!expandido)}>
        {expandido ? 'Ocultar detalles' : 'Ver detalles'}
      </button>

      {expandido && (
        <p style={{ marginTop: '8px', color: 'gray' }}>
          Aquí irían más detalles de la orden (historial, comentarios, etc.)
        </p>
      )}
    </div>
  );
}

export default OrdenCard;