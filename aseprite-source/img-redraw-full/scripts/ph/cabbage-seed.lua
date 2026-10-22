local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local glass = GV.ramp("#c8ecdc", { rim = "#8fcbd8" })
local body = c:rrect(14, 22, 50, 56, 10)
local neck = c:rect(22, 15, 42, 23)
local cork = c:rrect(21, 6, 43, 15, 2)
local seeds = c:ellipse(32, 48, 15, 6):clip(c:rrect(16, 23, 48, 54, 8))
seeds:add(c:rect(17, 48, 47, 53)):clip(c:rrect(16, 23, 48, 54, 8))
local leaf = c:poly({ {32, 25}, {38, 28}, {42, 33}, {41, 38}, {37, 42}, {32, 44}, {27, 42}, {23, 38}, {22, 33}, {26, 28} })
c:build{
  { "body", body, glass, { gloss = { 18, 27 } } },
  { "neck", neck, glass, { gloss = false } },
  { "seeds", seeds, "#7a4a1f", { gloss = false, rim = false } },
  { "leaf", leaf, "moss", { gloss = { 27, 30 } } },
  { "cork", cork, "#d9a660", { gloss = { 24, 8 } } },
}
-- cork shade ring
for x = 22, 42 do c:px(x, 12, "#b07a45"); c:px(x, 13, "#b07a45") end
-- orange band around neck
for x = 22, 42 do c:px(x, 20, "#f08a24"); c:px(x, 21, "#f08a24") end
for x = 22, 42 do c:px(x, 19, "#f5a050") end
-- leaf veins
c:line({ {32, 28}, {32, 41} }, 2)
c:fill(c:line({ {32, 28}, {32, 41} }, 2), "#2f5a2a")
c:fill(c:line({ {26, 33}, {31, 37} }, 2), "#2f5a2a")
c:fill(c:line({ {38, 32}, {33, 36} }, 2), "#2f5a2a")
-- seed dots
for _, p in ipairs({ {20, 49}, {26, 51}, {33, 49}, {40, 51}, {44, 48}, {29, 46}, {37, 46} }) do
  c:fill(c:rect(p[1], p[2], p[1] + 1, p[2] + 1), "#c9a96e")
end
-- seam under cork
c:seam({ {22, 15}, {42, 15} })
local t = c:save(O .. "aseprite/ph/cabbage-seed.aseprite", O .. "png/ph/cabbage-seed.png")
print(GV.report(t))
