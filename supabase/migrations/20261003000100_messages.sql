-- Published messages are public; only trusted server-side administration can
-- change them. Do not put a service-role credential in the Flutter client.
create table if not exists public.messages (
  id text primary key,
  slug text not null unique,
  text text not null,
  reference text not null,
  translation text not null default 'BLIVRE',
  category text not null,
  background_url text,
  featured boolean not null default false,
  published boolean not null default false,
  display_order integer not null default 0,
  search_text text generated always as (lower(text || ' ' || reference)) stored,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint messages_slug_format check (slug ~ '^[a-z0-9]+(-[a-z0-9]+)*$'),
  constraint messages_id_matches_slug check (id = slug),
  constraint messages_text_not_blank check (length(btrim(text)) > 0)
);

create index if not exists messages_published_order_idx on public.messages (display_order, id) where published;
create index if not exists messages_category_order_idx on public.messages (category, display_order) where published;

create or replace function public.touch_message_updated_at()
returns trigger language plpgsql set search_path = '' as $$
begin
  new.updated_at = now();
  return new;
end;
$$;
create trigger messages_touch_updated_at before update on public.messages
  for each row execute function public.touch_message_updated_at();

alter table public.messages enable row level security;
revoke all on public.messages from anon, authenticated;
grant select on public.messages to anon, authenticated;

create policy "Read published messages" on public.messages
  for select to anon, authenticated using (published = true);

create table if not exists public.message_favorites (
  user_id uuid not null references auth.users(id) on delete cascade,
  message_id text not null references public.messages(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (user_id, message_id)
);

create index if not exists message_favorites_user_idx on public.message_favorites (user_id, created_at desc);

alter table public.message_favorites enable row level security;
revoke all on public.message_favorites from anon, authenticated;
grant select, insert, delete on public.message_favorites to authenticated;

create policy "Read own message favorites" on public.message_favorites
  for select to authenticated using (auth.uid() = user_id);
create policy "Add own message favorites" on public.message_favorites
  for insert to authenticated with check (auth.uid() = user_id);
create policy "Remove own message favorites" on public.message_favorites
  for delete to authenticated using (auth.uid() = user_id);

-- These 12 entries are the same licensed BLIVRE pilot verses shipped offline.
insert into public.messages
  (id, slug, text, reference, category, featured, published, display_order)
values
  ('confiar-de-todo-coracao', 'confiar-de-todo-coracao', 'Confia no SENHOR com todo o teu coração, e não te apoies no teu próprio entendimento.', 'Provérbios 3:5', 'Fé', true, true, 1),
  ('caminhos-endireitados', 'caminhos-endireitados', 'Reconhece-o em todos os teus caminhos, e ele endireitará as tuas veredas.', 'Provérbios 3:6', 'Promessas', false, true, 2),
  ('o-senhor-me-sustenta', 'o-senhor-me-sustenta', 'Eu me deito e durmo; acordo, porque o SENHOR me sustenta.', 'Salmos 3:5', 'Força', true, true, 3),
  ('escudo-e-gloria', 'escudo-e-gloria', 'Porém tu, SENHOR, és escudo para mim; minha glória, e o que levanta minha cabeça.', 'Salmos 3:3', 'Esperança', false, true, 4),
  ('clamo-e-ele-responde', 'clamo-e-ele-responde', 'Com minha voz clamo ao SENHOR; e ele me responde desde seu santo monte. (Selá)', 'Salmos 3:4', 'Oração', false, true, 5),
  ('medita-de-dia-e-noite', 'medita-de-dia-e-noite', 'antes, tem seu prazer na Lei do SENHOR; e em sua Lei medita de dia e de noite.', 'Salmos 1:2', 'Salmos', false, true, 6),
  ('arvore-junto-as-aguas', 'arvore-junto-as-aguas', 'Porque será como a árvore, plantada junto a ribeiros de águas, que dá fruto a seu tempo, e suas folhas não caem; e tudo quanto fizer prosperará.', 'Salmos 1:3', 'Motivação', false, true, 7),
  ('bondade-e-fidelidade', 'bondade-e-fidelidade', 'Que a bondade e a fidelidade não te desamparem; amarra-as junto ao teu pescoço; escreve-as na tábua de teu coração.', 'Provérbios 3:3', 'Amor', false, true, 8),
  ('alegria-no-coracao', 'alegria-no-coracao', 'Deste-me alegria em meu coração, mais que quando o trigo e o vinho deles se multiplicaram.', 'Salmos 4:7', 'Gratidão', false, true, 9),
  ('instrucao-de-teu-pai', 'instrucao-de-teu-pai', 'Filho meu, ouve a instrução de teu pai; e não abandones a doutrina de tua mãe.', 'Provérbios 1:8', 'Família', false, true, 10),
  ('paz-ao-deitar', 'paz-ao-deitar', 'Em paz me deito e durmo; porque só tu, SENHOR, me fazes habitar seguro.', 'Salmos 4:8', 'Ansiedade', false, true, 11),
  ('ajuda-ao-proximo', 'ajuda-ao-proximo', 'Não detenhas o bem daqueles que possuem o direito, se tiveres em tuas mãos poder para o fazeres.', 'Provérbios 3:27', 'Amizade', false, true, 12)
on conflict (id) do nothing;
