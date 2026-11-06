-- apple-crumble (final, Opus). A low oval stoneware baking dish in glossy cobalt glaze (bright rim lip, wet specular
-- on the wall, two lug handles), heaped with a lumpy golden crumble (each crumb lit as its own little dome, crevice
-- shadows, sugar crystals, oat flakes) and dark-red apple syrup bubbling up at the rim.
-- quirk: one spoonful is already gone at the front right, showing glossy apple slices, and a steam curl rises from it.
local NAME = "apple-crumble"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR2_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, max, min, sqrt, sin, cos = math.floor, math.abs, math.max, math.min, math.sqrt, math.sin, math.cos
local c = A.new(NAME)

local DISH  = { "#172056", "#22327e", "#3150ac", "#4a74cc", "#7aa2e6", "#bcd6fa" }
local CRUMB = { "#6a3418", "#975224", "#c27c30", "#e2a344", "#f3c668", "#ffe6a0" }
local SYR   = { "#3e1416", "#6a2418", "#9a3e1c", "#c8682a", "#eea04a" }
local APL   = { "#a2702c", "#d0a04a", "#ecc874", "#fbe6a4", "#fff6d2" }
local STEAM = { "#b4b0c6", "#dedbe8", "#f6f2f2" }
local CX, CY, RX, RY = 31.5, 30, 21, 7.5        -- rim ellipse
local IX, IY = 18, 5.4                             -- inner (opening)
local BY, BRX, BRY = 39, 18, 5                   -- dish foot ellipse

c:groundShadow(32, 45, 22, 1.5)
local function inE(x, y, cx, cy, rx, ry) local dx, dy = (x - cx) / (rx + 0.45), (y - cy) / (ry + 0.45) return dx*dx + dy*dy <= 1 end

-- dish body: rim ellipse + walls down to the foot ellipse
local body = HP.mask()
for y = 18, 46 do for x = 8, 56 do
  local ok = inE(x, y, CX, CY, RX, RY) or inE(x, y, CX, BY, BRX, BRY)
  if not ok and y >= CY and y <= BY then
    local t = (y - CY) / (BY - CY)
    local r = RX + (BRX - RX) * t
    ok = abs(x - CX) <= r
  end
  if ok then body:set(x, y) end
end end
local dtok = { r = { name = "dish" } }
local bn, BS = {}, {}
body:each(function(x, y)
  local t = max(0, min(1, (y - CY) / (BY - CY)))
  local r = RX + (BRX - RX) * t
  local s = max(-0.96, min(0.96, (x - CX) / (r + 0.5)))
  local cz = sqrt(1 - s * s)
  bn[K(x, y)] = { A.norm(s, 0.75 * cz, cz) } BS[K(x, y)] = s
end)
local db = {}
body:each(function(x, y) if y >= BY + 3 then db[K(x, y)] = -1 end end)
A.shade(c, body, bn, DISH, { amb = 0.1, wrap = 0.3, tok = dtok, bias = db })

-- lug handles
local lugs = HP.mask()
for _, sx in ipairs{ -1, 1 } do
  for y = 28, 32 do for x = 0, 3 do
    local xx = sx < 0 and floor(CX - RX) - x or floor(CX + RX) + 1 + x
    if not (x == 3 and (y == 28 or y == 32)) then lugs:set(xx, y) end
  end end
end
lugs:each(function(x, y)
  local col = y == 28 and DISH[5] or (y == 29 and DISH[4] or (y == 32 and DISH[1] or DISH[x > CX and 2 or 3]))
  c:put(x, y, col, dtok)
end)
c:put(floor(CX - RX) - 2, 28, DISH[6], dtok)

-- rim lip: ring between rim ellipse and opening
local open = HP.mask()
for y = 20, 40 do for x = 8, 56 do if inE(x, y, CX, CY, IX, IY) then open:set(x, y) end end end
local ring = HP.mask()
for y = 20, 40 do for x = 8, 56 do if inE(x, y, CX, CY, RX, RY) and not open:has(x, y) then ring:set(x, y) end end end
local function rimCol(x, y)
  if y < CY then return (x < CX + 6) and DISH[6] or DISH[5] end      -- back lip faces up: bright
  return (x < CX - 4) and DISH[5] or DISH[4]
end
ring:each(function(x, y) c:put(x, y, rimCol(x, y), dtok) end)
-- inner back wall (just below back lip) in shade
open:each(function(x, y) if y < CY - 3 and not open:has(x, y - 1) then c:put(x, y, DISH[2], dtok) end end)

-- syrup bed inside the opening
local stok = { r = { name = "syrup" } }
open:each(function(x, y)
  local i = 3
  if y <= CY - 4 then i = 2 end
  if (x + y * 3) % 7 == 0 then i = 4 end
  c:put(x, y, SYR[i], stok)
end)

-- scoop (quirk) at the front right: no crumbs there
local SCX, SCY = 40, 31
local function inScoop(x, y) return inE(x, y, SCX, SCY, 6.2, 3.2) end

