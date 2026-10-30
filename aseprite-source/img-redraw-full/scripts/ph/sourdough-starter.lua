-- ph/sourdough-starter (Pantry ferment): tall straight jar, bubbly dough risen into a dome, coral rubber band, lid resting askew
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local R = GV.R
local N = "sourdough-starter"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local dough = GV.ramp("#f4f0e0", { shade = "#e0d4b0", deep = "#c9b878", bounce = "#e6d4ac", dot = "#fbf6e8" })
c:part(c:rrect(17, 15, 47, 56, 4), "glass", { gloss = false })
local d = c:rrect(19, 28, 45, 54, 3):add(c:ellipse(32, 27, 13, 6))
c:part(d, dough, { gloss = false, contour = "#9a8a50" })
-- bubbles: rings, a few cut open at the glass
for _, b in ipairs({ {24, 29}, {37, 25}, {30, 38}, {40, 41}, {21, 40}, {31, 24} }) do
  c:paint({ ".kk.", "k..k", "k..k", ".kk." }, b[1] - 1, b[2] - 1, { k = "#b8a060" })
end
c:px(31, 39, "#fbf6e8"); c:px(26, 22, "#e0d4b0"); c:px(36, 20, "#e0d4b0")
c:fill(c:rect(43, 33, 44, 33), "#c9b878")
-- coral rubber band marking the old level
c:part(c:rect(16, 34, 48, 36), GV.ramp("#e8604a", { rim = "#f2896a" }), { flat = true, contact = false })
-- wheat label
c:part(c:rect(22, 43, 42, 54), GV.ramp("#f1ece0", { dot = "#fbf6e8" }), { gloss = false, contact = false })
c:paint({
  "...e.e....",
  "....s.....",
  "...esE....",
  "....s.....",
  "...esE....",
  "....s.....",
  "....s.....",
}, 24, 45, { e = "#c9a030", E = "#e8c060", s = "#9a6b3f" })
c:paint({ "uuu.uu", "", "uu.uuu" }, 33, 47, { u = "#7a5a3a" })
c:gloss(c:rrect(17, 15, 47, 56, 4), "glass", { 20, 22 })
-- loose lid tilted, right side raised
local lid = c:poly({ {16, 14}, {47, 11}, {49, 15}, {17, 18} }):add(c:poly({ {22, 13}, {42, 11}, {42, 9}, {22, 11} }))
c:part(lid, "#c9a96e", { gloss = { 20, 13 } })
c:ground(32, 57, 16, 1.5)
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
