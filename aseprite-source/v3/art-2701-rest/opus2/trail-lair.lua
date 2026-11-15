-- trail-lair (32x32 trail map marker, Opus second pass). Landmark kind "lair": the landscape's legendary boss,
-- once a day; a first win gives a ribbon and a big reward. A dark violet crag shaped like a beast's head: two curved
-- ridged bone horns sweep up out of the rock, the cave mouth below is a jaw with bone fangs top and bottom, two red
-- eyes burn in the dark, and a spill of gold hoard glints on the cave floor. Silhouette: horned mound with a fanged
-- maw, not the tunnel's timber-framed boulder.
-- quirk: a red prize rosette with a gold heart (the first-win ribbon) is pinned to the rock beside the jaw, as if daring you.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local T = dofile(DIR .. "/_trail.lua")
local c = T.new("trail-lair")
local HP = T.HP

local RK = { "#241b32", "#382a4a", "#4f3e64", "#6a5882", "#8a78a2", "#ab9cc0" } -- crag deep..hi
local BN = { "#6e5844", "#9a8060", "#c4aa82", "#e2d0a6", "#f6ead0" }            -- bone deep..hi

-- horns: stamped discs along a curve, radius shrinking to the tip; ridged rings
local function horn(pts, r0, r1)
  local m = HP.mask()
  local n = 24
  for i = 0, n do
    local t = i / n
    local seg = t * (#pts - 1)
    local k = math.min(#pts - 1, math.floor(seg) + 1)
    local u = seg - (k - 1)
    local x = pts[k][1] + (pts[k + 1][1] - pts[k][1]) * u
    local y = pts[k][2] + (pts[k + 1][2] - pts[k][2]) * u
    local r = r0 + (r1 - r0) * t
    m:add(c:ellipse(math.floor(x + 0.5), math.floor(y + 0.5), r, r))
  end
  return m
end
local hl = horn({ { 8, 15 }, { 5, 11 }, { 3, 7 }, { 3, 3 } }, 2.4, 0.5)
local hr = horn({ { 23, 15 }, { 26, 11 }, { 28, 7 }, { 28, 3 } }, 2.4, 0.5)
T.vol(c, hl, BN, { bias = 0.2 })
T.vol(c, hr, BN, { bias = -0.1 })
for _, p in ipairs{ { 4, 9 }, { 5, 9 }, { 5, 12 }, { 6, 12 }, { 7, 12 } } do if hl:has(p[1], p[2]) then c:put(p[1], p[2], BN[2]) end end
for _, p in ipairs{ { 27, 9 }, { 26, 9 }, { 26, 12 }, { 25, 12 }, { 24, 12 } } do if hr:has(p[1], p[2]) then c:put(p[1], p[2], BN[1]) end end
c:put(3, 3, BN[5]) c:put(28, 3, BN[4])

-- crag: a domed head of rock with a knobbly brow
local crag = c:ellipse(15.5, 23, 14.5, 11)
crag:clip(c:rect(0, 0, 31, 29))
crag:add(c:ellipse(10, 13, 4, 3)):add(c:ellipse(21, 13, 4, 3))
T.vol(c, crag, RK, { bias = -0.12, k = 1.3 })
-- rock cracks and brow ridges
T.pt(c, { { 6, 25 }, { 5, 26 }, { 26, 24 }, { 27, 25 }, { 25, 15 }, { 26, 16 } }, RK[2])
T.pt(c, { { 7, 12 }, { 8, 11 }, { 9, 11 }, { 10, 11 }, { 3, 18 }, { 4, 16 } }, RK[6])
T.pt(c, { { 19, 11 }, { 20, 11 }, { 21, 11 } }, RK[5])
-- brow shadow over the jaw
T.pt(c, { { 11, 16 }, { 12, 16 }, { 13, 16 }, { 18, 16 }, { 19, 16 }, { 20, 16 } }, RK[2])

-- cave jaw
local maw = c:ellipse(15.5, 26, 8, 8.5)
maw:clip(c:rect(0, 18, 31, 29))
maw:grow(1):cut(maw):each(function(x, y)
  if crag:has(x, y) and y <= 28 then c:put(x, y, (y < 21) and RK[5] or RK[4]) end
end)
T.fill(c, maw, "#1c1428")
maw:each(function(x, y) if not maw:has(x, y - 1) or not maw:has(x - 1, y) then c:put(x, y, "#2e2040") end end)
-- eyes burning in the dark
T.pt(c, { { 12, 22 }, { 13, 22 }, { 18, 22 }, { 19, 22 } }, "#ff6a3c")
T.pt(c, { { 13, 23 }, { 19, 23 } }, "#c4302e")
c:put(12, 22, "#ffd08a") c:put(18, 22, "#ffd08a")
-- gold hoard on the cave floor
T.art(c, 26, {
  "................................",
  "...........a.gG.a...............",
  "..........gGggGgga..............",
  "..........aagaGgaa..............",
}, { G = "#ffe38a", g = "#f5b82e", a = "#b8741e" })
-- fangs (bone): upper from the arch, lower from the floor
for _, f in ipairs{ { 10, 19, 3 }, { 13, 18, 3 }, { 18, 18, 3 }, { 21, 19, 3 } } do
  local x, y, l = f[1], f[2], f[3]
  for j = 0, l - 1 do
    c:put(x, y + j, BN[4])
    if j < l - 1 then c:put(x + 1, y + j, j == 0 and BN[3] or BN[2]) end
  end
  c:put(x, y, BN[5])
end
for _, f in ipairs{ { 8, 28 }, { 22, 28 } } do
  c:put(f[1], f[2], BN[4]) c:put(f[1], f[2] + 1, BN[3]) c:put(f[1] + 1, f[2] + 1, BN[2])
end

-- quirk: a blue prize rosette pinned beside the jaw
T.art(c, 17, {
  "...bbb..........................",
  "..bBBBd.........................",
  "..bBGBd.........................",
  "..bBBdd.........................",
  "...ddd..........................",
  "...s.s..........................",
  "...s.s..........................",
}, { b = "#ff8a5c", B = "#e8493b", d = "#9e2a3c", G = "#ffe38a", s = "#c23a3e" })

T.done(c)
