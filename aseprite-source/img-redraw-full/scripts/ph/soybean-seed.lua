local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- slumped pouch with a flat bottom
local pouch = c:ellipse(32, 39, 20, 17):cut(c:rect(0, 54, 63, 63))
pouch:add(c:rrect(16, 46, 48, 53, 4))
-- frilly gathered top: neck with scallops
local top = c:rrect(22, 12, 42, 26, 3)
top:cut(c:ellipse(25.5, 11, 1.5, 2)); top:cut(c:ellipse(32, 11, 1.5, 2)); top:cut(c:ellipse(38.5, 11, 1.5, 2))
top:add(c:poly({ {20, 10}, {25, 14}, {22, 18} })); top:add(c:poly({ {44, 10}, {42, 18}, {39, 14} }))
local cord = c:rect(21, 24, 43, 27)
local tails = c:line({ {30, 27}, {27, 37} }, 2):add(c:line({ {36, 27}, {40, 36} }, 2))
local knotL = c:rect(26, 36, 28, 38); local knotR = c:rect(39, 35, 41, 37)
tails:add(knotL); tails:add(knotR)
-- curved bean pod
local pod = c:line({ {20, 46}, {26, 44}, {33, 41}, {39, 38}, {45, 34} }, 8)
local pstem = c:line({ {18, 48}, {15, 51} }, 3)

local p = c:build{
  { "pouch", pouch, "#e9b98a", { stitch = { side = "lit" } } },
  { "top",   top,   "#e9b98a" },
  { "cord",  cord,  "#8c4a1a", { gloss = false } },
  { "tails", tails, "#8c4a1a", { flat = true } },
  { "pstem", pstem, "#2e5a2c", { flat = true } },
  { "pod",   pod,   "#b07a45", { gloss = { 23, 43 } } },
}
-- gathered folds on the neck
c:fill(c:rect(27, 16, 27, 22), "#c47a52"); c:fill(c:rect(32, 15, 32, 22), "#c47a52"); c:fill(c:rect(37, 16, 37, 22), "#c47a52")
-- beans
for _, b in ipairs({ {27, 43}, {33, 40.5}, {39, 37.5} }) do
  c:fill(c:ellipse(b[1], b[2], 3, 2.5), "#44281c")
  c:px(math.floor(b[1]) - 1, math.floor(b[2]) - 1, "#7a4a3a")
end
c:button(30, 24)

local t = c:save(O .. "aseprite/ph/soybean-seed.aseprite", O .. "png/ph/soybean-seed.png")
print(GV.report(t))
