-- cannonball-tree-seed (final, Opus single pass, replaces the Sonnet draft). Three small flattened oval cannonball-tree
-- seeds (warm brown, per-pixel dome light, a pale fibrous coat that frays into hair tufts at the edge, a dark hilum
-- notch, glossy glint, contact shadow) on a torn scrap of the tree's long leaf (pinnate veins, jagged rip on the right,
-- a tear notch in the lower margin, cool lower-right rim). The middle seed has germinated: a thin root, a pale bowed
-- stem and two long, narrow obovate leaves with the cannonball tree's leaf shape (midrib, veins, a tiny drip tip).
-- quirk: a smear of the fruit's pulp clings to the left seed, turned blue-green the way cannonball pulp does in air.
local NAME = "cannonball-tree-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB1r0_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sqrt, max, min, abs, sin, cos, pi = math.floor, math.sqrt, math.max, math.min, math.abs, math.sin, math.cos, math.pi
local c = A.new(NAME)

local LEAF  = { "#173f33", "#225a3d", "#2f7744", "#46954b", "#68b452", "#98d06a" }
local YOUNG = { "#24544a", "#2f7a4a", "#4a9c50", "#6cba58", "#98d270", "#c8e894" }
local SEED  = { "#3a1e1a", "#5e3222", "#86502c", "#aa7238", "#cc9a52", "#ead08a" }
local STEM  = { "#5b8a4a", "#8cb862", "#bcdc8a" }
local PULP  = { "#2a6a6a", "#3e9a92", "#7cccb8" }
local SPEC  = "#fff4dc"

-- seeds (masks first, for leaf shadows)
local seeds = {
  { 18, 44, 4.2, 3.0, -0.35 },
  { 31, 46, 4.4, 3.1, 0.1 },
  { 43, 43, 4.0, 2.9, 0.45 },
}
local sAll = HP.mask()
for _, s in ipairs(seeds) do
  s.m, s.n = A.oval(s[1], s[2], s[3], s[4], s[5], 0.7)
  sAll:add(s.m)
end

-- torn leaf scrap: long blade on a shallow diagonal
local wfn = function(t)
  if t > 0.99 then return -1 end
  return 7.2 * (0.55 + 0.45 * sin(pi * min(1, t * 0.9 + 0.1)) ^ 0.6)
end
local cut = HP.mask()
-- jagged rip at the right end and a notch in the lower margin
for y = 20, 63 do for x = 0, 63 do
  local rip = 51 + floor(X.hash(floor(y / 2), 3, 9) * 4) - (y - 40) * 0.3
  if x > rip then cut:set(x, y) end
  if x < 7 + X.hash(floor(y / 2), 5, 2) * 3 then cut:set(x, y) end
end end
cut:add(c:poly{ { 22, 54 }, { 26, 49 }, { 29, 55 } })
local bias = {}
local lm0 = A.blade(6, 50, 30, 42, 58, 44, wfn, { fold = 0.4 })
X.ao(bias, lm0, sAll, 1, -1) A.cast(bias, lm0, sAll, 1, 2, -1) A.cast(bias, lm0, sAll, 2, 3, -1)
local lm, LT, LS, li = A.leaf(c, 6, 50, 30, 42, 58, 44, 7.2, LEAF, { wfn = wfn, cut = cut, bias = bias, vs = 3.4, fold = 0.4 })
-- cool rim lower-right on the leaf edge, pale torn fibres on the rip
local ltok = { r = { name = "leaf" } }
lm:edge():each(function(x, y)
  if LS[K(x, y)] and LS[K(x, y)] > 0.6 and not lm:has(x, y + 1) and X.hash(x, y, 4) > 0.4 then c:put(x, y, "#3f7a78", ltok) end
  if cut:has(x + 1, y) and x > 40 then c:put(x, y, LEAF[6], ltok) end
end)

