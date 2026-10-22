local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- one smooth wide heap with a soft peak, flat base at y 48
local mound = c:poly({ { 7, 49 }, { 11, 44 }, { 17, 38 }, { 23, 30 }, { 28, 25 }, { 36, 25 }, { 41, 30 },
  { 47, 38 }, { 53, 44 }, { 57, 49 } })
mound:add(c:ellipse(31.5, 27, 5, 3))
mound = mound:grow(1):shrink(1):cut(c:rect(0, 49, 63, 200))
c:build{
  { "salt", mound, GV.ramp("#f1ece0"), { gloss = { 24, 30 } } },
}
-- lumpy ridge lines across the heap
c:fill(c:line({ { 13, 44 }, { 18, 41 }, { 24, 40 } }, 1), "#d6c9b6")
c:fill(c:line({ { 39, 39 }, { 45, 40 }, { 50, 43 } }, 1), "#d6c9b6")
c:fill(c:line({ { 26, 46 }, { 31, 44 }, { 36, 46 } }, 1), "#d6c9b6")
-- three crystal glints: small faceted diamonds
local function crystal(x, y)
  c:paint({ "..a..", ".awb.", "awWwb", ".bwb.", "..b.." }, x - 2, y - 2,
    { a = "#c9b393", b = "#a08a6a", w = "#fff3c8", W = "#ffffff" })
end
crystal(25, 34); crystal(39, 31); crystal(33, 40)
c:ground(31.5, 50, 22, 1.5)
local t = c:save(O .. "aseprite/ph/sea-salt.aseprite", O .. "png/ph/sea-salt.png")
print(GV.report(t))
