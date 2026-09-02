const API_BASE = 'http://localhost:8000';

// Función central para hacer peticiones a la API.
// Agrega automáticamente el header Authorization si hay un token guardado.
export async function apiFetch(endpoint, opciones = {}) {
  const token = localStorage.getItem('token');

  const headers = {
    'Content-Type': 'application/json',
    ...(token ? { Authorization: `Bearer ${token}` } : {}),
    ...opciones.headers,
  };

  const respuesta = await fetch(`${API_BASE}/${endpoint}`, {
    ...opciones,
    headers,
  });

  const datos = await respuesta.json();

  if (!respuesta.ok) {
    // Si el backend respondió con error (400, 401, 403, etc.),
    // lanzamos una excepción con el mensaje que mandó PHP.
    throw new Error(datos.error || 'Error en la petición');
  }

  return datos;
}
