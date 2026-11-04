-- rock-garden (final, Sonnet high). A shallow oak tray with beveled rim, plank grain and two little feet, filled with
-- fine raked sand: straight furrows (lit lip + dark groove) that swing into concentric ripples round three stones -- a
-- tall faceted standing stone with a moss cap, a squat rounded boulder and a small pebble. Each stone sits in a dark
-- contact shadow. quirk: a tiny snail is climbing the tall stone.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD12_5.lua")
local HP, X, K, B = D.HP, D.X, D.K, D.B
local floor, ceil, abs, sin, cos, pi, max, min, sqrt = math.floor, math.ceil, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = D.new("rock-garden")
local WD = D.R.wood
local SA = { "#8e7048", "#b0905c", "#cfae74", "#e4c88c", "#f2dca4", "#fff0c8" }
local ST = { "#2f3049", "#4a4c6a", "#6c6e8c", "#908fa8", "#b8b6c8", "#e2e0e6" }
local MO = D.R.leaf
D.shadow(c, 32, 56, 24, 1.6)

-- tray: front wall, rim ring, feet
local front = c:rrect(7, 41, 57, 52, 3)
local rimOut = c:rrect(7, 26, 57, 48, 4)
local sandM = c:rrect(11, 30, 53, 44, 2)
-- feet
c:fillMask(c:rect(11, 53, 16, 54), WD[1]) c:fillMask(c:rect(48, 53, 53, 54), WD[1])
-- front wall: vertical bevel, plank grain
do
  local w = front:copy():cut(c:rrect(7, 26, 57, 40, 4):clip(c:rect(0, 0, 63, 40)))
  D.litB(c, w, WD, 3, { wrap = 0.4, amb = 0.12 }, function(x, y)
    if y == 47 or y == 48 then return -1 end
    local h = D.hash(x // 3, y, 6)
    if y % 4 == 1 and h > 0.5 then return -1 end
    if y == 42 then return 1 end
  end)
  -- front dark bottom row
  for x = 9, 55 do if w:has(x, 52) then c:px(x, 52, WD[1]) end end
  -- little plank joint
  for y = 43, 51 do c:px(31, y, WD[2]) end
  c:px(30, 43, WD[5])
  -- nail heads
  for _, q in ipairs{ {11,47},{53,47} } do c:px(q[1], q[2], ST[2]) c:px(q[1], q[2] - 1, ST[5]) end
end
-- rim ring (top face of the walls), pillow bevel + grain along the length
local ring = rimOut:copy():cut(sandM):clip(c:rect(0, 0, 63, 44)):add(rimOut:copy():clip(c:rect(0, 41, 63, 44)):cut(sandM))
do
  D.litB(c, ring, WD, 1.6, { wrap = 0.4, amb = 0.1 }, function(x, y)
    local h = D.hash(x, y, 3)
    if y < 30 and h > 0.55 then return 0 end
    if (x + (y > 40 and 2 or 0)) % 7 == 0 and h > 0.4 then return -1 end
    if y == 26 or y == 27 then return 1 end
  end)
end
-- inside far wall (shadowed strip under the far rim)
for x = 11, 53 do for y = 30, 31 do if sandM:has(x, y) then c:px(x, y, y == 30 and WD[1] or WD[2]) end end end
-- left inner wall highlight edge
for y = 32, 43 do c:px(11, y, WD[2]) end

-- sand
local sand = sandM:copy():cut(c:rect(0, 30, 63, 31))
do
  D.litB(c, sand, SA, 2, { wrap = 0.6, amb = 0.3 }, function(x, y)
    local h = D.hash(x, y, 7)
    if h > 0.92 then return 1 elseif h < 0.08 then return -1 end
  end)
end
-- stone anchor positions (footprints)
local tallC, midC, smallC = { 21, 41 }, { 43, 40 }, { 50, 33 }
local foot = {
  { tallC[1], tallC[2], 7, 3 },
  { midC[1], midC[2], 9, 3.4 },
  { smallC[1], smallC[2], 4.5, 1.9 },
}
local function edist(x, y)
  local best, bi = 1e9, 0
  for i, f in ipairs(foot) do
    local d = sqrt(((x - f[1]) / f[3]) ^ 2 + ((y - f[2]) / f[4]) ^ 2)
    if d < best then best, bi = d, i end
  end
  return best, bi
end
-- rake lines: rings near stones (scaled ellipses), straight rows elsewhere
sand:each(function(x, y)
  if y < 32 then return end
  local d, bi = edist(x, y)
  local f = foot[bi]
  local mx = min(f[3], f[4] * 2)
  local line
  if d < 3.2 then
    local ring = (d - 1.0) * (f[4] + 0.6)           -- distance in px-ish from footprint
    local r2 = (d - 1.0) * (min(f[3], f[4] * 2.2))
    line = (floor(r2 + 0.5) % 3 == 0) and d > 1.35
    if line then c:px(x, y, SA[2]) c:px(x, y + 1, SA[5]) end
    return
  end
  if (y % 3 == 0) and (x + y) % 11 ~= 0 then c:px(x, y, SA[2]) end
  if (y % 3 == 1) and (x + y - 1) % 11 ~= 0 then c:px(x, y, SA[5]) end
end)
-- clean up: re-lighten highlight pixels belonging to rows that were overwritten by ring hits (no-op, hard pixels)

-- contact shadow under each stone
for _, f in ipairs(foot) do
  local sh = c:ellipse(f[1] + 1, f[2] + 0.5, f[3] + 1.5, f[4] + 0.9):clip(sand)
  c:fillMask(sh, SA[1])
  c:fillMask(c:ellipse(f[1] + 0.5, f[2], f[3] + 0.2, f[4] - 0.3):clip(sand), "#6a5238")
end

-- stones
local function stoneLit(m, R, bf)
  return D.litB(c, m, ST, R, { wrap = 0.18, amb = 0.1 }, function(x, y)
    local b = bf and bf(x, y) or 0
    local h = D.hash(x, y, 12)
    if h > 0.93 then b = b + 1 elseif h < 0.07 then b = b - 1 end
    return b
  end)
end
-- big tall standing stone (faceted: left lit plane, right shade plane, angled top)
local tall = c:poly{ {14,43},{14,28},{16,19},{20,12},{25,11},{28,16},{29,25},{29,38},{27,43} }
stoneLit(tall, 3, function(x, y)
  if x >= 24 then return -1 end                  -- shade plane
  if y < 18 then return 0 end
  if x >= 21 and x < 24 then return 0 end
  return 0
end)
-- facet edge line (bright arris) down the tall stone and a crack
for y = 19, 40 do c:px(23, y, ST[5]) end
for y = 14, 17 do c:px(22, y, ST[5]) end c:px(21, 18, ST[5])
for _, q in ipairs{ {18,26},{18,27},{19,28},{19,29},{18,30} } do c:px(q[1], q[2], ST[2]) end
-- bottom ambient
tall:each(function(x, y) if y >= 41 then c:px(x, y, ST[1]) end end)
-- moss cap on the tall stone (ragged lower edge, little fringe)
local mc = c:poly{ {15,22},{16,19},{20,12},{25,11},{28,16},{29,22},{27,20},{25,22},{23,19},{21,21},{19,19},{17,23} }:clip(tall)
D.litB(c, mc, MO, 2, { wrap = 0.3, amb = 0.1 }, function(x, y) if D.hash(x, y, 2) > 0.8 then return 1 end end)
c:px(18, 24, MO[4]) c:px(22, 22, MO[3]) c:px(26, 23, MO[3])
c:px(19, 15, MO[6]) c:px(20, 14, MO[6])
-- squat boulder
local mid = c:ellipse(43, 38, 8.5, 5.2)
mid:add(c:poly{ {36,40},{37,34},{42,31},{49,33},{52,38},{50,43},{38,44} })
stoneLit(mid, 4)
for _, q in ipairs{ {39,36},{40,37},{45,35},{46,36},{47,40},{44,41} } do c:px(q[1], q[2], ST[4]) end
c:px(41, 33, ST[6]) c:px(42, 33, ST[6])
c:px(44, 43, ST[1]) c:px(48, 42, ST[1]) c:px(40, 43, ST[1])
-- small pebble
local peb = B.ell(51, 32, 3.6, 2.6, -0.3)
stoneLit(peb, 2.5)
c:px(49, 31, ST[6])

-- quirk: a tiny snail climbing the tall stone
local sh = B.ell(25, 30, 2.5, 2.5, 0)
B.lit(c, sh, { "#7a3a1c", "#a8542a", "#d98322", "#f5b82e", "#ffd060", "#ffe38a" }, 2)
c:px(25, 30, "#7a3a1c") c:px(26, 30, "#7a3a1c") c:px(26, 31, "#7a3a1c") c:px(25, 31, "#a8542a")
c:fillMask(c:rect(23, 32, 28, 33), "#d9c8f4")
c:px(22, 32, "#d9c8f4") c:px(29, 33, "#8a6fd0") c:px(23, 33, "#8a6fd0") c:px(28, 33, "#8a6fd0")
c:px(22, 31, "#d9c8f4") c:px(22, 30, "#d9c8f4") c:px(21, 29, "#d9c8f4") -- neck and antenna
c:px(23, 30, "#d9c8f4")
D.fin()
