;with dataset as (select DATENUM,DATE_DT,rn from (select convert(char,convert(datetime, '04-JUL-2020')+ ROW_NUMBER() OVER (ORDER BY object_id)-1,112) as DATENUM,
                        convert(datetime, '04-JUL-2020') + ROW_NUMBER() OVER (ORDER BY object_id)-1 as DATE_DT,
						ROW_NUMBER() OVER (ORDER BY object_id) as rn
                  from sys.all_columns)	as a
				  where  rn <= datediff(day,convert(datetime,'04-JUL-2020'),convert(datetime,'02-JUL-2021'))+1
				 )
insert into OPS_DW.D_CALENDAR
select DATENUM
      ,CASE WHEN MONTH(DATE_DT)>=7 THEN convert(varchar,YEAR(DATE_DT)+1) 
           ELSE convert(varchar,YEAR(DATE_DT)) END
       +ISNULL( RIGHT( '00' + convert(varchar,floor((datediff(
	                           day,(SELECT DATE_DT
	                                        FROM DATASET 
											WHERE MONTH(DATE_DT) = 7 
	                                        AND  DATENAME(weekday,DATE_DT)='Saturday' 
											AND DatePart(week, day(DATE_DT)) =2
											),DATE_DT
                               )+7)/7)+1),2),''
				)  REPORTING_PERIOD
            
       ,CASE WHEN +ISNULL( RIGHT( '00' + convert(varchar,floor((datediff(
	                           day,(SELECT DATE_DT
	                                FROM DATASET 
									WHERE MONTH(DATE_DT) = 7 
	                                AND  DATENAME(weekday,DATE_DT)='Saturday' 
									AND DatePart(week, day(DATE_DT)) = 2
									),DATE_DT
                               )+7)/7)),2),''
				)  = 0 then convert(varchar,YEAR(DATE_DT))+'52'
             ELSE 
        CASE WHEN MONTH(DATE_DT)>=7 THEN convert(varchar,YEAR(DATE_DT)+1 )
           ELSE convert(varchar,YEAR(DATE_DT)) END  + +ISNULL( RIGHT( '00' + convert(varchar,floor((datediff(
	                           day,(SELECT DATE_DT
	                                        FROM DATASET 
											WHERE MONTH(DATE_DT) = 7 
	                                        AND  DATENAME(weekday,DATE_DT)='Saturday' 
											AND DatePart(week, day(DATE_DT)) =2
											),DATE_DT
                               )+7)/7)),2),''
				) END	   
	      PREV_REPORTING_PERIOD
     ,YEAR(DATE_DT) AS CAL_YEAR
	 ,CASE WHEN MONTH(DATE_DT)>= 7 THEN YEAR(DATE_DT)+1
	       ELSE YEAR(DATE_DT) END F_YEAR 
     ,'FY'+ SUBSTRING(CONVERT(varchar(10),CASE WHEN MONTH(DATE_DT)>= 7 THEN YEAR(DATE_DT)+1
	       ELSE YEAR(DATE_DT) END),3,3) F_CHAR_YEAR
     ,MONTH(DATE_DT) AS CAL_MONTH_NUM
	 ,CASE WHEN MONTH(DATE_DT) >= 7 THEN MONTH(DATE_DT)-6 ELSE
	      MONTH(DATE_DT)+6  END F_MONTH_NUM
     ,CONVERT(varchar(4),DATE_DT,100)  AS CAL_MONTH_NAME
	 ,null
	 ,null
	 ,datepart(week, DATE_DT) as CAL_WEEK_NUM
	 ,floor(floor((datediff(
	                           day,(SELECT DATE_DT
	                                FROM DATASET 
									WHERE MONTH(DATE_DT) = 7 
	                                AND  DATENAME(weekday,DATE_DT)='Saturday' 
									AND DatePart(week, day(DATE_DT)) =2
									),DATE_DT
                               )+7)/7))+1  AS F_WEEK_NUM
     ,CASE WHEN DATENAME(weekday,DATE_DT) <> 'Friday' THEN 
	   case 	when datename(dw,dateadd(day,1,DATE_DT))='Friday' then dateadd(day,1,DATE_DT)
		when datename(dw,dateadd(day,2,DATE_DT))='Friday' then dateadd(day,2,DATE_DT)
		when datename(dw,dateadd(day,3,DATE_DT))='Friday' then dateadd(day,3,DATE_DT)
		when datename(dw,dateadd(day,4,DATE_DT))='Friday' then dateadd(day,4,DATE_DT)
		when datename(dw,dateadd(day,5,DATE_DT))='Friday' then dateadd(day,5,DATE_DT)
		when datename(dw,dateadd(day,6,DATE_DT))='Friday' then dateadd(day,6,DATE_DT)
		when datename(dw,dateadd(day,7,DATE_DT))='Friday' then dateadd(day,7,DATE_DT)
