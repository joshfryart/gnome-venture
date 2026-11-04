-- folk-gecko-2 sprite (folk F2_11) variant: 2
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local out = app.params.out or (DIR .. "/")
local INK, CREAM = "#2b1c26", "#f6ecd2"
local function R(hi, base, shade, deep) return { hi = hi, base = base, shade = shade, deep = deep } end
local function dots(c, m, list, hex) for _, q in ipairs(list) do if m:has(q[1], q[2]) then c:px(q[1], q[2], hex) end end end
local function recol(c, m, from, to) local l = {} m:each(function(x, y) if c:get(x, y) == from then l[#l + 1] = { x, y } end end) for _, q in ipairs(l) do c:px(q[1], q[2], to) end end
local function spike(c, cx, cy, rx, ry, deg, len)
  local a = math.rad(deg)
  local ex, ey = cx + math.cos(a) * rx, cy + math.sin(a) * ry
  local nx, ny = -math.sin(a), math.cos(a)
  return c:poly{ { ex + nx * 1.6, ey + ny * 1.6 }, { ex - nx * 1.6, ey - ny * 1.6 }, { ex + math.cos(a) * len, ey + math.sin(a) * len } }
end
local function noop() end
local S = R("#c6f286", "#72cc56", "#3c8c5c", "#265a5e")
local SPOT, MOUTH, PETAL = "#e8583e", "#2e4048", "#f08aa0"
local TUNIC = R("#f6aa6a", "#d26c3c", "#9c4442", "#642c44")
local SCARF = R("#f392c0", "#c84c8c", "#8c2e74", "#5a2054")
local CAP = R("#d8a874", "#a0704c", "#6c4a4a", "#46303e")
local CANVAS = R("#f0dca6", "#cfb07a", "#9a7c5e", "#66504c")
local ROLL = R("#a6bce0", "#6c88c0", "#4c5c96", "#323c6c")
local BRASS = R("#ffe28c", "#e0aa3c", "#a8703a", "#6c4434")
local GLOW = R("#fff4c0", "#ffd36a", "#eaa64a", "#b06a3a")
local BG = R("#f4c8e0", "#e7b4d2", "#c088b2", "#8e5c8c")
local ARM, BODY = TUNIC, TUNIC
local deco_pre = noop
local NAME = "folk-gecko-2"
local IDLE = { { b = 0 }, { b = 1, hs = 1, tt = 1 }, { b = 0 }, { b = 0, blink = true, tw = 1, tt = -1 } }
local function back(c, p, b)
  local t = c:line({ { 37, 85 }, { 45, 87 }, { 52, 87 }, { 57, 85 } }, 4)
  t:add(c:line({ { 57, 85 }, { 59, 82 }, { 58, 80 + (p.tt or 0) } }, 2))
  c:part(t, S, { band = 1, pop = { x = 47, y = 86 } })
  dots(c, t, { { 49, 87 }, { 54, 86 }, { 58, 83 } }, SPOT)
  local hs = p.hs or 0
  local pk = c:rrect(11, 59 + b, 26, 79 + b, 3)
  c:part(pk, CANVAS, { band = 2, pop = { x = 13, y = 66 + b } })
  c:part(c:rrect(11, 59 + b, 26, 65 + b, 2), R(CANVAS.base, CANVAS.shade, CANVAS.deep, CANVAS.deep), { band = 1, nopop = true })
  c:px(18, 66 + b, BRASS.base) c:px(19, 66 + b, BRASS.base)
  local roll = c:ellipse(18.5, 57 + b + hs, 8.5, 3)
  c:part(roll, ROLL, { band = 1, pop = { x = 13, y = 56 + b + hs } })
  for y = 55, 59 do c:px(14, y + b + hs, ROLL.deep) c:px(23, y + b + hs, ROLL.deep) end
end
local function clothes(c, p, b, torso)
  c:part(torso, TUNIC, { band = 2, pop = { x = 26, y = 67 + b } })
  c:part(c:rect(22, 77 + b, 42, 78 + b), CAP, { band = 1, nopop = true })
  c:px(31, 77 + b, BRASS.hi) c:px(32, 77 + b, BRASS.base)
  c:part(c:line({ { 24, 64 + b }, { 27, 76 + b } }, 2), CANVAS, { band = 1, nopop = true })
  local hs = p.hs or 0
  c:part(c:rrect(20, 60 + b, 44, 64 + b, 2), SCARF, { band = 1, pop = { x = 23, y = 61 + b } })
  local tail = c:poly{ { 36, 63 + b }, { 41, 63 + b }, { 41 + hs, 72 + b }, { 36 + hs, 71 + b } }
  c:part(tail, SCARF, { band = 1, nopop = true })
  c:px(37 + hs, 72 + b, SCARF.shade) c:px(39 + hs, 72 + b, SCARF.shade)
end
local function prop(c, p, b)
  local s = p.tw or 0
  c:fillMask(c:line({ { 43, 76 + b }, { 44 + s, 79 + b } }, 1), BRASS.deep)
  c:part(c:rect(42 + s, 79 + b, 47 + s, 80 + b), BRASS, { band = 1, nopop = true })
  c:part(c:rect(42 + s, 81 + b, 47 + s, 85 + b), GLOW, { band = 1, pop = { x = 43 + s, y = 82 + b } })
  for y = 81, 85 do c:px(44 + s, y + b, BRASS.shade) end
  c:part(c:rect(41 + s, 86 + b, 48 + s, 86 + b), BRASS, { band = 1, nopop = true })
end
local function deco(c, p, b, head)
  dots(c, head, { { 27, 47 + b }, { 37, 47 + b }, { 32, 45 + b }, { 20, 50 + b }, { 44, 50 + b }, { 24, 52 + b }, { 40, 52 + b }, { 29, 50 + b }, { 35, 50 + b } }, SPOT)
end
local function hat(c, p, b)
  local dome = c:ellipse(32, 36 + b, 11, 6) dome:clip(c:rect(0, 0, 63, 36 + b))
  c:part(dome, CAP, { band = 2, pop = { x = 26, y = 32 + b } })
  for y = 31, 36 do c:px(32, y + b, CAP.shade) end
  c:px(32, 30 + b, CAP.hi) c:px(31, 30 + b, CAP.hi)
  c:part(c:ellipse(32, 38 + b, 10, 1.8), R(CAP.base, CAP.shade, CAP.deep, CAP.deep), { band = 1, nopop = true })
  c:px(26, 37 + b, SCARF.base) c:px(27, 37 + b, SCARF.base)
end
local function eye(c, x, y, S, bl)
  for i = 1, 3 do c:px(x + i, y - 1, S.deep) end
  if bl then for i = 0, 4 do c:px(x + i, y + 2, INK) end c:px(x, y + 1, INK) c:px(x + 4, y + 1, INK) return end
  for dy = 0, 4 do for dx = 0, 4 do if not ((dx == 0 or dx == 4) and (dy == 0 or dy == 4)) then c:px(x + dx, y + dy, CREAM) end end end
  for dy = 1, 3 do for dx = 1, 3 do c:px(x + dx, y + dy, INK) end end
  c:px(x + 1, y + 1, CREAM)
end
local function frame(p)
  local c = HP.canvas{ w = 64, h = 96, name = NAME }
  local b = p.b or 0
  c:groundShadow(32, 89.5, 13, 3)
  back(c, p, b)
  local legs = c:rect(25, 82, 28, 87) legs:add(c:rect(36, 82, 39, 87))
  c:part(legs, S, { band = 1, nopop = true })
  for _, fx in ipairs{ 26.5, 37.5 } do
    local f = c:ellipse(fx, 87.5, 3.5, 1.8)
    for _, tx in ipairs{ -3.5, -0.5, 2.5 } do local x = math.floor(fx + tx) f:add(c:rect(x, 89, x + 1, 90)) end
    c:part(f, S, { band = 1, nopop = true })
    for _, tx in ipairs{ -3.5, -0.5, 2.5 } do c:px(math.floor(fx + tx), 89, S.hi) end
  end
  local torso = c:ellipse(32, 74 + b, 10.5, 10)
  c:part(torso, S, { band = 2, pop = { x = 26, y = 67 + b } })
  clothes(c, p, b, torso)
  for _, ax in ipairs{ 20.5, 43.5 } do c:part(c:ellipse(ax, 71 + b, 2.5, 4.5), ARM, { band = 1, nopop = true }) end
  prop(c, p, b)
  for _, ax in ipairs{ 20.5, 43.5 } do
    local h = c:ellipse(ax, 76.5 + b, 2.5, 1.8)
    local x = math.floor(ax)
    h:add(c:rect(x - 2, 78 + b, x - 2, 78 + b)) h:add(c:rect(x, 78 + b, x, 78 + b)) h:add(c:rect(x + 2, 78 + b, x + 2, 78 + b))
    c:part(h, S, { band = 1, nopop = true })
    c:px(x - 2, 78 + b, S.hi) c:px(x, 78 + b, S.hi) c:px(x + 2, 78 + b, S.hi)
  end
  deco_pre(c, p, b)
  local head = c:ellipse(32, 49 + b, 15.5, 11.5)
  head:add(c:ellipse(24, 43 + b, 4.5, 4.5)) head:add(c:ellipse(40, 43 + b, 4.5, 4.5))
  c:part(head, S, { band = 2, pop = { x = 21, y = 40 + b } })
  recol(c, c:ellipse(32, 55 + b, 7, 2.5), S.base, S.hi)
  deco(c, p, b, head)
  c:px(30, 52 + b, S.deep) c:px(34, 52 + b, S.deep)
  c:fillMask(c:line({ { 22, 55 + b }, { 26, 57 + b }, { 32, 58 + b }, { 38, 57 + b }, { 42, 55 + b } }, 1), MOUTH)
  c:px(21, 54 + b, MOUTH) c:px(43, 54 + b, MOUTH)
  for _, q in ipairs{ { 19, 56 }, { 20, 56 }, { 44, 56 }, { 45, 56 } } do c:px(q[1], q[2] + b, PETAL) end
  eye(c, 22, 41 + b, S, p.blink) eye(c, 38, 41 + b, S, p.blink)
  hat(c, p, b)
  c:finish{ outline = true }
  HP.assertClean(c)
  return c
end
local frames = {}
for _, p in ipairs(IDLE) do frames[#frames + 1] = frame(p) end
local W, H = 64, 96
local pc = app.pixelColor
local function rgba(h) return pc.rgba(tonumber(h:sub(2, 3), 16), tonumber(h:sub(4, 5), 16), tonumber(h:sub(6, 7), 16), 255) end
local imgs = {}
for f, c in ipairs(frames) do
  local im = Image(W, H, ColorMode.RGB) im:clear(pc.rgba(0, 0, 0, 0))
  for i, hex in pairs(c.pix) do im:putPixel(i % W, i // W, rgba(hex)) end
  imgs[f] = im
end
local strip = Image(W * 4, H, ColorMode.RGB) strip:clear(pc.rgba(0, 0, 0, 0))
for f = 1, 4 do strip:drawImage(imgs[f], Point((f - 1) * W, 0)) end
local sp = Sprite(W * 4, H, ColorMode.RGB) sp.cels[1].image = strip sp:saveCopyAs(out .. NAME .. ".png") sp:close()
local spr = Sprite(W, H, ColorMode.RGB)
for _ = 2, 4 do spr:newEmptyFrame() end
for f = 1, 4 do spr:newCel(spr.layers[1], spr.frames[f], imgs[f], Point(0, 0)) spr.frames[f].duration = 0.25 end
local tg = spr:newTag(1, 4) tg.name = "idle"
spr:saveAs(out .. NAME .. ".aseprite") spr:close()
print(NAME .. " sprite ok")
