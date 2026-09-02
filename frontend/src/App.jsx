import { useState, useEffect } from 'react';

function App() {
  const [orden, setOrden] = useState(null);
  const [cargando, setCargando] = useState(true);

  useEffect(() => {
    fetch('http://localhost:8000/seguimiento.php?codigo=TAL-3F6DB0')
      .then((respuesta) => respuesta.json())
      .then((datos) => {
        setOrden(datos);
        setCargando(false);
      });
  }, []);

  if (cargando) {
    return <p>Cargando...</p>;
  }

  return (
    <div>
      <h1>Seguimiento de tu orden</h1>
      <p>Código: {orden.codigo_seguimiento}</p>
      <p>Estado actual: {orden.estado_actual}</p>
    </div>
  );
}

export default App;