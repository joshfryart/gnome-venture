-- folk-moth-3 portrait (folk F2_5) variant: 3
-- oak-eggar cook/crafter: rust round hooked wings, dotted kerchief, apron with a nibbled hole (quirk), knitting.
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
local NAME = "folk-moth-3"
local R = {
  fur = { hi = "#f2bc84", base = "#d48c54", shade = "#9e5e4a", deep = "#663c4a" },
  body = { hi = "#e4a070", base = "#bc7048", shade = "#8a4c44", deep = "#5a3242" },
  ruff = { hi = "#fbe4b8", base = "#ecc48c", shade = "#be9270", deep = "#86605c" },
  wing = { hi = "#ec9e60", base = "#c0663e", shade = "#8a443e", deep = "#5a303e" },
  window = "#f6e4bc",
  leg = { hi = "#a47888", base = "#7a546a", shade = "#583c56", deep = "#3e2c44" },
  socket = "#6e3c50",
  nose = { hi = "#f6d0a0", base = "#d08a5c", shade = "#9a5a4c", deep = "#64384a" },
  ant = { hi = "#f8d8a0", base = "#dca86c", shade = "#a8784e", deep = "#6e4c46" },
  apron = { hi = "#fdf3dc", base = "#eedcb8", shade = "#c6b0a2", deep = "#8c7a88" },
  kerchief = { hi = "#cab4ea", base = "#9c84ca", shade = "#705aa0", deep = "#4c3e76" },
  yarn = { hi = "#92c4f0", base = "#5a90d8", shade = "#3e64a8", deep = "#2c4678" },
  wood = { hi = "#d8a070", base = "#a8704c", shade = "#7a4c44", deep = "#52343e" },
  gold = { hi = "#f8e08a", base = "#e8b440", shade = "#b07a3c", deep = "#74503c" },
  bg = { base = "#f0c48c", shade = "#d6a072", deep = "#b0785c" },
}
local V = {}
V.ant = { { 34, 32, 27, 5, 3.5 }, { 45, 32, 52, 5, 3.5 } }
V.back = function(c)
  local w = c:ellipse(10, 82, 12, 16) w:add(c:ellipse(69, 82, 12, 16))
  w:add(c:ellipse(3, 65, 3.5, 4)) w:add(c:ellipse(76, 65, 3.5, 4))
  part(c, w, R.wing, { band = 3, rim = true })
  c:fillMask(c:line({ { 1, 74 }, { 18, 97 } }, 1):clip(w), R.wing.deep)
  c:fillMask(c:line({ { 78, 74 }, { 61, 97 } }, 1):clip(w), R.wing.deep)
  c:fillMask(c:poly{ { 6, 78 }, { 13, 80 }, { 9, 86 } }, R.window)
  c:fillMask(c:poly{ { 73, 78 }, { 66, 80 }, { 70, 86 } }, R.window)
end
V.clothes = function(c, body)
  local a = c:rrect(27, 79, 52, 99, 4)
  a:cut(HP.ellipse(52, 87, 2, 2))
  part(c, a, R.apron, { band = 2, rim = true })
  part(c, c:line({ { 29, 80 }, { 25, 73 } }, 3), R.apron, { band = 1 })
  part(c, c:line({ { 50, 80 }, { 54, 73 } }, 3), R.apron, { band = 1 })
  part(c, c:rrect(32, 88, 47, 96, 2), R.apron, { band = 1 })
  c:stitch{ { 33, 89 }, { 46, 89 } }
  c:put(35, 83, R.body.shade) c:put(36, 83, R.body.shade) c:put(36, 84, R.body.deep)
end
V.hat = function(c)
  local k = c:ellipse(39.5, 48, 20.5, 17.5):clip(c:rect(0, 0, 79, 38))
  k:add(c:rrect(18, 36, 61, 41, 2))
  part(c, k, R.kerchief, { band = 3, rim = true, ud = true })
  local l = {}
  k:each(function(x, y) if x % 5 == 0 and y % 5 == ((x % 10 == 0) and 0 or 2) and c:get(x, y) == R.kerchief.base then l[#l + 1] = { x, y } end end)
  for _, q in ipairs(l) do c:put(q[1], q[2], R.apron.hi) c:put(q[1] + 1, q[2], R.apron.hi) end
  part(c, c:poly{ { 61, 40 }, { 69, 44 }, { 65, 48 } }, R.kerchief, { band = 1 })
  part(c, c:poly{ { 61, 38 }, { 70, 35 }, { 68, 40 } }, R.kerchief, { band = 1, rim = true })
  part(c, c:ellipse(60, 39, 3, 2.5), R.kerchief, { band = 1, rim = true })
end
V.front = function(c)
  c:fillMask(c:line({ { 56, 98 }, { 71, 70 } }, 2), R.wood.base)
  c:fillMask(c:line({ { 61, 99 }, { 76, 74 } }, 2), R.wood.shade)
  part(c, c:ellipse(71.5, 69, 1.5, 1.5), R.gold, { band = 1, rim = true })
  part(c, c:ellipse(76.5, 73, 1.5, 1.5), R.gold, { band = 1, rim = true })
  local s = c:rrect(57, 79, 71, 89, 1)
  part(c, s, R.yarn, { band = 2, rim = true })
  for y = 81, 87, 2 do for x = 58, 70, 2 do c:put(x, y, R.yarn.shade) c:put(x + 1, y + 1, R.yarn.hi) end end
  local ball = c:ellipse(69, 95, 6, 5)
  part(c, ball, R.yarn, { band = 2, rim = true })
  c:fillMask(c:line({ { 64, 93 }, { 73, 98 } }, 1):clip(ball), R.yarn.shade)
  c:fillMask(c:line({ { 66, 91 }, { 74, 95 } }, 1):clip(ball), R.yarn.shade)
  part(c, c:ellipse(56, 90, 4, 3.5), R.body, { band = 1, rim = true })
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
