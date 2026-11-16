-- trail-flooded (32x32 trail map marker, Opus richness pass 3, built on opus2). Road kind "flooded": the road dips under water and each
-- stretch is slower (Flood Boots halve it). A dirt road runs toward you in 3/4 view and disappears into a wide pool:
-- you see the road's pale bed under the water, then it climbs out again at the front. A wooden signpost stands in the
-- pool up to its knees (ripple ring round the post), its arrow board pointing on down the road. Water: deep rim at
-- the far bank, bright ripple lines, one glint.
-- quirk: a frog sits on top of the signboard, the only one happy about it.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local T = dofile(DIR .. "/_trail.lua")
local c = T.new("trail-flooded")

local DIRT = { "#6a4430", "#986a44", "#c49662", "#e2bd84" }
local WA = { "#24406e", "#2f6a9e", "#3f92be", "#5fc4c8", "#9ae2da", "#d4f6ec" }
local WD = { "#51302b", "#864c33", "#b97a4a", "#e8b982" }

-- road: narrow at the back, wide at the front
local road = c:poly{ { 13, 9 }, { 20, 9 }, { 26, 30 }, { 7, 30 } }
road:each(function(x, y)
  local h = DIRT[3]
  if not road:has(x - 1, y) then h = DIRT[4] elseif not road:has(x + 1, y) then h = DIRT[2] end
  if (x * 7 + y * 3) % 11 == 0 then h = DIRT[2] end
  c:put(x, y, h)
end)
-- grass verges along the road
road:grow(1):cut(road):each(function(x, y) if y >= 9 then c:put(x, y, (x < 16) and "#7cc35a" or "#3f9150") end end)
T.pt(c, { { 12, 10 }, { 21, 11 } }, "#a8dc78") -- grass tufts on the verges
for x = 14, 19 do c:put(x, 9, DIRT[4]) end    -- lit far edge of the lane as it tops the rise

-- the pool: a wide lens across the road; the drowned road bed shows through
local pool = c:ellipse(15.5, 19, 14.5, 6.5)
pool:each(function(x, y)
  local h = WA[3]
  if road:has(x, y) then h = WA[4] end
  if y <= 13 then h = WA[1] elseif y == 14 then h = road:has(x, y) and WA[3] or WA[2] end
  if not pool:has(x, y + 1) then h = WA[2] end
  c:put(x, y, h)
end)
-- wheel ruts run down the road, on the bank and through the drowned bed
for _, l in ipairs{ { { 15, 9 }, { 11, 29 } }, { { 18, 9 }, { 22, 29 } } } do
  c:line(l, 1):each(function(x, y)
    if pool:has(x, y) then if y > 14 then c:put(x, y, WA[3]) end
    elseif road:has(x, y) then c:put(x, y, DIRT[2]) end
  end)
end
-- muddy bank lips where the road enters and leaves the water
for x = 12, 20 do if pool:has(x, 13) then c:put(x, 12, DIRT[1]) end end
for x = 6, 26 do if road:has(x, 26) and not pool:has(x, 26) then c:put(x, 26, DIRT[1]) end end
-- ripple lines and a glint
T.pt(c, { { 4, 18 }, { 5, 18 }, { 6, 18 }, { 21, 16 }, { 22, 16 }, { 23, 16 }, { 24, 16 }, { 25, 21 }, { 26, 21 }, { 27, 21 },
  { 14, 22 }, { 15, 22 }, { 16, 22 }, { 18, 19 }, { 19, 19 } }, WA[5])
c:put(22, 16, WA[6]) c:put(23, 16, WA[6])

-- near bank: a lit lip where the water laps the road
for x = 7, 25 do if road:has(x, 26) and pool:has(x, 25) and not pool:has(x, 26) then c:put(x, 26, DIRT[4]) end end
-- the signpost's wobbling reflection under the water line
T.pt(c, { { 6, 21 }, { 7, 22 }, { 6, 23 }, { 7, 24 } }, "#2f6a9e")
-- cattails on the far right bank
T.art(c, 7, {
  "........................b.......",
  "........................B..b....",
  "........................b..B....",
  "........................b..b....",
  "........................s..s....",
  ".........................s.s....",
  ".........................s.s....",
}, { b = "#6a3a2a", B = "#b8784a", s = "#4f8a46" })
-- signpost standing in the pool, ripple ring round the post
for y = 10, 20 do c:put(6, y, WD[3]) c:put(7, y, WD[2]) end
for y = 17, 20 do c:put(6, y, "#5a7aa0") c:put(7, y, "#3a5a88") end -- post under water
T.pt(c, { { 3, 20 }, { 4, 21 }, { 5, 21 }, { 8, 21 }, { 9, 21 }, { 10, 20 } }, WA[6])
T.pt(c, { { 4, 20 }, { 9, 20 } }, WA[5])
-- arrow board pointing down the road (to the right)
T.art(c, 6, {
  "................................",
  ".aaaaaaaaaab....................",
  ".abbabbbbabbbc..................",
  ".ccccccccccd....................",
}, { a = WD[4], b = WD[3], c = WD[2], d = WD[1] })
T.pt(c, { { 4, 8 }, { 8, 8 } }, WD[2]) -- nail heads / grain knots on the board

-- quirk: a frog on top of the board
T.art(c, 3, {
  "..EE.EE.........................",
  "..EkGEkd........................",
  ".gGGggggd.......................",
  ".gcccggd........................",
}, { E = "#c4e07a", k = "#2b1c26", g = "#5fb04e", G = "#9cd86a", d = "#2f7a48", c = "#f0e6b0" })
c:put(3, 4, "#fff4d6") -- glint in the frog's eye

T.done(c)
