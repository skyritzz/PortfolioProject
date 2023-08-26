drop table if exists goldusers_signup;
CREATE TABLE goldusers_signup(userid integer,gold_signup_date date); 

INSERT INTO goldusers_signup(userid,gold_signup_date) 
 VALUES (1,'09-22-2017'),
(3,'04-21-2017');

drop table if exists users;
CREATE TABLE users(userid integer,signup_date date); 

INSERT INTO users(userid,signup_date) 
 VALUES (1,'09-02-2014'),
(2,'01-15-2015'),
(3,'04-11-2014');

drop table if exists sales;
CREATE TABLE sales(userid integer,created_date date,product_id integer); 

INSERT INTO sales(userid,created_date,product_id) 
 VALUES (1,'04-19-2017',2),
(3,'12-18-2019',1),
(2,'07-20-2020',3),
(1,'10-23-2019',2),
(1,'03-19-2018',3),
(3,'12-20-2016',2),
(1,'11-09-2016',1),
(1,'05-20-2016',3),
(2,'09-24-2017',1),
(1,'03-11-2017',2),
(1,'03-11-2016',1),
(3,'11-10-2016',1),
(3,'12-07-2017',2),
(3,'12-15-2016',2),
(2,'11-08-2017',2),
(2,'09-10-2018',3);


drop table if exists product;
CREATE TABLE product(product_id integer,product_name text,price integer); 

INSERT INTO product(product_id,product_name,price) 
 VALUES
(1,'p1',980),
(2,'p2',870),
(3,'p3',330);


select * from sales;
select * from product;
select * from goldusers_signup;
select * from users;

--what is the total amount each cutomer spent on zomato?

select * from sales;
select * from product;
select s.userid, count(s.userid) as count_of_order , sum(p.price) as total_amt_spent from sales s join product p on s.product_id = p.product_id group by s.userid;


--How many days has each customer visited zomato?

select userid, count(distinct created_date) distinct_days from sales group by userid;


-- what was the first product purchased by the each of the customer?

select userid, min(distinct created_date) distinct_days from sales group by userid;

--what is the most purachsed item on the menu and how many times it was purchased?

select  product_id, COUNT(product_id) as count_prdct_prschd from sales group by product_id order by COUNT(product_id) desc; 
-- product_id = 2 that is bought maximum number of times -- now we have to find which user bought how many times that product

select  userid, count(product_id) from sales where product_id = (
select top 1 product_id from sales group by product_id order by COUNT(product_id) desc) group by userid order by 1;

-- which item was the most popular for each customer

select * from (
select * , rank() over(partition by userid order by cnt desc) rnk from (
select userid,product_id,count( product_id) as cnt 
from sales group by userid, product_id)a)b where rnk = 1;



---which item was purchased first by the customer after they became a member

select * from sales;
select * from product;
select * from goldusers_signup;
select * from users;

select  userid, min(created_date) as first_order_goldmem from (
select s.userid, s.created_date from sales s join goldusers_signup g 
on s.userid = g.userid where s.created_date >= g.gold_signup_date 
group by s.userid, s.created_date)c group by userid;

--which item was purchased just before the customer became a member?

select  userid, max(created_date) as just_before_order_gold from (
select s.userid, s.created_date from sales s join goldusers_signup g 
on s.userid = g.userid where s.created_date <= g.gold_signup_date 
group by s.userid, s.created_date )c 
group by userid;

-- what is the total orders and amount spent for each member before they became a member?

select userid , count(created_date) as order_purchased,
sum(price) as total_amt_spent from 
(select c.* , p.price from 
(select s.userid, s.created_date, s.product_id, g.gold_signup_date
from sales s inner join goldusers_signup g on 
s.userid = g.userid and 
s.created_date <= g.gold_signup_date)c inner join product p 
on c.product_id = p.product_id)d group by userid;

-----If buying each product generates points for eg 5rs-2 zomato point and each product has different purchasing points
--for eg for p1 5rs=1 zomato point, for p2 10rs= 5 zomato point and p3 5rs=1 zomato point
--,calculate points collected by each customers and for which product most points have been given till now.


select userid, sum(f.total_points)*2.5 total_money_earned from 
(select e.* , e.amt/e.points as total_points from 
(select d.* , case when product_id = 1 then 5 when product_id = 2 then 2 when product_id = 3 then 5 else 0  end as points from 
(select c.userid, c.product_id, sum(price) as amt from 
(select s.*,  p.price  from sales s inner join product p 
on s.product_id = p.product_id) c group by userid, product_id)d)e)f group by userid
;

select * from 
(select * , rank() over (order by g.total_points_earned desc ) rnk from 
(select product_id, sum(f.total_points) as total_points_earned from 
(select e.* , e.amt/e.points as total_points from 
(select d.* , case when product_id = 1 then 5 when product_id = 2 then 2 when product_id = 3 then 5 else 0  end as points from 
(select c.userid, c.product_id, sum(price) as amt from 
(select s.*,  p.price  from sales s inner join product p 
on s.product_id = p.product_id) c group by userid, product_id)d)e)f 
group by product_id)g)h where rnk = 1
;

-----------------In the first one year after a customer joins the 
--gold program (including their join date) irrespective of what the customer has 
--purchased they earn 5 zomato points for every 10 rs spent who earned more 1 or 3 and 
--what was their points earnings in thier first yr?


select c.* , p.price*0.5 as total_points_earned from  
(select s.userid, s.created_date, s.product_id, g.gold_signup_date from sales s join goldusers_signup g 
on s.userid = g.userid where s.created_date >= g.gold_signup_date 
and created_date <= DATEADD( YEAR, 1 , gold_signup_date))c
inner join product p on c.product_id = p.product_id;
;


-- rank all the transaction of the customers

select *, rank() over(partition by userid order by created_date) rnk from sales;

-- rank all the transaction for each member whenever they are a 
--zomato gold member for every  non gold member transaction mark as na


select d.* , case when rnk = 0 then 'na' else rnk end as rnkk from 
(select c.* , cast((case when gold_signup_date is null then 0 else
rank() over (partition by userid order by created_date desc) end) as varchar) as rnk from 
(select s.userid, s.created_date, s.product_id, g.gold_signup_date 
from sales s left join goldusers_signup g 
on s.userid = g.userid and s.created_date >= g.gold_signup_date )c)d

