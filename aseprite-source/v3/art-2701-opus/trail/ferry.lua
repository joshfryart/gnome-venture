-- ferry (32x32 trail map marker, Opus pass). A stubby wooden river ferry in side view: plank hull with a
-- lit rail and a dark keel, a little cream cabin with a red gable roof, a round porthole and a door with a
-- gold knob, sitting in a lens of blue water with lit wave crests (blue reads well on the green map).
-- quirk: a yellow duck rides on the bow like a figurehead, beak into the wind.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local T = dofile(DIR .. "/_trail.lua")
local c = T.new("ferry")

-- water lens
local SEA = { "#2a4a7a", "#3a86b0", "#4aa6c0", "#5fc4c8", "#8edcd6", "#b6f0e0" }
local water = c:ellipse(15.5, 25.5, 15, 4)
T.fill(c, water, SEA[4])
water:each(function(x, y) if y >= 27 then c:put(x, y, SEA[3]) end if y >= 29 then c:put(x, y, SEA[2]) end end)
-- wave crests
for _, w in ipairs{ { 2, 25 }, { 26, 24 }, { 9, 28 }, { 21, 28 } } do
  c:put(w[1], w[2], SEA[6]) c:put(w[1] + 1, w[2], SEA[6]) c:put(w[1] + 2, w[2], SEA[5])
end

T.grid(c, 0, 5, {
  "...........hr...................",   -- 5  roof
  "..........hrrs..................",   -- 6
  ".........hrrrss.................",   -- 7
  "........hrrrrrss................",   -- 8
  ".......hrrrrrrrss...............",   -- 9
  "......qqqqqqqqqqqq..............",   -- 10 eave
  ".......lllllllllm...YY..........",   -- 11 walls / duck head
  ".......lWWWldddlm..Yykoo........",   -- 12
  ".......lWDWlddylmY.yyyo.........",   -- 13
  ".......lWWWldddlmYYyyyyg........",   -- 14
  "...nn..llllldddlmgyyyyyg....ee..",   -- 15 rope coil / bow tip
  "..nNNn.mmmmmdddmm.gggggg...ebd..",   -- 16
  "..eeeeeeeeeeeeeeeeeeeeeeeeebbd..",   -- 17 rail
  "..bbbbbbbbbbbbbbbbbbbbbbbbbbbd..",   -- 18
  "...WWWWWWWWWWWWWWWWWWWWWWWWWd...",   -- 19 plank seam
  "...bbebbbbbbbebbbbbbbbbebbbbd...",   -- 20 nails
  "....WWWWWWWWWWWWWWWWWWWWWWWd....",   -- 21
  ".....ddddddddddddddddddddd......",   -- 22 keel
}, {
  h = "#ff8a5c", r = "#e8493b", s = "#b52e3f", q = "#6e2038",
  l = "#f6dcae", m = "#d9ac78", W = "#864c33", D = "#b6f0e0", d = "#51302b",
  Y = "#ffe38a", y = "#f5b82e", g = "#d98322", k = "#2b1c26", o = "#f07a2e",
  e = "#e8b982", b = "#b97a4a", n = "#d9b77a", N = "#a8804c",
})
-- door is dark wood, porthole glass a two-tone
for y = 12, 16 do for x = 12, 14 do if c:get(x, y) == "#51302b" then c:put(x, y, "#5a3a33") end end end
c:put(12, 12, "#3e2a2c")
c:put(9, 13, "#b6f0e0") c:put(8, 13, "#5fc4c8") -- porthole
c:put(18, 12, "#2b1c26") -- keep duck head separate from the cabin wall
T.done(c)
