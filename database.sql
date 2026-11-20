IF DB_ID(N'EnviosImagenesDB') IS NULL
    CREATE DATABASE EnviosImagenesDB;
GO

USE EnviosImagenesDB;
GO

IF OBJECT_ID(N'dbo.Empleados', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Empleados (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        Nomina VARCHAR(20) NOT NULL UNIQUE,
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
        Id INT IDENTITY(1,1) PRIMARY KEY,
        EmpleadoId INT NOT NULL,
        FechaEntrega DATE NOT NULL,
        RegionAnatomica NVARCHAR(100) NOT NULL,
        ArticuloEntregado NVARCHAR(150) NOT NULL,
        Talla NVARCHAR(20) NULL,
        Unidad NVARCHAR(20) NULL,
        Cantidad INT NOT NULL,
        MotivoEntrega NVARCHAR(100) NULL,
        NombreRecibe NVARCHAR(150) NOT NULL,
        FirmaRecibe VARCHAR(MAX) NOT NULL,
        NombreEntrega NVARCHAR(150) NOT NULL,
        FirmaEntrega VARCHAR(MAX) NOT NULL,
        FechaRegistro DATETIME2 NOT NULL CONSTRAINT DF_Asignaciones_Fecha DEFAULT SYSUTCDATETIME(),
        CONSTRAINT FK_Asignaciones_Empleado FOREIGN KEY (EmpleadoId)
            REFERENCES dbo.Empleados(Id)
    );
END;
GO

IF COL_LENGTH(N'dbo.AsignacionesEPP', N'FechaEntrega') IS NULL
    ALTER TABLE dbo.AsignacionesEPP ADD FechaEntrega DATE NULL;
GO

IF COL_LENGTH(N'dbo.AsignacionesEPP', N'RegionAnatomica') IS NULL
    ALTER TABLE dbo.AsignacionesEPP ADD RegionAnatomica NVARCHAR(100) NULL;
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

IF COL_LENGTH(N'dbo.AsignacionesEPP', N'FirmaRecibe') IS NULL
    ALTER TABLE dbo.AsignacionesEPP ADD FirmaRecibe VARCHAR(MAX) NULL;
GO

IF COL_LENGTH(N'dbo.AsignacionesEPP', N'NombreEntrega') IS NULL
    ALTER TABLE dbo.AsignacionesEPP ADD NombreEntrega NVARCHAR(150) NULL;
GO

IF COL_LENGTH(N'dbo.AsignacionesEPP', N'FirmaEntrega') IS NULL
    ALTER TABLE dbo.AsignacionesEPP ADD FirmaEntrega VARCHAR(MAX) NULL;
GO

IF COL_LENGTH(N'dbo.AsignacionesEPP', N'FechaRegistro') IS NULL
    ALTER TABLE dbo.AsignacionesEPP
        ADD FechaRegistro DATETIME2 NOT NULL
            CONSTRAINT DF_Asignaciones_Fecha DEFAULT SYSUTCDATETIME();
GO
