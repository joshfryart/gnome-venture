-- ph/tomatillo-seed : seed packet, green tomatillo fruit
local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/test100/"
local N = "ph/tomatillo-seed"
local FR, FR_R = "#7ab55c", "moss"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local body = c:poly({ {16,12}, {49,12}, {52,18}, {52,57}, {13,57}, {13,18} })
c:build{
  { "body",   body, GV.ramp("#f1ece0"), { gloss = { 16, 22 }, cres = 3, deep = 1 } },
  { "fold",   c:rect(13, 18, 51, 19), GV.ramp("#dcb06a"), { flat = true, contact = false } },
  { "frame",  c:rrect(18, 22, 46, 50, 6), GV.ramp(FR), { flat = true, contact = false } },
  { "window", c:rrect(20, 24, 44, 48, 4), GV.ramp("#f4f0e0"), { gloss = false, contact = false, rim = false } },
  { "fruit",  c:ellipse(34, 39, 7), FR_R, { gloss = false } },
}
c:px(30, 35, "#fff1c8"); c:px(31, 35, "#fff1c8"); c:px(30, 36, "#fff1c8")
-- husk ribs
c:fill(c:line({ {34, 34}, {34, 44} }, 1), "#4a8a3e")
-- stem and leaf
c:fill(c:rect(33, 29, 34, 32), "#2f5a2a")
c:paint({ ".ll..", "lllll", "lllll.", ".lll" }, 35, 28, { l = "#58a03e" })
c:px(36, 30, "#4a8a3e"); c:px(37, 30, "#4a8a3e")
-- window gloss
c:px(22, 27, "#fff3c8"); c:px(23, 26, "#fff3c8"); c:px(22, 28, "#ffffff")
c:seam({ {15, 18}, {50, 18} })
for _, x in ipairs({ 25, 31, 37 }) do
  c:fill(c:rect(x, 52, x + 2, 54), "#8a4a1c"); c:px(x, 52, "#a8582f")
end
c:ground(32, 58, 17, 2, "#8a4f2a")
local t = c:save(O .. "aseprite/" .. N .. ".aseprite", O .. "png/" .. N .. ".png")
print(GV.report(t))
