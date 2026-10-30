-- ph/palusami (Gourmand P2 dish): tied dark taro-leaf parcel on a wide banana leaf, one corner folded back on white coconut cream
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "palusami"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- banana leaf: long lens with pointed tips
local leaf = c:ellipse(31.5, 46, 21, 7):add(c:poly({ {7, 47}, {14, 42}, {14, 51} })):add(c:poly({ {57, 44}, {50, 41}, {50, 51} }))
c:part(leaf, "#7ab648", { cres = 3, gloss = false })
c:fill(c:line({ {9, 47}, {31, 46}, {55, 44} }, 1), "#5a9a3a")
for _, x in ipairs({ 14, 20, 42, 48 }) do
  c:fill(c:line({ {x, 46}, {x - 3, 41} }, 1), "#9ad06a"); c:fill(c:line({ {x, 47}, {x - 3, 51} }, 1), "#5a9a3a")
end
-- parcel
local parcel = c:rrect(16, 15, 47, 47, 8):cut(c:poly({ {35, 13}, {49, 13}, {49, 28} }))
c:part(parcel, "#2f6a2a", { cres = 4, gloss = { 20, 20 } })
for _, l in ipairs({ { {20, 22}, {26, 26}, {30, 24} }, { {19, 40}, {25, 37}, {30, 39} }, { {35, 41}, {40, 37}, {44, 39} } }) do
  c:fill(c:line(l, 1), "#4f8a3a")
end
-- coconut cream showing in the opened corner
local cream = c:poly({ {35, 15}, {47, 15}, {47, 27} }):grow(1):clip(c:rrect(16, 15, 47, 47, 8))
c:part(cream, GV.ramp("#f1ece0", { dot = "#fbf6e8" }), { cres = 2, gloss = false, contact = false, contour = "#2a1a10" })
c:fill(c:poly({ {41, 18}, {46, 18}, {46, 23} }), "#e6dcc4")
-- folded-back flap lying on the parcel
local flap = c:poly({ {34, 15}, {48, 29}, {34, 29} })
c:part(flap, "#5a9a3a", { cres = 2, gloss = false, contact = true })
c:fill(c:line({ {35, 18}, {43, 26} }, 1), "#7ab648")
-- tie strip and knot
local tie = c:rect(16, 30, 47, 31):clip(parcel)
c:part(tie, "#c9a96e", { flat = true, contact = true })
c:paint({
  ".kk...kk.",
  "kddkKkddk",
  ".kk.K.kk.",
  "...k.k...",
  "..k...k..",
}, 18, 29, { k = "#e0c48a", d = "#8a6a3a", K = "#a8844a" })
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
