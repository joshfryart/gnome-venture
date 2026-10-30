-- ph/gochujang (Pantry paste): short wide red ceramic tub, glossy dark-red paste mounded into a swirled dome, wooden paddle
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local R = GV.R
local N = "gochujang"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local paste = GV.ramp("#a8241f", { gloss = "#f08a24", dot = "#ffc27a", rim = "#d6322b", shade = "#7a1a1f", deep = "#4e1420", bounce = "#8a2a2a" })
local tub = GV.ramp("#d6322b", { shade = "#a8241f", deep = "#6b1b2c", bounce = "#b8452f", gloss = "#ff9158", dot = "#ffc27a", rim = "#f2793a" })
-- wooden paddle stuck in the paste (drawn first so the dome buries its blade)
c:part(c:line({ {47, 8}, {37, 28} }, 4), "#c9a96e", { gloss = false, contact = false, cres = 2, deep = 0 })
c:fill(c:line({ {39, 22}, {37, 26} }, 2), "#a8241f")   -- paste daub on the blade
local dome = c:ellipse(32, 35, 20, 14):cut(c:rect(0, 34, 63, 63))
c:part(dome, paste, { gloss = { 20, 27 } })
-- swirl on the dome: a lit curl and a dark groove under it
c:paint({
  "........SSSSSS........",
  ".....SSS......SSS.....",
  "...SS...gggggg...SS...",
  "..S...gg......gg..S...",
  ".....g...SSSS...g.....",
  "....g..SS....S...g....",
  ".........ggg.S........",
}, 20, 23, { S = "#d6322b", g = "#6b1b2c" })
for _, p in ipairs({ {26, 31}, {38, 26}, {44, 31} }) do c:px(p[1], p[2], "#f5cf6a") end   -- rice specks
c:part(c:rrect(9, 35, 55, 55, 8), tub, { gloss = { 13, 41 } })
c:part(c:rrect(8, 32, 56, 37, 3), "flame", { gloss = false })   -- rim
c:seam({ {11, 36}, {53, 36} })
-- emblem: cream roundel with a chili pod
c:part(c:ellipse(32, 46.5, 7, 6), GV.ramp("#f1ece0", { dot = "#fbf6e8" }), { gloss = false, contact = false, cres = 3, deep = 0 })
c:paint({
  "....gg.",
  "...gg..",
  "..rrr..",
  ".rrRr..",
  ".rrr...",
  "rrr....",
  "rr.....",
}, 28, 43, { g = "#4f9a45", r = "#d6322b", R = "#ff9158" })
c:ground(32, 57, 22, 1.5)
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
