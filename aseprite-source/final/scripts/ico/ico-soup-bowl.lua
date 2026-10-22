local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-hybrid/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local bowlR = GV.ramp("#6a6070")
local rimR  = GV.ramp("#968f96")
-- steam: two S-curls
local s1 = c:line({ {25,21},{23,19},{23,17},{25,15},{25,13},{23,11},{23,10} }, 3)
local s2 = c:line({ {39,21},{37,19},{37,17},{39,15},{39,13},{37,11},{37,10} }, 3)
-- bowl body: flat top, half-ellipse bottom
local body = c:ellipse(31.5, 30, 17.5, 20):cut(c:rect(0, 0, 63, 29))
local foot = c:rrect(24, 47, 39, 51, 1)
local hl = c:rrect(10, 34, 16, 40, 2)
local hr = c:rrect(47, 34, 53, 40, 2)
local rim = c:rrect(12, 26, 51, 32, 3)
local soup = c:ellipse(31.5, 26, 17.5, 3):cut(c:rect(0, 27, 63, 63))
local p = c:build{
  { "steamL", s1, rimR, { flat = true } },
  { "steamR", s2, rimR, { flat = true } },
  { "soup", soup, GV.ramp("#e0501f"), { flat = true } },
  { "hl", hl, bowlR },
  { "hr", hr, bowlR },
  { "foot", foot, bowlR },
  { "body", body, bowlR },
  { "rim", rim, rimR },
}
c:seam({ {15, 29}, {48, 29} })
local t = c:save(O .. "aseprite/ico/ico-soup-bowl.aseprite", O .. "png/ico/ico-soup-bowl.png")
print(GV.report(t))
