local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- pouch body: round, slightly flattened bottom
local body = c:ellipse(31.5, 41, 18, 15):cut(c:rect(0, 55, 63, 63))
body:add(c:rrect(16, 46, 47, 54, 6))
-- neck: tapered gather from body up to cord
local neck = c:poly({ {25, 24}, {39, 24}, {41, 32}, {23, 32} })
-- frill above the cord: flared with ruffle notches on top
local frill = c:poly({ {20, 15}, {44, 15}, {40, 24}, {24, 24} })
for _, x in ipairs({ 23, 28, 33, 38 }) do frill:del(x, 15); frill:del(x + 1, 15); frill:del(x, 16) end
frill:del(20, 15); frill:del(43, 15)

local p = c:build{
  { "body",  body,  "#c9a96e", { stitch = { side = "lit" } } },
  { "neck",  neck,  "#c9a96e", { gloss = false } },
  { "frill", frill, "#c9a96e" },
  { "cord",  c:rrect(22, 24, 42, 27, 1), "#f5cf6a", { gloss = false } },
}
-- dangling cord ends with bead tips
c:part(c:line({ {27, 27}, {23, 35} }, 2), "#e8a317", { flat = true })
c:part(c:line({ {37, 27}, {41, 35} }, 2), "#e8a317", { flat = true })
c:part(c:rrect(20, 35, 23, 38, 1), "#e8a317", { gloss = false })
c:part(c:rrect(40, 35, 43, 38, 1), "#e8a317", { gloss = false })

-- big pointed tea leaf, pointing up
local leaf = c:poly({ {32, 30}, {36, 34}, {39, 40}, {39, 46}, {35, 51}, {32, 53}, {29, 51}, {25, 46}, {25, 40}, {28, 34} })
c:part(leaf, "#7ab55c", { gloss = { 28, 39 } })
-- veins
for y = 34, 50 do c:px(32, y, "#2f5a2a") end
c:px(31, 40, "#2f5a2a"); c:px(30, 39, "#2f5a2a"); c:px(29, 38, "#2f5a2a")
c:px(33, 42, "#2f5a2a"); c:px(34, 41, "#2f5a2a"); c:px(35, 40, "#2f5a2a")
c:px(31, 45, "#2f5a2a"); c:px(30, 44, "#2f5a2a"); c:px(29, 43, "#2f5a2a")
c:px(33, 47, "#2f5a2a"); c:px(34, 46, "#2f5a2a"); c:px(35, 45, "#2f5a2a")

c:ground(31.5, 56, 15, 1.5)
local t = c:save(O .. "aseprite/ph/tea-seed.aseprite", O .. "png/ph/tea-seed.png")
print(GV.report(t))
