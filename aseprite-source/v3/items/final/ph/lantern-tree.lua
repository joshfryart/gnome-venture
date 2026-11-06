-- lantern-tree (final, Opus single pass). A slim young lantern tree (Crinodendron): a thin leaning trunk with bark
-- grain and a root flare, forking into an upright canopy built from overlapping leaf clumps (each lit per pixel,
-- AO + cast shadow where a clump overlaps the one behind, speckled leaf texture), with crimson lantern-bell flowers
-- hanging on thread-thin stalks below the canopy (6-tone, waxy spec, pale petal tips). Ground shadow under the foot.
-- quirk: a firefly has crept into one lantern, which glows gold instead of red.
local NAME = "lantern-tree"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC15_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)

local LEAF = { "#14302e", "#1d4a3a", "#2a6842", "#3f8a48", "#62ab52", "#97cc68" }
local BARK = { "#3a2422", "#563428", "#7a4c32", "#9e6a42", "#c08c5a", "#ddb07c" }
local RED  = { "#4a1030", "#7a1834", "#ad243a", "#d8403e", "#f56e52", "#ffb08a" }
local GOLD = { "#7a3c1c", "#b8661e", "#e89a26", "#fbc840", "#ffe680", "#fff6c4" }
local PED = "#5a2a30"

c:groundShadow(31, 53, 9, 1)

-- trunk: thin, slight S, root flare, fork into canopy
local btok = { r = { name = "bark" } }
local tm, tn, TT, TS = A.stem(c, { { 31, 53 }, { 33, 45 }, { 29, 37 }, { 31, 28 } }, function(t) return 1.5 + 1.4 * (1 - t) ^ 3 end, BARK, { tok = btok })
local b1 = A.stem(c, { { 30, 37 }, { 27, 34 }, { 24, 31 }, { 22, 27 } }, function(t) return 1.0 - 0.3 * t end, BARK, { tok = btok, cut = tm })
local b2 = A.stem(c, { { 31, 33 }, { 34, 31 }, { 37, 29 }, { 40, 25 } }, function(t) return 0.9 - 0.2 * t end, BARK, { tok = btok, cut = tm })
-- bark grain: broken vertical dark lines + pale lit flecks
tm:each(function(x, y) local k = K(x, y)
  local s = TS[k]
  if s > 0.15 and s < 0.6 and X.hash(x, y, 3) > 0.45 then c:put(x, y, BARK[2], btok) end
  if s < -0.4 and X.hash(x, y, 5) > 0.7 and y < 49 then c:put(x, y, BARK[6], btok) end
end)
-- root flare spurs
for _, p in ipairs{ { 28, 53, 3 }, { 27, 54, 2 }, { 34, 53, 2 }, { 35, 54, 1 } } do c:put(p[1], p[2], BARK[p[3]], btok) end

-- canopy: clumps back to front (cx, cy, rx, ry)
local clumps = {
  { 32, 12, 7, 5.5 }, { 25, 17, 6, 5 }, { 39, 17, 6, 5 }, { 31, 20, 8, 6 },
  { 22, 25, 5.5, 4.5 }, { 41, 25, 5.5, 4.5 }, { 32, 27, 7, 4.5 }, { 33, 9, 4, 3 },
}
local masks = {}
for i, q in ipairs(clumps) do
  local mm = HP.mask()
  for y = floor(q[2] - q[4] - 1), floor(q[2] + q[4] + 1) do for x = floor(q[1] - q[3] - 1), floor(q[1] + q[3] + 1) do
    local dx, dy = (x + 0.5 - q[1]) / (q[3] + 0.3), (y + 0.5 - q[2]) / (q[4] + 0.3)
    -- leafy scallop on the rim
    local a = math.atan(dy, dx)
    local r = 1 + 0.09 * sin(a * 7 + i)
    if dx * dx + dy * dy <= r * r then mm:set(x, y) end
  end end
  masks[i] = mm
