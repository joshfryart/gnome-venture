-- kitchen EMPTY state, pass 2 (small sign). 96x80, anchor (48,70).
-- small chalkboard on a short two-leg stand, tiny red pot sitting on its top, check tea towel swings, chalk dust.
local G = dofile("/tmp/ase/states2/signs2_kbgt_kit.lua")
local P, HP = G.P, G.HP
local out = app.params.out or "/tmp/ase/states2/kitchen/"
local px, R, ink = G.px, G.R, G.ink
local W, S, E = P.wood, P.stone, P.ember
local SLATE = "#33494b"
local CHALK = P.cream

local PEG = { { 38, 67 }, { 58, 67 }, { 37, 74 }, { 59, 74 } }

local function empty(f)
  local c = G.new(96, 80, "kitchen-empty")
  G.miniPlot(35, 65, 61, 75, 3)
  G.pegsBack(PEG)
  G.shadow2(G.c:poly{ { 47, 71 }, { 58, 71 }, { 61, 73 }, { 50, 73 } })
  -- two splayed legs
  local legL = G.segMask(40, 64, 38, 70)
  local legR = G.segMask(56, 64, 58, 70)
  ink(legL, legR)
  G.c:fillMask(legL, W.base) G.c:fillMask(legR, W.shade)
  -- ledge under the board
  local ledge = G.c:rect(38, 64, 58, 64)
  ink(ledge) G.c:fillMask(ledge, W.base) px(38, 64, W.hi)
  -- slate board
  G.plate(37, 55, 23, 9, SLATE)
  G.text(39, 57, CHALK)
  -- tiny red pot sitting on the board's top right
  local pot = G.c:rect(53, 51, 57, 51):add(G.c:rect(52, 52, 58, 52)):add(G.c:rect(53, 53, 57, 54))
  ink(pot)
  R(53, 51, 57, 51, S.base) px(53, 51, S.hi) px(54, 51, S.hi)
  R(53, 52, 57, 52, E.base) px(52, 52, S.shade) px(58, 52, S.shade)
  R(53, 53, 57, 53, E.base) px(53, 52, E.hi) px(53, 53, E.hi) R(54, 54, 57, 54, E.shade) px(53, 54, E.base)
  -- check tea towel hanging off the ledge, its lower half swings 1 px
  local sw = ({ 0, 1, 0, -1 })[f]
  local tw = G.c:rect(53, 65, 55, 66):add(G.c:rect(53 + sw, 67, 55 + sw, 67))
  ink(tw)
  tw:each(function(x, y)
    local lx = (y == 67) and x - sw or x
    px(x, y, ((lx + y) % 2 == 0) and E.base or CHALK)
  end)
  -- chalk dust puff drifting up-left off the board's corner
  if f == 2 then px(36, 62, CHALK)
  elseif f == 3 then px(35, 60, CHALK) px(36, 61, S.hi)
  elseif f == 4 then px(34, 58, S.hi) end
  G.pegsFront(PEG)
  G.tinyPebble(44, 72) G.tinyPebble(51, 74) G.tinyTuft(35, 70) G.tinyTuft(61, 71)
  return c
end

local fr = {}
for f = 1, 4 do fr[f] = empty(f) end
G.save(fr, out, "kitchen")
