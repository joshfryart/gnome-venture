-- ph/pickled-daikon (Pantry pickle): staved wooden pressing tub with two iron hoops, board lid, big grey weight stone, daikon rounds peeking at the rim
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "pickled-daikon"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local tub = c:poly({ {11, 29}, {53, 29}, {51, 57}, {13, 57} })
-- daikon rounds peeking between board and rim (behind the tub)
local dk = GV.ramp("#e8e0b0", { shade = "#c9b878", deep = "#9a8a50" })
for _, q in ipairs({ {20, 26}, {44, 26}, {32, 25} }) do
  c:part(c:ellipse(q[1], q[2], 4.5, 4), dk, { cres = 2, deep = 0, gloss = false, contact = false })
  c:fill(c:ellipse(q[1], q[2], 2.5, 2):edge(), "#c9b878")
  c:px(q[1] - 2, q[2] - 2, "#f8f2d8")
end
c:part(tub, "#9a6b3f", { contour = "#5e2f1e", gloss = { 15, 33 } })
-- staves: vertical lines every 5 px
for x = 16, 48, 5 do c:fill(c:rect(x, 30, x, 56):clip(tub), "#7a4a1f"); c:fill(c:rect(x + 1, 30, x + 1, 56):clip(tub), "#b07a45") end
-- iron hoops
for _, y in ipairs({ 33, 50 }) do
  c:fill(c:rect(0, y, 63, y + 1):clip(tub), "#5b6470")
  c:fill(c:rect(0, y, 30, y):clip(tub), "#8b8f96")
  for x = 14, 50, 9 do c:px(x, y + 1, "#3d4650") end
end
-- hanging tag with a daikon emblem, tied by string
c:fill(c:line({ {22, 34}, {25, 38} }, 1), "#f1ece0")
c:part(c:rrect(24, 38, 40, 48, 1), "cream", { gloss = false, contact = false })
c:paint({
  "..gGg..........",
  "...g...........",
  "..bwwwwwwwbb...",
  ".bwWwwwwwwwwbbb",
  "..bwwwwwwwbb...",
}, 25, 40, { g = "#4f9a45", G = "#2f5a2a", b = "#c9b878", w = "#f1ece0", W = "#fbf6e8" })
c:paint({ "uuu.uu.uu" }, 28, 46, { u = "#7a5a3a" })
-- board lid and weight stone
c:part(c:rrect(15, 18, 49, 23, 2), "#c9a96e", { contour = "#7a4a1f", gloss = false })
c:fill(c:rect(18, 21, 27, 21), "#9a6b3f"); c:fill(c:rect(36, 20, 45, 20), "#9a6b3f")
c:part(c:ellipse(32, 13, 10, 6.5):add(c:rrect(22, 12, 42, 19, 5)), "stone", { contour = "#3d4650", gloss = { 25, 9 } })
for _, q in ipairs({ {35, 10}, {29, 15}, {38, 16}, {26, 12} }) do c:px(q[1], q[2], "#c9c5bc") end
c:seam({ {17, 19}, {47, 19} })
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 4, N .. " failed checks")
