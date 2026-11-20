-- beehive EMPTY state, pass 2 (small sign). 56x64, anchor (28,54).
-- small hexagonal honey plaque hanging from a short bent iron hook, tiny skep perched on it, a bee buzzing round.
local G = dofile("/tmp/ase/states2/signs2_kbgt_kit.lua")
local P, HP = G.P, G.HP
local out = app.params.out or "/tmp/ase/states2/beehive/"
local px, R, ink = G.px, G.R, G.ink
local GO, S, SKY, INK = P.gold, P.stone, P.sky, P.ink
local IRON_L, IRON_B = S.shade, S.deep

local PEG = { { 19, 51 }, { 37, 51 }, { 18, 56 }, { 38, 56 } }

local function hook()
  local post = G.c:rect(20, 36, 20, 52)
  local bar = G.c:rect(20, 35, 27, 35)
  local tip = G.pts{ { 28, 36 } }
  ink(post, bar, tip)
  G.c:fillMask(post, IRON_B) G.c:fillMask(bar, IRON_L) G.c:fillMask(tip, IRON_B)
  px(20, 35, IRON_L) px(20, 52, S.deep)
end

local function plaque(dx)
  local m = G.c:rect(18 + dx, 42, 38 + dx, 46):add(G.c:rect(20 + dx, 41, 36 + dx, 47))
  G.c:rim(m, INK)
  G.c:fillMask(m, GO.base)
  m:each(function(x, y)
    if y == 41 or (x == 18 + dx and y < 45) then px(x, y, GO.hi)
    elseif y == 47 or (x == 38 + dx and y > 43) then px(x, y, GO.shade) end
  end)
  G.text(19 + dx, 42, INK)
  -- chain link from the hook
  px(28, 37, S.base) px(28 + (dx > 0 and 1 or 0), 38, IRON_B) px(28 + dx, 39, S.base)
  -- tiny straw skep perched on the plaque's right shoulder
  local b = dx
  local sk = G.c:rect(33 + b, 36, 35 + b, 36):add(G.c:rect(32 + b, 37, 36 + b, 39))
  ink(sk)
  R(33 + b, 36, 35 + b, 36, GO.hi)
  R(32 + b, 37, 36 + b, 37, GO.base) px(32 + b, 37, GO.hi)
  R(32 + b, 38, 36 + b, 38, GO.shade)
  R(32 + b, 39, 36 + b, 39, GO.base) px(34 + b, 39, INK)
end

local function bee(f)
  local p = ({ { 41, 38 }, { 42, 41 }, { 40, 44 }, { 39, 41 } })[f]
  local x, y = p[1], p[2]
  px(x, y, INK) px(x + 1, y, GO.base) px(x - 1, y, GO.hi)
  px(x, y - 1, (f % 2 == 1) and SKY.hi or P.cream)
end

local function empty(f)
  local c = G.new(56, 64, "beehive-empty")
  local dx = ({ 0, 1, 0, -1 })[f]
  G.miniPlot(16, 48, 40, 58, 7)
  G.pegsBack(PEG)
  G.shadow2(G.c:poly{ { 24 + dx, 53 }, { 37 + dx, 53 }, { 39 + dx, 55 }, { 26 + dx, 55 } })
  hook()
  plaque(dx)
  G.pegsFront(PEG)
  G.tinyPebble(25, 57) G.tinyTuft(16, 53) G.tinyTuft(41, 54)
  G.flower(31, 55, P.dusk.hi, P.dusk.base)   -- one lavender sprig-flower
  bee(f)
  return c
end

local fr = {}
for f = 1, 4 do fr[f] = empty(f) end
G.save(fr, out, "beehive")
