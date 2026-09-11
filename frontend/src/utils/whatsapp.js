// URL pública del frontend (Vercel), usada para armar el link de seguimiento
// que se incluye en los mensajes de WhatsApp.
export const FRONTEND_URL = 'https://expertools.vercel.app';

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
