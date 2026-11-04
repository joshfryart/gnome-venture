-- ico-bird (final, Opus). A robin perched on a twig, side view facing right: slim tapered body tilted head-up,
-- round head, a long tail dropping to the lower left, folded wing with scalloped primaries, thin legs gripping.
-- Material: per-pixel lit plumage (6-tone warm brown back, 6-tone orange breast, cream belly), feather rows on
-- the wing (dark scallop + lit edge per feather), tail feathers split by shaft lines, AO under the wing and where
-- the breast meets the belly; 2-tone gold beak with a dark gape line; twig with grain, a knot and a leaf.
-- quirk: a stubborn cowlick feather curls up off the crown.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aA1_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, sqrt, abs, sin, cos = math.floor, math.max, math.min, math.sqrt, math.abs, math.sin, math.cos
local c = A.new("ico-bird")
local BR = { "#2e1d29", "#4e2f2f", "#764632", "#9c653f", "#bf8a57", "#dfb27c" }
local OR = { "#6a2236", "#a4352e", "#d4552a", "#ef7c36", "#ffa457", "#ffcf86" }
local CR = { "#6e5560", "#a68a86", "#cdb59c", "#e6d4b6", "#f6ead0", "#fff4d6" }
local WD = { "#3a2228", "#5a3530", "#82513a", "#a8704a", "#c99366", "#e8b982" }
local LF = { "#1c4a3c", "#2b6a45", "#3f9150", "#62b157", "#95cf6c" }
local GO = { "#8f4a1f", "#d98322", "#f5b82e", "#ffe38a" }
local tb, tw, tl = { r = { name = "body" } }, { r = { name = "wing" } }, { r = { name = "twig" } }

-- twig (behind feet), with a leaf on the right
local tm, tn = A.field(A.capsuleH(13, 50.5, 49, 47.5, 2.0), 4, 40, 60, 58)
local tidx = A.shade(c, tm, tn, WD, { tok = tl, amb = 0.14, wrap = 0.35 })
tm:each(function(x, y) if (x * 3 + y) % 7 == 0 then A.step(c, tidx, WD, x, y, -1, tl) end end)
-- end grain at the cut left end
c:put(11, 50, WD[6], tl) c:put(11, 51, WD[5], tl) c:put(11, 49, WD[5], tl)
-- knot
c:put(41, 49, WD[1], tl) c:put(42, 49, WD[2], tl) c:put(41, 48, WD[4], tl)
-- leaf off the right end, pointing up-right
local lm, ln, LT, LS = A.blade(48, 47, 52, 41, 55, 38, function(t) return 2.6 * sin(math.pi * max(t, 0.04) ^ 0.8) end)
local ltok = { r = { name = "leaf" } }
local lidx = X.tone(c, lm, X.light(ln, { amb = 0.08, wrap = 0.3 }), LF, { cuts = { 0.25, 0.45, 0.62, 0.8 }, tok = ltok })
lm:each(function(x, y) local k = K(x, y) if abs(LS[k]) < 0.22 and LT[k] > 0.08 and LT[k] < 0.9 then c:put(x, y, LF[2], ltok) end end)

-- tail (behind body): long, narrowing to the body, square tip, two shaft lines
local tailm, tailn, TT, TS = A.blade(25, 38, 17, 43, 10, 48, function(t) return 2.0 + 1.5 * t end, { fold = 0.25 })
local tbias = {} tailm:each(function(x, y) tbias[K(x, y)] = -1 end)
local taidx = A.shade(c, tailm, tailn, BR, { tok = tb, amb = 0.05, wrap = 0.25, bias = tbias })
tailm:each(function(x, y) local k = K(x, y)
  if abs(TS[k]) < 0.14 and TT[k] > 0.2 then A.step(c, taidx, BR, x, y, -2, tb) end
  if TS[k] > 0.55 and TS[k] < 0.75 and TT[k] > 0.45 then A.step(c, taidx, BR, x, y, -1, tb) end
end)

-- legs: 2 px, from belly to twig, toes wrapping the twig
local function leg(x0, y0, x1, y1)
  local lg = c:line({ { x0, y0 }, { x1, y1 } }, 2)
  lg:each(function(x, y) c:put(x, y, ((x - x0) - (x1 - x0) * (y - y0) / max(1, y1 - y0)) < 0.5 and "#c46a4a" or "#8a3f3c", tb) end)
  c:put(x1 + 1, y1 + 1, "#8a3f3c", tb) c:put(x1 + 2, y1 + 1, "#8a3f3c", tb) c:put(x1 - 1, y1 + 1, "#6e3036", tb)
end
leg(29, 41, 28, 45) leg(34, 41, 34, 45)

-- body + head height field (smooth union), tilted head-up
local bodyH = function(x, y)
  local ang = -0.42
  local dx, dy = x - 30.5, y - 34.5
  local u = dx * cos(ang) + dy * sin(ang)
  local v = -dx * sin(ang) + dy * cos(ang)
  -- egg: fuller in front (u>0)
  local rx = u > 0 and 12.0 or 13.0
  local q = 1 - (u / rx) ^ 2 - (v / 7.6) ^ 2
  return q > 0 and 8 * sqrt(q) or -1
