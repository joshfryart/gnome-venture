-- lemon-curd (final pass, Opus). A squat open glass jar filled to the brim with glossy lemon curd, a screw-thread
-- collar, the curd domed above the rim in a soft swirl, and a slim wooden spoon pushed in at an angle.
-- Material: curd = per-pixel dome light on a 6-tone custard ramp, a glossy specular and a darker swirl groove;
-- jar = lit glass wall ring, thread ridges on the collar, long cream specular streak, cool reflected right edge,
-- deep amber where the curd meets the base. Spoon: cylinder light, grain flecks, pale end grain on the handle tip,
-- AO where it enters the curd. 2-tone ground shadow.
-- History: Sonnet draft (_dC20) replaced.
-- quirk: one fat drip of curd has escaped over the rim and is running down the outside of the jar.
local NAME = "lemon-curd"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC20_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, max, min, sqrt = math.floor, math.abs, math.max, math.min, math.sqrt
local c = A.new(NAME)

local GLASS = { "#2a4a7a", "#3a6f96", "#5b9fbe", "#8fcfd8", "#c4eee8", "#eafff6" }
local CURD = { "#94501a", "#c98224", "#e9ad30", "#f7cc4a", "#ffe27e", "#fff4bc" }
local WOOD = { "#51302b", "#7a4a32", "#a06a42", "#c08d5a", "#ddb47e", "#f0d3a0" }

local cx = 27.5
c:groundShadow(28, 56, 14, 2)

-- spoon handle first (behind the dome top, in front of nothing)
local stok = { r = { name = "spoon" } }
local sp = { { 31, 25 }, { 36, 19 }, { 41, 14 }, { 46, 9 } }
local sm, sn = A.tube(sp, function(t) return 1.25 + 0.35 * t end)
local sidx = A.shade(c, sm, sn, WOOD, { tok = stok, amb = 0.12, wrap = 0.3 })

-- jar body: rounded straight sided, wide and low
local function w(y)
  if y < 24 then return nil end
  if y <= 28 then return 9.5 end        -- collar
  if y == 29 then return 10.5 end
  if y <= 51 then return 11.5 end
  if y <= 54 then return 11.5 - (y - 51) * 1.2 end
  return nil
end
local bm, bn, BS = A.lathe(cx, 24, 54, w)
local gtok, ctok = { r = { name = "jar" } }, { r = { name = "curd" } }
local inner = bm:shrink(1)
local gv = X.light(bn, { amb = 0.2, wrap = 0.4 })
bm:each(function(x, y) local k = K(x, y)
  c:put(x, y, GLASS[(gv[k] > 0.55) and 4 or ((gv[k] > 0.3) and 3 or 2)], gtok) end)
-- curd seen through the glass (below collar)
local cm = HP.mask()
inner:each(function(x, y) if y >= 30 then cm:set(x, y) end end)
local bias = {}
cm:each(function(x, y) if y >= 51 then bias[K(x, y)] = -1 end end)
X.tone(c, cm, X.light(bn, { amb = 0.15, wrap = 0.35 }), CURD, { cuts = A.CUTS, bias = bias, tok = ctok })
-- collar: thread ridges (alternating light/dark rows), glass over curd
for y = 24, 28 do for x = floor(cx - 10), floor(cx + 10) do if bm:has(x, y) then
  local k = K(x, y)
  local i = (y % 2 == 0) and ((BS[k] < 0) and 5 or 4) or ((BS[k] < 0.3) and 3 or 2)
  if BS[k] > 0.75 then i = max(1, i - 1) end
  c:put(x, y, GLASS[i], gtok)
end end end
-- shoulder under the collar: dark row (ambient)
for x = floor(cx - 10), floor(cx + 11) do if bm:has(x, 29) then c:put(x, 29, GLASS[2], gtok) end end

