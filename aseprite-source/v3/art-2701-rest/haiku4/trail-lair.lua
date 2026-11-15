-- trail-lair (32x32 trail map marker, Opus richness pass 3, built on opus2). Landmark kind "lair": the landscape's legendary boss,
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

-- horns: stamped discs along a curve that sweeps out and curls back in at the tip; ridge rings across the horn
local function horn(pts, r0, r1)
  local m = HP.mask()
  local samples = {}
  local n = 32
  for i = 0, n do
    local t = i / n
    local seg = t * (#pts - 1)
    local k = math.min(#pts - 1, math.floor(seg) + 1)
    local u = seg - (k - 1)
    local x = pts[k][1] + (pts[k + 1][1] - pts[k][1]) * u
    local y = pts[k][2] + (pts[k + 1][2] - pts[k][2]) * u
    local r = r0 + (r1 - r0) * t
    m:add(c:ellipse(math.floor(x + 0.5), math.floor(y + 0.5), r, r))
    samples[#samples + 1] = { x, y, t }
  end
  return m, samples
end
local function ridges(m, samples, col, tip)
  m:each(function(x, y)
    local best, bt = 1e9, 0
    for _, s in ipairs(samples) do
      local d = (x - s[1]) ^ 2 + (y - s[2]) ^ 2
      if d < best then best, bt = d, s[3] end
    end
    local u = bt * 7
    local edgeLit = not m:has(x - 1, y) or not m:has(x, y - 1)
    if bt > 0.15 and bt < 0.7 and u - math.floor(u) < 0.25 and not (edgeLit and bt < 0.5) then c:put(x, y, col) end
  end)
end
local hl, sl = horn({ { 8, 15 }, { 5, 12 }, { 3, 9 }, { 3, 5 }, { 6, 2 } }, 2.3, 0.4)
local hr, sr = horn({ { 23, 15 }, { 26, 12 }, { 28, 9 }, { 28, 5 }, { 25, 2 } }, 2.3, 0.4)
T.vol(c, hl, BN, { bias = 0.2 })
T.vol(c, hr, BN, { bias = -0.1 })
ridges(hl, sl, BN[1], BN[5])
ridges(hr, sr, BN[1], BN[4])
-- ring marks across the narrow horns, so each ridge reads at 16 px (left horn y7/y12, right horn y6/y11)
T.pt(c, { { 3, 7 }, { 4, 7 }, { 4, 12 } }, BN[1])
T.pt(c, { { 27, 6 }, { 28, 11 }, { 27, 11 } }, BN[1])
c:put(6, 2, BN[5]) c:put(25, 2, BN[4]) -- polished tips

-- crag: a domed head of rock with a knobbly brow
local crag = c:ellipse(15.5, 23, 14.5, 11)
crag:clip(c:rect(0, 0, 31, 29))
crag:add(c:ellipse(10, 13, 4, 3)):add(c:ellipse(21, 13, 4, 3))
T.vol(c, crag, RK, { bias = -0.12, k = 1.3 })
-- rock cracks and brow ridges
T.pt(c, { { 6, 25 }, { 5, 26 }, { 26, 24 }, { 27, 25 }, { 25, 15 }, { 26, 16 } }, RK[2])
T.pt(c, { { 7, 12 }, { 8, 11 }, { 9, 11 }, { 10, 11 }, { 3, 18 }, { 4, 16 } }, RK[6])
T.pt(c, { { 19, 11 }, { 20, 11 }, { 21, 11 } }, RK[5])
-- reflected light: a cool line just inside the lower-right edge of the crag (ground bounce)
crag:each(function(x, y)
  if x > 18 and y > 18 and crag:has(x + 1, y) and crag:has(x, y + 1) and (not crag:has(x + 2, y) or not crag:has(x, y + 2)) then c:put(x, y, RK[3]) end
end)
-- strata ledges in the rock (lit top lip over a dark seam)
T.pt(c, { { 3, 21 }, { 4, 21 }, { 5, 22 }, { 25, 20 }, { 26, 20 }, { 27, 21 } }, RK[2])
T.pt(c, { { 3, 20 }, { 4, 20 }, { 25, 19 } }, RK[5])
-- weathered pits on the dome (dark pit, lit lower lip)
for _, p in ipairs{ { 14, 12 }, { 22, 18 }, { 8, 18 }, { 17, 14 }, { 27, 17 } } do
  c:put(p[1], p[2], RK[2]) c:put(p[1], p[2] + 1, RK[5])
end
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
T.pt(c, { { 18, 28 }, { 19, 28 }, { 20, 28 } }, BN[4]) c:put(18, 27, BN[5]) c:put(20, 29, BN[3]) -- an old bone in the hoard
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

-- quirk: a red prize rosette with a gold heart (the first-win ribbon) pinned beside the jaw, tails splayed
T.art(c, 16, {
  "..b.b...........................",
  ".bBbBb..........................",
  ".BGBGd..........................",
  ".bGGGd..........................",
  ".bBGBd..........................",
  "..ddd...........................",
  "..s.s...........................",
  ".s...s..........................",
}, { b = "#ff8a5c", B = "#e8493b", d = "#9e2a3c", G = "#ffe38a", s = "#e8493b" })
c:put(2, 18, "#fff4d6") -- glint on the heart

T.done(c)
