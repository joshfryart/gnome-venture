-- curry-paste (final, Opus single pass). A speckled granite mortar on a flared foot holding a heaped red curry paste
-- (coarse chili flecks, green herb bits, pale lemongrass shreds, an oily sheen and one glossy specular) with a slim
-- wooden pestle resting against the back rim: wood grain, pale end-grain cap, paste smeared on its foot, contact
-- shadow on the rim. Stone cues: speckle, bevelled flat rim, dark inner wall, cool bounce on the shade side.
-- quirk: a fat drip of paste has slid over the front rim and hangs down the outside of the bowl.
local NAME = "curry-paste"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB23_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, max, min, sqrt = math.floor, math.abs, math.max, math.min, math.sqrt
local c = A.new(NAME)

local ST   = { "#2a2838", "#434258", "#62647e", "#888aa2", "#b0b2c4", "#d8d8e2" }
local PASTE = { "#561a1e", "#8a2a1e", "#bc421e", "#de6828", "#f29444", "#ffc470" }
local WOOD = { "#4a2a22", "#6e3f2c", "#93593a", "#b97a4a", "#d9a36c", "#f0c994" }
local HERB, LEMON, SEED = "#5e8c34", "#e6dc92", "#ffe2a8"

c:groundShadow(32, 54, 14, 1)

-- masks
local CX, RY0 = 32, 30
local top   = c:ellipse(CX, RY0, 16, 5)
local bowl  = c:ellipse(CX, RY0 + 1, 16, 14):clip(c:rect(0, RY0, 63, 63)):add(top)
local foot  = c:poly{ {24, 42}, {40, 42}, {42, 52}, {22, 52} }:add(c:rrect(21, 49, 43, 53, 2))
local hole  = c:ellipse(CX, RY0 + 0.5, 13, 3.5)        -- opening inside the rim
local paste = c:ellipse(CX, RY0 + 1, 12, 3):add(c:ellipse(CX - 1, RY0, 9, 3)):clip(hole:copy():add(c:ellipse(CX - 1, RY0 - 1, 9, 3)))

-- foot (behind the bowl)
local ftok = { r = { name = "foot" } }
local fn = A.mix(A.cylV(foot, CX, 10), X.pillow(foot, 2), 0.3)
local fidx = A.shade(c, foot, fn, ST, { tok = ftok, amb = 0.08, wrap = 0.25 })
local bias = {}
X.ao(bias, foot, bowl, 2, -1)
for k, b in pairs(bias) do local x, y = k % 1024 - 256, k // 1024 - 256 A.step(c, fidx, ST, x, y, b, ftok) end
foot:each(function(x, y) if y == 49 and x > 22 and x < 42 then A.step(c, fidx, ST, x, y, x < 30 and 1 or 0, ftok) end end)

-- bowl body: rounded stone
local btok = { r = { name = "bowl" } }
local bn = A.mix(A.ellN(bowl, CX, RY0, 16, 14, 1), X.pillow(bowl, 3), 0.25)
local bidx = A.shade(c, bowl, bn, ST, { tok = btok, amb = 0.06, wrap = 0.25 })
-- cool bounce on the lower-right
local rim = X.rim(bn)
bowl:edge():each(function(x, y) local k = K(x, y) if y > RY0 + 4 and rim[k] and rim[k] > 0.5 then c:put(x, y, "#56688c", btok) end end)

-- flat top rim: bevelled ring, outer row bright on the lit side
local ring = top:copy():cut(hole)
ring:each(function(x, y)
  local a = (x - CX)
  local i = (a < -4) and 6 or (a < 6 and 5 or 4)
  if y > RY0 + 2 then i = i - 1 end
  c:put(x, y, ST[i], btok)
end)
top:edge():each(function(x, y) if y >= RY0 + 2 then c:put(x, y, x < CX and ST[5] or ST[3], btok) end end)

-- inner wall: dark, darkest at the back (shadowed by the rim)
hole:each(function(x, y) c:put(x, y, (y <= RY0 - 2) and ST[1] or ST[2], btok) end)
-- inner wall lit on the right (catches light through the opening)
for _, p in ipairs{ {43, 29}, {44, 30}, {44, 31} } do if hole:has(p[1], p[2]) then c:put(p[1], p[2], ST[3], btok) end end

-- granite speckle on stone (not on the opening)
bowl:copy():cut(hole):add(foot):each(function(x, y) local h = X.hash(x, y, 3)
  local idx = bidx[K(x, y)] and bidx or fidx
  local tok = bidx[K(x, y)] and btok or ftok
  if h < 0.12 then A.step(c, idx, ST, x, y, -2, tok) elseif h > 0.94 then A.step(c, idx, ST, x, y, 1, tok) end end)

