local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/test100/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local R = GV.R

local p = c:build{
  { "pages", c:rect(48, 12, 54, 52), "cream", { gloss = false } },
  { "cover", c:rrect(12, 8, 50, 56, 4), GV.ramp("#6a9a3a", { shade = "#4a8a3e" }) },
  { "spine", c:rrect(12, 8, 21, 56, 3), GV.ramp("#4a8a3e", { shade = "#2f5a2a" }), { gloss = { 15, 12 } } },
  { "label", c:rect(27, 18, 44, 30), GV.ramp("#dcb06a"), { gloss = false } },
}
-- page leaves
c:fill(c:rect(51, 15, 51, 49), "#c9a96e")
c:fill(c:rect(53, 15, 53, 49), "#c9a96e")
-- label inset border
local lb = c:rect(29, 20, 42, 28):cut(c:rect(30, 21, 41, 27))
c:fill(lb, "#e8a317")
-- spine seam + cover edge stitch
c:seam({ {22, 11}, {22, 53} })
c:stitch(c:rrect(22, 8, 50, 56, 3), { side = "lit" })

local t = c:save(O .. "aseprite/ico/ico-book-green.aseprite", O .. "png/ico/ico-book-green.png")
print(GV.report(t))