end
local canopy = HP.mask()
for _, mm in ipairs(masks) do canopy:add(mm) end
local ltok = { r = { name = "leaf" } }
local gC = { 31, 17, 16 }   -- global canopy sphere for overall light
for i, q in ipairs(clumps) do
  local later = HP.mask()
  for j = i + 1, #clumps do later:add(masks[j]) end
  local vis = masks[i]:copy():cut(later)
  local ns = X.sphere(q[1], q[2], max(q[3], q[4]), masks[i])
  local ng = X.sphere(gC[1], gC[2], gC[3], masks[i])
  local n = {}
  for k, a in pairs(ns) do local b = ng[k] local w = 0.55
    n[k] = { A.norm(a[1] * w + b[1] * (1 - w), a[2] * w + b[2] * (1 - w), a[3] * w + b[3] * (1 - w)) } end
  local bias = {}
  A.cast(bias, vis, later, 1, 1, -2)
  X.ao(bias, vis, later, 1, -1)
  -- underside of whole canopy darker (lanterns hang in its shade)
  vis:each(function(x, y) if not canopy:has(x, y + 2) then local k = K(x, y) bias[k] = (bias[k] or 0) - 1 end end)
  local idx = A.shade(c, vis, n, LEAF, { amb = 0.08, wrap = 0.3, cuts = { 0.16, 0.32, 0.48, 0.64, 0.8 }, bias = bias, tok = ltok })
  -- leaf texture: little lit leaf ticks and dark gaps
  vis:each(function(x, y) local k = K(x, y) local i2 = idx[k]
    if not i2 then return end
    local h = X.hash(x, y, 17 + i)
    if h > 0.86 and i2 >= 3 and vis:has(x + 1, y) then c:put(x, y, LEAF[min(6, i2 + 1)], ltok) c:put(x + 1, y, LEAF[min(6, i2 + 1)], ltok)
    elseif h < 0.08 and i2 >= 2 then c:put(x, y, LEAF[i2 - 1], ltok) end
  end)
end
-- canopy contact shadow on the trunk + branch shown entering the canopy
for x = 29, 33 do if tm:has(x, 31) and not canopy:has(x, 31) then c:put(x, 31, BARK[1], btok) end end

-- lanterns: pedicel anchor (x, y), drop length, colour ramp
local lanterns = { { 21, 29, 3, RED }, { 27, 31, 4, RED }, { 37, 31, 3, GOLD }, { 43, 29, 4, RED }, { 33, 32, 5, RED } }
local function lantern(x, ytop, R, glow)
  local tok = { r = { name = "lantern" .. x } }
  -- 4 wide bell, 6 tall: calyx, swelling body, flared lip, petal tips
  local rows = {
    ".ab.",
    "abcc",
    "bdcc",
    "bdcb",
    "bccb",
    "abba",
    "e..e",
  }
  local map = { a = R[3], b = R[4], c = R[5], d = R[6], e = R[2] }
  if glow then map = { a = R[3], b = R[4], c = R[5], d = R[6], e = R[3] } end
  -- shading: right column darker
  for j, row in ipairs(rows) do for i = 1, #row do local ch = row:sub(i, i)
    if ch ~= "." then
      local col = map[ch]
      if i == 4 and ch ~= "e" then col = R[2] end
      if i == 3 and j > 2 and ch ~= "d" then col = R[3] end
      c:put(x - 2 + i - 1, ytop + j - 1, col, tok)
    end
  end end
  c:put(x - 1, ytop, glow and R[5] or "#3f8a48", tok)   -- calyx green dot / glowing cap
  c:put(x - 1, ytop + 2, glow and R[6] or R[6], tok)     -- waxy spec
end
for _, L in ipairs(lanterns) do
  local x, y0, d, R = L[1], L[2], L[3], L[4]
  local ptok = { r = { name = "ped" } }
  for y = y0, y0 + d - 1 do c:put(x, y, PED, ptok) end
  lantern(x, y0 + d, R, R == GOLD)
end

A.save(c, NAME)
