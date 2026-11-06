-- cantuta-seed (Opus single pass). Three papery winged cantuta seeds (oblong ribbed brown body inside a pale tan wing
-- with radial wing veins) on a torn, leathery cantua leaf scrap (diagonal, pointed tip, midrib + swept veins, pale
-- torn fibre edge at the base, cool reflected rim, AO + contact shadow under each seed). The right seed has sprouted:
-- slim green stem, two oval cotyledons and two small obovate box-like true leaves (the cantua leaf shape).
-- quirk: a tiny crimson cantuta trumpet already hangs from the seedling's tip, flared mouth and a gold stamen.
local NAME = "cantuta-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB1r0_2.lua")
local G, HP, X, K = A.G, A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local c = G.new2(NAME)
local LEAF = { "#14352f", "#1d4f3b", "#2a6a42", "#3f874a", "#62a552", "#94c66a" }
local SLEAF = { "#1a4234", "#25603f", "#357d46", "#4f9a4e", "#76b85c", "#a8d679" }
local WING = { "#6a4a3c", "#96704f", "#bc966a", "#d8b98a", "#ecd6a8", "#f8eccb" }
local BODY = { "#2e1a1e", "#4c2a24", "#6e3e2a", "#925834", "#b67a46", "#d8a466" }
local STEM = { "#3e7048", "#5f9a58", "#8fc072", "#c4e29a" }
local CR = { "#4a1030", "#7c1838", "#b0263e", "#d83a44", "#f2665a", "#ffa088" }

-- seeds: cx, cy, angle (wing rx/ry fixed)
local seeds = { { 18, 51.5, -0.25 }, { 28.5, 50.5, 0.35 }, { 39.5, 46, -0.55 } }
for _, s in ipairs(seeds) do
  s.wm, s.wn = G.oval(s[1], s[2], 4.5, 2.9, s[3], 0.35)
  s.bm, s.bn = G.oval(s[1] - 0.3, s[2] - 0.2, 2.3, 1.3, s[3], 0.9)
end
local allSeed = HP.mask() for _, s in ipairs(seeds) do allSeed:add(s.wm) end

-- leaf scrap
local lm, LT, LS, ltok = A.scrap(c, {
  a = { 7, 54 }, c = { 28, 56 }, b = { 57, 37 }, W = 7.2, fold = 0.42,
  prof = function(t) return sin(pi * (0.3 + 0.7 * t)) ^ 0.75 end,
  ramp = LEAF, vein = "#b9e08a", cool = "#356a70", torn = "#cfe3a0", per = 6.2,
  tear = { t0 = 0.03, amp = 0.07, seed = 11 }, casters = { allSeed }, name = "leaf" })

