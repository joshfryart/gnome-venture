-- ph/egusi-soup (Gourmand P2 dish): round-bellied iron pot on three stubby feet, deep green egusi with cream seed curds and a red palm-oil ring
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "egusi-soup"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local pot = GV.ramp("#3f4650", { rim = "#6a7480", gloss = "#9aa6b2", dot = "#c4ccd4" })
-- feet first (behind the belly)
local feet = c:rrect(15, 47, 20, 54, 2):add(c:rrect(29, 49, 34, 55, 2)):add(c:rrect(43, 47, 48, 54, 2))
c:part(feet, pot, { flat = true, contact = false })
-- globe belly wider than the mouth
local belly = c:ellipse(31.5, 37, 22, 15)
c:part(belly, pot, { cres = 5, gloss = { 16, 34 } })
c:fill(c:line({ {12, 33}, {20, 30}, {31, 29}, {43, 30}, {51, 33} }, 1), "#2f343c")   -- shoulder line
-- collar and mouth
local collar = c:rrect(16, 22, 47, 28, 3)
c:part(collar, pot, { cres = 2, gloss = false })
local rim = c:ellipse(31.5, 23, 17, 5)
c:part(rim, "stone", { flat = true, contact = false })
c:fill(rim:edge():clip(c:rect(0, 23, 63, 40)), "#5b6470")
-- soup, palm-oil ring, curds, leaf flecks
local soup = c:ellipse(31.5, 23, 14, 3.5)
c:part(soup, "#3a6a2a", { cres = 2, gloss = false, contact = false, contour = "#5b6470", rim = false })
c:fill(soup:edge(), "#d6522b")
c:fill(soup:edge():clip(c:rect(0, 0, 63, 22)), "#e8742a")
for _, p in ipairs({ {20, 22}, {27, 21}, {37, 23}, {30, 24} }) do
  c:paint({ ".cc.", "cCcc", ".cs." }, p[1], p[2], { c = "#e8dcb4", C = "#f8f0d0", s = "#bfae80" })
end
for _, p in ipairs({ {25, 24}, {34, 21}, {42, 23}, {23, 21}, {40, 25} }) do c:px(p[1], p[2], "#6ab648") end
c:ground(31.5, 57, 18, 1.2)
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
