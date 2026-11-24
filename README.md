# Firma
Aplicación web para registrar entregas de equipo de protección personal, guardar firmas localmente y sincronizar registros con Firebase. El servidor Express también conserva sus rutas opcionales para SQL Server.

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

Al escribir una nómina existente, el formulario consulta la colección `empleados` de Firestore y completa nombre, fecha de ingreso, área y puesto. Si la nómina no existe, captura esos datos manualmente; se guardarán al registrar la primera entrega y se autocompletarán en futuras consultas.

## Guardado en Firestore

`config.js` conecta la aplicación con el proyecto Firebase ya configurado. Al guardar una responsiva con conexión, se guarda en Firestore en `responsivas/{id}` y sus equipos y firmas en la subcolección `equipos`. Los datos del empleado se guardan en `empleados/{nomina}` para autocompletar futuras responsivas. También se conserva una copia local en IndexedDB para usar la aplicación sin conexión.

La app usa las reglas actuales de Firestore; deben permitir leer y escribir en esas colecciones. Si Firestore rechaza una operación, se muestra el error y el registro local se conserva.

## Firmas en SQL Server

Antes de cambiar el esquema, respalda `EnviosImagenesDB`. Después ejecuta `database.sql` en SQL Server Management Studio. El script agrega columnas `VARBINARY(MAX)`, convierte las firmas Base64 válidas existentes y conserva las cadenas antiguas que no pueda convertir. Reinicia Node.js antes de guardar nuevas entregas; desde entonces las firmas nuevas se guardan como binario.

Puedes comprobar el almacenamiento con:

```sql
SELECT Id, DATALENGTH(FirmaRecibeBin) AS BytesFirmaRecibe,
       DATALENGTH(FirmaEntregaBin) AS BytesFirmaEntrega
FROM dbo.AsignacionesEPP
ORDER BY Id DESC;
```

## Instalar en iPad y usar sin conexión

La versión publicada en GitHub Pages guarda empleados, responsivas y firmas en IndexedDB del navegador del iPad y los envía a Firestore cuando hay conexión. No se envían a GitHub ni a SQL Server. La primera visita necesita conexión para descargar la aplicación; después de instalarla desde Safari, la aplicación puede abrirse sin conexión.

1. Abre `https://alejandra212s.github.io/FirmasMen/` en Safari.
2. Toca **Compartir** y selecciona **Añadir a pantalla de inicio**.
3. Confirma con **Añadir**. Abre la app desde el icono nuevo.
4. Usa **Exportar respaldo** periódicamente y guarda el archivo JSON en Archivos o iCloud Drive. **Importar respaldo** reemplaza los datos locales del iPad.

Los datos están vinculados a ese iPad y a esa instalación de Safari. Si se borra el historial/datos del sitio o se cambia de dispositivo, restaura primero un respaldo. Las rutas de SQL Server del servidor Express no se usan desde esta aplicación.


