-- ph/lingonberry-cordial (Pantry cordial): tall slim dark-green wine bottle, neck dipped in dripping red wax, bright red lingonberry cordial, sprig label
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local R = GV.R
local N = "lingonberry-cordial"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- dark green wine-bottle glass (spec), clearly visible as a long green neck and a 2-3 px rim round
-- the red cordial: at 1x this is a green bottle with a red wax top, unlike the clear crown-cap hibiscus
local glass = c:rrect(24, 25, 40, 56, 5):add(c:rect(29, 10, 35, 26)):add(c:poly({ {29, 20}, {36, 20}, {41, 29}, {23, 29} }))
c:build{
  { "glass",  glass, GV.ramp("#2f6a3a", { gloss = "#a4d68a", dot = "#c8ecb0", rim = "#4f9a45", shade = "#1f4a32", deep = "#1f3f3a", bounce = "#2f5a2a" }), { pale = false, gloss = { 26, 30 } } },
  { "liquid", c:rrect(27, 31, 38, 53, 3), GV.ramp("#d6322b", { shade = "#a8241f", gloss = "#ff9158", rim = "#f2793a" }), { contour = "#6b1b2c", gloss = false } },
  { "label",  c:rect(26, 38, 38, 50), "cream", { gloss = false, contact = false } },
}
c:fill(c:rect(30, 18, 30, 25), "#4f9a45")   -- light down the green neck
-- bulbous wax dip with two drips down the neck
local wax = c:rrect(26, 6, 38, 15, 4):add(c:rrect(28, 15, 29, 21, 1)):add(c:rrect(35, 15, 36, 18, 1)):add(c:rect(27, 13, 37, 16))
c:part(wax, GV.ramp("#d6322b", { shade = "#a8241f", deep = "#6b1b2c", rim = "#f2793a", gloss = "#ff9158", dot = "#ffc27a" }), { cres = 2, gloss = { 29, 8 } })
-- sprig: stem, three leaves, three berries
c:fill(c:line({ {28, 48}, {36, 41} }, 1), "#4f9a45")
c:paint({ "gg", "gg" }, 27, 45, { g = "#4f9a45" }); c:paint({ "gg" }, 34, 46, { g = "#4f9a45" }); c:paint({ "gg" }, 35, 40, { g = "#4f9a45" })
for _, b in ipairs({ {29, 42}, {32, 40}, {34, 44} }) do
  c:paint({ ".r.", "rRr", ".r." }, b[1] - 1, b[2] - 1, { r = "#d6322b", R = "#f2793a" })
end
c:ground(32, 57, 9, 1.5)
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
