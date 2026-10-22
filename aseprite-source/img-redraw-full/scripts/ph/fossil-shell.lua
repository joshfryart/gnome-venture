local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- fan body: domed top narrowing to the hinge point
local fan = c:ellipse(32, 31, 22, 15):cut(c:rect(0, 32, 63, 63))
fan:add(c:poly({ {10, 31}, {55, 31}, {33, 54}, {31, 54} }))
-- scalloped rim: a bump at the end of each ray
local tips = { {12, 30}, {17, 21}, {24, 16}, {32, 14}, {40, 16}, {47, 21}, {52, 30} }
for _, t in ipairs(tips) do fan:add(c:ellipse(t[1], t[2], 4, 4)) end
-- small ears either side of the hinge
fan:add(c:poly({ {24, 46}, {40, 46}, {37, 53}, {27, 53} }))

local rib = "#dcb06a"
c:build{
  { "shell", fan, GV.ramp("#f6b8cf") },
}
-- radiating ribs (2px), drawn as flat detail on the shell
local ends = { {12, 28}, {18, 20}, {25, 16}, {32, 16}, {39, 16}, {46, 20}, {52, 28} }
local ribs = c:mask()
for _, e in ipairs(ends) do ribs:add(c:line({ {32, 50}, e }, 2)) end
ribs:clip(fan:shrink(2))
c:part(ribs, GV.ramp(rib), { flat = true, contour = false, contact = false, solid = false })
-- hinge nub
c:part(c:rrect(29, 48, 35, 52, 1), GV.ramp(rib), { contour = "#4a2c1a" })
c:gloss(fan, GV.ramp("#f6b8cf"), { 19, 24 })

local t = c:save(O .. "aseprite/ph/fossil-shell.aseprite", O .. "png/ph/fossil-shell.png")
print(GV.report(t))
