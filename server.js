require('dotenv').config();
const express = require('express');
const mssql = require('mssql');
const cors = require('cors');
const path = require('path');

const app = express();

// Configuraciones del servidor express
app.use(cors());
app.use(express.json({ limit: '50mb' })); // Sel amplia el límite para soportar el tamaño de la firma en Base64
app.use(express.static(path.join(__dirname)));

app.get('/api/health', (_req, res) => {
    res.status(200).json({ estado: 'activo' });
});

app.get('/api/empleados/:nomina', async (req, res) => {
    try {
        const nomina = String(req.params.nomina || '').trim();
        if (!nomina) {
            return res.status(400).json({ error: 'La nómina es obligatoria.' });
        }

        const pool = await mssql.connect(dbConfig);
        const resultado = await new mssql.Request(pool)
            .input('nomina', mssql.VarChar(20), nomina)
            .query(`
                SELECT TOP 1
                    Nomina,
                    NombreCompleto,
                    FechaIngreso,
                    AreaPlanta,
                    Puesto
                FROM dbo.Empleados
                WHERE Nomina = @nomina
            `);

        if (resultado.recordset.length === 0) {
            return res.status(404).json({ error: 'No existe un empleado con esa nómina.' });
        }

        res.status(200).json(resultado.recordset[0]);
    } catch (error) {
        console.error('Error consultando empleado:', error);
        res.status(500).json({ error: 'Error consultando SQL Server: ' + error.message });
    }
});

// Configuración de la conexión a SQL Server Express
const dbConfig = {
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    server: process.env.DB_SERVER || 'localhost\\SQLEXPRESS',
    database: process.env.DB_NAME || 'EnviosImagenesDB',
    options: {
        encrypt: false, 
        trustServerCertificate: true // Requerido para desarrollo local
    }
};

// Ruta API encargada de procesar el registro y guardarlo en SQL Server
app.post('/api/guardar-responsiva', async (req, res) => {
    const { empleado, equipos } = req.body;
    let transaction;

    try {
        if (!empleado || !Array.isArray(equipos) || equipos.length === 0) {
            return res.status(400).json({ error: 'Faltan los datos del empleado o de los equipos.' });
        }

        const pool = await mssql.connect(dbConfig);
        transaction = new mssql.Transaction(pool);
        await transaction.begin();

        const empleadoRequest = new mssql.Request(transaction);
        const resultadoEmpleado = await empleadoRequest
            .input('nomina', mssql.VarChar(20), empleado.nomina)
            .input('nombre', mssql.NVarChar(150), empleado.nombre)
            .input('fechaIngreso', mssql.Date, empleado.fechaIngreso || null)
            .input('area', mssql.NVarChar(50), empleado.area)
            .input('puesto', mssql.NVarChar(50), empleado.puesto)
            
            .query(`
                IF NOT EXISTS (SELECT 1 FROM dbo.Empleados WHERE Nomina = @nomina)
                BEGIN
                    INSERT INTO dbo.Empleados (Nomina, NombreCompleto, FechaIngreso, AreaPlanta, Puesto)
                    VALUES (@nomina, @nombre, @fechaIngreso, @area, @puesto);
                END
                ELSE
                BEGIN
                    UPDATE dbo.Empleados
                    SET NombreCompleto = @nombre,
                        FechaIngreso = @fechaIngreso,
                        AreaPlanta = @area,
                        Puesto = @puesto
                    WHERE Nomina = @nomina;
                END
                SELECT Id FROM dbo.Empleados WHERE Nomina = @nomina;
            `);

        const empleadoId = resultadoEmpleado.recordset[0].Id;

        for (const equipo of equipos) {
            await new mssql.Request(transaction)
                .input('empleadoId', mssql.Int, empleadoId)
                .input('fechaEntrega', mssql.Date, equipo.fechaEntrega)
                .input('region', mssql.NVarChar(100), equipo.region)
                .input('articulo', mssql.NVarChar(150), equipo.articulo)
                .input('talla', mssql.NVarChar(20), equipo.talla)
                .input('unidad', mssql.NVarChar(20), equipo.unidad)
                .input('cantidad', mssql.Int, equipo.cantidad)
                .input('motivo', mssql.NVarChar(100), equipo.motivo)
                .input('nombreRecibe', mssql.NVarChar(150), equipo.nombreRecibe)
                .input('firmaRecibe', mssql.VarChar(mssql.MAX), equipo.firmaRecibe)
                .input('nombreEntrega', mssql.NVarChar(150), equipo.nombreEntrega)
                .input('firmaEntrega', mssql.VarChar(mssql.MAX), equipo.firmaEntrega)
                .query(`
                    INSERT INTO dbo.AsignacionesEPP (
                        EmpleadoId, FechaEntrega, RegionAnatomica, ArticuloEntregado,
                        Talla, Unidad, Cantidad, MotivoEntrega,
                        NombreRecibe, FirmaRecibe, NombreEntrega, FirmaEntrega
                    )
                    VALUES (
                        @empleadoId, @fechaEntrega, @region, @articulo,
                        @talla, @unidad, @cantidad, @motivo,
                        @nombreRecibe, @firmaRecibe, @nombreEntrega, @firmaEntrega
                    );
                `);
        }

        await transaction.commit();
        res.status(200).json({ mensaje: '¡Registro completado y guardado correctamente!' });

    } catch (error) {
        if (transaction) {
            try { await transaction.rollback(); } catch (_) {}
        }
        console.error('Error procesando la base de datos:', error);
        res.status(500).json({ error: 'Error en SQL Server: ' + error.message });
    }
});



// Levantar el servidor local en el puerto 3000
const PUERTO = Number(process.env.PORT) || 3000;
app.listen(PUERTO, '0.0.0.0', () => {
    console.log(` Servidor de Planta activo en el puerto ${PUERTO}`);
});