-- ico-tier-easy (final pass, Opus). Jigsaw tier "Easy": ONE chunky glossy jigsaw piece, tilted a little,
-- knobs out on top and right, sockets in on the left and bottom (necked knobs, so it reads as a jigsaw at 16 px).
-- Material: printed glossy face lit per pixel (6-tone moss, bevelled die-cut edge, gentle dome), 2 px cardboard
-- thickness on the lower right with fibre flecks, ambient dark row where the face meets the card edge, a printed
-- daisy (cream petals, gold eye) on the face, one gloss streak + cream glint on the upper-left bevel.
-- quirk: the print is peeling at the lower-left corner: a curled paper flap shows the bare card underneath.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aR0_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, max, min, sin, cos, pi = math.floor, math.abs, math.max, math.min, math.sin, math.cos, math.pi
local c = A.new("ico-tier-easy")
local GREEN = { "#1b4638", "#2a6a40", "#3c8e46", "#58b04d", "#8ccf5e", "#c6ea88" }
local CARD  = { "#6e4c3e", "#c49c72", "#9a745a" }
local PAPER = { "#c9b08a", "#fff4d6" }
local BARE  = { "#b89874", "#8e6e54" }
local tok = { r = { name = "piece" } }

local CX, CY, S, ANG = 31, 31, 30, -0.1
local h = S / 2
local m, U, V = A.piece{ cx = CX, cy = CY, S = S, r = 4.7, ang = ANG, k = 0.92, cr = 3, roundAll = true,
  e = { t = 1, r = 1, b = -1, l = -1 } }

-- cardboard thickness first (face paints over)
A.thick(c, m, 2, CARD, tok)

-- face light: bevel + gentle dome
local n = A.slab(m, 3, CX - 2, CY - 2, 26, 0.32)
local bias = {}
-- ambient dark row along the lower-right rim (where the face turns into the card edge)
m:each(function(x, y) if not m:has(x + 1, y + 1) and (not m:has(x, y + 1) or not m:has(x + 1, y)) then
  bias[K(x, y)] = -1 end end)
local idx = A.shade(c, m, n, GREEN, { bias = bias, tok = tok, amb = 0.1, wrap = 0.3 })

-- printed daisy (flat print, lit tones by side)
local dcx, dcy = CX + 1.5, CY + 1.5
local petals = HP.mask()
for i = 0, 5 do
  local a = i * pi / 3 + 0.3
  local ux, uy = cos(a), sin(a)
  petals:add(A.rell(dcx + ux * 3.6, dcy + uy * 3.6, ux, uy, 2.9, 1.55))
end
petals:clip(m)
petals:each(function(x, y)
  local s = (x + 0.5 - dcx) + (y + 0.5 - dcy)
  c:put(x, y, s > 3.2 and "#dccaa8" or (s < -3.5 and "#fffaea" or "#f6e9c8"), tok)
end)
local eye = c:ellipse(floor(dcx), floor(dcy), 1.5, 1.5)
eye:each(function(x, y)
  local s = (x - floor(dcx)) + (y - floor(dcy))
  c:put(x, y, s > 0 and "#d98322" or (s < 0 and "#ffd65a" or "#f5b82e"), tok)
end)

-- quirk: peeling print at the lower-left corner
local ca, sa = cos(ANG), sin(ANG)
local P0, PF = 7, 5.5
local flap = HP.mask()
m:each(function(x, y)
  local k = K(x, y)
  local a, b = U[k] + h, h - V[k]               -- distance from the left edge / bottom edge
  local d = a + b
  if a >= -0.5 and b >= -0.5 and d < P0 then
    c:put(x, y, X.hash(x, y, 3) > 0.7 and BARE[2] or BARE[1], tok)
  elseif d >= P0 and d <= P0 + PF and abs(a - b) <= (P0 + PF - d) * P0 / PF then
    flap:set(x, y)
  elseif d > P0 + PF and d <= P0 + PF + 1.6 and abs(a - b) <= 2.2 then
    A.step(c, idx, GREEN, x, y, -2, tok)           -- flap shadow on the print
  end
end)
flap:each(function(x, y)
  local k = K(x, y)
  local d = U[k] + h + h - V[k]
  c:put(x, y, d < P0 + 1.2 and PAPER[1] or PAPER[2], tok)
end)

-- gloss: streak along the upper-left bevel + one cream glint
local gx, gy = A.specAt(m, n, 30)
c:put(gx, gy, A.CREAM, tok)
for i = 1, 3 do if m:has(gx + i, gy) and idx[K(gx + i, gy)] then c:put(gx + i, gy, GREEN[6], tok) end end
if m:has(gx, gy + 1) then c:put(gx, gy + 1, GREEN[6], tok) end

A.save(c, "ico-tier-easy")
