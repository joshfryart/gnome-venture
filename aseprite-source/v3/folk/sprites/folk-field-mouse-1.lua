-- folk-field-mouse-1 sprite (folk F1_1) variant: 1
local NAME = "folk-field-mouse-1"
-- Field mouse villager: big round ears with pink lining, pointed cream muzzle, pink nose, whiskers, long thin tail.
local HP = dofile("/home/user/gnome-venture/aseprite-source/v3/lib/hp.lua")
local P = HP.P
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") or "."
local out = app.params.out or (DIR .. "/")
local INK = "#2b1c26"
local EAR = { hi = "#f8c4c0", base = "#eb9a9e", shade = "#bc6c88", deep = "#7c4a66" }
local PAW = { hi = "#f8d0c0", base = "#e8a898", shade = "#b87888", deep = "#7a4a62" }
local TAIL = { hi = "#e8b8a8", base = "#c98e84", shade = "#94607a", deep = "#5e3e58" }
local CREAM = { hi = "#fff2de", base = "#f2dcba", shade = "#c8a898", deep = "#8a6c80" }
local NOSE = { hi = "#ffc0cc", base = "#e86c8c", shade = "#b04870", deep = "#6e2c50" }
local METAL = { hi = "#eef2f4", base = "#b8c2d0", shade = "#7a86a4", deep = "#4c5276" }
local function F(c, m, r, band) c:part(m, r, { band = band or 2, nopop = true }) return m end
local function low(c, m, hex) local l = {} m:each(function(x, y) if not m:has(x, y + 1) then l[#l + 1] = { x, y } end end) for _, q in ipairs(l) do c:put(q[1], q[2], hex) end end
local function onCol(c, m, from, to, test) local l = {} m:each(function(x, y) if c:get(x, y) == from and (not test or test(x, y)) then l[#l + 1] = { x, y } end end) for _, q in ipairs(l) do c:put(q[1], q[2], to) end end
local FUR = { hi = "#ecc080", base = "#cf9450", shade = "#946048", deep = "#5c3c4a" }
local DUNG = { hi = "#b0d878", base = "#78b04c", shade = "#4a7c4c", deep = "#2e4e46" }
local STRAW = { hi = "#fbe6a0", base = "#e8c262", shade = "#b48a4c", deep = "#705446" }
local BAND = { hi = "#f08a7a", base = "#d85a52", shade = "#9c3c4c", deep = "#5e2a40" }
local WOOD = { hi = "#d8a070", base = "#a8704a", shade = "#74483e", deep = "#4a2e36" }
local V = { BG = { base = "#a9d08c", shade = "#80ae74", deep = "#5a8a62" } }
local function hat(c, cx, by, brx, bry, crx, cry, cyo)
  local brim = c:ellipse(cx, by, brx, bry) F(c, brim, STRAW, 2) low(c, brim, STRAW.deep)
  onCol(c, brim, STRAW.base, STRAW.shade, function(x, y) return (x + y * 2) % 5 == 0 end)
  local crown = c:ellipse(cx, by - cyo, crx, cry):clip(c:rect(0, 0, 79, by + 1)) F(c, crown, STRAW, 2)
  local bl = {} crown:each(function(x, y) if not crown:has(x, y + 1) or not crown:has(x, y + 2) then bl[#bl + 1] = { x, y } end end)
  for _, q in ipairs(bl) do c:put(q[1], q[2], q[1] > cx + crx * 0.4 and BAND.shade or BAND.base) end
  return crown
end
V.S = {
  clothes = function(c, p, b, body)
    local m = body:copy():clip(c:rect(0, 75 + b, 63, 95)) m:add(c:rrect(27, 67 + b, 37, 75 + b, 1)) F(c, m, DUNG, 2)
    F(c, c:line({ { 28, 68 + b }, { 24, 63 + b } }, 2), DUNG, 1) F(c, c:line({ { 36, 68 + b }, { 40, 63 + b } }, 2), DUNG, 1)
    c:put(28, 68 + b, STRAW.hi) c:put(36, 68 + b, STRAW.hi)
    for x = 30, 34 do c:put(x, 71 + b, DUNG.shade) end c:put(30, 72 + b, DUNG.shade) c:put(34, 72 + b, DUNG.shade)
  end,
  head = function(c, p, b)
    hat(c, 32, 40 + b, 16, 4.5, 8, 5, 3)
    c:put(38, 39 + b, P.cream) c:put(40, 39 + b, P.cream) c:put(39, 38 + b, P.cream) c:put(39, 40 + b, P.cream) c:put(39, 39 + b, STRAW.hi)
  end,
  prop = function(c, p, b)
    F(c, c:rect(45, 75 + b, 47, 81 + b), WOOD, 1)
    local bl = c:poly{ { 43, 74 + b }, { 49, 74 + b }, { 49, 68 + b }, { 46, 62 + b }, { 43, 68 + b } }
    F(c, bl, METAL, 2) c:put(44, 67 + b, METAL.hi) c:put(44, 68 + b, METAL.hi)
    c:put(47, 64 + b + (p.pr or 0), WOOD.shade) c:put(48, 65 + b, WOOD.shade)
  end,
}
V.P = {
  clothes = function(c, body)
    F(c, c:rrect(27, 80, 52, 99, 3):clip(body), DUNG, 2)
    F(c, c:line({ { 29, 82 }, { 24, 70 } }, 3):clip(body), DUNG, 1) F(c, c:line({ { 50, 82 }, { 55, 70 } }, 3):clip(body), DUNG, 1)
    for _, x in ipairs{ 29, 49 } do F(c, c:rect(x, 82, x + 1, 83), STRAW, 1) end
    c:stitch{ { 33, 89 }, { 46, 89 } }
    for y = 89, 96 do c:put(33, y, DUNG.shade) c:put(46, y, DUNG.shade) end for x = 33, 46 do c:put(x, 89, DUNG.shade) end
  end,
  head = function(c)
    hat(c, 39.5, 35, 26, 6.5, 13, 9, 5)
    for _, q in ipairs{ { 48, 30 }, { 50, 30 }, { 49, 29 }, { 49, 31 } } do c:put(q[1], q[2], P.cream) end c:put(49, 30, STRAW.hi)
  end,
  prop = function(c)
    F(c, c:rect(60, 84, 63, 97), WOOD, 1)
    F(c, c:poly{ { 57, 83 }, { 66, 83 }, { 66, 74 }, { 61.5, 64 }, { 57, 74 } }, METAL, 2)
    for y = 70, 79 do c:put(59, y, METAL.hi) end
    F(c, c:ellipse(64, 68, 1.5, 1.5), WOOD, 1)
    F(c, c:ellipse(61.5, 87, 4, 3), PAW, 1)
  end,
}
local SV = V.S
local function eye(c, x, y, blink)
  if blink then for i = 0, 3 do c:put(x + i, y + 2, INK) end c:put(x, y + 1, INK) c:put(x + 3, y + 1, INK) return end
  c:put(x + 1, y, INK) c:put(x + 2, y, INK)
  for _, q in ipairs{ { 0, 1 }, { 3, 1 }, { 0, 2 }, { 3, 2 }, { 1, 3 }, { 2, 3 } } do c:put(x + q[1], y + q[2], P.cream) end
  c:put(x + 1, y + 1, P.cream) c:put(x + 2, y + 1, INK) c:put(x + 1, y + 2, INK) c:put(x + 2, y + 2, INK)
end
local function frame(p)
  local c = HP.canvas{ w = 64, h = 96, name = NAME }
  local b = p.bob or 0
  c:groundShadow(32, 89.5, 13, 3)
  if SV.back then SV.back(c, p, b) end
  local t = p.tail or 0
  F(c, c:line({ { 40, 82 + b }, { 47, 86 }, { 53, 84 }, { 56, 79 + t }, { 54 + t, 75 + t } }, 2), TAIL, 1)
  local body = c:ellipse(32, 74 + b, 11, 12) F(c, body, FUR, 3)
  F(c, c:ellipse(32, 76 + b, 6, 8):clip(body), CREAM, 2)
  if SV.clothes then SV.clothes(c, p, b, body) end
  local function arm(x) F(c, c:ellipse(x, 72 + b, 2.5, 4), V.SLEEVE or FUR, 1) F(c, c:ellipse(x, 76 + b, 2, 1.5), PAW, 1) end
  arm(20)
  if SV.prop then SV.prop(c, p, b) end
  arm(44)
  for _, x in ipairs{ 27, 37 } do local m = c:ellipse(x, 88, 3.5, 2) F(c, m, PAW, 1) low(c, m, PAW.deep) c:put(x - 1, 87, PAW.shade) c:put(x + 1, 87, PAW.shade) end
  local function ear(cx, dir, tw)
    local ey = 37 + b + (p.es or 0)
    F(c, c:ellipse(cx + dir * tw, ey, 7.5, 7), FUR, 2)
    F(c, c:ellipse(cx + dir * tw, ey + 1, 5, 4.5), EAR, 2)
  end
  ear(19, -1, p.twL or 0) ear(45, 1, p.twR or 0)
  local head = c:ellipse(32, 49 + b, 14, 12) F(c, head, FUR, 3)
  c:put(24, 40 + b, FUR.hi) c:put(25, 40 + b, FUR.hi) c:put(23, 41 + b, FUR.hi)
  F(c, c:ellipse(32, 56 + b, 6.5, 4), CREAM, 1)
  F(c, c:ellipse(32, 54 + b, 2, 1.5), NOSE, 1) c:put(31, 53 + b, NOSE.hi)
  c:put(32, 57 + b, INK) c:put(31, 58 + b, INK) c:put(33, 58 + b, INK)
  eye(c, 24, 47 + b, p.blink) eye(c, 37, 47 + b, p.blink)
  c:cheek(21, 54 + b) c:cheek(42, 54 + b)
  if SV.head then SV.head(c, p, b) end
  c:finish{ outline = true }
  for _, w in ipairs{ { 26, 55, 16, 53 }, { 26, 57, 16, 59 }, { 38, 55, 48, 53 }, { 38, 57, 48, 59 } } do
    c:fillMask(c:line({ { w[1], w[2] + b }, { w[3], w[4] + b } }, 1), FUR.deep)
  end
  HP.assertClean(c)
  return c
end
local IDLE = { { bob = 0 }, { bob = 1, es = 1, tail = 1, pr = 1 }, { bob = 0 }, { bob = 0, blink = true, twR = 1, sw = 1 } }
local frames = {}
for _, p in ipairs(IDLE) do frames[#frames + 1] = frame(p) end
local W, H, N = 64, 96, #frames
local pc = app.pixelColor
local function rgba(h) return pc.rgba(tonumber(h:sub(2, 3), 16), tonumber(h:sub(4, 5), 16), tonumber(h:sub(6, 7), 16), 255) end
local imgs = {}
for f, c in ipairs(frames) do
  local im = Image(W, H, ColorMode.RGB) im:clear(pc.rgba(0, 0, 0, 0))
  for i, hex in pairs(c.pix) do im:putPixel(i % W, i // W, rgba(hex)) end
  imgs[f] = im
end
local strip = Image(W * N, H, ColorMode.RGB) strip:clear(pc.rgba(0, 0, 0, 0))
for f = 1, N do strip:drawImage(imgs[f], Point((f - 1) * W, 0)) end
local s1 = Sprite(W * N, H, ColorMode.RGB) s1.cels[1].image = strip s1:saveCopyAs(out .. NAME .. ".png") s1:close()
local spr = Sprite(W, H, ColorMode.RGB)
for _ = 2, N do spr:newEmptyFrame() end
local ly = spr.layers[1] ly.name = NAME
for f = 1, N do spr:newCel(ly, spr.frames[f], imgs[f], Point(0, 0)) end
local tg = spr:newTag(1, N) tg.name = "idle"
spr:saveAs(out .. NAME .. ".aseprite") spr:close()
print(NAME .. " sprite ok")
