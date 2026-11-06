-- old-campfire-ash (final, Opus C3 single pass). A cold fire pit seen low: a soft mound of violet-grey ash
-- (speckled flakes, darker char crumbs, a sunken crater), ringed by rounded fieldstones (back ones half hidden,
-- front ones overlapping the mound, soot-stained tops, AO in every joint). Two charred sticks lie crossed in the ash,
-- their char cracked into alligator scales; one end still holds a red-orange ember seam, a thin smoke curl rises from it.
-- quirk: a single fresh green seedling has already pushed up through the ash.
local NAME = "old-campfire-ash"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC30_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local ASH = { "#3e3b50", "#57546a", "#757288", "#9794a8", "#b9b7c6", "#dddbe5" }
local STN = { "#352f40", "#4e4656", "#6d6372", "#8f8590", "#b2a8ac", "#d6cec8" }
local CHAR = { "#251a22", "#33242a", "#46323a", "#5e4548", "#7a5c58", "#9a7a6c" }
local EMB = { "#7a1f2e", "#c23a2c", "#ee6a2c", "#ffa242", "#ffd877" }
local SMOKE = { "#9a98ae", "#c4c2d2" }
local SPR = { "#245a40", "#3f8a48", "#6cb456", "#a6d878" }

c:groundShadow(32, 50, 24, 3)

-- back stones (behind the mound)
local stoneTok = A.tok("stones")
local function stone(cx, cy, rx, ry, ang, under)
  local m, n = A.oval(cx, cy, rx, ry, ang or 0, 0.9)
  if under then m:cut(under) end
  return m, n
end
local back = { { 15, 37, 4.0, 3.2 }, { 23, 33, 4.2, 3.0 }, { 32, 32, 4.4, 3.0 }, { 41, 33, 4.2, 3.0 }, { 49, 37, 4.0, 3.2 } }
-- ash mound
local am = HP.mask()
for y = 28, 52 do for x = 6, 58 do
  local dx, dy = (x - 32) / 19.5, (y - 43) / 8.5
  if dx * dx + dy * dy <= 1 and y >= 34 + (abs(x - 32) > 14 and (abs(x - 32) - 14) * 0.6 or 0) - 4 then am:set(x, y) end
end end
local an = {}
am:each(function(x, y)
  local dx, dy = (x - 32) / 19.5, (y - 46) / 9.5
  local q = max(0.02, 1 - dx * dx - dy * dy)
  an[K(x, y)] = { A.norm(dx * 0.8, dy * 1.2 - 0.35, sqrt(q)) }
end)
for i, s in ipairs(back) do
  local m, n = stone(s[1], s[2], s[3], s[4], 0, am)
  local sb = {}
  if i > 1 then X.ao(sb, m, A.oval(back[i - 1][1], back[i - 1][2], back[i - 1][3], back[i - 1][4], 0), 1, -1) end
  local idx = A.toneN(c, m, n, STN, { tok = stoneTok, bias = sb, cuts = { 0.14, 0.3, 0.46, 0.62, 0.8 }, amb = 0.12, wrap = 0.3 })
end

-- mound tone + texture, crater
local abias = {}
local idxA = A.toneN(c, am, an, ASH, { tok = A.tok("ash"), bias = abias, cuts = { 0.14, 0.3, 0.46, 0.62, 0.8 }, amb = 0.14, wrap = 0.35 })
local atok = A.tok("ash")
am:each(function(x, y) local h = X.hash(x, y, 11)
  if h > 0.9 then A.step(c, idxA, ASH, x, y, 1, atok)
  elseif h < 0.07 then A.step(c, idxA, ASH, x, y, -1, atok)
  elseif h < 0.1 and y > 38 then c:put(x, y, CHAR[3], atok) end
  -- sunken crater around the centre (inner bowl: shade on its upper-left wall, light on its lower-right lip)
  local dx, dy = (x - 31) / 9, (y - 39) / 3.2
  local r = dx * dx + dy * dy
  if r < 1 then A.step(c, idxA, ASH, x, y, (dx + dy < 0) and -2 or 0, atok)
  elseif r < 1.45 and dx + dy > 0.3 then A.step(c, idxA, ASH, x, y, 1, atok) end
end)

