-- trail-market (32x32 trail map marker, Opus second pass). A market stall where the gnome can trade. Teal and
-- cream striped awning with a scalloped valance (kept off red so it never reads as the toll barrier, the camp tent
-- or the ferry roof), two turned wooden posts, a shady back with a shelf of honey and jam jars, and a plank counter
-- piled with goods: a crate of red apples, a crusty loaf, and a cabbage.
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

-- awning: sloped top in stripes, scalloped valance
local top = c:poly{ { 4, 2 }, { 27, 2 }, { 30, 8 }, { 1, 8 } }
top:each(function(x, y)
  local band = ((x - 1) // 3) % 2
  local h = band == 0 and TE[3] or CR[3]
  if y <= 3 then h = band == 0 and TE[4] or CR[4] end
  if y >= 7 then h = band == 0 and TE[2] or CR[2] end
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
for x = 1, 30 do c:put(x, 20, x < 29 and WD[4] or WD[3]) end -- counter top lip
c:put(1, 21, WD[2]) c:put(30, 21, WD[1])

-- goods on the counter
T.art(c, 14, {
  "................................",
  "................................",
  "...ra.ra........................",
  "..rRrrRrr.....bbbb..............",
  "..rrrrrrrc...bBBbbd.gGg.........",
  "..ccccccccd.bBbbbbbdgGGgd.......",
}, { r = "#e8493b", R = "#ff8a5c", a = "#5a8a3a", c = "#b97a4a", d = "#864c33",
     b = "#d98a3a", B = "#f5c46a", g = "#5fb04e", G = "#9cd86a" })

-- quirk: a grey mouse scampering off along the counter with an apple of its own
T.art(c, 16, {
  "...........................pp...",
  "..........................mmmk..",
  "......................t.mmmmmRr.",
  ".......................tmmmmdrr.",
}, { m = "#cfc8da", d = "#948ca8", p = "#f5a0b8", k = "#2b1c26", t = "#c49aa8", r = "#e8493b", R = "#ff8a5c" })

T.done(c)