-- sprout (before the seeds, so the sprouting seed's coat overlaps the stem foot)
local stok = { r = { name = "stem" } }
local sm = A.stem(c, { { 39, 46 }, { 37, 37 }, { 40, 28 }, { 38, 20 } }, function(t) return 1.05 - 0.2 * t end, STEM, stok)
local lt = { r = { name = "sleaf" } }
local oval = function(t) return sin(pi * min(1, t * 0.92 + 0.08)) ^ 0.55 end
local obov = function(t) return sin(pi * min(1, 0.12 + t * 0.8)) ^ 0.5 * (0.55 + 0.45 * t) end
local cl = A.leaflet(c, 38, 32, 33, 29, 28, 30, 2.1, oval, SLEAF, lt, { cutBy = { sm } })
local cr = A.leaflet(c, 40, 32, 45, 29, 50, 29, 2.1, oval, SLEAF, lt, { cutBy = { sm } })
local tl1 = A.leaflet(c, 38, 23, 35, 19, 31, 18, 2.2, obov, SLEAF, lt, { cutBy = { sm } })
local tl2 = A.leaflet(c, 40, 26, 43, 23, 46, 23, 1.9, obov, SLEAF, lt, { cutBy = { sm } })

-- quirk: hanging crimson trumpet. green pedicel arcing over, then the tube flaring downward
local ped = A.stem(c, { { 38, 21 }, { 38, 16 }, { 40, 13 }, { 43, 13 } }, function() return 0.75 end, STEM, stok)
local trp = { { 43, 13 }, { 46, 13 }, { 48, 15 }, { 48.5, 21 } }
local tm, tn, TT, TS = G.tube(trp, function(t) return 0.8 + 1.7 * t ^ 1.6 end)
tm:cut(ped)
local ttok = { r = { name = "trumpet" } }
local tidx = X.tone(c, tm, X.light(tn, { amb = 0.1, wrap = 0.3 }), CR, { cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, tok = ttok })
tm:each(function(x, y) local k = K(x, y) local t, s = TT[k], TS[k]
  if t < 0.14 then c:put(x, y, s < 0 and STEM[3] or STEM[1], ttok)                    -- green calyx
  elseif t > 0.25 and t < 0.85 and abs(s - 0.25) < 0.12 then c:put(x, y, CR[max(1, (tidx[k] or 3) - 1)], ttok) end  -- petal crease
end)
-- flared mouth: dark throat + pink lip, then a gold stamen poking below
local mx, my = G.bez(trp, 1)
mx, my = floor(mx + 0.5), floor(my + 0.5)
c:put(mx - 2, my + 1, CR[5]) c:put(mx - 1, my + 1, CR[1]) c:put(mx, my + 1, CR[1]) c:put(mx + 1, my + 1, CR[2]) c:put(mx + 2, my + 1, CR[3])
c:put(mx, my + 2, "#e8c040") c:put(mx, my + 3, "#ffe27a")
do local sx, sy = G.bez(trp, 0.45) c:put(floor(sx), floor(sy + 0.5) - 1, CR[6]) end      -- glint on the tube

-- seeds last: wing then body
for i, s in ipairs(seeds) do
  local vis = s.wm:copy()
  local wb = {}
  X.ao(wb, s.wm, s.bm, 1, -1)
  for j = i + 1, #seeds do vis:cut(seeds[j].wm) X.ao(wb, s.wm, seeds[j].wm, 1, -1) end
  local tok = { r = { name = "wing" .. i } }
  local ca, sa = cos(s[3]), sin(s[3])
  local idx = G.toneN(c, vis, s.wn, WING, { bias = wb, tok = tok, cuts = { 0.15, 0.3, 0.48, 0.66, 0.82 }, amb = 0.25, wrap = 0.4 })
  vis:each(function(x, y) local k = K(x, y)
    local dx, dy = x - s[1], y - s[2]
    local u, v = (dx * ca + dy * sa) / 4.9, (-dx * sa + dy * ca) / 3.3
    local r = sqrt(u * u + v * v)
    local th = atan(v, u)
    if r > 0.62 and r < 0.92 and abs(((th / (pi / 4)) % 1) - 0.5) < 0.1 then c:put(x, y, WING[max(1, (idx[k] or 3) - 1)], tok) end
    if r > 0.9 and X.hash(x, y, 4) > 0.8 then c:put(x, y, WING[max(1, (idx[k] or 3) - 1)], tok) end   -- ragged papery rim
  end)
  -- body
  local bvis = s.bm:copy()
  for j = i + 1, #seeds do bvis:cut(seeds[j].wm) end
  local btok = { r = { name = "body" .. i } }
  local bidx = G.toneN(c, bvis, s.bn, BODY, { tok = btok, cuts = { 0.2, 0.38, 0.55, 0.72, 0.86 }, amb = 0.1 })
  bvis:each(function(x, y) local k = K(x, y)
    local dx, dy = x - s[1] + 0.3, y - s[2] + 0.2
    local v = (-dx * sa + dy * ca) / 1.75
    if abs(v) < 0.3 and abs((dx * ca + dy * sa) / 2.7) < 0.75 then c:put(x, y, BODY[max(1, (bidx[k] or 3) - 2)], btok) end  -- rib groove
  end)
  local gx, gy = G.specAt(bvis, s.bn, 30)
  if gx then c:put(gx, gy, "#f2cf92", btok) end
end

G.save2(c, NAME)
