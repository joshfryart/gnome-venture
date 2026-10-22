local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- tapered diagonal shaft: 4px wide lower, 3px near tip
local rod = c:line({ {9, 55}, {34, 26} }, 4)
rod:add(c:line({ {33, 27}, {48, 10} }, 3))
local tip = c:rect(47, 8, 49, 10)
rod:add(tip)

local reel = c:ellipse(21, 45, 5, 5)
local p = c:build{
  { "rod",  rod,  GV.ramp("#b6814d", { rim = "#d9a660" }), { gloss = { 27, 33 } } },
  { "reel", reel, GV.ramp("#6a6070"), { gloss = { 18, 42 } } },
}
-- bamboo node bands across the shaft (perpendicular, down-right)
local function node(x, y)
  c:px(x, y, "#8a4f2a"); c:px(x + 1, y + 1, "#8a4f2a"); c:px(x + 2, y + 2, "#8a4f2a"); c:px(x - 1, y - 1, "#8a4f2a")
end
node(29, 30); node(37, 21); node(43, 14)
-- reel hub
c:paint({ "hh", "hh" }, 20, 44, { h = "#c9c5bc" })
c:px(24, 45, "#4a2c1a")  -- handle knob

-- line: tip bows right then down
local linePts = { {49, 9}, {53, 10}, {56, 13}, {57, 17}, {57, 21}, {56, 25} }
c:part(c:line(linePts, 1), GV.ramp("#d6c9b6"), { flat = true, rim = false })
c:part(c:line({ {55, 30}, {54, 34}, {54, 37} }, 1), GV.ramp("#d6c9b6"), { flat = true, rim = false })
-- float
c:part(c:rect(54, 26, 57, 29), "red", { gloss = false, rim = false, bounce = false })
c:px(54, 26, "#ffc27a")
c:fill(c:rect(54, 26, 57, 26), "#f1ece0")
-- hook (J)
local hook = c:ascii({ "gg..", ".g..", ".g.g", ".ggg" }, 53, 37)
c:part(hook, "gold", { flat = true })

local t = c:save(O .. "aseprite/ph/cane-fishing-rod.aseprite", O .. "png/ph/cane-fishing-rod.png")
print(GV.report(t))
