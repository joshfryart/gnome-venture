-- shea (D15, final pass, Sonnet). A slim barky twig rises from the lower left and ends in a fan of three long glossy, closely
-- parallel-veined leaves; two plum-like fruit hang from it on thin stalks: one whole (green olive skin, waxy bloom, pale
-- lenticels, calyx cup, tiny pistil nub) and one cut open (skin ring, creamy flesh, big glossy brown nut with a pale scar).
-- Per-pixel light on every part (6 tones), cool reflected light on the fruit shade side, contact shadows where the nut sits in
-- the flesh and where the stalks and leaves meet the twig.
-- quirk: a bead of creamy shea butter is oozing off the cut fruit.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD15_3.lua")
local HP, X, K, G = A.HP, A.X, A.K, A
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new("shea")

local LEAF = { "#12332f", "#1b4d3a", "#276a42", "#388a48", "#58a852", "#8cc968" }
local OLIVE = { "#26361a", "#3d5620", "#5b7a2a", "#83a038", "#abc058", "#d4e48c" }
local FLESH = { "#6a6a30", "#8e9244", "#b4bb62", "#d2d985", "#eaedb0", "#fbfbd8" }
local NUT = { "#2a1616", "#4a2622", "#6e3a2a", "#975433", "#bd7a46", "#e2b078" }
local SCAR = { "#8a6a46", "#b08a58", "#cfae78", "#e6cf9c", "#f6e6bc", "#fff6dc" }
local BARK = { "#2e1c1c", "#4f2d26", "#74422f", "#9a5d3a", "#bc8250", "#dcb07a" }
local BUTTER = { "#c8a248", "#e4c366", "#f6dc88", "#fff0b4" }
local ltok, ftok, ntok, btok = { r = { name = "leaf" } }, { r = { name = "fruit" } }, { r = { name = "nut" } }, { r = { name = "bark" } }

-- twig -----------------------------------------------------------------------------------------------------------
local twig = { { 9, 28 }, { 17, 23 }, { 30, 24 }, { 43, 17 } }
local tm, tn, TT, TS, tidx = G.stem(c, twig, function(t) return 2.0 - 0.7 * t end, BARK, { tok = btok, amb = 0.1, wrap = 0.28 })
-- bark: short dark fissures + a pale lenticel flecks
tm:each(function(x, y) local k = K(x, y)
  local t, s = TT[k], TS[k]
  if abs(s) < 0.6 and X.hash(x, y, 3) > 0.84 and t > 0.05 then c:put(x, y, BARK[max(1, (tidx[k] or 3) - 1)], btok) end
  if s < -0.15 and s > -0.6 and X.hash(x, y, 9) > 0.9 then c:put(x, y, BARK[min(6, (tidx[k] or 3) + 1)], btok) end
end)
-- fresh-cut left end: pale end grain with a ring
c:px(8, 27, SCAR[4]) c:px(8, 28, SCAR[3]) c:px(9, 28, SCAR[2]) c:px(8, 29, SCAR[2]) c:px(9, 27, SCAR[5])
-- side knot
c:px(24, 26, BARK[1]) c:px(25, 26, BARK[2]) c:px(24, 25, BARK[3])

-- leaf fan (painted before the twig tip node) ----------------------------------------------------------------------
local function sheaLeaf(ax, ay, cx, cy, bx, by, w)
  return G.leaf(c, ax, ay, cx, cy, bx, by, w, LEAF, { vs = 2.6, pw = 0.62, tok = ltok })
end
sheaLeaf(43, 17, 36, 7, 27, 6, 4.4)          -- up-left
sheaLeaf(43, 16, 46, 4, 54, 2.5, 4.6)        -- up-right
local lr = sheaLeaf(43, 18, 52, 15, 58, 22, 4.4) -- right, drooping
-- bud node where the leaves leave the twig
local node = c:ellipse(43, 17.5, 2.2, 2.2)
G.shade(c, node, X.sphere(42.4, 17, 2.4, node), BARK, { tok = btok })
c:px(40, 16, BARK[1]) c:px(41, 20, BARK[1])
-- dark contact row under the leaf bases
c:px(44, 19, LEAF[1]) c:px(45, 19, LEAF[1]) c:px(41, 18, LEAF[1])

-- fruit helpers ---------------------------------------------------------------------------------------------------
local function stalk(x0, y0, x1, y1, bow)
  G.stem(c, { { x0, y0 }, { x0 + bow, (y0 + y1) / 2 - 1 }, { x1 - bow, (y0 + y1) / 2 + 1 }, { x1, y1 } }, function(t) return 1.05 end, BARK, { tok = btok, amb = 0.12 })
