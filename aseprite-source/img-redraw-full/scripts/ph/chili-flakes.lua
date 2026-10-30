-- ph/chili-flakes (Pantry dried): tilted kraft envelope sealed with a red wax dot, red flakes spilled onto a tiny wooden spoon
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "chili-flakes"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- envelope tilted about 8 degrees
local body = c:poly({ {17, 15}, {55, 10}, {57, 45}, {19, 50} })
c:part(body, "#c9a96e", { gloss = false })
local flap = c:poly({ {18, 16}, {54, 11}, {37, 31} })
c:part(flap, "#d8b97e", { gloss = { 22, 17 }, contact = false })
c:fill(c:line({ {19, 16}, {36, 30} }, 1):add(c:line({ {53, 12}, {38, 30} }, 1)), "#9a6b3f")
c:seam({ {20, 18}, {35, 30} }); c:seam({ {51, 14}, {39, 29} })
-- printed chili pod
c:paint({
  "........gg.",
  ".......gg..",
  "..rrrrrrg..",
  ".rRRrrrrr..",
  "rrrrrrrrd..",
  "r.ddddd....",
}, 32, 37, { r = "#d6322b", R = "#ff9158", d = "#a8241f", g = "#4f9a45" })
-- wax seal over the flap point
c:part(c:ellipse(37, 31, 4, 4), "#a8241f", { gloss = { 35, 29 } })
c:paint({ ".d.", "d.d", ".d." }, 36, 30, { d = "#6b1b2c" })
-- wooden spoon and the spill
local spoon = c:ellipse(15, 53, 5, 2.5):add(c:line({ {11, 51}, {8, 46} }, 2))
c:part(spoon, "#c9a96e", { gloss = false, cres = 2, deep = 0 })
c:fill(c:ellipse(15, 53, 3, 1), "#9a6b3f")
local heap = c:ellipse(15, 52, 3, 1):add(c:ellipse(26, 53, 6, 2))
c:part(heap, "#d6322b", { gloss = false, cres = 1, deep = 0 })
for _, p in ipairs({ {11, 51}, {14, 50}, {12, 53}, {15, 52}, {21, 52}, {24, 51}, {27, 52}, {23, 54}, {29, 53}, {26, 54} }) do c:px(p[1], p[2], "#a8241f") end
for _, p in ipairs({ {13, 51}, {22, 53}, {26, 52}, {29, 52}, {20, 53} }) do c:px(p[1], p[2], "#f08a24") end
c:px(17, 50, "#d6322b"); c:px(20, 49, "#d6322b"); c:px(22, 49, "#a8241f")    -- flakes still falling from the corner
c:ground(22, 56, 14, 1.5)
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
