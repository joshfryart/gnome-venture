local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local egg = c:ellipse(31.5, 30, 21, 18):add(c:ellipse(31.5, 38, 17, 15))
local shell = GV.ramp("#f6b8cf", { shade = "#e46a9b" })
c:build{ { "shell", egg, shell, { cres = 4 } } }
-- slit: slightly curved 3px line
c:fill(c:line({ {32, 17}, {31, 26}, {31, 36}, {32, 45}, {33, 51} }, 3), "#6b1b2c")
-- teeth
local T = "#dcb06a"
for i = 0, 4 do
  local y = 22 + i * 6
  local xs = (i < 2) and 0 or ((i == 4) and 1 or 0)
  c:fill(c:line({ {29 + xs, y}, {23 + xs, y - 2} }, 2), "#b8661a")
  c:fill(c:line({ {34 + xs, y}, {40 + xs, y - 2} }, 2), "#b8661a")
end
local t = c:save(O .. "aseprite/ph/cowrie-shell.aseprite", O .. "png/ph/cowrie-shell.png")
print(GV.report(t))
