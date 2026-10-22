local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local cloth = GV.ramp("#3f93b2")
-- gathered frilled top
local top = c:poly({ {25, 22}, {39, 22}, {45, 11}, {19, 11} })
for _, x in ipairs({ 23, 28, 33, 38 }) do top:cut(c:rect(x, 11, x + 1, 12)) end
-- bulging sack
local bag = c:ellipse(31.5, 37, 19, 15)
c:build{
  { "top", top, cloth },
  { "bag", bag, cloth, { stitch = { side = "lit" } } },
}
-- string tie and dangling ends
c:part(c:rrect(23, 20, 40, 23, 1), "gold")
c:part(c:line({ {24, 23}, {22, 28} }, 2), "gold", { flat = true })
c:part(c:line({ {39, 23}, {41, 28} }, 2), "gold", { flat = true })
-- edelweiss: pale star of petals
local fl = c:ellipse(31.5, 38, 3, 3)
for i = 0, 5 do
  local a = i * math.pi / 3 - math.pi / 2
  fl:add(c:ellipse(31.5 + 5 * math.cos(a), 38 + 5 * math.sin(a), 2, 2))
end
c:part(fl, "#f4f0e0", { contour = "#4a2c1a", gloss = false })
c:fill(c:rect(31, 37, 32, 38), "#e8a317")
c:part(c:ellipse(37, 32, 2.5, 1.5), "#58a03e", { flat = true })
-- dots
c:fill(c:rect(25, 46, 26, 47), "#8c4a1a")
c:fill(c:rect(31, 47, 32, 48), "#8c4a1a")
c:fill(c:rect(37, 46, 38, 47), "#8c4a1a")
c:ground(31.5, 52, 14, 1.5)
local t = c:save(O .. "aseprite/ph/edelweiss-seed.aseprite", O .. "png/ph/edelweiss-seed.png")
print(GV.report(t))
