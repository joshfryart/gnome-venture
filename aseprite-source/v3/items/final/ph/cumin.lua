-- cumin (final, Opus single pass). A small harvest bunch of three dried cumin stalks fanning up from a twine tie.
-- Each slim straw stalk ends in an umbel: thin rays spraying out, every ray tipped with a pair of long ribbed
-- khaki seeds (the split fruit). Threadlike dry leaves curl off the lower stalks. Twine shows a twist pattern,
-- ambient dark where stalks cross and where the twine bites.
-- quirk: one seed pair has come loose and is tumbling down beside the bunch.
local NAME = "cumin"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB23_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local c = A.new(NAME)
local STRAW = { "#4a3a24", "#6c5630", "#8f773e", "#b29a52", "#d2bc6e", "#ece09a" }
local SEED = { "#3a2a1a", "#5a4026", "#7e5c32", "#a27e46", "#c6a462", "#e8d092" }
local TW = { "#4a1f22", "#7a2e2a", "#a8432e", "#cc6440", "#e8925e", "#f6c08c" }
local LEAFD = { "#4e5a2c", "#71803c", "#98a454" }

-- stalks: from the tie (32,46) out to umbel centres
local heads = { { 18, 22 }, { 33, 17 }, { 47, 24 } }
local bottoms = { { 30, 54 }, { 32, 55 }, { 34, 54 } }
local stalks = {}
for i, h in ipairs(heads) do
  local b = bottoms[i]
  local p = { b, { 32 + (b[1] - 32) * 0.5, 44 }, { (32 + h[1]) / 2, 30 }, h }
  local m, n, T, S = A.tube(p, function(t) return 1.05 - 0.25 * t end)
  stalks[i] = { m = m, n = n, T = T, S = S, p = p }
end
-- draw back to front: outer stalks first, centre last; AO where they cross
local order = { 1, 3, 2 }
local drawn = HP.mask()
for _, i in ipairs(order) do
  local s = stalks[i]
  local tok = A.tok("stalk" .. i)
  A.shade(c, s.m, s.n, STRAW, { tok = tok, amb = 0.12, wrap = 0.3, cuts = { 0.18, 0.34, 0.5, 0.68, 0.84 } })
end
-- crossings: darken pixels of back stalks just beside the centre stalk
local front = stalks[2].m
for _, i in ipairs{ 1, 3 } do
  local bias = {}
  X.ao(bias, stalks[i].m, front, 1, -2)
  for k, b in pairs(bias) do local x, y = k % 1024 - 256, k // 1024 - 256 c:put(x, y, STRAW[1], A.tok("stalk" .. i)) end
end
A.shade(c, stalks[2].m, stalks[2].n, STRAW, { tok = A.tok("stalk2"), amb = 0.12, wrap = 0.3, cuts = { 0.18, 0.34, 0.5, 0.68, 0.84 } })

-- thread leaves off the lower stalks
local function thread(pts, col)
  for _, q in ipairs(A.curve(pts, 30)) do
    local free = true
    for _, s in ipairs(stalks) do if s.m:has(q[1], q[2]) then free = false end end
    if free then c:put(q[1], q[2], q[3] < 0.5 and col[2] or col[q[3] < 0.8 and 3 or 2], A.tok("thread")) end
  end
end
thread({ { 28, 40 }, { 24, 38 }, { 21, 39 }, { 19, 42 } }, LEAFD)
thread({ { 37, 35 }, { 41, 33 }, { 44, 34 }, { 45, 37 } }, LEAFD)
thread({ { 25, 33 }, { 22, 31 }, { 20, 32 }, { 19, 34 } }, LEAFD)

-- umbels: rays + seed pairs
local function seedpair(cx, cy, ang, tok)
  -- two long ovals in a slim V
  for j, da in ipairs{ -0.28, 0.28 } do
    local a = ang + da
    local ux, uy = cos(a), sin(a)
    local ox, oy = cx + ux * 2.0, cy + uy * 2.0
    local m, n = A.oval(ox, oy, 2.1, 0.75, a, 0.7)
    local idx = A.toneN(c, m, n, SEED, { tok = tok, amb = 0.12, wrap = 0.3, cuts = { 0.18, 0.34, 0.5, 0.66, 0.84 } })
    -- one pale rib along each seed
    m:each(function(x, y)
      local dx, dy = x - ox, y - oy
      local v = -dx * uy + dy * ux
      local u = dx * ux + dy * uy
      if abs(v) < 0.45 and abs(u) < 2 then c:put(x, y, SEED[min(6, (idx[K(x, y)] or 3) + 1)], tok) end
    end)
  end
end
for i, h in ipairs(heads) do
  local tok = A.tok("umbel" .. i)
  local base = -pi / 2 + (i - 2) * 0.35
  local nr = 5
  for r = 1, nr do
    local a = base + (r - (nr + 1) / 2) * 0.46
    local L = 5.2 + ((r % 2 == 0) and 0.8 or 0)
    local ex, ey = h[1] + cos(a) * L, h[2] + sin(a) * L
    for _, q in ipairs(A.curve({ h, { h[1] + cos(a) * L * 0.33, h[2] + sin(a) * L * 0.33 - 0.5 }, { h[1] + cos(a) * L * 0.66, h[2] + sin(a) * L * 0.66 - 0.5 }, { ex, ey } }, 12)) do
      c:put(q[1], q[2], (cos(a) < 0) and STRAW[5] or STRAW[3], tok)
    end
    seedpair(ex, ey, a, tok)
  end
  c:put(h[1], h[2], STRAW[2], tok)
end

-- twine tie: three wraps around the stalks at y 45..50, twist dashes, loose end
local ttok = A.tok("twine")
local tie = HP.mask()
for y = 45, 50 do for x = 27, 37 do tie:set(x, y) end end
tie:cut(HP.rect(27, 45, 27, 45)):cut(HP.rect(37, 45, 37, 45)):cut(HP.rect(27, 50, 27, 50)):cut(HP.rect(37, 50, 37, 50))
local _, tn = X.cyl(26, 47, 38, 47, function() return 5.5 end, tie)
local tidx = A.shade(c, tie, tn, TW, { tok = ttok, amb = 0.1, wrap = 0.3 })
tie:each(function(x, y)
  local k = K(x, y)
  local i = tidx[k] or 3
  if (x + y * 2) % 4 == 0 then i = i - 2 elseif (x + y * 2) % 4 == 1 then i = i + 1 end  -- twist
  if y == 47 or y == 48 then if x % 5 == 2 then i = i - 1 end end
  c:put(x, y, TW[max(1, min(6, i))], ttok)
end)
-- AO on stalks just above and below the tie
for _, s in ipairs(stalks) do
  s.m:each(function(x, y) if (y == 44 or y == 51) and x >= 26 and x <= 38 then c:put(x, y, STRAW[1], A.tok("stalkao")) end end)
end
-- loose twine end curling out to the right
for i, q in ipairs{ { 38, 49 }, { 39, 50 }, { 40, 51 }, { 41, 51 }, { 42, 52 }, { 43, 53 }, { 43, 54 } } do c:put(q[1], q[2], TW[i % 2 == 0 and 3 or 4], ttok) end
-- cut stalk ends: pale end grain at the bottoms
for _, b in ipairs(bottoms) do c:put(b[1], b[2] + 1, STRAW[6], A.tok("endgrain")) end

-- quirk: a loose seed pair tumbling down at the right
seedpair(51, 37, 1.1, A.tok("loose"))
c:put(17, 15, A.CREAM, A.tok("umbel1"))
A.save(c, NAME)
