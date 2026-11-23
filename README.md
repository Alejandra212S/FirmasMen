# Firma
Aplicación web para registrar entregas de equipo de protección personal y guardar firmas en SQL Server.

## Requisitos

- Node.js
- SQL Server Express
- SQL Server Management Studio (opcional)

## Configuración

1. Ejecuta `database.sql` en SQL Server Management Studio.
2. Copia `.env.example` como `.env`.
3. Cambia los datos de usuario y contraseña en `.env`.
4. Instala dependencias:

   ```powershell
   npm install
   ```

5. Inicia el servidor:

   ```powershell
   npm start
   ```

6. Abre `http://localhost:3000`.

Al escribir una nómina existente, el formulario consulta `dbo.Empleados` y completa nombre, fecha de ingreso, área y puesto. Si la nómina no existe, captura esos datos manualmente; se guardarán al registrar la primera entrega y se autocompletarán en futuras consultas.

## Firmas en SQL Server

Antes de cambiar el esquema, respalda `EnviosImagenesDB`. Después ejecuta `database.sql` en SQL Server Management Studio. El script agrega columnas `VARBINARY(MAX)`, convierte las firmas Base64 válidas existentes y conserva las cadenas antiguas que no pueda convertir. Reinicia Node.js antes de guardar nuevas entregas; desde entonces las firmas nuevas se guardan como binario.

Puedes comprobar el almacenamiento con:

```sql
SELECT Id, DATALENGTH(FirmaRecibeBin) AS BytesFirmaRecibe,
       DATALENGTH(FirmaEntregaBin) AS BytesFirmaEntrega
FROM dbo.AsignacionesEPP
ORDER BY Id DESC;
```


