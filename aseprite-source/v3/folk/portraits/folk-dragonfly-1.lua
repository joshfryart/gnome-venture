-- folk-dragonfly-1 portrait (folk F2_10) variant: 1
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
  pwings = { { fore = true, y = 74, r0 = 11, deg = 10, up = true, len = 13, wid = 4.5 }, { y = 80, r0 = 10, deg = 14, up = false, len = 11, wid = 4 } },
  ptail = { { 60, 92 }, { 64, 89 }, { 67, 85 }, { 69, 81 }, { 70, 77 }, { 70, 73 }, { 69, 70 } }, ptr = { 3.4, 2.2 },
}
V.pdress = function(c, bd)
  form(c, c:rrect(29, 79, 50, 99, 2), R.DUNG, 2)
  form(c, c:line({ { 31, 80 }, { 29, 75 } }, 3), R.DUNG, 1)
  form(c, c:line({ { 48, 80 }, { 50, 75 } }, 3), R.DUNG, 1)
  form(c, c:rect(34, 86, 45, 93), R.DUNG, 1)
  c:stitch{ { 35, 87 }, { 44, 87 } }
  form(c, c:rect(30, 80, 31, 81), R.STRAW, 1) form(c, c:rect(48, 80, 49, 81), R.STRAW, 1)
end
V.pprop = function(c)
  form(c, c:poly{ { 10, 80 }, { 24, 80 }, { 17, 63 } }, R.METAL, 2)
  c:fillMask(c:line({ { 17, 67 }, { 17, 78 } }, 1), R.METAL.shade)
  c:put(13, 77, R.BOOT.base) c:put(14, 77, R.BOOT.shade) c:put(20, 76, R.BOOT.base)
  form(c, c:rect(15, 80, 19, 82), R.METAL, 1)
  form(c, c:rrect(15, 83, 19, 97, 1), R.WOOD, 1)
  form(c, c:ellipse(17, 89, 4, 3), R.BODY, 1)
end
V.phat = function(c)
  local brim = c:ellipse(39.5, 34, 21, 4.5)
  form(c, brim, R.STRAW, 2)
  local cr = c:rrect(29, 19, 50, 34, 6)
  form(c, cr, R.STRAW, 2)
  local l = {}
  cr:copy():add(brim):each(function(x, y) if c:get(x, y) == R.STRAW.base and (x + y) % 4 == 0 then l[#l + 1] = { x, y } end end)
  for _, q in ipairs(l) do c:put(q[1], q[2], R.STRAW.shade) end
  for x = 29, 50 do if cr:has(x, 30) then c:put(x, 29, R.DUNG.hi) c:put(x, 30, R.DUNG.base) c:put(x, 31, R.DUNG.shade) end end
  form(c, c:line({ { 46, 29 }, { 50, 24 } }, 1), R.BODY, 1)
  form(c, c:ellipse(52, 23, 2.5, 1.5), R.BODY, 1)
  form(c, c:ellipse(48, 23, 1.5, 2), R.BODY, 1)
end

local c = HP.canvas{ w = 80, h = 100, scale = 1, name = NAME }
local function backdrop(r)
  local disc = HP.ellipse(39.5, 44.5, 30.5, 30.5)
  disc:each(function(x, y) if not c:get(x, y) then c:put(x, y, disc:has(x + 2, y + 2) and r.base or r.shade, "bg") end end)
  local ring = disc:grow(1):cut(disc)
  ring:each(function(x, y) if not c:get(x, y) then
    local dk = false
    for _, d in ipairs{ {1,0},{-1,0},{0,1},{0,-1} } do if c:get(x + d[1], y + d[2]) == r.shade then dk = true end end
    c:put(x, y, dk and r.deep or r.shade, "bg") end end)
end
for _, w in ipairs(V.pwings) do for _, s in ipairs{ -1, 1 } do
  wing(c, 39.5 + s * w.r0, w.y, s, w.deg, w.up, w.len, w.wid, R.WING, R.STIG)
end end
tail(c, V.ptail, 0, 0, R.SEG, R.BODY, V.ptr[1], V.ptr[2])
if V.pback then V.pback(c) end
form(c, c:rrect(32, 62, 47, 78, 3), R.BODY, 2)
local bd = c:ellipse(39.5, 96, 28, 22):clip(c:rect(0, 0, 79, 99))
form(c, bd, R.BODY, 3)
V.pdress(c, bd)
V.pprop(c)
form(c, c:ellipse(39.5, 54, 16, 12.5), R.BODY, 2)
form(c, c:ellipse(39.5, 58, 10, 7.5), R.FACE, 2)
for _, ex in ipairs{ 30.5, 48.5 } do
  local e = c:ellipse(ex, 43, 10.5, 10)
  form(c, e, R.EYE, 3)
  facets(c, e, R.EYE, 3)
  local gx = math.floor(ex) - 6
  for _, q in ipairs{ { 0, 0 }, { 1, 0 }, { 0, 1 }, { 2, 0 } } do c:put(gx + q[1], 37 + q[2], R.EYE.hi) end
end
c:eyeLocked(28, 43) c:eyeLocked(47, 43)
form(c, c:ellipse(39.5, 63, 4.5, 2.5), R.FACE, 1)
for _, q in ipairs{ { 36, 60 }, { 37, 61 }, { 38, 61 }, { 39, 61 }, { 40, 61 }, { 41, 61 }, { 42, 61 }, { 43, 60 } } do c:put(q[1], q[2], INK) end
c:put(39, 65, R.FACE.deep) c:put(40, 65, R.FACE.deep)
c:put(35, 64, R.FACE.shade) c:put(44, 64, R.FACE.shade)
c:cheek(27, 56) c:cheek(51, 56)
V.phat(c)
c:finish{ outline = true }
backdrop(R.DISC)
HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
print(NAME .. " ok")
