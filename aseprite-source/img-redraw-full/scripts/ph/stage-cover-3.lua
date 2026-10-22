local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local soil = GV.ramp("#8c4a1a")
local dark = GV.ramp("#58a03e")
local parts = {
  { "soil", c:ellipse(31.5, 46, 22, 8), soil },
}
-- back row (lighter, higher) first, then front row (darker, lower)
local back = { {22.5, 32}, {40.5, 32} }
local front = { {13.5, 41}, {31.5, 40}, {49.5, 41} }
for i, p in ipairs(back) do
  parts[#parts+1] = { "b"..i, c:ellipse(p[1], p[2], 8, 7.5), "moss" }
end
for i, p in ipairs(front) do
  parts[#parts+1] = { "f"..i, c:ellipse(p[1], p[2], 8, 7.5):cut(c:rect(0, 49, 63, 63)), dark }
end
local P = c:build(parts)
-- leaf veins / gloss accents on light clumps
for _, p in ipairs(back) do c:px(math.floor(p[1]) - 3, p[2] - 4, "#c8d77a") end
c:ground(31.5, 54, 19, 1.5)
local t = c:save(O .. "aseprite/ph/stage-cover-3.aseprite", O .. "png/ph/stage-cover-3.png")
print(GV.report(t))
