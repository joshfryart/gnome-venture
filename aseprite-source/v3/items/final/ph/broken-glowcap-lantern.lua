-- broken-glowcap-lantern (aB11_4, Opus single pass). Slim brass hand lantern: wire bail, vented cone cap,
-- two brass posts framing a glass chimney, a glowing lime glowcap mushroom on a moss bed inside, stepped brass foot.
-- Material: per-pixel lit brass (bevel, bright edge, specular, dark vent eyes, rivets); glass with bright rim, pale
-- core, a vertical specular streak and a lime glow halo around the mushroom; AO under the cap and over the foot.
-- broken: a triangular shard is knocked out of the upper-right pane (dark hole, bright fracture edge), cracks run
-- from it, and the shard flies off to the right with a tiny chip. quirk: a pale moth has come for the glow.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB11_4.lua")
local HP, X, c = A.new("broken-glowcap-lantern")
local K = A.K
local BR, GL, GW, MO = A.BRASS, A.GLASS, A.GLOW, A.MOSS
local floor, max, min, sqrt = math.floor, math.max, math.min, math.sqrt

c:groundShadow(32, 51, 13, 2)

-- wire bail (ring above the cap)
local bail = c:ellipse(32, 11, 7, 6):cut(c:ellipse(32, 11, 5, 4))
bail:cut(c:rect(0, 14, 63, 63))
A.pillow(c, bail, BR, 1.2, { amb = 0.15 })
c:px(28, 6, BR[6]) c:px(29, 5, BR[6])
-- knob + cone cap
local knob = c:rrect(30, 12, 34, 14, 1)
A.shade(c, knob, A.vcylN(knob, 30, 34, -0.4), BR)
local cap = c:poly{ { 28, 15 }, { 36, 15 }, { 41, 20 }, { 23, 20 } }
local capIdx = A.shade(c, cap, A.vcylN(cap, 23, 41, -0.55), BR)
for _, vx in ipairs{ 29, 32, 35 } do   -- vent slots: dark eye + lit lower lip
  c:px(vx, 17, BR[1]) c:px(vx, 18, BR[1]) c:px(vx, 19, BR[5])
end
c:px(30, 15, BR[6]) c:px(31, 15, BR[6])
-- cap rim
local rim = c:rrect(22, 20, 42, 22, 1)
local rimIdx = A.shade(c, rim, A.vcylN(rim, 22, 42, -0.2), BR)
for x = 23, 41 do A.bump(c, rimIdx, BR, x, 22, -1) end
c:px(24, 21, BR[1]) c:px(23, 20, BR[6])   -- rivets
c:px(40, 21, BR[1]) c:px(39, 20, BR[6])

-- glass chimney
local glass = c:rect(24, 23, 40, 43)
local colT = { [24] = 6, [25] = 4, [26] = 5, [27] = 6, [38] = 4, [39] = 3, [40] = 2 }
local gi = {}
glass:each(function(x, y)
  local i = colT[x] or 5
  if y == 23 then i = min(i, 2) elseif y == 24 then i = min(i, 3) end
  gi[K(x, y)] = i
  c:put(x, y, GL[i])
end)
-- moss bed
local moss = HP.mask()
for x = 24, 40 do
  local top = 40 + ((x * 7) % 3 == 0 and 0 or 1) - ((x == 29 or x == 35) and 1 or 0)
  for y = top, 43 do moss:set(x, y) end
end
local mi = A.pillow(c, moss, MO, 1.5, { amb = 0.2 })
-- glowcap: stem + domed cap
local stem = c:rect(31, 34, 33, 41)
for _, p in ipairs{ { 31, "#fff4d6" }, { 32, "#f1dcae" }, { 33, "#c9a77e" } } do
  for y = 34, 41 do c:put(p[1], y, p[2]) end
