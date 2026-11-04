-- folk-gecko-3 sprite (folk F2_11) variant: 3
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
local S = R("#f0d2e6", "#c29ccc", "#8a74a8", "#584e7e")
local SPOT, MOUTH, PETAL = "#f6e2c8", "#4a2850", "#f07890"
local SMOCK = R("#96d0f2", "#4e90d4", "#3a5ca6", "#283c74")
local APRON = R("#fbf0d4", "#ead9b2", "#bfae98", "#857a86")
local KERCH = R("#ff8a7a", "#e04c50", "#a83048", "#6c2040")
local COPPER = R("#ffc08a", "#e0804a", "#a8523e", "#6c3238")
local SOUP = R("#f8c868", "#d8963a", "#a8643a", "#6c3a38")
local BG = R("#c4e6f2", "#a8d8e8", "#7aaed0", "#5a7eaa")
local ARM, BODY = SMOCK, SMOCK
local NAME = "folk-gecko-3"
local IDLE = { { b = 0 }, { b = 1, hs = 1, tt = 1 }, { b = 0 }, { b = 0, blink = true, tw = 1, tt = -1 } }
local function back(c, p, b)
  local t = c:line({ { 27, 82 }, { 19, 81 + b }, { 15, 75 + b }, { 16, 69 + b } }, 4)
  t:add(c:line({ { 16, 69 + b }, { 19, 66 + b }, { 22, 67 + b }, { 21, 70 + b + (p.tt or 0) } }, 2))
  c:part(t, S, { band = 1, pop = { x = 15, y = 72 + b } })
  dots(c, t, { { 16, 74 + b }, { 18, 79 + b }, { 17, 68 + b } }, SPOT)
end
local function clothes(c, p, b, torso)
  c:part(torso, SMOCK, { band = 2, pop = { x = 26, y = 67 + b } })
  local ap = c:rrect(25, 67 + b, 39, 85 + b, 2)
  c:part(ap, APRON, { band = 2, pop = { x = 26, y = 68 + b } })
  for x = 28, 36 do c:px(x, 76 + b, APRON.shade) end
  for y = 76, 80 do c:px(28, y + b, APRON.shade) c:px(36, y + b, APRON.shade) end
  c:px(32, 77 + b, APRON.shade) c:px(32, 78 + b, APRON.shade)
  c:part(c:rect(21, 72 + b, 24, 73 + b), APRON, { band = 1, nopop = true })
end
local function prop(c, p, b)
  local s = p.tw or 0
  c:part(c:line({ { 44, 76 + b }, { 45, 64 + b } }, 2), COPPER, { band = 1, nopop = true })
  c:part(c:ellipse(46 + s, 61 + b, 3.5, 2.5), COPPER, { band = 1, pop = { x = 44 + s, y = 60 + b } })
  c:part(c:ellipse(46 + s, 60.5 + b, 2, 1), SOUP, { band = 1, nopop = true })
end
local function deco_pre(c, p, b)
  local m = HP.mask()
  for a = 150, 215, 13 do m:add(spike(c, 32, 49 + b, 15, 11, a, 3)) end
  for a = -35, 30, 13 do m:add(spike(c, 32, 49 + b, 15, 11, a, 3)) end
  for _, a in ipairs{ 200, 235 } do m:add(spike(c, 24, 43 + b, 4.2, 4.2, a, 2.5)) end
  for _, a in ipairs{ 305, 340 } do m:add(spike(c, 40, 43 + b, 4.2, 4.2, a, 2.5)) end
  c:part(m, S, { band = 1, nopop = true })
end
local function deco(c, p, b, head)
  dots(c, head, { { 18, 50 + b }, { 19, 53 + b }, { 46, 50 + b }, { 45, 53 + b }, { 21, 47 + b }, { 43, 47 + b } }, SPOT)
end
local function hat(c, p, b)
  local hs = p.hs or 0
  local k = c:ellipse(32, 40 + b, 9, 5) k:clip(c:rect(0, 0, 63, 40 + b))
  k:add(c:ellipse(41, 34 + b + hs, 2.5, 2)) k:add(c:ellipse(44, 32 + b + hs, 2, 1.5))
  c:part(k, KERCH, { band = 1, pop = { x = 26, y = 37 + b } })
  dots(c, k, { { 28, 37 + b }, { 32, 36 + b }, { 36, 38 + b }, { 30, 39 + b }, { 34, 40 + b }, { 44, 32 + b + hs } }, SPOT)
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
