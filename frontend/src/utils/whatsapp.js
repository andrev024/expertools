// URL pública del frontend (Vercel), usada para armar el link de seguimiento
// que se incluye en los mensajes de WhatsApp.
export const FRONTEND_URL = 'https://expertools.vercel.app';

// Formato "legacy" de Google Maps (maps.google.com/?q=...): a diferencia de
// /maps/search/?api=1&query=..., este SÍ genera una miniatura de mapa en la
// vista previa del link dentro de WhatsApp (funciona en Android e iPhone).
export const ENLACE_UBICACION = 'https://maps.google.com/?q=ExperTools%20Reparaci%C3%B3n%20Mantenimiento%20y%20Venta%20de%20Herramientas%2C%20Bogot%C3%A1';
export const ENLACE_INSTAGRAM = 'https://www.instagram.com/expertools_herramientas';

// Arma el link publico de seguimiento para un código de orden dado.
export function enlaceSeguimiento(codigoSeguimiento) {
  return `${FRONTEND_URL}/#/seguimiento?codigo=${encodeURIComponent(codigoSeguimiento || '')}`;
}

// Normaliza un teléfono colombiano de 10 dígitos (celular) al formato
// internacional que espera wa.me (57XXXXXXXXXX). Si no aplica, lo deja igual.
export function telefonoWhatsapp(telefono) {
  const soloDigitos = String(telefono || '').replace(/\D/g, '');
  return soloDigitos.length === 10 && soloDigitos.startsWith('3') ? `57${soloDigitos}` : soloDigitos;
}


// Formatea la lista de accesorios de un artículo para incluirla en un mensaje de WhatsApp.
export function formatearAccesorios(accesorios) {
  if (Array.isArray(accesorios)) {
    return accesorios
      .map((accesorio) => `- ${accesorio.nombre}${accesorio.descripcion ? `: ${accesorio.descripcion}` : ''}`)
      .join('\n');
  }
  return accesorios || '';
}

// Abre (o navega) una ventana ya creada hacia WhatsApp con el mensaje dado.
export function abrirWhatsapp(ventana, telefono, mensaje) {
  const numero = telefonoWhatsapp(telefono);
  const texto = encodeURIComponent(mensaje);
  // Se usa siempre web.whatsapp.com (en vez de wa.me) para los 3 sistemas operativos
  // de escritorio (Windows, macOS, Linux): al ser una URL https normal, el navegador
  // la carga directamente sin entregarle el texto a una app de escritorio registrada
  // como manejador del protocolo (que en Windows corrompe los emojis al pasar el texto
  // por la línea de comandos con el codepage local en vez de UTF-8). En celular, iOS y
  // Android igual interceptan este dominio como "universal link" y abren la app nativa
  // de WhatsApp sin pasar por ningún command-line, así que el comportamiento es el
  // mismo en todos los dispositivos.
  const url = `https://web.whatsapp.com/send?phone=${numero}&text=${texto}`;
  if (ventana) {
    ventana.location.href = url;
  } else {
    window.location.assign(url);
  }
}
