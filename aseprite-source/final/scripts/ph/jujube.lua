local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local body = c:ellipse(31.5, 38, 14, 18)
local leaf = c:poly({ {33,19}, {37,11}, {45,7}, {47,8}, {44,15}, {37,19} })
local rb = GV.ramp("#a83e2c")
local p = c:build{
  { "stalk", c:rect(30, 13, 32, 23), "wood", { flat = true } },
  { "leaf", leaf, "leaf" },
  { "body", body, rb },
}
-- dimple at stalk base
c:paint({ ".ddd.", "ddddd", ".ddd." }, 29, 21, { d = "#6b1b2c" })
-- wrinkles: short curved creases
local function wr(pts) local m = c:line(pts, 1); m:clip(body:shrink(3)); c:fill(m, "#ae2a2a") end
wr({ {34,29}, {37,32}, {38,36} })
wr({ {22,40}, {24,43}, {27,44} })
wr({ {36,44}, {39,47}, {39,51} })
wr({ {28,52}, {31,53} })
local t = c:save(O .. "aseprite/ph/jujube.aseprite", O .. "png/ph/jujube.png")
print(GV.report(t))
