-- miss-joaquim-seed (final, Opus single pass): a torn leaf scrap lying on the diagonal (ragged torn end, midrib +
-- swept veins, V-fold light, cool reflected rim). On it a slender ripe orchid capsule, ribbed, split along its shaded
-- side and spilling dust-fine orchid seeds onto the leaf (AO + contact shadow under the pod). From a little green
-- protocorm rise the Vanda's pencil-round (terete) leaves, with a silvery aerial root reaching over the leaf edge.
-- quirk: the seedling has already put out one tiny Miss Joaquim bloom (rose sepals, big magenta lip, orange eye).
local NAME = "miss-joaquim-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC2r0_0.lua")
local HP, X, K, G = A.HP, A.X, A.K, A
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local LEAF = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local TER  = { "#1c4a3a", "#2a6a44", "#3f8a4c", "#5ea856", "#8cc866", "#c2e48c" }
local COOL = "#3a6c72"
local POD  = { "#3e2a1c", "#664622", "#90692c", "#b8923a", "#d8ba5c", "#f2de96" }
local SEED = { "#8a6a3c", "#c8a466", "#ecd49a" }
local ROOT = { "#5c6a62", "#8c9a90", "#c0ccc0", "#e6efe2" }
local PET  = { "#5a1c4c", "#8c2c70", "#ba4a94", "#da78b2", "#f2acd2", "#ffdcec" }
local CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }

-- ---- leaf scrap with a torn base end ----
local la, lc_, lb = { 7, 53 }, { 30, 52 }, { 57, 42 }
local lwfn = function(t) if t > 0.985 then return -1 end return max(0.5, 6.4 * sin(pi * min(1, 0.36 + t * 0.64)) ^ 0.6) end
local _, _, T0, S0, len = G.blade(la[1], la[2], lc_[1], lc_[2], lb[1], lb[2], lwfn, { fold = 0.4 })
local torn = HP.mask()
for k, t in pairs(T0) do
  local x, y = k % 1024 - 256, k // 1024 - 256
  local jag = 1.5 + 3.2 * X.hash(floor((S0[k] + 1) * 3.2), 7)
  if t * len < jag then torn:set(x, y) end
end
-- pod mask first (AO on the leaf)
local podP = { { 13, 48 }, { 19, 45 }, { 27, 43 }, { 34, 40 } }
local pm, pn, PT, PS = G.tube(podP, function(t) return 2.5 * sin(pi * min(1, t * 0.94 + 0.04)) ^ 0.55 + 0.2 end)
local seeds = { { 36, 43 }, { 38, 45 }, { 35, 46 }, { 40, 43 }, { 41, 47 }, { 38, 48 }, { 44, 45 }, { 33, 48 }, { 43, 49 }, { 46, 47 } }
local smask = HP.mask()
for _, s in ipairs(seeds) do smask:set(s[1], s[2]) smask:set(s[1] + 1, s[2]) end
local lbias = {}
X.ao(lbias, HP.mask(), pm, 1, -1)
local lfull = G.blade(la[1], la[2], lc_[1], lc_[2], lb[1], lb[2], lwfn, { fold = 0.4 })
lfull:cut(torn)
X.ao(lbias, lfull, pm, 1, -1)
G.cast(lbias, lfull, pm, 1, 2, -1)
G.cast(lbias, lfull, smask, 1, 1, -1)
local ltok = { r = { name = "leaf" } }
local lm, LT, LS, lidx = A.leaf(c, la[1], la[2], lc_[1], lc_[2], lb[1], lb[2], 6.4, LEAF, { wfn = lwfn, fold = 0.4, cut = torn, bias = lbias, tok = ltok, vs = 3.6 })
lm:edge():each(function(x, y) local k = K(x, y) if not lbias[k] and LS[k] and LS[k] > 0.7 and LT[k] > 0.15 and LT[k] < 0.9 then c:put(x, y, COOL, ltok) end end)
-- torn edge: pale fibrous rim
torn:grow(1):clip(lm):cut(torn):each(function(x, y) if (x + y) % 2 == 0 then c:put(x, y, LEAF[6], ltok) end end)

