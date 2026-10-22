local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local tin = GV.ramp("#8b8f96")
local inner = GV.ramp("#5b6470")
local berryA = GV.ramp("#f5b030")
local berryB = GV.ramp("#e08a1a")
-- lid tilted back: a parallelogram leaning left, inside face showing
local lid = c:poly({ { 16, 9 }, { 50, 5 }, { 53, 28 }, { 13, 28 } })
local lidIn = c:poly({ { 19, 12 }, { 48, 9 }, { 50, 27 }, { 16, 27 } })
local p = c:build{
  { "lid", lid, tin, { gloss = false } },
}
c:part(lidIn, inner, { gloss = false, rim = false, bounce = false, contact = false, flat = true })
c:part(c:rect(46, 21, 50, 28), inner, { flat = true })
local body = c:rrect(11, 29, 52, 56, 3)
c:part(body, GV.ramp("#e8a317"))
-- berries: druplet clusters heaped over the rim
local pts = { { 18, 31, berryB }, { 46, 31, berryB }, { 25, 27, berryA }, { 39, 27, berryA }, { 32, 23, berryB }, { 32, 31, berryA } }
for i, b in ipairs(pts) do
  local m = c:ellipse(b[1], b[2], 5, 5):cut(c:rect(0, 37, 63, 63))
  c:part(m, b[3], { gloss = false, rim = true })
  c:px(b[1] - 2, b[2] - 2, "#fff1c8")
  c:px(b[1] + 1, b[2] + 1, "#7a3a14"); c:px(b[1] - 2, b[2] + 2, "#7a3a14")
end
-- leaf + stem
c:fill(c:rect(33, 17, 34, 20), "#2e5a2c")
c:part(c:poly({ { 34, 18 }, { 38, 13 }, { 45, 12 }, { 42, 17 } }), GV.ramp("#58a03e"), { flat = true })
-- label plate
local lab = c:rrect(20, 41, 44, 52, 3)
c:part(lab, GV.ramp("#f4f0e0"), { gloss = false })
c:fill(lab:edge(), "#e8a317")
c:paint({ ".o.o.", "o.o.o", ".o.o." }, 34, 45, { o = "#e8a317" })
c:paint({ "ll..", "llll" }, 26, 46, { l = "#58a03e" })
c:seam({ { 13, 37 }, { 50, 37 } })
c:button(22, 43)
local t = c:save(O .. "aseprite/ph/cloudberry-seed.aseprite", O .. "png/ph/cloudberry-seed.png")
print(GV.report(t))
