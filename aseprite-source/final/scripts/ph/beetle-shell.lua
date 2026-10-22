local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local shellR = GV.ramp("#7a5cc0", { rim = "#a894dc", shade = "#3e2f66", deep = "#291d4a" })
-- two halves, slightly asymmetric, split down the middle
local left  = c:poly({ {31,7}, {31,57}, {14,47}, {9,21} })
local right = c:poly({ {33,8}, {55,20}, {51,46}, {33,56} })
local shell = left:copy(); shell:add(right)
local p = c:build{
  { "left",  left,  shellR, { light = shell } },
  { "right", right, shellR, { light = shell, gloss = false } },
}
-- inner facet outline (nested), drawn as 1px ring per half
local facet = c:poly({ {32,15}, {46,23}, {43,41}, {32,48}, {21,41}, {18,23} })
local ring = facet:copy():cut(facet:shrink(2))
ring:cut(c:rect(30, 0, 34, 63))
ring:each(function(x, y) c:px(x, y, "#4e3a8a") end)
-- inner facet darker band on lower-right part
local inner = facet:shrink(1):cut(c:rect(30,0,34,63))
-- ridge arcs (scalloped)
local function scallop(x0, x1, y, col)
  for x = x0, x1 do
    local k = (x - x0) % 4
    local yy = (k == 0) and y or y - 1
    if shell:has(x, yy) and not c:rect(30,0,34,63):has(x,yy) then c:px(x, yy, col) end
  end
end
scallop(19, 29, 31, "#a894dc"); scallop(35, 45, 31, "#a894dc")
scallop(22, 29, 36, "#a894dc"); scallop(35, 42, 36, "#a894dc")
-- centre split
c:line({ {31.5, 7}, {31.5, 56} }, 2)
for y = 7, 57 do for x = 31, 32 do if shell:grow(1):has(x,y) then c:px(x, y, "#291d4a") end end end
local t = c:save(O .. "aseprite/ph/beetle-shell.aseprite", O .. "png/ph/beetle-shell.png")
print(GV.report(t))