-- ---- sprout: protocorm, terete leaves, aerial root, flower spike ----
local ttok = { r = { name = "terete" } }
local proto = G.oval(44, 41, 2.6, 2, -0.2, 1)
-- aerial root first (behind the protocorm), curling over the leaf's far edge
local rm = A.stem(c, { { 45, 42 }, { 49, 42 }, { 53, 44 }, { 55, 48 } }, function(t) return 0.95 - t * 0.2 end, ROOT, { tok = { r = { name = "root" } }, cuts = { 0.3, 0.55, 0.8 } })
c:put(55, 48, TER[5], ttok) c:put(55, 47, TER[4], ttok)
-- flower spike (thin), then the two terete leaves over it
local spike = { { 45, 38 }, { 46, 30 }, { 48, 23 }, { 47, 17 } }
for i = 0, 30 do local x, y = G.bez(spike, i / 30) c:put(floor(x + .5), floor(y + .5), i < 15 and TER[3] or TER[4], ttok) end
local tl = A.stem(c, { { 43, 39 }, { 41, 30 }, { 35, 22 }, { 33, 11 } }, function(t) return 1.45 - t * 0.55 end, TER, { tok = ttok, cut = proto })
local tr = A.stem(c, { { 45, 39 }, { 49, 35 }, { 54, 33 }, { 56, 26 } }, function(t) return 1.3 - t * 0.5 end, TER, { tok = ttok, cut = proto })
-- terete leaf tips: rounded pale caps
c:put(33, 11, TER[6], ttok) c:put(56, 26, TER[6], ttok)
-- protocorm over the leaf bases
local pidx = A.shade(c, proto, X.sphere(43.5, 40.5, 2.6, proto), TER, { tok = ttok })
c:put(43, 40, TER[6], ttok)

-- ---- capsule ----
local ptok = { r = { name = "pod" } }
local pb = {}
local pidx2 = A.shade(c, pm, pn, POD, { tok = ptok, amb = 0.1, wrap = 0.3 })
pm:each(function(x, y) local k = K(x, y)
  local i = pidx2[k]
  local s, t = PS[k], PT[k]
  -- six ribs: darker grooves at fixed offsets across
  if abs(s + 0.45) < 0.12 or abs(s - 0.1) < 0.12 then i = i - 1 end
  -- the split along the shade side, gaping toward the right end
  if t > 0.42 and t < 0.96 and s > 0.35 and s < 0.35 + 0.5 * (t - 0.42) then i = 1 end
  if t < 0.05 or t > 0.96 then i = max(1, i - 1) end
  c:put(x, y, POD[max(1, min(6, i))], ptok)
end)
-- dried flower remnant at the pod's tip, pedicel stub at the base
c:put(35, 39, POD[2], ptok) c:put(36, 38, POD[3], ptok) c:put(12, 49, POD[3], ptok) c:put(11, 49, POD[2], ptok)
c:put(17, 45, POD[6], ptok) c:put(18, 45, POD[6], ptok)   -- the pod's single specular
-- dust seeds spilling out of the split
local stok = { r = { name = "seeds" } }
for i, s in ipairs(seeds) do
  c:put(s[1], s[2], SEED[2], stok)
  c:put(s[1] + 1, s[2], (i % 3 == 0) and SEED[3] or SEED[1], stok)
end
for _, p in ipairs{ { 33, 44 }, { 34, 45 } } do c:put(p[1], p[2], SEED[3], stok) end

-- ---- quirk: tiny Miss Joaquim bloom on the spike ----
local ftok = { r = { name = "flower" } }
local fx, fy = 47, 13
local dors = G.oval(fx, fy - 3, 1.3, 2.1, 0, 1)
local sl = G.oval(fx - 3.5, fy - 0.5, 2.2, 1.3, -0.35, 1)
local sr = G.oval(fx + 3.5, fy - 0.5, 2.2, 1.3, 0.35, 1)
local pets = dors:copy():add(sl):add(sr)
A.shade(c, pets, X.pillow(pets, 1.4), PET, { tok = ftok, amb = 0.35, wrap = 0.4, cuts = { 0.15, 0.3, 0.45, 0.62, 0.8 } })
local lip = G.oval(fx, fy + 2.5, 2.6, 2.2, 0, 1)
local lb2 = {}
X.ao(lb2, lip, pets, 1, -1)
A.shade(c, lip, X.sphere(fx - 0.6, fy + 2, 2.8, lip), PET, { tok = ftok, bias = lb2, cuts = { 0.25, 0.45, 0.6, 0.78, 0.92 } })
-- lip markings: dark speckles fanning from an orange eye, cream column above
for _, p in ipairs{ { fx - 1, fy + 3 }, { fx + 1, fy + 3 }, { fx, fy + 4 } } do c:put(p[1], p[2], PET[1], ftok) end
c:put(fx, fy + 1, "#f59a2e", ftok) c:put(fx, fy + 2, "#d86a22", ftok)
c:put(fx, fy, "#fff4d6", ftok)

A.save(c, NAME)
