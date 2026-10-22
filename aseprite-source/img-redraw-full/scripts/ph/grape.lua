local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local lt = GV.ramp("#7a5cc0", { shade = "#4e3a8a", deep = "#291d4a" })
local dk = GV.ramp("#4e3a8a", { shade = "#3e2f66", deep = "#291d4a" })
local leafR = GV.ramp("#58a03e")
local stem = c:line({ {31, 10}, {32, 16}, {32, 24} }, 3)
local tendril = c:line({ {34, 19}, {38, 17}, {42, 17}, {45, 19}, {45, 22}, {42, 23}, {41, 21} }, 2)
local leaf = c:poly({ {33, 13}, {36, 8}, {41, 5}, {48, 4}, {47, 9}, {43, 13}, {37, 15} })
local parts = {
  { "stem", stem, "moss", { flat = true } },
  { "tendril", tendril, "moss", { flat = true } },
  { "leaf", leaf, leafR },
}
local rows = {
  { {21.5, 30}, {32, 29}, {42.5, 30}, lt },
  { {26.5, 40}, {37.5, 40}, dk },
  { {32, 50.5}, lt },
}
for ri, row in ipairs(rows) do
  local ramp = row[#row]
  for i = 1, #row - 1 do
    local b = row[i]
    parts[#parts + 1] = { "b" .. ri .. i, c:ellipse(b[1], b[2], 7, 7), ramp, { gloss = { math.floor(b[1]) - 4, math.floor(b[2]) - 4 }, cres = 3, deep = 1 } }
  end
end
c:build(parts)
c:fill(c:line({ {36, 13}, {41, 9}, {46, 6} }, 1), leafR.shade)
local t = c:save(O .. "aseprite/ph/grape.aseprite", O .. "png/ph/grape.png")
print(GV.report(t))
