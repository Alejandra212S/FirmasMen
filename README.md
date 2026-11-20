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
