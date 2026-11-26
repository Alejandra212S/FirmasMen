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

`config.js` conecta la aplicación con el proyecto Firebase ya configurado. Al abrir la app se pide un PIN numérico de 4 dígitos. Los registros nuevos se cifran con AES-GCM usando una clave derivada del PIN mediante PBKDF2; el PIN no se guarda, solo permanece en memoria mientras la app está abierta. La verificación cifrada se conserva en el almacenamiento local del navegador. Los datos nuevos cifrados se pueden leer en otro dispositivo ingresando el mismo PIN. Los registros locales de empleados siguen sin cifrar.

Los registros anteriores no se migran y siguen usando la clave antigua incluida en la aplicación para mantener su compatibilidad; por tanto, esos registros no obtienen la protección del PIN. Los nuevos IDs de empleado usan un HMAC derivado del PIN; los IDs antiguos siguen siendo hashes simples. Los respaldos nuevos se cifran con el PIN; los respaldos existentes se pueden importar con compatibilidad con el cifrado anterior.

El botón **Ver empleados A–Z** lee los documentos de la colección `empleados`, descifra los datos en el navegador y ordena los nombres con `localeCompare` en JavaScript. Como el nombre está cifrado, Firestore no puede ordenar directamente por ese campo. Esta acción requiere reglas de Firestore que permitan leer esa colección.

**Importante:** un PIN de 4 dígitos es débil: solo tiene 10,000 combinaciones y puede ser adivinado si alguien obtiene los datos cifrados. No lo consideres protección fuerte para información sensible; una frase secreta larga es mucho más segura. Conserva el PIN, porque si lo olvidas no se podrán descifrar los registros nuevos ni sus respaldos. El cifrado protege el contenido, pero no evita que alguien con reglas de Firestore demasiado abiertas lo borre o altere. Si Firestore rechaza una operación, se muestra el error y el registro local se conserva.

La opción **Olvidé mi PIN** borra solo el verificador local para permitir configurar otro PIN. No elimina registros, pero los datos cifrados con el PIN anterior ya no se podrán descifrar.

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


