-- folk-moth-1 sprite (folk F2_5) variant: 1
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
V.ant = { { 28, 25, 17, 11, 2 }, { 36, 25, 47, 11, 2 } }
V.back = function(c, b, p) -- luna wings: tented, long trailing hindwing tails, eyespots, lilac leading edge
  local w = c:poly{ { 22, 50 + b }, { 42, 50 + b }, { 52, 76 + b }, { 12, 76 + b } }
  w:add(c:ellipse(17, 73 + b, 7, 6)) w:add(c:ellipse(47, 73 + b, 7, 6))
  w:add(c:line({ { 15, 77 + b }, { 12, 83 + b }, { 14, 88 + b } }, 3))
  w:add(c:line({ { 49, 77 + b }, { 52, 83 + b }, { 50, 88 + b } }, 3))
  part(c, w, R.wing, { band = 2, rim = true, ud = true })
  c:fillMask(c:line({ { 22, 51 + b }, { 12, 72 + b } }, 1), R.edge)
  c:fillMask(c:line({ { 42, 51 + b }, { 52, 72 + b } }, 1), R.edge)
  for _, ex in ipairs{ 16, 48 } do
    c:fillMask(c:ellipse(ex, 69 + b, 2.5, 2.5), R.spot.base)
    c:fillMask(c:ellipse(ex, 69 + b, 1, 1), R.spot.deep) c:put(ex - 1, 68 + b, R.spot.hi)
  end
end
V.clothes = function(c, b, p, body) -- denim dungarees
  local d = body:copy():clip(c:rect(0, 75 + b, 63, 95))
  d:add(c:rrect(26, 64 + b, 38, 75 + b, 1))
  part(c, d, R.cloth, { band = 2, rim = true, ud = true })
  part(c, c:line({ { 27, 65 + b }, { 24, 59 + b } }, 2), R.cloth, { band = 1 })
  part(c, c:line({ { 37, 65 + b }, { 40, 59 + b } }, 2), R.cloth, { band = 1 })
  c:put(27, 65 + b, R.gold.base) c:put(37, 65 + b, R.gold.base)
  c:stitch{ { 28, 69 + b }, { 36, 69 + b } }
  for y = 80, 85 do if d:has(32, y + b) then c:put(32, y + b, R.cloth.deep) end end
