-- giant-toadstool (final pass, Opus single pass). Tall slim fly-agaric: domed glossy red cap with raised cream warts,
-- a dark gill fan under the rim, a drooping skirt ring, fibrous cream stem on a swollen cupped base.
-- Material: per-pixel dome light (6-tone red, violet shade), one wet specular, cool bounce on the lower-right rim,
-- pillow-lit warts, radial gills darkening toward the stem, stem fibre streaks, AO under gills and skirt.
-- quirk: a tiny round gnome door with a gold knob in the stem base.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB34_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, abs, sqrt = math.floor, math.max, math.min, math.abs, math.sqrt
local c = A.new("giant-toadstool")
local RED  = { "#5a1832", "#8c2238", "#c02e37", "#e8493b", "#ff7552", "#ffab7c" }
local STEM = { "#6a4a5a", "#977884", "#c4a9a2", "#e4cfb4", "#f5e6c8", "#fff4d6" }
local GILL = { "#4a2c3c", "#74505a", "#a07c78", "#c9aa94" }
local SPEC, BOUNCE = "#fff4d6", "#a8577a"

c:groundShadow(32, 58, 11, 2)

-- stem: gentle S curve, slim, swelling into a bulb at the base
local stok = { r = { name = "stem" } }
local sm, sn, ST, SS
sm, sn, ST, SS = A.tube({ { 31, 23 }, { 30, 34 }, { 34, 44 }, { 32, 54 } }, function(t) return 3.3 + t * 0.9 end)
local bulb, bn = A.oval(32, 54, 7, 3.6, 0, 1)
local bias = {}
-- AO under the gills (top rows) and under the skirt
sm:each(function(x, y) local k = K(x, y)
  if y <= 25 then bias[k] = -2 elseif y <= 27 then bias[k] = -1 end
  if y >= 34 and y <= 35 then bias[k] = (bias[k] or 0) - 1 end end)
local sidx = A.shade(c, sm, sn, STEM, { amb = 0.12, wrap = 0.3, bias = bias, tok = stok })
-- fibre streaks: short vertical darker dashes
sm:each(function(x, y) local k = K(x, y)
  if y > 27 and SS[k] > -0.7 and SS[k] < 0.75 and X.hash(x, floor(y / 4), 3) > 0.72 and (y % 4) ~= 0 then
    A.step(c, sidx, STEM, x, y, -1, stok) end end)
-- bulb with volva cup (drawn over the stem foot)
bulb:cut(c:rect(0, 0, 63, 51))
local bb = {}
bulb:each(function(x, y) if y <= 52 then bb[K(x, y)] = -1 end end)
local bidx = A.shade(c, bulb, bn, STEM, { amb = 0.1, wrap = 0.25, bias = bb, tok = stok })
-- volva lip: a ragged dark/lit rim line across the bulb
for x = 25, 39 do local y = 53 + ((x % 3 == 0) and 1 or 0)
  if bulb:has(x, y) then c:put(x, y, STEM[2], stok) if bulb:has(x, y - 1) then c:put(x, y - 1, STEM[5], stok) end end end

-- skirt ring (annulus): drooping frill
local sk = c:poly{ { 26.5, 29 }, { 36.5, 29 }, { 38.8, 32 }, { 38.5, 34 }, { 24.5, 34 }, { 24.2, 32 } }
for x = 25, 38 do if (x % 3) == 1 then sk:set(x, 35) end end
local skn = X.pillow(sk, 2.5)
local skb = {}
sk:each(function(x, y) if y == 29 then skb[K(x, y)] = -1 end end)
local kidx = A.shade(c, sk, skn, STEM, { amb = 0.14, wrap = 0.3, bias = skb, tok = stok })
-- frill folds: vertical pleat lines
sk:each(function(x, y) if y >= 31 and (x % 3) == 0 then A.step(c, kidx, STEM, x, y, -1, stok) end end)
for x = 25, 38 do if not sk:has(x, 36) and sm:has(x, 36) then c:put(x, 36, STEM[2], stok) end end

