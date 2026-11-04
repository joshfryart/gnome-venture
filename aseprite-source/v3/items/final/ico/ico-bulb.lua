-- ico-bulb (final, Opus). Upright glowing light bulb: pear-shaped glass globe on a slim neck, brass screw cap with
-- twisted threads, dark glass insulator and a small solder contact.
-- Material: glass = per-pixel sphere light mixed with an inner glow (6-tone warm yellow), bright cream window rim
-- upper-left, pale core, cool reflected light lower-right; filament support wires + a hot coil. Brass = cylinder
-- light (6 tones), diagonal thread ridges (lit crest, dark root) that twist, AO where the glass meets the cap.
-- quirk: the glowing filament coil is bent into a little heart.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aA2_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new("ico-bulb")
local GLASS = { "#c0662a", "#e48f2c", "#f7b93a", "#ffd760", "#ffea96", "#fff6cc" }
local BRASS = { "#4e3424", "#7d5530", "#a9793a", "#cf9e4c", "#e9c46e", "#fbe6a6" }
local INS   = { "#241826", "#3e2c44", "#5e4866" }
local BOUNCE, WIRE, HOT = "#c9a6d8", "#a4663a", "#fffbe8"

-- glass: globe + neck (solid of revolution; axis x = 31.5)
local CX = 31.5
local GT, GB = 8, 41               -- top of globe, bottom of neck
local GCY, GR = 20, 12.6
local function gw(h)               -- half width: round globe, then an eased taper into the neck
  if h <= GCY + 1 then return sqrt(max(0, GR * GR - (h - GCY) ^ 2)) end
  local u = (h - GCY - 1) / (GB - GCY - 1)
  local w1 = sqrt(GR * GR - 1)
  return 7.2 + (w1 - 7.2) * (0.5 + 0.5 * cos(pi * u))
end
local glass = HP.mask()
local gn, gI = {}, {}
for y = GT - 1, GB do for x = 14, 50 do
  local w = gw(y)
  local u = (x - CX) / (w + 0.5)
  if abs(u) <= 1 then
    local k = K(x, y)
    glass:set(x, y)
    local dw = (gw(min(GB, y + 1)) - gw(max(GT, y - 1))) / 2
    local vy = (y < GCY) and -((GCY - y) / GR) * 1.4 or 0
    gn[k] = { A.norm(u, -dw * 0.9 + vy, sqrt(max(0.03, 1 - u * u))) }
    gI[k] = { u = u, h = y }
  end
end end
glass:cut(HP.rect(0, GT - 1, 63, GT - 1))
local gtok = A.tok("glass")
-- light = lambert + inner glow (brighter toward the filament)
local add = {}
local FX, FY = 31.5, 23
glass:each(function(x, y) local k = K(x, y)
  local d = sqrt(((x - FX) / 12) ^ 2 + ((y - FY) / 13) ^ 2)
  add[k] = 0.2 * max(0, 1 - d) - 0.06
  if y >= GB - 2 then add[k] = add[k] - 0.25 end      -- AO where the glass sinks into the cap
end)
local gidx = A.shade(c, glass, gn, GLASS, { tok = gtok, add = add, amb = 0.1, wrap = 0.3, cuts = { 0.24, 0.42, 0.58, 0.74, 0.9 } })
-- window reflection: cream arc upper-left, 2 px wide, broken into a long and a short stroke
glass:each(function(x, y) local k = K(x, y) local u = gI[k].u
  local w = gw(y)
  local inner = (x - CX) / (w + 0.5)
  if y >= GT + 4 and y <= GT + 17 and inner < -0.6 and inner > -0.84 then c:put(x, y, A.CREAM, gtok)
  elseif y >= GT + 4 and y <= GT + 17 and inner <= -0.84 and inner > -0.95 then c:put(x, y, GLASS[3], gtok) end
  if y >= GT + 20 and y <= GT + 22 and inner < -0.6 and inner > -0.8 then c:put(x, y, GLASS[5], gtok) end
end)
-- cool reflected light: lower-right rim of the globe
glass:edge():each(function(x, y) local u = gI[K(x, y)].u
  if u > 0.55 and y > GT + 13 and y < GB - 6 then c:put(x, y, BOUNCE, gtok) end end)

