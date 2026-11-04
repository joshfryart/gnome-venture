-- folk-moth-2 sprite (folk F2_5) variant: 2
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
V.ant = { { 26, 31, 9, 21, 2 }, { 38, 31, 55, 21, 2 } }
V.back = function(c, b, p) -- small rosy wing tips under a big canvas pack with a bedroll
  local w = c:poly{ { 20, 66 + b }, { 44, 66 + b }, { 51, 84 + b }, { 13, 84 + b } }
  part(c, w, R.wing, { band = 2, ud = true })
  c:fillMask(w:copy():clip(c:rect(0, 76 + b, 63, 78 + b)), R.fur.base)
  part(c, c:rrect(15, 46 + b, 49, 72 + b, 5), R.pack, { band = 2, rim = true, ud = true })
  part(c, c:rrect(12, 41 + b, 52, 49 + b, 3), R.roll, { band = 2, rim = true, ud = true })
  for _, x in ipairs{ 16, 47 } do part(c, c:rect(x, 41 + b, x + 1, 49 + b), R.leather, { band = 1 }) end
  c:put(13, 44 + b, R.roll.deep) c:put(13, 45 + b, R.roll.deep)
end
V.clothes = function(c, b, p, body) -- yellow fuzz band + pack straps
  part(c, body:copy():clip(c:rect(0, 74 + b, 63, 77 + b)), R.fur, { band = 1 })
  part(c, c:line({ { 24, 59 + b }, { 23, 78 + b } }, 2), R.leather, { band = 1 })
  part(c, c:line({ { 40, 59 + b }, { 41, 78 + b } }, 2), R.leather, { band = 1 })
  c:put(23, 70 + b, R.gold.base) c:put(41, 70 + b, R.gold.base)
end
V.neck = function(c, b, p) -- striped teal scarf, tail over the right
  local s = c:rrect(19, 53 + b, 45, 58 + b, 2)
  s:add(c:line({ { 40, 57 + b }, { 43, 63 + b }, { 42, 69 + b } }, 4))
  part(c, s, R.scarf, { band = 2, rim = true, ud = true })
  for x = 21, 44, 4 do if s:has(x, 55 + b) then c:put(x, 55 + b, R.fur.base) c:put(x, 56 + b, R.fur.shade) end end
  c:put(41, 66 + b, R.fur.base) c:put(42, 66 + b, R.fur.base)
end
V.hat = function(c, b, p) -- soft plum traveller's cap with a forward peak
  local cr = c:ellipse(32, 31 + b, 13.5, 6.5)
  part(c, cr, R.cap, { band = 2, rim = true })
  c:fillMask(c:line({ { 32, 26 + b }, { 24, 35 + b } }, 1):clip(cr), R.cap.shade)
  c:fillMask(c:line({ { 32, 26 + b }, { 40, 35 + b } }, 1):clip(cr), R.cap.shade)
  part(c, c:ellipse(32, 37 + b, 9.5, 2.5), R.cap, { band = 1, ud = true })
  c:put(32, 25 + b, R.gold.base) c:put(31, 25 + b, R.gold.hi)
end
V.front = function(c, b, p) -- glowing lantern swinging from the left hand (moth + lamp)
  local sw = p.tw and 1 or 0
  c:fillMask(c:line({ { 20, 71 + b }, { 20 + sw, 74 + b } }, 1), R.metal.deep)
  part(c, c:rect(17 + sw, 74 + b, 23 + sw, 75 + b), R.metal, { band = 1, rim = true })
  part(c, c:rrect(17 + sw, 76 + b, 23 + sw, 82 + b, 1), R.glow, { band = 1, rim = true })
  c:fillMask(c:ellipse(20 + sw, 79 + b, 1, 1.5), R.glow.hi)
  part(c, c:rect(17 + sw, 83 + b, 23 + sw, 84 + b), R.metal, { band = 1 })
  part(c, c:ellipse(20, 69 + b, 2.5, 2), R.body, { band = 1, rim = true })
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