end
-- contact shadow of a stalk on the twig
c:px(19, 25, BARK[1]) c:px(20, 25, BARK[1]) c:px(35, 22, BARK[1]) c:px(36, 22, BARK[1])

-- WHOLE FRUIT ---------------------------------------------------------------------------------------------------------
stalk(19, 24, 19, 33, 1.2)
local W = { cx = 19, cy = 42, rx = 8, ry = 9 }
local fm = c:ellipse(W.cx, W.cy, W.rx, W.ry)
fm:add(c:ellipse(W.cx + 0.5, W.cy + W.ry - 0.5, 1.6, 1.6))      -- little pistil point at the base
local fn = {}
do
  local ns = X.sphere(W.cx, W.cy, 8.8, fm)
  local np = X.pillow(fm, 6)
  for k, a in pairs(ns) do local b = np[k]
    fn[k] = { A.norm(a[1] * 0.65 + b[1] * 0.35, a[2] * 0.65 + b[2] * 0.35, a[3] * 0.65 + b[3] * 0.35) } end
end
local fbias = {}
-- a faint crease from the shoulder (suture) running down the shade side
local fidx, fv = G.shade(c, fm, fn, OLIVE, { amb = 0.08, wrap = 0.26, bias = fbias, tok = ftok })
fm:each(function(x, y) local k = K(x, y)
  local dx, dy = x - W.cx, y - W.cy
  -- suture line: curved groove, slightly right of centre
  local gx = W.cx + 3.2 + 1.4 * sin((y - W.cy) / 5.0)
  if abs(x - gx) < 0.45 and y > W.cy - 5 and y < W.cy + 8 then c:put(x, y, OLIVE[max(1, (fidx[k] or 3) - 1)], ftok) end
  -- waxy bloom: pale blue-grey haze on the lit shoulder
  if fv[k] > 0.55 and dx < 1 and dy < -1 and X.hash(x, y, 5) > 0.55 then c:put(x, y, "#c4e0b0", ftok) end
end)
-- cool reflected light on the lower-right rim
do local rim = X.rim(fn)
  fm:edge():each(function(x, y) local k = K(x, y)
    if rim[k] > 0.75 and x > W.cx + 1 and y > W.cy - 2 and y < W.cy + 7 then c:put(x, y, "#5a9a7a", ftok) end end)
end
-- lenticels: tiny pale freckles
for _, p in ipairs{ { 16, 43 }, { 20, 38 }, { 23, 45 }, { 14, 48 }, { 19, 49 }, { 22, 41 }, { 17, 37 } } do
  if fm:has(p[1], p[2]) then c:px(p[1], p[2], OLIVE[5]) end
end
-- specular: 2x1 hi + one cream sparkle
c:px(14, 36, OLIVE[6]) c:px(15, 36, OLIVE[6]) c:px(13, 38, OLIVE[6]) c:px(14, 35, "#fbfbe8")
-- calyx cup + pistil nub
for _, p in ipairs{ { 17, 33 }, { 18, 33 }, { 19, 33 }, { 20, 33 }, { 21, 33 }, { 18, 34 }, { 19, 34 }, { 20, 34 } } do c:px(p[1], p[2], BARK[3]) end
c:px(17, 33, BARK[4]) c:px(18, 33, BARK[5]) c:px(21, 33, BARK[2]) c:px(20, 34, BARK[2]) c:px(19, 34, BARK[2])
c:px(20, 51, BARK[2]) c:px(19, 51, BARK[3])

-- CUT FRUIT ----------------------------------------------------------------------------------------------------------------
stalk(35, 22, 37, 28, -1.0)
local Cx, Cy, Cr = 38, 37, 8.6
local cm = c:ellipse(Cx, Cy, Cr, Cr)
local cn = X.sphere(Cx, Cy, Cr, cm)
-- outer skin ring (the tilted shoulder of the skin shows as a rounded rim)
local inner = cm:shrink(2)
local ring = cm:copy():cut(inner)
local nr = {}
ring:each(function(x, y) nr[K(x, y)] = cn[K(x, y)] end)
G.shade(c, ring, nr, OLIVE, { amb = 0.08, wrap = 0.3, tok = ftok })
-- flesh face: flat plane, lit by wrap, with a soft shadow cast by the skin lip on the upper left
local fl = inner
local fln = {}
fl:each(function(x, y) local k = K(x, y)
  local dx, dy = (x - Cx) / Cr, (y - Cy) / Cr
  fln[k] = { A.norm(dx * 0.28, dy * 0.28, 1) } end)
