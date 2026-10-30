-- ph/garam-masala (Pantry spread): hinged flat spice tin with brass corners, lid thrown back like a flip book, red-brown spice inside
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "garam-masala"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- open lid standing up behind: tin frame, cream inner face with whole spices
local lid = c:rrect(10, 7, 54, 35, 3)
c:part(lid, "stone", { gloss = { 13, 9 } })
c:part(c:rect(13, 10, 51, 33), "#f4f0e0", { gloss = false, contact = false, pale = false })
c:fill(c:rect(13, 10, 51, 10), "#c9c5bc"); c:fill(c:rect(13, 10, 13, 33), "#c9c5bc")
-- two cinnamon sticks
c:paint({
  "wwwwwwwwwwwk",
  "WWWWWWWWWWWk",
  "wwwwwwwwwwwk",
  "............",
  ".wwwwwwwwwwk",
  ".WWWWWWWWWWk",
  ".wwwwwwwwwwk",
}, 16, 13, { w = "#9a6b3f", W = "#c98a4a", k = "#5e2f1e" })
-- star anise
c:paint({
  "....s....",
  "....s....",
  ".s..s..s.",
  "..sssss..",
  "sssskssss",
  "..sssss..",
  ".s..s..s.",
  "....s....",
  "....s....",
}, 31, 19, { s = "#7a4a1f", k = "#e8a317" })
-- cardamom pods
c:paint({ ".gg.", "gGgg", "gggg", ".gg." }, 43, 23, { g = "#a4b86a", G = "#c8d77a" })
c:paint({ ".gg.", "gGgg", "gggg", ".gg." }, 18, 25, { g = "#a4b86a", G = "#c8d77a" })
-- tin base: interior seen from above, then the front wall
local base = c:rrect(8, 35, 56, 55, 3)
c:part(base, "stone", { gloss = { 11, 46 } })
c:fill(c:rect(11, 34, 53, 34), "#5b6470")   -- hinge
local fill = c:rect(12, 37, 52, 44)
c:part(fill, "#8a4a1f", { gloss = false, cres = 2, deep = 0, contact = false })
for _, p in ipairs({ {15, 38}, {20, 40}, {26, 38}, {31, 41}, {37, 39}, {43, 41}, {48, 38}, {18, 43}, {29, 43}, {41, 43}, {50, 42}, {23, 42}, {35, 42}, {46, 40} }) do c:px(p[1], p[2], "#c8661f") end
c:fill(c:rect(14, 37, 50, 37), "#a8582f")
c:fill(c:rect(10, 46, 54, 46), "#5b6470")
for x = 12, 52, 3 do c:px(x, 48, "#e8a317") end
-- brass corners and the latch
for _, p in ipairs({ {8, 35}, {53, 35}, {8, 52}, {53, 52}, {10, 7}, {51, 7} }) do
  c:paint({ "bbbb", "bBBs", "bBss", "bss." }, p[1], p[2], { b = "#f5cf6a", B = "#e8a317", s = "#b8661a" })
end
c:button(30, 50)
c:ground(32, 56, 22, 1.5)
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
