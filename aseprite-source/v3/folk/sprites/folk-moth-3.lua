-- folk-moth-3 sprite (folk F2_5) variant: 3
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
V.ant = { { 28, 30, 22, 11, 2.5 }, { 36, 30, 42, 11, 2.5 } }
V.back = function(c, b, p) -- broad rounded atlas-style wings with hooked tips, dark band, cream windows
  local w = c:ellipse(14, 63 + b, 10, 12) w:add(c:ellipse(50, 63 + b, 10, 12))
  w:add(c:ellipse(7, 52 + b, 3.5, 3)) w:add(c:ellipse(57, 52 + b, 3.5, 3))
  w:add(c:poly{ { 20, 52 + b }, { 44, 52 + b }, { 46, 70 + b }, { 18, 70 + b } })
  part(c, w, R.wing, { band = 2, rim = true, ud = true })
  c:fillMask(c:line({ { 6, 58 + b }, { 20, 74 + b } }, 1):clip(w), R.wing.deep)
  c:fillMask(c:line({ { 58, 58 + b }, { 44, 74 + b } }, 1):clip(w), R.wing.deep)
  for _, q in ipairs{ { 12, 63 }, { 52, 63 } } do
    c:fillMask(c:poly{ { q[1] - 2, q[2] - 2 + b }, { q[1] + 2, q[2] - 1 + b }, { q[1], q[2] + 2 + b } }, R.window) end
end
V.clothes = function(c, b, p, body) -- cream apron with pocket; quirk: a nibbled hole in its own apron
  local a = c:rrect(25, 60 + b, 39, 85 + b, 3)
  a:cut(HP.ellipse(38, 85 + b, 1.5, 1.5))
  part(c, a, R.apron, { band = 2, rim = true, ud = true })
  part(c, c:line({ { 26, 61 + b }, { 23, 57 + b } }, 2), R.apron, { band = 1 })
  part(c, c:line({ { 38, 61 + b }, { 41, 57 + b } }, 2), R.apron, { band = 1 })
  part(c, c:rect(21, 70 + b, 43, 71 + b), R.apron, { band = 1 })
  part(c, c:rrect(28, 75 + b, 36, 80 + b, 1), R.apron, { band = 1 })
  c:stitch{ { 29, 76 + b }, { 35, 76 + b } }
  c:put(30, 64 + b, R.body.shade) c:put(31, 64 + b, R.body.shade) c:put(31, 65 + b, R.body.deep)
end
V.hat = function(c, b, p) -- lilac polka-dot kerchief knotted on the right
  local k = c:ellipse(32, 41 + b, 15.5, 13.5):clip(c:rect(0, 0, 63, 33 + b))
  k:add(c:rrect(17, 31 + b, 47, 35 + b, 2))
  part(c, k, R.kerchief, { band = 2, rim = true, ud = true })
  local l = {}
  k:each(function(x, y) if x % 4 == 0 and (y - b) % 4 == ((x % 8 == 0) and 0 or 2) and c:get(x, y) == R.kerchief.base then l[#l + 1] = { x, y } end end)
  for _, q in ipairs(l) do c:put(q[1], q[2], R.apron.hi) end
  part(c, c:poly{ { 48, 34 + b }, { 54, 37 + b }, { 51, 40 + b } }, R.kerchief, { band = 1 })
  part(c, c:ellipse(47, 34 + b, 2.5, 2), R.kerchief, { band = 1, rim = true })
end
V.front = function(c, b, p) -- knitting: needles + swatch in hand, yarn ball on the ground
  local ball = c:ellipse(49, 86, 3.5, 3.5)
  part(c, ball, R.yarn, { band = 1, rim = true, ud = true })
  c:fillMask(c:line({ { 47, 84 }, { 51, 87 } }, 1):clip(ball), R.yarn.shade)
  c:fillMask(c:line({ { 46, 73 + b }, { 48, 79 + b }, { 49, 83 } }, 1), R.yarn.base)
  c:fillMask(c:line({ { 40, 74 + b }, { 49, 60 + b } }, 1), R.wood.base)
  c:fillMask(c:line({ { 43, 75 + b }, { 53, 63 + b } }, 1), R.wood.shade)
  c:put(49, 59 + b, R.gold.base) c:put(53, 62 + b, R.gold.base)
  local s = c:rrect(41, 66 + b, 48, 72 + b, 1)
  part(c, s, R.yarn, { band = 1, rim = true })
  for y = 67, 71, 2 do for x = 42, 47, 2 do c:put(x, y + b, R.yarn.shade) end end
  part(c, c:ellipse(43, 71 + b, 2, 2), R.body, { band = 1, rim = true })
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
