-- ico-piece: one jigsaw piece with a scrap of picture on its face (warm sky, a green hill, a red poppy).
-- Not the flat blue ico-puzzle: tabs top and left, blanks right and bottom, printed two-tone face.
-- Run: python3 aseprite-source/tools/aseshim.py aseprite-source/final/scripts/ico/ico-piece.lua
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local PNG = "/home/user/gnome-venture/game/assets/img/ico/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local X, Y = 5, 4 -- shift to centre the silhouette

-- body 31x31; tabs (r 6) out on the top and left, round sockets (r 5.5, 7 px mouth) cut in from the right and bottom
local body = c:rect(17+X, 18+Y, 47+X, 48+Y)
body:add(c:ellipse(32+X, 11+Y, 6)):add(c:rect(29+X, 14+Y, 35+X, 18+Y))       -- top tab on a neck
body:add(c:ellipse(10+X, 33+Y, 6)):add(c:rect(13+X, 30+Y, 17+X, 36+Y))       -- left tab
body:cut(c:ellipse(42.5+X, 33+Y, 5.5)):cut(c:rect(44+X, 30+Y, 47+X, 36+Y))   -- right socket
body:cut(c:ellipse(32+X, 43.5+Y, 5.5)):cut(c:rect(29+X, 46+Y, 35+X, 48+Y))   -- bottom socket

-- the printed face: pale day sky above, a rolling hill below (its own part, so it gets a contour line)
local hill = c:ellipse(38+X, 58+Y, 33, 24):clip(body)
c:build{
  { "sky",  body, GV.ramp("#7cc0e2", { shade = "#4f8fc0" }), { gloss = { 20+X, 22+Y }, cres = 4 } },
  { "hill", hill, "moss", { gloss = false, light = body, cres = 4 } },
}
-- a gold sun on the sky and a red poppy on the hill (flat bits, 3 px+)
c:paint({ ".ss.", "ssss", "ssss", ".ss." }, 34+X, 23+Y, { s = "#f5cf6a" })
c:paint({ ".r.", "rrr", ".r." }, 20+X, 42+Y, { r = "#d8453a" })
c:px(21+X, 43+Y, "#f5cf6a")
local t = c:save(D .. "final/aseprite/ico/ico-piece.aseprite", PNG .. "ico-piece.png")
print("ico-piece", GV.report(t))
