/*
Missing Index Details from TEST01.sql - BMSTKNYSDB02.KINYO-LIVE (BMKINYO\kny.jrivera (2737))
The Query Processor estimates that implementing the following index could improve the query cost by 19.0809%.
*/


USE [KINYO-LIVE]
GO
CREATE NONCLUSTERED INDEX [RCTYPE]
ON [dbo].[OITR] ([Canceled],[ReconDate])
INCLUDE ([ReconType],[InitObjAbs])
GO

