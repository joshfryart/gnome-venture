-- coconut-husk (final, Opus single pass). A curved shard of coconut husk on the diagonal: smooth brown outer skin on
-- the convex lower edge (lengthwise ridges, one specular, cool bounce), a deep seam where skin meets fibre, and the
-- torn coir face on top: tan fibres in parallel strands with a few lifted, twisted loose ends at both tips.
-- quirk: one long loose fibre has curled itself into a tidy little loop.
local NAME = "coconut-husk"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB20_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)

local SKIN = { "#24161a", "#3e2420", "#5c3624", "#7e4e2c", "#a06a38", "#c48e50" }
local FIB = { "#4a2c1c", "#6e4428", "#946230", "#b8864a", "#d8aa66", "#f0d094" }
local COOL = "#5c4c70"

local pts = { { 13, 42 }, { 21, 54 }, { 40, 51 }, { 51, 23 } }
local m, n, T, S = A.tube(pts, function(t) return max(0.6, 7.2 * sin(pi * t) ^ 0.75) end)
local tok_s, tok_f = { r = { name = "skin" } }, { r = { name = "fibre" } }
-- split: outer skin = shade side band (lower right), coir face = rest
local skin, fib = HP.mask(), HP.mask()
m:each(function(x, y) local k = K(x, y) if S[k] > 0.3 then skin:set(x, y) else fib:set(x, y) end end)
-- coir face lit as a shallow trough (concave): flip the across-normal
local fn = {}
fib:each(function(x, y) local k = K(x, y) local a = n[k] fn[k] = { -a[1] * 0.5, -a[2] * 0.5, 1 } end)
for k, v in pairs(fn) do local l = sqrt(v[1]^2 + v[2]^2 + v[3]^2) fn[k] = { v[1] / l, v[2] / l, v[3] / l } end
local fb = {}
X.ao(fb, fib, skin, 1, -1)
local fidx = A.shade(c, fib, fn, FIB, { tok = tok_f, bias = fb, amb = 0.1, wrap = 0.3, cuts = { 0.3, 0.45, 0.6, 0.74, 0.86 } })
-- fibres: parallel strands along the shard, broken into lengths, alternating tone
fib:each(function(x, y) local k = K(x, y)
  local lane = floor((S[k] + 1) * 7)
  local seg = floor(T[k] * 30 + X.hash(lane, 0, 4) * 6)
  local h = X.hash(lane, seg, 9)
  local i = fidx[k]
  if lane % 2 == 0 then i = i - 1 end
  if h > 0.8 then i = i + 1 elseif h < 0.12 then i = i - 1 end
  if not fb[k] then c:put(x, y, FIB[max(1, min(6, i))], tok_f) end
end)
-- skin: smooth, ridged lengthwise, spec + cool bounce
local sidx = A.shade(c, skin, n, SKIN, { tok = tok_s, amb = 0.12, wrap = 0.35, cuts = { 0.12, 0.26, 0.4, 0.55, 0.72 } })
skin:each(function(x, y) local k = K(x, y)
  if abs(S[k] - 0.62) < 0.06 and sidx[k] > 1 then c:put(x, y, SKIN[sidx[k] - 1], tok_s) end
  if X.hash(x, y, 13) > 0.9 and sidx[k] > 1 then c:put(x, y, SKIN[sidx[k] - 1], tok_s) end end)
-- seam: deep row along the skin's top edge where it meets the fibre
skin:each(function(x, y) if fib:has(x, y - 1) or fib:has(x - 1, y) then c:put(x, y, SKIN[1], tok_s) end end)
-- ridge highlight just below the seam (rounded lip)
skin:each(function(x, y) local k = K(x, y) if S[k] > 0.34 and S[k] < 0.44 and T[k] > 0.25 and T[k] < 0.75 then c:put(x, y, SKIN[5], tok_s) end end)
local rim = X.rim(n)
skin:edge():each(function(x, y) local k = K(x, y) if rim[k] > 0.7 and T[k] > 0.15 and T[k] < 0.85 then c:put(x, y, COOL, tok_s) end end)
-- spec 2x1 on the skin
do local x, y = A.bez(pts, 0.5) local bx, by = floor(x + 4.5), floor(y + 3.5)
  if skin:has(bx, by) then c:put(bx, by, "#fff4d6", tok_s) end if skin:has(bx + 1, by) then c:put(bx + 1, by, SKIN[6], tok_s) end end

-- loose fibres at the tips: 1 px strands with a light/dark twist pattern
local function strand(p, name, n0)
  local tk = { r = { name = name } }
  local N = n0 or 40
  local last
  for i = 0, N do local x, y = A.bez(p, i / N)
    local xi, yi = floor(x + .5), floor(y + .5)
    local key = xi .. "," .. yi
    if key ~= last and not m:has(xi, yi) then c:put(xi, yi, (xi + yi) % 3 == 0 and FIB[2] or FIB[4], tk) end
    last = key
  end
end
strand({ { 14, 41 }, { 12, 38 }, { 11, 36 }, { 10, 34 } }, "s1")
strand({ { 14, 43 }, { 12, 44 }, { 10, 43 }, { 8, 44 } }, "s2")
strand({ { 49, 25 }, { 50, 21 }, { 49, 18 }, { 51, 15 } }, "s3")
-- quirk: loop
strand({ { 51, 23 }, { 55, 21 }, { 56, 16 }, { 53, 14 } }, "s4")
strand({ { 53, 14 }, { 50, 13 }, { 51, 18 }, { 54, 17 } }, "s4")

A.save(c, NAME)
