-- broken-tin-lantern (aB12_5, Opus single pass). Slim tin hurricane lantern: wire bail, cone cap with vent slots and
-- chimney, rolled collar, warm-lit glass globe in a 3-post tin cage with a tiny flame, rim + fuel tank + foot.
-- Material: per-pixel cylinder light on tin (6 tones, bevel highlights, rivets), glass bright rim + pale core,
-- AO rows under the collar and rim. broken: a shard punched out of the globe (dark hole with lit glass edge + cracks
-- radiating), the bail bent out of true, a dent in the tank; flying glass shard + tin flake.
-- quirk: a moth has landed on the cap, drawn by the light.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB12_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, abs, sin = math.floor, math.max, math.min, math.abs, math.sin
local c = A.new("broken-tin-lantern")
local T, G = A.TIN, A.GLOW

c:groundShadow(32, 57, 13, 1)

-- wire bail (bent: right shoulder pushed in)
local bm, bn = A.tube({ { 25, 20 }, { 19, 2 }, { 44, 4 }, { 39, 20 } }, function() return 0.85 end)
A.tone(c, bm, bn, T, { amb = 0.15 })
-- bail lugs
local lugs = c:rect(24, 18, 25, 20):add(c:rect(39, 18, 40, 20))
A.lit(c, lugs, T, { R = 1 })

-- chimney + cap top
local ch = c:rect(30, 12, 34, 15)
A.tone(c, ch, A.vcyl(ch, 30, 34), T)
local cht = c:rrect(28, 11, 36, 12, 1)
A.lit(c, cht, T, { R = 1 })
-- cone cap
local cap = c:poly{ { 22.5, 24 }, { 41.5, 24 }, { 36, 15 }, { 28, 15 } }
local capn = {}
cap:each(function(x, y)
  local t = max(-.95, min(.95, (x - 32) / 9))
  capn[K(x, y)] = { t * 0.9, -0.45, 0.75 }
end)
local cb = {}
X.ao(cb, cap, ch, 1, -1)
A.tone(c, cap, capn, T, { bias = cb })
-- vent slots on the cap
for _, x in ipairs{ 27, 30, 34, 37 } do c:px(x, 19, T[1]) c:px(x, 20, T[2]) c:px(x - 1, 20, T[5]) end
c:px(31, 14, A.SPEC) -- chimney glint

-- rolled collar
local col = c:rrect(22, 24, 42, 26, 1)
local _, coln = A.lit(c, col, T, { R = 1.2 })
for x = 23, 41 do if A.get(c, x, 24) == T[5] then c:px(x, 24, T[6]) end end

-- glass globe
local gl = c:rect(24, 27, 40, 44)
local gb = {}
X.ao(gb, gl, col, 2, -1)
local gn = A.vcyl(gl, 24, 40)
A.tone(c, gl, gn, G, { amb = 0.45, wrap = 0.6, bias = gb, cuts = { 0.2, 0.4, 0.62, 0.8, 0.93 } })
-- pale core column + bright rim on lit edge
for y = 29, 42 do c:px(27, y, G[6]) c:px(28, y, G[5]) end
-- flame + wick
A.rows(c, {
  "..c..",
  "..y..",
  ".yWy.",
  ".oWy.",
  "roWyo",
  ".rok.",
  "..k..",
}, 30, 33, { c = "#fff4d6", y = "#ffe38a", W = "#fffbe8", o = "#f5b82e", r = "#e8493b", k = "#3a2228" })
-- cage posts (2 px corners, 1 px centre bar)
for y = 27, 44 do
  c:px(24, y, T[5]) c:px(25, y, T[4])
  c:px(39, y, T[3]) c:px(40, y, T[2])
end

-- rim + tank + foot
local rim = c:rrect(21, 45, 43, 47, 1)
A.lit(c, rim, T, { R = 1.2 })
local tank = c:rect(23, 48, 41, 53)
local tb = {}
X.ao(tb, tank, rim, 1, -1)
-- dent: push normals in a small bowl at (36,50)
local tn = A.vcyl(tank, 23, 41)
tank:each(function(x, y) local dx, dy = x - 36, y - 50.5
  if dx*dx + dy*dy < 6 then tn[K(x, y)] = { -dx * 0.35, -dy * 0.35, 0.8 } end end)
A.tone(c, tank, tn, T, { bias = tb })
for _, x in ipairs{ 26, 32, 38 } do c:px(x, 50, T[6]) c:px(x, 51, T[2]) end -- rivets
local foot = c:rrect(21, 54, 43, 56, 1)
A.lit(c, foot, T, { R = 1 })
for x = 22, 42 do if A.get(c, x, 54) ~= T[1] then c:px(x, 54, T[2]) end end -- AO under tank

-- broken: shard punched out of the globe
local hole = c:poly{ { 33, 30 }, { 36.5, 29 }, { 38.6, 33 }, { 37, 37 }, { 34.5, 35.2 } }
hole:each(function(x, y) c:px(x, y, (x + y) % 5 == 0 and "#6a3328" or "#3e2026") end)
hole:edge():each(function(x, y) if (hole:has(x + 1, y) and not hole:has(x - 1, y)) or not hole:has(x, y - 1) then c:px(x, y, G[6]) end end)
for _, p in ipairs{ { 32, 29 }, { 32, 28 }, { 37, 38 }, { 36, 39 }, { 36, 40 }, { 35, 41 }, { 38, 28 }, { 39, 34 } } do
  c:px(p[1], p[2], G[1])
end
c:px(34, 36, G[1]) c:px(35, 37, G[1]) -- crack running to the flame side
-- flying glass shard + tin flake
A.rows(c, { "ab..", "bcc.", ".bdd" }, 46, 33, { a = G[6], b = G[5], c = G[4], d = G[2] })
A.rows(c, { "ef", "gh" }, 46, 50, { e = T[6], f = T[4], g = T[3], h = T[2] })

-- quirk: moth on the cap (wings spread, antennae)
A.rows(c, {
  ".k...k.",
  "..k.k..",
  "wWwbwwv",
  "WwwbwvV",
  ".vv.vv.",
}, 34, 13, { k = "#3a2228", w = "#efe2c0", W = "#fff4d6", b = "#6a4a3a", v = "#b8a080", V = "#c9b48e" })

A.save(c)
