-- extras/icon-16: hand-drawn 16x16 app icon (favicon size), not a downscale.
-- Green badge with a light ring, red gnome hat with a gold seam, cream beard, salmon nose.
-- Shapes are placed pixel by pixel; 1 px selective outline. Writes png/icon-16.png, aseprite/icon-16.aseprite.
local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/extras-pixel/"
local c = GV.canvas{ w = 16, h = 16, mode = "scene", ol = 1, olx = 0, cres = 2, deep = 0 }

local disc = c:ellipse(7.5, 7.5, 6.5)
c:part(disc, "leaf", { gloss = false, bounce = false })
-- light ring, one px inside the outline, lit (upper-left) side brighter
c:ellipse(7.5, 7.5, 6.5):cut(c:ellipse(7.5, 7.5, 5.5)):each(function(x, y)
  c:px(x, y, (x + y < 16) and GV.R.moss.rim or GV.R.moss.base)
end)

local hat = c:ascii({
  "..##..",  -- y 2
  "..##..",
  ".####.",
  ".####.",
  "######",
  "######",  -- y 7
}, 5, 2)
hat:add(c:rect(4, 8, 11, 8))           -- brim row
local beard = c:ascii({
  "############",  -- y 9
  "############",
  "..########..",
  "...######...",  -- y 12
}, 2, 9)
local nose = c:ascii({ ".##.", "####", ".##." }, 6, 8)
c:outline(hat:copy():add(beard):add(nose))

-- paint by hand with ramp colours (legend letters)
local R, Cr, N = GV.R.red, GV.R.cream, GV.ramp("#e9a08c")
local L = {
  E = R.rim, R = R.base, r = R.shade, D = R.deep, y = GV.C.gold,
  C = Cr.base, c = Cr.shade, W = Cr.gloss, N = N.base, n = GV.R.skin.shade, w = N.gloss, k = "#2a1a10",
}
c:paint({
  "..Er..",  -- y 2
  "..yr..",
  ".EyRr.",
  ".ERRr.",
  "ERyRRr",
  "ERyRRr",  -- y 7
}, 5, 2, L)
c:paint({ "DDDDDDDD" }, 4, 8, L)
c:paint({
  "WCCCCCCCCCCc",  -- y 9
  "CCCCCCCCCCcc",
  "..CCCCCCcc..",
  "...cCCCcc...",
}, 2, 9, L)
c:paint({ ".NN.", "NNNn", ".Nn." }, 6, 8, L)

local t = c:save(O .. "aseprite/icon-16.aseprite", O .. "png/icon-16.png")
print(GV.report(t))
