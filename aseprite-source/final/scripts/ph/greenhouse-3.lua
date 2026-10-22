local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local glass = c:poly{ {10,51}, {10,33}, {18,17}, {47,17}, {55,33}, {55,51} }
local plinth = c:rrect(9, 46, 55, 52, 2)
local plants = c:mask()
for _, x in ipairs{ 15, 20, 26, 32, 38, 44, 49 } do plants:add(c:ellipse(x, 42, 3.5, 3)) end
plants:add(c:rect(12, 42, 52, 46)):clip(glass:shrink(2)):cut(c:rect(0, 47, 63, 63))
local pole = c:rect(31, 11, 32, 17)
local flag = c:poly{ {33,11}, {42,11}, {40,13}, {42,16}, {33,16} }
local lantern = c:rrect(13, 28, 17, 34, 1)

c:build{
  { "glass", glass, GV.ramp("#a9d6ea", { gloss = "#e4f6f0", dot = "#f6fcf4", rim = "#c8ecdc" }), { gloss = { 25, 22 } } },
  { "plants", plants, "moss", { gloss = false, contour = false } },
  { "plinth", plinth, GV.ramp("#968f96") },
  { "pole", pole, GV.ramp("#44281c"), { flat = true } },
  { "flag", flag, GV.ramp("#d6322b"), { flat = true } },
}
-- lantern glow inside the glass
local glow = c:ellipse(15, 31, 5.5, 5.5):clip(glass:shrink(2)):cut(plants)
c:fill(glow, "#dcecc4")
-- frame ribs (white) over glass
local frame = glass:copy():cut(glass:shrink(2)):cut(c:rect(0, 46, 63, 63))
c:fill(frame, "#f4f0e0")
local rib = c:line({ {12, 33}, {53, 33} }, 1)
rib:add(c:line({ {22, 18}, {22, 32} }, 1)):add(c:line({ {32, 18}, {32, 32} }, 1)):add(c:line({ {42, 18}, {42, 32} }, 1))
rib:add(c:line({ {18, 19}, {22, 33} }, 1)):add(c:line({ {46, 19}, {42, 33} }, 1))
c:fill(rib:cut(plants), "#f4f0e0")
-- tomatoes
c:part(c:ellipse(20.5, 42.5, 2, 2), GV.ramp("#d6322b"), { flat = true })
c:part(c:ellipse(38.5, 41.5, 2, 2), GV.ramp("#d6322b"), { flat = true })
c:part(c:ellipse(46.5, 43.5, 1.5, 1.5), GV.ramp("#d6322b"), { flat = true })
-- lantern
c:paint({ "u", "u" }, 15, 26, { u = "#4a2c1a" })
c:part(lantern, "gold", { gloss = { 14, 29 } })
c:paint({ "ccc" }, 14, 31, { c = "#fff1c8" })
-- sparkle
c:paint({ "...y...", "...y...", "..yYy..", "yyYWYyy", "..yYy..", "...y...", "...y..." }, 44, 21,
        { y = "#f5cf6a", Y = "#ffe28a", W = "#fff1c8" })
-- gold base trim
c:fill(c:line({ { 11, 51 }, { 53, 51 } }, 1), "#e8a317")
c:ground(32, 54, 22, 2, "#6a4528")
local t = c:save(D .. "img-redraw-full/aseprite/ph/greenhouse-3.aseprite",
                 D .. "img-redraw-full/png/ph/greenhouse-3.png")
print(GV.report(t))
