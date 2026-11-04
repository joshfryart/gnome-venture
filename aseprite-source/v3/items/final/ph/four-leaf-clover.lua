-- four-leaf-clover (B3, Opus single pass). One lucky clover sprig: slim S-curved stalk, four heart-shaped leaflets in
-- an X, each folded along a pale midrib with fine lateral veins, the clover's pale chevron watermark, a cool reflected
-- edge on the shade side, ambient darkening where the leaflets meet the stalk and a cut, paler stalk end.
-- quirk: a ladybird is strolling across the upper-right leaflet.
local NAME = "four-leaf-clover"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB32_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, abs, sin, cos, pi, sqrt = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi, math.sqrt
local c = A.new(NAME)

local LEAF = { "#163a33", "#1f5a3e", "#2c7a45", "#46994b", "#6fba56", "#a3d570" }
local CHEV, COOL = "#cdeba2", "#3a6c72"
local STALK = { "#2c5a3e", "#4f8a55", "#86b86c", "#b8dc92" }
local CX, CY = 32, 25

-- stalk (drawn first, leaflets overlap its top)
local stok = { r = { name = "stalk" } }
local sp = { { CX, CY + 1 }, { 34, 36 }, { 29, 46 }, { 34, 57 } }
local sm, sn, ST, SS, sidx = A.stem(c, sp, function(t) return 1.05 end, STALK, { tok = stok, cuts = { 0.3, 0.55, 0.8 } })
-- cut end: pale ring
sm:each(function(x, y) if ST[K(x, y)] > 0.975 then c:put(x, y, STALK[4], stok) end end)
c:put(34, 57, "#e2f2bc", stok)

-- leaflets: heart shapes pointing out along angle a (wedge to centre + two rounded lobes)
local leaves = {}
local function heart(a, L, r)
  local ux, uy = cos(a), sin(a)
  local vx, vy = -uy, ux
  local m = HP.mask()
  local lob = r * 0.92
  for _, sd in ipairs{ -1, 1 } do
    m:add(c:ellipse(CX + ux * (L - r) + vx * sd * lob, CY + uy * (L - r) + vy * sd * lob, r, r))
  end
  local p1 = { CX + ux * 1.0, CY + uy * 1.0 }
  local q1 = { CX + ux * (L - r) - vx * (lob + r * 0.85), CY + uy * (L - r) - vy * (lob + r * 0.85) }
  local q2 = { CX + ux * (L - r) + vx * (lob + r * 0.85), CY + uy * (L - r) + vy * (lob + r * 0.85) }
  m:add(c:poly{ p1, q1, q2 })
  return m, ux, uy, vx, vy
end
local spec = { { -3 * pi / 4, 12.5, 3.6 }, { -pi / 4, 13, 3.7 }, { pi / 4, 12, 3.5 }, { 3 * pi / 4, 12.5, 3.6 } }
-- paint back-to-front: lower leaflets first
local order = { 3, 4, 1, 2 }
local cen = c:ellipse(CX, CY, 1.6, 1.6)
for _, i in ipairs(order) do
  local s = spec[i]
  local m, ux, uy, vx, vy = heart(s[1], s[2], s[3])
  local tok = { r = { name = "leaf" .. i } }
  -- normals: pillow + fold along the midrib
  local np = X.pillow(m, 2.6)
  local n = {}
  m:each(function(x, y) local k = K(x, y)
    local dx, dy = x - CX, y - CY
    local b = dx * vx + dy * vy
    local f = b < 0 and -0.38 or 0.38
    local a = np[k]
    n[k] = { A.norm(a[1] + vx * f, a[2] + vy * f, a[3]) }
  end)
  local bias = {}
  X.ao(bias, m, cen, 3, -1)
  for _, j in ipairs(leaves) do X.ao(bias, m, j, 1, -1) end
  local idx = A.shade(c, m, n, LEAF, { amb = 0.1, wrap = 0.3, cuts = { 0.18, 0.34, 0.5, 0.67, 0.84 }, tok = tok, bias = bias })
  local L = s[2]
  m:each(function(x, y) local k = K(x, y)
    local dx, dy = x - CX, y - CY
    local a, b = dx * ux + dy * uy, dx * vx + dy * vy
    local i0 = idx[k] or 3
    -- chevron watermark (pale V opening outward)
    if abs(a - (L * 0.42 + abs(b) * 0.75)) < 0.55 and abs(b) > 0.8 and abs(b) < s[3] * 1.6 then
      c:put(x, y, i0 >= 3 and CHEV or LEAF[5], tok)
    -- midrib
    elseif abs(b) < 0.5 and a > 2 and a < L - 1.5 then
      c:put(x, y, LEAF[min(6, i0 + 1)], tok)
    -- lateral veins
    elseif a > 3 and abs(b) > 1.2 and abs(b) < s[3] * 1.4 and abs((a - abs(b) * 0.9) % 3.2) < 0.45 and a < L - 2 then
      c:put(x, y, LEAF[max(1, i0 - 1)], tok)
    end
  end)
  -- cool reflected light on the lower-right edge
  m:edge():each(function(x, y) local k = K(x, y)
    local nn = n[k] if nn and nn[1] + nn[2] > 0.75 and not (bias[k]) then c:put(x, y, COOL, tok) end end)
  leaves[#leaves + 1] = m
end
-- heart of the sprig: deep knot where all four meet
for _, q in ipairs{ { 0, 0, 1 }, { 1, 0, 1 }, { 0, 1, 1 }, { -1, 0, 2 }, { 0, -1, 2 }, { 1, 1, 2 } } do c:put(CX + q[1], CY + q[2], LEAF[q[3]]) end
-- glint
c:put(24, 15, "#e8f6c8") c:put(25, 15, "#e8f6c8")

-- quirk: ladybird on the upper-right leaflet
local LB = { "#6e2038", "#b52e3f", "#e8493b", "#ff8a5c" }
local lt = { r = { name = "ladybird" } }
local lm, ln = A.oval(41.5, 17.5, 2.6, 2.1, -0.6, 0.8)
A.shade(c, lm, ln, LB, { cuts = { 0.3, 0.55, 0.85 }, tok = lt })
c:put(43, 15, "#2b1c26", lt) c:put(44, 15, "#2b1c26", lt) c:put(44, 16, "#2b1c26", lt)  -- head
c:put(42, 17, "#2b1c26", lt) c:put(41, 18, "#2b1c26", lt) c:put(40, 17, "#2b1c26", lt)   -- wing seam + spots
c:put(42, 19, "#2b1c26", lt)
c:put(40, 16, "#fff4d6", lt)

A.save(c, NAME)
