-- ph/candied-chestnuts (Pantry candied): round bentwood box, lid leaning at its side, glazed chestnuts in gold foil cups
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "candied-chestnuts"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- lid leaning against the right side, behind the box: rim disc with a chestnut burr
local lid = c:ellipse(48, 40, 8, 14)
c:part(lid, "#c9a96e", { gloss = false })
c:fill(c:ellipse(48, 40, 8, 14):edge():cut(c:rect(0, 0, 63, 40)), "#e8d8b0")
c:fill(c:ellipse(49, 40, 5.5, 11):edge(), "#9a6b3f")
c:paint({
  "..k.k.k..",
  "k.ggggg.k",
  ".gGgggggk",
  "kgggggggk",
  ".gggggggk",
  "kgggggggk",
  ".ggggggg.",
  "k.ggggg.k",
  "..k.k.k..",
}, 45, 36, { g = "#4f9a45", G = "#c8d77a", k = "#2f5a2a" })
-- chestnuts in foil cups (behind the box rim)
local function nut(x)
  c:part(c:ellipse(x, 26, 5, 5), "#7a4a1f", { gloss = false, cres = 2 })
  c:px(x - 2, 23, "#c9a96e"); c:px(x - 3, 24, "#c9a96e"); c:px(x - 2, 24, "#ecc58a")
  c:fill(c:rect(x - 1, 21, x, 22), "#3d2a1c"); c:px(x + 1, 27, "#3d2a1c"); c:px(x + 2, 28, "#3d2a1c")
end
nut(14); nut(24); nut(34)
local function cup(x)
  c:part(c:poly({ {x - 6, 29}, {x + 6, 29}, {x + 5, 34}, {x - 5, 34} }), "gold", { gloss = false, cres = 2, deep = 0 })
  for i = -4, 4, 2 do c:px(x + i, 31, "#b07a10"); c:px(x + i, 32, "#b07a10") end
end
cup(14); cup(24); cup(34)
-- bentwood box with band lines, lap seam and ribbon
local box = c:rrect(7, 32, 41, 55, 4)
c:part(box, "#e8d8b0", { gloss = false })
for y = 36, 52, 4 do c:fill(c:rect(9, y, 39, y):clip(box), "#c9a96e") end
c:fill(c:rect(28, 33, 28, 54), "#9a6b3f"); c:fill(c:rect(29, 33, 29, 54), "#f4e8c8")
for y = 34, 53, 3 do c:px(30, y, "#9a6b3f") end
c:part(c:rect(8, 43, 40, 45), "#a8241f", { flat = true, contact = false })
c:fill(c:rect(8, 45, 40, 45), "#6b1b2c")
c:seam({ {8, 33}, {40, 33} })
c:ground(30, 56, 22, 1.5)
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
