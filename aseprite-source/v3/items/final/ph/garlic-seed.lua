-- garlic-seed (final, Opus single pass). Two garlic cloves on a torn scrap of flat garlic leaf (parallel veins,
-- V-fold light, ragged torn ends, AO + contact shadow under each clove). The upright clove has sprouted: a pale
-- shoot and three flat, glaucous strap leaves (garlic leaf shape), little cream roots out of its tan root plate.
-- Material: papery cream skin with violet streaks, waxy bloom specks, one specular, cool reflected edge.
-- quirk: a curl of papery skin peels off the lying clove's back.
local NAME = "garlic-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB33_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)

local SCRAP = { "#1c3f34", "#2a5a3e", "#3b7845", "#58984c", "#7fb75a", "#b0d478" }
local GLAU  = { "#173a40", "#22564f", "#2f7258", "#4a9064", "#74ae7c", "#a8d2a0" }
local SKIN  = { "#4e3354", "#7c5a7e", "#ae90a8", "#d6c2c8", "#efe2da", "#fff8ee" }
local VIO   = { "#5e2c5e", "#84467e", "#a86a9c" }
local PLATE = { "#5a4030", "#866448", "#b08e66", "#d6b88a" }
local ROOT  = "#e8dcc0"
local SHOOT = { "#4e7a54", "#7ea86a", "#b2d290", "#def0be" }
local COOL, SPEC = "#8e98c6", "#fffaf2"

-- clove: tip T -> base B, half width w, bend (sideways bow). returns mask, normals, U (0 tip..1 base), SN (-1..1)
local function clove(tx, ty, bx, by, w, bend)
  local vx, vy = bx - tx, by - ty
  local len = sqrt(vx * vx + vy * vy)
  local ux, uy = vx / len, vy / len
  local px, py = -uy, ux
  if px + py < 0 then px, py = -px, -py end
  local m, U, SN = HP.mask(), {}, {}
  local function hw(u)
    local h = w * min(1, u / 0.62) ^ 0.7
    if u > 0.82 then h = h * sqrt(1 - ((u - 0.82) / 0.18) ^ 2 * 0.45) end
    return h
  end
  for y = floor(min(ty, by)) - 9, floor(max(ty, by)) + 9 do for x = floor(min(tx, bx)) - 9, floor(max(tx, bx)) + 9 do
    local rx, ry = x - tx, y - ty
    local u = (rx * ux + ry * uy) / len
    local s = rx * px + ry * py - bend * sin(pi * min(1, max(0, u)))
    if u >= 0 and u <= 1 then
      local h = hw(u)
      if abs(s) <= h + 0.1 and h > 0.3 then
        m:set(x, y) local k = K(x, y)
        U[k] = u SN[k] = max(-0.97, min(0.97, s / (h + 0.5)))
      end
    end
  end end
  local np = X.pillow(m, 3.5)
  local n = {}
  for k, a in pairs(np) do
    local sn = SN[k] local nz = sqrt(1 - sn * sn)
    local tip = max(0, 0.25 - U[k]) * 2.2
    local x, y, z = a[1] * 0.4 + px * sn * 0.6 - ux * tip, a[2] * 0.4 + py * sn * 0.6 - uy * tip, a[3] * 0.4 + nz * 0.6
    local l = sqrt(x * x + y * y + z * z) n[k] = { x / l, y / l, z / l }
  end
  return m, n, U, SN
end

local cA, nA, UA, SA = clove(33, 41, 14, 45, 4.7, -1.8)   -- lying, tip to the right
local cB, nB, UB, SB = clove(41, 26, 41, 41, 5.2, 1.2)    -- upright, sprouting
local seedsM = cA:copy():add(cB)

