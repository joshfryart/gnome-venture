-- ph/dried-apricots (Pantry dried): wide low slatted fruit crate heaped with orange apricot halves cut-side up, rope handles at both ends
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local R = GV.R
local N = "dried-apricots"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local wood = GV.ramp("#9a6b3f", { shade = "#7a4a1f", deep = "#5e2f1e" })
-- rope handles behind the crate ends
c:part(c:ellipse(11, 41, 3.5, 5):cut(c:ellipse(11, 41, 1.5, 3)):cut(c:rect(12, 30, 20, 52)), "#c9a96e", { flat = true })
c:part(c:ellipse(52, 41, 3.5, 5):cut(c:ellipse(52, 41, 1.5, 3)):cut(c:rect(40, 30, 51, 52)), "#c9a96e", { flat = true })
c:part(c:rrect(11, 32, 53, 55, 2), wood, { gloss = false })
c:fill(c:rect(12, 38, 52, 38), "#7a4a1f")
-- apricot halves, back row first
local apr = GV.ramp("#e0821f", { shade = "#c8661f", rim = "#f5cf6a" })
for _, q in ipairs({ {31, 19}, {20, 26}, {41, 26}, {26, 31}, {37, 31}, {16, 34}, {47, 34} }) do
  c:part(c:ellipse(q[1], q[2], 6, 5), apr, { gloss = false, cres = 2, deep = 0, contact = false })
  c:fill(c:ellipse(q[1] + 0.5, q[2] + 0.5, 2.5, 2), "#a8541a"); c:fill(c:rect(q[1] + 1, q[2] + 1, q[2] and q[1] + 2, q[2] + 1), "#7a3a14")
  c:px(q[1] - 1, q[2] - 1, "#c8661f"); c:px(q[1] - 3, q[2] - 2, "#f5cf6a"); c:px(q[1] - 2, q[2] - 3, "#f5cf6a")
end
-- front rail with nails, gold dashes, label
c:part(c:rect(11, 43, 53, 55), GV.ramp("#b88650", { shade = "#9a6b3f", deep = "#7a4a1f" }), { gloss = false })
c:fill(c:rect(12, 49, 52, 49), "#9a6b3f")
c:seam({ {13, 45}, {51, 45} })
for _, x in ipairs({ 14, 50 }) do c:px(x, 47, "#2a1a10"); c:px(x, 52, "#2a1a10") end
c:part(c:rect(24, 46, 40, 53), "cream", { gloss = false, contact = false })
c:paint({ "...g", ".oog", "oOoo", "oooo", ".oo." }, 30, 47, { o = "#e0821f", O = "#f5cf6a", g = "#4f9a45" })
c:ground(32, 57, 22, 1.5)
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
