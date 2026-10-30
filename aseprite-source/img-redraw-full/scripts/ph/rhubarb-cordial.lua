-- ph/rhubarb-cordial (Pantry cordial): square-shouldered swing-top bottle, wire bail over a ceramic stopper, pink rhubarb cordial, rhubarb stalk label
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local R = GV.R
local N = "rhubarb-cordial"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local glass = c:rrect(20, 24, 44, 56, 5):add(c:rect(28, 15, 36, 25))
c:build{
  { "glass",  glass, "#d8ecf0", { pale = false } },
  { "liquid", c:rrect(22, 28, 42, 54, 4), GV.ramp("#e46a9b", { shade = "#c8527f" }), { contour = "#c8527f", gloss = { 24, 31 } } },
  { "label",  c:rrect(25, 36, 39, 48, 2), "cream", { gloss = false, contact = false } },
}
-- hinge ring round the neck, two lever arms, wire loop over the stopper
c:part(c:rect(26, 20, 38, 21), "stone", { flat = true })
c:part(c:line({ {26, 20}, {25, 12}, {27, 7}, {37, 7}, {39, 12}, {38, 20} }, 2), "#8b8f96", { flat = true })
c:part(c:ellipse(32, 13, 6, 4), "cream", { gloss = { 29, 11 }, cres = 2 })
c:seam({ {28, 17}, {36, 17} }, { free = true })
-- rhubarb stalk + leaf fan
c:fill(c:line({ {28, 45}, {33, 39} }, 2), "#d6322b")
c:fill(c:line({ {29, 46}, {34, 40} }, 1), "#a8241f")
c:paint({ ".gg.g", "gGggg", ".gggg", "..gg." }, 32, 36, { g = "#7ab55c", G = "#a4b86a" })
c:px(23, 30, "#fbf6e8"); c:px(40, 44, "#fbf6e8"); c:px(26, 51, "#fbf6e8")
c:ground(32, 57, 12, 1.5)
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