-- paste: heaped dome
local ptok = { r = { name = "paste" } }
local pn = A.ellN(paste, CX - 1, RY0, 12, 4, 0.8)
local pidx = A.shade(c, paste, pn, PASTE, { tok = ptok, amb = 0.12, wrap = 0.3 })
paste:each(function(x, y) local h = X.hash(x, y, 11)
  if h < 0.08 then c:put(x, y, HERB, ptok)
  elseif h < 0.13 then c:put(x, y, PASTE[1], ptok)
  elseif h > 0.95 then c:put(x, y, LEMON, ptok) end end)
-- AO where paste meets the inner wall at the front lip
for x = 20, 44 do if paste:has(x, RY0 + 3) then c:put(x, RY0 + 3, PASTE[2], ptok) end end

-- pestle: slim wooden shaft leaning on the back-right rim, fattening into a rounded grinding foot
local pts = { { 35, 30 }, { 38, 23 }, { 42, 15 }, { 46, 8 } }
local pm, pn2, PT, PS = A.tube(pts, function(t) return 2.0 - 0.6 * t + (t > 0.9 and 0.3 or 0) end)
local ptk = { r = { name = "pestle" } }
local widx = A.shade(c, pm, pn2, WOOD, { tok = ptk, amb = 0.12, wrap = 0.3 })
pm:each(function(x, y) local k = K(x, y)
  -- grain: two broken dark lines along the shaft
  if (abs(PS[k] - 0.35) < 0.14 or abs(PS[k] + 0.25) < 0.1) and X.hash(x, y, 5) > 0.3 then A.step(c, widx, WOOD, x, y, -1, ptk) end
  -- paste coat on the foot
  if PT[k] < 0.16 then c:put(x, y, PASTE[max(2, min(6, (widx[k] or 3) + (PT[k] < 0.1 and 0 or -1)))], ptk) end
end)
-- end grain cap (paler rings)
for _, p in ipairs{ {45, 7, 6}, {46, 7, 5}, {47, 7, 5}, {45, 8, 5}, {46, 8, 4}, {47, 8, 4} } do
  if pm:has(p[1], p[2]) then c:put(p[1], p[2], WOOD[p[3]], ptk) end end
-- glossy specular on the paste and on the pestle coat
local sx, sy = A.specAt(paste, pn, 40)
c:put(sx, sy, PASTE[6], ptok) c:put(sx + 1, sy, A.CREAM, ptok)
-- contact shadow of the pestle on the back rim and paste (one step down just below-right of the shaft)
pm:shift(1, 1):each(function(x, y) if not pm:has(x, y) then
  if ring:has(x, y) then c:put(x, y, ST[3], btok) elseif paste:has(x, y) then c:put(x, y, PASTE[2], ptok) end end end)
-- ring of paste pushed up around the pestle foot
for _, p in ipairs{ {33, 30, 5}, {34, 31, 4}, {37, 31, 3}, {38, 30, 2} } do c:put(p[1], p[2], PASTE[p[3]], ptok) end

-- quirk: a drip sliding over the front rim and down the outside
local dtok = { r = { name = "drip" } }
local drip = { {24, 34}, {25, 34}, {24, 35}, {25, 35}, {24, 36}, {25, 36}, {24, 37}, {25, 37}, {24, 38}, {25, 38},
               {23, 39}, {24, 39}, {25, 39}, {26, 39}, {23, 40}, {24, 40}, {25, 40}, {26, 40}, {24, 41}, {25, 41} }
for _, p in ipairs(drip) do
  local x, y = p[1], p[2]
  local i = (x <= 24) and 5 or 3
  if y >= 40 then i = i - 1 end
  if x == 26 or y == 41 then i = 2 end
  c:put(x, y, PASTE[i], dtok)
end
c:put(24, 39, PASTE[6], dtok)
-- the drip's start on the rim
for _, p in ipairs{ {23, 33, 4}, {24, 33, 5}, {25, 33, 4}, {26, 33, 3} } do c:put(p[1], p[2], PASTE[p[3]], dtok) end
-- contact shadow beside the drip on the bowl
for y = 35, 40 do local x = (y >= 39) and 27 or 26 if bowl:has(x, y) then A.step(c, bidx, ST, x, y, -1, btok) end end

A.save(c, NAME)
