local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local body = c:poly({ {19,18}, {45,18}, {52,44}, {12,44} }):add(c:rrect(12, 38, 51, 50, 5))
local rim = c:poly({ {22,12}, {42,12}, {46,16}, {46,21}, {18,21}, {18,16} })
local mound = c:ellipse(31.5, 31, 12, 10):add(c:ellipse(31.5, 38, 14, 4))
local p = c:build{
  { "body", body, GV.ramp("#a5663a") },
  { "rim", rim, GV.ramp("#dcb06a"), { gloss = false } },
  { "mound", mound, "stone", { gloss = { 24, 25 } } },
}
local plank = "#5e2f1e"
for _, y in ipairs({ 26, 36, 46 }) do
  c:fill(c:rect(12, y, 20, y):add(c:rect(43, y, 52, y)):clip(body):cut(mound), plank)
end
c:seam({ {19, 16}, {45, 16} })
c:fill(c:line({ {26,32}, {31,38}, {32,38}, {37,32} }, 2):clip(mound), "#6a6070")
for _, s in ipairs({ {27,26}, {35,28}, {29,40}, {37,37} }) do c:fill(c:rect(s[1], s[2], s[1]+1, s[2]+1), "#c9c5bc") end
local t = c:save(O .. "aseprite/ph/shell-meal.aseprite", O .. "png/ph/shell-meal.png")
print(GV.report(t))
