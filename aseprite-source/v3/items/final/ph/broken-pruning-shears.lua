-- broken-pruning-shears (aB12_2, Opus single pass). Bypass secateurs, jaws up: a slim curved cutting blade with a
-- bright honed edge and a darker hooked anvil, brass pivot bolt, coil spring between two curved handles with
-- ember rubber grips. Material: bevelled steel + spec, grip ridges, spring twist, AO at pivot and grip collars.
-- broken: the cutting blade snapped two-thirds up (its tip spins away), a split in the right grip, a steel chip flies.
-- quirk: a snipped leaf sprig still caught in the jaws.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB12_2.lua")
local HP, X, K = A.HP, A.X, A.K
local c = A.new("broken-pruning-shears")
local RED = { "#4e1530", "#7e1f38", "#b52e3f", "#e8493b", "#ff7a55", "#ffb08a" }
local LEAF = A.LEAF

local L = A.bez(31, 25, 23, 38, 20, 56)
local R = A.bez(33, 25, 41, 38, 44, 56)
local function hwH(t) return t < 0.32 and 1.3 or 2.1 end
local lm, lT = A.taper(c, L, hwH)
local rm, rT = A.taper(c, R, hwH)
local BA = A.bez(32, 25, 23, 19, 25, 8)     -- cutting blade
local BB = A.bez(32, 25, 41, 19, 38, 9)     -- anvil hook
local ahw = function(t) return 0.7 + 2.0 * (1 - t) end
local am = A.taper(c, A.sub(BA, 0, 0.62), function(t) return ahw(t * 0.62) end)
local bm = A.taper(c, BB, function(t) return 0.9 + 2.0 * (1 - t) end)
local fly = A.shift(A.sub(BA, 0.68, 1), -5, 1)
local fm = A.taper(c, fly, function(t) return ahw(0.68 + 0.32 * t) end, 20)
-- spring (behind handles)
A.rod(c, 25, 36, 39, 36, 1.3, A.STEEL, { twist = 2 })
-- handles: steel near pivot, ember grip lower
local function handle(m, T)
  local steel, grip = HP.mask(), HP.mask()
  m:each(function(x, y) if T[K(x, y)] < 0.32 then steel:set(x, y) else grip:set(x, y) end end)
  A.lit(c, steel, A.STEEL, { R = 1.2, bias = A.ao(steel, { grip }, 1, -1) })
  local gi = A.lit(c, grip, RED, { R = 1.8, wrap = 0.3 })
  -- grip ridges
  grip:each(function(x, y) local t = T[K(x, y)] if t > 0.4 and t < 0.95 and math.floor(t * 40) % 3 == 0 then
    local i = gi[K(x, y)] c:put(x, y, RED[math.max(1, i - 1)]) end end)
  return grip
end
local lg = handle(lm, lT)
local rg = handle(rm, rT)
-- blades
local bi, bn = A.lit(c, bm, A.STEEL, { R = 1.5, bias = A.ao(bm, { am }, 1, -1), wrap = 0.2 })
local ai, an = A.lit(c, am, A.STEEL, { R = 1.5, wrap = 0.35 })
A.streak(c, am, ai, A.STEEL, 42, 2)
A.bevel(c, am, 1, 0, A.STEEL[6])          -- honed inner edge
local fi = A.lit(c, fm, A.STEEL, { R = 1, wrap = 0.35 })
A.bevel(c, fm, 1, 0, A.STEEL[6])
local sx, sy = A.specAt(am, an) c:px(sx, sy, A.SPEC)
-- fresh break faces
for y = 10, 16 do if am:has(26, y) and not am:has(26, y - 1) then c:px(26, y, A.STEEL[5]) end end
-- pivot bolt
local bolt = c:ellipse(32, 25, 2.5, 2.5)
A.tone(c, bolt, X.sphere(31.6, 24.6, 2.5, bolt), A.GOLD)
c:px(31, 24, A.GOLD[6]) c:px(31, 25, A.GOLD[2]) c:px(32, 25, A.GOLD[2]) c:px(33, 25, A.GOLD[2])
-- AO ring below the bolt
for x = 30, 34 do if not bolt:has(x, 28) then c:px(x, 28, A.STEEL[2]) end end
-- split in right grip
A.gap(c, { { 43, 47 }, { 41, 50 }, { 42, 52 } }, 1)
c:px(40, 49, RED[6])
-- flying chip
A.chip(c, { { 14, 25 }, { 17, 23 }, { 17, 27 } }, A.STEEL)
c:px(16, 24, A.SPEC)
-- quirk: leaf sprig caught in the jaws
local stem = c:line({ { 30, 21 }, { 35, 15 } }, 1) c:fillMask(stem, "#3f6a3a")
local leaf = c:poly{ { 34, 15 }, { 36, 11 }, { 40, 9 }, { 41, 12 }, { 38, 15 } }
local li = A.lit(c, leaf, LEAF, { R = 1.5 })
c:line({ { 35, 15 }, { 40, 10 } }, 1):each(function(x, y) if leaf:has(x, y) then c:px(x, y, LEAF[2]) end end)
c:px(37, 11, LEAF[6])
A.save(c)
