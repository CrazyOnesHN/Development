USE [KINYO_DEVEL]
GO

DECLARE	@return_value int

EXEC	@return_value = [dbo].[SMCommissionCreditMemo]
		@BeginDate = N'20220101',
		@EndDate = N'20220131',
		@SlpCode = 11

SELECT	'Return Value' = @return_value

GO
