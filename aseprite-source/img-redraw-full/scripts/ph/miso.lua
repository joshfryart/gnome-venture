-- ph/miso (Pantry paste): squat tan stoneware crock with ear handles, parchment dome cover tied with string, spoon of golden paste
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local R = GV.R
local N = "miso"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local parch = GV.ramp("#f1ece0", { shade = "#e0d4b0", deep = "#c9b878", bounce = "#e6d4ac", dot = "#fbf6e8" })
-- ear handles behind the crock
c:part(c:rrect(7, 35, 14, 45, 3):cut(c:rect(10, 38, 11, 42)), "soil", { gloss = false, contact = false, cres = 2, deep = 0 })
c:part(c:rrect(50, 35, 56, 45, 3):cut(c:rect(52, 38, 53, 42)), "soil", { gloss = false, contact = false, cres = 2, deep = 0 })
local crock = c:rrect(12, 27, 52, 55, 10)
c:part(crock, "soil", { gloss = { 16, 38 } })
c:part(c:rect(12, 36, 52, 38):clip(crock), "#c9a96e", { gloss = false, contact = false, cres = 2, deep = 0 })   -- glaze band
-- parchment cover: dome with a scalloped skirt, string tie and knot
local cover = c:rrect(14, 13, 50, 29, 8)
for i = 0, 6 do cover:add(c:ellipse(15.5 + i * 5.5, 30, 2.5, 3)) end
c:part(cover, parch, { gloss = { 19, 16 } })
c:part(c:rect(15, 28, 49, 29), "#7a4a1f", { flat = true, contact = false })
c:paint({ "kk.kk", ".kkk.", "k.k.k" }, 30, 29, { k = "#5e2f1e" })
c:paint({ "..s", ".s.", "", "s.." }, 20, 18, { s = "#d8c49a" })   -- creases
-- wooden ladle resting on the cover, its bowl heaped with golden miso
c:part(c:line({ {22, 24}, {35, 17} }, 2), "wood", { flat = true, contact = false })
c:part(c:ellipse(40.5, 15, 6, 4), "wood", { gloss = false, contact = false, cres = 2, deep = 0 })
c:part(c:ellipse(40.5, 13, 4.5, 2.5):add(c:ellipse(40, 11, 2.5, 1.5)), "#e0b860", { gloss = false, contact = false, cres = 2, deep = 0 })
c:px(39, 11, "#fbf0c0"); c:px(38, 12, "#f5d890")
-- paper label on the crock: two soybeans, one tucked behind the other
c:part(c:rrect(23, 40, 41, 51, 2), GV.ramp("#f1ece0", { dot = "#fbf6e8" }), { gloss = false, contact = false })
c:paint({
  ".kkkk.......",
  "kBbbbk......",
  "kbbbbbk.....",
  "kbbsbbkkkk..",
  ".kbbbkBbbbk.",
  "..kkkbbbbbbk",
  "....kbbbsbbk",
  ".....kbbbbk.",
  "......kkkk..",
}, 26, 41, { k = "#5e2f1e", b = "#e8d890", B = "#fbf0c0", s = "#7a4a1f" })
c:ground(32, 57, 21, 1.5)
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
