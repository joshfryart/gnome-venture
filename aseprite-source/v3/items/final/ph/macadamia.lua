-- macadamia (final pass, Opus aC21_5). A slim woody twig on the diagonal with one narrow spiny-toothed macadamia
-- leaf sweeping up-left and two nuts hanging on short pedicels with air between them: the left nut still in its
-- leathery green husk, split open at the lower right to show the brown shell inside (pale pithy lip, deep AO in the
-- gap); the right nut bare, a glossy tan-brown ball with a pale hilum scar, a faint suture line and pitted speckle.
-- Material: wood tube light + end-grain cap with ring, leaf V fold + pale midrib + veins, husk matte with lenticel
-- dots, shell 6-tone sphere with one specular and a cool reflected rim. AO where pedicels meet the twig.
-- History: Sonnet draft (dC21) replaced.
-- quirk: a hairline crack in the bare shell with a sliver of cream kernel peeking out.
local NAME = "macadamia"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC21_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)

local WOOD  = { "#3a2226", "#5a3528", "#7e4e32", "#a06a40", "#c48c58", "#e2b480" }
local LEAF  = { "#16382e", "#1f5038", "#2c6a40", "#43874a", "#66a656", "#94c46c" }
local HUSK  = { "#1c4430", "#2a5e38", "#3e7c40", "#5c9a48", "#86ba5a", "#b4d67a" }
local SHELL = { "#3a2018", "#5c3220", "#82502e", "#a8703e", "#cc9658", "#ecc488" }
local PITH, COOL, VEIN = "#dfe6a6", "#5a6a8a", "#c2e48c"
local KERN = { "#c8a870", "#ead6a4", "#fff4d6" }

