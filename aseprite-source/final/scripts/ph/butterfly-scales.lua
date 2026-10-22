local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

-- upper wings: big lobes pointing up and out
local ul = c:poly({ {31, 30}, {22, 33}, {13, 30}, {10, 22}, {11, 14}, {17, 11}, {25, 14}, {31, 22} })
ul:add(c:ellipse(17, 18, 7, 6))
local ur = c:poly({ {33, 30}, {42, 33}, {51, 30}, {54, 22}, {53, 14}, {47, 11}, {39, 14}, {33, 22} })
ur:add(c:ellipse(47, 18, 7, 6))
-- lower wings: smaller rounded lobes
local ll = c:ellipse(23, 37, 9, 7):add(c:poly({ {31, 30}, {31, 44}, {24, 45} }))
local lr = c:ellipse(41, 37, 9, 7):add(c:poly({ {33, 30}, {40, 45}, {33, 44} }))

local lowR = GV.ramp("#c4507f")
local upR = GV.ramp("#e46a9b", { gloss = "#f6b8cf" })
local p = c:build{
  { "lowl", ll, lowR, { gloss = false } },
  { "lowr", lr, lowR, { gloss = false } },
  { "upl", ul, upR, { gloss = { 14, 15 } } },
  { "upr", ur, upR, { gloss = false } },
  { "body", c:rrect(30, 22, 34, 48, 2), "dusk", { gloss = false, bounce = false } },
}
-- antennae
c:part(c:line({ {31, 22}, {28, 10} }, 2), "#3e2f66", { flat = true })
c:part(c:line({ {33, 22}, {36, 10} }, 2), "#3e2f66", { flat = true })
c:part(c:rect(26, 7, 28, 9), "#3e2f66", { flat = true })
c:part(c:rect(36, 7, 38, 9), "#3e2f66", { flat = true })

-- wing spots: cream-pink diamonds
local sp = "#f6b8cf"
c:paint({ ".p.", "ppp", ".p." }, 19, 22, { p = sp })
c:paint({ ".p.", "ppp", ".p." }, 43, 22, { p = sp })
c:paint({ "pp", "pp" }, 21, 37, { p = sp })
c:paint({ "pp", "pp" }, 42, 37, { p = sp })

local t = c:save(O .. "aseprite/ph/butterfly-scales.aseprite", O .. "png/ph/butterfly-scales.png")
print(GV.report(t))
