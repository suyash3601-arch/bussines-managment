-- Run once in Supabase SQL Editor if the original single-item version is already installed.
alter table public.sales drop constraint if exists sales_metal_check;
alter table public.sales add constraint sales_metal_check check (metal in ('Gold','Silver','Mixed'));
alter table public.sales add column if not exists items jsonb not null default '[]'::jsonb;
