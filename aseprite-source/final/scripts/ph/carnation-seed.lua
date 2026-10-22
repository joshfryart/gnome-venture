local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local body = c:rrect(11, 14, 53, 54, 2)
local flap = c:poly({{11,14},{54,14},{32.5,31}})
local win = c:rrect(18, 33, 46, 50, 4)
local seed = c:ellipse(32, 43, 5.5, 5)
c:build{
  { "body", body, "cream" },
  { "flap", flap, GV.ramp("#e8dcc0"), { light = body } },
  { "window", win, GV.ramp("#e46a9b"), { gloss = false } },
}
c:part(c:rrect(20, 35, 44, 48, 3), GV.ramp("#f4f0e0"), { gloss = false, contact = false, contour = false, flat = true })
c:part(seed, "petal", { gloss = { 29, 40 } })
c:part(c:rect(31, 34, 32, 37), GV.ramp("#58a03e"), { flat = true })
c:part(c:ellipse(35.5, 35, 2.5, 1.5), GV.ramp("#58a03e"), { flat = true })
c:seam({ {12, 15}, {32, 30}, {52, 15} })
c:button(30, 27)
c:paint({ "dd....dd....dd", "dd....dd....dd" }, 25, 51, { d = "#8c4a1a" })
local t = c:save(O .. "aseprite/ph/carnation-seed.aseprite", O .. "png/ph/carnation-seed.png")
print(GV.report(t))