-- gill fan under the rim
local gtok = { r = { name = "gill" } }
local gm = c:ellipse(32, 22.5, 18, 3)
gm:cut(c:rect(0, 0, 63, 21))
gm:each(function(x, y)
  local dx = x - 32
  local d = sqrt((dx / 18) ^ 2 + ((y - 22.5) / 3) ^ 2)
  local i = 2 + ((abs(dx) % 2 == 0) and 1 or 0)
  if d < 0.45 then i = i - 1 end
  if y >= 24 then i = max(1, i - 1) end
  c:put(x, y, GILL[max(1, min(4, i))], gtok)
end)

-- cap: half dome, base at y=22
local ctok = { r = { name = "cap" } }
local CX, CY, RX, RY = 32, 22, 21, 13
local cm, cn = HP.mask(), {}
for y = CY - RY - 1, CY do for x = CX - RX - 1, CX + RX + 1 do
  local u, v = (x - CX) / (RX + 0.5), (y - CY + 0.5) / (RY + 0.5)
  local q = u * u + v * v
  if q <= 1 then cm:set(x, y) cn[K(x, y)] = { A.norm(u * 0.9, v * 1.05 - 0.05, sqrt(max(1 - q, 0.03)) * 1.15) } end
end end
local cb = {}
cm:each(function(x, y) if y == CY then cb[K(x, y)] = -1 end end)
local cidx, cv = A.shade(c, cm, cn, RED, { amb = 0.05, wrap = 0.2, bias = cb, tok = ctok })
-- cool bounce on lower-right rim
local rim = X.rim(cn)
cm:edge():each(function(x, y) local k = K(x, y) if rim[k] > 0.62 and x > CX + 8 and y > CY - 6 then c:put(x, y, BOUNCE, ctok) end end)
-- rolled rim lip: lit top line just above the dark bottom row on the left half
for x = CX - 17, CX + 4 do if cm:has(x, CY - 1) and cidx[K(x, CY - 1)] then A.step(c, cidx, RED, x, CY - 1, 1, ctok) end end

-- warts: raised cream flecks, pillow-lit, with a dark red seat on their lower-right
local wtok = { r = { name = "wart" } }
local warts = { { 22, 14, 1.6, 1.0 }, { 31, 11, 1.8, 1.1 }, { 40, 13, 1.5, 1.0 }, { 16, 19, 1.2, 0.8 }, { 27, 18, 1.4, 0.9 },
  { 37, 19, 1.3, 0.8 }, { 46, 18, 1.1, 0.8 }, { 49, 20, 0.7, 0.6 }, { 13, 21, 0.6, 0.5 }, { 34, 15.5, 0.6, 0.5 } }
for _, w in ipairs(warts) do
  local wm, wn = A.oval(w[1], w[2], w[3], w[4], 0, 0.8)
  wm:clip(cm)
  wm:shift(1, 1):each(function(x, y) if cm:has(x, y) and not wm:has(x, y) then A.step(c, cidx, RED, x, y, -2, ctok) end end)
  A.shade(c, wm, wn, { STEM[3], STEM[4], STEM[5], STEM[6] }, { cuts = { 0.25, 0.5, 0.72 }, amb = 0.2, wrap = 0.4, tok = wtok })
end
-- wet specular on the upper-left dome
c:put(19, 11, RED[6], ctok) c:put(20, 11, SPEC, ctok) c:put(21, 10, RED[6], ctok) c:put(18, 12, RED[6], ctok)

-- quirk: tiny gnome door in the stem base (arched, plank lines, gold knob, step)
local DX, DY = 32, 47
local door = {
  ".kkk.",
  "kWwWk",
  "kWwWk",
  "kWwWk",
  "kWwgk",
  "kWwWk",
}
A.map(c, door, DX - 2, DY, { k = "#3a2230", W = "#864c33", w = "#5e3528", g = "#ffd25a" }, stok)
c:put(DX - 2, DY + 6, STEM[2], stok) c:put(DX - 1, DY + 6, STEM[3], stok) c:put(DX, DY + 6, STEM[3], stok)
c:put(DX + 1, DY + 6, STEM[3], stok) c:put(DX + 2, DY + 6, STEM[2], stok)
A.save(c, "giant-toadstool")
