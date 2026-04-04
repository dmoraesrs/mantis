-- =============================================================================
-- SQL Server - Script de Criacao de Usuario de Monitoramento para Grafana
-- =============================================================================
-- Descricao: Cria um login/usuario dedicado com permissoes minimas necessarias
--            para monitoramento via Grafana (read-only, sem acesso a dados).
--
-- Requisitos: Executar como sysadmin no SQL Server de PRD
-- Data source: Grafana plugin "Microsoft SQL Server" (mssql)
-- =============================================================================

-- =============================================
-- PASSO 1: Criar Login no nivel do servidor
-- =============================================
-- IMPORTANTE: Altere a senha abaixo para uma senha forte e unica!
USE [master]
GO

-- Verifica se o login ja existe antes de criar
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'grafana_monitor')
BEGIN
    CREATE LOGIN [grafana_monitor] WITH PASSWORD = N'<ALTERAR_SENHA_FORTE_AQUI>',
        DEFAULT_DATABASE = [master],
        CHECK_EXPIRATION = OFF,
        CHECK_POLICY = ON;
    PRINT 'Login [grafana_monitor] criado com sucesso.';
END
ELSE
BEGIN
    PRINT 'Login [grafana_monitor] ja existe. Pulando criacao.';
END
GO

-- =============================================
-- PASSO 2: Permissoes no nivel do servidor
-- =============================================
-- VIEW SERVER STATE: Necessario para DMVs de performance (sys.dm_exec_*, sys.dm_os_*)
GRANT VIEW SERVER STATE TO [grafana_monitor];
PRINT 'Permissao VIEW SERVER STATE concedida.';
GO

-- VIEW ANY DEFINITION: Necessario para ver metadados de objetos em todos os databases
GRANT VIEW ANY DEFINITION TO [grafana_monitor];
PRINT 'Permissao VIEW ANY DEFINITION concedida.';
GO

-- CONNECT ANY DATABASE: Permite conectar em qualquer database para coletar metricas
GRANT CONNECT ANY DATABASE TO [grafana_monitor];
PRINT 'Permissao CONNECT ANY DATABASE concedida.';
GO

-- =============================================
-- PASSO 3: Criar usuario no master
-- =============================================
USE [master]
GO

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'grafana_monitor')
BEGIN
    CREATE USER [grafana_monitor] FOR LOGIN [grafana_monitor];
    PRINT 'Usuario [grafana_monitor] criado no [master].';
END
GO

-- Permissao para ler sys.master_files (tamanho dos databases)
GRANT VIEW DATABASE STATE TO [grafana_monitor];
GO

-- =============================================
-- PASSO 4: Criar usuario em TODOS os databases de usuario
-- =============================================
-- Este cursor cria o usuario grafana_monitor em cada database
-- e concede VIEW DATABASE STATE para metricas por database

DECLARE @dbname NVARCHAR(256);
DECLARE @sql NVARCHAR(MAX);

DECLARE db_cursor CURSOR FOR
    SELECT name FROM sys.databases
    WHERE state_desc = 'ONLINE'
    AND name NOT IN ('tempdb')  -- tempdb nao persiste usuarios
    AND database_id > 0;

OPEN db_cursor;
FETCH NEXT FROM db_cursor INTO @dbname;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @sql = 'USE [' + @dbname + ']; ' +
               'IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = ''grafana_monitor'') ' +
               'BEGIN ' +
               '    CREATE USER [grafana_monitor] FOR LOGIN [grafana_monitor]; ' +
               '    PRINT ''Usuario criado em [' + @dbname + ']''; ' +
               'END; ' +
               'GRANT VIEW DATABASE STATE TO [grafana_monitor]; ' +
               'PRINT ''VIEW DATABASE STATE concedido em [' + @dbname + ']'';';

    BEGIN TRY
        EXEC sp_executesql @sql;
    END TRY
    BEGIN CATCH
        PRINT 'AVISO: Nao foi possivel criar usuario em [' + @dbname + ']: ' + ERROR_MESSAGE();
    END CATCH

    FETCH NEXT FROM db_cursor INTO @dbname;
END

CLOSE db_cursor;
DEALLOCATE db_cursor;
GO

-- =============================================
-- PASSO 5: Verificacao final
-- =============================================
PRINT '';
PRINT '============================================';
PRINT 'VERIFICACAO DE PERMISSOES';
PRINT '============================================';

-- Verificar permissoes do servidor
SELECT
    'SERVER' AS scope,
    permission_name,
    state_desc
FROM sys.server_permissions
WHERE grantee_principal_id = (
    SELECT principal_id FROM sys.server_principals WHERE name = 'grafana_monitor'
)
ORDER BY permission_name;

-- Verificar em quais databases o usuario existe
PRINT '';
PRINT 'Databases com usuario grafana_monitor:';

DECLARE @dbcheck NVARCHAR(256);
DECLARE @sqlcheck NVARCHAR(MAX);

DECLARE dbcheck_cursor CURSOR FOR
    SELECT name FROM sys.databases WHERE state_desc = 'ONLINE';

OPEN dbcheck_cursor;
FETCH NEXT FROM dbcheck_cursor INTO @dbcheck;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @sqlcheck = 'IF EXISTS (SELECT 1 FROM [' + @dbcheck + '].sys.database_principals WHERE name = ''grafana_monitor'') ' +
                    'PRINT ''  [OK] ' + @dbcheck + '''';
    BEGIN TRY
        EXEC sp_executesql @sqlcheck;
    END TRY
    BEGIN CATCH
        PRINT '  [SKIP] ' + @dbcheck;
    END CATCH

    FETCH NEXT FROM dbcheck_cursor INTO @dbcheck;
END

CLOSE dbcheck_cursor;
DEALLOCATE dbcheck_cursor;
GO

PRINT '';
PRINT '============================================';
PRINT 'Setup concluido com sucesso!';
PRINT 'Use as credenciais abaixo no Grafana:';
PRINT '  Login: grafana_monitor';
PRINT '  Database: master (padrao)';
PRINT '============================================';
GO
