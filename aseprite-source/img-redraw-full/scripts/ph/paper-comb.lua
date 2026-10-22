local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local body = c:rrect(10, 14, 54, 39, 2)
for i = 0, 4 do
  local x0 = 10 + 9 * i
  body:add(c:poly({ {x0, 38}, {x0 + 9, 38}, {x0 + 5.5, 52}, {x0 + 3.5, 52} }))
end
c:build{ { "card", body, GV.ramp("#7ab55c", { gloss = "#c8d77a", shade = "#4a8a3e", deep = "#2f5a2a" }), { gloss = {14, 20} } } }
c:fill(c:rect(18, 22, 46, 23), "#d6c9b6")
c:fill(c:rect(18, 27, 46, 28), "#d6c9b6")
c:fill(c:rect(18, 32, 38, 33), "#d6c9b6")
c:seam({ {14, 17}, {50, 17} })
local t = c:save(O .. "aseprite/ph/paper-comb.aseprite", O .. "png/ph/paper-comb.png")
print(GV.report(t))
