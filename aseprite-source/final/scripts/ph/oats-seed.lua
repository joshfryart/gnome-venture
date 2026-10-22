local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local tan = GV.ramp("#dcb06a")
local gold = GV.ramp("#f5cf6a")
local whole = c:rrect(12, 9, 51, 53, 2)
c:build{
  { "body",  c:rrect(12, 9, 51, 53, 2), "cream", { light = whole } },
  { "flap",  c:rrect(12, 9, 51, 21, 2), tan, { light = whole } },
  { "crimp", c:rect(12, 49, 51, 53):clip(whole), tan, { light = whole, gloss = false } },
}
-- crimp ticks
for x = 15, 49, 4 do for y = 50, 52 do c:px(x, y, "#b07a45") end end
-- leaf, stem, grains
c:part(c:line({ {21, 47}, {27, 41} }, 3), GV.ramp("#58a03e"), { flat = true, gloss = false })
c:part(c:rect(31, 28, 33, 48), "#2f5a2a", { flat = true, gloss = false })
local rows = { { 34, gold, tan }, { 40, tan, gold }, { 46, gold, tan } }
for _, r in ipairs(rows) do
  local y = r[1]
  c:part(c:line({ {29, y + 1}, {25, y - 3} }, 4), r[2], { flat = true, gloss = false })
  c:part(c:line({ {35, y + 1}, {39, y - 3} }, 4), r[3], { flat = true, gloss = false })
end
c:part(c:ellipse(32, 25.5, 2.5, 4), gold, { flat = true, gloss = false })
c:seam({ {13, 21}, {50, 21} })
c:button(30, 19)
local t = c:save(O .. "aseprite/ph/oats-seed.aseprite", O .. "png/ph/oats-seed.png")
print(GV.report(t))
