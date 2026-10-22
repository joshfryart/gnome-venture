local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local shell = c:poly({ {32, 7}, {54, 19}, {50, 47}, {32, 57}, {14, 47}, {10, 19} })
local inner = c:poly({ {32, 15}, {46, 23}, {43, 41}, {32, 48}, {21, 41}, {18, 23} })
local notch = c:poly({ {28, 9}, {36, 9}, {35, 14}, {29, 14} })

local p = c:build{
  { "shell", shell, "moss" },
  { "inner", inner, "#4a8a3e", { light = shell, gloss = { 24, 26 } } },
  { "notch", notch, "#6a9a3a", { flat = true } },
}
-- centre split
c:fill(c:rect(31, 14, 32, 54), "#2f5a2a")
-- facet lines from inner corners to outer corners
local F = "#4a8a3e"
for _, l in ipairs({ { {18, 23}, {12, 20} }, { {46, 23}, {52, 20} }, { {21, 41}, {16, 45} }, { {43, 41}, {48, 45} } }) do
  c:line(l, 1):each(function(x, y) if shell:has(x, y) and not inner:has(x, y) then c:px(x, y, F) end end)
end
-- gold flecks (diamonds)
c:paint({ ".g.", "ggg", ".g." }, 22, 30, { g = "#f5cf6a" })
c:paint({ ".g.", "ggg", ".g." }, 38, 30, { g = "#f5cf6a" })
c:seam({ {32, 16}, {32, 50} }, { gap = "#2f5a2a" })

local t = c:save(O .. "aseprite/ph/scarab-shell.aseprite", O .. "png/ph/scarab-shell.png")
print(GV.report(t))
