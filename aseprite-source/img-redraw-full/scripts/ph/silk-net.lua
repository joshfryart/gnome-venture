local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local cx, cy = 38.5, 23.5
local handle = c:line({ {14,50}, {29,33} }, 6)
local silk = c:ellipse(cx, cy, 10.5)
local ring = c:ellipse(cx, cy, 13.5):cut(c:ellipse(cx, cy, 9.5))
local ferrule = c:line({ {27,37}, {30,34} }, 7)
local p = c:build{
  { "handle", handle, GV.ramp("#b6814d", { rim = "#f0d49a" }) },
  { "silk", silk, GV.ramp("#a9d6ea", { gloss = "#c8ecdc", dot = "#fff3c8" }), { gloss = false } },
  { "ring", ring, GV.ramp("#d6c9b6"), { gloss = { 30, 14 } } },
  { "ferrule", ferrule, "gold", { gloss = false } },
}
local inner = c:ellipse(cx, cy, 9.5)
local mesh = c:line({ {29,23}, {48,23} }, 2):add(c:line({ {38,14}, {38,33} }, 2))
for d = -8, 8, 4 do if d ~= 0 then mesh:add(c:line({ {29,23+d}, {48,23+d} }, 1)):add(c:line({ {38+d,14}, {38+d,33} }, 1)) end end
c:fill(mesh:clip(inner), "#968f96")
c:paint({ ".gg", "g..", "g.." }, 32, 17, { g = "#c8ecdc" })
c:px(35, 17, "#fff3c8")
local t = c:save(O .. "aseprite/ph/silk-net.aseprite", O .. "png/ph/silk-net.png")
print(GV.report(t))
