local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local walls = c:rect(10, 28, 54, 51)
local roof = c:poly({ {7, 30}, {21, 12}, {44, 12}, {58, 30} })
local eave = c:rect(7, 28, 57, 31)
local door = c:rect(25, 35, 39, 51)

local p = c:build{
  { "walls", walls, GV.ramp("#a9d6ea"), { gloss = false } },
  { "roof",  roof,  "petal" },
  { "eave",  eave,  GV.ramp("#6a6070"), { gloss = false } },
  { "door",  door,  GV.ramp("#8c4a1a"), { gloss = false } },
}

-- plank lines on walls (outside the door)
local planks = c:rect(10, 38, 54, 38):add(c:rect(10, 45, 54, 45)):cut(door:grow(1))
c:fill(planks, GV.ramp("#a9d6ea").shade)

-- door braces: centre plank + X, 1 px
local br = "#44281c"
c:fill(c:line({ {27, 37}, {37, 49} }, 1), br)
c:fill(c:line({ {37, 37}, {27, 49} }, 1), br)
c:fill(c:rect(32, 37, 32, 49), br)
c:px(36, 44, "#f5cf6a") -- knob

-- left tool: trowel
local lt = c:line({ {14, 50}, {13, 37} }, 2)
c:part(lt, "wood", { flat = true })
c:part(c:poly({ {10, 33}, {17, 33}, {14, 39} }), GV.ramp("#968f96"), { gloss = false })
-- right tool: spade
local rt = c:line({ {50, 50}, {51, 40} }, 2)
c:part(rt, "wood", { flat = true })
c:part(c:rrect(48, 34, 54, 40, 1):add(c:poly({ {48, 40}, {55, 40}, {51, 44} })), GV.ramp("#968f96"), { gloss = false })
c:fill(c:rect(49, 32, 52, 33), "#2a1a10")

-- eave seam and door button
c:seam({ {8, 31}, {56, 31} }, { free = true })
c:button(30, 35)

c:ground(32, 53, 24, 1.5)
local t = c:save(O .. "aseprite/ph/tool_shed-painted.aseprite", O .. "png/ph/tool_shed-painted.png")
print(GV.report(t))
