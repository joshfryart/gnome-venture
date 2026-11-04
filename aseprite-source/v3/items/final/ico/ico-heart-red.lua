-- ico-heart-red (final, Opus). A plump, glossy enamel heart leaning a touch to the left: two round lobes, a soft
-- crease down the centre notch, a clean point. Material: pillow-bevel per-pixel light on a 6-tone red ramp
-- (cool-violet shade side), a big window-pane gloss on the left lobe plus a small one on the right, a cool
-- reflected rim on the lower right, AO in the notch.
-- quirk: a cream sticking plaster crossed over the right lobe (someone got a little hurt).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA5_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sqrt, max, min, abs = math.floor, math.sqrt, math.max, math.min, math.abs
local c = A.new("ico-heart-red")
local R = { "#4e1430", "#7f1d3a", "#b42a3e", "#e2403c", "#fb6a4c", "#ff9f7c" }
local SPEC, BOUNCE, GLOSS = "#fff4d6", "#a8406a", "#ffd0b4"
local tok = A.tok("heart")

local h = A.heart(32, 31, 19.5, 1.0, -0.1)
local n = A.dome(h, 15, 1.15, 3)
-- crease: pull normals toward the centre line below the notch
local bias = {}
local d = X.dist(h)
local v = A.val(n, { amb = 0.02, wrap = 0.2 })
local idx = X.tone(c, h, v, R, { cuts = { 0.2, 0.4, 0.6, 0.8, 0.95 }, tok = tok })
-- notch AO: pixels near the top notch
local nx, ny = 0, 0
do -- find the notch: lowest top-edge pixel between the lobes
  local best = -1
  for x = 26, 36 do
    local y = 0 while y < 63 and not h:has(x, y) do y = y + 1 end
    if y > best then best, nx, ny = y, x, y end
  end
end
h:each(function(x, y)
  local dd = sqrt((x - nx) ^ 2 + (y - ny) ^ 2)
  if dd < 2.2 then A.step(c, idx, R, x, y, -2, tok) elseif dd < 4.2 then A.step(c, idx, R, x, y, -1, tok) end
end)
-- crease running down from the notch: a faint darker line, slightly left-of-centre lit lip
for i = 3, 9 do
  local x, y = nx - floor(i * 0.12 + 0.5), ny + i
  if i < 8 then A.step(c, idx, R, x, y, -1, tok) end
end
-- cool reflected light on the lower-right edge
local rim = X.rim(n)
h:edge():each(function(x, y) local k = K(x, y)
  if rim[k] and rim[k] > 0.55 and y > 34 and x > 31 then c:put(x, y, BOUNCE, tok) end end)
-- gloss: window pane on the left lobe (curved bar + small square) and a dab on the right lobe
local gl = A.pred(0, 0, 63, 63, function(x, y)
  local dx, dy = x - 23, y - 22
  local r = sqrt(dx * dx + dy * dy)
  local a = math.atan(dy, dx)
  return r >= 5.6 and r <= 8.2 and a > -2.9 and a < -1.55
end):clip(h)
A.fill = A.fill or function(m, col) m:each(function(x, y) c:put(x, y, col, tok) end) end
gl:each(function(x, y) c:put(x, y, GLOSS, tok) end)
for _, p in ipairs{ { 19, 21 }, { 20, 21 }, { 19, 22 }, { 20, 22 } } do
  if h:has(p[1], p[2]) then c:put(p[1], p[2], GLOSS, tok) end end
c:put(19, 16, SPEC) c:put(20, 16, SPEC) c:put(18, 17, SPEC)
c:put(15, 24, R[6]) c:put(15, 25, R[6]) c:put(15, 26, R[6])
-- small gloss on the right lobe
c:put(38, 19, R[6]) c:put(39, 19, R[6]) c:put(40, 19, R[6]) c:put(37, 20, R[6])

-- quirk: crossed sticking plaster on the right lobe
local PL = { "#8a5a46", "#c99470", "#efc79a", "#ffe6c0" }
local ptok = A.tok("plaster")
local function strip(ax, ay, bx, by)
  local m = A.caps(ax, ay, bx, by, 1.6)
  return m
end
local s1 = strip(38, 22, 47, 31)
local s2 = strip(47, 22, 38, 31)
local function paintStrip(m, under)
  local fr = A.frame(38, 22, 1, 1)
  m:each(function(x, y)
    local col = PL[3]
    if m:has(x + 1, y + 1) == false or m:has(x, y + 1) == false then col = PL[2] end
    if not m:has(x - 1, y) or not m:has(x, y - 1) then col = PL[4] end
    c:put(x, y, col, ptok)
  end)
end
-- contact shadow of the plaster on the heart
s1:copy():add(s2):shift(1, 1):each(function(x, y)
  if h:has(x, y) and not s1:has(x, y) and not s2:has(x, y) then A.step(c, idx, R, x, y, -1, tok) end end)
paintStrip(s2)
-- s1 on top, with a dark seam where it crosses s2
A.touch(s1, s2):each(function(x, y) if not s1:has(x, y) then c:put(x, y, PL[1], ptok) end end)
paintStrip(s1)
-- gauze pad in the middle + pores
for _, p in ipairs{ { 42, 26 }, { 43, 26 }, { 42, 27 }, { 43, 27 } } do c:put(p[1], p[2], "#f4d9e0", ptok) end
c:put(43, 27, "#d7b0bc", ptok)
c:put(40, 24, PL[2], ptok) c:put(46, 30, PL[2], ptok) c:put(45, 24, PL[2], ptok)
A.save(c, "ico-heart-red")
