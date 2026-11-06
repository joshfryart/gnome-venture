-- lemon (final, Opus single pass). A slim tilted lemon: ellipsoid with a pointed nipple at the lower-left end and a
-- green stem button at the upper-right, short woody twig and one glossy leaf. Per-pixel light (6-tone yellow), pitted
-- peel (pore specks), waxy bloom on the lit shoulder, one cream specular + glint, cool green reflected light on the
-- shade side, AO under the calyx and contact shadow from the leaf. Leaf: midrib + angled veins, cool edge.
-- quirk: a tiny ladybird walking up the leaf.
local NAME = "lemon"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC15_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)

local YEL  = { "#6c4a35", "#a8702c", "#d99d24", "#f3c72f", "#fde25a", "#fff3a2" }
local LEAF = { "#173d3a", "#22593f", "#2f7848", "#479a4f", "#6fbb5a", "#a2d673" }
local TWIG = { "#4a2e28", "#7a5034", "#a8784a", "#d0a46c" }
local BOUNCE, SPEC, NIP = "#b9c682", "#fffbe8", "#bfc04a"

-- body: rotated ellipsoid with a nipple at the -u end
local CX, CY, RX, RY, ANG = 30, 37, 15.5, 10.6, -0.4
local ux, uy = cos(ANG), sin(ANG)
local px, py = -uy, ux
local function hw(a)
  local e = (abs(a) <= RX) and RY * sqrt(1 - (a / RX)^2) ^ 0.92 or 0
  if a < -RX + 2.5 then e = max(e, 2.4 - 0.85 * (-a - RX + 2.5)) end   -- nipple
  if a > RX - 1.5 then e = max(e, 3.2 - 1.6 * (a - RX + 1.5)) end      -- blunt stem end
  return e
end
local body, n, AU = HP.mask(), {}, {}
for y = CY - 22, CY + 22 do for x = CX - 24, CX + 24 do
  local dx, dy = x - CX, y - CY
  local a, b = dx * ux + dy * uy, dx * px + dy * py
  local h = hw(a)
  if h > 0 and abs(b) <= h then
    body:set(x, y)
    local sb = b / (h + 0.6)
    local sa = a / (RX + 4)
    local nx, ny = ux * sa * 0.8 + px * sb, uy * sa * 0.8 + py * sb
    local nz = sqrt(max(0.03, 1 - sb * sb - (sa * 0.8)^2))
    n[K(x, y)] = { A.norm(nx, ny, nz) }
    AU[K(x, y)] = a
  end
end end

-- stem end position
local SX, SY = floor(CX + ux * (RX + 0.5) + 0.5), floor(CY + uy * (RX + 0.5) + 0.5)

-- leaf + twig masks first (for AO / contact shadow)
local tw = { { SX, SY }, { SX + 1, SY - 2 }, { SX + 2, SY - 3 }, { SX + 3, SY - 5 } }
local bias = {}
local lm, ln, LT, LS, llen = A.blade(SX + 3, SY - 5, SX + 6, SY - 17, SX - 6, SY - 21, function(t)
  if t > 0.985 then return -1 end
  return max(0.4, 4.2 * sin(pi * min(1, t * 0.97 + 0.03)) ^ 0.7)
end, { fold = 0.42 })
lm:cut(body)
-- AO on the lemon around the stem button, and leaf contact shadow
X.ao(bias, body, c:ellipse(SX, SY, 2, 2), 2, -1)
A.cast(bias, body, lm, 1, 2, -1)

