-- broken-fine-secateurs (aB11_2, Opus single pass). Bypass pruning shears standing open: a curved hook (anvil) blade and a
-- slim bevelled cutting blade meet at a brass pivot bolt; two slim steel necks splay down into red-lacquered grips, a
-- twisted steel spring between them. Material: per-pixel tube light on steel (6 tones, bevel + specular), lacquer gloss on
-- the grips, brass bolt with slot, AO where blades meet the bolt and grips meet the necks.
-- broken: the cutting blade has snapped two-thirds along; the tip spins away with a tiny shard.
-- quirk: a red rosehip is still caught in the open jaws.
local H = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB11_2.lua")
local HP, X, K = H.HP, H.X, H.K
local S, R, B = H.STEEL, H.RED, H.BRASS
local max, min, floor = math.max, math.min, math.floor
local c = H.new("broken-fine-secateurs")
local stok = { r = { name = "steel" } }

-- handles: steel neck then lacquered grip
local function handle(p)
  local nm, nn, nT = H.tube(p, function(t) return t < 0.3 and 1.5 or 2.3 - 0.3 * (t - 0.3) end)
  local neck, grip = HP.mask(), HP.mask()
  local gn = {}
  nm:each(function(x, y) local k = K(x, y) if nT[k] < 0.3 then neck:set(x, y) else grip:set(x, y) gn[k] = nn[k] end end)
  local nb = {}
  neck:each(function(x, y) nb[K(x, y)] = 0 end)
  H.shade(c, neck, nn, S, { spec = 20, specThr = 0.9, tok = stok })
  local gb = X.ao({}, grip, neck, 1, -2)
  H.shade(c, grip, gn, R, { bias = gb, spec = 30, specThr = 0.86, specCol = R[6], bounce = "#7a4a8a" })
  -- brass ferrule ring where grip starts
  grip:each(function(x, y) local k = K(x, y) if nT[k] < 0.36 then c:put(x, y, (nn[k][1] + nn[k][2] < 0) and B[5] or B[3]) end end)
  return nm
end
handle({ { 30, 32 }, { 25, 38 }, { 18, 44 }, { 12, 50 } })
handle({ { 32, 33 }, { 32, 41 }, { 30, 49 }, { 27, 57 } })

-- spring: twisted coil between the necks
for i = 0, 6 do
  local x, y = 23 + i, 39 + floor(i * 0.5 + 0.5)
  c:put(x, y - 1, (i % 2 == 0) and S[6] or S[4], stok)
  c:put(x, y, (i % 2 == 0) and S[4] or S[2], stok)
end

-- hook (anvil) blade
local am, an, aT, aS = H.tube({ { 31, 31 }, { 33, 22 }, { 38, 14 }, { 46, 10 } }, function(t) return 3.0 - 1.9 * t end)
local ab = X.ao({}, am, HP.mask():set(31, 31):grow(2), 2, -1)
H.shade(c, am, an, S, { bias = ab, spec = 18, specThr = 0.88, specCol = H.SPEC, bounce = "#6a78b0", tok = stok })
-- groove along the hook (sap channel)
am:each(function(x, y) local k = K(x, y) if aT[k] > 0.25 and aT[k] < 0.8 and aS[k] > 0.15 and aS[k] < 0.42 then c:put(x, y, S[2], stok) end end)

-- cutting blade, snapped at t ~ 0.66: drawn to 0.62 then a jagged end
local cp = { { 32, 32 }, { 39, 27 }, { 45, 21 }, { 52, 18 } }
local cw = function(t) return 2.4 * (1 - t) + 0.5 end
local cm, cn, cT, cS = H.tube(cp, cw, 0, 0.64)
H.shade(c, cm, cn, S, { spec = 16, specThr = 0.9, tok = stok })
-- bright honed bevel along the upper (cutting) edge
cm:edge():each(function(x, y) local k = K(x, y) if cS[k] < -0.4 and cT[k] > 0.12 then c:put(x, y, S[6], stok) end end)
-- jagged break: notch out pixels at the end
do local ex, ey = H.bez(cp, 0.64)
  local notch = HP.mask():set(floor(ex + 0.5), floor(ey + 0.5)):set(floor(ex + 0.5) - 1, floor(ey + 0.5) - 1)
  H.erase(c, notch)
  c:put(floor(ex + 0.5) - 1, floor(ey + 0.5), S[1], stok) end
-- flying tip, rotated a little and shifted away
local tip = { { 50, 25 }, { 52, 23 }, { 55, 22 }, { 58, 22 } }
local tm, tn, tT, tS = H.tube(tip, function(t) return 1.3 * (1 - t) + 0.45 end)
H.shade(c, tm, tn, S, { spec = 16, specThr = 0.88, tok = stok })
c:put(50, 25, S[1], stok) c:put(50, 24, S[2], stok)
-- tiny shard
c:put(55, 28, S[5], stok) c:put(56, 28, S[3], stok)

-- pivot bolt
local bm = c:ellipse(31, 31, 2.5, 2.5)
local bn = X.sphere(31, 31, 2.5, bm)
H.shade(c, bm, bn, B, { spec = 30, specThr = 0.8 })
c:put(30, 32, B[1]) c:put(31, 31, B[1]) c:put(32, 30, B[2])
c:put(30, 30, B[6])

-- quirk: rosehip caught in the jaws
local hm = c:ellipse(43, 17, 1.5, 2)
local hn = X.sphere(43, 17, 2, hm)
H.shade(c, hm, hn, { "#6e2038", "#a3263a", "#d83c33", "#f2683a", "#ffa070" }, { cuts = { 0.15, 0.35, 0.55, 0.78 }, spec = 30, specThr = 0.85, specCol = H.SPEC })
c:put(44, 15, "#2e6a44") c:put(45, 14, "#5b9a52")

H.fin(c, debug.getinfo(1, "S").source)
