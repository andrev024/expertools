# Flujo de negocio

Expertools registra una orden de servicio desde el ingreso del articulo hasta su entrega.

## Ciclo de una orden

1. Recepcion registra el cliente, el articulo y el motivo de ingreso.
2. La orden queda en `Recibido` y recibe un codigo de seguimiento.
3. El tecnico toma la orden siguiendo el criterio FIFO y la pasa a `EnDiagnostico`.
4. El tecnico registra el diagnostico. Si el articulo es irreparable, pasa a `Chatarra`.
5. Si requiere autorizacion, se crea una cotizacion y la orden pasa a `Cotizado`.
6. La aprobacion del cliente permite pasar a `EnReparacion`; el rechazo pasa a `NoAutorizado`.
7. Si falta un repuesto, la orden pasa temporalmente a `EsperandoRepuesto`.
8. Al terminar el trabajo pasa por `FinalizadoTecnico` y `EnRevisionRecepcion`.
9. Recepcion marca la orden como `ListoParaEntregar` y finalmente `Entregado`.

Cada cambio importante queda registrado en el historial con fecha, usuario y comentario cuando corresponde. El cliente consulta una version simplificada del estado desde el codigo publico de seguimiento.

## Cotizaciones

Una cotizacion puede incluir diagnostico, repuestos, cantidades, precios, monto total y abono. Actualmente el total corresponde al subtotal; el campo historico de IVA permanece en la base de datos con valor `0` para mantener compatibilidad con las migraciones existentes.