local flbias = {}
-- nut footprint shadow + skin lip shadow
local nutm = c:ellipse(Cx + 0.5, Cy + 0.6, 4.4, 5.4)
X.ao(flbias, fl, nutm, 1, -1)
nutm:shift(1, 1):each(function(x, y) if fl:has(x, y) and not nutm:has(x, y) then flbias[K(x, y)] = (flbias[K(x, y)] or 0) - 1 end end)
fl:each(function(x, y) local k = K(x, y)
  local dx, dy = x - Cx, y - Cy
  if dx + dy < -6 then flbias[k] = (flbias[k] or 0) - 1 end end)
local flidx = G.shade(c, fl, fln, FLESH, { amb = 0.36, wrap = 0.5, bias = flbias, cuts = { 0.3, 0.46, 0.6, 0.74, 0.88 }, tok = ftok })
-- fibre flecks in the flesh
fl:each(function(x, y) local k = K(x, y)
  local dx, dy = x - Cx, y - Cy
  local r = sqrt(dx*dx + dy*dy)
  if r > 5.2 and r < 6.2 and X.hash(x, y, 2) > 0.62 then c:put(x, y, FLESH[max(1, (flidx[k] or 3) - 1)], ftok) end
end)
-- the nut: glossy brown, with a pale scar on its flank
local nn = {}
do local ns = X.sphere(Cx + 0.2, Cy + 0.3, 5.0, nutm)
  local np = X.pillow(nutm, 4)
  for k, a in pairs(ns) do local b = np[k]
    nn[k] = { A.norm(a[1] * 0.7 + b[1] * 0.3, a[2] * 0.7 + b[2] * 0.3, a[3] * 0.7 + b[3] * 0.3) } end
end
local nidx = G.shade(c, nutm, nn, NUT, { amb = 0.06, wrap = 0.24, tok = ntok })
-- scar on the lower-right of the nut
local scar = c:ellipse(Cx + 1.8, Cy + 2.6, 2.1, 2.7):clip(nutm)
scar:each(function(x, y)
  local dx, dy = (x - Cx - 1.8) / 2.4, (y - Cy - 2.6) / 3
  local v = max(0, min(1, 0.7 - dx * 0.4 - dy * 0.35))
  c:put(x, y, SCAR[2 + floor(v * 3.99)], ntok) end)
c:px(Cx + 1, Cy + 4, SCAR[1]) c:px(Cx + 2, Cy + 5, SCAR[1])
-- nut spec streak
c:px(Cx - 2, Cy - 3, NUT[6]) c:px(Cx - 1, Cy - 3, NUT[6]) c:px(Cx - 3, Cy - 2, NUT[5]) c:px(Cx - 2, Cy - 4, "#fff4d6")
-- skin lip inner dark row where flesh meets the skin ring (lower-right gets lit rim)
inner:edge():each(function(x, y) local k = K(x, y)
  if x + y > Cx + Cy + 3 then c:px(x, y, FLESH[6]) elseif x + y < Cx + Cy - 6 then c:px(x, y, OLIVE[2]) end end)
-- cool reflected light on the skin ring, lower-right
do local rim = X.rim(cn)
  ring:each(function(x, y) local k = K(x, y)
    if rim[k] > 0.8 and cm:edge():has(x, y) then c:put(x, y, "#5a9a7a", ftok) end end)
end
-- skin spec on the shoulder
c:px(Cx - 6, Cy - 4, OLIVE[6]) c:px(Cx - 5, Cy - 5, OLIVE[6]) c:px(Cx - 4, Cy - 6, OLIVE[5])
-- calyx cap on top
for _, p in ipairs{ { 36, 28 }, { 37, 28 }, { 38, 28 }, { 37, 29 } } do c:px(p[1], p[2], BARK[3]) end
c:px(36, 28, BARK[4]) c:px(38, 28, BARK[2])

-- quirk: a bead of butter oozing off the cut face, hanging below the rim
do
  local bx, by = 40, 46
  c:px(bx + 1, by - 1, FLESH[4]) c:px(bx + 1, by, BUTTER[2])
  c:px(bx, by + 1, BUTTER[2]) c:px(bx + 1, by + 1, BUTTER[3]) c:px(bx + 2, by + 1, BUTTER[1])
  c:px(bx, by + 2, BUTTER[3]) c:px(bx + 1, by + 2, BUTTER[4]) c:px(bx + 2, by + 2, BUTTER[2])
  c:px(bx, by + 3, BUTTER[2]) c:px(bx + 1, by + 3, BUTTER[2]) c:px(bx + 2, by + 3, BUTTER[1])
  c:px(bx + 1, by + 4, BUTTER[1])
end
A.save(c, "shea")
