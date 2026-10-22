local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local topR = GV.ramp("#b07a45", { rim = "#ecc58a" })
local botR = GV.ramp("#8a4f2a", { rim = "#d9a660" })
local p = c:build{
  { "bottom", c:rrect(13, 34, 57, 47, 3), botR, { gloss = { 50, 37 } } },
  { "top", c:rrect(6, 19, 51, 32, 3), topR, { gloss = { 10, 22 } } },
}
local G = "#5e2f1e"
-- end grain rings on the plank faces
c:fill(c:rect(14, 26, 27, 27), G)
c:fill(c:rect(33, 23, 45, 24), G)
c:fill(c:rect(38, 28, 44, 28), G)
c:fill(c:rect(18, 41, 34, 42), G)
c:fill(c:rect(40, 38, 50, 38), G)
-- knot
c:paint({ ".kk.", "k..k", ".kk." }, 22, 22, { k = G })
c:paint({ ".kk.", "k..k", ".kk." }, 42, 41, { k = G })
local t = c:save(O .. "aseprite/ph/timber-plank.aseprite", O .. "png/ph/timber-plank.png")
print(GV.report(t))
