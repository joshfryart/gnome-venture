-- folk-dragonfly-1 sprite (folk F2_10) variant: 1
-- Dragonfly villager gardener: emerald darter in rust dungarees + straw hat with a sprig, wings spread flat, tail curling up right; prop trowel (soil crumb).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "folk-dragonfly-1"
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
  BODY = lc{ hi = "#a6e07a", base = "#4fb35a", shade = "#2f7f5a", deep = "#2a4f52" },
  SEG = lc{ hi = "#5fae66", base = "#2f7f5a", shade = "#2a5c56", deep = "#273c48" },
  EYE = lc{ hi = "#a8ecec", base = "#3a9fbf", shade = "#2f6a92", deep = "#2e3f6a" },
  FACE = lc{ hi = "#f2f2b0", base = "#d2e07a", shade = "#96b85a", deep = "#5a7a4a" },
  WING = lc{ hi = "#f4f6e2", base = "#d6ead8", shade = "#a2c6c2", deep = "#6f8fa0" },
  DUNG = lc{ hi = "#eea866", base = "#c96e3c", shade = "#8f4436", deep = "#5a2e3a" },
  STRAW = lc{ hi = "#f8e294", base = "#e2b552", shade = "#b07f3e", deep = "#7a5236" },
  BOOT = lc{ hi = "#a87c52", base = "#7d5538", shade = "#573a35", deep = "#3d2a33" },
  METAL = lc{ hi = "#e2e8ec", base = "#a8b4c0", shade = "#717f96", deep = "#4a4f6a" },
  WOOD = lc{ hi = "#d8a868", base = "#a87644", shade = "#7a5236", deep = "#4e3432" },
  DISC = lc{ hi = "#f8dcb0", base = "#f0c48e", shade = "#d29a6a", deep = "#9e6a50" },
  STIG = "#3d5a50",
}
R.ARM = R.BODY
local V = {
  wings = { { fore = true, y = 52, r0 = 3, deg = 10, up = true, len = 13, wid = 3.5 }, { y = 57, r0 = 3, deg = 12, up = false, len = 11, wid = 3.5 } },
  flick = 6,
  tail = { { 40, 70 }, { 44, 71 }, { 48, 70 }, { 51, 68 }, { 53, 65 }, { 54, 62 }, { 55, 59 }, { 55, 56 } }, tr = { 2.6, 1.6 },
}
V.feet = function(c)
  for _, x0 in ipairs{ 23, 33 } do
    form(c, c:rrect(x0, 84, x0 + 7, 90, 2), R.BOOT, 1)
    for x = x0 + 1, x0 + 6 do c:put(x, 90, R.BOOT.deep) end
  end
end
V.dress = function(c, b, p, tor)
  local dg = tor:copy():clip(c:rect(0, 66 + b, 63, 95))
  dg:add(c:rrect(26, 57 + b, 37, 67 + b, 1))
  form(c, dg, R.DUNG, 2)
  form(c, c:line({ { 26, 58 + b }, { 24, 54 + b } }, 2), R.DUNG, 1)
  form(c, c:line({ { 37, 58 + b }, { 39, 54 + b } }, 2), R.DUNG, 1)
  form(c, c:rect(29, 60 + b, 34, 63 + b), R.DUNG, 1)
  c:put(27, 58 + b, R.STRAW.hi) c:put(36, 58 + b, R.STRAW.hi)
end
V.prop = function(c, b, p)
  local t = p.tw or 0
  form(c, c:poly{ { 17, 68 + b }, { 25, 68 + b }, { 21 + t, 78 + b } }, R.METAL, 1)
  form(c, c:rect(20, 60 + b, 22, 67 + b), R.WOOD, 1)
  form(c, c:rect(19, 67 + b, 23, 68 + b), R.METAL, 1)
  c:put(22 + t, 74 + b, R.BOOT.base) c:put(21 + t, 75 + b, R.BOOT.shade)
end
V.hat = function(c, b, p)
  local brim = c:ellipse(31.5, 23 + b, 14.5, 3)
  form(c, brim, R.STRAW, 1)
  local cr = c:rrect(25, 14 + b, 38, 23 + b, 4)
  form(c, cr, R.STRAW, 2)
  local l = {}
  cr:copy():add(brim):each(function(x, y) if c:get(x, y) == R.STRAW.base and (x + y) % 4 == 0 then l[#l + 1] = { x, y } end end)
  for _, q in ipairs(l) do c:put(q[1], q[2], R.STRAW.shade) end
  for x = 25, 38 do if cr:has(x, 21 + b) then c:put(x, 21 + b, R.DUNG.base) c:put(x, 22 + b, R.DUNG.shade) end end
  c:put(36, 20 + b, R.BODY.shade) c:put(37, 19 + b, R.BODY.base) c:put(38, 18 + b, R.BODY.hi) c:put(39, 18 + b, R.BODY.base)
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
