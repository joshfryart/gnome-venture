-- trail-market (32x32 trail map marker, Opus richness pass 3, built on opus2). A market stall where the gnome can trade. Teal and
-- cream striped awning with a scalloped valance (kept off red so it never reads as the toll barrier, the camp tent
-- or the ferry roof), two turned wooden posts, a shady back with a shelf of honey and jam jars, and a plank counter
-- piled with goods: a crate of red apples, a crusty loaf, and a cabbage.
-- opus3: canvas folds on the awning (lit ridge, shaded trough), turned beads on the posts, nails and grain on the
-- counter, a scored crusty loaf, cabbage veins, and a bigger mouse.
-- quirk: a little grey mouse is scampering off along the counter with an apple of its own.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local T = dofile(DIR .. "/_trail.lua")
local c = T.new("trail-market")

local TE = { "#1f5a6a", "#2c8090", "#3fa6a8", "#6cccc0" }   -- teal deep..lit
local CR = { "#b8a68a", "#dccbaa", "#f2e6c8", "#fff4d6" }   -- cream deep..lit
local WD = { "#51302b", "#864c33", "#b97a4a", "#e8b982" }

-- shady back of the stall
T.fill(c, c:rect(5, 11, 26, 20), "#3a2838")
for x = 5, 26 do c:put(x, 11, "#2a1c2c") end
-- shelf with jars
for x = 6, 25 do c:put(x, 16, WD[2]) c:put(x, 17, WD[1]) end
T.art(c, 12, {
  "................................",
  "......hh..jj..hh....jj..........",
  "......gH..rJ..gH....rJ..........",
  "......gg..rr..gg....rr..........",
}, { h = "#efe0c0", H = "#ffe38a", g = "#f5b82e", j = "#efe0c0", J = "#ff8a5c", r = "#c23a3e" })

-- posts (turned wood, lit left)
for y = 9, 29 do
  c:put(3, y, WD[4]) c:put(4, y, WD[2])
  c:put(27, y, WD[3]) c:put(28, y, WD[1])
end
for _, y in ipairs{ 13, 17 } do c:put(3, y, "#fff0c8") c:put(4, y, WD[3]) c:put(27, y, WD[4]) c:put(28, y, WD[2]) end -- turned beads

-- awning: sloped top in stripes, scalloped valance
local top = c:poly{ { 4, 2 }, { 27, 2 }, { 30, 8 }, { 1, 8 } }
top:each(function(x, y)
  local band = ((x - 1) // 3) % 2
  local h = band == 0 and TE[3] or CR[3]
  if y <= 3 then h = band == 0 and TE[4] or CR[4] end
  if y >= 7 then h = band == 0 and TE[2] or CR[2] end
  if (x - 1) % 3 == 2 and y >= 3 and y <= 6 then h = band == 0 and TE[2] or CR[2] end      -- shade in each fold of the canvas
  if (x - 1) % 3 == 0 and y >= 3 and y <= 6 and band == 0 then h = TE[4] end                -- lit ridge of each teal fold
  c:put(x, y, h)
end)
for x = 1, 30 do
  local band = ((x - 1) // 3) % 2
  local k = (x - 1) % 3
  c:put(x, 9, band == 0 and TE[2] or CR[2])
  if k ~= 2 then c:put(x, 10, band == 0 and TE[1] or CR[1]) end
  if k == 0 then c:put(x, 11, band == 0 and TE[1] or CR[1]) end
end
for x = 1, 30 do c:put(x, 8, ((x - 1) // 3) % 2 == 0 and TE[1] or CR[1]) end -- fold line
c:put(15, 1, WD[2]) c:put(16, 1, WD[2]) c:put(15, 0 + 1, WD[3]) -- ridge knob

-- counter
local front = c:rect(2, 21, 29, 28)
front:each(function(x, y)
  local h = WD[3]
  if y == 24 or y == 27 then h = WD[2] end
  if x == 29 or y == 28 then h = WD[1] end
  if (x * 5 + y) % 13 == 0 and y ~= 24 and y ~= 27 then h = WD[2] end
  c:put(x, y, h)
end)
T.pt(c, { { 4, 22 }, { 27, 22 }, { 4, 25 }, { 27, 25 } }, "#6a4a52")  -- nail heads
T.pt(c, { { 9, 22 }, { 10, 22 }, { 20, 26 }, { 21, 26 } }, "#d49a64") -- grain streaks
for x = 1, 30 do c:put(x, 20, x < 29 and WD[4] or WD[3]) end -- counter top lip
c:put(1, 21, WD[2]) c:put(30, 21, WD[1])

-- goods on the counter: a crate of apples, a scored loaf, a cabbage
T.art(c, 14, {
  "................................",
  "................................",
  "...ra.ra.....kkkk...............",
  "..rRrrRrr...kCsCCk..............",
  "..rrrrrrrc.kcCcsCck.gGg.........",
  "..ccdcdccd.kkcccckkgGGgd........",
}, { r = "#e8493b", R = "#ff8a5c", a = "#5a8a3a", c = "#b97a4a", d = "#864c33",
     k = "#a0561e", C = "#e8a050", s = "#f6dca0",
     g = "#5fb04e", G = "#9cd86a" })
c:put(13, 17, "#fff0c8") -- glint on the crust
c:put(21, 18, "#2f7a48") c:put(22, 19, "#2f7a48") -- cabbage leaf veins

-- quirk: a grey mouse scampering off along the counter with an apple of its own
T.art(c, 15, {
  "..........................pP....",
  "........................mmmmm...",
  "......................t.mmmMekn.",
  ".......................tmmmmmRr.",
  ".........................d.d.rr.",
}, { m = "#cfc8da", M = "#ece6f2", e = "#2b1c26", k = "#cfc8da", n = "#f5a0b8", p = "#f5a0b8", P = "#c46a88",
     t = "#c49aa8", d = "#948ca8", r = "#e8493b", R = "#ff8a5c" })

T.done(c)
