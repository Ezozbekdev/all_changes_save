
CREATE DATABASE task_db
    WITH
    OWNER = git_project
    ENCODING = 'UTF8'
    CONNECTION LIMIT = -1;


CREATE TABLE public.cars
(
    title character varying(50) NOT NULL,
    year integer NOT NULL,
    brand character varying(50) NOT NULL,
    price bigint NOT NULL
)

TABLESPACE ts_task_pdp;

ALTER TABLE IF EXISTS public.cars
    OWNER to git_project;

CREATE TABLE public.planning_car
(
    id integer NOT NULL,
    title varchar(50) NOT NULL,
    brand varchar(50) NOT NULL,
    planning_date(50) NOT NULL,
    price integer NOT NULL

)

TABLESPACE ts_task_pdp;

ALTER TABLE IF EXISTS public.planning_car
    OWNER to git_project;

CREATE TABLE public.sell_car
(
    car_title varchar(50) NOT NULL,
    sell_price varchar(50) NOT NULL

)

TABLESPACE ts_task_pdp;

ALTER TABLE IF EXISTS public.sell_car
    OWNER to git_project;

CREATE TABLE public.all_changes_db
(
    tb_name varchar(50) NOT NULL,
    operation varchar(50) NOT NULL,
    oper_time time without time zone NOT NULL,
    change_data text NOT NULL

)

TABLESPACE ts_task_pdp;

ALTER TABLE IF EXISTS public.all_changes_db
    OWNER to git_project;


CREATE FUNCTION public.tgf_all_changes()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
begin 
    if TG_OP='INSERT' or TG_OP='UPDATE' then
        insert into all_changes_db(tb_name, operation,oper_time, change_data)
        values('cars', TG_OP,now(),new);
        insert into all_changes_db(tb_name, operation,oper_time, change_data)
        values('planning_car', TG_OP,now(),new);
        insert into all_changes_db(tb_name, operation,oper_time, change_data)
        values('sell_car', TG_OP,now(),new);
        return new;
    else
        insert into all_changes_db(tb_name, operation,oper_time, change_data)
        values('cars', TG_OP,now(),old());
        return old;
        insert into all_changes_db(tb_name, operation,oper_time, change_data)
        values('planning_car', TG_OP,now(),old());
        return old;
        insert into all_changes_db(tb_name, operation,oper_time, change_data)
        values('sell_car', TG_OP,now(),old());
        return old;
    end if;
end;
$BODY$;

ALTER FUNCTION public.tgf_all_changes()
    OWNER TO git_project;


CREATE TRIGGER tgf_sell_car_all
    AFTER INSERT OR DELETE OR UPDATE 
    ON public.sell_car
    FOR EACH ROW
    EXECUTE FUNCTION public.tgf_all_changes();


CREATE TRIGGER tgf_planning_car
    AFTER INSERT OR DELETE OR UPDATE 
    ON public.planning_car
    FOR EACH ROW
    EXECUTE FUNCTION public.tgf_all_changes();


CREATE TRIGGER cars
    AFTER INSERT OR DELETE OR UPDATE 
    ON public.cars
    FOR EACH ROW
    EXECUTE FUNCTION public.tgf_all_changes();

