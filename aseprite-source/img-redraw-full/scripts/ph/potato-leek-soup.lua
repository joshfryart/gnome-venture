local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- wide shallow bowl on a foot ring
local bowl = c:ellipse(31.5, 25, 24, 24):clip(c:rect(0, 25, 63, 63))
bowl:add(c:ellipse(31.5, 25, 24, 8))
bowl:cut(c:rect(0, 47, 63, 63))
bowl:add(c:rrect(14, 40, 49, 47, 6))
local p = c:build{
  { "foot", c:rrect(21, 44, 42, 54, 3), "stone" },
  { "bowl", bowl, GV.ramp("#8b8f96") },
  { "soup", c:ellipse(31.5, 25, 21, 6), GV.ramp("#f1ece0"), { gloss = { 16, 22 } } },
}
-- leek rings (2px thick ring outlines)
local ring = { ".gggg.", "gg..gg", "gg..gg", ".gggg." }
local function leek(x, y)
  local m = c:ascii(ring, x, y)
  c:part(m, "moss", { flat = true })
  c:px(x + 1, y, "#c8d77a")
end
leek(18, 22); leek(31, 20); leek(41, 24)
-- potato cube
c:part(c:rect(25, 25, 29, 29), GV.ramp("#e0b45a"), { flat = true })
c:px(28, 28, "#b8661a"); c:px(29, 29, "#b8661a"); c:px(28, 29, "#b8661a"); c:px(29, 28, "#b8661a")
-- pepper flecks
c:px(37, 27, "#3d2a1c"); c:px(24, 21, "#3d2a1c"); c:px(46, 22, "#3d2a1c")
-- bowl band seam
c:seam({ { 13, 36 }, { 50, 36 } })
local t = c:save(D .. "img-redraw-full/aseprite/ph/potato-leek-soup.aseprite", D .. "img-redraw-full/png/ph/potato-leek-soup.png")
print(GV.report(t))