end ELSE convert(char,DATE_DT,112)  END PERIOD_END_DT
, case 	when datename(dw,dateadd(day,1,DATE_DT))='Saturday' then dateadd(day,1,DATE_DT)
		when datename(dw,dateadd(day,2,DATE_DT))='Saturday' then dateadd(day,2,DATE_DT)
		when datename(dw,dateadd(day,3,DATE_DT))='Saturday' then dateadd(day,3,DATE_DT)
		when datename(dw,dateadd(day,4,DATE_DT))='Saturday' then dateadd(day,4,DATE_DT)
		when datename(dw,dateadd(day,5,DATE_DT))='Saturday' then dateadd(day,5,DATE_DT)
		when datename(dw,dateadd(day,6,DATE_DT))='Saturday' then dateadd(day,6,DATE_DT)
		when datename(dw,dateadd(day,7,DATE_DT))='Saturday' then dateadd(day,7,DATE_DT)
end    FORWARD_DT
,DATEPART(day,DATE_DT) AS DAY_OF_MONTH 
,convert(int,DATEPART(dayofyear, DATE_DT)) AS CAL_DAY_OF_YEAR
,DATENAME(weekday,DATE_DT) as DAY_NAME
,CASE WHEN DATENAME(weekday,DATE_DT) IN ('Saturday','Sunday') THEN 'N' ELSE 'Y' END AS WEEK_DAY_IND
,'Q'+DATENAME(qq, DATE_DT) AS CAL_QTR_NAME
,convert(int,DATENAME(qq, DATE_DT)) AS CAL_QTR_NUM
,DATEADD(mm, DATEDIFF(mm, 0, DATE_DT), 0) START_OF_MONTH
,DATEADD (dd, -1, DATEADD(mm, DATEDIFF(mm, 0, DATE_DT) + 1, 0))  END_OF_MONTH
,CASE WHEN DATENAME(weekday,DATE_DT) <> 'Friday' THEN 
	   case when datename(dw,dateadd(day,1,DATE_DT))='Friday' then dateadd(day,1,DATE_DT)
		when datename(dw,dateadd(day,2,DATE_DT))='Friday' then dateadd(day,2,DATE_DT)
		when datename(dw,dateadd(day,3,DATE_DT))='Friday' then dateadd(day,3,DATE_DT)
		when datename(dw,dateadd(day,4,DATE_DT))='Friday' then dateadd(day,4,DATE_DT)
		when datename(dw,dateadd(day,5,DATE_DT))='Friday' then dateadd(day,5,DATE_DT)
		when datename(dw,dateadd(day,6,DATE_DT))='Friday' then dateadd(day,6,DATE_DT)
		when datename(dw,dateadd(day,7,DATE_DT))='Friday' then dateadd(day,7,DATE_DT)
end 
ELSE DATE_DT END PERIOD_END_DATE
,convert(date,DATE_DT) as CAL_DATE
,CONVERT(varchar(4),DATE_DT,100) AS STD_CAL_MONTH
from dataset