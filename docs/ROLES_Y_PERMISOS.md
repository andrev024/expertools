# Roles y permisos

| Rol | Responsabilidades principales |
|---|---|
| Recepcion | Registrar clientes y ordenes, consultar ordenes, gestionar entrega y avisar al cliente |
| Tecnico | Tomar ordenes, diagnosticar, crear o editar cotizaciones y registrar avances de reparacion |
| Administrador | Gestionar usuarios y aplicar cambios de estado administrativos cuando sea necesario |
| Cliente | Consultar publicamente el avance de una orden mediante su codigo de seguimiento |

Las operaciones internas requieren autenticacion mediante JWT. El seguimiento publico no requiere cuenta, pero solo expone la informacion preparada para consulta del cliente y no los datos internos de autenticacion o administracion.

Cada usuario pertenece a una ferretería. Las operaciones de gestión de usuarios
(listar, crear, editar y eliminar) solo afectan usuarios de la misma
ferretería; el mismo límite aplica a clientes, artículos, órdenes y sus
registros asociados. Los roles conservan sus permisos actuales dentro de esa
ferretería.
