-- stag-beetle-shell (lean P1b_O10)
-- Glossy mahogany stag-beetle husk, top view: huge toothed antler mandibles, ridged thorax, split elytra with hard gloss streaks, six jointed legs. Quirk: a round exit hole chewed in one wing-case, hollow and dark.
local NAME = "stag-beetle-shell"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local function paint(c, m, ramp, vf, nm, adj)
  local tok = { r = { name = nm } }
  local nr = #ramp
  m:each(function(x, y)
    local v = vf(x, y)
    local i = 1 + floor(max(0, min(0.999, v)) * nr)
    if adj then i = adj(x, y, i, v) or i end
    c:put(x, y, ramp[max(1, min(nr, i))], tok)
  end)
end
local function T(nm) return { r = { name = nm } } end
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local SH = { "#220e12", "#4a1a1a", "#78301f", "#a64c28", "#d07036", "#f4a65c" }
local LEG = { "#1c0c10", "#3e1816", "#64281c", "#8a3c22" }
c:groundShadow(32, 58, 18, 2)
local function tube(pts, w, ramp, nm)
  local m, n = G.tube(pts, w)
  local v = X.light(n, { amb = 0.15, wrap = 0.3 })
  paint(c, m, ramp, function(x, y) return v[K(x, y)] end, nm)
  return m
end
-- legs first (under the body)
local tw = function(t) return 1.5 - 0.5 * t end
tube({ {24, 30}, {14, 28}, {10, 34}, {9, 41} }, tw, LEG, "leg")
tube({ {23, 38}, {13, 40}, {10, 46}, {12, 53} }, tw, LEG, "leg")
tube({ {25, 46}, {17, 52}, {16, 56}, {19, 58} }, tw, LEG, "leg")
tube({ {40, 30}, {50, 28}, {54, 34}, {55, 41} }, tw, LEG, "leg")
tube({ {41, 38}, {51, 40}, {54, 46}, {52, 53} }, tw, LEG, "leg")
tube({ {39, 46}, {47, 52}, {48, 56}, {45, 58} }, tw, LEG, "leg")
-- elytra
local ely = c:ellipse(32, 41, 12.5, 16)
local ev = X.light(X.pillow(ely, 9), { amb = 0.1, wrap = 0.25 })
local hole = c:ellipse(37, 46, 3, 3)
paint(c, ely, SH, function(x, y) local v = ev[K(x, y)] return v end, "elytra", function(x, y, i)
  if x == 32 or x == 31 and y > 28 then return 1 end
  if (x - 32) % 4 == 0 and abs(x - 32) > 3 and y > 30 and X.hash(x, y, 2) > 0.2 then return i - 1 end
end)
-- hard gloss streaks
for y = 32, 44 do c:put(25, y, SH[6], T"elytra") end
c:put(25, 45, SH[5], T"elytra") c:put(26, 31, SH[5], T"elytra")
for y = 33, 38 do c:put(26, y, SH[5], T"elytra") end
-- exit hole (quirk)
paint(c, hole, { "#10060a", "#2a0e12", "#4a1a1a" }, function(x, y) return 0.1 + 0.25 * ((x < 37 and y < 46) and 1 or 0) end, "hole")
-- thorax
local th = c:ellipse(32, 24, 10, 6)
paint(c, th, SH, function(x, y) return ev[K(x, y)] ~= nil and 0 or 0 end, "thorax")
local tv = X.light(X.pillow(th, 6), { amb = 0.1, wrap = 0.25 })
paint(c, th, SH, function(x, y) return tv[K(x, y)] * 0.9 end, "thorax", function(x, y, i) if y == 24 and abs(x - 32) < 6 then return i - 1 end end)
c:put(27, 21, SH[6], T"thorax") c:put(28, 21, SH[6], T"thorax") c:put(26, 22, SH[5], T"thorax")
-- head
local hd = c:ellipse(32, 16, 6, 4)
local hv = X.light(X.pillow(hd, 5), { amb = 0.1, wrap = 0.25 })
paint(c, hd, SH, function(x, y) return hv[K(x, y)] * 0.9 end, "head")
c:put(29, 15, "#10060a", T"eye") c:put(35, 15, "#10060a", T"eye")
-- mandibles: antlers with teeth
local mw = function(t) return 2.0 - 1.1 * t end
tube({ {28, 15}, {19, 14}, {16, 8}, {22, 5} }, mw, SH, "mand")
tube({ {36, 15}, {45, 14}, {48, 8}, {42, 5} }, mw, SH, "mand")
for _, p in ipairs{ {18,12},{17,11},{20,9},{21,8},{46,12},{47,11},{44,9},{43,8} } do c:put(p[1], p[2], SH[3], T"mand") end
c:put(17, 9, SH[6], T"mand")
-- antennae
c:put(29, 12, LEG[3], T"ant") c:put(28, 11, LEG[3], T"ant") c:put(35, 12, LEG[3], T"ant") c:put(36, 11, LEG[3], T"ant")
G.save(c, NAME)
