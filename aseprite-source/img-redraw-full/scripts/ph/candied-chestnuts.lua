-- ph/candied-chestnuts (Pantry candied): round bentwood box, lid leaning at its side with a big chestnut-burr emblem, glazed chestnuts in gold foil cups
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "candied-chestnuts"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- lid leaning against the right side, behind the box, turned more to face us, carrying a big spiky
-- chestnut burr (green husk split open on a brown nut) that fills most of the lid face
local lid = c:ellipse(46, 37, 10, 14)
c:part(lid, "#c9a96e", { gloss = false })
c:fill(lid:edge():cut(c:rect(0, 37, 63, 63)):cut(c:rect(47, 0, 63, 63)), "#e8d8b0")
c:fill(c:ellipse(46, 37, 8, 12):edge(), "#9a6b3f")
c:paint({
  "...k..k..k...",
  "k..kk.k.kk..k",
  ".kkgggggggkk.",
  "..gGgggggggk.",
  "kkgGggnnnggkk",
  "..ggnnNnnnggk",
  ".kggnNnnnsggk",
  "kkggnnnnnsgkk",
  "..ggnnnnssgk.",
  ".kkggsssssgk.",
  "...kgggggkkk.",
  "k.kk.k.k.kk.k",
  "....k...k....",
}, 40, 31, { k = "#2f5a2a", g = "#7ab55c", G = "#c8d77a", n = "#7a4a1f", N = "#c9a96e", s = "#4e2a16" })
-- chestnuts in foil cups (behind the box rim)
local function nut(x)
  c:part(c:ellipse(x, 26, 4.5, 5), "#7a4a1f", { gloss = false, cres = 2 })
  c:px(x - 2, 23, "#c9a96e"); c:px(x - 3, 24, "#c9a96e"); c:px(x - 2, 24, "#ecc58a")
  c:fill(c:rect(x - 1, 21, x, 22), "#3d2a1c"); c:px(x + 1, 27, "#3d2a1c"); c:px(x + 2, 28, "#3d2a1c")
end
nut(13); nut(22); nut(31)
local function cup(x)
  c:part(c:poly({ {x - 5, 29}, {x + 6, 29}, {x + 5, 34}, {x - 4, 34} }), "gold", { gloss = false, cres = 2, deep = 0 })
  for i = -3, 3, 2 do c:px(x + i, 31, "#b07a10"); c:px(x + i, 32, "#b07a10") end
end
cup(13); cup(22); cup(31)
-- bentwood box with band lines, lap seam and ribbon
local box = c:rrect(6, 32, 37, 55, 4)
c:part(box, "#e8d8b0", { gloss = false })
for y = 36, 52, 4 do c:fill(c:rect(8, y, 35, y):clip(box), "#c9a96e") end
c:fill(c:rect(26, 33, 26, 54), "#9a6b3f"); c:fill(c:rect(27, 33, 27, 54), "#f4e8c8")
for y = 34, 53, 3 do c:px(28, y, "#9a6b3f") end
c:part(c:rect(7, 43, 36, 45), "#a8241f", { flat = true, contact = false })
c:fill(c:rect(7, 45, 36, 45), "#6b1b2c")
c:seam({ {7, 33}, {36, 33} })
c:ground(31, 56, 24, 1.5)
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
