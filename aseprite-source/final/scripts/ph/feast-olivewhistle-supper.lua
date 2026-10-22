local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local plate = GV.ramp("#d6c9b6")
local pale = GV.ramp("#f4f0e0")
-- platter
local rim = c:ellipse(31.5, 45, 25, 9)
local p = c:part(rim, plate, { gloss = false })
local well = c:ellipse(31.5, 43, 20, 6)
c:part(well, pale, { gloss = false, cres = 2, deep = 1 })
-- green mound: dome
local mound = c:ellipse(31.5, 36, 14, 12):cut(c:rect(0, 44, 63, 63))
mound:add(c:rrect(16, 36, 47, 44, 4))
c:part(mound, GV.ramp("#58a03e"))
-- leaf scallops on the mound
c:seam({ { 20, 40 }, { 26, 37 }, { 32, 39 }, { 38, 36 }, { 44, 40 } }, { gap = "#3f7a2e" })
-- olives
c:part(c:ellipse(23, 36, 3.5, 3.5), GV.ramp("#2e5a2c"), { gloss = { 21, 34 } })
c:part(c:ellipse(40, 34, 4, 4), "moss", { gloss = { 38, 32 } })
-- golden fruit
c:part(c:ellipse(31.5, 29, 3.5, 3.5), "gold", { gloss = { 30, 27 } })
-- star
local pts = {}
local scx, scy = 31.5, 16.5
for i = 0, 9 do
  local a = math.rad(-90 + i * 36)
  local r = (i % 2 == 0) and 10 or 4.5
  pts[#pts + 1] = { scx + r * math.cos(a), scy + r * math.sin(a) + 1 }
end
c:part(c:poly(pts), "gold", { gloss = { 29, 12 } })
c:stitch(well)
c:ground(31.5, 55, 18, 1.5)
local t = c:save(O .. "aseprite/ph/feast-olivewhistle-supper.aseprite", O .. "png/ph/feast-olivewhistle-supper.png")
print(GV.report(t))
