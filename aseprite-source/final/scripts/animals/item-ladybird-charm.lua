local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local ring = c:ellipse(31.5, 13.5, 4.5, 4.5):cut(c:ellipse(31.5, 13.5, 1.5, 1.5))
local link = c:rect(30, 18, 32, 22)
local shell = c:ellipse(31.5, 39.5, 16, 13)
local head = c:ellipse(31.5, 25.5, 6.5, 5.5)
local headR = GV.ramp("#35161f", { rim = "#5e2a3a", gloss = "#5e2a3a", dot = "#5e2a3a" })

local p = c:build{
  { "ring", ring, "gold", { gloss = false, cres = 2, deep = 1 } },
  { "link", link, "gold", { flat = true } },
  { "shell", shell, "red" },
  { "head", head, headR, { gloss = false } },
}
-- centre split
c:fill(c:rect(31, 31, 32, 53):clip(shell), "#35161f")
-- spots
c:spot(c:ellipse(24, 37, 2.5, 2.5)); c:spot(c:ellipse(39, 37, 2.5, 2.5))
c:spot(c:ellipse(25.5, 46, 2.5, 2)); c:spot(c:ellipse(37.5, 46, 2.5, 2))
-- eyes and head glint
c:eye(27, 23, true); c:eye(33, 23, true)
c:px(29, 21, "#5e2a3a"); c:px(30, 21, "#5e2a3a")
local t = c:save(O .. "aseprite/animals/item-ladybird-charm.aseprite", O .. "png/animals/item-ladybird-charm.png")
print(GV.report(t))
