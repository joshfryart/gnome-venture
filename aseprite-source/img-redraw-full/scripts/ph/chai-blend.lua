-- ph/chai-blend (Pantry spread): shouldered ceramic tea caddy, domed lid with a gold acorn knob, brown glaze, painted spice band
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "chai-blend"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local body = c:ellipse(32, 40, 20, 15):add(c:rrect(16, 44, 48, 55, 4))
c:part(body, "#8a5a2f", { gloss = { 17, 33 } })
c:fill(c:rect(15, 35, 16, 45):clip(body), "#a8742f")
c:part(c:rrect(20, 22, 44, 29, 2), "#7a4a1f", { gloss = false, cres = 2, deep = 0 })
-- domed lid, seam and acorn knob
local dome = c:ellipse(32, 23, 14, 9):cut(c:rect(0, 24, 63, 63)):add(c:rrect(17, 21, 47, 25, 2))
c:part(dome, "#a8441f", { gloss = { 23, 17 } })
c:seam({ {19, 25}, {45, 25} }, { free = true })
c:fill(c:rect(19, 26, 45, 26), "#5a3a1f")
c:part(c:ellipse(32, 12, 3, 3), "gold", { gloss = { 31, 11 }, cres = 2, deep = 0 })
c:part(c:rrect(28, 8, 36, 10, 1), "#9a6b3f", { flat = true, contact = false })
c:px(32, 7, "#5e2f1e")
-- painted cream band with cardamom, cinnamon and a tea leaf
local band = c:rect(12, 38, 52, 46):clip(body)
c:part(band, "cream", { gloss = false, contact = false })
for x = 14, 50, 3 do c:px(x, 39, "#e8a317"); c:px(x + 1, 45, "#e8a317") end
c:paint({ ".gg.", "gGgg", "gggg", ".gg." }, 19, 40, { g = "#a4b86a", G = "#c8d77a" })
c:paint({ "wwwwwwwwk", "WWWWWWWWk", "wwwwwwwwk" }, 27, 41, { w = "#9a6b3f", W = "#c98a4a", k = "#5e2f1e" })
c:paint({ "..lll", ".lLll", "lllk.", "llk..", "k...." }, 40, 40, { l = "#4f9a45", L = "#a4b86a", k = "#2f5a2a" })
c:ground(32, 56, 16, 1.5)
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
