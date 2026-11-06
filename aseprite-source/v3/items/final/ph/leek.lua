-- leek (final, Opus single pass). Slim diagonal leek: root plate + root tuft at lower-left, a long blanched shaft
-- (6-tone cream, lengthwise sheath lines, layered sheath rims) turning yellow-green, then three flat V-folded
-- blue-green strap leaves fanning out to the upper-right with parallel veins, cool edges and AO where they leave
-- the shaft. Per-pixel light via hpx normals.
-- quirk: a little clod of soil still caught in the roots.
local NAME = "leek"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC15_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)

local WH   = { "#8a8a7c", "#b4b49a", "#d6d6b8", "#ecebd0", "#f8f4e0", "#fffbee" }
local LG   = { "#4a6a3a", "#6e8f44", "#97b456", "#bfd36e", "#dde895", "#f1f6c2" }
local LF   = { "#14343c", "#1d4e4c", "#2a6a56", "#3f8a62", "#64aa72", "#98c98a" }
local ROOT = { "#7c6a58", "#a89276", "#ccb894", "#ebdcbc" }
local SOIL = { "#3d2724", "#5e3b2e", "#864c33", "#b07a52" }
local COOL = "#4f7f8a"

-- shaft along a straight diagonal
local sh = { { 15, 51 }, { 21, 45 }, { 27, 38 }, { 33, 31 } }
local sm, sn, ST, SS = A.tube(sh, function(t) return 3.7 - 0.5 * t end)

-- leaves: quadratic beziers from the shaft top
local function strap(ax, ay, cx, cy, bx, by, w)
  return A.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    local tip = t > 0.86 and ((1 - t) / 0.14) ^ 0.6 or 1
    return max(0.4, (w - t * 0.9) * tip)
  end, { fold = 0.5 })
end
local L = {}
L[1] = { strap(31, 32, 30, 18, 23, 11, 3.0) }     -- back leaf, up-left
L[2] = { strap(33, 31, 46, 22, 56, 26, 3.0) }    -- right, drooping
L[3] = { strap(32, 31, 40, 20, 48, 10, 3.4) }     -- front, tallest

-- paint order: back leaf, shaft, right leaf, front leaf
local function paintLeaf(e, bias)
  local m, n, T, S, len = e[1], e[2], e[3], e[4], e[5]
  local tok = { r = { name = "leaf" } }
  local idx = A.toneN(c, m, n, LF, { tok = tok, cuts = { 0.2, 0.37, 0.53, 0.69, 0.85 }, amb = 0.1, wrap = 0.28, bias = bias })
  m:each(function(x, y) local k = K(x, y) local s, t = S[k], T[k]
    local i = idx[k] or 3
    if abs(s) < 0.14 and t < 0.92 then c:put(x, y, s <= 0 and LF[min(6, i + 1)] or LF[max(1, i - 1)], tok)        -- fold crease
    elseif abs(abs(s) - 0.55) < 0.12 and t > 0.08 and t < 0.85 then c:put(x, y, LF[max(1, i - 1)], tok) end      -- parallel vein
  end)
  m:edge():each(function(x, y) local k = K(x, y) if S[k] > 0.6 and T[k] > 0.2 and T[k] < 0.85 then c:put(x, y, COOL, tok) end end)
  return idx
end
-- AO: back leaf darker where it goes behind the shaft / front leaves
local b1 = {}
X.ao(b1, L[1][1], L[3][1], 1, -1)
L[1][1]:cut(sm)
paintLeaf(L[1], b1)

-- shaft: cream base, yellow-green neck, sheath lines, AO under the leaves
local sb = {}
local front = L[3][1]:copy():add(L[2][1])
X.ao(sb, sm, front, 2, -1)
local stok = { r = { name = "shaft" } }
local v = X.light(sn, { amb = 0.1, wrap = 0.3 })
local sidx = {}
sm:each(function(x, y) local k = K(x, y)
  local val = v[k] local i = 1
  for j, t in ipairs{ 0.18, 0.34, 0.5, 0.66, 0.82 } do if val >= t then i = j + 1 end end
  i = max(1, min(6, i + (sb[k] or 0)))
  sidx[k] = i
  local t = ST[k]
  local green = t > 0.62 + 0.05 * sin(SS[k] * 3 + 1)
  c:put(x, y, (green and LG or WH)[i], stok)
  -- lengthwise sheath lines
  if t > 0.06 and t < 0.92 and (abs(SS[k] + 0.32) < 0.09 or abs(SS[k] - 0.38) < 0.09) then c:put(x, y, (green and LG or WH)[max(1, i - 1)], stok) end
end)
-- layered sheath rims (diagonal steps up the shaft)
for _, tr in ipairs{ 0.36, 0.55 } do
  sm:each(function(x, y) local k = K(x, y)
    local d = ST[k] - tr - SS[k] * 0.05
    if d >= 0 and d < 0.035 then c:put(x, y, (ST[k] > 0.62 and LG or WH)[max(1, sidx[k] - 2)], stok) end
  end)
end
-- specular streak on the lit side of the white
for _, t in ipairs{ 0.2, 0.24, 0.28 } do
  local x, y = A.bez(sh, t) c:put(floor(x - 2 + 0.5), floor(y - 2 + 0.5), WH[6], stok)
end

paintLeaf(L[2], {})
paintLeaf(L[3], {})
-- one glint on the front leaf
c:put(38, 23, "#d8f0c0", { r = { name = "leaf" } })

-- root plate (flattened end) and roots
local rp = c:ellipse(14, 52, 3, 3)
rp:cut(sm)
for _, p in ipairs{ { 12, 53 }, { 13, 54 }, { 12, 52 }, { 14, 54 }, { 11, 53 } } do c:put(p[1], p[2], ROOT[2], stok) end
c:put(13, 52, ROOT[3], stok) c:put(14, 53, ROOT[1], stok)
local roots = {
  { { 12, 54 }, { 10, 57 }, { 8, 58 }, { 7, 59 } },
  { { 13, 55 }, { 13, 58 }, { 12, 59 }, { 13, 60 } },
  { { 11, 53 }, { 8, 54 }, { 6, 56 }, { 4, 56 } },
  { { 15, 55 }, { 17, 57 }, { 17, 58 }, { 19, 59 } },
  { { 11, 52 }, { 8, 51 }, { 6, 52 }, { 4, 51 } },
}
local rtok = { r = { name = "root" } }
for ri, r in ipairs(roots) do
  for i = 0, 24 do local x, y = A.bez(r, i / 24)
    c:put(floor(x + 0.5), floor(y + 0.5), (i < 8) and ROOT[3] or ((ri % 2 == 0) and ROOT[2] or ROOT[4]), rtok) end
end
-- quirk: soil clod in the roots
local clod = { { 0, 0, 3 }, { 1, 0, 3 }, { 2, 0, 2 }, { -1, 1, 3 }, { 0, 1, 4 }, { 1, 1, 2 }, { 2, 1, 1 }, { 0, 2, 2 }, { 1, 2, 1 } }
for _, q in ipairs(clod) do c:put(8 + q[1], 55 + q[2], SOIL[q[3]], rtok) end

A.save(c, NAME)
