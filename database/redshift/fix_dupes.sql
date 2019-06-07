drop table if exists example.reservation_finance_item_dedupe;

create table example.reservation_finance_item_dedupe as (select distinct * from example.reservation_finance_item);

select count(*) from example.reservation_finance_item;
select count(*) from example.reservation_finance_item_dedupe;

drop table if exists example.reservation_finance_item_old;

set search_path=example;

alter table reservation_finance_item rename to reservation_finance_item_old;
alter table reservation_finance_item_dedupe rename to reservation_finance_item;

select count(*) from example.reservation_finance_item;
select count(*) from example.reservation_finance_item_old;

