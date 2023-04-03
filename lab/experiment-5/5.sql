
-- Display order info with salesman name which has given on date before 10  of any month

select orders.*, salesmen.sname from orders join salesmen  on salesmen.sid = orders.sid where extract(day from odate)<10


--     Display minimum order amount of each sales man
select sid, min(o_amt) from orders group by sid;


-- Display total order amount for each salesman.

select sid, sum(o_amt) from orders group by sid;


-- Find the customer city of customer which order amount is minimum.

select city, min(o_amt) from customers join orders o on customers.cid = o.cid group by city;