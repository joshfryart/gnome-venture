-- ph/dried-mushrooms (Pantry dried): kraft lunch bag, top folded twice and clipped with a wooden peg, mushroom slices peeking out
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "dried-mushrooms"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- mushroom slices behind the fold: umbrella caps on short stems
local function slice(x, y)
  c:part(c:rect(x - 1, y, x + 1, y + 9), "#d8b97e", { flat = true, contact = false })
  c:part(c:ellipse(x, y, 5, 3):cut(c:rect(0, y + 1, 63, 63)), "#8a5a2f", { gloss = false, cres = 2, deep = 0 })
  c:fill(c:rect(x - 4, y + 1, x + 4, y + 1), "#c9a96e")
  c:px(x - 2, y - 2, "#c98a4a")
end
slice(26, 9); slice(39, 9); slice(19, 12); slice(45, 12)
-- bag body with side gusset
local bag = c:rrect(14, 24, 50, 55, 2)
c:part(bag, "#d8b97e", { gloss = { 17, 30 } })
c:fill(c:rect(44, 26, 44, 53), "#c9a96e"); c:fill(c:rect(45, 26, 45, 53), "#b8955a")
for y = 26, 52, 3 do c:px(16, y, "#e8a317"); c:px(48, y, "#e8a317") end
-- double-folded top
c:part(c:rrect(12, 17, 52, 26, 2), "#c9a96e", { gloss = { 15, 19 } })
c:fill(c:rect(14, 21, 50, 21), "#9a6b3f"); c:fill(c:rect(14, 22, 50, 22), "#ecc58a")
-- stamped label with a morel
c:part(c:rect(21, 32, 41, 50), "cream", { gloss = false, contact = false })
c:paint({
  "...mm...",
  "..mmmm..",
  ".mdmmdm.",
  ".mmdmmm.",
  ".mmmdmm.",
  ".dmmmdm.",
  ".mmdmmm.",
  "..mmmm..",
  "...ss...",
  "...ss...",
  "..ssss..",
}, 27, 36, { m = "#8a5a2f", d = "#5a3a1f", s = "#d8b97e" })
for x = 23, 39, 2 do c:px(x, 34, "#c9a96e"); c:px(x, 48, "#c9a96e") end
-- wooden clothes-peg clipping the fold
c:part(c:rrect(28, 12, 36, 32, 2), "#c9a96e", { gloss = { 30, 14 } })
c:fill(c:rect(32, 13, 32, 31), "#7a4a1f")
c:part(c:rect(30, 21, 34, 23), "stone", { flat = true, contact = false })
c:ground(32, 56, 19, 1.5)
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
