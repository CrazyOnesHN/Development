

SELECT 

	T0.WddCode,
	CASE
		WHEN T0.[StepCode]=20 THEN 'Order Revision' 
		WHEN T0.[StepCode]=17 THEN 'Credit Limit' 
	END 'Stage', 
	CASE
		WHEN T0.[UserID]=T1.[USERID] THEN T1.U_NAME
	END 'Authorizer',
	CASE 
		WHEN T0.Status='W' THEN 'Pending' 
		WHEN T0.Status='Y' THEN	'Approved'
		WHEN T0.Status='N' THEN	'Rejected'
	END 'Answer', 	
	T0.[UpdateDate]		'Answer Date',
	('Stage: ' + CASE 	
					WHEN T0.[StepCode]=20 THEN 'Order Revision' 
					WHEN T0.[StepCode]=17 THEN 'Credit Limit' 
				 END 
	+ ' ' + ' / ' +
	'Authorizer: ' + CASE 
						WHEN T0.[UserID]=T1.[USERID] THEN T1.U_NAME 
					END 
	+ ' ' + ' / ' +
	'Status: ' + CASE 
						WHEN T0.Status='W' THEN 'Pending' 
						WHEN T0.Status='Y' THEN	'Approved'
						WHEN T0.Status='N' THEN	'Rejected' 
				 END
	+ ' ' + ' / ' + 'Issue Draft Production Ticket') STR1

FROM WDD1 T0

	INNER  JOIN [dbo].[OUSR] T1  ON  T1.[USERID] = T0.[UserID]   



WHERE T0.WddCode=5947 AND T0.StepCode=20 AND T0.Status='Y'
