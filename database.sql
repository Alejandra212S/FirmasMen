IF DB_ID(N'EnviosImagenesDB') IS NULL
BEGIN
    EXEC(N'CREATE DATABASE [EnviosImagenesDB]');
END;
GO

USE [EnviosImagenesDB];
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

IF OBJECT_ID(N'dbo.Empleados', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Empleados (
        Id INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Empleados PRIMARY KEY,
        Nomina VARCHAR(20) NOT NULL CONSTRAINT UQ_Empleados_Nomina UNIQUE,
        NombreCompleto NVARCHAR(150) NOT NULL,
        FechaIngreso DATE NULL,
        AreaPlanta NVARCHAR(50) NULL,
        Puesto NVARCHAR(50) NULL
    );
END;
GO

IF COL_LENGTH(N'dbo.Empleados', N'FechaIngreso') IS NULL
    ALTER TABLE dbo.Empleados ADD FechaIngreso DATE NULL;
GO

IF COL_LENGTH(N'dbo.Empleados', N'AreaPlanta') IS NULL
    ALTER TABLE dbo.Empleados ADD AreaPlanta NVARCHAR(50) NULL;
GO

IF COL_LENGTH(N'dbo.Empleados', N'Puesto') IS NULL
    ALTER TABLE dbo.Empleados ADD Puesto NVARCHAR(50) NULL;
GO

IF OBJECT_ID(N'dbo.AsignacionesEPP', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.AsignacionesEPP (
        Id INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_AsignacionesEPP PRIMARY KEY,
        EmpleadoId INT NOT NULL,
        FechaEntrega DATE NOT NULL,
        RegionAnatomica NVARCHAR(100) NOT NULL,
        ArticuloEntregado NVARCHAR(150) NOT NULL,
        Talla NVARCHAR(20) NULL,
        Unidad NVARCHAR(20) NULL,
        Cantidad INT NOT NULL,
        MotivoEntrega NVARCHAR(100) NULL,
        NombreRecibe NVARCHAR(150) NOT NULL,
        FirmaRecibeBin VARBINARY(MAX) NOT NULL,
        NombreEntrega NVARCHAR(150) NOT NULL,
        FirmaEntregaBin VARBINARY(MAX) NOT NULL,
        FechaRegistro DATETIME2 NOT NULL
            CONSTRAINT DF_AsignacionesEPP_FechaRegistro DEFAULT SYSUTCDATETIME(),
        CONSTRAINT FK_AsignacionesEPP_Empleados FOREIGN KEY (EmpleadoId)
            REFERENCES dbo.Empleados(Id)
    );
END;
GO

-- Add columns required by the current application without deleting legacy records.
IF COL_LENGTH(N'dbo.AsignacionesEPP', N'EmpleadoId') IS NULL
    ALTER TABLE dbo.AsignacionesEPP ADD EmpleadoId INT NULL;
GO

IF COL_LENGTH(N'dbo.AsignacionesEPP', N'FechaEntrega') IS NULL
    ALTER TABLE dbo.AsignacionesEPP ADD FechaEntrega DATE NULL;
GO

IF COL_LENGTH(N'dbo.AsignacionesEPP', N'RegionAnatomica') IS NULL
    ALTER TABLE dbo.AsignacionesEPP ADD RegionAnatomica NVARCHAR(100) NULL;
GO

IF COL_LENGTH(N'dbo.AsignacionesEPP', N'ArticuloEntregado') IS NULL
    ALTER TABLE dbo.AsignacionesEPP ADD ArticuloEntregado NVARCHAR(150) NULL;
GO

IF COL_LENGTH(N'dbo.AsignacionesEPP', N'Talla') IS NULL
    ALTER TABLE dbo.AsignacionesEPP ADD Talla NVARCHAR(20) NULL;
GO

IF COL_LENGTH(N'dbo.AsignacionesEPP', N'Unidad') IS NULL
    ALTER TABLE dbo.AsignacionesEPP ADD Unidad NVARCHAR(20) NULL;
GO

IF COL_LENGTH(N'dbo.AsignacionesEPP', N'Cantidad') IS NULL
    ALTER TABLE dbo.AsignacionesEPP ADD Cantidad INT NULL;
GO

IF COL_LENGTH(N'dbo.AsignacionesEPP', N'MotivoEntrega') IS NULL
    ALTER TABLE dbo.AsignacionesEPP ADD MotivoEntrega NVARCHAR(100) NULL;
GO

IF COL_LENGTH(N'dbo.AsignacionesEPP', N'NombreRecibe') IS NULL
    ALTER TABLE dbo.AsignacionesEPP ADD NombreRecibe NVARCHAR(150) NULL;
GO

IF COL_LENGTH(N'dbo.AsignacionesEPP', N'FirmaRecibeBin') IS NULL
    ALTER TABLE dbo.AsignacionesEPP ADD FirmaRecibeBin VARBINARY(MAX) NULL;
GO

IF COL_LENGTH(N'dbo.AsignacionesEPP', N'NombreEntrega') IS NULL
    ALTER TABLE dbo.AsignacionesEPP ADD NombreEntrega NVARCHAR(150) NULL;
GO

IF COL_LENGTH(N'dbo.AsignacionesEPP', N'FirmaEntregaBin') IS NULL
    ALTER TABLE dbo.AsignacionesEPP ADD FirmaEntregaBin VARBINARY(MAX) NULL;
GO

IF COL_LENGTH(N'dbo.AsignacionesEPP', N'FechaRegistro') IS NULL
BEGIN
    ALTER TABLE dbo.AsignacionesEPP
        ADD FechaRegistro DATETIME2 NOT NULL
            CONSTRAINT DF_AsignacionesEPP_FechaRegistro DEFAULT SYSUTCDATETIME();
END;
GO

-- Legacy signature columns remain intact; defaults allow new binary-signature inserts.
IF COL_LENGTH(N'dbo.AsignacionesEPP', N'FirmaRecibe') IS NOT NULL
   AND NOT EXISTS (
       SELECT 1
       FROM sys.default_constraints AS dc
       INNER JOIN sys.columns AS c
           ON c.object_id = dc.parent_object_id
          AND c.column_id = dc.parent_column_id
       WHERE dc.parent_object_id = OBJECT_ID(N'dbo.AsignacionesEPP')
         AND c.name = N'FirmaRecibe'
   )
BEGIN
    ALTER TABLE dbo.AsignacionesEPP
        ADD CONSTRAINT DF_AsignacionesEPP_FirmaRecibe DEFAULT ('') FOR FirmaRecibe;
END;
GO

IF COL_LENGTH(N'dbo.AsignacionesEPP', N'FirmaEntrega') IS NOT NULL
   AND NOT EXISTS (
       SELECT 1
       FROM sys.default_constraints AS dc
       INNER JOIN sys.columns AS c
           ON c.object_id = dc.parent_object_id
          AND c.column_id = dc.parent_column_id
       WHERE dc.parent_object_id = OBJECT_ID(N'dbo.AsignacionesEPP')
         AND c.name = N'FirmaEntrega'
   )
BEGIN
    ALTER TABLE dbo.AsignacionesEPP
        ADD CONSTRAINT DF_AsignacionesEPP_FirmaEntrega DEFAULT ('') FOR FirmaEntrega;
END;
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE object_id = OBJECT_ID(N'dbo.AsignacionesEPP')
      AND name = N'IX_AsignacionesEPP_EmpleadoId_FechaEntrega'
)
BEGIN
    CREATE INDEX IX_AsignacionesEPP_EmpleadoId_FechaEntrega
        ON dbo.AsignacionesEPP (EmpleadoId, FechaEntrega);
END;
GO
