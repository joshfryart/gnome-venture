local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local body = c:poly({
  {33,7},{35,9},{35,14},{34,20},{35,27},{37,34},{40,41},{41,47},{40,52},
  {38,55},{36,52},{33,56},{30,52},{27,56},{24,52},{21,56},{18,52},{17,48},
  {15,42},{14,35},{15,27},{19,19},{25,12},
})
local ramp = GV.ramp("#dcb06a", { rim = "#f5b860", gloss = "#fff3c8", dot = "#ffffff", shade = "#a5663a" })
local p = c:build{
  { "shard", body, ramp, { cres = 7, deep = 2, pale = true } },
}
-- bone core groove
local groove = c:line({ {21,48},{19,42},{18,36},{19,30},{23,24},{27,19} }, 3):clip(body:shrink(3))
c:fill(groove, "#f1ece0")
c:fill(groove:shift(1,1):cut(groove):clip(body:shrink(2)), "#c9a96e")
-- growth ridges
c:fill(c:line({ {29,16},{32,15} }, 1), "#8a4f2a")
c:fill(c:line({ {29,26},{33,25} }, 1), "#8a4f2a")
c:fill(c:line({ {31,36},{36,35} }, 1), "#8a4f2a")
local t = c:save(O .. "aseprite/ph/antler-shard.aseprite", O .. "png/ph/antler-shard.png")
print(GV.report(t))
