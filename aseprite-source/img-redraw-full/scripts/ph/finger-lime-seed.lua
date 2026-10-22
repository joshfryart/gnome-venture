local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local tab   = c:poly({ {44, 7}, {52, 18}, {38, 18} })
local body  = c:rrect(13, 14, 51, 57, 3)
local flap  = c:poly({ {13, 14}, {52, 14}, {52, 28}, {32, 32}, {13, 28} }):clip(body)
local win   = c:rrect(19, 34, 45, 53, 4)
local lime  = c:ellipse(32, 44, 7, 7)

c:build{
  { "tab",  tab,  GV.ramp("#4a8a3e"), { cres = 2 } },
  { "body", body, GV.ramp("#f1ece0"), { pale = true } },
  { "flap", flap, GV.ramp("#dcb06a") },
  { "win",  win,  GV.ramp("#f4f0e0"), { pale = true, gloss = false, cres = 2 } },
  { "lime", lime, "moss", { cres = 3 } },
}
-- stem and leaf on the lime
c:part(c:rect(31, 34, 32, 37), GV.ramp("#2e5a2c"), { flat = true })
c:part(c:poly({ {33, 35}, {37, 32}, {40, 32}, {37, 36}, {33, 36} }), GV.ramp("#58a03e"), { flat = true })
-- tiny dots
c:px(26, 55, "#8c4a1a"); c:px(32, 55, "#8c4a1a"); c:px(38, 55, "#8c4a1a")
-- seam on flap edge and button at the point
c:seam({ {15, 27}, {32, 30}, {50, 27} })
c:button(30, 28)

local t = c:save(O .. "aseprite/ph/finger-lime-seed.aseprite", O .. "png/ph/finger-lime-seed.png")
print(GV.report(t))
