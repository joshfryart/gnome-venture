-- ico-tier-expert (final pass, Opus). Jigsaw tier "Expert": a 2x2 block of interlocking corner pieces (flat outer
-- edges, necked knobs inside) with the fourth piece still in the air, tilted, about to drop into its slot.
-- Material: glossy printed faces lit per pixel (6-tone ember / gold / dusk / sea), bevelled die-cut edges, 1 px cut
-- lines in each piece's deep tone, 2 px cardboard thickness with fibre flecks, a soft cast shadow of the hovering
-- piece on the block, ambient dark row along the cuts, one gold star printed on the last piece + a cream glint.
-- quirk: the last piece hangs above its empty slot (its two knobs and the two empty sockets waiting for them are visible).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aR0_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, max, min, sin, cos, pi = math.floor, math.abs, math.max, math.min, math.sin, math.cos, math.pi
local c = A.new("ico-tier-expert")
local EMBER = { "#56182f", "#8a2233", "#c03431", "#e5553b", "#ff875a", "#ffbf8a" }
local GOLD  = { "#6a361e", "#a5621f", "#d68d22", "#f3b52e", "#ffd55e", "#fff0a6" }
local DUSK  = { "#231846", "#3a2a74", "#5643a4", "#7860c8", "#a289e4", "#cfbff8" }
local SEA   = { "#173a5a", "#225e7a", "#2f8a98", "#45b2b4", "#7fd8cc", "#c2f2e4" }
local CARD  = { "#6e4c3e", "#c49c72", "#9a745a" }
local tok = { r = { name = "block" } }
local ftok = { r = { name = "last" } }

local S, R, KK = 17, 3.6, 0.9
local X0, Y0 = 12, 16
local function ctr(i, j) return X0 + S * i + S / 2, Y0 + S * j + S / 2 end
local pieces = {
  { i = 0, j = 0, ramp = EMBER, e = { t = 0, l = 0, r = -1, b = -1 } },
  { i = 0, j = 1, ramp = GOLD,  e = { t = 1, l = 0, b = 0, r = -1 } },
  { i = 1, j = 1, ramp = DUSK,  e = { l = 1, b = 0, r = 0, t = -1 } },
}
local block = HP.mask()
for _, p in ipairs(pieces) do
  local cx, cy = ctr(p.i, p.j)
  p.cx, p.cy = cx, cy
  p.m = A.piece{ cx = cx, cy = cy, S = S, r = R, k = KK, cr = 3, e = p.e }
  block:add(p.m)
end
-- hovering last piece: lifted up-right, tilted
local fcx, fcy = ctr(1, 0)
fcx, fcy = fcx + 6, fcy - 6
local FANG = 0.12
local fm = A.piece{ cx = fcx, cy = fcy, S = S, r = R, k = KK, cr = 3, ang = FANG, e = { t = 0, r = 0, l = 1, b = 1 } }

-- block thickness, then faces
A.thick(c, block, 2, CARD, tok)
local shadow = fm:shift(3, 5)
for pi_, p in ipairs(pieces) do
  local n = A.slab(p.m, 2.4, p.cx - 1, p.cy - 1, 15, 0.3)
  local bias = {}
  p.m:each(function(x, y)
    local k = K(x, y)
    if shadow:has(x, y) and not fm:has(x, y) then bias[k] = (bias[k] or 0) - 1 end
  end)
  -- ambient row along cuts shared with earlier pieces + rim
  for q = 1, pi_ - 1 do X.ao(bias, p.m, pieces[q].m, 1, -1) end
  p.idx = A.shade(c, p.m, n, p.ramp, { bias = bias, tok = tok, amb = 0.1, wrap = 0.3 })
  p.n = n
end
-- cut lines: pixels of a later piece touching an earlier one take that later piece's deep tone
for a = 2, #pieces do
  local p = pieces[a]
  for b = 1, a - 1 do
    local g = pieces[b].m:grow(1):clip(p.m)
    g:each(function(x, y) c:put(x, y, p.ramp[1], tok) end)
  end
end
-- small gloss 2x1 per block piece (hi), on the upper-left bevel
for _, p in ipairs(pieces) do
  local gx, gy = A.specAt(p.m, p.n, 30)
  c:put(gx, gy, p.ramp[6], tok) if p.m:has(gx + 1, gy) then c:put(gx + 1, gy, p.ramp[6], tok) end
end

-- the last piece: its own thickness (taller: it is lifted), face, printed star, glint
A.thick(c, fm, 2, CARD, ftok)
local fn = A.slab(fm, 2.4, fcx - 1, fcy - 1, 15, 0.3)
local fidx = A.shade(c, fm, fn, SEA, { tok = ftok, amb = 0.12, wrap = 0.3 })
-- star printed on it (rotated with the piece)
local pts = {}
for i = 0, 9 do
  local a = -pi / 2 + FANG + i * pi / 5
  local rr = (i % 2 == 0) and 5.6 or 2.5
  pts[#pts + 1] = { floor(fcx + cos(a) * rr + 0.5), floor(fcy + 0.5 + sin(a) * rr + 0.5) }
end
local star = c:poly(pts):clip(fm)
star:each(function(x, y)
  local s = (x + 0.5 - fcx) + (y + 0.5 - fcy - 0.5)
  local col = s < -2.5 and GOLD[6] or (s < 0.5 and GOLD[5] or (s < 3 and GOLD[4] or GOLD[3]))
  c:put(x, y, col, ftok)
end)
star:edge():each(function(x, y)
  if not star:has(x + 1, y) or not star:has(x, y + 1) then c:put(x, y, GOLD[2], ftok) end
end)
local gx, gy = A.specAt(fm, fn, 30)
c:put(gx, gy, A.CREAM, ftok) if fm:has(gx + 1, gy) then c:put(gx + 1, gy, SEA[6], ftok) end

A.save(c, "ico-tier-expert")
