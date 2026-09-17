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


// Abre (o navega) una ventana ya creada hacia el link de wa.me con el mensaje dado.
export function abrirWhatsapp(ventana, telefono, mensaje) {
  const url = `https://wa.me/${telefonoWhatsapp(telefono)}?text=${encodeURIComponent(mensaje)}`;
  if (ventana) {
    ventana.location.href = url;
  } else {
    window.location.assign(url);
  }
}
