local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- tall narrow envelope body
local body = c:rrect(15, 10, 48, 56, 3)
-- top flap: pointed flap with clipped corners
local flap = c:poly({ {15, 13}, {18, 10}, {46, 10}, {49, 13}, {49, 20}, {32, 27}, {15, 20} })
local win = c:rrect(20, 28, 43, 50, 5)
local winIn = c:rrect(22, 30, 41, 48, 4)
local berry = c:ellipse(31.5, 39, 6.5, 6.5)

local p = c:build{
  { "body", body, "#f1ece0" },
  { "win", win, "gold", { gloss = false } },
  { "winIn", winIn, "#f4f0e0", { gloss = false, contact = false } },
  { "flap", flap, "#ece2c8", { contact = true } },
  { "berry", berry, GV.ramp("#e8a317", { shade = "#b07a10" }) },
}
-- stem and leaf
c:fill(c:rect(31, 30, 32, 33), "#2e5a2c")
c:paint({ ".lll.", "lllll", ".lll." }, 33, 29, { l = "#58a03e" })
c:px(34, 29, "#8cc45a")
-- flap seam
c:seam({ {18, 19}, {32, 25}, {46, 19} })
c:button(30, 21)
-- label dots
c:fill(c:rect(25, 52, 26, 53), "#8c4a1a")
c:fill(c:rect(31, 52, 32, 53), "#8c4a1a")
c:fill(c:rect(37, 52, 38, 53), "#8c4a1a")
c:ground(31.5, 58, 14, 1.5)
local t = c:save(O .. "aseprite/ph/dog-rose-seed.aseprite", O .. "png/ph/dog-rose-seed.png")
print(GV.report(t))
