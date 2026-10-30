-- ph/hot-sauce (Pantry sauce): small woozy bottle with a long neck, red shaker cap, red drop, flame-edged label
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "hot-sauce"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local bottle = c:rrect(20, 29, 44, 55, 6):add(c:poly({ {27, 24}, {38, 24}, {45, 33}, {19, 33} })):add(c:rect(27, 14, 37, 26)):closed(1)
c:build{
  { "glass", bottle, "glass" },
  { "sauce", bottle:shrink(2):cut(c:rect(0, 0, 63, 19)), "#d6322b", { contour = "#7a1a14", gloss = false } },
}
c:fill(c:rect(22, 34, 22, 52), "#ff7a60"); c:fill(c:rect(29, 21, 29, 28), "#ff7a60")   -- glint column
-- flame-edged label
local label = c:rrect(22, 36, 42, 50, 1):add(c:poly({ {23, 37}, {25, 32}, {28, 37} })):add(c:poly({ {28, 37}, {31, 31}, {34, 37} })):add(c:poly({ {34, 37}, {38, 32}, {41, 37} }))
c:part(label, "cream", { gloss = false, contact = false })
c:fill(c:line({ {24, 36}, {25, 34} }, 1), "#f08a24"); c:fill(c:line({ {30, 36}, {31, 33} }, 1), "#f08a24"); c:fill(c:line({ {37, 36}, {38, 34} }, 1), "#f08a24")
-- emblem: chili inside a flame ring
c:paint({
  "...f.f...",
  "..fofof..",
  ".fo...of.",
  "fo..gg.of",
  "o..rr..o.",
  "o.rRr..o.",
  "o.rr...o.",
  ".orr..o..",
  "..ooooo..",
}, 27, 39, { f = "#e0501f", o = "#f08a24", r = "#d6322b", R = "#ff8a70", g = "#4f9a45" })
-- shaker cap with its hole
c:part(c:rrect(25, 7, 39, 16, 2), "#d6322b", { contour = "#7a1a14" })
for x = 27, 37, 2 do c:px(x, 15, "#a8241f") end
c:px(32, 9, "#2a1a10")
c:seam({ {27, 16}, {37, 16} })
-- red drop running down the neck
c:part(c:rect(34, 17, 35, 19):add(c:ellipse(34.5, 20.5, 1.5, 1.5)), "#e03a2a", { flat = true })
c:px(34, 20, "#ff9a80")
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 4, N .. " failed checks")
