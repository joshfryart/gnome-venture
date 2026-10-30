-- ph/hummus-jar (Pantry spread): low wide stoneware pot with two ear handles, scalloped parchment cover tied with twine, chickpea label
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "hummus-jar"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- lug handles behind the body
local ears = c:ellipse(12, 41, 3.5, 5):cut(c:ellipse(12, 41, 1, 2.5)):add(c:ellipse(52, 41, 3.5, 5):cut(c:ellipse(52, 41, 1, 2.5)))
c:part(ears, "#c9a96e", { gloss = false, cres = 2, deep = 0 })
local pot = c:rrect(12, 32, 52, 55, 8)
c:part(pot, "#c9a96e", { gloss = { 16, 38 } })
-- glaze drip band
c:fill(c:rect(14, 42, 50, 42), "#9a6b3f")
for _, x in ipairs({ 18, 25, 33, 41, 47 }) do c:fill(c:rect(x, 43, x, 44 + (x % 3)), "#9a6b3f") end
-- parchment cover: bulging top, scalloped edge hanging over the rim
local cover = c:ellipse(32, 31, 21, 6):add(c:ellipse(32, 28, 12, 6))
for x = 13, 51, 4 do cover:add(c:ellipse(x + 1, 36, 2, 1.5)) end
c:part(cover, "#f4f0e0", { gloss = { 24, 25 } })
c:fill(c:ellipse(32, 27, 6, 2), "#e8d8b0"); c:fill(c:ellipse(33, 27, 3, 1), "#d6b98a")
c:fill(c:line({ {20, 31}, {24, 27} }, 1), "#c9c5bc"); c:fill(c:line({ {44, 31}, {40, 27} }, 1), "#c9c5bc"); c:fill(c:line({ {32, 34}, {32, 31} }, 1), "#c9c5bc")
for x = 15, 49, 3 do c:px(x, 36, "#e8a317") end
-- twine: two wraps and a bow
c:fill(c:rect(13, 33, 51, 33), "#7a4a1f"); c:fill(c:rect(13, 35, 51, 35):clip(cover), "#7a4a1f")
c:paint({ "kk.kk", "kkkkk", ".k.k.", "k...k" }, 30, 32, { k = "#5e2f1e" })
-- label with a chickpea and a paprika dust dot
c:part(c:rect(24, 43, 40, 52), "cream", { gloss = false, contact = false })
c:paint({
  "..ccc...",
  ".cCccc..",
  "cccccbc.",
  "ccccc.cb",
  ".ccsss..",
  "..ss....",
}, 28, 45, { c = "#d6b98a", C = "#f4e8c0", s = "#b08a50", b = "#9a6b3f" })
c:px(37, 45, "#a8241f")
c:ground(32, 56, 22, 1.5)
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
