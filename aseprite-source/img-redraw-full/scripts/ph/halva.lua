-- ph/halva (Pantry spread): round paper tub of marbled halva with a wedge cut away, wax-paper lid leaning behind, string tie
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "halva"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- wax-paper lid leaning at the back right
local wax = c:poly({ {41, 7}, {52, 5}, {55, 16}, {44, 18} })
c:part(wax, "#f4f0e0", { gloss = false })
c:fill(c:line({ {45, 8}, {47, 16} }, 1), "#c9c5bc"); c:fill(c:line({ {49, 7}, {51, 15} }, 1), "#c9c5bc")
-- tub
local tub = c:rrect(10, 30, 54, 55, 4)
c:part(tub, "#c9a96e", { gloss = { 13, 37 } })
for x = 14, 50, 4 do c:fill(c:rect(x, 36, x, 53):clip(tub), "#9a6b3f") end
-- halva block domed above the rim, with a wedge taken out at the front right
local wedge = c:poly({ {32, 25}, {58, 18}, {58, 44}, {46, 44} })
local block = c:ellipse(32, 25, 21, 8):add(c:rect(11, 25, 53, 33)):cut(wedge)
c:part(block, "#e8d8a0", { gloss = { 16, 22 }, contact = false })
for _, l in ipairs({ { {16, 25}, {20, 23}, {25, 25}, {28, 27} }, { {24, 20}, {29, 21}, {33, 20} }, { {18, 29}, {24, 28}, {30, 30} } }) do
  c:fill(c:line(l, 2), "#8a5a2f")
end
c:fill(c:line({ {37, 22}, {42, 23} }, 1), "#8a5a2f")
-- the cut: a dark empty pocket behind, and the bright marbled cut face in front
local faceL = c:poly({ {32, 25}, {48, 35}, {48, 43}, {32, 34} })
local pocket = c:poly({ {32, 25}, {54, 20}, {54, 31}, {48, 35} }):cut(faceL)
c:part(pocket, "#7a4a1f", { gloss = false, cres = 2, deep = 0, contact = false, rim = false })
c:fill(c:poly({ {35, 26}, {53, 22}, {53, 28} }), "#5e2f1e")
c:part(faceL, "#e8d8a0", { gloss = false, cres = 2, deep = 0, contact = false })
c:fill(c:line({ {33, 28}, {37, 29}, {41, 32}, {47, 36} }, 1), "#8a5a2f")
c:fill(c:line({ {33, 31}, {38, 34}, {42, 34}, {47, 39} }, 1), "#5a3a1f")
c:fill(c:line({ {34, 33}, {39, 36}, {43, 38}, {46, 41} }, 1), "#a8742f")
c:fill(c:line({ {32, 25}, {48, 35} }, 1), "#fff3c8")
-- string tie under the dome
c:fill(c:rect(11, 34, 46, 34):clip(tub), "#7a4a1f"); c:paint({ "k.k", ".k.", "k.k" }, 13, 33, { k = "#7a4a1f" })
-- label with a ring of sesame seeds
c:part(c:rrect(20, 40, 38, 51, 2), "cream", { gloss = false, contact = false })
for _, p in ipairs({ {28, 41}, {33, 43}, {31, 47}, {25, 47}, {23, 43} }) do
  c:paint({ ".s.", "sSs", "sss", ".s." }, p[1], p[2], { s = "#c9a96e", S = "#ecc58a" })
end
c:px(29, 45, "#9a6b3f"); c:px(30, 45, "#9a6b3f")
c:ground(32, 56, 22, 1.5)
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