-- charred sticks, crossed
local ctok = A.tok("char")
local s1 = { { 11, 40 }, { 21, 39 }, { 34, 38 }, { 46, 31 } }
local s2 = { { 18, 30 }, { 28, 35 }, { 40, 40 }, { 52, 42 } }
local m2, n2, T2, S2 = A.tube(s2, function(t) return 2.2 - t * 0.4 end)
local m1, n1, T1, S1 = A.tube(s1, function(t) return 2.4 - t * 0.6 end)
m2:cut(m1)
local function char(m, n, T, S, seed, bias)
  local idx = A.toneN(c, m, n, CHAR, { tok = ctok, bias = bias, cuts = { 0.18, 0.34, 0.5, 0.66, 0.84 }, amb = 0.1, wrap = 0.3 })
  -- alligator cracks: cross-grain notches every ~3 px + split along the grain
  m:each(function(x, y) local k = K(x, y)
    local u = T[k] * 40 + (S[k] > 0 and 1.5 or 0)
    if abs(u - floor(u / 3 + 0.5) * 3) < 0.35 then A.step(c, idx, CHAR, x, y, -2, ctok)
    elseif abs(S[k]) < 0.12 then A.step(c, idx, CHAR, x, y, -1, ctok) end
  end)
  return idx
end
local b2 = {}
X.ao(b2, m2, m1, 1, -2)
char(m2, n2, T2, S2, 2, b2)
local idx1 = char(m1, n1, T1, S1, 1)
-- AO + contact shadow of sticks on the ash
local sh = m1:copy():add(m2)
sh:shift(1, 2):each(function(x, y) if am:has(x, y) and not sh:has(x, y) then A.step(c, idxA, ASH, x, y, -2, atok) end end)
-- pale end grain on the near-left stick end
for _, q in ipairs{ { 10, 39, 6 }, { 10, 40, 5 }, { 10, 41, 4 }, { 11, 39, 5 } } do c:put(q[1], q[2], CHAR[q[3]], ctok) end
-- ember seam on the right end of stick 2 (glowing cracks)
local etok = A.tok("ember")
m2:each(function(x, y) local k = K(x, y)
  if T2[k] > 0.82 then
    local u = T2[k] * 40 + (S2[k] > 0 and 1.5 or 0)
    if abs(u - floor(u / 3 + 0.5) * 3) < 0.4 then c:put(x, y, S2[k] < 0 and EMB[4] or EMB[3], etok)
    elseif S2[k] > 0.45 then c:put(x, y, EMB[1], etok) end
  end
end)
c:put(53, 41, EMB[2], etok) c:put(53, 42, EMB[3], etok) c:put(52, 41, EMB[5], etok)

-- front stones over the mound foot
local front = { { 11, 45, 4.2, 3.4, 0.2 }, { 19, 49, 4.7, 3.4, 0.1 }, { 28, 51, 4.9, 3.3, 0 }, { 37, 51, 4.8, 3.3, 0 }, { 46, 49, 4.7, 3.4, -0.1 }, { 53, 45, 4.0, 3.4, -0.2 } }
local prev
for i, s in ipairs(front) do
  local m, n = A.oval(s[1], s[2], s[3], s[4], s[5], 0.9)
  local sb = {}
  if prev then X.ao(sb, m, prev, 1, -1) end
  local idx = A.toneN(c, m, n, STN, { tok = stoneTok, bias = sb, cuts = { 0.14, 0.3, 0.46, 0.62, 0.8 }, amb = 0.12, wrap = 0.3 })
  -- soot stain on the top (fire side), lichen-free; a crack line on two stones
  m:each(function(x, y) if y < s[2] - s[4] + 1.5 and X.hash(x, y, 5) > 0.45 then A.step(c, idx, STN, x, y, -2, stoneTok) end end)
  if i == 3 or i == 5 then for d = 0, 2 do if m:has(s[1] + 1 + d, s[2] - 1 + d) then A.step(c, idx, STN, s[1] + 1 + d, s[2] - 1 + d, -2, stoneTok) end end end
  prev = m
end

-- smoke curl rising from the ember end
local stk = A.tok("smoke")
local curl = { { 50, 37, 2 }, { 49, 36, 2 }, { 49, 35, 1 }, { 50, 34, 1 }, { 51, 33, 2 }, { 51, 32, 2 }, { 50, 31, 1 }, { 49, 30, 2 }, { 49, 29, 2 }, { 50, 28, 1 }, { 51, 27, 2 } }
for _, q in ipairs(curl) do c:put(q[1], q[2], SMOKE[q[3]], stk) end

-- quirk: seedling through the ash, in front of the crater
local ptok = A.tok("seedling")
for _, q in ipairs{ { 22, 36, 2 }, { 22, 35, 2 }, { 22, 34, 3 }, { 22, 33, 3 } } do c:put(q[1] + 2, q[2] + 11, SPR[q[3]], ptok) end
local leaves = { { 19, 31, 3 }, { 20, 31, 4 }, { 20, 32, 3 }, { 21, 32, 2 }, { 23, 31, 3 }, { 24, 31, 3 }, { 24, 30, 4 }, { 25, 30, 2 }, { 23, 32, 2 }, { 18, 30, 2 } }
for _, q in ipairs(leaves) do c:put(q[1] + 2, q[2] + 11, SPR[q[3]], ptok) end

A.save(c, NAME)
