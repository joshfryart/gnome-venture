-- bramble-pelt (final, Opus aB10_2). The tanned pelt of a bramble beast laid out flat, seen from above: a slim oval
-- body with four tapering leg flaps, a pointed head flap and a thin tail. Russet-plum fur lit upper-left with soft
-- pillowed edges, combed strands flowing down and out from the spine, ragged fur tufts on the rim. A dark berry-plum
-- stripe runs down the spine, set with pale hooked thorns. The lower-right leg flap curls over to show the pale
-- suede skin side, with a dark fold line.
-- quirk: one ripe blackberry is snagged in the fur by the left shoulder.
local NAME = "bramble-pelt"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB10_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, max, min = math.floor, math.abs, math.max, math.min
local c = A.new(NAME)
local FUR = { "#2e1b26", "#4a2a33", "#6c3d3a", "#8f5741", "#b5774f", "#d9a26a" }
local SPINE = { "#24142c", "#3c2246", "#5a3366", "#7c4a86" }
local SUEDE = { "#7a4a3c", "#a8735a", "#d2a07c", "#f0cfa4" }
local THORN, THORNS = "#f2e2b4", "#b88f6a"

local CX = 32
local body = c:ellipse(CX, 32, 10, 15)
local function leg(ax, ay, bx, by, w0, w1)
  local m, n, T, S = A.tube({ { ax, ay }, { (2 * ax + bx) / 3, (2 * ay + by) / 3 + 1 }, { (ax + 2 * bx) / 3, (ay + 2 * by) / 3 }, { bx, by } },
    function(t) return w0 + (w1 - w0) * t end)
  return m, T, S
end
local lf = leg(26, 23, 12, 14, 3.6, 1.5)
local rf = leg(38, 23, 52, 14, 3.6, 1.5)
local lh = leg(26, 41, 12, 51, 3.8, 1.6)
local rh, RHT, RHS = leg(38, 41, 52, 51, 3.8, 1.8)
local head = leg(CX, 19, CX, 8, 3.4, 0.9)
local tail = A.tube({ { CX, 45 }, { CX + 1, 50 }, { CX + 4, 54 }, { CX + 6, 57 } }, function(t) return 1.6 - t * 0.9 end)
local all = body:copy():add(lf):add(rf):add(lh):add(rh):add(head):add(tail)
-- ragged fur tufts on the rim (never on the thin tips)
local edge = all:edge()
edge:each(function(x, y) local h = X.hash(x, y, 9)
  if h < 0.3 and body:grow(3):has(x, y) and not head:has(x, y) then all.s[K(x, y)] = nil end end)
local curl = HP.mask()
rh:each(function(x, y) if RHT[K(x, y)] > 0.66 then curl:set(x, y) end end)
curl:clip(all)
local fur = all:copy():cut(curl)

-- fur: pillowed body, strands combed down and out from the spine
local n = X.pillow(all, 3)
local bias = {}
fur:each(function(x, y) local k = K(x, y)
  local a = abs(x - CX)
  local p = a - 0.6 * y
  local f = (p / 3) - floor(p / 3)
  local cell = X.hash(floor(p / 3), floor((0.6 * a + y) / 4), 5)
  local b = 0
  if f < 0.34 and cell < 0.6 then b = -1 elseif f > 0.67 and cell > 0.55 then b = 1 end
  if X.hash(x, y, 2) < 0.05 then b = b - 1 end
  bias[k] = b
end)
-- ambient under the curled flap
curl:each(function(x, y) for _, d in ipairs{ { -1, 0 }, { 0, -1 }, { -1, -1 } } do
  local k = K(x + d[1], y + d[2]) if fur:has(x + d[1], y + d[2]) then bias[k] = (bias[k] or 0) - 2 end end end)
local tok = { r = { name = "fur" } }
local v = X.light(n, { amb = 0.12, wrap = 0.3 })
X.tone(c, fur, v, FUR, { cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, bias = bias, tok = tok })

-- spine stripe with hooked thorns
local stok = { r = { name = "spine" } }
for y = 12, 46 do
  if all:has(CX, y) then
    local wide = y > 18 and y < 44
    for dx = (wide and -1 or 0), (wide and 1 or 0) do
      local i = (dx == -1) and 3 or (dx == 0 and 2 or 1)
      if y < 16 or y > 42 then i = max(1, i - 1) end
      c:put(CX + dx, y, SPINE[i], stok)
    end
    if wide and y % 2 == 0 then c:put(CX - 1, y, SPINE[4], stok) end
  end
end
for i, y in ipairs{ 21, 26, 31, 36, 41 } do
  local s = (i % 2 == 1) and -1 or 1
  local x0 = CX + s * 2
  c:put(x0, y, s < 0 and THORN or THORNS, stok)
  c:put(x0 + s, y - 1, s < 0 and THORN or THORNS, stok)
  c:put(x0, y + 1, FUR[1], tok)   -- tiny cast shadow under each thorn
end

-- curled flap: suede skin side with fold line
local ctok = { r = { name = "suede" } }
local cn = X.pillow(curl, 1.5)
local cv = X.light(cn, { amb = 0.2, wrap = 0.4 })
X.tone(c, curl, cv, SUEDE, { cuts = { 0.3, 0.55, 0.8 }, tok = ctok })
curl:each(function(x, y) local t = RHT[K(x, y)]
  if t and t < 0.72 then c:put(x, y, FUR[1], ctok) end
  if t and t > 0.9 and RHS[K(x, y)] < 0 then c:put(x, y, SUEDE[4], ctok) end
end)

-- quirk: snagged blackberry at the left shoulder
local btok = { r = { name = "berry" } }
A.map(c, 19, 23, {
  ".dbd.",
  "dWbbd",
  "bbdbs",
  "dbbsd",
  ".dsd.",
}, { W = "#fff4d6", b = "#5a3a8a", d = "#2e1f4e", s = "#3b2a62" }, btok)
c:put(21, 22, "#5a8a3c", btok) c:put(22, 21, "#3f6e34", btok)  -- calyx stub
for _, q in ipairs{ { 24, 25 }, { 24, 26 }, { 22, 28 }, { 23, 27 } } do
  if fur:has(q[1], q[2]) then c:put(q[1], q[2], FUR[1], tok) end end

A.save(c, NAME)
