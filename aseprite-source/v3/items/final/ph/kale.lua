-- kale (final pass, Opus single pass). One tall curly-kale leaf: slim pale petiole running up as a thick midrib,
-- an oblong blade lobed near the base and frilled all along the margin (ruffled rolls lit/shaded in turn), angled
-- pale side veins, blue-green ramp with a waxy blue-grey bloom on the lit facets, cool reflected rim on the shade
-- side, AO along the midrib. quirk: a single dew bead sits on the waxy blade, refusing to soak in.
local NAME = "kale"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC13_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, pi, max, min = math.floor, math.abs, math.sin, math.pi, math.max, math.min
local c = A.new(NAME)
local LEAF = { "#122a36", "#1b4244", "#275d4e", "#367a58", "#529866", "#86b88a" }
local BLOOM, COOL, VEIN = "#a9cbbf", "#3d6f80", "#c6e2a6"
local STEM = { "#3f6b4a", "#6f9d6a", "#a3c890", "#d4ebbc", "#eef7d6" }
local DEW = { "#3a86b0", "#7cc6d6", "#c4f0ec", "#fff4d6" }

-- blade
local lm, ln, LT, LS, len = A.blade(31, 45, 25, 26, 35, 10, function(t)
  if t > 0.99 then return -1 end
  local u = min(1, t * 0.94 + 0.04)
  return max(0.8, 14.2 * sin(pi * u ^ 0.85) ^ 0.62)
end, { fold = 0.42 })
-- deep lobes near the base, fine frill everywhere
local lob = {}
lm:each(function(x, y) local k = K(x, y) local t, s = LT[k], LS[k]
  local ph = t * len / 8.5 + (s > 0 and 0.5 or 0)
  local f = abs((ph - floor(ph)) - 0.5) * 2
  if t < 0.42 and abs(s) > 0.98 - (1 - f) ^ 2 * (0.75 - t) then lob[#lob + 1] = k end
end)
for _, k in ipairs(lob) do lm.s[k] = nil end
local F = A.frill(lm, LT, LS, len, 4.3, function(t) return 0.3 + 0.08 * t end, 0.04, 0.985)
A.ruffle(ln, LT, LS, len, 4.3, 0.7, 0.68, 0.15, -1)

-- petiole / midrib tube (painted after the blade; AO on the blade beside it)
local pp = { { 32, 57 }, { 31, 50 }, { 29, 40 }, { 28, 31 } }
local pm, pn, PT, PS = A.tube(pp, function(t) return 1.9 - t * 0.9 end)
local bias = {}
X.ao(bias, lm, pm, 1, -1)
local ltok = { r = { name = "leaf" } }
local idx = A.shade(c, lm, ln, LEAF, { bias = bias, tok = ltok, amb = 0.12, wrap = 0.3, cuts = { 0.14, 0.3, 0.46, 0.62, 0.8 } })
-- veins: angled, pale on the lit half, dark grooves on the shade half; midrib continues thin to the tip
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.1 and t > 0.55 and t < 0.94 then c:put(x, y, s <= 0 and VEIN or LEAF[3], ltok) return end
  local ph = (t * len - abs(s) * 6) / 5.2 + (s > 0 and 0.5 or 0)
  local f = abs((ph - floor(ph)) - 0.5) * 2
  if f > 0.86 and abs(s) > 0.14 and abs(s) < 0.72 and t > 0.08 and t < 0.9 then
    c:put(x, y, s < 0 and LEAF[min(6, idx[k] + 2)] or LEAF[max(1, idx[k] - 1)], ltok) end
end)
-- waxy bloom on the brightest ruffles; cool rim on the shade side
lm:each(function(x, y) local k = K(x, y)
  if idx[k] == 6 and not bias[k] and abs(LS[k]) > 0.6 and (F[k] or 0) > 0.55 then c:put(x, y, BLOOM, ltok) end end)
lm:edge():each(function(x, y) local k = K(x, y)
  if LS[k] > 0.62 and LT[k] > 0.15 and LT[k] < 0.9 and (idx[k] or 3) <= 3 then c:put(x, y, COOL, ltok) end end)

local stok = { r = { name = "stem" } }
local sidx = A.shade(c, pm, pn, STEM, { tok = stok, amb = 0.15, wrap = 0.35, cuts = { 0.25, 0.45, 0.65, 0.85 } })
-- fine ribs down the petiole
pm:each(function(x, y) local k = K(x, y) if abs(PS[k] - 0.35) < 0.12 and PT[k] < 0.75 then c:put(x, y, STEM[max(1, sidx[k] - 1)], stok) end end)
-- cut stem foot: pale end
c:put(31, 57, STEM[4], stok) c:put(32, 57, STEM[3], stok) c:put(33, 57, STEM[2], stok)

-- quirk: dew bead on the lit half of the blade
local bx, by = 22, 25
local dm = HP.mask()
for _, q in ipairs{ {0,-1},{1,-1},{-1,0},{0,0},{1,0},{2,0},{-1,1},{0,1},{1,1},{2,1},{0,2},{1,2} } do dm:set(bx + q[1], by + q[2]) end
local dtok = { r = { name = "dew" } }
dm:each(function(x, y) c:put(x, y, DEW[2], dtok) end)
c:put(bx + 1, by + 2, DEW[1], dtok) c:put(bx + 2, by + 1, DEW[1], dtok)
c:put(bx, by + 1, DEW[3], dtok) c:put(bx + 1, by + 1, DEW[3], dtok)
c:put(bx, by - 1, DEW[4], dtok) c:put(bx - 1, by, DEW[3], dtok)
-- shadow cast by the bead
for _, q in ipairs{ {1,3},{2,3},{3,2},{3,1} } do if lm:has(bx + q[1], by + q[2]) then c:put(bx + q[1], by + q[2], LEAF[2], ltok) end end

A.save(c, NAME)
