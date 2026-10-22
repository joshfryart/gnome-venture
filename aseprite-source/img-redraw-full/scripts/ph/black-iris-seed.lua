local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- plump sack: narrow neck widening to a sagging, wide bottom
local body = c:ellipse(32, 40, 17, 15):add(c:ellipse(32, 46.5, 19.5, 9.5)):add(c:rrect(24, 20, 40, 30, 3))
-- flared ruffle above the tie
local ruffle = c:poly({ {25, 22}, {18, 13}, {21, 10}, {26, 13}, {32, 9}, {38, 13}, {43, 10}, {47, 13}, {40, 22} })
local tie = c:rrect(22, 20, 42, 23, 1)
local knot = c:rrect(29, 18, 34, 24, 2)
local emblem = c:ellipse(32, 39, 8, 8)

local p = c:build{
  { "body", body, "#c9a96e", { stitch = { side = "lit" } } },
  { "ruffle", ruffle, "#c9a96e" },
  { "tie", tie, "#9a6b3f" },
  { "knot", knot, "#9a6b3f" },
  { "emblem", emblem, GV.ramp("#3f8fb0", { shade = "#256a80" }) },
}
-- ruffle fold lines
c:paint({ "f....", ".f...", ".f...", "..f..", "..f.." }, 25, 14, { f = "#9a6b3f" })
c:paint({ "....f", "...f.", "...f.", "..f..", "..f.." }, 35, 14, { f = "#9a6b3f" })
-- twine as thread seam
c:seam({ {23, 21}, {28, 21} }); c:seam({ {35, 21}, {41, 21} })
-- dangling twine ends
c:paint({ "t.", "t.", ".t", ".t" }, 29, 25, { t = "#9a6b3f" })
c:paint({ ".t", ".t", "t.", "t." }, 33, 25, { t = "#9a6b3f" })
-- sprout tucked into the tie
c:part(c:line({ {37, 19}, {39, 14} }, 2), "#58a03e", { flat = true })
c:part(c:ellipse(41.5, 12.5, 3, 2), "#58a03e", { flat = true })
-- iris seeds on the emblem
c:spot(c:ellipse(29, 38, 1.5, 2), "#2a3c6c")
c:spot(c:ellipse(34, 37, 1.5, 2), "#2a3c6c")
c:spot(c:ellipse(32, 42, 1.5, 1.5), "#2a3c6c")
-- dots along the bottom
for _, x in ipairs({ 25, 31, 37 }) do c:fill(c:rect(x, 51, x + 2, 53), "#3f8fb0") end

local t = c:save(O .. "aseprite/ph/black-iris-seed.aseprite", O .. "png/ph/black-iris-seed.png")
print(GV.report(t))
