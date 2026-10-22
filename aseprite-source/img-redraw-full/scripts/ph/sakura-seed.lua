local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local burlap = GV.ramp("#c9a96e")
local cuffr = GV.ramp("#e0c88e")
local sack = c:ellipse(31.5, 42, 22, 14)
sack:add(c:rrect(14, 28, 49, 40, 4))
local cuff = c:rrect(12, 19, 51, 30, 4)
local p = c:build{
  { "sack", sack, burlap, { stitch = true, gloss = false } },
  { "cuff", cuff, cuffr, { stitch = { side = "lit" } } },
}
-- cuff seam
c:seam({ {14, 25}, {49, 25} })
-- twine band
c:fill(c:line({ {13, 31}, {50, 31} }, 2), "#7a4a1f")
-- bow on the right side
c:part(c:ellipse(44, 30, 3, 2.5), GV.ramp("#9a6b3f"), { flat = true })
c:part(c:ellipse(51, 30, 3, 2.5), GV.ramp("#9a6b3f"), { flat = true })
c:fill(c:line({ {47, 32}, {45, 37} }, 2), "#7a4a1f")
c:fill(c:line({ {48, 32}, {51, 36} }, 2), "#7a4a1f")
c:fill(c:rect(47, 29, 48, 32), "#7a4a1f")
-- pink seed
c:part(c:ellipse(30, 44, 7, 7), "petal", { contact = false })
-- sprout
c:fill(c:rect(30, 34, 31, 37), "#2e5a2c")
c:part(c:ellipse(34.5, 34, 3, 1.5), GV.ramp("#58a03e"), { flat = true })
c:ground(31.5, 57, 18, 1.5)
local t = c:save(O .. "aseprite/ph/sakura-seed.aseprite", O .. "png/ph/sakura-seed.png")
print(GV.report(t))
