local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

local pages = c:rrect(44, 11, 55, 53, 2)
local cover = c:rrect(12, 8, 49, 56, 4)
local spine = c:rrect(12, 8, 21, 56, 4)
local plate = c:rect(27, 18, 43, 29)

c:build{
  { "pages", pages, GV.ramp("#f8eed2"), { gloss = false } },
  { "cover", cover, GV.ramp("#c4302a"), { gloss = { 25, 12 } } },
  { "spine", spine, GV.ramp("#6b1b2c"), { gloss = false } },
  { "plate", plate, GV.ramp("#e8a317", { rim = "#f5cf6a" }) },
}
-- page lines on the edge strip
for y = 15, 50, 4 do c:px(53, y, "#e0c890"); c:px(54, y, "#e0c890") end
-- spine bands
c:part(c:rect(13, 17, 20, 19), GV.ramp("#d0862a"), { flat = true })
c:part(c:rect(13, 45, 20, 47), GV.ramp("#d0862a"), { flat = true })
-- seam beside the spine
c:seam({ { 23, 12 }, { 23, 52 } })

local t = c:save(O .. "aseprite/ico/ico-book-red.aseprite", O .. "png/ico/ico-book-red.png")
print(GV.report(t))
