local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- slumped belly, narrower neck, leaning a touch right
local sack = c:ellipse(32.5, 43, 19, 13)
sack:add(c:poly({ {22, 24}, {43, 24}, {50, 40}, {14, 40} }))
sack:add(c:rrect(14, 38, 52, 56, 8))
local top = c:poly({ {22, 26}, {43, 26}, {48, 11}, {41, 16}, {33, 9}, {25, 16}, {16, 11} })
local twine = c:rrect(20, 22, 45, 25, 1)

local burlap = GV.ramp("#c9a96e", { shade = "#9a6b3f" })
local p = c:build{
  { "top", top, burlap },
  { "sack", sack, burlap, { stitch = { side = "lit" } } },
  { "twine", twine, "#7a4a1f", { flat = true } },
}
-- twine knot and tails
c:part(c:rrect(30, 21, 34, 26, 1), "#7a4a1f", { flat = true })
c:line({ {31, 27}, {27, 31} }, 2)
c:fill(c:line({ {31, 27}, {27, 31} }, 2), "#7a4a1f")
c:fill(c:line({ {34, 27}, {38, 31} }, 2), "#7a4a1f")
c:px(31, 22, "#b07a45"); c:px(21, 23, "#b07a45"); c:px(25, 23, "#b07a45"); c:px(38, 23, "#b07a45")

-- fringe lines in the flared top
c:fill(c:rect(25, 18, 25, 21), "#9a6b3f")
c:fill(c:rect(33, 13, 33, 21), "#9a6b3f")
c:fill(c:rect(41, 19, 41, 21), "#9a6b3f")

-- seam down the left
c:seam({ {18, 30}, {17, 50} })

-- stamp: cream disc, green ring, bulb
c:fill(c:ellipse(33, 43, 9, 9), "#58a03e")
c:fill(c:ellipse(33, 43, 7, 7), "#f1ece0")
c:fill(c:ellipse(33, 44, 4.5, 4.5), "#7ab55c")
c:fill(c:ellipse(34, 45, 4.5, 4.5):cut(c:ellipse(32.5, 43.5, 4.5, 4.5)):clip(c:ellipse(33, 44, 4.5, 4.5)), "#4a8a3e")
c:px(31, 42, "#c8d77a"); c:px(32, 41, "#c8d77a")
-- sprout
c:fill(c:rect(32, 37, 33, 40), "#2e5a2c")
c:paint({ ".ll", "lll", "ll." }, 34, 36, { l = "#58a03e" })

c:ground(33, 57, 17, 1.5)
local t = c:save(O .. "aseprite/ph/tuberose-seed.aseprite", O .. "png/ph/tuberose-seed.png")
print(GV.report(t))
