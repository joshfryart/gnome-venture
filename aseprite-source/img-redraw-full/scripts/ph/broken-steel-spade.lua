local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- shaft with a T grip on top
local shaft = c:rrect(29, 14, 34, 34, 2)
local grip = c:rrect(22, 9, 41, 14, 3)
-- shield blade: flat round-shouldered top, point at bottom
local blade = c:poly({ {16, 36}, {48, 36}, {48, 44}, {44, 50}, {38, 54}, {32, 57}, {26, 54}, {20, 50}, {16, 44} })
blade:add(c:rrect(16, 34, 47, 42, 4))
-- chips: notch lower right and a bite on the left edge
blade:cut(c:poly({ {48, 44}, {44, 47}, {47, 51}, {49, 51} }))
blade:cut(c:poly({ {15, 40}, {19, 42}, {15, 45} }))
-- collar
local collar = c:rrect(26, 30, 37, 36, 2)

local p = c:build{
  { "grip", grip, "wood" },
  { "shaft", shaft, GV.ramp("#b6814d", { rim = "#f0d49a" }) },
  { "blade", blade, GV.ramp("#968f96") },
  { "collar", collar, GV.ramp("#5b6470"), { gloss = false } },
}
-- loose chip floating off the lower right
c:part(c:poly({ {50, 51}, {53, 50}, {52, 54} }), GV.ramp("#968f96"), { flat = true })

-- streaks on the blade
c:line({ {21, 40}, {25, 40} }, 1)
for x = 21, 25 do c:px(x, 40, "#e6e2d6") end
for x = 21, 23 do c:px(x, 44, "#e6e2d6") end

-- crack down the shaft and into the blade
local K = "#2a1a10"
c:fill(c:line({ {31, 15}, {33, 19}, {31, 24}, {32, 28} }, 1), K)
c:fill(c:line({ {33, 37}, {30, 42}, {35, 47}, {32, 52} }, 1), K)
c:seam({ {27, 33}, {37, 33} })
c:button(30, 31)

local t = c:save(O .. "aseprite/ph/broken-steel-spade.aseprite", O .. "png/ph/broken-steel-spade.png")
print(GV.report(t))
