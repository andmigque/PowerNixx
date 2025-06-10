
EXEC master.dbo.sp_MSset_oledb_prop 
    N'MSDASQL', 
    N'DynamicParameters', 
    1; -- Example, check correct properties
GO
RECONFIGURE
GO