-- garden-oak (final, Opus single pass). Young garden oak: slim fissured trunk with flared roots, two limbs
-- forking into a canopy of rounded leaf clumps (each lit as its own ball, darker seams where clumps overlap,
-- lobed oak-leaf flecks), a few acorns with checked caps hanging under the crown.
-- Material: bark fissures (dark grooves + lit ridges), cool reflected light on the trunk's right, AO under the
-- canopy and at the root collar, contact shadow on the ground.
-- quirk: two little eyes peep out of a knothole in the trunk.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB33_3.lua")
local HP, X, K, R = A.HP, A.X, A.K, A.R
local floor, max, min, abs, sqrt = math.floor, math.max, math.min, math.abs, math.sqrt
local c = A.new("garden-oak")
local B, L = R.bark, R.leaf
local tokB = { r = { name = "bark" } }

c:groundShadow(32, 54, 13, 2)

-- trunk: slim tube, flaring at the base
local function hw(t) -- t 0 = base
  if t < 0.12 then return 3.0 + (0.12 - t) / 0.12 * 2.6 end
  return 3.0 - t * 0.9
end
local tm, tnn, T, S, samp = A.tube({ { 32, 54 }, { 32, 47 }, { 31, 40 }, { 32, 30 } }, hw)
tm:clip(c:rect(0, 0, 63, 54))
-- roots on the ground
local roots = c:poly{ { 23, 54 }, { 28, 50 }, { 30, 54 } }:add(c:poly{ { 41, 54 }, { 35, 50 }, { 34, 54 } })
local rn = X.pillow(roots, 1.5)
-- limbs into the crown
local l1 = A.tube({ { 31, 38 }, { 28, 33 }, { 24, 29 }, { 20, 26 } }, function(t) return 1.8 - t * 0.8 end)
local l2 = A.tube({ { 33, 37 }, { 36, 33 }, { 40, 29 }, { 44, 26 } }, function(t) return 1.8 - t * 0.8 end)
local wood = tm:copy():add(l1):add(l2)
local nb = X.pillow(wood, 2)
for k, v in pairs(tnn) do nb[k] = v end
local bias = {}
wood:each(function(x, y) local k = K(x, y)
  if y >= 52 then bias[k] = -1 end
end)
local bidx = A.shade(c, wood, nb, B, { amb = 0.1, wrap = 0.3, bias = bias, tok = tokB })
A.shade(c, roots, rn, B, { amb = 0.1, wrap = 0.3, tok = tokB, bias = setmetatable({}, { __index = function() return -1 end }) })
-- bark fissures: wavy vertical grooves with lit ridge to the left
tm:each(function(x, y) local k = K(x, y)
  local s = S[k] or 0
  local i = bidx[k] or 3
  for _, g in ipairs{ -0.45, 0.05, 0.55 } do
    local off = s - g - 0.12 * math.sin(y * 0.7 + g * 9)
    if abs(off) < 0.13 and X.hash(x, y, 3) > 0.18 then c:put(x, y, B[max(1, i - 2)], tokB)
    elseif off < -0.13 and off > -0.38 and s < 0.3 and X.hash(x, y, 5) > 0.5 then c:put(x, y, B[min(6, i + 1)], tokB) end
  end
end)
-- cool reflected light on the trunk's right edge
tm:edge():each(function(x, y) if (S[K(x, y)] or 0) > 0.75 and y > 41 and y < 51 then c:put(x, y, "#6a5a7a", tokB) end end)
-- root collar AO
for x = 27, 37 do if wood:has(x, 53) or roots:has(x, 53) then c:put(x, 53, B[1], tokB) end end

-- quirk: knothole with two peeping eyes
A.map(c, {
  ".kk.",
  "kddk",
  "dcdc",
  "kddk",
  ".hh.",
}, 30, 42, { k = B[2], d = "#1e1218", c = A.CREAM, h = B[5] }, tokB)

-- canopy: clumps back to front
local clumps = {
  { 32, 15, 8 }, { 22, 18, 7.5 }, { 42, 18, 7.5 },
  { 15, 25, 5.8 }, { 49, 25, 5.8 }, { 26, 26, 7 }, { 38, 26, 7 }, { 32, 21, 6.5 },
}
local canopy = HP.mask()
local tokL = { r = { name = "canopy" } }
local cidx = {}
for ci, cl in ipairs(clumps) do
  local cx, cy, r = cl[1], cl[2], cl[3]
  local m = A.ell(cx, cy, r, r * 0.88)
  -- leafy, nibbled rim
  m:edge():each(function(x, y) if X.hash(x, y, ci) < 0.28 then m.s[K(x, y)] = nil end end)
  local n = A.blend(X.sphere(cx, cy - 1, r, m), X.pillow(m, 3), 0.35)
  local bi = {}
  -- lower clumps sit in the crown's shade
  m:each(function(x, y) if y > 27 then bi[K(x, y)] = -1 end end)
  local idx = A.shade(c, m, n, L, { amb = 0.08, wrap = 0.3, bias = bi, tok = tokL })
  -- seam: pixels of this clump touching earlier canopy go dark; earlier canopy just below/right gets AO
  m:each(function(x, y) local k = K(x, y)
    for _, d in ipairs{ { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } } do
      local q = K(x + d[1], y + d[2])
      if canopy.s[q] and not m.s[q] then
        idx[k] = max(1, (idx[k] or 3) - 2) c:put(x, y, L[idx[k]], tokL) break end
    end
  end)
  for k, i in pairs(idx) do cidx[k] = i end
  canopy:add(m)
end
-- lobed oak-leaf flecks: small lit 2-px lobes with a dark notch below
canopy:each(function(x, y) local k = K(x, y)
  local i = cidx[k]
  if i and i >= 3 and i <= 5 and X.hash(x, y, 11) < 0.1 and canopy:has(x + 1, y) and canopy:has(x, y + 1) then
    c:put(x, y, L[i + 1], tokL) c:put(x + 1, y, L[i + 1], tokL)
    if canopy:has(x + 1, y + 1) then c:put(x + 1, y + 1, L[max(1, i - 1)], tokL) end
  end
end)
-- one glint on the top clump
c:put(28, 10, "#d6f0a0", tokL) c:put(29, 10, "#d6f0a0", tokL)
-- AO on the trunk just under the canopy
wood:each(function(x, y) if not canopy:has(x, y) then
  if canopy:has(x, y - 1) then c:put(x, y, B[1], tokB) elseif canopy:has(x, y - 2) then c:put(x, y, B[2], tokB) end end end)

-- acorns hanging under the crown
local tokA = { r = { name = "acorn" } }
for _, a in ipairs{ { 17, 30 }, { 44, 31 }, { 24, 32 } } do
  A.map(c, {
    ".s.",
    "CcC",
    "cCd",
    "gGo",
    "Ggo",
    ".o.",
  }, a[1], a[2], { s = B[2], C = B[3], c = B[5], d = B[2], G = R.ochre[5], g = R.ochre[6], o = R.ochre[3] }, tokA)
end

A.save(c, "garden-oak")
