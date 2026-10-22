local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local jar = c:rrect(17, 22, 47, 54, 8)
jar:add(c:rrect(20, 20, 44, 26, 2))
local honey = c:rrect(20, 29, 44, 52, 6)
honey:add(c:rect(20, 29, 44, 33))
local lid = c:rrect(15, 12, 49, 23, 4)
local label = c:rrect(22, 36, 42, 46, 2)
c:build{
  { "jar",   jar,   "#a9d6ea", { gloss = false } },
  { "honey", honey, "gold", { gloss = { 23, 32 } } },
  { "lid",   lid,   "gold" },
  { "label", label, "#f4f0e0", { gloss = false } },
}
-- glass highlight streak on the left of the jar
c:fill(c:rect(19, 30, 19, 46), "#e4f4fa")
c:fill(c:rect(19, 27, 21, 27), "#e4f4fa")
-- honey drip from label top
c:paint({
  "hh.......hh..h",
  ".hhh..hhhhhhhh",
  "..h...h....h..",
}, 25, 36, { h = "#e8a317" })
-- tiny bee/hex mark on label
c:paint({
  ".b.b.",
  "bbbbb",
  ".bbb.",
}, 30, 40, { b = "#b8661a" })
-- lid ridges
for x = 19, 45, 4 do c:px(x, 21, "#b8661a") end
c:seam({ {16, 23}, {48, 23} })
local t = c:save(D .. "img-redraw-full/aseprite/ico/ico-honey-pot.aseprite", D .. "img-redraw-full/png/ico/ico-honey-pot.png")
print(GV.report(t))
