-- ph/raisins (Pantry dried): twisted kraft paper cornet, tip down, heaped with dark raisins, grape bunch stamp
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "raisins"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local cone = c:poly({ {13, 24}, {52, 24}, {33, 57} })
c:part(cone, "#c9a96e", { gloss = { 19, 28 } })
-- folded paper: the right face is a shade darker, split by the fold seam
c:fill(c:poly({ {31, 25}, {50, 25}, {33, 54} }):cut(c:poly({ {48, 25}, {52, 25}, {34, 57} })), "#b8955a")
c:fill(c:line({ {30, 25}, {32, 54} }, 1), "#9a6b3f")
-- mouth: dark inside behind the heap
c:part(c:ellipse(32.5, 23, 19, 4), "#d8b97e", { gloss = false, contact = false })
c:fill(c:ellipse(32.5, 22, 16, 2), "#5e2f1e")
-- raisin heap, back to front: wrinkled near-black pearls
local function raisin(x, y)
  c:part(c:ellipse(x, y, 3, 3), "#4e2a3a", { gloss = false, cres = 2, deep = 0 })
  c:px(x - 1, y - 1, "#8a5a6a"); c:px(x + 1, y, "#6a3a4a"); c:px(x - 1, y + 1, "#6a3a4a")
end
for _, p in ipairs({ {32, 11}, {25, 14}, {39, 14}, {19, 18}, {45, 18}, {29, 17}, {36, 17}, {24, 21}, {32, 21}, {40, 21} }) do raisin(p[1], p[2]) end
-- front lip of the cornet rolled over
local lip = c:ellipse(32.5, 24, 20, 3.5):cut(c:rect(0, 0, 63, 24))
c:part(lip, "#d8b97e", { gloss = false })
c:seam({ {15, 25}, {50, 25} })
-- twist tie
c:fill(c:rect(21, 32, 44, 32), "#8a5a2f"); c:fill(c:rect(21, 33, 44, 33), "#5e2f1e")
c:paint({ "t.t", ".t.", "t.t" }, 44, 31, { t = "#8a5a2f" })
-- stamp: grape bunch (six berries in a triangle), stem and leaf
c:paint({
  "....s.ll.",
  "....sll..",
  "..ggg.ggg",
  ".gGgggGgg",
  ".ggggggggd",
  "..gggggd.",
  "...gGgg..",
  "...ggggd.",
  "....ggd..",
  ".....d...",
}, 28, 35, { g = "#7a5cc0", G = "#a894dc", d = "#54447f", s = "#7a4a1f", l = "#4f9a45" })
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
