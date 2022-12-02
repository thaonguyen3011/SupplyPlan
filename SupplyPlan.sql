-- Tính tổng tích luỹ supply quantity theo thời gian

With 
-- Tính tổng tích luỹ supply quantity theo thời gian
Supply as (select Part_No , Supply_week, Supply_quantity,
[Stock on hand] + Sum(Supply_quantity) over( partition by Part_No order by Supply_week
rows between unbounded preceding and current row) as Cum_supply 
from dbo.Supply),
-- Tính tổng tích luỹ demand quantity theo thời gian
Demand as (select Part_No, [Job No], [Job Qty], [Job start date],
Sum([Job Qty]) over( partition by Part_no order by [Job start date]
rows between unbounded preceding and current row) as Cum_demand 
from dbo.Demand),
-- Tìm ra các thời điểm và số lượng hàng có thể đáp ứng được nhu cầu 
Enough_Supply as (select D.Part_No as Part_No, [Job Qty],  [Job start date], Cum_demand, Supply_quantity, Supply_week, Cum_supply,
ROW_NUMBER() over( partition by D.Part_no, [Job Qty]  order by Cum_supply) as num
from Demand as D  
left join Supply as S
on S.Part_No = D.Part_No
where Cum_supply >= Cum_demand),
-- Tìm ra supply week đầu tiên đáp ứng được  demand quantity
First_Supply as
(select Part_No, [Job Qty],  convert(date,[Job start date],101) as [Job start date] ,
Cum_demand, Supply_quantity,  convert(date,Supply_week ,101) as Supply_week , Cum_supply
from Enough_Supply
where num = 1)
-- Tính số ngày nguy cơ bị thiếu hàng 
select D.Part_No,D.[Job Qty],convert(date,D.[Job start date],101) as [Job start date], Supply_week, Supply_quantity,
Datediff(day,convert(date,D.[Job start date],101),Supply_week) as [Number_days_lack_goods]
from First_Supply as FS
right join Demand as D
on D.Part_No = FS.Part_No and D.[Job Qty] = FS.[Job Qty]
order by Part_No, [Job start date],  Supply_week