end
local headH = A.sphereH(41, 23.5, 7.0)
local function hf(x, y) return A.smax(bodyH(x, y), headH(x, y), 3.0) end
local bm, bn, BH, BC = A.field(hf, 10, 10, 56, 50, 0.85)
-- zones: breast (orange) on the front lower half, belly (cream) under it, back/crown brown
local function zone(x, y)
  local dx, dy = x - 45, y - 33
  if (dx / 12.5) ^ 2 + (dy / 11.5) ^ 2 <= 1 and y >= 24 and y <= 40 then return "OR" end
  if x >= 43 and y >= 23 then return "OR" end
  if y >= 39 and x >= 24 then return "CR" end
  return "BR"
end
local zm = { BR = HP.mask(), OR = HP.mask(), CR = HP.mask() }
bm:each(function(x, y) zm[zone(x, y)]:set(x, y) end)
local ramps = { BR = BR, OR = OR, CR = CR }
local bidx = {}
for z, mm in pairs(zm) do
  local bias = {}
  mm:each(function(x, y) local k = K(x, y) if BC[k] > 0.4 then bias[k] = -1 end if z == "BR" then bias[k] = (bias[k] or 0) - 1 end end)
  local id = A.shade(c, mm, bn, ramps[z], { tok = tb, bias = bias, amb = z == "OR" and 0.14 or 0.06, wrap = 0.3, cuts = { 0.2, 0.36, 0.53, 0.7, 0.86 } })
  for k, v in pairs(id) do bidx[k] = { z, v } end
end
-- soft boundary row where breast meets belly / back (one tone deeper on the lower zone)
bm:each(function(x, y)
  local z = zone(x, y)
  local up = bm:has(x, y - 1) and zone(x, y - 1)
  if up and up ~= z and z == "CR" then local e = bidx[K(x, y)] c:put(x, y, CR[max(1, e[2] - 1)], tb) end
end)
-- breast feather flecks
for _, p in ipairs{ { 45, 30 }, { 47, 33 }, { 43, 35 }, { 48, 37 }, { 46, 39 } } do
  local e = bidx[K(p[1], p[2])]
  if e and e[1] == "OR" then c:put(p[1], p[2], OR[max(1, e[2] - 1)], tb) if bm:has(p[1] + 1, p[2] - 1) then c:put(p[1] + 1, p[2] - 1, OR[min(6, e[2] + 1)], tb) end end
end

-- wing: folded, from shoulder to tips past the rump, pillow lit, feather rows
local wing = c:poly{ { 26, 27 }, { 34, 26 }, { 38, 30 }, { 36, 35 }, { 30, 39 }, { 22, 42 }, { 16, 44 }, { 19, 38 } }
-- scalloped primaries along the lower edge
for i, p in ipairs{ { 19, 43 }, { 23, 41.5 }, { 27, 40 }, { 31, 38 } } do wing:add(A.ellM(p[1], p[2], 2.2, 1.6)) end
wing:clip(bm:copy():add(tailm):grow(1))
local wn = X.pillow(wing, 2.6)
local wb = {}
wing:each(function(x, y) wb[K(x, y)] = -1 end)
local widx = A.shade(c, wing, wn, BR, { tok = tw, bias = wb, amb = 0.1, wrap = 0.3, cuts = { 0.16, 0.32, 0.5, 0.68, 0.86 } })
-- 1 px separation where the wing edge lies on the body (darker neighbour), lit top edge kept
wing:edge():each(function(x, y)
  local below = (not wing:has(x, y + 1)) or (not wing:has(x + 1, y))
  if below and y > 28 then c:put(x, y, BR[1], tw) widx[K(x, y)] = 1 end
end)
-- covert row (upper) + primary separations
local function wstep(x, y, d) if wing:has(x, y) then A.step(c, widx, BR, x, y, d, tw) end end
for x = 25, 35 do local y = floor(31.5 - (x - 25) * 0.3 + 0.5) wstep(x, y, -1) wstep(x, y - 1, 1) end
for _, f in ipairs{ { 21, 39, 25, 36 }, { 25, 38, 29, 34 }, { 29, 36, 33, 33 } } do
  local ln = c:line({ { f[1], f[2] }, { f[3], f[4] } }, 1)
  ln:each(function(x, y) wstep(x, y, -2) wstep(x, y - 1, 1) end)
end
-- AO on body pixels directly under the wing lower edge
wing:grow(1):cut(wing):each(function(x, y)
  if bm:has(x, y) and y > 30 and not tailm:has(x, y) then local e = bidx[K(x, y)] if e then c:put(x, y, ramps[e[1]][max(1, e[2] - 2)], tb) end end
end)

-- beak: slim 2-tone wedge with dark gape line
A.map(c, {
  "hhh..",
  "bbbbh",
  "ddddd",
  "bbb..",
}, 47, 22, { h = GO[4], b = GO[3], d = GO[1] }, tb)
c:put(51, 23, GO[2], tb) c:put(50, 25, GO[2], tb)
-- eye with a pale ring
c:put(42, 20, CR[5], tb) c:put(44, 20, CR[4], tb) c:put(42, 23, CR[4], tb)
c:eyeSmall(43, 20)
-- quirk: cowlick feather curling off the crown
A.map(c, {
  ".kk",
  "k.k",
  "..k",
  ".k.",
}, 37, 13, { k = BR[3] }, tb)
c:put(38, 13, BR[5], tb) c:put(39, 14, BR[4], tb)
A.save(c, "ico-bird")