-- sprout from the middle seed: root, stem, two narrow obovate leaves
local sx, sy = 32, 44
local rtok = { r = { name = "stem" } }
A.map(c, { "a..", ".a.", ".ab" }, sx + 3, sy + 2, { a = "#e8dcc0", b = "#c8b898" }, rtok)
local sp = { { sx, sy - 1 }, { sx + 1, sy - 10 }, { sx - 3, sy - 17 }, { sx - 1, sy - 26 } }
for i = 0, 60 do local t = i / 60 local x, y = A.bez(sp, t)
  local xi, yi = floor(x + .5), floor(y + .5)
  c:put(xi, yi, STEM[3], rtok) c:put(xi + 1, yi, STEM[2], rtok)
  if t < 0.3 then c:put(xi + 1, yi, STEM[1], rtok) end
end
local TX, TY = A.bez(sp, 1)
local function obov(t) if t > 0.97 then return -1 end return max(0.4, 4.3 * sin(pi * min(1, t ^ 1.4 * 0.95 + 0.04)) ^ 0.7) end
local tl1 = A.leaf(c, TX, TY, TX + 7, TY - 9, TX + 17, TY - 9, 4.3, YOUNG, { wfn = obov, vs = 2.8 })
local tl2 = A.leaf(c, TX, TY + 1, TX - 6, TY - 4, TX - 14, TY - 2, 3.6, LEAF, { wfn = function(t) if t > 0.97 then return -1 end return max(0.4, 3.6 * sin(pi * min(1, t ^ 1.4 * 0.95 + 0.04)) ^ 0.7) end, vs = 2.8 })
-- drip tip on the big leaf
c:put(floor(TX + 18), floor(TY - 9), YOUNG[3], rtok)
c:put(floor(TX), floor(TY), STEM[2], rtok) c:put(floor(TX), floor(TY + 1), STEM[1], rtok)

-- seeds
for i, s in ipairs(seeds) do
  local tok = { r = { name = "seed" .. i } }
  local idx = A.shade(c, s.m, s.n, SEED, { amb = 0.08, wrap = 0.2, tok = tok })
  -- fibrous coat: pale strands along the long axis
  local ca, sa = cos(s[5]), sin(s[5])
  s.m:each(function(x, y) local k = K(x, y)
    local v = (-(x - s[1]) * sa + (y - s[2]) * ca)
    if (floor(v + 10) % 2 == 0) and X.hash(x, y, i) > 0.55 then A.step(c, idx, SEED, x, y, 1, tok) end
  end)
  -- hair tufts beyond the edge (lower-right side darker)
  for j = 0, 3 do
    local a = s[5] + j * pi / 2 + 0.6
    local hx, hy = floor(s[1] + cos(a) * (s[3] + 1.2) + .5), floor(s[2] + sin(a) * (s[4] + 1.0) + .5)
    if not s.m:has(hx, hy) and not lm:has(hx, hy) or true then c:put(hx, hy, (cos(a) + sin(a) > 0) and SEED[3] or SEED[5], tok) end
  end
  -- hilum notch at the right end
  local hx, hy = floor(s[1] + ca * (s[3] - 0.6) + .5), floor(s[2] + sa * (s[3] - 0.6) + .5)
  c:put(hx, hy, SEED[1], tok)
  local bx, by = A.specAt(s.m, s.n, 50)
  c:put(bx, by, SPEC, tok) if s.m:has(bx + 1, by) then c:put(bx + 1, by, SEED[6], tok) end
end
-- re-draw the sprout base over the middle seed
c:put(sx, sy - 1, STEM[2], rtok) c:put(sx + 1, sy - 1, STEM[1], rtok) c:put(sx, sy, SEED[1], rtok) c:put(sx + 1, sy, SEED[2], rtok)

-- quirk: blue-green pulp smear on the left seed
A.map(c, { ".ab", "abc", ".c." }, 15, 42, { a = PULP[3], b = PULP[2], c = PULP[1] })

A.save(c, NAME)
