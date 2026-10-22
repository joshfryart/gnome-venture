local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local can = c:rrect(14, 16, 49, 52, 2):add(c:ellipse(31.5, 51, 17.5, 3))
local rim = c:rect(14, 49, 49, 52):add(c:ellipse(31.5, 52, 17.5, 3)):cut(c:rect(0, 0, 63, 48))
local label = c:rect(14, 26, 49, 44)
local lid = c:ellipse(31.5, 16, 17.5, 5)
local tomato = c:ellipse(31.5, 36, 4.5, 4)

local metal = GV.ramp("#8b8f96", { shade = "#5b6470" })
local p = c:build{
  { "can",    can,    metal, { gloss = false } },
  { "rim",    rim,    GV.ramp("#5b6470"), { gloss = false, light = can } },
  { "label",  label,  "red", { light = can, gloss = { 18, 29 } } },
  { "lid",    lid,    GV.ramp("#c9c5bc"), { gloss = { 21, 14 } } },
  { "tomato", tomato, GV.ramp("#ff9158"), { gloss = false, contact = false } },
}
-- highlight strip on can left (metal parts only)
for y = 21, 25 do c:px(17, y, "#c9c5bc"); c:px(18, y, "#c9c5bc") end
for y = 45, 48 do c:px(17, y, "#c9c5bc"); c:px(18, y, "#c9c5bc") end
-- lid inner groove + ring pull
c:fill(c:ellipse(31.5, 16, 13.5, 3):cut(c:ellipse(31.5, 16, 12.5, 2)), "#8b8f96")
c:fill(c:ellipse(36, 15, 3, 2):cut(c:ellipse(36, 15, 1.5, 0.8)), "#5b6470")
c:fill(c:rect(31, 15, 33, 16), "#5b6470")
-- emblem leaf + glint
c:paint({ ".ll.", "llll" }, 30, 30, { l = "#6a9a3a" })
c:px(32, 32, "#4a8a3e")
c:px(29, 34, "#ffc27a")
-- label stitches top and bottom
c:seam({ {15, 27}, {48, 27} })
c:seam({ {15, 43}, {48, 43} })

local t = c:save(D .. "img-redraw-full/aseprite/ph/bought-garden-vegetable-soup.aseprite", D .. "img-redraw-full/png/ph/bought-garden-vegetable-soup.png")
print(GV.report(t))
