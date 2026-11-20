-- tailor EMPTY state, pass 2 (small sign). 64x64, anchor (32,54).
-- small wooden tag dangling by a red thread from a crossbar post, a cotton spool caps the post, a cream moth flutters.
local G = dofile("/tmp/ase/states2/signs2_kbgt_kit.lua")
local P, HP = G.P, G.HP
local out = app.params.out or "/tmp/ase/states2/tailor/"
local px, R, ink = G.px, G.R, G.ink
local W, S, E, D, PE, GO, CREAM, INK = P.wood, P.stone, P.ember, P.dusk, P.petal, P.gold, P.cream, P.ink

local PEG = { { 22, 51 }, { 42, 51 }, { 21, 56 }, { 43, 56 } }

local function post()
  local p = G.c:rect(41, 38, 41, 52)
  local bar = G.c:rect(28, 38, 42, 38)
  local spool = G.c:rect(40, 35, 43, 35):add(G.c:rect(41, 36, 42, 36)):add(G.c:rect(40, 37, 43, 37))
  ink(p, bar, spool)
  G.c:fillMask(p, W.shade) px(41, 52, W.deep)
  G.c:fillMask(bar, W.base) px(28, 38, W.hi)
  -- spool finial on the post: wooden flanges, red thread, a needle poking out
  R(40, 35, 43, 35, W.hi) R(40, 37, 43, 37, W.base) px(43, 37, W.shade)
  R(41, 36, 42, 36, E.base) px(41, 36, E.hi)
end

local function tag(dx)
  local m = G.c:rect(21, 43, 41, 47):add(G.c:rect(24, 42, 41, 42)):add(G.c:rect(24, 48, 41, 48))
  m = m:shift(dx, 0)
  G.c:rim(m, INK)
  G.c:fillMask(m, W.hi)
  m:each(function(x, y)
    local lx = x - dx
    if y == 42 or (lx == 21 and y < 46) then px(x, y, CREAM)
    elseif y == 48 or lx == 41 then px(x, y, W.base) end
  end)
  -- brass eyelet the thread runs through
  px(31 + dx, 42, GO.shade)
  G.text(22 + dx, 43, D.deep)
end

local function moth(f)   -- a small cream moth fluttering by the bar's open end
  local p = ({ { 23, 37 }, { 25, 35 }, { 22, 34 }, { 20, 36 } })[f]
  local x, y = p[1], p[2]
  px(x, y, INK)
  if f % 2 == 1 then px(x - 1, y, CREAM) px(x + 1, y, CREAM)
  else px(x - 1, y - 1, CREAM) px(x + 1, y - 1, CREAM) end
end

local function empty(f)
  local c = G.new(64, 64, "tailor-empty")
  local dx = ({ 0, 1, 0, -1 })[f]
  G.miniPlot(19, 48, 45, 58, 5)
  G.pegsBack(PEG)
  G.shadow2(G.c:poly{ { 26 + dx, 53 }, { 40 + dx, 53 }, { 42 + dx, 55 }, { 28 + dx, 55 } })
  post()
  -- red thread from the bar to the tag's eyelet
  px(31, 39, E.base) px(31, 40, E.base) px(31 + dx, 41, E.base)
  tag(dx)
  G.pegsFront(PEG)
  G.tinyPebble(35, 56) G.tinyTuft(19, 53) G.tinyTuft(45, 54)
  -- a dropped gold button instead of a flower
  px(27, 56, GO.base) px(28, 56, GO.shade)
  moth(f)
  return c
end

local fr = {}
for f = 1, 4 do fr[f] = empty(f) end
G.save(fr, out, "tailor")
