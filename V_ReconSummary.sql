/****** Object:  View [dbo].[V_ReconSummary]    Script Date: 28-01-2022 17:22:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create view [dbo].[V_ReconSummary] as
 WITH tab1 as
       (
	    select ISNULL(b.Headcount,1) as Headcount,ISNULL(EstFTE,1) AS FTE,e.SSL,e.Region ,Sector_der AS Sector ,ISNULL(TransactionType,'BoY') as TransactionType, 
        		(select FiscalYear from get_Curr_FYear(getDate())) as FiscalYear, 0 as PRT_TransactionID
         From
        	(select 'BoY' as TransactionType, t.headcount,EstFTE, FK_Employee, FiscalYear,Region
        	 FROM
        		(select EstFTE, FK_TransactionType, FK_Employee,FiscalYear, NULL as Region from dbo.F_PRTDirectAdmit 
        		  where FiscalYear <(select FiscalYear from get_Curr_FYear(getDate())) and   Active is null
        		Union 
        		 select EstFTE,FK_TransactionType, FK_Employee,FiscalYear,NULL as Region from dbo.F_PRTPromotion where FiscalYear <(select FiscalYear from get_Curr_FYear(getDate())) and  Active is null
        		Union 
        		 select  EstFTE, FK_TransactionType, FK_Employee,FiscalYear,Region from dbo.F_PRTTransferIn where FiscalYear <(select FiscalYear from get_Curr_FYear(getDate())) and  Active is null
        		Union 
        		 select  EstFTE,FK_TransactionType, FK_Employee,FiscalYear,NULL as Region from dbo.F_PRTTransferOut where FiscalYear <(select FiscalYear from get_Curr_FYear(getDate())) and  Active is null
        		Union 
        		 select EstFTE,FK_TransactionType, FK_Employee,FiscalYear,NULL as Region from dbo.F_PRTRetirement where FiscalYear <(select FiscalYear from get_Curr_FYear(getDate())) and  Active is null
        		Union 
        		 select  EstFTE,FK_TransactionType, FK_Employee,FiscalYear,NULL as Region from dbo.F_PRTSeparation where FiscalYear <(select FiscalYear from get_Curr_FYear(getDate())) and  Active is null) AS a
        	 inner join dbo.D_PRTTransactionType t on t.PRT_TransactionID = a.FK_TransactionType
			) as b
        right join (select SSL, Region, PRT_EmployeeID, Joining_Date,Sector_der
                      from  dbo.D_PRTEmployee c
	    		     where Rank = 'Partner/Principal' 
					   and   Active is null 
	    				  --and   Joining_Date <=(select startDate from get_Curr_FYear(getDate())) 
	    		       and not exists (select FK_employee from dbo.F_PRTPromotion p where p.FK_employee=c.PRT_employeeID and Active is null
                                       Union All
	    						       select FK_employee from dbo.F_PRTDirectAdmit d where d.FK_employee=c.PRT_employeeID and Active is null
	    					           ) 
        				
	    ) as e on e.PRT_EmployeeID = b.FK_Employee
       Union All
        select (b.Headcount) as Headcount, ISNULL(b.EstFTE,1) as FTE,isnull(e.SSL,b.SSL) as SSL, isnull(b.Region,e.Region) as Region,isnull(Sector_der,'NA') AS Sector ,b.TransactionType, b.FiscalYear,(       b.FK_TransactionType) as PRT_TransactionID
         From
        	(select t.TransactionType, t.headcount, a.EstimatedDate, a.EstFTE, a.FK_TransactionType,Region,SSL, a.FK_Employee, ISNULL(a.FiscalYear,(select FiscalYear from get_Curr_FYear(getDate()))) as        FiscalYear
        	  FROM
        	     (select EstimatedDate, EstFTE, FK_TransactionType, FK_Employee, FiscalYear,NULL as Region,null as SSL from dbo.F_PRTDirectAdmit where FiscalYear=(select FiscalYear from get_Curr_FYear(getDate())) and Active is Null
        		  Union All
        		  select EstimatedDate, EstFTE, FK_TransactionType, FK_Employee, FiscalYear,NULL as Region,null as SSL from dbo.F_PRTPromotion where FiscalYear=(select FiscalYear from get_Curr_FYear(getDate())) and Active is Null
        		  Union All
        		  select EstimatedDate, EstFTE, FK_TransactionType, FK_Employee, FiscalYear,Region ,null as SSL from dbo.F_PRTTransferIn where FiscalYear=(select FiscalYear from get_Curr_FYear(getDate())) and Active is Null
        		  Union All
        		  select EstimatedDate, EstFTE, FK_TransactionType, FK_Employee, FiscalYear,NULL as Region,null as SSL from dbo.F_PRTTransferOut where FiscalYear=(select FiscalYear from get_Curr_FYear(getDate())) and Active is Null
        		  Union All
        		  select EstimatedDate, EstFTE, FK_TransactionType, FK_Employee, FiscalYear,NULL as Region,null as SSL from dbo.F_PRTRetirement where FiscalYear=(select FiscalYear from get_Curr_FYear(getDate())) and Active is Null
        		  Union All
        		  select EstimatedDate, EstFTE, FK_TransactionType, FK_Employee, FiscalYear,NULL as Region,null as SSL from dbo.F_PRTSeparation where FiscalYear=(select FiscalYear from get_Curr_FYear(getDate())) and Active is Null
	    		  Union All
	    		  select EstimatedDate,EstFTE,FK_TransactionType, FK_Employee,FiscalYear,Region,SSL from [dbo].[D_PRTTBD] where FiscalYear =(select FiscalYear from get_Curr_FYear(getDate())) and Active is Null
	    		  ) AS a
        	inner join dbo.D_PRTTransactionType t on t.PRT_TransactionID = a.FK_TransactionType) as b
        left join (select PRT_EmployeeID,SSL,Region,Sector_der 
	                from dbo.D_PRTEmployee 
	    	    	where rank = 'Partner/Principal'
	    			  and Active is null 
				 ) 
				 as e on e.PRT_EmployeeID = b.FK_Employee
	    Union All 
	   (
	    select ISNULL(b.Headcount,1) as Headcount,ISNULL(EstFTE,1) AS FTE, isnull(e.SSL,b.SSL), coalesce(b.Region,e.Region) as Region,isnull(Sector_der,'NA') AS Sector ,ISNULL(TransactionType,'Number before Promotions') as TransactionType, 
    		(select FiscalYear from get_Curr_FYear(getDate())) as FiscalYear, 6.5 as PRT_TransactionID
             From
    	       (select 'Number before Promotions' as TransactionType,Region,SSL, coalesce(a.headcount,t.headcount) headcount,EstFTE, FK_Employee, FiscalYear
    	 FROM
    		(select 1 as headcount, EstFTE, FK_TransactionType, FK_Employee,FiscalYear,NULL as Region,null as SSL from dbo.F_PRTDirectAdmit where FiscalYear <=(select FiscalYear from get_Curr_FYear(getDate())) and Active is Null
    		Union All
    		 select 1 as headcount, EstFTE, FK_TransactionType, FK_Employee,FiscalYear,Region,null as SSL from dbo.F_PRTTransferIn where FiscalYear <=(select FiscalYear from get_Curr_FYear(getDate())) and Active is Null
    		Union All  
    		 select 0 as headcount, EstFTE,FK_TransactionType, FK_Employee,FiscalYear,ToRegion as Region,null as SSL from dbo.F_PRTTransferOut where FiscalYear <=(select FiscalYear from get_Curr_FYear(getDate())) and Active is Null
    		Union All
    		 select 0 as headcount,EstFTE,FK_TransactionType, FK_Employee,FiscalYear,NULL as Region,null as SSL  from dbo.F_PRTRetirement where FiscalYear <=(select FiscalYear from get_Curr_FYear(getDate())) and Active is Null
    		Union All
    		 select 0 as headcount, EstFTE,FK_TransactionType, FK_Employee,FiscalYear,NULL as Region,null as SSL from dbo.F_PRTSeparation where FiscalYear <=(select FiscalYear from get_Curr_FYear(getDate())) and Active is Null
			 Union All
			 select NULL as headcount, EstFTE,FK_TransactionType, FK_Employee,FiscalYear,Region,SSL from [dbo].[D_PRTTBD] where FiscalYear <= (select FiscalYear from get_Curr_FYear(getDate())) and Active is Null
			 ---select (case when headcount=-1 then 0 else 1 end) as headcount, EstFTE,FK_TransactionType, FK_Employee,FiscalYear,Region,SSL from [dbo].[D_PRTTBD] where FiscalYear <= (select FiscalYear from get_Curr_FYear(getDate())) and Active is Null
			 ) AS a
    	inner join dbo.D_PRTTransactionType t on t.PRT_TransactionID = a.FK_TransactionType) as b
        full outer join (select SSL, Region, PRT_EmployeeID, Joining_Date,Sector_der
                      from dbo.D_PRTEmployee a 
					  where rank = 'Partner/Principal'
					  and Active is NULL
					  and not exists (select FK_employee 
					                    from dbo.F_PRTPromotion p 
									    where p.FK_employee=a.PRT_employeeID	
									    and FiscalYear = (select FiscalYear from get_Curr_FYear(getDate()))
									   ) 									  
			 	 ) as e on e.PRT_EmployeeID = b.FK_Employee
    )
   Union All
        select ISNULL(b.Headcount,1) as Headcount,ISNULL(EstFTE,1) AS FTE, isnull(e.SSL,b.SSL), isnull(b.Region,e.Region) as Region,isnull(Sector_der,'NA') AS Sector ,ISNULL(TransactionType,'Number after Promotions') as TransactionType, 
    		(select FiscalYear from get_Curr_FYear(getDate())) as FiscalYear, 7.5 as PRT_TransactionID
        From
    	(select 'Number after Promotions' as TransactionType,Region,SSL,coalesce(a.headcount,t.headcount) as headcount ,EstFTE, FK_Employee, FiscalYear
    	 FROM
    		(select 1 as headcount, EstFTE, FK_TransactionType, FK_Employee,FiscalYear,NULL as Region,null as SSL from dbo.F_PRTDirectAdmit where FiscalYear <=(select FiscalYear from get_Curr_FYear(getDate())) and Active is Null
    		Union All
			 select 1 as headcount, EstFTE, FK_TransactionType, FK_Employee,FiscalYear,NULL as Region,null as SSL from dbo.F_PRTPromotion where FiscalYear <=(select FiscalYear from get_Curr_FYear(getDate())) and Active is Null
			Union All
    		 select 1 as headcount, EstFTE, FK_TransactionType, FK_Employee,FiscalYear,Region,null as SSL from dbo.F_PRTTransferIn where FiscalYear <=(select FiscalYear from get_Curr_FYear(getDate())) and Active is Null
    		Union All
    		 select 0 as headcount, EstFTE,FK_TransactionType, FK_Employee,FiscalYear,NULL as Region,null as SSL from dbo.F_PRTTransferOut where FiscalYear <=(select FiscalYear from get_Curr_FYear(getDate())) and Active is Null
    		Union All
    		 select 0 as headcount,EstFTE,FK_TransactionType, FK_Employee,FiscalYear,NULL as Region,null as SSL  from dbo.F_PRTRetirement where FiscalYear <=(select FiscalYear from get_Curr_FYear(getDate())) and Active is Null
    		Union All
    		 select 0 as headcount, EstFTE,FK_TransactionType, FK_Employee,FiscalYear,NULL as Region,null as SSL from dbo.F_PRTSeparation where FiscalYear <=(select FiscalYear from get_Curr_FYear(getDate())) and Active is Null
			Union All
			 select Null as headcount,EstFTE,FK_TransactionType, FK_Employee,FiscalYear,Region,SSL from [dbo].[D_PRTTBD] where FiscalYear <= (select FiscalYear from get_Curr_FYear(getDate())) and Active is Null
			 ---select (case when headcount=-1 then 0 else 1 end) as headcount,EstFTE,FK_TransactionType, FK_Employee,FiscalYear,Region,SSL from [dbo].[D_PRTTBD] where FiscalYear = (select FiscalYear from get_Curr_FYear(getDate())) and Active is Null
			 ) AS a
    	inner join dbo.D_PRTTransactionType t on t.PRT_TransactionID = a.FK_TransactionType) as b
         full outer join (select SSL, Region, PRT_EmployeeID, Joining_Date,Sector_der
                            from dbo.D_PRTEmployee a
					       where rank = 'Partner/Principal'
					         and Active is NULL					         									  
			 	 ) as e on e.PRT_EmployeeID = b.FK_Employee
   Union All
	select ISNULL(b.Headcount,1) as Headcount,ISNULL(EstFTE,1) AS FTE, isnull(e.SSL,b.SSL) as SSL, isnull(b.Region,e.Region) as Region,isnull(Sector_der,'NA') AS Sector, ISNULL(TransactionType,'Early Accruals') as TransactionType, 
    		ISNULL(b.FiscalYear,2021) as FiscalYear, 9 as PRT_TransactionID
			from
	(select 'Early Accruals' as TransactionType,Region,SSL ,t.headcount,EstFTE, FK_Employee, FiscalYear
    	 FROM
    		(select EstFTE, FK_TransactionType, FK_Employee,FiscalYear,NULL as Region,null as SSL from dbo.F_PRTDirectAdmit where FiscalYear =(select FiscalYear+1 from get_Curr_FYear(getDate())) and datepart(Month,EstimatedDate) in(7,8,9)
    		Union All
    		 select EstFTE,FK_TransactionType, FK_Employee,FiscalYear,NULL as Region,null as SSL from dbo.F_PRTPromotion where FiscalYear =(select FiscalYear+1 from get_Curr_FYear(getDate())) and datepart(Month,EstimatedDate) in(7,8,9)
    		Union All
    		 select  EstFTE, FK_TransactionType, FK_Employee,FiscalYear,Region ,null as SSL from dbo.F_PRTTransferIn where FiscalYear =(select FiscalYear+1 from get_Curr_FYear(getDate())) and datepart(Month,EstimatedDate) in(7,8,9)
    		Union All
    		 select  EstFTE,FK_TransactionType, FK_Employee,FiscalYear,NULL as Region,null as SSL from dbo.F_PRTTransferOut where FiscalYear =(select FiscalYear+1 from get_Curr_FYear(getDate())) and datepart(Month,EstimatedDate) in(7,8,9)
    		Union All
    		 select EstFTE,FK_TransactionType, FK_Employee,FiscalYear,NULL as Region,null as SSL from dbo.F_PRTRetirement where FiscalYear =(select FiscalYear+1 from get_Curr_FYear(getDate())) and datepart(Month,EstimatedDate) in(7,8,9)
    		Union All
    		 select EstFTE,FK_TransactionType, FK_Employee,FiscalYear,NULL as Region,null as SSL from dbo.F_PRTSeparation where FiscalYear =(select FiscalYear+1 from get_Curr_FYear(getDate())) and datepart(Month,EstimatedDate) in(7,8,9)
			 Union All
			 select EstFTE,FK_TransactionType, FK_Employee,FiscalYear,Region,SSL from [dbo].[D_PRTTBD] where FiscalYear =(select FiscalYear+1 from get_Curr_FYear(getDate())) and datepart(Month,EstimatedDate) in(7,8,9)) AS a
    	inner join dbo.D_PRTTransactionType t on t.PRT_TransactionID = a.FK_TransactionType) as b
    left join (select PRT_EmployeeID,SSL,Region,Sector_der from dbo.D_PRTEmployee where rank = 'Partner/Principal')as e on e.PRT_EmployeeID = b.FK_Employee 
	Union All
	select ISNULL(b.Headcount,1) as Headcount,ISNULL(EstFTE,1) AS FTE,isnull(e.SSL,b.SSL) as SSL, isnull(b.Region,e.Region) as Region,isnull(Sector_der,'NA') AS Sector, ISNULL(TransactionType,'EoY (Including Early Accruals)') as TransactionType, 
    		(select FiscalYear from get_Curr_FYear(getDate())) as FiscalYear, 10 as PRT_TransactionID
			from
	(select  'EoY (Including Early Accruals)' as TransactionType, Region,SSL, coalesce(a.headcount,t.headcount) as headcount ,EstFTE, FK_Employee, FiscalYear
    	 FROM
    		(select 1 as headcount, EstFTE, FK_TransactionType, FK_Employee,FiscalYear,NULL as Region,null as SSL from dbo.F_PRTDirectAdmit where FiscalYear =(select FiscalYear from get_Curr_FYear(getDate())) and Active is Null
                                                                                                                                
    		Union All
    		 select 1 as headcount, EstFTE, FK_TransactionType, FK_Employee,FiscalYear,NULL as Region,null as SSL from dbo.F_PRTPromotion where FiscalYear =(select FiscalYear from get_Curr_FYear(getDate())) and Active is Null
                                                                                                                          
    		Union All
    		 select 1 as headcount, EstFTE, FK_TransactionType, FK_Employee,FiscalYear,Region,null as SSL from dbo.F_PRTTransferIn where FiscalYear =(select FiscalYear from get_Curr_FYear(getDate())) and Active is Null
                                                                                                                      
           	Union All

    		  select 0 as headcount, EstFTE,FK_TransactionType, FK_Employee,FiscalYear,NULL as Region,null as SSL from dbo.F_PRTTransferOut where FiscalYear =(select FiscalYear from get_Curr_FYear(getDate())) and Active is Null
                                                                                                                              
       		Union All
    		 select 0 as headcount,EstFTE,FK_TransactionType, FK_Employee,FiscalYear,NULL as Region,null as SSL  from dbo.F_PRTRetirement where FiscalYear =(select FiscalYear from get_Curr_FYear(getDate())) and Active is Null
                                                                                                                           
      		Union All
    		 select 0 as headcount, EstFTE,FK_TransactionType, FK_Employee,FiscalYear,NULL as Region,null as SSL from dbo.F_PRTSeparation where FiscalYear =(select FiscalYear from get_Curr_FYear(getDate())) and Active is Null
                                                                                                                            
        	 Union All
			 select null as headcount,EstFTE,FK_TransactionType, FK_Employee,FiscalYear,Region,SSL from [dbo].[D_PRTTBD] where FiscalYear  = (select FiscalYear from get_Curr_FYear(getDate())) and Active is Null
                                                                                                           
   																										   ) AS a
    	inner join dbo.D_PRTTransactionType t on t.PRT_TransactionID = a.FK_TransactionType) as b
        full outer join (select SSL, Region, PRT_EmployeeID, Joining_Date,Sector_der
                            from dbo.D_PRTEmployee a
					       where rank = 'Partner/Principal'
					         and Active is NULL					          									  
			 	 ) as e on e.PRT_EmployeeID = b.FK_Employee
      Union All
	   select ISNULL(b.Headcount,1) as Headcount,ISNULL(EstFTE,1) AS FTE, isnull(e.SSL,b.SSL) as SSL, isnull(b.Region,e.Region) as Region,isnull(Sector_der,'NA') AS Sector, ISNULL(TransactionType,'EoY (Including Early Accruals)') as TransactionType, 
    		  ISNULL(b.FiscalYear,2021) as FiscalYear, 10 as PRT_TransactionID
		from
	        (select 'EoY (Including Early Accruals)' as TransactionType,Region,SSL ,t.headcount,EstFTE, FK_Employee, FiscalYear
    	     FROM
    		    (select EstFTE, FK_TransactionType, FK_Employee,FiscalYear,NULL as Region,null as SSL from dbo.F_PRTDirectAdmit where ISNULL(FiscalYear, 1001)=(select FiscalYear+1 from get_Curr_FYear(getDate())) and datepart(Month,EstimatedDate) in(7,8,9)
    		    Union All
    		     select EstFTE,FK_TransactionType, FK_Employee,FiscalYear,NULL as Region,null as SSL from dbo.F_PRTPromotion where ISNULL(FiscalYear, 1001)=(select FiscalYear+1 from get_Curr_FYear(getDate())) and datepart(Month,EstimatedDate) in(7,8,9)
    		    Union All
    		     select  EstFTE, FK_TransactionType, FK_Employee,FiscalYear,Region ,null as SSL from dbo.F_PRTTransferIn where ISNULL(FiscalYear, 1001)=(select FiscalYear+1 from get_Curr_FYear(getDate())) and datepart(Month,EstimatedDate) in(7,8,9)
    		    Union All
    		     select  EstFTE,FK_TransactionType, FK_Employee,FiscalYear,NULL as Region,null as SSL from dbo.F_PRTTransferOut where ISNULL(FiscalYear, 1001)=(select FiscalYear+1 from get_Curr_FYear(getDate())) and datepart(Month,EstimatedDate) in(7,8,9)
    		    Union All
    		     select EstFTE,FK_TransactionType, FK_Employee,FiscalYear,NULL as Region,null as SSL from dbo.F_PRTRetirement where ISNULL(FiscalYear, 1001)=(select FiscalYear+1 from get_Curr_FYear(getDate())) and datepart(Month,EstimatedDate) in(7,8,9)
    		    Union All
    		     select EstFTE,FK_TransactionType, FK_Employee,FiscalYear,NULL as Region,null as SSL from dbo.F_PRTSeparation where ISNULL(FiscalYear, 1001)=(select FiscalYear+1 from get_Curr_FYear(getDate())) and datepart(Month,EstimatedDate) in(7,8,9)
			    Union All
			     select EstFTE,FK_TransactionType, FK_Employee,FiscalYear,Region,SSL from [dbo].[D_PRTTBD] where ISNULL(FiscalYear, 1001)=(select FiscalYear+1 from get_Curr_FYear(getDate())) and datepart(Month,EstimatedDate) in(7,8,9)) AS a
    	     inner join dbo.D_PRTTransactionType t on t.PRT_TransactionID = a.FK_TransactionType) as b
       left join (select PRT_EmployeeID,SSL,Region,Sector_der from dbo.D_PRTEmployee where rank = 'Partner/Principal')as e on e.PRT_EmployeeID = b.FK_Employee

    	 ), pv1 as
        (
         select PRT_TransactionID,TransactionType,SSL,Sector,FiscalYear,[East],[West],[Expats],[Central],[PPG],[FSO],[FAAS],[Forensics],[EYIS],[Nat'l Assurance Other/Leadership]
         from   tab1 
         PIVOT  (SUM(Headcount) FOR Region IN ([East],[West],[Expats],[Central],[PPG],[FSO],[FAAS],[Forensics],[EYIS],[Nat'l Assurance Other/Leadership])) AS p1
        ), pv2 as
       (
        select PRT_TransactionID,TransactionType,SSL,Sector,FiscalYear,[East],[West],[Expats],[Central],[PPG],[FSO],[FAAS],[Forensics],[EYIS],[Nat'l Assurance Other/Leadership]
        from   tab1 
        PIVOT  (SUM(FTE) FOR Region IN ([East],[West],[Expats],[Central],[PPG],[FSO],[FAAS],[Forensics],[EYIS],[Nat'l Assurance Other/Leadership])) AS p2
       )
        select a.PRT_TransactionID,a.TransactionType,a.SSL,a.Sector,a.FiscalYear,[Headcount East],[Headcount West],[Headcount Expats],[Headcount Central],[Headcount PPG],[Headcount FSO],[Headcount FAAS],[Headcount Forensics],[Headcount EYIS],[Headcount Nat'l Assurance Other/Leadership]
             ,[FTE East],[FTE West],[FTE Expats],[FTE Central],[FTE PPG],[FTE FSO],[FTE FAAS],[FTE Forensics], [FTE EYIS],[FTE Nat'l Assurance Other/Leadership]
        from 
       (select PRT_TransactionID
	          ,pv1.TransactionType
              ,isnull(pv1.SSL,'X') as SSL
			  ,Sector
    		   ,pv1.FiscalYear
              ,[Headcount East]     = sum(pv1.[East])
    		   ,[Headcount West]    = sum(pv1.[West])
    		   ,[Headcount Expats]  = sum(pv1.[Expats])
    		   ,[Headcount Central] = sum(pv1.[Central])
    		   ,[Headcount PPG]     = sum(pv1.[PPG])
    		   ,[Headcount FSO]     = sum(pv1.[FSO])
			   ,[Headcount FAAS]    = sum(pv1.[FAAS])
			   ,[Headcount Forensics] = sum(pv1.[Forensics])
			   ,[Headcount EYIS]    = sum(pv1.[EYIS])
			   ,[Headcount Nat'l Assurance Other/Leadership] = sum(pv1.[Nat'l Assurance Other/Leadership])
    	from pv1 
    	group by pv1.PRT_TransactionID,pv1.TransactionType
               ,pv1.SSL,Sector,FiscalYear
    	) a
    	,(select pv2.PRT_TransactionID,pv2.TransactionType,
             isnull(pv2.SSL,'X') as SSL,
			 Sector,
    		 pv2.FiscalYear,        
    		[FTE East]       = sum(pv2.[East]),
    		[FTE West]       = sum(pv2.[West]),
    		[FTE Expats]     = sum(pv2.[Expats]),
    		[FTE Central]    = sum(pv2.[Central]),
    		[FTE PPG]        = sum(pv2.[PPG]),
    		[FTE FSO]        = sum(pv2.[FSO]),
			[FTE FAAS]       = sum(pv2.[FAAS]),
			[FTE Forensics]  = sum(pv2.[Forensics]),
			[FTE EYIS]       = sum(pv2.[EYIS]),
			[FTE Nat'l Assurance Other/Leadership] = sum(pv2.[Nat'l Assurance Other/Leadership])
    	from pv2 
    	group by pv2.PRT_TransactionID,pv2.TransactionType
                ,pv2.SSL,Sector,FiscalYear) b
    	where a.PRT_TransactionID =b.PRT_TransactionID
		and a.TransactionType = b.TransactionType
    	and a.SSL = b.SSL
		and a.Sector = b.Sector
    	and a.FiscalYear = b.FiscalYear;


GO


