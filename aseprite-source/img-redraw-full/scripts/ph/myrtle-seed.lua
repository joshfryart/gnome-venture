local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local body = c:rect(13, 19, 50, 56)
-- flap trapezoid with crimped (zigzag) top edge
local flap = c:poly({ {16, 13}, {48, 13}, {51, 21}, {13, 21} })
for x = 17, 47, 4 do flap:cut(c:rect(x, 13, x + 1, 13)) end
local win = c:rrect(18, 25, 45, 50, 6)

local p = c:build{
  { "body", body, "#f1ece0" },
  { "flap", flap, GV.ramp("#dcb06a") },
  { "window", win, "#f4f0e0", { gloss = false } },
}
-- window outline 2px moss
c:fill(win:copy():cut(win:shrink(2)), "#7ab55c")
-- berry
local berry = c:ellipse(31.5, 39, 8)
c:part(berry, GV.ramp("#7ab55c", { shade = "#4a8a3e", deep = "#2f5a2a" }))
-- crown dimple
c:paint({ "d.d", ".d." }, 30, 45, { d = "#2f5a2a" })
-- stalk + leaf
c:fill(c:rect(31, 28, 32, 31), "#2f5a2a")
local leaf = c:poly({ {33, 30}, {35, 26}, {40, 24}, {39, 28}, {35, 31} })
c:part(leaf, "moss", { flat = true })
c:paint({ "..v", ".v", "v" }, 35, 27, { v = "#2f5a2a" })
-- crimp seam along flap bottom
c:seam({ { 15, 22 }, { 48, 22 } }, { free = true })
-- print dots
for _, x in ipairs({ 25, 31, 37 }) do c:fill(c:rect(x, 52, x + 1, 53), "#8c4a1a") end
local t = c:save(O .. "aseprite/ph/myrtle-seed.aseprite", O .. "png/ph/myrtle-seed.png")
print(GV.report(t))
