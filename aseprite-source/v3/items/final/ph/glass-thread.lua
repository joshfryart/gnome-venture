-- glass-thread (Opus single pass). A slim wooden spool seen a touch from above (end-grain top face with growth rings
-- and a dark spindle hole, grained rims) wound with spun-glass thread: twisted 2-row windings with a bright rim and
-- a pale core, glints, AO under the top flange and above the bottom one. The loose end trails off to the right in a
-- twisted glassy curl. 2-tone ground shadow.
-- quirk: a tiny steel needle is stuck through the windings, its eye catching the light.
local NAME = "glass-thread"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB34_2.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, max, min, sin, pi = math.floor, math.abs, math.max, math.min, math.sin, math.pi
local c = G.new2(NAME)
local WOOD = { "#3a2226", "#51302b", "#864c33", "#b97a4a", "#d49a64", "#e8b982" }
local GLASS = { "#2a4a7a", "#3a86b0", "#5fc4c8", "#8fe0dc", "#c4f4ea", "#eefcf6" }
local STEEL = { "#444663", "#74758c", "#aaa9b8", "#e2e0e6" }
local CX = 25
local wtok, gtok = { r = { name = "wood" } }, { r = { name = "glass" } }
local CUT6 = { 0.15, 0.3, 0.47, 0.64, 0.82 }

c:groundShadow(CX, 54, 13, 1)

-- loose thread end first (behind the spool where it leaves it)
local tp = { { 32, 24 }, { 46, 18 }, { 53, 34 }, { 44, 42 } }
local tm, tn, TT = G.tube(tp, function() return 0.85 end)
local tp2 = { { 44, 42 }, { 38, 47 }, { 44, 52 }, { 49, 47 } }
local tm2, tn2, TT2 = G.tube(tp2, function(t) return 0.8 - 0.25 * t end)
local function twist(m, n, T, L)
  local idx = G.toneN(c, m, n, GLASS, { tok = gtok, cuts = { 0.2, 0.38, 0.56, 0.72, 0.86 }, amb = 0.2, wrap = 0.35 })
  m:each(function(x, y) local k = K(x, y) local ph = (T[k] * L) % 3
    if ph < 1 then c:put(x, y, GLASS[max(1, (idx[k] or 3) - 2)], gtok) elseif ph < 2 then c:put(x, y, GLASS[min(6, (idx[k] or 3) + 1)], gtok) end end)
end
twist(tm, tn, TT, 34) twist(tm2:cut(tm), tn2, TT2, 20)

-- barrel of wound glass thread
local function rb(y) if y >= 15 and y <= 47 then return 7.6 end end
local bm, bn, BS = G.lathe(CX, 15, 47, rb)
local bias = {}
bm:each(function(x, y) local k = K(x, y)
  if y <= 16 then bias[k] = -2 elseif y == 17 then bias[k] = -1 end
  if y >= 46 then bias[k] = -1 end
end)
local gidx = G.toneN(c, bm, bn, GLASS, { tok = gtok, bias = bias, cuts = CUT6, amb = 0.15, wrap = 0.3 })
bm:each(function(x, y) local k = K(x, y)
  local i = gidx[k] or 3
  if y >= 18 and y <= 45 then
    local ph = (y + floor((x - CX + 8) * 0.34)) % 3
    if ph == 0 then i = i - 2 elseif ph == 1 then i = i + 1 end         -- groove, bright strand rim, core
    if abs(BS[k]) < 0.25 and ph == 2 then i = i + 1 end                 -- pale core down the middle
  end
  c:put(x, y, GLASS[max(1, min(6, i))], gtok)
end)
-- glints on the glass windings
for _, p in ipairs{ { CX - 4, 21 }, { CX - 4, 22 }, { CX - 3, 33 }, { CX - 5, 39 } } do c:put(p[1], p[2], "#fff4d6", gtok) end
-- where the loose end leaves the barrel: a short strand wrapping over the right edge
for _, p in ipairs{ { CX + 6, 25 }, { CX + 7, 25 }, { CX + 7, 24 } } do c:put(p[1], p[2], GLASS[5], gtok) end

-- flanges (wood): rims with grain, a top face with end grain
local function rim(y0, y1)
  local m, n = G.lathe(CX, y0, y1, function(y) return (y == y0 or y == y1) and 9.6 or 10.2 end)
  local idx = G.toneN(c, m, n, WOOD, { tok = wtok, cuts = CUT6, amb = 0.12, wrap = 0.3 })
  -- grain: broken horizontal lines one tone darker
  m:each(function(x, y) local k = K(x, y)
    if (y == y0 + 1 and X.hash(x, 1, 3) > 0.45) or (y == y1 - 1 and X.hash(x, 2, 4) > 0.6) then c:put(x, y, WOOD[max(1, (idx[k] or 3) - 1)], wtok) end end)
  return m
end
local bot = rim(46, 51)
-- contact AO on the glass right above the bottom flange
for x = CX - 7, CX + 7 do c:put(x, 45, GLASS[x < CX and 2 or 1], gtok) end
local top = rim(12, 16)
-- top face: pale end-grain ellipse with growth rings and the spindle hole
local face = HP.mask()
for y = 8, 13 do for x = CX - 11, CX + 11 do
  if ((x + 0.5 - CX) / 10.2) ^ 2 + ((y + 0.5 - 11) / 3.2) ^ 2 <= 1 then face:set(x, y) end end end
face:each(function(x, y)
  local dx, dy = (x + 0.5 - CX) / 10.2, (y + 0.5 - 11) / 3.2
  local r = (dx * dx + dy * dy) ^ 0.5
  local col = WOOD[6]
  if dx > 0.45 or dy > 0.55 then col = WOOD[5] end
  local ring = (r * 4.2) % 1
  if ring < 0.22 and r > 0.3 then col = WOOD[4] end
  if r > 0.9 and dy > 0 then col = WOOD[4] end
  c:put(x, y, col, wtok)
end)
-- spindle hole with a dark eye and a lit far lip
for _, p in ipairs{ { -1, 10, 1 }, { 0, 10, 1 }, { 1, 10, 2 }, { -2, 11, 2 }, { -1, 11, 1 }, { 0, 11, 1 }, { 1, 11, 1 }, { 2, 11, 3 }, { -1, 12, 3 }, { 0, 12, 4 }, { 1, 12, 4 } } do
  c:put(CX + p[1], p[2], WOOD[p[3]], wtok) end
c:put(CX - 6, 9, "#fff4d6", wtok)

-- quirk: a little steel needle stuck through the windings, eye up-left
local nt = { r = { name = "needle" } }
local pts = { { 20, 31 }, { 19, 30 }, { 18, 29 }, { 17, 28 }, { 16, 27 }, { 15, 26 }, { 14, 25 }, { 13, 24 }, { 12, 23 } }
for i, p in ipairs(pts) do c:put(p[1], p[2], i % 3 == 0 and STEEL[4] or STEEL[3], nt) c:put(p[1] + 1, p[2], STEEL[2], nt) end
-- eye: open loop at the end
c:put(11, 22, STEEL[3], nt) c:put(11, 21, STEEL[4], nt) c:put(12, 21, STEEL[2], nt) c:put(13, 22, STEEL[1], nt)
c:put(12, 22, "#2b1c26", nt)
-- puncture shadow where it enters the glass
c:put(21, 31, GLASS[1], gtok) c:put(21, 32, GLASS[2], gtok)

G.save2(c, NAME)
