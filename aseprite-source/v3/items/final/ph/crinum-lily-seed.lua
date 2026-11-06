-- crinum-lily-seed (final pass, Opus). One big fleshy crinum seed (lumpy, pale jade-grey with corky cream
-- patches) and a smaller one, lying on a torn strip of strap-shaped crinum leaf (long, narrow, parallel veins,
-- torn at both ends). The big seed has germinated: a thick pale root and one long arching strap leaf.
-- quirk: a bead of water sits on the big seed (crinum seeds are made to float).
local NAME = "crinum-lily-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB22_4.lua")
local G, HP, X, K = A, A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min
local c = A.new(NAME)
local LEAF = { "#183e3c", "#22574a", "#30744f", "#4a9258", "#78b468", "#acd486" }
local SEED = { "#2c4040", "#46625a", "#6a8a72", "#94b08c", "#c0d4a8", "#e6efc8" }
local CORK = { "#7a6448", "#a88e66", "#d2bc8e" }
local ROOT = { "#7a6450", "#b49a7c", "#dccbaa", "#f6ecd0" }
local WATER = { "#3a86b0", "#8fd6e0", "#e4f6ff" }

-- big lumpy seed: union of three blobs, plus a small seed
local big = HP.mask():add(G.rell(25, 43, 1, 0.15, 8.2, 6.6)):add(G.rell(30, 39, 1, -0.3, 4.6, 3.6)):add(G.rell(20, 47, 1, 0.3, 4.5, 3.4))
local small = (G.oval(41, 47, 4.2, 3.4, 0.4, 0.8))

-- scrap: long narrow strap, torn both ends, parallel veins
A.scrap(c, LEAF, 6, 55, 28, 47, 54, 50, 4.4, { casters = { big, small }, tear0 = 0.08, tear1 = 0.07, seed = 7,
  veins = "par", nvein = 3, wfn = function(t) return 4.4 end, fibre = "#c8e2a0" })

-- root: thick pale radicle down out of the big seed's lower left, curling over the strap edge
local rp = { { 18, 48 }, { 14, 52 }, { 11, 55 }, { 13, 59 } }
local rm, _, RT = A.stem(c, rp, function(t) return 1.7 * (1 - t) ^ 0.7 + 0.4 end, { ROOT[1], ROOT[1], ROOT[2], ROOT[3], ROOT[3], ROOT[4] }, { cut = big })
rm:each(function(x, y) if RT[K(x, y)] > 0.8 then c:put(x, y, ROOT[2], { r = { name = "root" } }) end end)

-- sprout: one long strap leaf rising from the top of the big seed and arching over to the right
local lm, LT, LS = A.leaf(c, 30, 37, 28, 4, 51, 22, 2.2, LEAF, { cut = big,
  wfn = function(t) if t > 0.985 then return -1 end return max(0.5, 2.3 * min(1, (1 - t) * 2.2) ^ 0.6) end, vs = 99 })
-- parallel vein line along the strap (monocot)
lm:each(function(x, y) local k = K(x, y) if abs(LS[k] + 0.55) < 0.14 and LT[k] < 0.85 then c:put(x, y, LEAF[6], { r = { name = "leaf" } }) end end)
-- white sheath where the leaf leaves the seed
for _, q in ipairs{ { 29, 36, 4 }, { 30, 36, 3 }, { 29, 35, 3 } } do c:put(q[1], q[2], ROOT[q[3]], { r = { name = "root" } }) end

-- seeds: small first, big over it with AO
local sb = {} X.ao(sb, small, big, 1, -1)
A.seed(c, { 41, 47, 4.2, 3.4, 0.4 }, SEED, { bias = sb, over = { big }, name = "seed2", glint = SEED[6] })
local nb = A.body(big, 25, 42, 9, 4, 0.55)
local bidx = A.shade(c, big, nb, SEED, { tok = { r = { name = "seed1" } }, amb = 0.08, wrap = 0.25 })
local stok = { r = { name = "seed1" } }
-- corky cream patches (hash clusters) on the lit half, darker pits on the shade half
big:each(function(x, y) local k = K(x, y) local h = X.hash(floor(x / 2), floor(y / 2), 5)
  if h > 0.78 and bidx[k] >= 3 and not big:edge():has(x, y) then c:put(x, y, CORK[(bidx[k] >= 5) and 3 or 2], stok)
  elseif h < 0.08 and bidx[k] <= 3 then c:put(x, y, SEED[max(1, bidx[k] - 1)], stok) end end)
-- lobe creases between blobs
for _, q in ipairs{ { 27, 39 }, { 26, 40 }, { 22, 45 }, { 23, 46 } } do c:put(q[1], q[2], SEED[2], stok) end
-- cool bounce on the lower right rim
local rim = X.rim(nb)
big:edge():each(function(x, y) local k = K(x, y) if (rim[k] or 0) > 0.6 and bidx[k] <= 2 then c:put(x, y, "#5a8a96", stok) end end)

-- quirk: water bead on the big seed
local wtok = { r = { name = "water" } }
for _, q in ipairs{ { 21, 41, 2 }, { 22, 41, 2 }, { 20, 42, 2 }, { 21, 42, 2 }, { 22, 42, 1 }, { 21, 43, 1 }, { 20, 41, 3 }, { 23, 42, 1 } } do
  c:put(q[1], q[2], WATER[q[3]], wtok) end
c:put(20, 40, WATER[3], wtok)
A.save(c, NAME)
