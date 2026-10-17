import jsPDF from 'jspdf';
import autoTable from 'jspdf-autotable';
import { apiFetch, apiFetchBlob } from '../api';
import { formatearEstado, formatearTipoOrden } from './textoUI';
import { enlaceSeguimiento } from './whatsapp';

function formatearMoneda(valor) {
  return `$${Number(valor || 0).toLocaleString('es-CO')}`;
}

async function cargarLogoDataUrl() {
  const blob = await apiFetchBlob('marca_logo.php');
  return new Promise((resolve, reject) => {
    const lector = new FileReader();
    lector.onload = () => resolve(lector.result);
    lector.onerror = reject;
    lector.readAsDataURL(blob);
  });
}

// Trae la cotización más reciente de una orden, o null si aún no tiene (no rompe el flujo).
export async function obtenerCotizacionOrden(ordenId) {
  try {
    return await apiFetch(`cotizacion.php?orden_id=${ordenId}`);
  } catch {
    return null;
  }
}

// Arma el comprobante/factura en PDF de una orden. Si se pasa `cotizacion`,
// agrega la sección de diagnóstico y detalle de repuestos con el total y abono.
export async function generarFacturaOrdenPdf({ orden, cotizacion }) {
  const doc = new jsPDF();
  const marca = await apiFetch('marca.php');
  const logo = marca.tiene_logo ? await cargarLogoDataUrl() : null;
  const margenX = 15;
  let y = 15;

  if (logo) {
    doc.addImage(logo, logo.startsWith('data:image/jpeg') ? 'JPEG' : 'PNG', margenX, y, 26, 26);
  }
  const xTitulo = logo ? margenX + 32 : margenX;
  const anchoTitulo = 180 - (xTitulo - margenX);

  doc.setFontSize(15);
  doc.setFont(undefined, 'bold');
  const lineasNombre = doc.splitTextToSize(marca.nombre_comercial, anchoTitulo);
  doc.text(lineasNombre, xTitulo, y + 7);
  doc.setFont(undefined, 'normal');
  doc.setFontSize(10);
  const yDatos = y + 9 + lineasNombre.length * 6;
  doc.text('Comprobante de servicio', xTitulo, yDatos);
  doc.text(`Código de seguimiento: ${orden.codigo_seguimiento || ''}`, xTitulo, yDatos + 6);
  doc.text(`Estado actual: ${formatearEstado(orden.estado_actual)}`, xTitulo, yDatos + 12);
  doc.text(`Fecha de emisión: ${new Date().toLocaleString('es-CO', { timeZone: 'America/Bogota' })}`, xTitulo, yDatos + 18);

  y = Math.max(y + 36, yDatos + 24);
  doc.setDrawColor(200);
  doc.line(margenX, y, 195, y);
  y += 8;

  doc.setFontSize(12);
  doc.setFont(undefined, 'bold');
  doc.text('Datos del cliente', margenX, y);
  doc.setFont(undefined, 'normal');
  doc.setFontSize(10);
  y += 6;
  [
    orden.cliente_nombre ? `Nombre: ${orden.cliente_nombre}` : null,
    orden.cliente_empresa ? `Empresa: ${orden.cliente_empresa}` : null,
    orden.cliente_telefono ? `Teléfono: ${orden.cliente_telefono}` : null,
    orden.cliente_cedula ? `Cédula: ${orden.cliente_cedula}` : null,
    orden.cliente_correo ? `Correo: ${orden.cliente_correo}` : null,
  ].filter(Boolean).forEach((linea) => { doc.text(linea, margenX, y); y += 5; });

  y += 3;
  doc.setFontSize(12);
  doc.setFont(undefined, 'bold');
  doc.text('Datos del artículo', margenX, y);
  doc.setFont(undefined, 'normal');
  doc.setFontSize(10);
  y += 6;
  doc.text(`Tipo de servicio: ${formatearTipoOrden(orden.tipo)}`, margenX, y); y += 5;
  doc.text(`Artículo: ${orden.articulo_tipo || ''}${orden.marca ? ` ${orden.marca}` : ''}${orden.modelo ? ` ${orden.modelo}` : ''}`, margenX, y); y += 5;
  if (Array.isArray(orden.accesorios) && orden.accesorios.length) {
    doc.text('Accesorios recibidos:', margenX, y); y += 5;
    orden.accesorios.forEach((accesorio) => {
      doc.text(`- ${accesorio.nombre}${accesorio.descripcion ? `: ${accesorio.descripcion}` : ''}`, margenX + 3, y);
      y += 5;
    });
  }

  if (cotizacion) {
    y += 3;
    doc.setFontSize(12);
    doc.setFont(undefined, 'bold');
    doc.text('Diagnóstico y cotización', margenX, y);
    doc.setFont(undefined, 'normal');
    doc.setFontSize(10);
    y += 6;
    if (cotizacion.dictamen) {
      const lineas = doc.splitTextToSize(`Diagnóstico: ${cotizacion.dictamen}`, 180);
      doc.text(lineas, margenX, y);
      y += lineas.length * 5;
    }

    const repuestos = Array.isArray(cotizacion.repuestos) ? cotizacion.repuestos : [];
    if (repuestos.length) {
      autoTable(doc, {
        startY: y,
        head: [['Repuesto/Servicio', 'Cant.', 'Vlr. unitario', 'Total']],
        body: repuestos.map((r) => [
          r.referencia || '',
          String(r.cantidad ?? ''),
          formatearMoneda(r.montoUnitario),
          formatearMoneda(Number(r.cantidad || 0) * Number(r.montoUnitario || 0)),
        ]),
        margin: { left: margenX, right: margenX },
        styles: { fontSize: 9 },
        headStyles: { fillColor: [30, 30, 30] },
      });
      y = doc.lastAutoTable.finalY + 8;
    } else {
      doc.text('No requiere repuestos', margenX, y);
      y += 8;
    }

    doc.setFont(undefined, 'bold');
    doc.text(`Total: ${formatearMoneda(cotizacion.monto)}`, margenX, y); y += 6;
    if (Number(cotizacion.abono) > 0) {
      doc.text(`Abono requerido: ${formatearMoneda(cotizacion.abono)}`, margenX, y); y += 6;
      doc.text(`Saldo pendiente: ${formatearMoneda(Number(cotizacion.monto || 0) - Number(cotizacion.abono || 0))}`, margenX, y); y += 6;
    }
    doc.setFont(undefined, 'normal');
  }

  y += 4;
  doc.setDrawColor(200);
  doc.line(margenX, y, 195, y);
  y += 8;
  doc.setFontSize(9);
  doc.setTextColor(90);
  doc.text(`Seguimiento en línea: ${enlaceSeguimiento(orden.codigo_seguimiento)}`, margenX, y); y += 5;
  if (marca.telefono) {
    doc.text(`Teléfono: ${marca.telefono}`, margenX, y);
    y += 5;
  }
  if (marca.direccion) {
    const lineasDireccion = doc.splitTextToSize(`Dirección: ${marca.direccion}`, 180);
    doc.text(lineasDireccion, margenX, y);
  }

  return doc;
}

// Genera el PDF y dispara su descarga en el navegador.
export async function descargarFacturaOrden({ orden, cotizacion, sufijo }) {
  const doc = await generarFacturaOrdenPdf({ orden, cotizacion });
  const nombre = `Comprobante-${orden.codigo_seguimiento || orden.id}${sufijo ? `-${sufijo}` : ''}.pdf`;
  doc.save(nombre);
}
