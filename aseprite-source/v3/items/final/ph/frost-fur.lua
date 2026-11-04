-- frost-fur (aB32_5, Opus single pass). A slim S-curved lock of pale winter fur, bound at the top by a leather tab
-- and a twisted red cord with a hanging loop. Fur is lit as a soft cylinder with strand grooves and lit strand lines,
-- splitting into three pointed clumps; the lower third is frosted (cool ice ramp, rime flecks) and each clump tip
-- drips a thin icicle. Ambient seam under the cord wrap.
-- quirk: one snowflake is caught in the fur.
local NAME = "frost-fur"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB32_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, max, min, pi = math.floor, math.abs, math.sin, math.cos, math.max, math.min, math.pi
local c = A.new(NAME)
local FUR = { "#4a4270", "#6d6a9c", "#9a9cc4", "#c6cbe2", "#e6e8f0", "#fff4d6" }
local ICE = { "#2a4a7a", "#3a7fae", "#5fb6cc", "#97dce2", "#c9f1ec", "#ecfcf6" }
local CORD = { "#5e1d36", "#9a2a3a", "#d0453c", "#f27a52" }
local HIDE = { "#4e2e2a", "#7e4a33", "#ad7448", "#d9a46e" }

local path = { { 20, 14 }, { 10, 30 }, { 50, 27 }, { 42, 45 } }
local m, n, T, S = A.tube(path, function(t)
  if t < 0.05 then return 2.6 end
  return 2.6 + 3.6 * sin(pi * min(1, (t - 0.05) * 1.25)) ^ 0.7 + (t > 0.8 and 1.2 or 0)
end)
-- split the end into three pointed clumps (different lengths)
local TE = { 0.93, 1.0, 0.88 }
local T0 = 0.66
local cut = {}
m:each(function(x, y) local k = K(x, y)
  local t, s = T[k], S[k]
  if t > T0 then
    local q = (s + 1) / 2 * 3
    local i = max(0, min(2, floor(q)))
    local f = q - i - 0.5
    local te = TE[i + 1]
    local allow = 0.52 * max(0, (te - t) / (te - T0)) ^ 0.8
    if abs(f) > allow then cut[#cut + 1] = k end
  end
end)
for _, k in ipairs(cut) do m.s[k] = nil end

local tok = { r = { name = "fur" } }
local bias = {}
-- ambient under the cord wrap
m:each(function(x, y) local t = T[K(x, y)] if t > 0.13 and t < 0.18 then bias[K(x, y)] = -1 end end)
local idx = A.shade(c, m, n, FUR, { tok = tok, bias = bias, cuts = { 0.14, 0.3, 0.48, 0.66, 0.84 }, amb = 0.1, wrap = 0.3 })
local frost = {}
m:each(function(x, y) local k = K(x, y)
  local t, s = T[k], S[k]
  local i = idx[k]
  local ph = s * 5.2 + 0.7 * sin(t * 11)
  local f = ph - floor(ph)
  if f < 0.2 then i = i - 1 elseif f > 0.5 and f < 0.66 and s < 0.3 then i = i + 1 end
  i = max(1, min(6, i)) idx[k] = i
  local fr = t > 0.6 + 0.08 * X.hash(x, y, 3)
  frost[k] = fr
  c:put(x, y, (fr and ICE or FUR)[i], tok)
  if fr and X.hash(x, y, 9) < 0.06 and i >= 3 then c:put(x, y, ICE[6], tok) end
end)

-- icicles from each clump tip
local tips = {}
m:each(function(x, y) local k = K(x, y)
  local q = (S[k] + 1) / 2 * 3 local i = max(0, min(2, floor(q))) + 1
  if not tips[i] or T[k] > tips[i][3] then tips[i] = { x, y, T[k] } end end)
local itok = { r = { name = "ice" } }
for i, tp in ipairs(tips) do
  local L = ({ 3, 5, 3 })[i]
  for d = 1, L do
    c:put(tp[1], tp[2] + d, d < L and ICE[5] or ICE[6], itok)
    if d <= 2 then c:put(tp[1] + 1, tp[2] + d, ICE[3], itok) end
  end
end

-- leather tab at the root
local tab = HP.mask()
m:each(function(x, y) if T[K(x, y)] < 0.07 then tab:set(x, y) end end)
tab:add(c:rrect(16, 9, 22, 15, 1))
local htok = { r = { name = "hide" } }
tab:each(function(x, y) local i = (x + y < 29) and 4 or ((x - y > 7) and 2 or 3) if y == 15 then i = 1 end c:put(x, y, HIDE[i], htok) end)
c:put(18, 11, HIDE[2], htok) c:put(20, 12, HIDE[2], htok)

-- twisted cord wrap
local ctok = { r = { name = "cord" } }
local cord = HP.mask()
m:each(function(x, y) local t = T[K(x, y)] if t > 0.08 and t < 0.13 then cord:set(x, y) end end)
cord = cord:grow(1):clip(m:copy():add(tab):grow(1))
cord:each(function(x, y)
  local ph = (x + y * 0.8) / 2.5
  local f = ph - floor(ph)
  local i = f < 0.45 and 3 or 2
  if f > 0.15 and f < 0.3 then i = 4 end
  if not cord:has(x + 1, y + 1) and not cord:has(x, y + 1) then i = 1 end
  c:put(x, y, CORD[i], ctok)
end)
-- hanging loop
local loop = c:ellipse(15, 9, 3.2, 3.6):cut(c:ellipse(15, 9, 1.9, 2.3))
loop:cut(tab)
loop:each(function(x, y) c:put(x, y, (x - 15) + (y - 9) < 0 and CORD[3] or CORD[2], ctok) end)

-- quirk: snowflake caught in the fur (cream arms on a darker fur shadow)
local sx, sy = 26, 27
for _, q in ipairs{ { 0, 0 }, { -1, 0 }, { 1, 0 }, { 0, -1 }, { 0, 1 }, { -2, -2 }, { 2, 2 }, { 2, -2 }, { -2, 2 }, { -2, 0 }, { 2, 0 }, { 0, -2 }, { 0, 2 } } do
  if m:has(sx + q[1], sy + q[2]) then
    local cc = (abs(q[1]) == 2 or abs(q[2]) == 2) and ICE[4] or A.CREAM
    c:put(sx + q[1], sy + q[2], cc, tok)
  end
end
for _, q in ipairs{ { 1, 1 }, { -1, 1 }, { 1, -1 } } do if m:has(sx + q[1], sy + q[2]) then c:put(sx + q[1], sy + q[2], FUR[2], tok) end end

-- pop: soft sheen on the fur's lit shoulder
c:put(16, 20, A.CREAM, tok) c:put(17, 20, A.CREAM, tok)

A.save(c, NAME)
