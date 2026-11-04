-- pine-log (final pass, Opus). A slim pine log lying on the diagonal, sawn end toward the viewer (lower left).
-- Bark: per-pixel cylinder light on a 6-tone red-brown ramp, broken into scaly pine plates by dark fissures
-- (long cracks along the log, staggered cross breaks), lit upper lip on each plate. End grain: pale sapwood,
-- growth rings, warm resinous heartwood, pith dot, one radial drying check, dark bark rim. A sawn-off branch knot
-- on the upper side with its own rings; AO where the knot meets the bark.
-- quirk: a tiny pine sprig (a tuft of needles) still sprouting from the knot.
-- History: Sonnet draft replaced.
local NAME = "pine-log"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC35_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local c = A.new(NAME)

local BARK = { "#2c181e", "#4c2824", "#723e2c", "#985836", "#bc7646", "#d89a64" }
local WOOD = { "#8a5430", "#b67c48", "#d6a468", "#ecc68c", "#f8e0b0" }
local HEART = { "#a8542a", "#c87038", "#de8c48" }
local NEED = { "#1e4a3a", "#2e6a44", "#4a8c4c", "#7ab45a" }

local AX, AY, BX, BY, W = 13, 44, 50, 27, 6.6
local vx, vy = BX - AX, BY - AY
local L = sqrt(vx * vx + vy * vy)
local ux, uy = vx / L, vy / L
local px, py = -uy, ux
if px + py < 0 then px, py = -px, -py end
local RA = 3.3

-- body: cylinder + rounded back cap
local bm, bn, BT, BS = X.cyl(AX, AY, BX, BY, function(t) return W end)
local cap = A.rell(BX, BY, ux, uy, RA, W + 0.4)
cap:each(function(x, y) if not bm:has(x, y) then
  local dx, dy = x - BX, y - BY
  local a = dx * ux + dy * uy
  if a > 0 then bm:set(x, y) local s = (dx * px + dy * py) / (W + 0.5) s = max(-0.98, min(0.98, s))
    local k = K(x, y) bn[k] = { px * s, py * s, sqrt(1 - s * s) } BT[k], BS[k] = 1, s end
end end)
local face = A.rell(AX, AY, ux, uy, RA, W + 0.4)
bm:cut(face)

-- knot (sawn branch stub) on the upper side
local KX, KY = AX + ux * 27 - px * 5.6, AY + uy * 27 - py * 5.6
local knot = A.rell(KX, KY, ux, uy, 2.2, 1.8)
local bias = {}
X.ao(bias, bm, knot, 1, -1)
-- bark plates
local ftok = { r = { name = "bark" } }
local seg = {}
bm:each(function(x, y) local k = K(x, y)
  local t, s = BT[k], BS[k]
  local along = t * L
  local band = floor((s + 1.1) / 0.36 + 0.25 * sin(along * 0.45))
  local fr = ((s + 1.1) / 0.36 + 0.25 * sin(along * 0.45)) % 1
  local off = X.hash(band, 1, 9) * 6
  local per = 5 + floor(X.hash(band, 2, 9) * 3)
  local ph = (along + off) % per
  if fr < 0.22 or ph < 0.9 then bias[k] = (bias[k] or 0) - 2
  elseif fr < 0.45 and ph > 1.8 then bias[k] = (bias[k] or 0) + 1 end
end)
local idx = A.shade(c, bm, bn, BARK, { amb = 0.08, wrap = 0.25, bias = bias, tok = ftok, cuts = { 0.16, 0.32, 0.48, 0.64, 0.8 } })

-- knot: end grain of the stub
local ktok = { r = { name = "knot" } }
knot:each(function(x, y)
  local dx, dy = x - KX, y - KY
  local a, b = (dx * ux + dy * uy) / 2.7, (dx * px + dy * py) / 2.3
  local r = sqrt(a * a + b * b)
  local col = WOOD[3]
  if r > 0.8 then col = BARK[2] elseif r > 0.5 then col = WOOD[2] elseif r < 0.25 then col = HEART[1] end
  if b < -0.2 and r <= 0.8 and r > 0.25 then col = WOOD[4] end
  c:put(x, y, col, ktok)
end)

-- quirk: pine sprig from the knot
local ntok = { r = { name = "needles" } }
local sx, sy = floor(KX + 0.5) + 1, floor(KY + 0.5) - 2
for i = 0, 2 do c:put(sx, sy - i, i == 0 and BARK[3] or "#6a4a30", ntok) end
local tips = { { -5, -4 }, { -4, -6 }, { -2, -7 }, { 1, -7 }, { 3, -6 }, { 5, -4 }, { -3, -2 }, { 4, -1 } }
for j, tp in ipairs(tips) do
  local n = 6
  for i = 1, n do local f = i / n
    local x, y = floor(sx + tp[1] * f + 0.5), floor(sy - 2 + tp[2] * f + 0.5)
    local col = NEED[(tp[1] <= 0 and 3 or 2) + (i == n and 1 or 0)]
    if tp[2] > -3 then col = NEED[tp[1] < 0 and 2 or 1] end
    c:put(x, y, col, ntok)
  end
end
c:put(sx, sy - 3, NEED[2], ntok)

-- end grain
local etok = { r = { name = "endgrain" } }
face:each(function(x, y)
  local dx, dy = x - AX, y - AY
  local a, b = (dx * ux + dy * uy) / (RA + 0.45), (dx * px + dy * py) / (W + 0.85)
  local r = sqrt(a * a + b * b)
  local ang = atan(b, a)
  local col
  if r > 0.84 then col = (b > 0.2) and BARK[1] or BARK[3]
  elseif r < 0.13 then col = BARK[2]
  else
    local base = r < 0.42 and 0 or 1
    local ring = ((r - 0.13) / 0.12) % 1 < 0.28
    if base == 0 then col = ring and HEART[1] or HEART[2 + ((b < -0.1) and 1 or 0)]
    else col = ring and WOOD[2] or WOOD[(b < -0.1 and a < 0.2) and 5 or 4] end
    if r > 0.74 then col = ring and WOOD[1] or WOOD[3] end
  end
  -- radial drying check toward the upper rim
  if r > 0.2 and r < 0.84 and abs(b + r * 0.9) < 0.14 and a > -0.25 then col = WOOD[1] end
  c:put(x, y, col, etok)
end)
-- AO: bark shade where the end grain meets it on the lower side
bm:each(function(x, y) local k = K(x, y)
  if (face:has(x - 1, y) or face:has(x, y - 1)) and BS[k] > 0.2 then c:put(x, y, BARK[1], ftok) end end)
-- glint on the sapwood
c:px(floor(AX - px * 4 + 0.5), floor(AY - py * 4 + 0.5), "#fff4d6")

A.save(c, NAME)
