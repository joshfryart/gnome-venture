local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local B = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local hex = c:poly({{32,8},{54,20},{51,46},{32,57},{13,46},{10,20}})
local inner = c:poly({{32,14},{47,22},{44,41},{32,48},{20,41},{17,22}})
local p = c:build{
  { "plate", hex, GV.ramp("#b0bc66"), { gloss = {20,21} } },
  { "inner", inner, GV.ramp("#6a9a3a"), { gloss = false } },
}
-- growth rings bowed left of centre
c:fill(c:line({{32,50},{27,46},{24,39},{23,31},{25,22},{29,16},{33,13}}, 1), "#2f5a2a")
c:fill(c:line({{32,43},{29,40},{27,35},{27,28},{29,22},{33,18}}, 1), "#2f5a2a")
-- centre ridge
c:fill(c:rect(32, 11, 33, 53), "#4a8a3e")
c:fill(c:rect(32, 11, 32, 30), "#a4b86a")
local t = c:save(B .. "aseprite/ph/turtle-scute.aseprite", B .. "png/ph/turtle-scute.png")
print(GV.report(t))
