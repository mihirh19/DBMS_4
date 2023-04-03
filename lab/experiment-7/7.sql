
-- Display customer name which order amount  is highest.

select cname from customers where cid in (select cid from orders where o_amt = (select  max(o_amt) from orders));

--     Display customer name whose salesman staying in Ahmedabad.

select cname from customers where cid in (select cid from orders where sid in (select sid from salesmen where  city like 'BARODA'));



-- Display order info for which order taken earliest.


select * from orders order by odate limit 1;

