local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- stepped plinth: two tiers
local plinth = c:rrect(11, 49, 52, 53, 2)
plinth:add(c:rrect(14, 46, 49, 50, 1))
local wall = c:rect(17, 31, 46, 47)
local posts = c:rect(15, 31, 18, 47):add(c:rect(45, 31, 48, 47))
local roof = c:poly({ {9, 32}, {32, 15}, {55, 32} })
roof:add(c:rrect(10, 30, 53, 33, 1))
c:build{
  { "plinth", plinth, GV.ramp("#b07a45", { rim = "#d9a660" }) },
  { "wall", wall, GV.ramp("#a8582f", { shade = "#8a4f2a" }), { gloss = false } },
  { "posts", posts, GV.ramp("#b07a45", { rim = "#d9a660" }), { gloss = false } },
  { "roof", roof, "gold", { gloss = { 24, 24 } } },
}
-- dark arched stage opening
local opening = c:ellipse(31.5, 40, 7, 7):cut(c:rect(0, 41, 63, 63))
opening:add(c:rect(25, 40, 38, 46))
c:fill(opening, "#3d2a1c")
opening:edge():each(function(x, y) if y < 46 then c:px(x, y, "#5e2f1e") end end)
-- plinth step lips
for x = 15, 48 do c:px(x, 46, "#d9a660") end
for x = 12, 51 do c:px(x, 49, "#d9a660") end
-- finial pole and pennant
c:fill(c:rect(31, 9, 32, 15), "#5e2f1e")
c:paint({ "rrrr", "rrr.", "rr.." }, 33, 9, { r = "#dd3a2a" })
c:px(33, 9, "#f2793a")
c:seam({ {13, 31}, {51, 31} })
c:button(30, 18)
local t = c:save(O .. "aseprite/ph/gnome-bandstand.aseprite", O .. "png/ph/gnome-bandstand.png")
print(GV.report(t))
