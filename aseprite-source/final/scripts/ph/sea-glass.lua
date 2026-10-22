local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- angular six-cornered shard, taller than wide, tilting right
local body = c:poly({ {12,31}, {26,10}, {42,12}, {52,32}, {41,54}, {20,51} })
local ramp = GV.ramp("#a9d6ea", { gloss = "#e6f8ee", rim = "#c8ecdc", shade = "#5a86b8", deep = "#2f6290", bounce = "#8fcbd8" })
c:build{
  { "glass", body, ramp, { gloss = { 22, 21 } } },
}
-- frosted paler middle
c:fill(c:ellipse(32, 33, 8, 7):clip(body), "#b8deee")
-- inner facets
c:line({ {26,11}, {33,31}, {51,32} }, 1)
c:fill(c:line({ {26,11}, {33,31}, {51,32} }, 1):clip(body:shrink(1)), "#8fcbd8")
c:fill(c:line({ {33,31}, {29,50} }, 1):clip(body:shrink(1)), "#8fcbd8")
-- wavy glint line
c:paint({
  "..ww......ww.....",
  "ww..w....w..ww...",
  ".....ww.w.....ww.",
  ".......w.........",
}, 17, 37, { w = "#e6f8ee" })
-- big enamel gloss comma
c:paint({
  "..gg.",
  ".ggg.",
  "ggg..",
  "gg...",
  "g....",
}, 19, 18, { g = "#f4fff6" })
c:px(26, 17, "#f4fff6")
local t = c:save(D .. "img-redraw-full/aseprite/ph/sea-glass.aseprite", D .. "img-redraw-full/png/ph/sea-glass.png")
print(GV.report(t))
