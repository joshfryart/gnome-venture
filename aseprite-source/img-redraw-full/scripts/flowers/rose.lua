local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- five outer petal lobes
local petals = c:mask()
local cs = { {32,15}, {47,26}, {41,44}, {23,44}, {17,26} }
for _, q in ipairs(cs) do petals:add(c:ellipse(q[1], q[2], 9.5)) end
petals:add(c:ellipse(32, 31.5, 16))
local whole = petals:copy()
local p = c:build{
  { "petals", petals, "red", { gloss = false } },
  { "centre", c:ellipse(32, 31, 11.5), "red", { light = whole, gloss = false } },
}
-- petal divisions between lobes (short dark notches toward the centre)
local D = "#ae2a2a"
c:fill(c:line({ {39,18},{37,21} }, 1), D)
c:fill(c:line({ {47,37},{43,35} }, 1), D)
c:fill(c:line({ {32,47},{32,43} }, 1), D)
c:fill(c:line({ {17,37},{21,35} }, 1), D)
c:fill(c:line({ {25,18},{27,21} }, 1), D)
-- spiral of petal edges in the centre
c:fill(c:line({ {32,31},{34,30},{35,32},{33,34},{30,33},{29,30},{31,27},{35,27},{38,30},{38,34},{35,37},{30,37},{26,34},{25,30},{27,25} }, 2), D)
-- gloss arcs
c:fill(c:line({ {24,22},{28,19},{33,18} }, 2), "#ffc27a")
c:px(37, 18, "#ff9158"); c:px(38, 19, "#ff9158")
c:fill(c:line({ {23,30},{24,26} }, 1), "#ff9158")
local t = c:save(O .. "aseprite/flowers/rose.aseprite", O .. "png/flowers/rose.png")
print(GV.report(t))
