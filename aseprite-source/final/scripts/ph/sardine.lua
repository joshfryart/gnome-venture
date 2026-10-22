local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- forked tail
local tail = c:poly({ {40, 29}, {57, 18}, {51, 33}, {57, 48}, {40, 38} })
-- fish body: lens with a pointed nose on the left
local body = c:ellipse(27, 33, 20, 10)
body:add(c:poly({ {5, 33}, {14, 25}, {14, 41} }))
body:cut(c:poly({ {0, 0}, {9, 0}, {9, 28}, {0, 33} }))
-- dorsal fin
local fin = c:poly({ {24, 25}, {30, 18}, {36, 19}, {35, 25} })
-- pale belly
local belly = body:copy():clip(c:ellipse(28, 42, 17, 6))

local p = c:build{
  { "tail", tail, "#f08a24" },
  { "fin", fin, "#e0501f", { flat = true } },
  { "body", body, "#f08a24" },
  { "belly", belly, "#f1ece0", { contact = false, gloss = false } },
}
-- gill arc
c:line({ {17, 26}, {19, 29}, {19, 35}, {17, 39} }, 2):each(function(x, y)
  if body:has(x, y) then c:px(x, y, "#b8452f") end
end)
-- back dots
for _, d in ipairs({ {25, 29}, {31, 28}, {37, 30} }) do
  c:fill(c:rect(d[1], d[2], d[1] + 1, d[2] + 1), "#e0501f")
end
-- tail rays
c:line({ {44, 32}, {52, 26} }, 1):each(function(x, y) if tail:has(x, y) and not body:has(x,y) then c:px(x, y, "#e0501f") end end)
c:line({ {44, 35}, {52, 41} }, 1):each(function(x, y) if tail:has(x, y) and not body:has(x,y) then c:px(x, y, "#e0501f") end end)
c:eye(11, 29, true)
c:paint({ "u.u", ".u." }, 8, 36, { u = "umber" })

local t = c:save(O .. "aseprite/ph/sardine.aseprite", O .. "png/ph/sardine.png")
print(GV.report(t))
