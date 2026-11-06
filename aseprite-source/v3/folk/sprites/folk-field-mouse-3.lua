-- folk-field-mouse-3 sprite (folk F1_1) variant: 3
local NAME = "folk-field-mouse-3"
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
local FUR = { hi = "#e8a07c", base = "#bf6c48", shade = "#86464a", deep = "#542c42" }
local SMOCK = { hi = "#dcc8f4", base = "#a88ad4", shade = "#7462a8", deep = "#483c74" }
local APRON = { hi = "#fff2dc", base = "#f0dcc0", shade = "#c4a8a8", deep = "#866c84" }
local KER = { hi = "#fde08a", base = "#f0b84a", shade = "#b47a44", deep = "#6e4a44" }
local SOUP = { hi = "#ffc070", base = "#f08a3c", shade = "#c05a3c", deep = "#7e3a3e" }
local STRIPE = "#6a9ad8"
local V = { SLEEVE = SMOCK, BG = { base = "#f4bc94", shade = "#da9078", deep = "#ac665e" } }
local function dots(c, m, x0, y0)
  local l = {} m:each(function(x, y) if (x - x0) % 4 == 0 and (y - y0) % 3 == 0 and ((y - y0) // 3) % 2 == 0 or (x - x0 - 2) % 4 == 0 and (y - y0) % 3 == 0 and ((y - y0) // 3) % 2 == 1 then
    if m:has(x + 1, y) and m:has(x - 1, y) and m:has(x, y + 1) and m:has(x, y - 1) then l[#l + 1] = { x, y } end end end)
  for _, q in ipairs(l) do c:put(q[1], q[2], P.cream) end
end
V.S = {
  clothes = function(c, p, b, body)
    F(c, body:copy(), SMOCK, 3)
    local a = c:rrect(26, 67 + b, 38, 86 + b, 2):clip(body) F(c, a, APRON, 2)
    for y = 68, 86 do for _, x in ipairs{ 29, 35 } do if a:has(x, y + b) then c:put(x, y + b, STRIPE) end end end
    for x = 29, 35 do c:put(x, 78 + b, APRON.shade) end
    F(c, c:line({ { 27, 67 + b }, { 25, 63 + b } }, 1), APRON, 1) F(c, c:line({ { 37, 67 + b }, { 39, 63 + b } }, 1), APRON, 1)
  end,
  head = function(c, p, b)
    local k = c:ellipse(32, 49 + b, 14, 12):clip(c:rect(0, 0, 63, 43 + b)) F(c, k, KER, 2) low(c, k, KER.deep) dots(c, k, 24, 38 + b)
    F(c, c:ellipse(46, 41 + b, 2, 2), KER, 1)
    F(c, c:poly{ { 47, 41 + b }, { 51, 38 + b + (p.pr or 0) }, { 51, 43 + b + (p.pr or 0) } }, KER, 1)
  end,
  prop = function(c, p, b)
    F(c, c:line({ { 45, 77 + b }, { 48, 63 + b } }, 2), METAL, 1)
    F(c, c:ellipse(49, 60 + b, 3.5, 2.5), METAL, 1)
    F(c, c:ellipse(49, 59.5 + b, 2, 1), SOUP, 1) c:put(48, 59 + b, SOUP.hi)
  end,
}
V.P = {
  clothes = function(c, body)
    F(c, body:copy(), SMOCK, 3)
    F(c, c:ellipse(39.5, 70, 11, 3), SMOCK, 1)
    local a = c:rrect(26, 79, 53, 99, 3):clip(body) F(c, a, APRON, 2)
    for y = 80, 99 do for _, x in ipairs{ 31, 35, 44, 48 } do if a:has(x, y) and c:get(x, y) ~= APRON.shade then c:put(x, y, STRIPE) end end end
    F(c, c:line({ { 28, 80 }, { 33, 70 } }, 2), APRON, 1) F(c, c:line({ { 51, 80 }, { 46, 70 } }, 2), APRON, 1)
    for x = 33, 46 do c:put(x, 88, APRON.shade) end for y = 88, 95 do c:put(33, y, APRON.shade) c:put(46, y, APRON.shade) end
  end,
  head = function(c)
    local k = c:ellipse(39.5, 52, 20, 17):clip(c:rect(0, 0, 79, 42)) F(c, k, KER, 2) low(c, k, KER.deep) dots(c, k, 25, 37)
    F(c, c:ellipse(59.5, 38, 3, 2.5), KER, 1)
    F(c, c:poly{ { 60, 37 }, { 67, 33 }, { 66, 39 } }, KER, 1) F(c, c:poly{ { 60, 39 }, { 67, 42 }, { 63, 45 } }, KER, 1)
  end,
  prop = function(c)
    F(c, c:line({ { 62, 99 }, { 65, 73 } }, 2), METAL, 1)
    F(c, c:ellipse(65.5, 70, 5, 3.5), METAL, 2)
    F(c, c:ellipse(65.5, 69.5, 3.5, 2), SOUP, 1) c:put(63, 69, SOUP.hi) c:put(64, 69, SOUP.hi)
    F(c, c:ellipse(62.5, 90, 3.5, 3), PAW, 1)
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
