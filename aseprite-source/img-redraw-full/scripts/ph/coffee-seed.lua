local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local bean = GV.ramp("#8c4a1a")
local leaf = GV.ramp("#58a03e")

local p = c:build{
  { "back",  c:rect(13, 28, 51, 36), GV.ramp("#8a4f2a"), { gloss = false } },
  { "leaf",  c:poly({ {33, 17}, {37, 10}, {43, 6}, {50, 6}, {48, 12}, {42, 17}, {36, 19} }), leaf, { gloss = false } },
  { "bean",  c:ellipse(30.5, 26, 10.5, 11), bean },
  { "front", c:rrect(11, 33, 52, 55, 2), "wood", { gloss = { 15, 36 } } },
}
-- leaf vein
c:line({ {37, 16}, {42, 11}, {47, 8} }, 1)
for _, q in ipairs({ {37, 16}, {38, 15}, {39, 14}, {40, 13}, {41, 12}, {42, 11}, {43, 10}, {44, 9}, {46, 8} }) do
  c:px(q[1], q[2], "#2e5a2c")
end
-- bean S-crease
c:paint({
  "..cc.",
  "...cc",
  "...cc",
  "..cc.",
  ".cc..",
  "cc...",
  "cc...",
  ".cc..",
}, 29, 18, { c = "#44281c" })
-- plank lines
c:fill(c:rect(13, 40, 50, 41), "#8a4f2a")
c:fill(c:rect(13, 47, 50, 48), "#8a4f2a")
-- end posts
c:fill(c:rect(19, 35, 19, 53), "#8a4f2a")
c:fill(c:rect(44, 35, 44, 53), "#8a4f2a")
-- nails
for _, q in ipairs({ {15, 36}, {47, 36}, {15, 50}, {47, 50} }) do
  c:paint({ "nn", "nn" }, q[1], q[2], { n = "#5e2f1e" })
end

local t = c:save(O .. "aseprite/ph/coffee-seed.aseprite", O .. "png/ph/coffee-seed.png")
print(GV.report(t))
