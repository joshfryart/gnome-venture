-- hooked-forager-s-knife (final, Opus single pass). A slim forager's hawkbill: turned wooden handle on the diagonal
-- (lower-left), brass ferrule with two raised rings, then a dark carbon-steel blade that rises and curls over into a
-- downward hook. Material: per-pixel cylinder light on handle + ferrule, wood grain streaks and a pale end-grain butt,
-- two brass pins; blade = flat face + honed bevel on the inner (concave) edge with a bright edge line, grind line,
-- specular streak and one glint, AO where blade meets ferrule and ferrule meets wood.
-- quirk: a short red twine lanyard, twisted, tied through the butt hole with a frayed tail.
local NAME = "hooked-forager-s-knife"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC12_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local WOOD  = { "#3e2420", "#5e3427", "#844b30", "#a8673c", "#c98a52", "#e8b77c" }
local BRASS = { "#4e2c16", "#8a5420", "#bd8128", "#dea53a", "#f5cd62", "#fff0a8" }
local STEEL = { "#2a2634", "#433d4c", "#625a6a", "#8a8292", "#bab3c0", "#eee8ee" }
local TWINE = { "#5c1a2a", "#9a2a34", "#d0453c", "#f07a5a" }

-- handle: straight turned tube, slight swell, rounded butt
local hp = { { 15, 54 }, { 19, 50 }, { 23, 46 }, { 27, 42 } }
local hm, hn, HT, HS = A.tube(hp, function(t)
  if t < 0.06 then return 1.6 + t / 0.06 * 0.8 end
  return 2.4 + 0.25 * sin(pi * t)
end)
local htok = { r = { name = "wood" } }
local hb = {}
local hidx = A.tone(c, hm, hn, WOOD, { tok = htok, bias = hb, cuts = { 0.16, 0.32, 0.5, 0.68, 0.86 } })
-- grain: thin dark streaks along the handle that wander slightly
hm:each(function(x, y) local k = K(x, y) local t, s = HT[k], HS[k]
  local g = (s + 1) * 2.6 + 0.5 * sin(t * 17 + s * 2)
  if t > 0.07 and abs(g - floor(g) - 0.5) < 0.12 and (hidx[k] or 3) > 2 then c:put(x, y, WOOD[(hidx[k] or 3) - 1], htok) end
end)
-- pale end grain at the butt + lanyard hole
hm:each(function(x, y) local k = K(x, y) if HT[k] < 0.05 and HS[k] < 0.5 then c:put(x, y, WOOD[5], htok) end end)
c:put(16, 52, WOOD[1], htok) c:put(17, 52, WOOD[2], htok)
-- brass pins
for _, t in ipairs{ 0.38, 0.68 } do
  local x, y = A.bez(hp, t) x, y = floor(x + .5), floor(y + .5)
  c:put(x, y, BRASS[5], htok) c:put(x + 1, y, BRASS[3], htok) c:put(x, y + 1, BRASS[2], htok)
end

-- ferrule: short brass collar over the handle top
local fp = { { 26.2, 42.8 }, { 27.2, 41.8 }, { 28.2, 40.8 }, { 29.4, 39.6 } }
local fm, fn, FT, FS = A.tube(fp, function(t) return 2.9 end)
local ftok = { r = { name = "brass" } }
local fidx = A.tone(c, fm, fn, BRASS, { tok = ftok, cuts = { 0.14, 0.3, 0.48, 0.66, 0.84 } })
fm:each(function(x, y) local k = K(x, y) local t = FT[k]
  if t < 0.22 or (t > 0.55 and t < 0.68) then c:put(x, y, BRASS[max(1, (fidx[k] or 3) - 2)], ftok) end
end)
-- AO on the wood just under the ferrule
hm:each(function(x, y) if not fm:has(x, y) and (fm:has(x + 1, y) or fm:has(x, y - 1) or fm:has(x + 1, y - 1)) then c:put(x, y, WOOD[1], htok) end end)

