
-- Create a view which shows the detail of salesman with his salary. (Salesmanname,salary)

create view salesman_detail as select sname, salary from salesmen;

select * from salesman_detail;

--                   Write a program to find factorial from the given number.
--     Hint: Take the number in one procedure and pass it to the function which is calculating
--     the factorial of a given number and returns the factorial to the calling procedure.


create procedure factorial(in number integer, out result integer) as
    $$
    BEGIN
    select fact(number) into result ;
    return ;
end;
$$ LANGUAGE plpgsql;


drop procedure factorial;

create function fact(number int) returns integer as
    $$
    declare
        result integer := 1;
        i integer;

    begin
        for i in 1..number loop
            result := result * i;
            end loop;

        return result;

end;
$$ language plpgsql;


call factorial(5,0);
