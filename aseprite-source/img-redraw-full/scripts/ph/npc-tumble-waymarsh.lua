local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 80, h = 100, mode = "bust" }
local tan = GV.ramp("#dcb06a")
local pink = GV.ramp("#f6b8cf")
local green = GV.ramp("#58a03e")
-- ears: tall, slightly splayed, reaching the top
local earL = c:poly({{25,40},{21,22},{22,9},{26,3},{31,3},{35,10},{36,24},{34,40}})
local earR = c:poly({{46,40},{44,24},{45,10},{49,3},{54,3},{58,9},{59,22},{55,40}})
local inL = c:poly({{27,36},{25,22},{26,11},{28,7},{30,7},{32,12},{32,24},{31,36}})
local inR = c:poly({{49,36},{48,24},{48,12},{50,7},{52,7},{54,11},{55,22},{53,36}})
local jacket = c:rrect(8, 72, 71, 104, 10)
local head = c:ellipse(39.5, 52, 19, 17)
local scarf = c:rrect(20, 66, 59, 73, 3)
scarf:add(c:poly({{46,70},{54,70},{56,88},{49,88}}))
local p = c:build{
  { "earL", earL, tan },
  { "earR", earR, tan },
  { "inL", inL, pink, { flat = true } },
  { "inR", inR, pink, { flat = true } },
  { "jacket", jacket, "gold", { light = c:rect(8, 30, 71, 104) } },
  { "head", head, tan },
  { "scarf", scarf, green, { stitch = { side = "lit" } } },
  { "muzzle", c:ellipse(39.5, 59, 8, 5.5), "cream" },
  { "plaster", c:ellipse(49, 49, 5.5, 5.5), "cream" },
}
-- jacket collar V and placket
c:paint({
  "o.........o",
  ".o.......o.",
  "..o.....o..",
}, 34, 74, { o = "#b07a10" })
for y = 89, 99 do c:px(39, y, "#b07a10") end
c:button(37, 90); c:button(37, 96)
-- plaster cross stitch
c:px(48, 48, GV.C.gold); c:px(50, 48, GV.C.gold); c:px(49, 49, GV.C.gold)
c:px(48, 50, GV.C.gold); c:px(50, 50, GV.C.gold)
-- face
c:eye(26, 46)
c:paint({ ".nnnn.", "nnnnnn", ".nnnn." }, 37, 55, { n = "#d9667f" })
c:paint({ "..u..", "uu.uu" }, 37, 59, { u = "umber" })
c:paint({ "ww...", "..www" }, 22, 59, { w = "#f8eed2" })
c:paint({ "...ww", "www.." }, 53, 59, { w = "#f8eed2" })
local t = c:save(O .. "aseprite/ph/npc-tumble-waymarsh.aseprite", O .. "png/ph/npc-tumble-waymarsh.png")
print(GV.report(t))
