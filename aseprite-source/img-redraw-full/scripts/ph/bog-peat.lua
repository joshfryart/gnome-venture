local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local clod = c:poly({ {8,48},{10,40},{16,32},{21,26},{26,17},{28,17},{33,25},{36,28},{42,30},{49,34},{55,40},{57,47},{52,51},{42,54},{22,54},{12,52} })
clod:add(c:ellipse(23, 29, 6, 5))
clod:add(c:ellipse(42, 34, 9, 5))
clod:add(c:ellipse(32, 47, 23, 5))
local top = clod:copy():clip(c:rect(0, 0, 63, 37))
local p = c:build{
  { "clod", clod, GV.ramp("#5b6470"), { gloss = false } },
  { "top", top, GV.ramp("#8b8f96", { gloss = "#c9c5bc" }), { light = clod, gloss = {20, 29}, contact = false } },
}
-- wet dark band along the bottom
local band = clod:copy():clip(c:ellipse(32, 46, 26, 7):cut(c:ellipse(32, 43, 25, 6)))
c:fill(band, "#35161f")
-- root fibres
c:paint({ "f...", ".ff.", "...f" }, 15, 30, { f = "#9a6b3f" })
c:paint({ "ff..", "..ff" }, 29, 40, { f = "#9a6b3f" })
c:paint({ "..f", "ff.", "f.." }, 44, 37, { f = "#9a6b3f" })
local t = c:save(O .. "aseprite/ph/bog-peat.aseprite", O .. "png/ph/bog-peat.png")
print(GV.report(t))
