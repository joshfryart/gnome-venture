local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- tail: thick near body, curling down-left and back
local tail = c:line({ {18,40}, {14,42}, {12,45} }, 4)
tail:add(c:line({ {12,45}, {11,49}, {13,52} }, 3))
tail:add(c:line({ {13,52}, {16,53}, {18,52} }, 2))
local feet = c:ellipse(20.5, 49, 3.5, 2.5):add(c:ellipse(36.5, 49, 3.5, 2.5))
local body = c:ellipse(28.5, 41, 13, 7)
local belly = c:ellipse(29.5, 45, 9, 3.5):clip(body)
local head = c:ellipse(43, 33, 6.5, 6):add(c:poly({ {41,29}, {51,32}, {52,36}, {44,39} }))
local neck = c:poly({ {35,36}, {42,31}, {46,37}, {39,42} })
head:add(neck)
local p = c:build{
  { "tail", tail, "#d9a660", { light = body:copy():add(tail) } },
  { "feet", feet, "#8a4f2a" },
  { "body", body, "#a8582f", { stitch = { side = "lit" } } },
  { "belly", belly, "#d9a660", { gloss = false, contact = false } },
  { "head", head, "#a8582f" },
  { "tongue", c:ascii({ "...t", "ttt.", "ttt.", "...t" }, 52, 33), "#d9667f", { flat = true } },
}
-- spice-speckle diamonds along the back
local function dia(x, y) c:spot(c:poly({ {x,y-2}, {x+2,y}, {x,y+2}, {x-2,y} }), "#5e2f1e", "#8a4f2a") end
dia(22, 37); dia(29, 36); dia(36, 38); dia(26, 41); dia(33, 42)
c:eye(42, 29)
-- nostril and mouth line
c:px(49, 32, "#5e2f1e")
c:paint({ "mmmm" }, 46, 36, { m = "#5e2f1e" })
local t = c:save(O .. "aseprite/ph/creature-spice-monitor.aseprite", O .. "png/ph/creature-spice-monitor.png")
print(GV.report(t))
