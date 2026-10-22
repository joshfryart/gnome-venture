local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 100, h = 75, out = 2, mode = "sticker" }

-- glass body: shoulders narrowing to a short neck, rounded base
local glass = GV.ramp("#cfeaf3", { shade = "#9ccfe0", deep = "#7fb3c7", bounce = "#a8d4e4", rim = "#e6f6fa" })
local body = c:rrect(35, 30, 65, 66, 6)
body:add(c:poly({ {37, 31}, {63, 31}, {60, 26}, {40, 26} }))
local neck = c:rrect(38, 21, 62, 27, 1)
local lip = c:rrect(36, 17, 64, 22, 2)
local p = c:build{
  { "body", body, glass, { pale = true, gloss = false } },
  { "neck", neck, glass, { pale = true, gloss = false, light = body } },
  { "lip",  lip,  GV.ramp("#9bc4d4"), { gloss = false, light = body } },
}
-- mouth opening (dark inside) and front rim arc
c:fill(c:rrect(39, 18, 61, 19, 1), "#7fb3c7")
for x = 40, 60 do c:px(x, 20, "#c8ecdc") end
-- thicker glass base band
for x = 38, 62 do c:px(x, 61, "#9ccfe0") end
for x = 40, 60 do c:px(x, 62, "#c8ecdc") end
-- vertical highlights (brightest)
c:fill(c:rect(38, 33, 39, 57), "#fff3c8")
c:fill(c:rect(42, 33, 42, 37), "#fff3c8")
c:px(38, 29, "#fff3c8"); c:px(39, 28, "#fff3c8")
-- cream paper label with umber outline and two text bars
local lab = c:rrect(43, 39, 59, 53, 2)
c:fill(lab:grow(1), "#74462a")
c:fill(lab, "#fff8e6")
for x = 46, 56 do c:px(x, 43, "#c9a85a"); c:px(x, 44, "#c9a85a") end
for x = 46, 52 do c:px(x, 47, "#c9a85a"); c:px(x, 48, "#c9a85a") end
for y = 41, 51 do c:px(58, y, "#f5b860") end
c:px(44, 40, "#ffffff")

c:ground(50, 68, 20, 2)
local t = c:save(O .. "aseprite/flowers/jar.aseprite", O .. "png/flowers/jar.png")
print(GV.report(t))