-- filament: two support wires from the stem up to a hot heart-shaped coil
local wtok = A.tok("wire")
for y = 29, 39 do c:put(28, y, WIRE, wtok) c:put(35, y, WIRE, wtok) end
c:put(29, 39, WIRE, wtok) c:put(34, 39, WIRE, wtok)
-- glass stem (pale) in the neck
for y = 36, 40 do for x = 30, 33 do c:put(x, y, GLASS[5], gtok) end end
c:put(30, 36, GLASS[6], gtok)
-- heart coil (quirk): hot core with an amber halo
local heart = {
  ".hh..hh.",
  "hHHhhHHh",
  "hHWHHHHh",
  "hHHHHHHh",
  ".hHHHHh.",
  "..hHHh..",
  "...hh...",
}
-- warm halo round the coil
do local hm = HP.mask()
  for yy, row in ipairs(heart) do for xx = 1, #row do if row:sub(xx, xx) ~= "." then hm:set(27 + xx, 22 + yy) end end end
  hm:grow(2):cut(hm):each(function(x, y) if glass:has(x, y) then c:put(x, y, GLASS[6], gtok) end end)
end
A.map(c, heart, 28, 23, { h = "#d8602a", H = "#ffd24a", W = HOT }, wtok)
c:put(28, 28, WIRE, wtok) c:put(35, 28, WIRE, wtok)

-- brass screw cap (cylinder, threads twist diagonally)
local BT, BB = 41, 52
local btok = A.tok("brass")
local cap = HP.rect(24, BT, 39, BB)
cap:cut(HP.rect(24, BB, 24, BB)):cut(HP.rect(39, BB, 39, BB))
local cn, cu = {}, {}
cap:each(function(x, y) local u = (x - 31.5) / 8.5 cn[K(x, y)] = { A.norm(u, 0.05, sqrt(max(0.05, 1 - u * u))) } cu[K(x, y)] = u end)
local bias = {}
cap:each(function(x, y) local k = K(x, y)
  if y == BT then bias[k] = -2 elseif y == BT + 1 then bias[k] = -1 end end)
local bidx = A.shade(c, cap, cn, BRASS, { tok = btok, bias = bias, amb = 0.06, wrap = 0.2, cuts = { 0.12, 0.3, 0.5, 0.68, 0.86 } })
-- thread ridges: a groove line that slopes 1 px across the cap, lit crest just above
for _, t0 in ipairs{ 44.5, 48.5 } do
  cap:each(function(x, y)
    local yy = t0 + (x - 24) * 0.14
    if abs(y - yy) < 0.5 then A.step(c, bidx, BRASS, x, y, -2, btok)
    elseif y - yy > -1.5 and y - yy <= -0.5 and cu[K(x, y)] < 0.6 then A.step(c, bidx, BRASS, x, y, 1, btok) end
  end)
end
c:put(26, 43, BRASS[6], btok) c:put(27, 43, BRASS[6], btok)          -- specular streak on the top band
c:put(26, 47, BRASS[6], btok)
-- crimped edge bumps on the outline (threads read in silhouette)
for _, y in ipairs{ 46, 50 } do c:put(23, y, BRASS[3], btok) c:put(40, y, BRASS[1], btok) end

-- dark glass insulator + solder contact
local itok = A.tok("ins")
for x = 27, 36 do c:put(x, 53, x < 30 and INS[3] or INS[2], itok) c:put(x, 54, INS[1], itok) end
c:put(28, 53, "#8a7090", itok)
local stok = A.tok("solder")
for x = 30, 33 do c:put(x, 55, x == 30 and "#e2e0e6" or "#aaa9b8", stok) c:put(x, 56, "#74758c", stok) end
A.save(c, "ico-bulb")
