-- folk-moth-2 portrait (folk F2_5) variant: 2
-- rosy-maple traveller: pink/yellow fuzz, cap, striped scarf, pack+bedroll, glowing lantern.
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
local NAME = "folk-moth-2"
local R = {
  fur = { hi = "#fdeaa6", base = "#f4cc5c", shade = "#cc9658", deep = "#8e5c58" },
  body = { hi = "#fac0cf", base = "#e884a4", shade = "#b45a84", deep = "#7a406c" },
  ruff = { hi = "#fff0c4", base = "#f8de8e", shade = "#d6ac6c", deep = "#9a7062" },
  wing = { hi = "#f8b4c4", base = "#de7c9c", shade = "#a8547e", deep = "#703c66" },
  leg = { hi = "#d48aa0", base = "#a46282", shade = "#74466c", deep = "#4c3256" },
  socket = "#8c4c78",
  nose = { hi = "#fbd8a0", base = "#e0905a", shade = "#a8604e", deep = "#6c3e4a" },
  ant = { hi = "#fdeab0", base = "#f0c86c", shade = "#c49058", deep = "#845a52" },
  scarf = { hi = "#86dccc", base = "#44a8a2", shade = "#2e7684", deep = "#244e62" },
  cap = { hi = "#a596c0", base = "#73689a", shade = "#504874", deep = "#363252" },
  pack = { hi = "#e4c896", base = "#c09a68", shade = "#8c6a52", deep = "#5c4446" },
  roll = { hi = "#9cc4e4", base = "#6a94c4", shade = "#4c6a9a", deep = "#344a70" },
  leather = { hi = "#b47a58", base = "#8a5440", shade = "#643a3c", deep = "#442838" },
  metal = { hi = "#c8c0c8", base = "#8e8494", shade = "#625a70", deep = "#423c52" },
  glow = { hi = "#fff2b8", base = "#fcd468", shade = "#eca244", deep = "#c06c3c" },
  gold = { hi = "#f8e08a", base = "#e8b440", shade = "#b07a3c", deep = "#74503c" },
  bg = { base = "#f2aec0", shade = "#d68aa6", deep = "#b06a8c" },
}
local V = {}
V.ant = { { 31, 30, 5, 17, 3 }, { 48, 30, 74, 17, 3 } }
V.back = function(c)
  for _, s in ipairs{ -1, 1 } do
    local w = oval(39.5 + s * 35, 90, 6, 11, s * -20)
    part(c, w, R.wing, { band = 2 })
    c:fillMask(oval(39.5 + s * 35, 93, 7, 1.5, s * -20):clip(w), R.fur.base)
  end
  part(c, c:rrect(7, 66, 72, 99, 7), R.pack, { band = 3, rim = true })
  c:stitch{ { 10, 76 }, { 18, 72 } } c:stitch{ { 61, 72 }, { 69, 76 } }
  part(c, c:rrect(3, 58, 76, 68, 4), R.roll, { band = 2, rim = true, ud = true })
  for _, x in ipairs{ 9, 69 } do part(c, c:rect(x, 58, x + 1, 68), R.leather, { band = 1 }) end
  for _, x in ipairs{ 4, 75 } do c:put(x, 62, R.roll.deep) c:put(x, 63, R.roll.deep) end
end
V.clothes = function(c, body)
  part(c, body:copy():clip(c:rect(0, 88, 79, 92)), R.fur, { band = 1 })
  part(c, c:line({ { 26, 74 }, { 22, 99 } }, 4), R.leather, { band = 1, rim = true })
  part(c, c:line({ { 53, 74 }, { 57, 99 } }, 4), R.leather, { band = 1, rim = true })
  part(c, c:rect(21, 84, 26, 87), R.gold, { band = 1, rim = true }) part(c, c:rect(53, 84, 58, 87), R.gold, { band = 1, rim = true })
end
V.neck = function(c)
  local s = c:rrect(20, 67, 59, 76, 3)
  s:add(c:line({ { 50, 74 }, { 55, 86 }, { 53, 95 } }, 6))
  part(c, s, R.scarf, { band = 2, rim = true, ud = true })
  local l = {}
  s:each(function(x, y) if (x + (y > 76 and y or 0)) % 6 == 0 and c:get(x, y) ~= R.scarf.deep then l[#l + 1] = { x, y } end end)
  for _, q in ipairs(l) do c:put(q[1], q[2], R.fur.base) end
  for x = 50, 56, 2 do c:put(x, 98, R.scarf.shade) c:put(x, 99, R.scarf.shade) end
end
V.hat = function(c)
  local cr = c:ellipse(39.5, 34, 19.5, 9.5)
  part(c, cr, R.cap, { band = 2, rim = true })
  c:fillMask(c:line({ { 39, 26 }, { 27, 42 } }, 1):clip(cr), R.cap.shade)
  c:fillMask(c:line({ { 40, 26 }, { 52, 42 } }, 1):clip(cr), R.cap.shade)
  part(c, c:ellipse(39.5, 42, 14, 3), R.cap, { band = 1, ud = true })
  part(c, c:ellipse(39.5, 25, 2, 1.5), R.gold, { band = 1, rim = true })
end
V.front = function(c)
  c:fillMask(c:line({ { 65, 82 }, { 65, 84 } }, 1), R.metal.deep)
  part(c, c:rect(60, 85, 70, 87), R.metal, { band = 1, rim = true })
  part(c, c:rrect(60, 88, 70, 97, 2), R.glow, { band = 2, rim = true })
  c:fillMask(c:ellipse(65, 92, 2, 3), R.glow.hi)
  for y = 88, 97 do c:put(62, y, R.metal.shade) c:put(68, y, R.metal.shade) end
  part(c, c:rect(60, 98, 70, 99), R.metal, { band = 1 })
  part(c, c:ellipse(65, 80, 4, 3), R.body, { band = 1, rim = true })
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