-- curd dome above the rim + a swirl peak
local dm = c:ellipse(cx, 23, 9.5, 4)
dm:add(c:ellipse(cx - 1.5, 19.5, 6, 2.6))
dm:add(c:ellipse(cx - 2, 17, 2.5, 1.5))
local cut = HP.mask() dm:each(function(x, y) if y > 24 then cut:set(x, y) end end) dm:cut(cut)
local dn = A.dome(dm, cx - 1, 21, 9, 3, 0.55)
local dbias = {}
X.ao(dbias, dm, bm, 1, -1)
local didx = A.shade(c, dm, dn, CURD, { tok = ctok, bias = dbias, amb = 0.14, wrap = 0.3 })
-- swirl groove: a curve wrapping around the peak
for _, p in ipairs{ { -6, 21 }, { -5, 21 }, { -4, 22 }, { -3, 22 }, { -2, 22 }, { -1, 22 }, { 0, 22 }, { 1, 21 }, { 2, 21 }, { 3, 20 },
  { -4, 18 }, { -3, 19 }, { -2, 19 }, { -1, 19 }, { 0, 19 }, { 1, 18 } } do
  A.step(c, didx, CURD, floor(cx + p[1]), p[2], -2, ctok) end
-- lit lip above each groove
for _, p in ipairs{ { -5, 20 }, { -4, 21 }, { -3, 21 }, { -2, 21 }, { -3, 18 }, { -2, 18 } } do
  A.step(c, didx, CURD, floor(cx + p[1]), p[2], 1, ctok) end
-- glossy specular on the dome
c:put(floor(cx - 5), 20, A.CREAM, ctok) c:put(floor(cx - 4), 20, A.CREAM, ctok)
c:put(floor(cx - 3), 16, CURD[6], ctok)

-- spoon re-drawn where it rises out of the curd (in front of the dome), AO ring on the curd round it
local front = HP.mask()
sm:each(function(x, y) if not dm:has(x, y) or y < 21 then front:set(x, y) end end)
local ring = HP.mask()
front:grow(1):each(function(x, y) if dm:has(x, y) and not front:has(x, y) and y >= 19 then ring:set(x, y) end end)
ring:each(function(x, y) A.step(c, didx, CURD, x, y, -2, ctok) end)
local sidx2 = A.shade(c, front, sn, WOOD, { tok = stok, amb = 0.12, wrap = 0.3 })
for _, t in ipairs{ 0.32, 0.5, 0.66, 0.8 } do
  local x, y = A.bez(sp, t) x, y = floor(x + 0.5), floor(y + 0.5)
  if front:has(x, y) then A.step(c, sidx2, WOOD, x, y, -2, stok) end
end
-- end grain on the handle tip
c:put(46, 8, WOOD[6], stok) c:put(47, 9, WOOD[5], stok) c:put(46, 9, WOOD[5], stok)

-- glass specular streak + cool reflected edge
for y = 31, 50 do if y ~= 46 then c:put(floor(cx - 8), y, (y > 33 and y < 42) and A.CREAM or GLASS[6], gtok) end end
for y = 33, 38 do c:put(floor(cx - 7), y, GLASS[6], gtok) end
for y = 32, 51 do c:put(floor(cx + 11), y, "#9fd8dc", gtok) end
for x = floor(cx - 9), floor(cx - 6) do c:put(x, 25, GLASS[6], gtok) end

-- quirk: drip over the rim on the left, down the outside of the jar
local drip = { { -10, 24, 4 }, { -11, 25, 5 }, { -11, 26, 4 }, { -11, 27, 4 }, { -11, 28, 3 }, { -12, 29, 4 }, { -12, 30, 4 },
  { -12, 31, 4 }, { -12, 32, 3 }, { -12, 33, 4 }, { -12, 34, 3 }, { -13, 34, 5 }, { -13, 35, 4 }, { -12, 35, 3 }, { -13, 36, 3 },
  { -12, 36, 2 }, { -13, 33, 6 } }
for _, p in ipairs(drip) do c:put(floor(cx + p[1]), p[2], CURD[p[3]], ctok) end

A.save(c, "ph", NAME)
