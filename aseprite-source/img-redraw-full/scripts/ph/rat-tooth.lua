local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local bone  = GV.ramp("#f1ece0")
local back  = GV.ramp("#e8c27a")
local bevel = GV.ramp("#c9a96e", { shade = "#9a6b3f" })

-- stout, slightly curved incisor: fat round root upper-left, tapering to a chisel tip lower-right
local body = c:ellipse(24, 18, 9, 8.5)
body:add(c:poly({ { 15.4, 21 }, { 23, 26 }, { 27.5, 37 }, { 31, 49 }, { 36, 53 },
                  { 45, 43 }, { 41, 33 }, { 35, 21 }, { 32, 12 } }))
-- chisel bevel face at the tip (flat cut)
local bev = body:copy():clip(c:poly({ { 40, 37 }, { 58, 42 }, { 40, 62 }, { 28, 47 } }))
-- dentine back strip along the right edge
local strip = body:copy():cut(body:shift(-3, 1)):cut(bev):cut(c:rect(0, 0, 63, 22))

c:build{
  { "tooth", body, bone, { gloss = { 18, 15 } } },
  { "back", strip, back, { flat = true, contour = false } },
  { "bevel", bev, bevel, { gloss = false, cres = 2, deep = 1 } },
}
-- enamel stripe down the lit front
c:fill(c:line({ { 21, 25 }, { 25, 33 }, { 28, 42 } }, 2), "#fff3c8")
-- pulp hole in the root
c:fill(c:ellipse(25, 16, 3, 2), "#7a4a1f")
c:px(24, 15, "#5e2f1e"); c:px(25, 15, "#5e2f1e"); c:px(26, 15, "#5e2f1e")
-- sharp chisel edge
c:fill(c:line({ { 36, 50 }, { 43, 43 } }, 1), "#fff3c8")

local t = c:save(O .. "aseprite/ph/rat-tooth.aseprite", O .. "png/ph/rat-tooth.png")
print(GV.report(t))
