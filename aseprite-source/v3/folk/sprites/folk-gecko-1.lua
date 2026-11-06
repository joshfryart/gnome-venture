-- folk-gecko-1 sprite (folk F2_11) variant: 1
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
local S = R("#ffcf8e", "#f29a52", "#b8604c", "#7a3a4c")
local SPOT, MOUTH, PETAL = "#8a4058", "#5a2440", "#f58a8a"
local STRAW = R("#fbe9a6", "#e6c766", "#b48f56", "#7c5e4e")
local BAND = R("#f07a5a", "#d0463a", "#9a2e3e", "#621e36")
local OVR = R("#a6dc72", "#5fae4c", "#3d7c4c", "#285450")
local WOOD = R("#e0a870", "#b47448", "#80504a", "#523640")
local METAL = R("#e4ecf0", "#a8b8c8", "#7080a0", "#4a5070")
local LEAF = R("#b8e880", "#78c050", "#4a8848", "#2e5a44")
local GOLD = R("#ffe08a", "#f0b840", "#b87c3a", "#7a4c38")
local BG = R("#e8f2b0", "#d6e49a", "#adc070", "#7c9058")
local ARM, BODY = S, S
local deco_pre = noop
local NAME = "folk-gecko-1"
local IDLE = { { b = 0 }, { b = 1, hs = 1, tt = 1 }, { b = 0 }, { b = 0, blink = true, tt = -1, tw = 1 } }
local function back(c, p, b)
  local t = c:line({ { 27, 84 }, { 20, 87 }, { 14, 86 }, { 11, 83 } }, 4)
  t:add(c:line({ { 11, 83 }, { 12, 80 }, { 15, 79 + (p.tt or 0) } }, 2))
  c:part(t, S, { band = 1, pop = { x = 18, y = 85 } })
  dots(c, t, { { 22, 86 }, { 16, 86 }, { 12, 84 }, { 12, 81 } }, SPOT)
end
local function clothes(c, p, b, torso)
  local ov = torso:copy() ov:clip(c:rect(0, 72 + b, 63, 95))
  ov:add(c:rect(26, 66 + b, 38, 72 + b))
  ov:add(c:line({ { 27, 66 + b }, { 24, 63 + b } }, 2)) ov:add(c:line({ { 37, 66 + b }, { 40, 63 + b } }, 2))
  ov:add(c:rect(25, 82, 28, 83)) ov:add(c:rect(36, 82, 39, 83))
  c:part(ov, OVR, { band = 2, pop = { x = 27, y = 67 + b } })
  for x = 29, 35 do c:px(x, 74 + b, OVR.shade) end
  for y = 74, 77 do c:px(29, y + b, OVR.shade) c:px(35, y + b, OVR.shade) end
  c:px(27, 67 + b, GOLD.base) c:px(37, 67 + b, GOLD.base)
  dots(c, torso, { { 24, 67 + b }, { 39, 66 + b }, { 22, 72 + b } }, SPOT)
end
local function prop(c, p, b)
  c:part(c:rect(43, 70 + b, 44, 76 + b), WOOD, { band = 1, nopop = true })
  local tw = p.tw or 0
  c:part(c:rect(42, 77 + b, 45, 77 + b), METAL, { band = 1, nopop = true })
  local bl = c:poly{ { 41, 78 + b }, { 47, 78 + b }, { 44 + tw, 85 + b } }
  c:part(bl, METAL, { band = 1, pop = { x = 42, y = 79 + b } })
  c:px(44, 80 + b, METAL.shade) c:px(44, 81 + b, METAL.shade)
end
local function deco(c, p, b, head)
  dots(c, head, { { 19, 48 + b }, { 25, 50 + b }, { 39, 49 + b }, { 45, 48 + b }, { 30, 46 + b }, { 35, 46 + b }, { 17, 52 + b }, { 47, 52 + b }, { 42, 53 + b }, { 22, 53 + b }, { 32, 49 + b } }, SPOT)
end
local function hat(c, p, b)
  local hs = p.hs or 0
  local brim = c:ellipse(32, 36 + b, 18, 3.5)
  if hs > 0 then brim:add(c:rect(14, 37 + b, 16, 38 + b)) brim:add(c:rect(48, 37 + b, 50, 38 + b)) end
  c:part(brim, STRAW, { band = 1, pop = { x = 19, y = 35 + b } })
  for x = 16, 48, 3 do if brim:has(x, 37 + b) then c:px(x, 37 + b, STRAW.shade) end end
  local crown = c:rrect(25, 25 + b, 39, 35 + b, 4)
  c:part(crown, STRAW, { band = 2, pop = { x = 27, y = 27 + b } })
  for y = 27, 31, 2 do for x = 26 + (y % 4 == 3 and 1 or 0), 38, 3 do if crown:has(x, y + b) then c:px(x, y + b, STRAW.shade) end end end
  for x = 25, 39 do c:px(x, 36 + b, STRAW.deep) end
  c:part(c:rect(25, 32 + b, 39, 34 + b), BAND, { band = 1, nopop = true })
  c:fillMask(c:line({ { 27, 32 + b }, { 23, 29 + b + hs }, { 21, 27 + b + hs } }, 1), LEAF.deep)
  c:part(c:ellipse(20.5, 26 + b + hs, 2, 1.5), LEAF, { band = 1, nopop = true })
  c:part(c:ellipse(25, 28 + b + hs, 1.5, 1.2), LEAF, { band = 1, nopop = true })
  c:px(19, 26 + b + hs, LEAF.hi)
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
