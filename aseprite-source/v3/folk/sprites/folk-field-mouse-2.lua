-- folk-field-mouse-2 sprite (folk F1_1) variant: 2
local NAME = "folk-field-mouse-2"
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
local FUR = { hi = "#d2bca4", base = "#a48a74", shade = "#6e5c68", deep = "#46394c" }
local SCARF = { hi = "#f08a6a", base = "#d4503e", shade = "#9a3448", deep = "#5e2640" }
local CAP = { hi = "#7ad0c8", base = "#3e9ea0", shade = "#2e6e80", deep = "#24465e" }
local CAPV = { hi = CAP.base, base = CAP.shade, shade = CAP.deep, deep = CAP.deep }
local PACK = { hi = "#d49a64", base = "#a86a40", shade = "#74463c", deep = "#4a2c34" }
local ROLL = { hi = "#f4d890", base = "#d8b058", shade = "#a07848", deep = "#664a44" }
local IRON = { hi = "#a8a0b8", base = "#706a88", shade = "#4a4664", deep = "#2f2c44" }
local GLOW = { hi = "#fff4b0", base = "#ffd860", shade = "#f0a040", deep = "#b06838" }
local V = { BG = { base = "#9ccbe2", shade = "#74a6cc", deep = "#527ca6" } }
local function lantern(c, cx, top, w, h)
  local x0, x1 = math.floor(cx - w / 2 + 0.5), math.floor(cx + w / 2 - 0.5)
  F(c, c:rect(x0 + 1, top, x1 - 1, top + 1), IRON, 1)
  local g = c:rect(x0, top + 2, x1, top + h - 2) F(c, g, GLOW, 2)
  for y = top + 2, top + h - 2 do c:put(x0, y, IRON.base) c:put(x1, y, IRON.shade) end
  F(c, c:rect(x0, top + h - 1, x1, top + h), IRON, 1)
  c:put(x0 + 1, top + 3, GLOW.hi) c:put(x0 + 1, top + 4, GLOW.hi)
end
V.S = {
  back = function(c, p, b)
    local pk = c:rrect(18, 63 + b, 46, 82 + b, 4) F(c, pk, PACK, 2)
    local r = c:ellipse(32, 62 + b, 15, 3) F(c, r, ROLL, 1)
    for _, x in ipairs{ 20, 44 } do for y = 60, 64 do if r:has(x, y + b) then c:put(x, y + b, PACK.deep) end end end
  end,
  clothes = function(c, p, b, body)
    F(c, c:line({ { 24, 63 + b }, { 25, 79 + b } }, 2), PACK, 1) F(c, c:line({ { 40, 63 + b }, { 39, 79 + b } }, 2), PACK, 1)
    F(c, c:rrect(21, 59 + b, 43, 64 + b, 2), SCARF, 2)
    local t = c:poly{ { 23, 62 + b }, { 27, 62 + b }, { 26, 71 + b }, { 22, 70 + b } } F(c, t, SCARF, 1)
    c:put(23, 71 + b, SCARF.shade) c:put(25, 72 + b, SCARF.shade)
  end,
  head = function(c, p, b)
    F(c, c:ellipse(32, 40 + b, 9, 5):clip(c:rect(0, 0, 63, 42 + b)), CAP, 2)
    for x = 24, 40, 3 do c:put(x, 41 + b, CAP.shade) end
    F(c, c:ellipse(32, 43 + b, 7, 1.5), CAPV, 1)
    F(c, c:ellipse(32, 35 + b, 1.5, 1.5), SCARF, 1)
  end,
  prop = function(c, p, b)
    local s = p.sw or 0
    c:fillMask(c:line({ { 44, 76 + b }, { 44 + s, 78 + b } }, 1), IRON.deep)
    lantern(c, 44 + s, 79 + b, 7, 7)
  end,
}
V.P = {
  back = function(c)
    local r = c:ellipse(39.5, 70, 30, 5) F(c, r, ROLL, 2)
    for _, x in ipairs{ 16, 63 } do for y = 64, 76 do if r:has(x, y) then c:put(x, y, PACK.deep) c:put(x + 1, y, PACK.shade) end end end
  end,
  clothes = function(c, body)
    F(c, c:line({ { 24, 72 }, { 26, 99 } }, 3):clip(body), PACK, 1) F(c, c:line({ { 55, 72 }, { 53, 99 } }, 3):clip(body), PACK, 1)
    for _, q in ipairs{ { 25, 88 }, { 54, 88 } } do F(c, c:rect(q[1] - 1, q[2], q[1] + 1, q[2] + 1), IRON, 1) end
    F(c, c:rrect(20, 66, 59, 75, 4), SCARF, 2)
    for x = 22, 57, 4 do c:put(x, 72, SCARF.shade) c:put(x + 1, 71, SCARF.shade) end
    F(c, c:poly{ { 24, 72 }, { 31, 72 }, { 30, 86 }, { 23, 85 } }, SCARF, 1)
    for _, x in ipairs{ 23, 25, 27, 29 } do c:put(x, 87, SCARF.base) c:put(x, 86, SCARF.shade) end
  end,
  head = function(c)
    F(c, c:ellipse(39.5, 36, 15, 9):clip(c:rect(0, 0, 79, 39)), CAP, 2)
    for x = 27, 52, 3 do c:put(x, 37, CAP.shade) end
    F(c, c:ellipse(39.5, 40, 13, 2.5), CAPV, 1)
    F(c, c:ellipse(39.5, 26, 2, 2), SCARF, 1)
  end,
  prop = function(c)
    c:fillMask(c:line({ { 59, 79 }, { 62.5, 74 }, { 66, 79 } }, 1), IRON.deep)
    lantern(c, 62.5, 79, 10, 15)
    F(c, c:ellipse(62.5, 74, 3, 2.5), PAW, 1)
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
