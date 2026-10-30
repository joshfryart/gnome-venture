-- ph/tepache (Pantry ferment): glass pitcher with a side handle and pouring lip, cloudy gold drink, spiky pineapple-crown lid
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local R = GV.R
local N = "tepache"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local drink = GV.ramp("#f5cf6a", { shade = "#e8a317", deep = "#b8661a", bounce = "#d0862a", rim = "#fbe08a", gloss = "#fff1c8", dot = "#fff8e0", pale = false })
local froth = GV.ramp("#f4f0e0", { shade = "#e0d4b0", dot = "#fbf6e8" })
-- C handle on the right (behind the body)
c:part(c:rrect(38, 27, 54, 48, 7):cut(c:rrect(42, 31, 50, 44, 4)), "glass", { gloss = false, contact = false, cres = 2, deep = 0 })
local body = c:rrect(12, 20, 44, 56, 8):add(c:poly({ {7, 18}, {16, 20}, {14, 27} }))   -- pouring lip at upper left
c:part(body, "glass", { gloss = false })
c:part(c:rrect(14, 28, 42, 54, 6), drink, { gloss = false, contour = "#b8661a" })
c:part(c:rect(14, 26, 42, 29), froth, { gloss = false, contact = false, cres = 2, deep = 0 })
for _, p in ipairs({ {17, 27}, {25, 26}, {33, 27}, {39, 26} }) do c:px(p[1], p[2], "#e8c070") end
for _, p in ipairs({ {19, 33}, {36, 31}, {40, 52} }) do   -- rind pieces
  c:paint({ ".o.", "ogo", ".o." }, p[1], p[2], { o = "#d0862a", g = "#7ab55c" })
end
c:part(c:rect(18, 39, 38, 52), GV.ramp("#f1ece0", { dot = "#fbf6e8" }), { gloss = false, contact = false })
c:paint({   -- pineapple emblem
  "..g.g.g..",
  "...ggg...",
  "....g....",
  "..ooooo..",
  ".oOoHoOo.",
  ".ooHoHoo.",
  ".oOoHoOo.",
  ".ooHoHoo.",
  "..ooooo..",
}, 24, 41, { g = "#4f9a45", o = "#e8a317", O = "#f5cf6a", H = "#b07a10" })
c:gloss(body, "glass", { 15, 24 })
-- pineapple crown lid: spiky leaves on the rim
local crown = c:poly({ {16, 22}, {41, 22}, {40, 14}, {37, 17}, {35, 7}, {32, 13}, {29, 5}, {26, 13}, {22, 8}, {21, 16}, {17, 12} })
c:part(crown, "leaf", { gloss = { 23, 15 } })
c:fill(c:line({ {29, 8}, {30, 20} }, 1), "#2f6a3a"); c:fill(c:line({ {35, 10}, {34, 20} }, 1), "#2f6a3a")
c:seam({ {17, 21}, {40, 21} })
c:ground(28, 57, 16, 1.5)
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
