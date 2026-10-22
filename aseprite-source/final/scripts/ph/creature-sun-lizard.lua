local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- tail: thick at the body, curling down-left and back up into a hook
local tail = c:line({ {20, 41}, {15, 42}, {11, 44} }, 5)
tail:add(c:line({ {11, 44}, {8, 47}, {8, 51} }, 4))
tail:add(c:line({ {8, 51}, {11, 53}, {14, 52} }, 3))
tail:add(c:line({ {14, 52}, {15, 50} }, 2))
local feet = c:ellipse(21, 47.5, 3.5, 2.5):add(c:ellipse(37, 47.5, 3.5, 2.5))
local body = c:ellipse(30, 41, 14, 6)
local belly = c:ellipse(30, 45, 10, 2.5):clip(body)
local head = c:ellipse(43, 34, 7, 6.5):add(c:poly({ {44, 31}, {52, 34}, {53, 37}, {51, 39}, {44, 40} }))
local p = c:build{
  { "tail",  tail,  "gold" },
  { "feet",  feet,  GV.ramp("#b07a10"), { flat = true } },
  { "body",  body,  "gold", { gloss = { 20, 37 } } },
  { "belly", belly, "cream", { gloss = false, contour = false, contact = false } },
  { "head",  head,  "gold", { gloss = { 40, 30 } } },
}
-- chunky amber diamond spots on the back
local function dia(x, y) c:spot(c:poly({ {x, y - 2}, {x + 2, y}, {x, y + 2}, {x - 2, y} }), "#b8661a", "#d0862a") end
dia(22, 39); dia(29, 37); dia(36, 39); dia(26, 43); dia(33, 43)
-- spine seam
c:seam({ {19, 37}, {25, 35}, {32, 35}, {37, 36} }, { gap = "#e8a317" })
c:eye(41, 31)
c:px(51, 35, "#7a3a14")
c:paint({ "mmm." }, 46, 38, { m = "#7a3a14" })
c:ground(30, 51, 15, 1.5)
local t = c:save(O .. "aseprite/ph/creature-sun-lizard.aseprite", O .. "png/ph/creature-sun-lizard.png")
print(GV.report(t))
