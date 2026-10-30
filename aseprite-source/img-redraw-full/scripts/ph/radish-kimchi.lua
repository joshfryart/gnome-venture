-- Redraw B: radish cubes are 7 px (were 5) with a lit top, shaded side and paste corners, placed off-centre.
-- ph/radish-kimchi (Pantry kimchi): tall brown onggi crock, sloped shoulders, narrow mouth, pinch-knob lid, red paste runs, radish cubes
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local R = GV.R
local N = "radish-kimchi"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local onggi = GV.ramp("#7a4a1f", { rim = "#9a6b3f", gloss = "#c98a4a", dot = "#e8a060", shade = "#5a3416", deep = "#3d2a1c", bounce = "#6a3a1a" })
local cube = GV.ramp("#f1ece0", { dot = "#fbf6e8", shade = "#d8c49a" })
c:part(c:rrect(21, 51, 43, 56, 1), "#5a3416", { gloss = false })   -- foot ring
-- amphora silhouette: narrow neck, steep sloped shoulders, widest low on the belly
local body = c:poly({ {25, 16}, {40, 16}, {41, 20}, {49, 30}, {52, 41}, {47, 52}, {17, 52}, {12, 41}, {15, 30}, {23, 20} })
c:part(body, onggi, { gloss = { 18, 32 } })
c:part(c:rrect(23, 15, 41, 19, 1), "soil", { gloss = false, cres = 2, deep = 0 })   -- rolled mouth rim
c:seam({ {16, 31}, {48, 31} })   -- glaze line round the shoulder
-- red chili paste running down from the mouth
local paste = c:rect(26, 20, 39, 21)
paste:add(c:rrect(26, 20, 28, 30, 1)):add(c:rrect(32, 20, 34, 25, 1)):add(c:rrect(37, 20, 39, 34, 1))
c:part(paste, "red", { gloss = false, contact = false, cres = 2, deep = 0, contour = false })
c:px(27, 31, "#ae2a2a"); c:px(38, 35, "#ae2a2a")
c:part(c:rrect(24, 10, 40, 15, 2), "#c9a96e", { gloss = { 26, 11 } })   -- lid
c:part(c:rrect(30, 6, 34, 10, 2), "soil", { gloss = false, contact = false })   -- pinch knob
-- emblem: round daikon with a green top on a cream patch
c:part(c:ellipse(32, 43, 6, 6), cube, { gloss = false, contact = false, cres = 3, deep = 0 })
c:paint({
  ".g...g.",
  "..g.g..",
  "...g...",
}, 29, 34, { g = "#4f9a45" })
c:paint({ "gg.gg", ".ggg." }, 30, 36, { g = "#2f6a3a" })
c:fill(c:rect(30, 41, 30, 42), "#fbf6e8")
c:paint({ "r..r", ".rr.", "..r." }, 31, 44, { r = "#dd3a2a" })
-- radish cubes, red coated: big 7 px blocks with a lit top face and a shaded side, spilt on the shoulder and at the foot
local function rcube(x, y)
  c:part(c:rect(x, y, x + 6, y + 6), cube, { gloss = false, contact = false, cres = 2, deep = 0, contour = "#2a1a10" })
  c:fill(c:rect(x, y, x + 6, y + 1), "#f8f2e0")                                   -- lit top face
  c:fill(c:rect(x + 5, y + 2, x + 6, y + 6), "#d8c49a")                           -- shaded side
  c:fill(c:rect(x + 4, y, x + 6, y + 2), "#dd3a2a"); c:px(x + 6, y + 3, "#ae2a2a")  -- chili paste on the corner
  c:fill(c:rect(x, y + 4, x + 2, y + 6), "#dd3a2a"); c:px(x + 3, y + 6, "#ae2a2a")
  c:px(x + 1, y, "#fbf6e8")
end
rcube(15, 18); rcube(8, 30); rcube(43, 47)   -- a diagonal tumble down the left, one in front on the right
c:ground(32, 57, 15, 1.5)
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
