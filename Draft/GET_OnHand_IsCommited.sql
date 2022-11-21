declare @p1 int
set @p1=NULL
exec sp_prepexec @p1 output,N'@P1 nvarchar(254),@P2 nvarchar(254)',N'


SELECT 

T0.[ItemCode] , 
T0.[WhsCode] , 
T0.[OnHand] , 
T0.[IsCommited] 


FROM [dbo].[OITW] T0 

WHERE T0.[ItemCode] = (@P1)  AND  T0.[WhsCode] = (@P2)  ',N'87DYCPAK02//001',N'C2'
select @p1