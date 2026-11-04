-- folk-dragonfly-2 portrait (folk F2_10) variant: 2
-- Dragonfly villager traveller: azure hawker with bedroll pack, plum scarf, olive cap with pin, wings swept back-down, tail straight out left; prop brass lantern.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "folk-dragonfly-2"
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
  BODY = lc{ hi = "#9ad8f6", base = "#3f9ee0", shade = "#2f68b0", deep = "#2e3d78" },
  SEG = lc{ hi = "#4aa6e0", base = "#2f68b0", shade = "#2e4a8a", deep = "#2a3060" },
  EYE = lc{ hi = "#c4acf4", base = "#7a5ed0", shade = "#523ea0", deep = "#33286a" },
  FACE = lc{ hi = "#eaf6f8", base = "#b4dcec", shade = "#7aaad0", deep = "#4a6a9a" },
  WING = lc{ hi = "#f0f2f8", base = "#d2dcf0", shade = "#a2b0d6", deep = "#6f7aa8" },
  SCARF = lc{ hi = "#f490a4", base = "#cc4a6a", shade = "#8f2f5a", deep = "#5a2244" },
  PACK = lc{ hi = "#ead4a4", base = "#c2a06a", shade = "#8f7050", deep = "#5e4a44" },
  CAP = lc{ hi = "#c0c878", base = "#8a9448", shade = "#5e6a3e", deep = "#3c4434" },
  BRASS = lc{ hi = "#f6d474", base = "#d4a03a", shade = "#9a6a32", deep = "#5e4030" },
  GLOW = lc{ hi = "#fcf0b4", base = "#f8d870", shade = "#eca84a", deep = "#b8703a" },
  DISC = lc{ hi = "#d4e4bc", base = "#bcd2a0", shade = "#93ad7a", deep = "#62785a" },
  STIG = "#3a3a70",
}
R.ARM = R.BODY
local V = {
  pwings = { { fore = true, y = 74, r0 = 10, deg = 26, up = false, len = 13, wid = 4 }, { y = 80, r0 = 9, deg = 40, up = false, len = 11, wid = 3.5 } },
  ptail = { { 18, 95 }, { 13, 94 }, { 9, 93 }, { 5, 92 }, { 2, 90 } }, ptr = { 3.2, 2.2 },
}
V.pback = function(c)
  form(c, c:rrect(14, 76, 65, 99, 6), R.PACK, 3)
  form(c, c:rrect(10, 70, 69, 77, 3), R.CAP, 2)
  for _, x in ipairs{ 15, 64 } do for y = 71, 76 do c:put(x, y, R.CAP.deep) end end
end
V.pdress = function(c, bd)
  for _, x in ipairs{ 25, 52 } do form(c, c:rect(x, 76, x + 2, 99):clip(bd), R.PACK, 1) end
  form(c, c:rrect(23, 67, 56, 76, 3), R.SCARF, 2)
  local tl = c:poly{ { 26, 73 }, { 34, 73 }, { 31, 92 }, { 23, 90 } }
  form(c, tl, R.SCARF, 1)
  for x = 23, 34 do if tl:has(x, 84) then c:put(x, 84, R.SCARF.shade) end if tl:has(x, 86) then c:put(x, 86, R.SCARF.shade) end end
end
V.pprop = function(c)
  c:fillMask(c:line({ { 58, 86 }, { 61, 81 }, { 64, 86 } }, 1), R.BRASS.shade)
  form(c, c:rrect(55, 86, 67, 88, 1), R.BRASS, 1)
  form(c, c:rect(57, 89, 65, 96), R.GLOW, 2)
  for y = 89, 96 do c:put(61, y, R.BRASS.shade) end
  c:put(59, 92, R.GLOW.hi) c:put(59, 93, R.GLOW.hi)
  form(c, c:rect(55, 97, 67, 99), R.BRASS, 1)
  form(c, c:ellipse(61, 81, 3, 2.5), R.SEG, 1)
end
V.phat = function(c)
  form(c, c:rrect(28, 24, 51, 36, 6), R.CAP, 2)
  form(c, c:ellipse(39.5, 37, 12, 2.2), R.CAP, 2)
  for y = 25, 35 do c:put(39, y, R.CAP.shade) end
  c:put(39, 24, R.CAP.hi) c:put(40, 24, R.CAP.hi)
  form(c, c:rect(45, 28, 47, 30), R.SCARF, 1)
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
