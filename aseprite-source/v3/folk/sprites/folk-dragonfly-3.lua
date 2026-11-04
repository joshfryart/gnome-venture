-- folk-dragonfly-3 sprite (folk F2_10) variant: 3
-- Dragonfly villager cook: scarlet darter in teal smock + cream apron, knotted polka headscarf, wings raised in a V, tail hooked up behind; prop copper ladle with soup.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "folk-dragonfly-3"
local INK = "#2b1c26"
local function lc(t) local o = {} for k, v in pairs(t) do o[k] = v:lower() end return o end
local function R2(v) return math.floor(v + 0.5) end
local function oval(cx, cy, rx, ry, deg)
  local a = math.rad(deg)
  local ca, sa, m = math.cos(a), math.sin(a), HP.mask()
  local RR = math.max(rx, ry) + 1
  for y = math.floor(cy - RR), math.ceil(cy + RR) do for x = math.floor(cx - RR), math.ceil(cx + RR) do
    local dx, dy = x + .5 - cx, y + .5 - cy
    local u, v = dx * ca + dy * sa, -dx * sa + dy * ca
    if (u / (rx + .3)) ^ 2 + (v / (ry + .3)) ^ 2 <= 1 then m:set(x, y) end
  end end
  return m
end
-- base + shade band (c:part) + warm 1px rim on the upper-left = 4 tones per material
local function form(c, m, R, band)
  c:part(m, R, { band = band or 1, nopop = true })
  local lit = {}
  m:each(function(x, y) if c:get(x, y) == R.base and not m:has(x - 1, y - 1) then lit[#lit + 1] = { x, y } end end)
  for _, q in ipairs(lit) do c:put(q[1], q[2], R.hi) end
  return m
end
local function facets(c, m, R, st)
  local l = {}
  m:each(function(x, y) if c:get(x, y) == R.base and y % st == 0 and (x + ((y // st) % 2) * 2) % (st + 1) == 0 then l[#l + 1] = { x, y } end end)
  for _, q in ipairs(l) do c:put(q[1], q[2], R.shade) end
end
local function wing(c, x0, y0, sgn, deg, up, len, wid, R, stig)
  local th = math.rad(deg)
  local dx, dy = sgn * math.cos(th), (up and -1 or 1) * math.sin(th)
  local m = oval(x0 + dx * len, y0 + dy * len, len, wid, math.deg(math.atan(dy, dx)))
  form(c, m, R, 1)
  local inn = m:shrink(1)
  local L = 2 * len
  c:fillMask(c:line({ { R2(x0 + dx * 2), R2(y0 + dy * 2) }, { R2(x0 + dx * (L - 3)), R2(y0 + dy * (L - 3)) } }, 1):clip(inn), R.shade)
  local px, py = -dy, dx
  if py > 0 then px, py = -px, -py end
  for k = 7, L - 6, 6 do
    local ax, ay = x0 + dx * k, y0 + dy * k
    c:fillMask(c:line({ { R2(ax), R2(ay) }, { R2(ax + px * wid), R2(ay + py * wid) } }, 1):clip(inn), R.shade)
  end
  local sx, sy = x0 + dx * (L - 5) + px * wid * 0.4, y0 + dy * (L - 5) + py * wid * 0.4
  c:fillMask(c:line({ { R2(sx), R2(sy) }, { R2(sx + dx * 2), R2(sy + dy * 2) } }, 1):clip(inn), stig)
end
-- segmented abdomen: beads base->tip, alternating segment rings
local function tail(c, pts, b, tip, A, B, r0, r1)
  local n = #pts
  for i = n, 1, -1 do
    local t = (i - 1) / (n - 1)
    local q = pts[i]
    form(c, c:ellipse(q[1], q[2] + b + R2(tip * t), r0 + (r1 - r0) * t, r0 + (r1 - r0) * t), (i % 2 == 0) and A or B, 1)
  end
end
local R = {
  BODY = lc{ hi = "#f8a080", base = "#e0503a", shade = "#a8343e", deep = "#6a2440" },
  SEG = lc{ hi = "#e8604a", base = "#a8343e", shade = "#7a2a40", deep = "#4e2038" },
  EYE = lc{ hi = "#f8d088", base = "#c9803a", shade = "#8f5034", deep = "#5a3030" },
  FACE = lc{ hi = "#fde2b0", base = "#f4b07a", shade = "#cc6a52", deep = "#8a3a44" },
  WING = lc{ hi = "#faf2da", base = "#f0dcb8", shade = "#d2ae8e", deep = "#a0807a" },
  SMOCK = lc{ hi = "#86e2cc", base = "#36b0a0", shade = "#2a7a80", deep = "#2a4a5e" },
  APRON = lc{ hi = "#f6eed2", base = "#ddd6aa", shade = "#a8a884", deep = "#6f7a6a" },
  COPPER = lc{ hi = "#f8c48c", base = "#d88a52", shade = "#a05a3e", deep = "#6a3a38" },
  SOUP = lc{ hi = "#fcd070", base = "#f0a030", shade = "#c87028", deep = "#8a4a30" },
  DISC = lc{ hi = "#f6e4a0", base = "#efd27a", shade = "#cfa65a", deep = "#9a7448" },
  STIG = "#7a2a40",
}
R.ARM = R.SMOCK
local function dots(c, m)
  local l = {}
  m:each(function(x, y) if c:get(x, y) == R.SMOCK.base and x % 3 == 0 and y % 3 == (x // 3) % 2 then l[#l + 1] = { x, y } end end)
  for _, q in ipairs(l) do c:put(q[1], q[2], R.APRON.hi) end
end
local V = {
  wings = { { fore = true, y = 50, r0 = 3, deg = 42, up = true, len = 12, wid = 3.5 }, { y = 55, r0 = 3, deg = 18, up = true, len = 11, wid = 3.5 } },
  flick = 6,
  tail = { { 24, 66 }, { 20, 64 }, { 17, 61 }, { 15, 57 }, { 14, 53 }, { 14, 49 }, { 15, 46 } }, tr = { 2.6, 1.6 },
}
V.feet = function(c)
  for _, x0 in ipairs{ 24, 34 } do form(c, c:rrect(x0, 88, x0 + 5, 90, 1), R.SEG, 1) end
end
V.dress = function(c, b, p, tor)
  form(c, tor, R.SMOCK, 2)
  local ap = c:rrect(27, 57 + b, 36, 64 + b, 1):add(c:rrect(25, 63 + b, 38, 77 + b, 2))
  form(c, ap, R.APRON, 2)
  form(c, c:line({ { 28, 57 + b }, { 29, 52 + b } }, 1), R.APRON, 1)
  form(c, c:line({ { 35, 57 + b }, { 34, 52 + b } }, 1), R.APRON, 1)
  form(c, c:rect(28, 68 + b, 35, 72 + b), R.APRON, 1)
  c:put(39, 63 + b, R.APRON.shade) c:put(40, 64 + b, R.APRON.base) c:put(40, 62 + b, R.APRON.base)
end
V.prop = function(c, b, p)
  local s = p.tw or 0
  form(c, c:line({ { 44, 52 + b }, { 43 + s, 71 + b } }, 2), R.COPPER, 1)
  c:put(45, 51 + b, R.COPPER.base) c:put(46, 52 + b, R.COPPER.shade)
  form(c, c:ellipse(43.5 + s, 73.5 + b, 3.5, 2.5), R.COPPER, 1)
  c:put(43 + s, 72 + b, R.SOUP.base) c:put(44 + s, 72 + b, R.SOUP.hi)
end
V.hat = function(c, b, p)
  local t = p.tw or 0
  local m = c:ellipse(31.5, 25 + b, 10, 4.5)
  form(c, m, R.SMOCK, 2)
  local k1, k2 = c:ellipse(36, 18 + b, 2, 3), c:ellipse(40 + t, 19 + b, 2.5, 2)
  form(c, k1, R.SMOCK, 1) form(c, k2, R.SMOCK, 1)
  form(c, c:ellipse(37.5, 21.5 + b, 2, 1.5), R.SMOCK, 1)
  dots(c, m)
end

local function frame(p)
  local c = HP.canvas{ w = 64, h = 96, name = NAME }
  local b = p.b or 0
  c:groundShadow(32, 89, 14, 3)
  for _, w in ipairs(V.wings) do for _, s in ipairs{ -1, 1 } do
    local deg = w.deg + ((p.flick and w.fore) and V.flick or 0)
    wing(c, 31.5 + s * w.r0, w.y + b + ((not w.fore) and (p.droop or 0) or 0), s, deg, w.up, w.len, w.wid, R.WING, R.STIG)
  end end
  tail(c, V.tail, b, p.tip or 0, R.SEG, R.BODY, V.tr[1], V.tr[2])
  if V.back then V.back(c, b, p) end
  for _, x in ipairs{ 26, 36 } do form(c, c:rect(x, 70 + b, x + 1, 88), R.SEG, 1) end
  V.feet(c)
  form(c, c:rrect(28, 48 + b, 35, 56 + b, 2), R.BODY, 1)
  local tor = c:ellipse(31.5, 64 + b, 10, 10)
  form(c, tor, R.BODY, 2)
  V.dress(c, b, p, tor)
  form(c, c:ellipse(21, 61 + b, 2.5, 4), R.ARM, 1) form(c, c:ellipse(42, 61 + b, 2.5, 4), R.ARM, 1)
  V.prop(c, b, p)
  form(c, c:ellipse(21, 66 + b, 2, 1.5), R.SEG, 1) form(c, c:ellipse(42, 66 + b, 2, 1.5), R.SEG, 1)
  form(c, c:ellipse(31.5, 41 + b, 12.5, 9.5), R.BODY, 2)
  form(c, c:ellipse(31.5, 44.5 + b, 7, 5), R.FACE, 1)
  for _, ex in ipairs{ 24, 39 } do
    local e = c:ellipse(ex, 31 + b, 8, 7.5)
    form(c, e, R.EYE, 2)
    facets(c, e, R.EYE, 3)
    c:put(ex - 4, 26 + b, R.EYE.hi) c:put(ex - 3, 26 + b, R.EYE.hi) c:put(ex - 4, 27 + b, R.EYE.hi)
  end
  for _, ex in ipairs{ 22, 37 } do
    if p.blink then
      for _, q in ipairs{ { 0, 2 }, { 1, 3 }, { 2, 3 }, { 3, 3 }, { 4, 2 } } do c:put(ex + q[1], 31 + b + q[2], INK) end
    else c:eyeLocked(ex, 31 + b) end
  end
  form(c, c:ellipse(31.5, 47.5 + b, 3.5, 2), R.FACE, 1)
  for _, q in ipairs{ { 28, 45 }, { 29, 46 }, { 30, 46 }, { 31, 46 }, { 32, 46 }, { 33, 46 }, { 34, 46 }, { 35, 45 } } do c:put(q[1], q[2] + b, INK) end
  c:put(31, 49 + b, R.FACE.deep) c:put(32, 49 + b, R.FACE.deep)
  c:cheek(25, 43 + b) c:cheek(37, 43 + b)
  V.hat(c, b, p)
  c:finish{ outline = true }
  HP.assertClean(c)
  return c
end
local P4 = { { b = 0 }, { b = 1, tip = 1, droop = 1 }, { b = 0 }, { b = 0, blink = true, flick = true, tw = 1 } }
local frames = {}
for i, p in ipairs(P4) do frames[i] = frame(p) end
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
local ss = Sprite(W * 4, H, ColorMode.RGB) ss.cels[1].image = strip
ss:saveCopyAs(out .. NAME .. ".png") ss:close()
local spr = Sprite(W, H, ColorMode.RGB)
for _ = 2, 4 do spr:newEmptyFrame() end
local Ly = spr.layers[1] Ly.name = NAME
for f = 1, 4 do spr:newCel(Ly, spr.frames[f], imgs[f], Point(0, 0)) spr.frames[f].duration = (f == 4) and 0.2 or 0.35 end
local tg = spr:newTag(1, 4) tg.name = "idle"
spr:saveAs(out .. NAME .. ".aseprite") spr:close()
print(NAME .. " ok")
