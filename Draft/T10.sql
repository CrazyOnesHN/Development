USE [KINYO_DEVEL]
GO

DECLARE	@return_value int

EXEC	@return_value = [dbo].[SMCommission]
		@BeginDate = N'20220301',
		@EndDate = N'20220331',
		@SlpCode = 11

--SELECT	'Return Value' = @return_value

GO
