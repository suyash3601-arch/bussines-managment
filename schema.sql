-- Shani Jewellers database schema for Supabase
-- Run this entire file in Supabase Dashboard > SQL Editor > New query.
create extension if not exists pgcrypto;

create table if not exists public.inventory (
 id uuid primary key default gen_random_uuid(),
 user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
 name text not null,
 item_code text,
 metal text not null check (metal in ('Gold','Silver')),
 purity text not null default '',
 quantity integer not null default 1 check (quantity >= 0),
 gross_weight numeric(12,3) not null check (gross_weight >= 0),
 net_weight numeric(12,3) not null check (net_weight >= 0),
 purchase_wastage numeric(8,3) not null default 0,
 default_selling_wastage numeric(8,3) not null default 0,
 purchase_date date not null default current_date,
 supplier text,
 purchase_rate numeric(12,2) not null default 0,
 created_at timestamptz not null default now()
);
create table if not exists public.purchases (
 id uuid primary key default gen_random_uuid(),
 user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
 item_name text not null,
 metal text not null check (metal in ('Gold','Silver')),
 quantity integer not null,
 net_weight numeric(12,3) not null,
 purchase_wastage numeric(8,3) not null default 0,
 purchase_date date not null default current_date,
 supplier text,
 created_at timestamptz not null default now()
);
create table if not exists public.sales (
 id uuid primary key default gen_random_uuid(),
 user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
 bill_no text not null,
 customer_name text not null,
 phone text,
 bill_date date not null default current_date,
 item_summary text,
 metal text not null check (metal in ('Gold','Silver','Mixed')),
 purity text,
 quantity integer not null,
 net_weight numeric(12,3) not null,
 selling_wastage numeric(8,3) not null default 0,
 wastage_weight numeric(12,3) not null default 0,
 billable_weight numeric(12,3) not null,
 rate numeric(12,2) not null,
 metal_value numeric(14,2) not null,
 making_charges numeric(14,2) not null default 0,
 discount numeric(14,2) not null default 0,
 gst_percent numeric(8,3) not null default 0,
 gst_amount numeric(14,2) not null default 0,
 total numeric(14,2) not null,
 items jsonb not null default '[]'::jsonb,
 created_at timestamptz not null default now(),
 unique(user_id,bill_no)
);

alter table public.inventory enable row level security;
alter table public.purchases enable row level security;
alter table public.sales enable row level security;

drop policy if exists "Users manage own inventory" on public.inventory;
create policy "Users manage own inventory" on public.inventory for all to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);
drop policy if exists "Users manage own purchases" on public.purchases;
create policy "Users manage own purchases" on public.purchases for all to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);
drop policy if exists "Users manage own sales" on public.sales;
create policy "Users manage own sales" on public.sales for all to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);

grant usage on schema public to authenticated;
grant select,insert,update,delete on public.inventory, public.purchases, public.sales to authenticated;
