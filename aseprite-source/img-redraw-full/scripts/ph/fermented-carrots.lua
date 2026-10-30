-- ph/fermented-carrots (Pantry ferment): heavy orange stoneware crock, water-moat rim, domed lid with a knob, bubbles escaping
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local R = GV.R
local N = "fermented-carrots"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local glaze = GV.ramp("#c8641a", { shade = "#8a3a10", deep = "#5e2410", bounce = "#a04a1a", rim = "#ef8a24", gloss = "#ffc27a", dot = "#ffe0a8" })
local bub = GV.ramp("#f4f0e0", { shade = "#c9e6f0", deep = "#8fcbd8", bounce = "#d8ecf0", dot = "#fbf6e8" })
c:part(c:rrect(12, 30, 52, 55, 9), glaze, { gloss = { 16, 36 } })
c:part(c:rrect(16, 33, 18, 41, 1), "#8a3a10", { flat = true, contact = false, rim = false })   -- glaze run
c:part(c:rrect(9, 24, 55, 31, 3), "flame", { gloss = false })   -- moat rim
c:part(c:rrect(13, 25, 51, 27, 1), "water", { gloss = false, contact = false, cres = 1, deep = 0, contour = "#2a3c6c" })
c:part(c:ellipse(32, 26, 15, 12):cut(c:rect(0, 27, 63, 63)), "flame", { gloss = { 22, 18 } })   -- domed lid in the moat
c:part(c:ellipse(32, 13, 3), "soil", { gloss = false, contact = false, cres = 2, deep = 0 })    -- knob
c:px(31, 12, "#e8a060")
-- bubbles escaping from the water seal, rising
for _, b in ipairs({ {13, 20, 2}, {9, 13, 1.5}, {51, 18, 2}, {47, 10, 1.5} }) do
  c:part(c:ellipse(b[1], b[2], b[3]), bub, { gloss = false, contact = false, cres = 2, deep = 0 })
  c:px(b[1] - 1, b[2] - 1, "#fbf6e8")
end
-- emblem: three carrot batons and a dill sprig on the belly
c:part(c:rrect(23, 37, 41, 51, 3), GV.ramp("#f1ece0", { dot = "#fbf6e8" }), { gloss = false, contact = false })
c:paint({
  "..g.g.g...",
  "...ggg....",
  "....g.....",
  ".OoOoOo...",
  ".OoOoOo...",
  ".OoOoOo...",
  ".OoOoOo...",
  ".OoOoOo...",
  "..oOoOo...",
}, 27, 40, { g = "#4f9a45", O = "#ef8a24", o = "#c8641a" })
c:paint({ "o.", "oo", "o.", "oo" }, 35, 44, { o = "#c8641a" })
c:ground(32, 57, 20, 1.5)
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
