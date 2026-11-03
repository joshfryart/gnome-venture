-- ico-onion (final pass, Opus single pass). Bold icon: a golden-brown bulb onion, broad low shoulders tapering
-- up into a slim dried neck that twists to a frayed tip, a dark basal plate with a tuft of pale roots below.
-- Per-pixel light (sphere + pillow blend, 6-tone papery gold-brown, cool-violet shade), papery meridian striations
-- with a lit sheen beside each, a torn patch of skin on the lower left showing the glossy cream-violet flesh layer
-- under a ragged dark edge, cool reflected light lower-right, AO where the neck meets the bulb. Neck: twist bands.
-- quirk: a single blue tear floats beside the onion (it makes everyone cry, even itself).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA7_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, sqrt, abs, sin, pi, asin = math.floor, math.max, math.min, math.sqrt, math.abs, math.sin, math.pi, math.asin
local c = A.new("ico-onion")
local SKIN  = { "#4e2226", "#7e3a24", "#ae5c2a", "#d6853a", "#eeac58", "#ffd68e" }
local NECK  = { "#4a2a24", "#7a4c30", "#a8784a", "#d2a86e" }
local FLESH = { "#a88496", "#d4b8be", "#f2e2d6", "#fff6ea" }
local ROOT  = { "#7a5a44", "#b08e6a", "#e0c89c" }
local stok, ntok, ftok = A.tok("skin"), A.tok("neck"), A.tok("flesh")

-- roots first (bulb paints over their tops)
local rtk = A.tok("root")
for i, r in ipairs{ { 28, 25, 58 }, { 30, 29, 59 }, { 32, 33, 59 }, { 34, 36, 58 }, { 36, 40, 56 }, { 30, 27, 56 } } do
  local m = c:line({ { r[1], 51 }, { (r[1] + r[2]) / 2, 55 }, { r[2], r[3] } }, 1)
  m:each(function(x, y) c:put(x, y, (x + y) % 3 == 0 and ROOT[1] or (i % 2 == 0 and ROOT[3] or ROOT[2]), rtk) end)
end
local plate = c:ellipse(32, 52, 4, 1.5)
c:fillMask(plate, NECK[1])
c:put(30, 52, NECK[2]) c:put(31, 52, NECK[2])

-- bulb
local function hw(y)
  if y <= 40 then return 2.8 + 12.2 * sin(max(0, (y - 22) / 18) * pi / 2) ^ 1.15 end
  return 15 * sqrt(max(0, 1 - ((y - 40) / 12.8) ^ 2.2))
end
local m, U = A.lathe(22, 52, function(y) return 32 end, hw)
local ns = X.sphere(31, 39, 15, m)
local np = X.pillow(m, 4)
local n = A.blend(ns, np, 0.35)
local bias = {}
m:each(function(x, y) local k = K(x, y) if y < 26 then bias[k] = -1 end end)
local idx = A.shade(c, m, n, SKIN, { amb = 0.03, wrap = 0.22, bias = bias, tok = stok, cuts = { 0.15, 0.33, 0.52, 0.7, 0.87 } })
-- papery striations: meridians, dark line + lit sheen on its left
m:each(function(x, y) local k = K(x, y)
  if y > 24 and y < 51 then
    local f = asin(max(-1, min(1, U[k]))) / (pi / 2) * 3.5
    local d = f - floor(f + 0.5)
    if abs(d) < 0.13 then A.step(c, idx, SKIN, x, y, (idx[k] >= 4 and -2 or -1), stok)
    elseif d > -0.3 and d < -0.13 and idx[k] >= 3 and idx[k] <= 5 and X.hash(x, y, 8) > 0.5 then A.step(c, idx, SKIN, x, y, 1, stok) end
  end
end)
-- cool reflected light lower-right
local rim = X.rim(n)
m:edge():each(function(x, y) local k = K(x, y) if rim[k] > 0.68 and y > 40 and x > 32 then c:put(x, y, "#8a4a64", stok) end end)
-- glossy skin highlight
A.map(c, {
  "..hh",
  ".hs.",
  "hs..",
  "h...",
}, 21, 31, { h = SKIN[6], s = "#fff0c4" }, stok)
c:put(22, 32, A.CREAM, stok)

-- torn patch on the lower left: flesh layer under a ragged dark edge
local pm = c:ellipse(24.5, 44, 4, 3):add(c:ellipse(27, 46, 3, 2)):clip(m:shrink(2))
pm:cut(c:rect(20, 40, 21, 41))
local pn = X.sphere(23.5, 43, 5, pm)
local pidx = A.shade(c, pm, pn, FLESH, { amb = 0.15, wrap = 0.35, tok = ftok })
-- one layer ring inside the flesh + glint
pm:each(function(x, y) local dx, dy = (x - 26) / 4, (y - 46) / 3 if abs(dx * dx + dy * dy - 1) < 0.18 then A.step(c, pidx, FLESH, x, y, -1, ftok) end end)
c:put(23, 42, FLESH[4], ftok) c:put(22, 43, FLESH[4], ftok)
pm:grow(1):cut(pm):clip(m):each(function(x, y) c:put(x, y, (y < 43 and x < 27) and SKIN[6] or (X.hash(x, y, 3) > 0.6 and SKIN[2] or SKIN[1]), stok) end)

-- curled-back flap of torn skin sticking out at the patch's upper-left
A.map(c, {
  ".hh..",
  "hSSs.",
  ".hSdd",
  "..sd.",
}, 15, 39, { h = SKIN[6], S = SKIN[5], s = SKIN[3], d = SKIN[1] }, A.tok("flap"))
-- neck: dried twisted top, leans right, frayed tip
local nm, nn, NT, NS = A.tube({ { 32, 25 }, { 32, 20 }, { 33, 16 }, { 35, 12 } }, function(t) return 2.6 - t * 0.8 end)
nm:cut(m:shrink(1))
local nidx = A.shade(c, nm, nn, NECK, { amb = 0.15, wrap = 0.3, tok = ntok })
nm:each(function(x, y) local k = K(x, y)
  if (NT[k] * 14 + NS[k] * 1.6) % 2.4 < 0.75 then A.step(c, nidx, NECK, x, y, -1, ntok) end end)
c:put(35, 10, NECK[3], ntok) c:put(37, 10, NECK[2], ntok) c:put(36, 11, NECK[2], ntok) c:put(35, 11, NECK[4], ntok)
-- AO where neck meets bulb
for x = 29, 35 do if idx[K(x, 24)] then A.step(c, idx, SKIN, x, 24, -1, stok) end end

-- quirk: a tear beside the onion
A.map(c, {
  ".b..",
  ".b..",
  "bhb.",
  "hBbb",
  "BBbd",
  ".dd.",
}, 47, 20, { b = "#5fc4c8", B = "#b6f0e0", h = "#e4fbf4", d = "#3a86b0" }, A.tok("tear"))
A.save(c, "ico-onion")