-- blade: rises up-right then hooks over to the left, point aimed down-left. inner edge on the -A side.
local bp = { { 29.5, 39.5 }, { 39, 27 }, { 52, 8 }, { 37, 11.5 } }
local bm, BT, BS, BSM, bs, blen = A.ribbon(bp, function(t)
  local wa = (t < 0.05) and 1.0 or (3.4 * (1 - t) ^ 0.7 + 0.4)
  local wb = 1.7 * (1 - t) ^ 0.45 + 0.45
  return wa, wb
end)
bm:cut(fm)
local bn, bias = {}, {}
bm:each(function(x, y) local k = K(x, y) local s, sm = BS[k], BSM[k]
  local nx, ny, nz
  if s < -sm.wa * 0.42 and BT[k] > 0.05 then nx, ny, nz = A.norm(-sm.ax * 0.8, -sm.ay * 0.8, 1)      -- bevel faces the edge
  elseif s > sm.wb - 0.8 then nx, ny, nz = A.norm(sm.ax * 0.5, sm.ay * 0.5, 1)                         -- rounded spine
  else nx, ny, nz = A.norm(-0.1 + sm.ax * s * 0.06, -0.12 + sm.ay * s * 0.06, 1) end                   -- flat face
  bn[k] = { nx, ny, nz }
  if BT[k] < 0.05 then bias[k] = -1 end
end)
local btok = { r = { name = "steel" } }
local bidx = A.tone(c, bm, bn, STEEL, { tok = btok, bias = bias, cuts = { 0.18, 0.34, 0.5, 0.66, 0.84 } })
bm:each(function(x, y) local k = K(x, y) local s, sm, t = BS[k], BSM[k], BT[k]
  -- honed edge line
  if s < -sm.wa + 0.95 and t > 0.06 and t < 0.93 then c:put(x, y, (t < 0.6) and STEEL[6] or STEEL[5], btok) return end
  -- grind line between bevel and flat
  if abs(s + sm.wa * 0.42) < 0.5 and t > 0.08 and t < 0.8 then c:put(x, y, STEEL[2], btok) return end
end)
-- specular streak on the flat + glint
for _, t in ipairs{ 0.16, 0.2, 0.24, 0.28, 0.32 } do
  local s = bs[floor(t * 200) + 1]
  local x, y = floor(s.x + s.ax * 0.3 + .5), floor(s.y + s.ay * 0.3 + .5)
  if bm:has(x, y) then c:put(x, y, STEEL[5], btok) end
end
do local s = bs[floor(0.22 * 200) + 1] c:put(floor(s.x + s.ax * 0.3 + .5), floor(s.y + s.ay * 0.3 + .5), A.CREAM, btok) end
-- maker's dot stamped near the heel
do local s = bs[floor(0.1 * 200) + 1] local x, y = floor(s.x + s.ax * 0.6 + .5), floor(s.y + s.ay * 0.6 + .5) c:put(x, y, STEEL[1], btok) c:put(x - 1, y, STEEL[5], btok) end

-- quirk: red twine lanyard through the butt hole, twisted, with a frayed tail
local tp = { { 16, 53 }, { 12, 55 }, { 11, 59 }, { 15, 59 } }
local ttok = { r = { name = "twine" } }
for i = 0, 40 do
  local t = i / 40
  local x, y = A.bez(tp, t) x, y = floor(x + .5), floor(y + .5)
  if not hm:has(x, y) then
    c:put(x, y, (i % 4 < 2) and TWINE[3] or TWINE[2], ttok)
    if i % 4 == 0 and not hm:has(x + 1, y) then c:put(x + 1, y, TWINE[4], ttok) end
  end
end
c:put(16, 60, TWINE[2], ttok) c:put(17, 60, TWINE[3], ttok) c:put(18, 61, TWINE[4], ttok) c:put(17, 61, TWINE[1], ttok)
A.save2(c, NAME)
