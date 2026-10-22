local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local B = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local rim = c:ellipse(31.5, 45, 26, 9.5)
local well = c:ellipse(31.5, 43.5, 20, 6)
local mound = c:poly({ {13, 44}, {18, 36}, {24, 30}, {29, 25}, {34, 25}, {39, 30}, {45, 36}, {50, 44} })
mound:add(c:ellipse(31.5, 41, 18, 5))
local starPts = {}
for i = 0, 9 do
  local a = -math.pi / 2 + i * math.pi / 5
  local r = (i % 2 == 0) and 8 or 3.6
  starPts[#starPts + 1] = { 31.5 + r * math.cos(a), 14 + r * math.sin(a) }
end
local star = c:poly(starPts)
c:build{
  { "rim", rim, GV.ramp("#d6c9b6"), { cres = 3 } },
  { "well", well, "cream", { gloss = false, cres = 2 } },
  { "mound", mound, "moss" },
  { "vegA", c:ellipse(23.5, 37, 3.5), GV.ramp("#58a03e"), { cres = 2 } },
  { "vegB", c:ellipse(39.5, 35.5, 4), GV.ramp("#9cc85a"), { cres = 2 } },
  { "pea", c:ellipse(31.5, 29, 3), "gold", { cres = 2 } },
  { "star", star, "gold", { cres = 3 } },
}
-- spice flecks
c:px(28, 36, "#ae2a2a"); c:px(35, 40, "#ae2a2a"); c:px(20, 41, "#e8a317"); c:px(44, 40, "#e8a317")
c:seam({ {9, 47}, {14, 50}, {22, 52}, {31, 53}, {41, 52}, {49, 50}, {54, 47} })
local t = c:save(B .. "aseprite/ph/feast-spicepeak-thali.aseprite", B .. "png/ph/feast-spicepeak-thali.png")
print(GV.report(t))
