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

`config.js` conecta la aplicación con el proyecto Firebase ya configurado. Los datos del empleado, el contenido de cada responsiva y cada equipo se cifran con AES-GCM antes de guardarse en Firestore. Los datos cifrados se descifran al buscar un empleado; los documentos antiguos sin cifrar siguen siendo compatibles. Los nuevos documentos de empleado usan el SHA-256 de la nómina como ID; los registros antiguos conservan su ruta original hasta que se migren. La copia local de las responsivas y los respaldos exportados también se cifran; el registro local de empleados permanece sin cifrar.

**Importante:** el hash de nómina oculta el valor a simple vista, pero una nómina predecible puede adivinarse probando valores posibles. La clave de cifrado también está escrita en el JavaScript que se publica con la aplicación, por lo que cualquier persona que descargue el sitio puede obtenerla. Esto no sustituye un secreto privado ni protege contra alguien que inspeccione el código. Los registros antiguos no se migran automáticamente.

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


