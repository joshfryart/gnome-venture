-- ico-olive (final pass, Opus single pass). Bold icon: a slim sprig. A thin grey-brown twig runs across the top,
-- two long narrow olive leaves fan off it (one turned to show its silvery underside), and two olives hang on short
-- stalks: a glossy green one in front and a ripe plum-black one tucked behind. Per-pixel ellipsoid light (6-tone
-- each), hard specular + cream glint on the green, dusty waxy bloom on the ripe one, cool reflected light, contact
-- shadow where the green overlaps the ripe olive, AO at the stalk ends. Twig: bark ticks + pale cut end.
-- quirk: a single golden bead of olive oil is about to drip off the green olive's tip.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA7_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, sqrt, abs, sin, pi = math.floor, math.max, math.min, math.sqrt, math.abs, math.sin, math.pi
local c = A.new("ico-olive")
local GRN  = { "#25351c", "#3c5220", "#577028", "#748c34", "#98ac4a", "#c8d27e" }
local RIPE = { "#1c1224", "#2f1d38", "#47294e", "#633a66", "#87587e", "#b88aae" }
local LEAF = { "#1a3a30", "#26503a", "#356a44", "#4e8650", "#74a464", "#a8c88a" }
local SILV = { "#4c6460", "#6e8a80", "#90aa9c", "#b2c8b6", "#d4e2cc", "#eef2dc" }
local BARK = { "#3a2a2c", "#5e4a44", "#86705e", "#ad9878" }
local gtok, rtok, btok = A.tok("green"), A.tok("ripe"), A.tok("bark")

-- leaves (behind the twig)
local function leaf(ax, ay, cx, cy, bx, by, w, R, under)
  local m, n, LT, LS = A.blade(ax, ay, cx, cy, bx, by, function(t) return w * sin(pi * min(1, t * 1.03)) ^ 0.6 - 0.1 end, { fold = 0.45 })
  local b = {}
  m:each(function(x, y) local k = K(x, y) if LT[k] < 0.12 then b[k] = -1 end end)
  local tk = A.tok(under and "leafu" or "leaf")
  local idx = A.shade(c, m, n, R, { amb = 0.1, wrap = 0.28, bias = b, tok = tk })
  m:each(function(x, y) local k = K(x, y)
    if abs(LS[k]) < 0.18 and LT[k] > 0.08 and LT[k] < 0.92 then
      c:put(x, y, under and R[max(1, idx[k] - 2)] or R[min(6, idx[k] + 2)], tk) end end)
  return m
end
leaf(22, 17, 14, 22, 9, 35, 3.2, LEAF)
leaf(46, 14, 54, 15, 58, 27, 3.0, SILV, true)
leaf(36, 14, 40, 9, 47, 6, 2.6, LEAF)

-- twig: thin bezier tube, bark ticks, cut end on the right
local tm, tn, TT, TS = A.tube({ { 12, 19 }, { 22, 14 }, { 40, 15 }, { 54, 11 } }, function(t) return 1.55 - t * 0.35 end)
local tidx = A.shade(c, tm, tn, BARK, { amb = 0.15, wrap = 0.3, tok = btok })
tm:each(function(x, y) local k = K(x, y) if X.hash(x, y, 9) > 0.8 and tidx[k] > 1 then A.step(c, tidx, BARK, x, y, -1, btok) end end)
c:put(54, 10, "#d8c49a", btok) c:put(54, 11, "#c0a87c", btok) c:put(55, 11, "#d8c49a", btok)

-- stalks
local function stalk(ax, ay, bx, by)
  local m, n = X.cyl(ax, ay, bx, by, function() return 0.9 end)
  A.shade(c, m, n, { "#3a4a2a", "#627a3a", "#8ea456" }, { amb = 0.2, wrap = 0.35, tok = A.tok("stalk") })
end
stalk(39, 15, 42, 25)
stalk(29, 16, 27, 27)

-- ripe olive (behind)
local rm, rn = A.oval(42, 35, 7, 10.5, -0.25)
local rb = {}
rm:each(function(x, y) local k = K(x, y) if y < 27 then rb[k] = -1 end end)
local ridx = A.shade(c, rm, rn, RIPE, { amb = 0.05, wrap = 0.2, bias = rb, tok = rtok })
-- dusty bloom on the lit half
rm:each(function(x, y) local k = K(x, y) if ridx[k] >= 4 and X.hash(x, y, 2) > 0.8 then c:put(x, y, RIPE[min(6, ridx[k] + 1)], rtok) end end)
c:put(38, 29, RIPE[6], rtok) c:put(39, 29, RIPE[6], rtok) c:put(38, 30, "#e0c6dc", rtok)

-- green olive (front)
local gm, gn = A.oval(27, 39, 9, 12.5, 0.22)
local gb = {}
gm:each(function(x, y) local k = K(x, y) if y < 29 and abs(x - 27) < 3 then gb[k] = -1 end end)
local gidx = A.shade(c, gm, gn, GRN, { amb = 0.05, wrap = 0.22, bias = gb, tok = gtok, cuts = { 0.12, 0.28, 0.48, 0.68, 0.86 } })
-- contact shadow on the ripe olive where the green one overlaps it
local cs = gm:shift(2, 1)
cs:each(function(x, y) if rm:has(x, y) and not gm:has(x, y) then A.step(c, ridx, RIPE, x, y, -2, rtok) end end)
-- cool reflected light lower-right
local rim = X.rim(gn)
gm:edge():each(function(x, y) local k = K(x, y) if rim[k] > 0.7 and y > 40 then c:put(x, y, "#4e7a6a", gtok) end end)
-- specular streak + glint
A.map(c, {
  ".hh.",
  "hss.",
  "hs..",
  "hs..",
  ".h..",
}, 20, 31, { h = GRN[6], s = "#f0f0c0" }, gtok)
c:put(21, 32, A.CREAM, gtok)
-- stalk end dimple
c:put(27, 27, GRN[1], gtok) c:put(28, 27, GRN[2], gtok)

-- quirk: oil bead at the bottom tip
local bx, by = -1, -1
gm:each(function(x, y) if y > by or (y == by and x < bx) then bx, by = x, y end end)
A.map(c, {
  "..o..",
  ".ooO.",
  "ohooO",
  "ohoOd",
  ".OOd.",
}, bx - 2, by + 1, { o = "#f5b82e", O = "#d98322", h = "#fff0a8", d = "#a85e1f" }, A.tok("oil"))
A.save(c, "ico-olive")
