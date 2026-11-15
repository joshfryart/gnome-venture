-- yarn-scarf: hand-knitted scarf, rust red with pine-teal stripes, knotted with two tails and fringes.
-- quirk: one loose strand of yarn unravelling from the left tail.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local W = dofile(DIR .. "/_gw.lua")
local HP, X, K, R, G = W.HP, W.X, W.K, W.R, W.G
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "yarn-scarf" }
local floor, abs = math.floor, math.abs

-- knitted band along a bezier: stripes along length, knit V columns across
local function band(pts, w, len, phase, bias)
  local m, n, T, S = G.tube(pts, function() return w end)
  local b = {}
  if bias then m:each(function(x, y) b[K(x, y)] = bias end) end
  local idxA = W.toneN(c, m, n, R.yarnA, { bias = b, cuts = { .2, .36, .52, .7, .88 } })
  m:each(function(x, y)
    local k = K(x, y)
    local u = T[k] * len + phase
    local i = idxA[k]
    local ramp = (floor(u) % 10 >= 6) and R.yarnB or R.yarnA
    -- knit V: columns across the width, chevron offset along the length
    local col = (S[k] + 1) * w
    local cf = col - floor(col / 2.5) * 2.5
    local d = 0
    if cf < 0.7 and floor(u) % 2 == 0 then d = -1 end
    if floor(u) % 3 == 0 and cf > 1.6 then d = -1 end
    i = math.max(1, math.min(6, i + d))
    c:put(x, y, ramp[i])
  end)
  return m, T, S
end

-- neck loop (behind), then knot, then the two tails
local loopM = band({ {26,17}, {7,-2}, {57,-2}, {38,17} }, 3.2, 56, 3, -1)
local tailL = G.tube({ {29,19}, {24,30}, {18,41}, {20,52} }, function() return 4.4 end)
local tailR = G.tube({ {35,19}, {41,28}, {47,37}, {45,49} }, function() return 4.4 end)
W.sep(c, tailL:copy():add(tailR), loopM, W.ink)
band({ {29,19}, {24,30}, {18,41}, {20,52} }, 4.4, 36, 0, nil)
local rM = band({ {35,19}, {41,28}, {47,37}, {45,49} }, 4.4, 33, 5, nil)
-- separation where the right tail meets the left
local knot = c:ellipse(32, 18, 5, 4)
W.sep(c, knot, tailL:copy():add(tailR):add(loopM), W.ink)
local ki = W.lit(c, knot, R.yarnA, { R = 3 })
W.retone(c, knot, ki, R.yarnA, function(x, y) if (x + floor(y / 2)) % 3 == 0 then return -1 end end)
-- knot wrap line
for y = 15, 21 do c:put(31 + (y > 18 and 1 or 0), y, R.yarnB[y < 18 and 4 or 2]) c:put(32 + (y > 18 and 1 or 0), y, R.yarnB[y < 18 and 5 or 3]) end
-- fringes
local function fringe(x0, y0, n, ramp)
  for j = 0, n - 1 do
    local x = x0 + j * 2
    local L = 3 + (j % 2)
    for y = 0, L do c:put(x, y0 + y, ramp[y == L and 3 or 4]) end
  end
end
fringe(15, 55, 5, R.yarnA)
fringe(41, 52, 5, R.yarnB)
-- quirk: loose strand curling off the left tail
local strand = c:line({ {24,54}, {26,57}, {29,58}, {31,56}, {30,54} }, 1)
strand:each(function(x, y) if not c:get(x, y) then c:put(x, y, R.yarnA[4]) end end)
c:put(30, 54, R.yarnA[6])
-- wool pop
c:put(26, 23, R.yarnA[6]) c:put(27, 23, W.cream)
W.save(c, "yarn-scarf")
