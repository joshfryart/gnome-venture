-- croton-seed (final pass, Opus). Two round-oval croton seeds (dove-grey with dark tiger mottling and a pale
-- cream caruncle cap) on a torn piece of glossy croton leaf: deep green with bold yellow midrib and veins and a
-- red-orange flush. The sprout has a pair of opposite oval leaves, one already variegated with gold veins.
-- quirk: an empty split capsule third (the seed's old cradle) lies tipped on its back like a little boat.
local NAME = "croton-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB22_4.lua")
local G, HP, X, K = A, A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min
local c = A.new(NAME)
local LEAF = { "#123a36", "#1b5442", "#287048", "#3e8e4c", "#62ac58", "#94cc70" }
local GOLD = { "#8f4a1f", "#d98322", "#f5b82e", "#ffe38a" }
local FLUSH = { "#7a1e2e", "#b8322e", "#e05a30", "#f88a44" }
local SEED = { "#2e2834", "#4c4654", "#6e6a78", "#9a96a2", "#c4c0c6", "#e8e4e2" }
local CAP = { "#c49a5a", "#ecd49a", "#fff4d6" }
local CAPS = { "#4a2a20", "#6e4228", "#966038", "#bc8650", "#dcae74", "#f2d49c" }

local s1, s2 = { 23, 47, 3.8, 3.0, -0.3 }, { 33, 50, 3.6, 2.9, 0.35 }
local m1 = (G.oval(s1[1], s1[2], s1[3], s1[4], s1[5], 0.8))
local m2 = (G.oval(s2[1], s2[2], s2[3], s2[4], s2[5], 0.8))
-- capsule third: a boat-shaped hull (half ellipse, open side up)
local hull = HP.mask()
for y = 46, 52 do for x = 39, 52 do local dx, dy = (x - 45.5) / 6.6, (y - 46) / 5.2
  if dy >= 0 and dx * dx + dy * dy <= 1 then hull:set(x, y) end end end

-- scrap: broad elliptic leaf piece, tip toward the upper right, torn at the base
local tok = { r = { name = "scrap" } }
local lm, LT, LS, lidx, len = A.scrap(c, LEAF, 7, 56, 24, 46, 56, 44, 8.6, { casters = { m1, m2, hull }, tear0 = 0.13, seed = 9,
  veins = "net", vs = 5.5, sweep = 1.3, vein = GOLD[3], fibre = "#c4e08a",
  wfn = function(t) if t > 0.985 then return -1 end return max(0.5, 8.6 * sin(pi * min(1, 0.1 + t * 0.9)) ^ 0.62) end })
-- variegation: gold midrib + gold side veins, red flush blotches near the margin
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k] local i = lidx[k]
  local p = c:get(x, y)
  if p == LEAF[1] then return end
  if abs(s) < 0.13 and t < 0.94 then c:put(x, y, s <= 0 and GOLD[4] or GOLD[3], tok) return end
  local d = (t * len - abs(s) * 8.6 * 1.3) % 5.5
  if d < 0.8 and abs(s) > 0.2 and abs(s) < 0.72 and t < 0.88 then c:put(x, y, s < 0 and GOLD[3] or GOLD[2], tok) return end
  local h = X.hash(floor(x / 3), floor(y / 2), 21)
  if abs(s) > 0.55 and h > 0.62 and t > 0.25 and t < 0.85 then c:put(x, y, FLUSH[max(1, min(4, i - 2))], tok) end
end)

-- sprout from seed 2: stem + pair of opposite oval leaves
local stok = { r = { name = "stem" } }
local STEM = { "#3a6a46", "#6e9a5a", "#a8c882", "#d8ecb0" }
local stp = { { 34, 49 }, { 35, 42 }, { 33, 33 }, { 34, 26 } }
local sm = A.stem(c, stp, function(t) return 1.0 end, STEM, { cut = m2, tok = stok })
local la, laT, laS = A.leaf(c, 33, 26, 26, 19, 17, 21, 3.6, LEAF, { cut = sm, vs = 3.0, pw = 0.6 })
local lb, lbT, lbS, lbI = A.leaf(c, 35, 25, 40, 16, 49, 14, 3.8, LEAF, { cut = sm:copy():add(la), vs = 3.0, pw = 0.6 })
-- right sprout leaf already variegated: gold midrib and gold vein dashes
lb:each(function(x, y) local k = K(x, y) local s, t = lbS[k], lbT[k]
  if abs(s) < 0.16 and t < 0.88 then c:put(x, y, s <= 0 and GOLD[4] or GOLD[3], { r = { name = "leaf" } })
  elseif X.hash(x, y, 4) > 0.86 and abs(s) > 0.3 and (lbI[k] or 1) >= 3 then c:put(x, y, GOLD[3], { r = { name = "leaf" } }) end end)
-- bud between the leaves
c:put(34, 24, LEAF[5], stok) c:put(34, 23, LEAF[6], stok)

-- quirk: capsule hull, tipped like a boat; ribbed outside, pale inner rim
local hn = A.body(hull, 45.5, 44, 7, 3, 0.5)
local hidx = A.shade(c, hull, hn, CAPS, { tok = { r = { name = "capsule" } } })
for x = 40, 51 do c:put(x, 46, (x < 46) and CAPS[6] or CAPS[5], { r = { name = "capsule" } }) end
for x = 41, 50 do c:put(x, 47, CAPS[2], { r = { name = "capsule" } }) end
for _, x in ipairs{ 43, 46, 49 } do for y = 48, 50 do if hull:has(x, y) then c:put(x, y, CAPS[max(1, hidx[K(x, y)] - 1)], { r = { name = "capsule" } }) end end end

-- seeds: mottled grey with a cream caruncle
for i, s in ipairs{ s1, s2 } do
  local m, idx, st, vis = A.seed(c, s, SEED, { name = "seed" .. i, glint = "#fff4d6" })
  vis:each(function(x, y) local k = K(x, y)
    local h = X.hash(floor((x + y) / 2), floor((x - y) / 2), 7 + i)
    if h > 0.66 and idx[k] >= 2 and idx[k] <= 5 then c:put(x, y, SEED[max(1, idx[k] - 2)], st) end end)
  local ux, uy = cos(s[5]), sin(s[5])
  local cx, cy = s[1] - ux * (s[3] - 0.3), s[2] - uy * (s[3] - 0.3)
  for _, q in ipairs{ { 0, 0, 2 }, { 0, -1, 3 }, { -1, 0, 1 }, { 0, 1, 1 } } do c:put(floor(cx + 0.5) + q[1], floor(cy + 0.5) + q[2], CAP[q[3]], st) end
end
A.save(c, NAME)
