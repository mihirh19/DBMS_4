-- Write a trigger for overdraft facility.


CREATE TABLE accounts (
                          account_number INTEGER PRIMARY KEY,
                          balance NUMERIC(10, 2)
);


CREATE FUNCTION update_balance()
    RETURNS TRIGGER AS $$
DECLARE
    overdraft_amount NUMERIC(10, 2) := 500.00; -- maximum allowed overdraft amount
BEGIN
    -- check if the new balance is less than 0
    IF NEW.balance < 0 THEN
        -- calculate the amount by which the account is overdrawn
        -- and check if it exceeds the maximum allowed overdraft amount
        IF (NEW.balance * -1) > overdraft_amount THEN
            -- if the overdraft amount is exceeded, rollback the transaction
            RAISE EXCEPTION 'Overdraft facility limit exceeded!';
        END IF;
    END IF;

    -- if the balance is not negative or the overdraft amount is not exceeded, update the balance
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER overdraft_trigger
    BEFORE UPDATE OF balance ON accounts
    FOR EACH ROW
EXECUTE FUNCTION update_balance();

insert into accounts (account_number, balance) VALUES (1,500);
update accounts set balance = -600 where account_number=1;

select *
from accounts;



-- Write a cursor for calculating income tax for the given employee table.
-- Emp (eid, ename, salary, incometax)


CREATE TABLE emp (
                     eid INTEGER PRIMARY KEY,
                     ename VARCHAR(50),
                     salary NUMERIC(10, 2),
                     incometax NUMERIC(10, 2)
);
drop table if exists emp;


create or replace function calculate_income_tax() returns void as
    $$
    DECLARE
        emp_id INTEGER;
        emp_name VARCHAR(50);
        emp_salary numeric(10,2);
        emp_incometax numeric(10,2);

        cur_emp cursor for select eid,ename, salary from emp;

    BEGIN
        open cur_emp;

        fetch cur_emp into emp_id,emp_name, emp_salary;

        while FOUND loop
                emp_incometax := emp_salary *0.2;

            update emp set incometax = emp_incometax where eid = emp_id;

            fetch cur_emp into emp_id,emp_name,emp_salary;
            end loop;
        close cur_emp;
end
$$ language plpgsql;


insert into emp (eid,ename, salary) values(1,'mihir',5000), (2, 'mihir2', 70000);
select * from emp;
delete from emp;
select calculate_income_tax()