end
c:put(30, 41, "#e2c79a") c:put(34, 41, "#a58466")
local capM = c:ellipse(32, 34, 6, 4):cut(c:rect(0, 35, 63, 63))
local capN = X.sphere(31, 34, 6, capM)
local cIdx = A.shade(c, capM, capN, GW, { amb = 0.35, cuts = { 0.15, 0.3, 0.48, 0.66, 0.84 } })
for x = 27, 37 do c:px(x, 35, x < 33 and GW[2] or GW[1]) end  -- gills row
c:px(26, 34, GW[2]) c:px(38, 34, GW[1])
for _, p in ipairs{ { 29, 32 }, { 33, 31 }, { 35, 33 } } do c:px(p[1], p[2], GW[6]) end
c:px(30, 31, A.CREAM)
-- glow halo in the glass around the mushroom
local mush = capM:copy():add(stem)
local h1 = mush:grow(1):cut(mush)
local h2 = mush:grow(2):cut(mush):cut(h1)
h2:each(function(x, y) if glass:has(x, y) and not moss:has(x, y) then c:put(x, y, "#d4f6c0") end end)
h1:each(function(x, y) if glass:has(x, y) and not moss:has(x, y) then c:put(x, y, "#f0fdd2") end end)
-- glass specular streak + left rim stays bright over everything
for y = 25, 38 do c:put(27, y, GL[6]) end
for y = 26, 31 do c:put(28, y, GL[6]) end
-- brass posts
for _, px in ipairs{ { 22, 23 }, { 41, 42 } } do
  local post = c:rect(px[1], 23, px[2], 43)
  local pi = A.shade(c, post, A.vcylN(post, px[1], px[2]), BR, { amb = 0.15 })
  c:put(px[1], 24, BR[2]) c:put(px[2], 24, BR[1])
end
-- foot: rim + stepped plinth
local foot = c:rrect(21, 44, 43, 46, 1)
local fi = A.shade(c, foot, A.vcylN(foot, 21, 43, -0.5), BR)
for x = 22, 42 do A.bump(c, fi, BR, x, 46, -1) end
for x = 24, 40 do c:put(x, 44, x < 32 and BR[5] or BR[4]) end
local plinth = c:rect(23, 47, 41, 49)
local pi2 = A.shade(c, plinth, A.vcylN(plinth, 23, 41, 0.3), BR)
for x = 23, 41 do A.bump(c, pi2, BR, x, 47, -2) end   -- AO under the rim
c:px(25, 45, BR[6]) c:px(26, 45, BR[6])

-- damage: shard knocked out of the upper-right pane
local hole = c:poly{ { 34, 23 }, { 40, 23 }, { 40, 30 }, { 38, 28 }, { 37, 26 } }
hole:clip(glass)
hole:each(function(x, y) c:put(x, y, (y < 25 or x > 38) and GL[1] or GL[2]) end)
-- far (back) pane seen through the hole: faint glow
c:put(37, 27, GL[3]) c:put(38, 27, GL[3]) c:put(39, 28, GL[3])
hole:grow(1):cut(hole):each(function(x, y)
  if glass:has(x, y) then c:put(x, y, GL[6]) end end)
-- cracks
local function crack(pts)
  for _, p in ipairs(pts) do c:put(p[1], p[2], GL[1]) if glass:has(p[1] + 1, p[2]) then c:put(p[1] + 1, p[2], GL[6]) end end
end
crack{ { 33, 24 }, { 32, 25 }, { 31, 26 }, { 30, 26 }, { 29, 27 } }
crack{ { 39, 31 }, { 38, 32 }, { 39, 33 } }
crack{ { 38, 37 }, { 37, 38 }, { 37, 39 } }
-- flying shard + chip
local shard = c:poly{ { 46, 17 }, { 51, 16 }, { 48, 22 } }
shard:each(function(x, y) c:put(x, y, GL[5]) end)
shard:edge():each(function(x, y) c:put(x, y, (x + y < 66) and GL[6] or GL[3]) end)
c:put(47, 18, A.CREAM)
c:put(52, 22, GL[5]) c:put(53, 22, GL[3])
c:sparkle(46, 26)

-- quirk: a pale moth drawn to the glow (left of the lantern)
A.map(c, {
  "ww.ww",
  "wWbWw",
  ".wbw.",
  "..b..",
}, 14, 26, { w = "#efe4fa", W = "#c9b2f0", b = "#6a4e5a" })
c:put(16, 25, "#6a4e5a")
A.fin(c)
