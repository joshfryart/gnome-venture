-- ph/pickled-ginger (Pantry pickle): opaque white porcelain pot with cobalt bands, domed lid tipped ajar on the left, pale blush ginger heap, ginger-root emblem
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "pickled-ginger"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local porc = GV.ramp("#f1ece0", { shade = "#c9c5bc", bounce = "#ddd8cc", deep = "#8b8f96" })
local blush = GV.ramp("#f6b8cf", { shade = "#e46a9b", deep = "#b8456e" })
-- ginger heap rising above the rim (behind the pot front)
local heap = c:ellipse(33, 32, 12, 7):cut(c:rect(0, 36, 63, 63))
c:part(heap, blush, { cres = 2, deep = 0, gloss = false })
for _, s in ipairs({ { {24, 31}, {28, 28}, {32, 27} }, { {30, 33}, {35, 29}, {39, 28} }, { {35, 32}, {40, 30}, {43, 31} },
                     { {26, 34}, {31, 31} }, { {38, 34}, {42, 33} }, { {29, 27}, {34, 25}, {37, 26} } }) do
  c:fill(c:line(s, 1), "#e46a9b")
end
c:px(28, 30, "#fbe3ea"); c:px(33, 28, "#fbe3ea"); c:px(39, 31, "#fbe3ea")
-- pot body with two cobalt bands
local pot = c:rrect(14, 34, 50, 56, 9)
c:part(pot, porc, { gloss = { 18, 38 }, contour = "#9a6b3f" })
c:fill(c:rect(14, 37, 50, 38):clip(pot), "#3f8fb0")
c:fill(c:rect(14, 52, 50, 53):clip(pot), "#3f8fb0")
c:fill(c:rect(14, 37, 30, 37):clip(pot), "#8fcbd8")
-- ginger root emblem with two pink slices
c:paint({
  ".bb.....bb...",
  "byyb...byyb..",
  "byyb..byYyb..",
  "byyybbyyyyb.b",
  ".byyyyyrybbyb",
  "..byyyyyyyyyb",
  "..byryyyybbb.",
  "...bbyyyb....",
  ".....bbb.....",
}, 20, 40, { b = "#9a6b3f", y = "#e8d890", Y = "#f4ecc0", r = "#c9b070" })
c:paint({ ".pp.", "pPpp", ".pp." }, 36, 47, { p = "#f6b8cf", P = "#fbe3ea" })
c:paint({ ".pp.", "pppp", ".pp." }, 41, 45, { p = "#f6b8cf" })
-- domed lid tipped ajar, resting on the left of the rim
local lid = c:poly({ {12, 33}, {14, 26}, {19, 21}, {26, 19}, {32, 21}, {35, 25}, {14, 34} })
c:part(lid, porc, { cres = 2, deep = 1, gloss = { 18, 24 }, contour = "#9a6b3f" })
c:fill(c:line({ {14, 29}, {18, 25}, {24, 23}, {31, 24} }, 1), "#3f8fb0")
c:part(c:ellipse(24, 17, 2.5, 2), "water", { flat = true })
c:px(23, 16, "#c8ecdc")
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 4, N .. " failed checks")
