libname project1 "your Path";
proc import datafile="path where csv file is located"
			out=project2.auto
			dbms=csv;
run;
proc print data=project2.auto;
run;

/*2.	Which is the most commonly used mode of contact? */
proc sql;
select sum(ContactByEmail) as contact_by_mail,sum(ContactByTelephone) as contact_by_phone
from project2.auto;
quit;

/*3.	Within what period of time most leads would prefer to buy the car?*/
proc sql;
select sum(within24) as Within_24_hours,sum(within48) as Within_48_hours,
sum(within72) as Within_72_hours,sum(withinweek) as Within_week,sum(withinweeks) as Within_weeks,
sum(withinmonth) as Within_month
from project2.auto;
quit;

/*4.	Who is the best and worst lead provider?*/
proc sql;
create table leadprovider as
select leadprovider_id,count(LeadProvider_Id) as countOfLeads
from  project2.auto
group by leadprovider_id
order by countofleads desc;
quit;

data best_lead_provider worst_lead_provider;
set  leadprovider end=eof;
if _n_=1 then output  best_lead_provider;
if eof then output 	worst_lead_provider;
run;

/*5.	Do most of the customers prefer to buy new car?*/
proc sql;
select status,count(status) as status_count
from project2.auto
group by status
order by status_count desc;
quit;
/*---------------------*/

proc sort data= project2.auto out=sorted_1;
by status;
run;

data preferred_car;
set sorted_1(keep=Request_Hour Request_Weekday Request_MonthDay Status);
by status;
if first.status=1 then total_request=0;
total_request+sum(of Request_:);
if last.status;
run;

proc print data= preferred_car;
var  status total_request;
run;



/*-----------------------------*/
proc sort data=project2.auto out=sorted_data;
by status;
run;

data new_auto;
set sorted_data;
by status;
if first.status=1 then count=0;
count+1;
if last.status;
run;
proc print data=new_auto;
var status count ;
run;
/*----------------------------------*/

/*6.----------	Give the list of states with their car model name which is in more demand or sold there?*/
proc tabulate data=project2.auto;
class state model;
tables model,state;
run;

/*---------------------------*/
proc sort data=project2.auto(keep=State Model) out=car_demand;
by 	State Model;
run;
proc print data= car_demand;
run;
data car_demand_statewise;
set  car_demand;
by 	State Model;
if first.model=1 then count=0;
count+1;
if last.model=1;
run;
proc print data= car_demand_statewise;
run;

proc sql;
select state,model,max(count) as max_model_sold
from car_demand_statewise
group by state
having count=max(count);
quit;

/*-----------------------------------*/

proc means data=project2.auto nway noprint;
var Request_Hour Request_Weekday Request_MonthDay;
class state model;
output out=	auto sum=sum_request;
run;
proc print data=auto;
run;

proc sort data=auto out=more_demand;
by descending sum_request;
run;
proc print data=more_demand;
var  state model sum_request;
run;


/*------------------------*/
/*7.	Which is the best trade in year for the manufacturer Toyota?*/

proc sort data=	project2.auto(keep=Manufacturer TradeInModelYear) out=sorted;
by 	TradeInModelYear;
where  Manufacturer="Toyota";
run;
data best_trade_year;
set sorted;
by 	TradeInModelYear;
if first.TradeInModelYear=1 then count=0;
count+1;
if last.TradeInModelYear;
run;
proc sort data=	best_trade_year out=sorted1;
by descending count ;
run;
proc print data= sorted1;
run;

/*8.	Create a new variable by combining the manufacturer name and model.*/

data manuf_model;
set  project2.auto(keep=Manufacturer Model);
combined=catx("-",Manufacturer,Model);
run;
proc print data=manuf_model;
run;

/*9.	Create a new variable and the values conditionally.
 If distance to dealer<10 -very near
 >=10 and <50                    -near
 >=50 and <100                  -far
 >=100                                 -very far
*/

data dist_dealer;
set project2.auto(keep=DistanceToDealer);
if DistanceToDealer<10 then distance_abstract="very near";
else if 10<=DistanceToDealer<50 then distance_abstract="near";
else if 50<=DistanceToDealer<100 then distance_abstract="far";
else distance_abstract="very far";
run;
proc print data=dist_dealer;
run;

/*10.  Which is the distance within which most customers lie?*/

proc sort data=	dist_dealer out=sorted_distance;
by 	distance_abstract;
run;

data freq_distance;
set sorted_distance(keep=distance_abstract);
by 	distance_abstract;
if first.distance_abstract=1 then count=0;
count+1;
if last.distance_abstract;
run;
proc sort data=freq_distance out=sorted_freq_distance;
by descending count;
run;
proc print data= sorted_freq_distance;
footnote "distance to dealer <10 -very near, >=10 and <50 -near,>=50 and <100  -far, >=100  -very far";
run;
footnote;
