-- ph/yogurt (Pantry dairy): squat milk-bottle jar of thick white yogurt with a cream line and a crimped blue foil cap.
-- Redraw B: the goat head is the emblem, so it is now big (17 x 16 px) and white on a cobalt oval label that matches
-- the cap, with dark curled horns and floppy grey ears: it reads at 16 px as "white goat face, two horns".
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "yogurt"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local yog = GV.ramp("#f4f0e0", { shade = "#e0d4b0", deep = "#c9b878", bounce = "#e6d4ac", dot = "#fbf6e8" })
c:part(c:rrect(16, 24, 48, 56, 10):add(c:rect(22, 16, 42, 26)), "glass", { gloss = false })
c:part(c:rrect(18, 30, 46, 54, 8):add(c:rect(24, 22, 40, 31)), yog, { gloss = false, contour = "#9a8a50" })
c:fill(c:rect(24, 22, 40, 23), "#fbf6e8"); c:fill(c:rect(24, 24, 40, 24), "#efe0bc")   -- cream line on top
-- cobalt oval label
c:part(c:ellipse(32, 44, 12, 10), GV.ramp("#3f8fb0", { shade = "#25637d", deep = "#1e4a66", rim = "#7ab8d0" }), { gloss = false, contact = false, cres = 3, deep = 1, contour = "#2a1a10" })
-- big goat head: curled dark horns, floppy ears, long white face, dark eyes, beard
c:paint({
  "hH.............Hh",
  "hhH...........Hhh",
  ".hhH.........Hhh.",
  "..hhH.......Hhh..",
  "...hhFFFFFFFhh...",
  "eee.FFFFFFFFs.eee",
  "eeeeFFFFFFFFseeee",
  ".ee.FkkFFFkks.ee.",
  "....FkKFFFkKs....",
  "....FFFFFFFFs....",
  ".....FFFFFFs.....",
  ".....FFFFFFs.....",
  "......FnFns......",
  "......FFFss......",
  ".......bbb.......",
  "........b........",
}, 24, 35, { h = "#5e2f1e", H = "#9a6b3f", F = "#f4f0e0", s = "#d0c8b8", k = "#2a1a10", K = "#f2e4c0", e = "#a8a49c", n = "#7a5a3a", b = "#d0c8b8" })
c:gloss(c:rrect(16, 24, 48, 56, 10), "glass", { 19, 31 })
-- crimped blue foil cap
c:part(c:rrect(20, 8, 44, 18, 2), "water", { gloss = { 23, 10 } })
for _, x in ipairs({ 24, 29, 35, 40 }) do c:fill(c:rect(x, 13, x, 18), "#25637d") end
c:seam({ {21, 17}, {43, 17} }, { free = false })
c:ground(32, 57, 17, 1.5)
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
