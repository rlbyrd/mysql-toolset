drop table if exists vacasa.reservation_finance_item_dedupe;

create table vacasa.reservation_finance_item_dedupe as (select distinct * from vacasa.reservation_finance_item);

select count(*) from vacasa.reservation_finance_item;
select count(*) from vacasa.reservation_finance_item_dedupe;

drop table if exists vacasa.reservation_finance_item_old;

set search_path=vacasa;

alter table reservation_finance_item rename to reservation_finance_item_old;
alter table reservation_finance_item_dedupe rename to reservation_finance_item;

select count(*) from vacasa.reservation_finance_item;
select count(*) from vacasa.reservation_finance_item_old;

