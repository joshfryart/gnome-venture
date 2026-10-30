-- ph/blackcurrant-cordial (Pantry cordial): squat square-shouldered apothecary bottle, ribbed dark screw cap, near-black purple cordial, berry-cluster label
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local R = GV.R
local N = "blackcurrant-cordial"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local glass = c:rrect(14, 27, 50, 56, 4):add(c:rect(24, 19, 40, 28))
c:build{
  { "glass",  glass, "#c8dde4", { pale = false } },
  { "liquid", c:rrect(16, 32, 48, 54, 3), GV.ramp("#3a1f5a", { rim = "#5a3a8a" }), { contour = "#2a1640", gloss = false } },
}
c:fill(c:rect(18, 34, 20, 50), "#7a5cc0"); c:fill(c:rect(18, 34, 18, 50), "#a894dc")   -- sheen band
c:part(c:rect(20, 38, 44, 50), "cream", { gloss = false, contact = false, contour = "#4a2c1a" })
c:fill(c:rect(21, 39, 43, 39):add(c:rect(21, 49, 43, 49)), "#d8c49a")
c:part(c:rrect(22, 10, 42, 20, 2), GV.ramp("#4a3a30"), { gloss = false })
for _, x in ipairs({ 25, 29, 33, 37 }) do c:fill(c:rect(x, 12, x, 18), "#2a1a10") end
c:fill(c:rect(24, 11, 40, 11), "#6a5a4a")
c:seam({ {23, 21}, {41, 21} }, { free = true })
-- three berries + leaf
for _, b in ipairs({ {26, 43}, {34, 43}, {30, 40} }) do
  c:paint({ ".bb.", "bBbb", "bbbb", ".bb." }, b[1], b[2], { b = "#3a1f5a", B = "#7a5cc0" })
end
c:paint({ "ggg.", ".ggg" }, 34, 40, { g = "#4f9a45" })
c:ground(32, 57, 18, 1.5)
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