-- crumble: domed heap of crumbs, painted back to front
local crumbs = {}
for gy = 0, 6 do for gx = 0, 12 do
  local bx = CX - 18 + gx * 3.1 + ((gy % 2) * 1.5) + (X.hash(gx, gy, 1) - 0.5) * 1.6
  local by = CY - 5 + gy * 1.9 + (X.hash(gx, gy, 2) - 0.5) * 1.0
  local dx, dy = (bx - CX) / IX, (by - CY) / IY
  local q = dx*dx + dy*dy
  if q < 0.86 and not inE(floor(bx), floor(by), SCX, SCY, 6.4, 3.6) then
    local h = 7.5 * (1 - q) ^ 0.7
    local r = 1.7 + X.hash(gx, gy, 3) * 1.4
    crumbs[#crumbs + 1] = { x = bx, y = by - h, r = r, base = by }
  end
end end
table.sort(crumbs, function(a, b) return a.base < b.base end)
local ctok = { r = { name = "crumb" } }
local cr = HP.mask()
local frontLimit = function(x, y) return open:has(x, y) or y < CY end   -- crumbs never cover the front lip
local owner = {}
for i, b in ipairs(crumbs) do
  local m = HP.mask()
  for y = floor(b.y - b.r) - 1, floor(b.y + b.r) + 1 do for x = floor(b.x - b.r) - 1, floor(b.x + b.r) + 1 do
    local dx, dy = (x - b.x) / (b.r + 0.45), (y - b.y) / (b.r * 0.85 + 0.45)
    if dx*dx + dy*dy <= 1 and frontLimit(x, y) and not inScoop(x, y) then m:set(x, y) end
  end end
  local n = X.sphere(b.x - 0.3, b.y - 0.3, b.r, m)
  local bias = {}
  -- crevice: darken where this crumb sits right on an earlier one
  m:each(function(x, y) local k = K(x, y) if owner[K(x, y + 1)] and owner[K(x, y + 1)] ~= i and not m:has(x, y + 1) then bias[k] = -1 end end)
  A.shade(c, m, n, CRUMB, { amb = 0.02, wrap = 0.15, tok = ctok, bias = bias, cuts = { 0.2, 0.4, 0.56, 0.72, 0.88 } })
  m:each(function(x, y) owner[K(x, y)] = i end)
  cr:add(m)
end
-- the crumb outlines: 1 px deep line where a crumb's lower edge meets a crumb behind it (separation)
cr:each(function(x, y)
  local a, b = owner[K(x, y)], owner[K(x, y + 1)]
  if b and a ~= b and owner[K(x, y + 1)] < a then end
end)
-- sugar crystals + oat flakes
for _, p in ipairs{ {20,22},{27,18},{33,17},{38,20},{24,27},{44,24},{30,24},{17,28} } do
  if cr:has(p[1], p[2]) then c:put(p[1], p[2], "#fff4d6", ctok) end
end
for _, p in ipairs{ {23,20},{35,22},{41,27},{28,29} } do
  if cr:has(p[1], p[2]) and cr:has(p[1] + 1, p[2]) then c:put(p[1], p[2], "#e8d2a2", ctok) c:put(p[1] + 1, p[2], "#c8ac78", ctok) end
end
-- syrup bubbling up between crumbs along the front edge
for _, p in ipairs{ {16,31},{22,35},{29,36},{14,29},{47,30} } do
  if open:has(p[1], p[2]) and not cr:has(p[1], p[2]) then c:put(p[1], p[2], SYR[5], stok) end
end

-- scoop: glossy apple slices in syrup, crumb wall behind casts shade
local scoop = HP.mask()
open:each(function(x, y) if inScoop(x, y) and not cr:has(x, y) then scoop:set(x, y) end end)
scoop:each(function(x, y) c:put(x, y, SYR[(y <= SCY - 2) and 1 or 3], stok) end)
local atok = { r = { name = "apple" } }
-- three crescent slices lying in the scoop (pale flesh, red skin rim, wet edge)
for _, sl in ipairs{ { 35, 30 }, { 39, 32 }, { 43, 30 } } do
  A.map(c, {
    ".hhhh.",
    "hmmmmd",
    "rdddsr",
    ".rrrr.",
  }, sl[1] - 2, sl[2] - 1, { h = APL[5], m = APL[3], d = APL[2], s = APL[1], r = "#b8302e" }, atok)
end
c:put(39, 30, A.CREAM, atok)                         -- wet glint
-- shade on the slices right under the back crumbs
for x = 33, 47 do local y = SCY - 3 while y < SCY + 3 and cr:has(x, y) do y = y + 1 end
  if scoop:has(x, y) then c:put(x, y, SYR[1], stok) end end

-- front lip on top of everything (crumbs and syrup tucked behind it)
ring:each(function(x, y) if y >= CY then c:put(x, y, rimCol(x, y), dtok) end end)
-- lip highlight + wall specular (glossy glaze)
for x = 15, 22 do c:put(x, CY + 6, DISH[6], dtok) end
c:put(13, 34, DISH[6], dtok) c:put(14, 35, DISH[6], dtok) c:put(14, 36, DISH[5], dtok)
-- ambient dark row right under the lip on the wall
body:each(function(x, y) if not ring:has(x, y) and ring:has(x, y - 1) and y > CY + 2 then c:put(x, y, DISH[2], dtok) end end)

-- steam curl from the scoop
local st = { r = { name = "steam" } }
A.map(c, {
  "..aa.",
  ".a...",
  ".ab..",
  "..bb.",
  "...bc",
  "..bc.",
  ".bc..",
}, 41, 15, { a = STEAM[3], b = STEAM[2], c = STEAM[1] }, st)

A.save(c, NAME)
