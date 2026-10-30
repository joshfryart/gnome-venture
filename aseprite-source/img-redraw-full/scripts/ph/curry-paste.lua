-- ph/curry-paste (Pantry spread): squat terracotta pot, golden paste under a green banana-leaf lid tied with string, chili tag
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "curry-paste"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local pot = c:rrect(10, 28, 54, 55, 10)
c:part(pot, "#c8661f", { gloss = { 14, 36 } })
c:fill(c:rect(12, 33, 52, 33), "#a8441f")
-- golden paste peeking out under the leaf edge
c:part(c:ellipse(32, 28, 17, 4), "#e8a317", { gloss = false, contact = false })
c:fill(c:line({ {22, 29}, {27, 30}, {33, 29} }, 2), "#c8821f")
-- banana leaf pulled over the mouth, wavy edge drooping down the sides
local leaf = c:ellipse(32, 21, 21, 7):add(c:poly({ {11, 21}, {14, 30}, {17, 27}, {20, 26} })):add(c:poly({ {53, 21}, {50, 30}, {47, 27}, {44, 26} }))
for x = 13, 51, 5 do leaf:del(x, 28); leaf:del(x, 27) end
c:part(leaf, "leaf", { gloss = { 20, 16 } })
c:fill(c:rect(14, 21, 50, 21), "#2f5a2a")
for x = 17, 47, 5 do c:fill(c:line({ {x, 21}, {x + 3, 16} }, 1):add(c:line({ {x, 22}, {x + 3, 26} }, 1)):clip(leaf), "#3f7a3a") end
for x = 15, 49, 3 do c:px(x, 18, "#c8d77a") end
-- string wraps and bow on the neck
c:fill(c:rect(12, 30, 52, 30), "#7a4a1f"); c:fill(c:rect(12, 32, 52, 32), "#7a4a1f")
c:paint({ "kk.kk", "kkkkk", "k.k.k", ".k.k." }, 30, 29, { k = "#4e2a16" })
-- hanging tag with a red chili
c:fill(c:line({ {33, 33}, {33, 38} }, 1), "#7a4a1f")
c:part(c:rrect(24, 39, 41, 52, 1), "cream", { gloss = false, contact = false })
c:paint({
  "..........gg",
  ".........gg.",
  "...rrrrrrgg.",
  ".rRRrrrrrr..",
  "rrrrrrrrd...",
  "r.dddddd....",
}, 27, 43, { r = "#d6322b", R = "#ff9158", d = "#a8241f", g = "#4f9a45" })
c:ground(32, 56, 20, 1.5)
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
