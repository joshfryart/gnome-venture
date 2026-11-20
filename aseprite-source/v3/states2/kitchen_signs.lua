-- kitchen EMPTY state only (BUILD-sign craft pass). 96x80, anchor (48,70).
local G = dofile("/tmp/ase/states2/signs_kbgt_common.lua")
local P, HP = G.P, G.HP
local out = app.params.out or "/tmp/ase/states2/kitchen/"
local px, R, ink, lerp = G.px, G.R, G.ink, G.lerp
local W, S, E, ST, GO, M = P.wood, P.stone, P.ember, P.stone, P.gold, P.moss
local SLATE, SLATE_D, SLATE_L, SLATE_EDGE = "#33494b", "#26383d", "#476163", "#1f2e34"
local CHALK = P.cream

local STK = { { 24, 63 }, { 72, 63 }, { 22, 74 }, { 74, 74 } }

local function towel(f)   -- check tea towel hanging from the ledge's right end, swings 1 px
  local sw = ({ 0, 1, 0, -1 })[f]
  local m = HP.mask()
  for y = 58, 64 do
    local o = (y >= 61) and sw or 0
    for x = 62, 65 do m:set(x + o, y) end
  end
  ink(m)
  m:each(function(x, y)
    local o = (y >= 61) and sw or 0
    local lx = x - o
    local check = ((lx - 62) // 2 + (y - 58) // 2) % 2 == 0
    px(x, y, check and E.base or CHALK)
  end)
  -- fold shadow under the ledge and fringe
  for x = 62, 65 do px(x, 58, E.shade) end
  px(65 + sw, 64, lerp(CHALK, G.DUSKSH, .25)) px(64 + sw, 64, E.shade)
end

local function dust(f)   -- chalk dust puff drifting up-left from the chalk on the ledge (soft, unoutlined)
  local function puff(x, y, big)
    if big then
      px(x, y - 1, CHALK) px(x - 1, y, CHALK) px(x, y, CHALK) px(x + 1, y, S.base) px(x, y + 1, S.base)
    else px(x, y, CHALK) px(x + 1, y, S.base) end
  end
  if f == 1 then puff(26, 55)
  elseif f == 2 then puff(25, 53, true) px(28, 55, CHALK)
  elseif f == 3 then puff(22, 50, true) puff(25, 52)
  else px(20, 47, S.base) px(22, 46, CHALK) px(23, 46, S.base) px(23, 49, CHALK) end
end

local function empty(f)
  local c = G.new(96, 80, "kitchen-empty")
  G.plot(15, 58, 81, 77, 5, 3)
  G.tuft(18, 63) G.tuft(60, 59) G.tuft(80, 69) G.tuft(32, 78)
  G.stringBack(STK)
  -- cast shadow of the easel (cool, hard, lower right)
  G.shadow(G.c:poly{ { 35, 71 }, { 63, 71 }, { 77, 75 }, { 49, 75 } })
  G.shadow(G.c:poly{ { 64, 66 }, { 68, 66 }, { 72, 69 }, { 66, 69 } })
  -- easel: two front legs meeting at a pegged apex, a rear leg, a ledge
  local legL = G.c:line({ { 45, 29 }, { 34, 70 } }, 2)
  local legR = G.c:line({ { 50, 29 }, { 61, 70 } }, 2)
  local rear = G.c:line({ { 48, 56 }, { 50, 67 } }, 1)
  local apex = G.c:rect(45, 27, 50, 29)
  ink(rear) G.c:fillMask(rear, W.shade) px(48, 56, W.deep)
  ink(legL, legR, apex)
  G.c:fillMask(legL, W.base) G.c:fillMask(legR, W.base)
  legL:each(function(x, y) if not legL:has(x - 1, y) then px(x, y, W.hi) end end)
  legR:each(function(x, y) if not legR:has(x + 1, y) then px(x, y, W.shade) end end)
  G.c:fillMask(apex, W.base) R(45, 27, 50, 27, W.hi) R(46, 29, 50, 29, W.shade) px(47, 28, GO.base) px(48, 28, GO.base) px(47, 28, GO.hi)
  -- the board: wooden frame, visible thickness lower right, slate face
  local frame = G.c:rect(31, 33, 63, 55)
  local thick = G.c:rect(32, 56, 64, 56):add(G.c:rect(64, 34, 64, 56))
  ink(frame, thick)
  G.c:fillMask(thick, W.deep)
  G.c:fillMask(frame, W.base)
  R(31, 33, 63, 33, W.hi) R(31, 33, 31, 55, W.hi)
  R(32, 55, 63, 55, W.shade) R(63, 34, 63, 55, W.shade)
  -- grain on the frame
  for _, g in ipairs{ { 37, 33 }, { 38, 33 }, { 52, 33 }, { 53, 33 }, { 58, 33 }, { 31, 40 }, { 31, 41 }, { 31, 48 }, { 41, 55 }, { 42, 55 }, { 56, 55 }, { 63, 44 }, { 63, 45 } } do
    px(g[1], g[2], (g[2] == 33 or g[1] == 31) and W.base or W.deep)
  end
  -- slate (recessed: dark top/left inner edge)
  R(33, 35, 61, 53, SLATE)
  R(33, 35, 61, 35, SLATE_EDGE) R(33, 35, 33, 53, SLATE_EDGE)
  R(34, 36, 61, 36, SLATE_D) R(34, 36, 34, 53, SLATE_D)
  -- chalk smudges well away from the lettering
  for _, s in ipairs{ { 36, 51 }, { 37, 51 }, { 37, 52 }, { 58, 38 }, { 59, 38 }, { 59, 39 }, { 57, 52 }, { 58, 52 }, { 36, 39 } } do px(s[1], s[2], SLATE_L) end
  -- nail heads at the frame corners
  for _, n in ipairs{ { 32, 34 }, { 62, 34 }, { 32, 54 }, { 62, 54 } } do px(n[1], n[2], S.hi) end
  -- red pot icon (chalk steam above)
  local ox = 47
  px(ox, 38, GO.hi)
  R(ox - 2, 39, ox + 2, 39, S.hi)
  R(ox - 3, 40, ox + 3, 40, S.base)
  R(ox - 3, 41, ox + 3, 43, E.base)
  R(ox - 2, 44, ox + 2, 44, E.shade)
  R(ox - 2, 41, ox - 1, 41, E.hi) px(ox - 3, 42, E.hi)
  R(ox + 2, 43, ox + 3, 43, E.shade)
  px(ox - 4, 41, S.hi) px(ox + 4, 41, S.hi)
  px(ox - 3, 37, CHALK) px(ox - 2, 36, CHALK) px(ox + 3, 36, CHALK) px(ox + 2, 37, CHALK)
  -- BUILD, chalk on slate with a dark slate shadow
  G.text(38, 47, CHALK, SLATE_EDGE)
  -- ledge with chalk stick
  local ledge = G.c:rect(29, 57, 66, 58)
  ink(ledge)
  G.c:fillMask(ledge, W.base) R(29, 57, 66, 57, W.hi) R(30, 58, 66, 58, W.shade)
  local chalk = G.c:rect(28, 56, 30, 56)
  ink(chalk) G.c:fillMask(chalk, CHALK) px(30, 56, S.hi)
  R(29, 57, 66, 57, W.hi)
  towel(f)
  dust(f)
  G.stringFront(STK)
  G.pebble(28, 66, true) G.pebble(70, 64) G.pebble(43, 74)
  G.flower(25, 68, P.dusk.hi, P.dusk.base)   -- chive blossom
  G.flower(71, 70, GO.base)                  -- marigold
  return c
end

local fr = {}
for f = 1, 4 do fr[f] = empty(f) end
G.save(fr, out, "kitchen")
