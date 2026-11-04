-- folk-dragonfly-3 portrait (folk F2_10) variant: 3
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
  pwings = { { fore = true, y = 72, r0 = 10, deg = 42, up = true, len = 13, wid = 4.5 }, { y = 78, r0 = 10, deg = 18, up = true, len = 11, wid = 4 } },
  ptail = { { 20, 86 }, { 16, 82 }, { 13, 78 }, { 11, 74 }, { 10, 70 }, { 10, 66 }, { 11, 63 } }, ptr = { 3.4, 2.2 },
}
V.pdress = function(c, bd)
  form(c, bd, R.SMOCK, 3)
  form(c, c:rrect(29, 80, 50, 99, 3), R.APRON, 2)
  form(c, c:line({ { 31, 80 }, { 34, 70 } }, 2), R.APRON, 1)
  form(c, c:line({ { 48, 80 }, { 45, 70 } }, 2), R.APRON, 1)
  form(c, c:rrect(33, 87, 46, 94, 2), R.APRON, 1)
  c:stitch{ { 34, 88 }, { 45, 88 } }
end
V.pprop = function(c)
  form(c, c:line({ { 63, 98 }, { 66, 70 } }, 2), R.COPPER, 1)
  form(c, c:ellipse(66.5, 66, 6, 3.5), R.COPPER, 2)
  form(c, c:ellipse(66.5, 65, 4, 1.5), R.SOUP, 1)
  c:put(71, 70, R.SOUP.base) c:put(71, 71, R.SOUP.shade)
  form(c, c:ellipse(63, 90, 3.5, 3), R.SEG, 1)
end
V.phat = function(c)
  local m = c:ellipse(39.5, 35, 14, 6)
  form(c, m, R.SMOCK, 2)
  form(c, c:ellipse(47, 25, 3, 4.5), R.SMOCK, 1)
  form(c, c:ellipse(53, 27, 3.5, 3), R.SMOCK, 1)
  form(c, c:ellipse(49, 30, 2.5, 2), R.SMOCK, 1)
  dots(c, m)
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
