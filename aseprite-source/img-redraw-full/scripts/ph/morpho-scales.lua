local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local outer = c:poly({ {32, 7}, {33, 7}, {55, 20}, {51, 46}, {33, 57}, {32, 57}, {14, 46}, {10, 20} })
local inner = c:poly({ {32, 15}, {33, 15}, {46, 23}, {43, 40}, {33, 47}, {32, 47}, {22, 40}, {19, 23} })
local p = c:build{
  { "shield", outer, "petal", { gloss = { 17, 22 } } },
  { "panel", inner, GV.ramp("#b8452f"), { gloss = false } },
}
c:fill(c:line({ {32, 9}, {32, 54} }, 2):clip(outer), "#4a2c1a")
-- facet lines from inner corners to outer corners
local fl = "#f6b8cf"
c:fill(c:line({ {19, 23}, {12, 21} }, 1):clip(outer):cut(inner), fl)
c:fill(c:line({ {46, 23}, {52, 21} }, 1):clip(outer):cut(inner), "#b8452f")
c:fill(c:line({ {22, 40}, {16, 45} }, 1):clip(outer):cut(inner), "#b8452f")
c:fill(c:line({ {43, 40}, {49, 45} }, 1):clip(outer):cut(inner), "#b8452f")
for _, s in ipairs({ {26, 26}, {36, 32}, {27, 38} }) do
  c:fill(c:rect(s[1], s[2], s[1] + 1, s[2] + 1), "#f0d49a")
end
c:px(25, 25, "#fff1c8"); c:px(37, 34, "#fff1c8")
local t = c:save(O .. "aseprite/ph/morpho-scales.aseprite", O .. "png/ph/morpho-scales.png")
print(GV.report(t))
