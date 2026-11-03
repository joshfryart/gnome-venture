-- beet (final pass, Opus). A round crimson beet with a slim curving tap root and three glossy leaves on red
-- stalks out of a rough crown. Bulb: per-pixel sphere light on a 6-tone beet ramp, faint horizontal ring scars,
-- violet waxy bloom specks, one specular, cool reflected light lower-right, AO under the crown where stalks meet.
-- Leaves: broad oval blades with a crinkled margin, V-fold light, red midrib and red angled veins (beet leaf cue),
-- stalks red with a lit edge. Root: tapered red tube with two fine root hairs.
-- quirk: a caterpillar has nibbled a neat round bite out of the right leaf.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR4_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sqrt, max, min, sin, pi = math.floor, math.abs, math.sqrt, math.max, math.min, math.sin, math.pi
local NAME = "beet"
local c = A.new(NAME)
local B, LF, RB = A.BEET, A.LEAF, A.RIB
local BOUNCE, SPEC, BLOOM = "#7b6fb4", "#fff0f2", "#c78bb4"

local CX, CY, BRX, BRY = 31.5, 39, 9.5, 9
local crown = { CX, CY - BRY + 1 }

-- leaves: stalk (t < st) then crinkled oval blade; returns blade mask
local ltok = { r = { name = "leaf" } }
local function leaf(ax, ay, qx, qy, bx, by, wmax, st, bite)
  local len = sqrt((qx - ax)^2 + (qy - ay)^2) + sqrt((bx - qx)^2 + (by - qy)^2)
  local m, n, T, S = A.blade(ax, ay, qx, qy, bx, by, function(t)
    if t > 0.985 then return -1 end
    if t < st then return 0.75 end
    local u = (t - st) / (1 - st)
    local w = wmax * sin(pi * min(1, u * 0.92 + 0.08)) ^ 0.75
    return max(0.75, w + 0.5 * sin(t * len * 1.25))
  end, { fold = 0.42 })
  if bite then m:cut(c:ellipse(bite[1], bite[2], bite[3], bite[3])) end
  local bias = {}
  -- blade darker near the stalk junction (AO)
  m:each(function(x, y) local k = K(x, y) if T[k] < st + 0.08 and T[k] >= st then bias[k] = -1 end end)
  local idx = A.tone(c, m, n, LF, { bias = bias, amb = 0.12, wrap = 0.3, cuts = { 0.16, 0.32, 0.5, 0.66, 0.84 } })
  m:each(function(x, y)
    local k = K(x, y) local s, t = S[k], T[k]
    if t < st then c:put(x, y, s <= 0 and RB[4] or (s < 0.5 and RB[3] or RB[2]))
    elseif abs(s) < 0.17 and t < 0.94 then c:put(x, y, s <= 0 and RB[3] or RB[2])           -- red midrib
    else
      for _, vt in ipairs{ 0.16, 0.4, 0.64 } do                                       -- angled red veins
        local d = (t - st - vt * (1 - st)) * len - abs(s) * 3.2
        if d > -0.5 and d < 0.5 and abs(s) > 0.2 and abs(s) < 0.8 then c:put(x, y, s < 0 and LF[6] or RB[2]) end
      end
    end
  end)
  -- lit leaf rim on the upper-left edge, cool edge lower-right
  m:edge():each(function(x, y) local k = K(x, y)
    if T[k] > st + 0.05 and S[k] < -0.7 and (idx[k] or 0) >= 4 then c:put(x, y, LF[6]) end
  end)
  return m
end
leaf(30, 31, 22, 23, 10, 15, 5.0, 0.3)
leaf(32, 31, 33, 19, 30, 8, 4.2, 0.34)
leaf(33, 31, 42, 23, 54, 16, 4.8, 0.3, { 46.5, 17.5, 2.2 })

-- tap root: tapered tube curving right, two fine hairs
local rm, rn = A.tube({ { 32, 45 }, { 33, 50 }, { 31, 54 }, { 35, 57 } }, function(t) return 2.4 * (1 - t) ^ 1.1 + 0.3 end)
local bulb = HP.mask()
for y = floor(CY - BRY - 1), floor(CY + BRY + 1) do for x = floor(CX - BRX - 1), floor(CX + BRX + 1) do
  local dx, dy = (x - CX) / (BRX + 0.45), (y - CY) / (BRY + 0.45)
  -- slightly top-shaped: wider shoulders, narrowing to the root
  if dy > 0 then dx = dx * (1 + dy * 0.28) end
  if dx*dx + dy*dy <= 1 then bulb:set(x, y) end
end end
rm:cut(bulb)
A.tone(c, rm, rn, B, { amb = 0.1, wrap = 0.3, cuts = { 0.25, 0.45, 0.65, 0.85 }, lo = 2 })
for _, p in ipairs{ { 29, 51 }, { 28, 52 }, { 35, 49 } } do c:put(p[1], p[2], B[3]) end

-- bulb: sphere light, AO under the crown, ring scars, bloom, spec, bounce
local n = X.sphere(CX - 0.5, CY - 0.5, BRX + 0.5, bulb)
local bias = {}
bulb:each(function(x, y)
  local d = sqrt((x - crown[1])^2 + ((y - crown[2]) * 1.4)^2)
  if d < 3.2 then bias[K(x, y)] = -2 elseif d < 4.6 then bias[K(x, y)] = -1 end
  if not bulb:has(x, y + 1) and rm:has(x, y + 1) then bias[K(x, y)] = (bias[K(x, y)] or 0) end
end)
local bidx = A.tone(c, bulb, n, B, { bias = bias, amb = 0.06, wrap = 0.22, cuts = { 0.12, 0.27, 0.43, 0.6, 0.8 } })
-- horizontal ring scars: short darker dashes following the curve
for _, yy in ipairs{ 37, 41, 45 } do
  for x = floor(CX - BRX), floor(CX + BRX) do
    local y = floor(yy + ((x - CX) / BRX)^2 * 1.6 + 0.5)
    if bulb:has(x, y) and bulb:has(x, y - 1) and bulb:has(x, y + 1) and X.hash(x, yy, 3) > 0.45 and (x + yy) % 5 < 3 then
      A.step(c, bidx, B, x, y, -1, 1)
    end
  end
end
bulb:copy():shrink(1):each(function(x, y)
  local k = K(x, y)
  if (bidx[k] or 0) >= 4 and X.hash(x, y, 9) > 0.86 then c:put(x, y, BLOOM) end
end)
local rim = X.rim(n)
bulb:edge():each(function(x, y) if rim[K(x, y)] > 0.75 and y > CY and y < CY + 7 then c:put(x, y, BOUNCE) end end)
c:put(25, 34, SPEC) c:put(26, 34, SPEC) c:put(25, 35, B[6]) c:put(27, 33, B[6])
-- crown: rough knobbly top with stalk bases sinking in
for _, p in ipairs{ { 29, 30, RB[2] }, { 30, 30, RB[3] }, { 31, 30, RB[1] }, { 32, 30, RB[3] }, { 33, 30, RB[2] }, { 34, 30, RB[1] },
                    { 30, 31, B[1] }, { 31, 31, B[2] }, { 32, 31, B[1] }, { 33, 31, B[2] } } do
  c:put(p[1], p[2], p[3])
end

A.save(c, NAME)
