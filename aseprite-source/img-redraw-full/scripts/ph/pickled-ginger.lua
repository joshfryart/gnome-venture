-- ph/pickled-ginger (Pantry pickle): opaque white porcelain pot with cobalt bands, domed lid tipped ajar on the left,
-- pale blush ginger heap, ginger-root emblem.
-- Redraw B: the lid is now solid cobalt (cream band, cream knob) and sits low on the left, the heap is a bigger pink mound
-- on the right with an umber line between them, so at 16 px it reads as three blocks: blue lid, pink heap, white pot.
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "pickled-ginger"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local porc = GV.ramp("#f1ece0", { shade = "#c9c5bc", bounce = "#ddd8cc", deep = "#8b8f96", dot = "#fbf6e8" })
local blush = GV.ramp("#f6b8cf", { shade = "#e46a9b", deep = "#b8456e", rim = "#fbd4e2", pale = false })
local cobalt = GV.ramp("#3f8fb0", { shade = "#25637d", deep = "#1e4a66", rim = "#7ab8d0", gloss = "#a9d6ea", dot = "#d8f0f8" })
-- ginger heap: a big mound rising above the rim, right of centre
local heap = c:ellipse(37, 33, 13, 10):cut(c:rect(0, 37, 63, 63))
c:part(heap, blush, { cres = 3, deep = 1, gloss = false })
for _, s in ipairs({ { {29, 31}, {33, 27}, {38, 25} }, { {33, 34}, {38, 30}, {44, 29} }, { {40, 34}, {45, 32}, {48, 33} },
                     { {28, 35}, {32, 32} }, { {36, 26}, {41, 24}, {44, 25} } }) do
  c:fill(c:line(s, 1), "#e46a9b")
end
c:px(31, 30, "#fbe3ea"); c:px(36, 27, "#fbe3ea"); c:px(42, 31, "#fbe3ea")
-- pot body with two cobalt bands
local pot = c:rrect(14, 35, 50, 56, 9)
c:part(pot, porc, { gloss = { 18, 39 }, contour = "#4a2c1a" })
c:fill(c:rect(14, 38, 50, 39):clip(pot), "#3f8fb0")
c:fill(c:rect(14, 52, 50, 53):clip(pot), "#3f8fb0")
c:fill(c:rect(14, 38, 30, 38):clip(pot), "#8fcbd8")
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
}, 20, 42, { b = "#9a6b3f", y = "#e8d890", Y = "#f4ecc0", r = "#c9b070" })
c:paint({ ".pp.", "pPpp", ".pp." }, 36, 47, { p = "#e46a9b", P = "#f6b8cf" })
c:paint({ ".pp.", "pppp", ".pp." }, 41, 44, { p = "#e46a9b" })
-- cobalt domed lid tipped ajar, resting on the left of the rim
local lid = c:poly({ {9, 35}, {10, 28}, {14, 23}, {20, 20}, {25, 21}, {29, 25}, {30, 30}, {11, 37} })
c:part(lid, cobalt, { cres = 2, deep = 1, gloss = { 13, 27 }, contour = "#2a1a10" })
c:fill(c:line({ {11, 32}, {15, 28}, {21, 26}, {28, 28} }, 1), "#f1ece0")
c:part(c:ellipse(19, 18, 2.5, 2), porc, { flat = true, contact = false })
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