-- leaf scrap: flat garlic strap, torn at both ends
local wS = function(t) return 4.4 + 0.5 * sin(t * 9) end
local lm, ln, LT, LS, len = A.blade(6, 51, 30, 49, 58, 42, wS, { fold = 0.3 })
local cut = {}
lm:each(function(x, y) local k = K(x, y)
  local d = LT[k] * len
  local band = floor((LS[k] + 1) * 3.5)
  local j1 = 1.0 + 3.2 * X.hash(band, 1, 7)
  local j2 = 1.0 + 3.6 * X.hash(band, 2, 9)
  if d < j1 or d > len - j2 then cut[#cut + 1] = k end
end)
for _, k in ipairs(cut) do lm.s[k] = nil end
local bias = {}
X.ao(bias, lm, seedsM, 1, -1)
A.cast(bias, lm, cA, 1, 2, -1) A.cast(bias, lm, cB, 2, 1, -1)
local ltok = { r = { name = "scrap" } }
local lidx = A.shade(c, lm, ln, SCRAP, { bias = bias, tok = ltok, amb = 0.16, wrap = 0.3, cuts = { 0.14, 0.3, 0.46, 0.62, 0.8 } })
-- parallel veins (monocot), midrib slightly paler
lm:each(function(x, y) local k = K(x, y)
  if bias[k] then return end
  local s = LS[k]
  local i = lidx[k] or 3
  for _, vs in ipairs{ -0.62, -0.3, 0.3, 0.62 } do
    if abs(s - vs) < 0.09 then c:put(x, y, s < 0 and SCRAP[min(6, i + 1)] or SCRAP[max(1, i - 1)], ltok) end
  end
  if abs(s) < 0.08 then c:put(x, y, s <= 0 and SCRAP[6] or SCRAP[4], ltok) end
end)
-- torn edge: pale fibrous ends
lm:edge():each(function(x, y) local k = K(x, y)
  local d = LT[k] * len
  if (d < 5 or d > len - 6) and not bias[k] and X.hash(x, y, 3) > 0.35 then c:put(x, y, SCRAP[5], ltok) end
  if LS[k] > 0.8 and d > 6 and d < len - 6 and not bias[k] then c:put(x, y, COOL, ltok) end
end)

-- roots under the upright clove (over the scrap, under the clove)
for _, r in ipairs{ { {39, 41}, {37, 44}, {36, 45} }, { {41, 42}, {41, 45} }, { {43, 41}, {45, 43}, {46, 44} } } do
  for i = 1, #r - 1 do
    c:line({ r[i], r[i + 1] }, 1):each(function(x, y) if not cB:has(x, y) then c:px(x, y, ROOT) end end)
  end
end

-- paint a clove
local function paintClove(m, n, U, SN, name, bb)
  local tok = { r = { name = name } }
  local idx, v = A.shade(c, m, n, SKIN, { bias = bb, tok = tok, amb = 0.1, wrap = 0.26, cuts = { 0.16, 0.32, 0.5, 0.68, 0.85 } })
  m:each(function(x, y) local k = K(x, y) local u, s = U[k], SN[k] local i = idx[k]
    -- violet streaks along the length, tapering toward the tip
    local f = (s * 1.9 + 0.3) % 1
    if u > 0.22 and u < 0.86 and f < 0.3 and abs(s) < 0.8 then
      c:put(x, y, VIO[max(1, min(3, i - 2))], tok)
    end
    -- root plate
    if u > 0.9 then c:put(x, y, PLATE[max(1, min(4, i - 1))], tok) end
    -- waxy bloom specks on the lit side
    if u > 0.25 and u < 0.85 and v[k] > 0.72 and X.hash(x, y, 13) > 0.86 and i < 6 then c:put(x, y, SKIN[6], tok) end
  end)
  m:edge():each(function(x, y) local k = K(x, y) if SN[k] > 0.6 and U[k] > 0.3 and U[k] < 0.88 and (idx[k] or 3) <= 3 then c:put(x, y, COOL, tok) end end)
  return idx
end
-- lying clove: AO where it meets the upright one
local bA = {}
X.ao(bA, cA, cB, 1, -1)
local iA = paintClove(cA, nA, UA, SA, "cloveA", bA)
local iB = paintClove(cB, nB, UB, SB, "cloveB", {})
-- separation line where cloves touch (darker neighbour tone)
cA:each(function(x, y) if cB:has(x + 1, y) or cB:has(x, y - 1) then c:px(x, y, SKIN[2]) end end)

-- sprout: shoot out of the upright clove tip
local stok = { r = { name = "shoot" } }
local sm = A.stem(c, { {41, 27}, {41, 24}, {40, 21}, {40, 18} }, function(t) return 1.25 - 0.2 * t end, SHOOT, { cut = cB, tok = stok })
-- three flat strap leaves (garlic): left arch, right arch, centre spear
local leaves = HP.mask()
local function strap(ax, ay, cx, cy, bx, by, w)
  local m = A.leaf(c, ax, ay, cx, cy, bx, by, w, GLAU, { cut = sm:copy():add(cB):add(leaves), pw = 0.35, fold = 0.5, vs = 99,
    wfn = function(t) if t > 0.985 then return -1 end return max(0.5, w * min(1, (1 - t) / 0.35) ^ 0.6 * min(1, 0.55 + t * 3)) end })
  leaves:add(m)
  return m
end
strap(40, 19, 41, 13, 45, 7, 1.6)
strap(39, 19, 30, 10, 17, 14, 1.8)
strap(41, 19, 51, 12, 58, 19, 1.7)
-- shoot shines on its lit side
c:px(40, 22, SHOOT[4]) c:px(40, 23, SHOOT[4])

-- specular on the upright clove's shoulder + one cream sparkle
c:px(38, 32, SPEC) c:px(38, 33, SPEC) c:px(39, 31, SKIN[6])
c:px(19, 42, SPEC) c:px(20, 42, SKIN[6])

-- quirk: a papery skin curl peeling up off the lying clove's back
A.map(c, {
  "..ab",
  ".ab.",
  "abc.",
  "bc..",
}, 21, 36, { a = SKIN[6], b = SKIN[4], c = SKIN[3] })

A.save(c, NAME)
