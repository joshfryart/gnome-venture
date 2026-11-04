-- folk-moth-1 portrait (folk F2_5) variant: 1
-- luna-moth gardener: mint wings with tails+eyespots, straw sun hat with sprig, denim dungarees, trowel.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local INK = "#2b1c26"
local function oval(cx, cy, rx, ry, deg)
  local a = math.rad(deg)
  local ca, sa, m = math.cos(a), math.sin(a), HP.mask()
  local R0 = math.max(rx, ry)
  for y = math.floor(cy - R0 - 1), math.ceil(cy + R0 + 1) do for x = math.floor(cx - R0 - 1), math.ceil(cx + R0 + 1) do
    local dx, dy = x + .5 - cx, y + .5 - cy
    local u, v = dx * ca + dy * sa, -dx * sa + dy * ca
    if (u / (rx + .3)) ^ 2 + (v / (ry + .3)) ^ 2 <= 1 then m:set(x, y) end
  end end
  return m
end
local function under(c, m, hex)
  local l = {}
  m:each(function(x, y) if not m:has(x, y + 1) then l[#l + 1] = { x, y } end end)
  for _, q in ipairs(l) do c:put(q[1], q[2], hex) end
end
local function part(c, m, r, o)
  o = o or {}
  c:part(m, r, { band = o.band or 1, nopop = true, inner = o.inner })
  if o.rim then local l = {}
    m:each(function(x, y) if not m:has(x - 1, y - 1) and c:get(x, y) == r.base then l[#l + 1] = { x, y } end end)
    for _, q in ipairs(l) do c:put(q[1], q[2], r.hi, r) end end
  if o.ud then under(c, m, r.deep) end
  return m
end
local function shadeIn(c, m, from, to)
  local l = {}
  m:each(function(x, y) if c:get(x, y) == from then l[#l + 1] = { x, y } end end)
  for _, q in ipairs(l) do c:put(q[1], q[2], to) end
end
-- feathered (bipectinate) moth antenna: thin stalk, then a feather frond with a dark rachis and alternating barbs
local function frond(c, x0, y0, x1, y1, w, A)
  c:fillMask(c:line({ { x0, y0 }, { x1, y1 } }, 1), A.deep)
  local sx, sy = x0 + (x1 - x0) * 0.3, y0 + (y1 - y0) * 0.3
  local dx, dy = x1 - sx, y1 - sy
  local len = math.sqrt(dx * dx + dy * dy)
  local m = oval((sx + x1) / 2, (sy + y1) / 2, len / 2, w, math.deg(math.atan(dy, dx)))
  c:part(m, A, { band = 1, nopop = true, inner = false })
  local ux, uy = dx / len, dy / len
  local l = {}
  m:each(function(x, y)
    local px, py = x + .5 - sx, y + .5 - sy
    local u, v = px * ux + py * uy, -px * uy + py * ux
    if math.abs(v) < 0.75 then l[#l + 1] = { x, y, A.deep }
    elseif (math.floor(u) + (v > 0 and 0 or 1)) % 2 == 0 then l[#l + 1] = { x, y, A.shade }
    elseif v < 0 and u < len * 0.6 then l[#l + 1] = { x, y, A.hi } end
  end)
  for _, q in ipairs(l) do c:put(q[1], q[2], q[3], A) end
  return m
end
local NAME = "folk-moth-1"
local R = {
  fur = { hi = "#f1f4c8", base = "#d6e3a2", shade = "#9fb48c", deep = "#667f74" },
  body = { hi = "#e3f0b8", base = "#bcd694", shade = "#88a886", deep = "#587470" },
  ruff = { hi = "#fbf6dc", base = "#ece6bc", shade = "#c2c09e", deep = "#8a8c84" },
  wing = { hi = "#d2f2b8", base = "#98d69a", shade = "#62a894", deep = "#3e7076" },
  edge = "#9c7cb8",
  spot = { hi = "#f6d98a", base = "#e0a64a", shade = "#a86c44", deep = "#5e3a48" },
  leg = { hi = "#b48aa0", base = "#8a6482", shade = "#62466a", deep = "#443452" },
  socket = "#7c6a94",
  nose = { hi = "#f2c08a", base = "#c8784a", shade = "#94524a", deep = "#64384a" },
  ant = { hi = "#f6e2a8", base = "#d8b874", shade = "#a48058", deep = "#6c4e4a" },
  straw = { hi = "#f8de90", base = "#e2b65e", shade = "#b27e4a", deep = "#7c5046" },
  ribbon = { hi = "#ec8a62", base = "#cc5a4c", shade = "#923c4e", deep = "#602c46" },
  cloth = { hi = "#88a6d0", base = "#5c78ac", shade = "#435488", deep = "#2f3a62" },
  steel = { hi = "#e2e6ee", base = "#a8b2c4", shade = "#727c96", deep = "#4c526c" },
  wood = { hi = "#d8a070", base = "#a8704c", shade = "#7a4c44", deep = "#52343e" },
  leaf = { hi = "#b8e070", base = "#72b04c", shade = "#4a8048", deep = "#2e5440" },
  gold = { hi = "#f8e08a", base = "#e8b440", shade = "#b07a3c", deep = "#74503c" },
  bg = { base = "#b4dca4", shade = "#8cbc94", deep = "#679a86" },
}
local V = {}
V.ant = { { 35, 24, 21, 5, 3 }, { 44, 24, 58, 5, 3 } }
V.back = function(c)
  local w = c:poly{ { 30, 62 }, { 49, 62 }, { 73, 72 }, { 79, 99 }, { 0, 99 }, { 6, 72 } }
  w:add(c:line({ { 4, 90 }, { 1, 99 } }, 4)) w:add(c:line({ { 75, 90 }, { 78, 99 } }, 4))
  part(c, w, R.wing, { band = 3, rim = true })
  c:fillMask(c:line({ { 30, 62 }, { 6, 72 }, { 2, 88 } }, 1):clip(w), R.edge)
  c:fillMask(c:line({ { 49, 62 }, { 73, 72 }, { 77, 88 } }, 1):clip(w), R.edge)
  for _, ex in ipairs{ 10, 69 } do
    c:fillMask(c:ellipse(ex, 84, 3.5, 3.5), R.spot.base) c:fillMask(c:ellipse(ex, 84, 1.5, 1.5), R.spot.deep)
    c:put(ex - 2, 82, R.spot.hi) c:put(ex - 1, 82, R.spot.hi)
  end
end
V.clothes = function(c, body)
  part(c, c:rrect(28, 82, 51, 99, 3), R.cloth, { band = 2, rim = true })
  part(c, c:line({ { 30, 83 }, { 25, 74 } }, 3), R.cloth, { band = 1 })
  part(c, c:line({ { 49, 83 }, { 54, 74 } }, 3), R.cloth, { band = 1 })
  part(c, c:rect(29, 82, 31, 84), R.gold, { band = 1, rim = true }) part(c, c:rect(48, 82, 50, 84), R.gold, { band = 1, rim = true })
  part(c, c:rrect(33, 88, 46, 96, 2), R.cloth, { band = 1 })
  c:stitch{ { 34, 89 }, { 45, 89 } }
end
V.hat = function(c)
  local brim = c:ellipse(39.5, 36, 26, 6)
  part(c, brim, R.straw, { band = 2, rim = true, ud = true })
  local cr = c:rrect(27, 19, 52, 36, 7)
  part(c, cr, R.straw, { band = 2, rim = true })
  local l = {}
  brim:copy():add(cr):each(function(x, y) if (x + 2 * y) % 5 == 0 and c:get(x, y) == R.straw.base then l[#l + 1] = { x, y } end end)
  for _, q in ipairs(l) do c:put(q[1], q[2], R.straw.shade) end
  part(c, c:rect(27, 30, 52, 33), R.ribbon, { band = 1, rim = true })
  for x = 15, 64 do if c:get(x, 42) == R.fur.base or c:get(x, 42) == R.fur.hi then c:put(x, 42, R.fur.shade) end end
  c:fillMask(c:line({ { 51, 31 }, { 57, 21 } }, 1), R.leaf.deep)
  for _, q in ipairs{ { 57, 20 }, { 60, 24 }, { 54, 24 } } do part(c, c:ellipse(q[1], q[2], 2, 1.5), R.leaf, { band = 1, rim = true }) end
end
V.front = function(c)
  local bl = c:poly{ { 9, 84 }, { 21, 84 }, { 19, 74 }, { 15, 66 }, { 11, 74 } }
  part(c, bl, R.steel, { band = 2, rim = true })
  c:fillMask(c:line({ { 15, 69 }, { 15, 83 } }, 1), R.steel.shade)
  c:put(15, 66, R.wood.deep) c:put(15, 67, R.wood.shade) c:put(14, 67, R.wood.shade) c:put(16, 68, R.wood.shade)
  part(c, c:rect(13, 84, 17, 86), R.steel, { band = 1 })
  part(c, c:rrect(13, 87, 17, 99, 1), R.wood, { band = 1, rim = true })
  part(c, c:ellipse(15, 92, 4.5, 3.5), R.body, { band = 1, rim = true })
end

local c = HP.canvas{ w = 80, h = 100, scale = 1, name = NAME }
local function backdrop(r)
  local disc = HP.ellipse(39.5, 44.5, 30.5, 30.5)
  disc:each(function(x, y) if not c:get(x, y) then c:put(x, y, disc:has(x + 2, y + 2) and r.base or r.shade, "bg") end end)
  local ring = disc:grow(1):cut(disc)
  ring:each(function(x, y) if not c:get(x, y) then
    local dk = false
    for _, d in ipairs{ { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } } do if c:get(x + d[1], y + d[2]) == r.shade then dk = true end end
    c:put(x, y, dk and r.deep or r.shade, "bg") end end)
end
V.back(c)
local body = c:ellipse(39.5, 104, 29, 30):clip(c:rect(0, 72, 79, 99))
for _, q in ipairs{ { 12, 90 }, { 15, 84 }, { 20, 79 }, { 59, 79 }, { 64, 84 }, { 67, 90 } } do body:add(HP.ellipse(q[1], q[2], 2, 2)) end
part(c, body, R.body, { band = 3, rim = true })
for y = 76, 99, 3 do for x = (y % 2) * 2, 79, 4 do
  if c:get(x, y) == R.body.base then c:put(x, y, R.body.shade) end end end
V.clothes(c, body)
local ruff = c:ellipse(39.5, 70, 17, 4)
for x = 24, 56, 4 do ruff:add(HP.ellipse(x, 73, 2.2, 2.2)) end
part(c, ruff, R.ruff, { band = 1, rim = true })
for x = 25, 55, 4 do if c:get(x, 74) == R.ruff.base then c:put(x, 74, R.ruff.shade) end end
if V.neck then V.neck(c) end
local head = c:ellipse(39.5, 48, 20, 17)
for i = 0, 8 do local a = math.rad(195 + i * 18.75) head:add(HP.ellipse(39.5 + math.cos(a) * 19.5, 48 + math.sin(a) * 16.5, 2.5, 2.5)) end
part(c, head, R.fur, { band = 3, rim = true, ud = true })
for _, s in ipairs{ { 28, 36, 29, 34 }, { 34, 33, 35, 31 }, { 44, 33, 45, 31 }, { 50, 36, 51, 34 }, { 24, 42, 25, 40 }, { 55, 42, 56, 40 }, { 22, 52, 23, 50 }, { 57, 52, 58, 50 } } do
  c:line({ { s[1], s[2] }, { s[3], s[4] } }, 1):clip(head):each(function(x, y) if c:get(x, y) == R.fur.base then c:put(x, y, R.fur.shade) end end)
end
-- compound-eye sockets around the locked eyes
c:fillMask(c:ellipse(32, 48, 4.5, 4), R.socket) c:fillMask(c:ellipse(47, 48, 4.5, 4), R.socket)
c:eyeLocked(30, 46) c:eyeLocked(45, 46)
-- coiled proboscis nose
for _, q in ipairs{ { 38, 53 }, { 39, 53 }, { 40, 53 }, { 41, 54 }, { 41, 55 }, { 40, 56 }, { 39, 56 }, { 38, 55 } } do c:put(q[1], q[2], R.nose.base) end
c:put(38, 53, R.nose.hi) c:put(39, 53, R.nose.hi) c:put(40, 55, R.nose.deep) c:put(41, 55, R.nose.shade) c:put(40, 56, R.nose.shade)
for _, q in ipairs{ { 35, 59 }, { 36, 60 }, { 37, 60 }, { 38, 60 }, { 39, 60 }, { 40, 60 }, { 41, 60 }, { 42, 60 }, { 43, 60 }, { 44, 59 } } do c:put(q[1], q[2], INK) end
c:cheek(24, 55) c:cheek(53, 55)
V.hat(c)
for _, a in ipairs(V.ant) do frond(c, a[1], a[2], a[3], a[4], a[5], R.ant) end
V.front(c)
c:finish{ outline = true }
backdrop(R.bg)
HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
print(NAME .. " portrait ok")
