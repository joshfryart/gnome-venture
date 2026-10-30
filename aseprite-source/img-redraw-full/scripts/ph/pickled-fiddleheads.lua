-- ph/pickled-fiddleheads (Pantry pickle): jar sealed with lumpy dripping green wax, fern coils standing in pale brine
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local R = GV.R
local N = "pickled-fiddleheads"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
c:build{
  { "glass", c:rrect(17, 24, 47, 56, 7):add(c:rect(20, 22, 44, 25)), "glass" },
  { "brine", c:rrect(19, 30, 45, 54, 5), "#e0f0d0", { contour = "#8fb4a0", gloss = false } },
}
-- fiddleheads: three 2 px coils on stalks, the stalks run down behind the label
local coil = {
  ".GGGG..",
  "GLLLGG.",
  "GL..LG.",
  "GL.GLG.",
  "GL.GG..",
  "GL.....",
  ".GL....",
  "..GL...",
  "..GL...",
  "..GL...",
  "..GL...",
  "..GL...",
}
for _, p in ipairs({ {21, 31}, {29, 29}, {37, 32} }) do
  c:paint(coil, p[1], p[2], { G = "#2f5a2a", L = "#4f9a45" })
  c:px(p[1] + 1, p[2] + 1, "#c8d77a")
end
c:part(c:rrect(22, 43, 42, 53, 2), "cream", { gloss = false, contact = false })
c:paint({   -- label emblem: small coil on a stalk
  ".ggg.",
  "gLLgg",
  "gL.Lg",
  "gL.g.",
  ".gL..",
  "..gL.",
  "..gL.",
}, 26, 45, { g = "#2f5a2a", L = "#4f9a45" })
c:paint({ "uuu.uu", "", "uu.uuu" }, 33, 47, { u = "#7a5a3a" })
-- cork lid, then the green wax poured over it: lumpy dome with three drips down the neck
c:part(c:rrect(20, 17, 44, 26, 2), "soil", { gloss = false })
local wax = c:rrect(19, 11, 45, 21, 5):add(c:ellipse(26, 11, 4, 2)):add(c:ellipse(37, 11, 5, 2))
wax:add(c:rrect(21, 19, 24, 30, 1)):add(c:rrect(31, 19, 34, 32, 1)):add(c:rrect(40, 19, 43, 28, 1))
c:part(wax, "leaf", { gloss = { 23, 13 } })
c:px(22, 30, "#a4b86a"); c:px(32, 32, "#a4b86a"); c:px(41, 28, "#a4b86a")   -- lit drip beads
for _, b in ipairs({ {26, 41}, {35, 40}, {41, 47} }) do c:px(b[1], b[2], "#f6fbf0") end   -- brine bubbles
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
