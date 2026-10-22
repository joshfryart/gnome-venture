local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

-- hump body: tall ellipse dome over straight sides
local body = c:ellipse(31.5, 41, 22, 18):cut(c:rect(0, 41, 63, 63))
body:add(c:rect(10, 36, 53, 46))
-- arch opening
local hole = c:ellipse(31.5, 37, 8.5, 8.5):cut(c:rect(0, 38, 63, 63))
hole:add(c:rect(23, 37, 40, 46))
body:cut(hole)
-- deck band along the hump top (4 px)
local deck = body:copy():cut(body:shift(0, 4)):clip(c:rect(12, 0, 51, 63)):cut(c:rect(0, 36, 63, 63))

local water = c:rrect(9, 44, 54, 50, 2)
local stone = GV.ramp("#968f96", { gloss = "#c9c5bc", shade = "#5b6470" })
c:build{
  { "water", water, GV.ramp("#4a7fb0") },
  { "body", body, stone, { stitch = false } },
  { "deck", deck, GV.ramp("#6a6070"), { gloss = false } },
}
-- dark arch interior with water glimpsed at its foot
c:fill(hole, "#3a3048")
c:fill(hole:copy():clip(c:rect(0, 44, 63, 46)), "#2f6290")
c:fill(hole:copy():clip(c:rect(0, 44, 63, 44)), "#3f8fb0")
-- voussoir ticks around the arch rim
for _, t in ipairs{ { {22, 34}, {19, 32} }, { {31, 27}, {31, 25} }, { {41, 34}, {44, 32} },
                    { {25, 29}, {23, 27} }, { {38, 29}, {40, 27} } } do
  c:fill(c:line(t, 2), "#5b6470")
end
-- block joints on the wall sides
c:fill(c:rect(13, 40, 18, 40), "#5b6470"); c:fill(c:rect(45, 40, 50, 40), "#5b6470")
local t = c:save(O .. "aseprite/ico/ico-bridge.aseprite", O .. "png/ico/ico-bridge.png")
print(GV.report(t))
