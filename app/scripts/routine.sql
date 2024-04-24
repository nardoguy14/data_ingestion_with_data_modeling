create or replace function my_to_timestamp(arg text) returns timestamp without time zone
language plpgsql
as $$
begin
begin
return arg::timestamp;
exception when others then
        return null;
end;
end $$;

