-- ph/tempeh (Pantry ferment): banana-leaf envelope, open right end shows the white-moulded bean cake, bamboo pick pins the fold
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local R = GV.R
local N = "tempeh"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local mould = GV.ramp("#f4f0e0", { shade = "#e0d4b0", deep = "#c9b878", bounce = "#e6d4ac", dot = "#fbf6e8" })
-- bamboo pick behind the parcel top
c:part(c:line({ {25, 9}, {33, 26} }, 2), "#c9a96e", { flat = true, contact = false })
-- leaf parcel: slight skew, flat envelope
local leaf = c:poly({ {9, 22}, {47, 19}, {49, 53}, {8, 54} })
c:part(leaf, "leaf", { gloss = { 13, 26 } })
c:fill(c:line({ {10, 38}, {46, 37} }, 1), "#7ab55c")   -- mid vein
for _, x in ipairs({ 16, 24, 32, 40 }) do   -- side veins
  c:fill(c:line({ {x, 37}, {x + 3, 33} }, 1), "#5f9a4a"); c:fill(c:line({ {x, 38}, {x + 3, 42} }, 1), "#5f9a4a")
end
c:fill(c:line({ {10, 24}, {22, 34} }, 2), "#2f6a3a")   -- fold line of the top flap
c:fill(c:line({ {10, 52}, {22, 44} }, 2), "#2f6a3a")
-- open right end: tempeh block poking out, white mould with beans
local block = c:rrect(42, 23, 55, 49, 2)
c:part(block, mould, { gloss = { 45, 26 } })
for _, p in ipairs({ {46, 30}, {51, 28}, {49, 34}, {45, 40}, {52, 39}, {48, 45}, {53, 45} }) do
  c:paint({ "BB", "Bb" }, p[1], p[2], { B = "#c9a96e", b = "#9a6b3f" })
end
c:part(c:poly({ {41, 19}, {48, 19}, {44, 26} }), "leaf", { gloss = false, contact = false, cres = 2, deep = 0 })   -- leaf flap folded back
c:part(c:poly({ {41, 53}, {48, 54}, {44, 46} }), "leaf", { gloss = false, contact = false, cres = 2, deep = 0 })
-- pick tip in front of the leaf
c:part(c:line({ {33, 26}, {35, 31} }, 2), "#c9a96e", { flat = true, contact = false })
-- emblem painted on the leaf: soybean pod with three beans
c:paint({
  "..kkkkkkkkk.",
  ".kPPPPPPPPPk",
  "kPBBPBBPBBPk",
  "kPBbPBbPBbk.",
  ".kkkkkkkkk..",
}, 14, 44, { k = "#2f5a2a", P = "#e8d890", B = "#fbf0c0", b = "#c9b878" })
c:ground(32, 57, 22, 1.5)
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