-- leaf (behind): narrow, spiny toothed margin
local lm, ln, LT, LS, len = A.blade(33, 21, 22, 9, 8, 13, function(t)
  if t > 0.985 then return -1 end
  return max(0.5, 3.6 * sin(pi * min(1, t * 0.9 + 0.1)) ^ 0.6)
end, { fold = 0.45 })
local cut = {}
lm:each(function(x, y) local k = K(x, y)
  local ph = (LT[k] * len) / 4.2 + (LS[k] > 0 and 0.5 or 0)
  local f = ph - floor(ph)
  -- saw tooth: shallow notch behind each spine tip
  if abs(LS[k]) > 0.55 + 0.4 * f and LT[k] > 0.12 and LT[k] < 0.92 then cut[#cut + 1] = k end
end)
for _, k in ipairs(cut) do lm.s[k] = nil end
local ltok = { r = { name = "leaf" } }

-- twig
local tw = { { 53, 9 }, { 46, 13 }, { 38, 18 }, { 29, 24 } }
local wm, wn, WT, WS = A.tube(tw, function(t) return 1.7 - 0.3 * t end)
local wtok = { r = { name = "twig" } }
-- pedicels
local pa = { { 31, 23 }, { 28, 27 }, { 24, 29 }, { 22, 32 } }
local pb = { { 40, 18 }, { 41, 24 }, { 41, 30 }, { 41, 37 } }
local am, an = A.tube(pa, function(t) return 1.05 end)
local bm, bn = A.tube(pb, function(t) return 1.05 end)

-- nuts
local NA = { 20, 41, 9 }
local NB = { 41, 45, 7.6 }
local hm = c:ellipse(NA[1], NA[2], NA[3], NA[3])
local sm = c:ellipse(NB[1], NB[2], floor(NB[3] + .5), floor(NB[3] + .5))

-- leaf tone with AO under twig
local lb = {}
X.ao(lb, lm, wm, 1, -1) A.cast(lb, lm, wm, 1, 2, -1)
local _, lv = A.shade(c, lm, ln, LEAF, { bias = lb, tok = ltok, amb = 0.14, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y)
  if lb[k] then return end
  local s, t = LS[k], LT[k]
  if abs(s) < 0.16 and t < 0.94 then c:put(x, y, s <= 0 and VEIN or LEAF[3], ltok) return end
  local ph = (t * len - abs(s) * 3.0) / 4.2 + (s > 0 and 0.5 or 0)
  local f = ph - floor(ph)
  if f > 0.86 and abs(s) > 0.2 and abs(s) < 0.6 and t > 0.1 and t < 0.86 then c:put(x, y, s < 0 and LEAF[5] or LEAF[2], ltok) end
end)

-- twig tone, AO where pedicels join
local tb = {}
X.ao(tb, wm, am, 1, -1) X.ao(tb, wm, bm, 1, -1)
local tidx = A.shade(c, wm, wn, WOOD, { bias = tb, tok = wtok, amb = 0.1, wrap = 0.3 })
-- bark grain: short dark dashes along the twig
for i = 2, 18 do local t = i / 20 local x, y = A.bez(tw, t)
  if i % 3 == 0 then c:put(floor(x + .5), floor(y + 1.3), WOOD[2], wtok) end end
-- end grain cap (cut end, upper right)
c:put(53, 8, WOOD[6], wtok) c:put(54, 9, WOOD[5], wtok) c:put(53, 9, WOOD[4], wtok) c:put(54, 8, WOOD[6], wtok)
c:put(53, 10, WOOD[5], wtok)
-- bud node
c:put(45, 11, WOOD[5], wtok) c:put(46, 11, WOOD[4], wtok) c:put(45, 12, WOOD[4], wtok)

for _, p in ipairs{ { am, an, "pa" }, { bm, bn, "pb" } } do
  local m = p[1]:copy():cut(wm)
  A.shade(c, m, p[2], WOOD, { tok = { r = { name = p[3] } }, amb = 0.12, wrap = 0.3 })
end

-- husked nut (left)
local htok = { r = { name = "husk" } }
local hn = X.sphere(NA[1], NA[2], NA[3], hm)
local open = A.rell(25, 45, 0.707, 0.707, 3.4, 6.2)
open:clip(hm)
local hb = {}
X.ao(hb, hm, am, 1, -1)
local husk = hm:copy():cut(open)
A.shade(c, husk, hn, HUSK, { bias = hb, tok = htok, amb = 0.1, wrap = 0.25 })
-- husk suture seam (across the top) + lenticel dots
for x = 13, 20 do local y = floor(35 - (x - 13) * 0.25 + 0.5) if husk:has(x, y) then c:put(x, y, HUSK[2], htok) end end
husk:each(function(x, y) local h = X.hash(x, y, 7)
  if h > 0.93 and not husk:edge():has(x, y) then c:put(x, y, HUSK[6], htok) end end)
-- shell inside the split
local stok2 = { r = { name = "innershell" } }
local inn = X.sphere(23, 43, 7, open)
local ib = {}
open:each(function(x, y)
  -- near (lower-right) lip casts AO onto the inner shell
  if not hm:has(x + 1, y + 1) or not open:has(x + 1, y + 1) then ib[K(x, y)] = -2 end
end)
A.shade(c, open, inn, SHELL, { bias = ib, tok = stok2, amb = 0.15, wrap = 0.3 })
-- pithy lip on the far (upper-left) side of the opening
open:grow(1):cut(open):clip(husk):each(function(x, y)
  if not open:has(x + 1, y + 1) and not open:has(x, y + 1) and not open:has(x + 1, y) then return end
  if open:has(x + 1, y + 1) or open:has(x + 1, y) or open:has(x, y + 1) then
    c:put(x, y, (x + y) % 5 == 0 and HUSK[5] or PITH, htok) end end)
c:put(24, 42, SHELL[6], stok2)
-- reflected cool light on husk shade rim
husk:edge():each(function(x, y) local dx, dy = x - NA[1], y - NA[2]
  if dx + dy > 10 and not open:grow(1):has(x, y) then c:put(x, y, COOL, htok) end end)

-- bare shell nut (right)
local btok = { r = { name = "shell" } }
local bnrm = X.sphere(NB[1], NB[2], NB[3], sm)
local bb = {}
X.ao(bb, sm, bm, 1, -1)
local sidx = A.shade(c, sm, bnrm, SHELL, { bias = bb, tok = btok, amb = 0.08, wrap = 0.25, cuts = { 0.16, 0.32, 0.5, 0.68, 0.85 } })
-- pitted speckle
sm:each(function(x, y) local k = K(x, y)
  if X.hash(x, y, 3) > 0.9 and (sidx[k] or 1) > 2 then A.step(c, sidx, SHELL, x, y, -1, btok) end end)
-- suture: faint pale arc from hilum down the lit side
for y = 39, 50 do local x = floor(NB[1] - 1 - 3.2 * sin((y - 38) / 13 * pi) + .5)
  if sm:has(x, y) then local i = sidx[K(x, y)] or 3 c:put(x, y, SHELL[min(6, i + 1)], btok) end end
-- hilum scar where the pedicel meets the shell
c:put(40, 38, SHELL[6], btok) c:put(41, 38, KERN[3], btok) c:put(42, 38, SHELL[5], btok)
c:put(41, 39, SHELL[4], btok)
-- specular
local gx, gy = A.specAt(sm, bnrm, 50)
c:put(gx, gy, KERN[3], btok) c:put(gx + 1, gy, SHELL[6], btok)
-- cool reflected rim
sm:edge():each(function(x, y) local dx, dy = x - NB[1], y - NB[2]
  if dx + dy > 8.5 then c:put(x, y, COOL, btok) end end)
-- quirk: hairline crack with kernel sliver
for _, q in ipairs{ { 46, 43, 1 }, { 45, 44, 1 }, { 45, 45, 0 }, { 44, 46, 1 }, { 44, 47, 0 } } do
  c:put(q[1], q[2], SHELL[1], btok) end
c:put(46, 44, KERN[2], btok) c:put(46, 45, KERN[1], btok) c:put(45, 46, KERN[2], btok)

A.save(c, "ph", NAME)