-- paint lemon
local v = X.light(n, { amb = 0.06, wrap = 0.22 })
local idx = X.tone(c, body, v, YEL, { cuts = { 0.16, 0.32, 0.5, 0.68, 0.85 }, bias = bias, tok = { r = { name = "lemon" } } })
local ltok = { r = { name = "lemon" } }
-- pitted peel: small pores one tone darker on the lit side, one lighter speck in the shade
body:shrink(1):each(function(x, y) local k = K(x, y) local i = idx[k]
  local h = X.hash(x, y, 7)
  if i >= 4 and h > 0.82 then A.step(c, idx, YEL, x, y, -1, ltok)
  elseif i == 3 and h > 0.9 then A.step(c, idx, YEL, x, y, 1, ltok) end
end)
-- waxy bloom: pale speckle across the brightest band
body:shrink(2):each(function(x, y) local k = K(x, y)
  if idx[k] == 5 and X.hash(x, y, 19) > 0.8 then c:put(x, y, YEL[6], ltok) end end)
-- cool reflected light lower-right
local rim = X.rim(n)
body:edge():each(function(x, y) local k = K(x, y)
  if rim[k] > 0.55 and not bias[k] and (idx[k] or 1) <= 3 and AU[k] > -RX + 2 then c:put(x, y, BOUNCE, ltok) end end)
-- nipple tip greener
body:each(function(x, y) local k = K(x, y) if AU[k] < -RX - 0.2 then c:put(x, y, (idx[k] or 3) >= 4 and NIP or "#8f8a32", ltok) end end)
-- specular: 2x1 cream + 1px glint
local sx, sy = A.specAt(body, n, 30)
c:put(sx, sy, SPEC, ltok) c:put(sx + 1, sy, SPEC, ltok) c:put(sx - 2, sy + 2, YEL[6], ltok)

-- stem button: star calyx + twig
local cal = { { 0, 0, 3 }, { -1, 0, 4 }, { 1, 0, 2 }, { 0, -1, 4 }, { 0, 1, 2 }, { -1, 1, 3 }, { 1, -1, 3 } }
for _, q in ipairs(cal) do c:put(SX + q[1], SY + q[2], LEAF[q[3]], ltok) end
local tm = A.stem(c, tw, function(t) return 1.15 - 0.2 * t end, TWIG, { tok = { r = { name = "twig" } } })
c:put(SX, SY, TWIG[1], ltok)

-- leaf
lm:cut(tm)
local lt = { r = { name = "leaf" } }
local lidx = A.toneN(c, lm, ln, LEAF, { tok = lt, cuts = { 0.2, 0.38, 0.54, 0.7, 0.86 }, amb = 0.12, wrap = 0.28 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if abs(s) < 0.15 and t > 0.03 and t < 0.9 then c:put(x, y, s <= 0 and LEAF[6] or LEAF[3], lt)
  elseif t > 0.12 and t < 0.86 and abs(s) > 0.3 and abs(s) < 0.78 then
    local d = (t * llen - abs(s) * 4.6) % 3.4
    if d < 0.9 then c:put(x, y, s < 0 and LEAF[min(6, (lidx[k] or 3) + 1)] or LEAF[max(1, (lidx[k] or 3) - 1)], lt) end
  end
end)
lm:edge():each(function(x, y) local k = K(x, y) if LS[k] > 0.6 and LT[k] > 0.15 and LT[k] < 0.85 then c:put(x, y, "#3c6e74", lt) end end)
c:put(SX + 4, SY - 11, "#e8f7c0", lt) -- leaf gloss

-- quirk: ladybird on the leaf (red dome, ink head + spots, cream glint)
local bx, by = SX + 4, SY - 15
local bug = { r = { name = "bug" } }
for _, q in ipairs{ { 0, 0, "#e8493b" }, { 1, 0, "#e8493b" }, { 2, 0, "#b52e3f" }, { 0, 1, "#b52e3f" }, { 1, 1, "#6e2038" }, { 2, 1, "#b52e3f" },
                     { 1, -1, "#ff8a5c" } } do c:put(bx + q[1], by + q[2], q[3], bug) end
c:put(bx - 1, by, "#2b1c26", bug) c:put(bx - 1, by + 1, "#2b1c26", bug)
c:put(bx + 1, by, "#2b1c26", bug)
c:put(bx, by, "#fff4d6", bug)

A.save(c, NAME)
