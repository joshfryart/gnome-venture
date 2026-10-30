-- ph/pickled-capers (Pantry pickle): tiny round-bellied bottle, narrow neck, cork in a wire cage, belly full of little olive caper buds
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "pickled-capers"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local body = c:ellipse(32, 42, 13, 13):add(c:rect(28, 18, 36, 31))
c:build{
  { "glass", body, "glass" },
  { "brine", c:ellipse(32, 43, 11, 10.5):cut(c:rect(0, 0, 63, 33)), "#d8e4a0", { contour = "#8a9a4a", gloss = false } },
}
c:fill(c:rect(23, 34, 41, 34):clip(c:ellipse(32, 43, 11, 10.5)), "#eef0c0")
-- caper buds: many 2 px olive dots with a lit pixel
for _, q in ipairs({ {25, 37}, {29, 35}, {34, 36}, {38, 38}, {23, 41}, {27, 40}, {31, 39}, {36, 41}, {40, 42},
                     {25, 46}, {39, 46}, {27, 50}, {31, 51}, {35, 50}, {22, 45}, {41, 47} }) do
  c:fill(c:rect(q[1], q[2], q[1] + 1, q[2] + 1), "#6a8a3a")
  c:px(q[1], q[2], "#4f9a45"); c:px(q[1] + 1, q[2] + 1, "#3d5a24")
end
-- small label with a caper bud emblem
c:part(c:rrect(25, 43, 39, 49, 1), "cream", { gloss = false, contact = false })
c:paint({
  "..g..",
  ".ooo.",
  "oOooo",
  ".ooo.",
}, 26, 44, { g = "#4f9a45", o = "#6a8a3a", O = "#a4b86a" })
c:px(30, 44, "#f4f0e0")
c:paint({ "uu.u", "", "u.uu" }, 33, 45, { u = "#7a5a3a" })
-- cork with wire cage
c:part(c:rrect(27, 11, 37, 19, 2), "#c9a96e", { contour = "#7a4a1f", gloss = false })
c:px(30, 13, "#9a6b3f"); c:px(34, 16, "#9a6b3f"); c:px(29, 17, "#9a6b3f")
c:fill(c:line({ {27, 19}, {32, 10}, {37, 19} }, 1), "#8b8f96")
c:fill(c:rect(27, 14, 37, 14), "#8b8f96")
c:px(32, 10, "#c9c5bc")
c:part(c:rect(27, 20, 37, 21), "#8b8f96", { flat = true, contour = "#3d4650" })   -- wire loop at the neck
c:px(37, 22, "#5b6470")
c:gloss(c:ellipse(32, 42, 13, 13), "glass", { 24, 36 })
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 4, N .. " failed checks")