end
V.hat = function(c, b, p) -- wide straw sun hat, antennae out through the crown, sprig in the band
  local brim = c:ellipse(32, 33 + b, 18, 4.5)
  part(c, brim, R.straw, { band = 2, rim = true, ud = true })
  local cr = c:rrect(23, 21 + b, 41, 32 + b, 5)
  part(c, cr, R.straw, { band = 2, rim = true })
  shadeIn(c, c:rect(23, 32 + b, 41, 32 + b):clip(brim), R.straw.base, R.straw.shade)
  local l = {}
  brim:copy():add(cr):each(function(x, y) if (x + 2 * y) % 5 == 0 and c:get(x, y) == R.straw.base then l[#l + 1] = { x, y } end end)
  for _, q in ipairs(l) do c:put(q[1], q[2], R.straw.shade) end
  part(c, c:rect(23, 28 + b, 41, 30 + b), R.ribbon, { band = 1 })
  c:fillMask(c:line({ { 40, 29 + b }, { 44, 21 + b } }, 1), R.leaf.deep)
  part(c, c:ellipse(45, 21 + b, 1.5, 1), R.leaf, { rim = true }) part(c, c:ellipse(42, 23 + b, 1.5, 1), R.leaf, { rim = true })
  part(c, c:ellipse(45, 25 + b, 1.5, 1), R.leaf)
end
V.front = function(c, b, p) -- garden trowel in the right hand, soil on the tip
  part(c, c:rect(43, 63 + b, 45, 68 + b), R.wood, { band = 1, rim = true })
  part(c, c:rect(43, 69 + b, 45, 69 + b), R.steel, { band = 1 })
  local bl = c:poly{ { 41, 70 + b }, { 47, 70 + b }, { 46, 76 + b }, { 44, 79 + b }, { 42, 76 + b } }
  part(c, bl, R.steel, { band = 1, rim = true })
  for y = 71, 76 do c:put(44, y + b, R.steel.shade) end
  c:put(44, 79 + b, R.wood.shade) c:put(43, 78 + b, R.wood.shade) c:put(44, 78 + b, R.wood.deep)
  part(c, c:ellipse(44, 67 + b, 2.5, 2), R.body, { band = 1, rim = true })
end

local function eye(c, x, y, blink)
  if blink then for i = 0, 3 do c:put(x + i, y + 2, INK) end return end
  c:put(x + 1, y, INK) c:put(x + 2, y, INK)
  for _, q in ipairs{ { 0, 1 }, { 3, 1 }, { 0, 2 }, { 3, 2 }, { 1, 3 }, { 2, 3 }, { 1, 1 } } do c:put(x + q[1], y + q[2], P.cream) end
  c:put(x + 2, y + 1, INK) c:put(x + 1, y + 2, INK) c:put(x + 2, y + 2, INK)
end
local function draw(p)
  local c = HP.canvas{ w = 64, h = 96, name = NAME }
  local b = p.bob or 0
  c:groundShadow(32, 90, 14, 3)
  V.back(c, b, p)
  for _, fx in ipairs{ 27, 37 } do -- thin insect legs + round feet (never move)
    part(c, c:rect(fx - 1, 82, fx, 88), R.leg, { band = 1 })
    local f = c:ellipse(fx + (fx < 32 and -1 or 1), 88.5, 3.5, 2)
    part(c, f, R.leg, { band = 1, rim = true, ud = true })
  end
  local body = c:ellipse(32, 72 + b, 11, 13)
  for _, q in ipairs{ { 21, 66 }, { 43, 66 }, { 21.5, 74 }, { 42.5, 74 }, { 24, 82 }, { 40, 82 } } do body:add(HP.ellipse(q[1], q[2] + b, 1.5, 1.5)) end
  part(c, body, R.body, { band = 2, rim = true })
  for _, yy in ipairs{ 70, 76, 81 } do
    local l = {} body:each(function(x, y) if y == yy + b and x % 3 ~= 0 and c:get(x, y) == R.body.base then l[#l + 1] = { x, y } end end)
    for _, q in ipairs(l) do c:put(q[1], q[2], R.body.shade) end
  end
  under(c, body, R.body.deep)
  V.clothes(c, b, p, body)
  for _, ax in ipairs{ 20, 44 } do part(c, c:ellipse(ax, 67 + b, 3, 4.5), R.body, { band = 1, rim = ax < 32, ud = true }) end
  local ruff = c:ellipse(32, 55 + b, 13, 3.5)
  for x = 20, 44, 4 do ruff:add(HP.ellipse(x, 58 + b, 2, 2)) end
  part(c, ruff, R.ruff, { band = 1, rim = true })
  if V.neck then V.neck(c, b, p) end
  local head = c:ellipse(32, 41 + b, 15, 13)
  for i = 0, 6 do local a = math.rad(200 + i * 23) head:add(HP.ellipse(32 + math.cos(a) * 14.5, 41 + b + math.sin(a) * 12.5, 2, 2)) end
  part(c, head, R.fur, { band = 2, rim = true, ud = true })
  for _, q in ipairs{ { 24, 31 }, { 30, 30 }, { 36, 30 }, { 41, 33 }, { 20, 38 }, { 44, 40 }, { 25, 32 }, { 37, 31 } } do
    if c:get(q[1], q[2] + b) == R.fur.base then c:put(q[1], q[2] + b, R.fur.shade) end end
  for _, ex in ipairs{ 24, 37 } do c:fillMask(c:ellipse(ex + 1.5, 43 + b, 3.5, 3), R.socket) end
  eye(c, 24, 41 + b, p.blink) eye(c, 37, 41 + b, p.blink)
  for _, q in ipairs{ { 31, 47 }, { 32, 47 }, { 33, 47 }, { 33, 48 }, { 31, 49 }, { 32, 49 } } do c:put(q[1], q[2] + b, R.nose.base) end
  c:put(31, 47 + b, R.nose.hi) c:put(32, 48 + b, R.nose.deep)
  for _, q in ipairs{ { 29, 51 }, { 30, 52 }, { 31, 52 }, { 32, 52 }, { 33, 52 }, { 34, 51 } } do c:put(q[1], q[2] + b, INK) end
  c:cheek(20, 47 + b) c:cheek(42, 47 + b)
  V.hat(c, b, p)
  for i, a in ipairs(V.ant) do
    local tx, ty = a[3], a[4] + b + (p.at or 0)
    if i == 2 and p.tw then tx, ty = tx + 1, ty - 1 end
    frond(c, a[1], a[2] + b, tx, ty, a[5], R.ant)
  end
  V.front(c, b, p)
  c:finish{ outline = true }
  HP.assertClean(c)
  return c
end
local frames = {}
for _, p in ipairs{ { bob = 0 }, { bob = 1, at = 1 }, { bob = 0 }, { bob = 0, blink = true, tw = true } } do frames[#frames + 1] = draw(p) end
local W, H = 64, 96
local pc = app.pixelColor
local function rgba(h) return pc.rgba(tonumber(h:sub(2, 3), 16), tonumber(h:sub(4, 5), 16), tonumber(h:sub(6, 7), 16), 255) end
local spr = Sprite(W, H, ColorMode.RGB)
for _ = 2, 4 do spr:newEmptyFrame() end
local strip = Image(W * 4, H, ColorMode.RGB) strip:clear(pc.rgba(0, 0, 0, 0))
for f, c in ipairs(frames) do
  local im = Image(W, H, ColorMode.RGB) im:clear(pc.rgba(0, 0, 0, 0))
  for i, hex in pairs(c.pix) do im:putPixel(i % W, i // W, rgba(hex)) end
  spr:newCel(spr.layers[1], spr.frames[f], im, Point(0, 0))
  strip:drawImage(im, Point((f - 1) * W, 0))
end
spr.layers[1].name = NAME
local tg = spr:newTag(1, 4) tg.name = "idle"
spr:saveAs(out .. NAME .. ".aseprite") spr:close()
local s2 = Sprite(W * 4, H, ColorMode.RGB) s2.cels[1].image = strip
s2:saveCopyAs(out .. NAME .. ".png") s2:close()
print(NAME .. " sprite ok")
