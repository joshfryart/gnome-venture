local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local body = c:ellipse(31.5, 38, 11, 14)
body:add(c:ellipse(22, 39, 10, 12)):add(c:ellipse(41, 39, 10, 12))
body:add(c:rrect(14, 30, 49, 48, 6))
local leaf = c:poly({ {35, 21}, {37, 14}, {41, 9}, {45, 8}, {44, 13}, {40, 18}, {36, 22} })
local p = c:build{
  { "leaf", leaf, "leaf", { gloss = false } },
  { "stem", c:poly({ {30, 17}, {35, 16}, {35, 27}, {30, 27} }), GV.ramp("#35602c"), { gloss = false } },
  { "body", body, GV.ramp("#f08a24"), { gloss = { 22, 30 } } },
}
local rib = "#b8661a"
for _, pts in ipairs({ { {28, 26}, {26, 32}, {25, 40}, {26, 47}, {28, 51} }, { {36, 26}, {38, 32}, {39, 40}, {38, 47}, {36, 51} } }) do
  c:fill(c:line(pts, 1):clip(p.body.m), rib)
end
local t = c:save(O .. "aseprite/ph/pumpkin.aseprite", O .. "png/ph/pumpkin.png")
print(GV.report(t))
