-- ph/hibiscus-cordial (Pantry cordial): crown-capped longneck with an S-curve shoulder, crimped silver cap, crimson hibiscus cordial, five-petal flower oval label
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local R = GV.R
local N = "hibiscus-cordial"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local glass = c:rrect(20, 30, 44, 56, 6):add(c:rect(28, 12, 36, 24))
glass:add(c:poly({ {28, 22}, {37, 22}, {40, 25}, {43, 29}, {45, 33}, {19, 33}, {21, 29}, {24, 25} }))
c:build{
  { "glass",  glass, "#d8ecf0", { pale = false } },
  { "liquid", c:rrect(22, 32, 42, 54, 5), GV.ramp("#a8241f", { gloss = "#f6b8cf", rim = "#e46a9b" }), { contour = "#7a1a16", gloss = false } },
  { "label",  c:ellipse(32, 44, 8.5, 7.5), "cream", { gloss = false, contact = false } },
}
c:fill(c:rect(24, 34, 25, 50), "#e46a9b")
-- crown cap with serrated lower edge
c:part(c:rect(26, 7, 38, 12):add(c:ascii({ "x.x.x.x.x.x.x" }, 26, 13)), "stone", { gloss = false, cres = 2 })
c:fill(c:rect(27, 8, 37, 8), "#c9c5bc"); c:px(28, 9, "#eef0ec")
c:seam({ {28, 15}, {36, 15} }, { free = true })
-- hibiscus: five round petals, gold centre, stamen
for _, d in ipairs({ {0, -4}, {4, -1}, {2, 4}, {-3, 4}, {-4, -1} }) do
  c:paint({ ".pp.", "pPpp", "pppp", ".pq." }, 30 + d[1], 42 + d[2], { p = "#e46a9b", P = "#f6b8cf", q = "#c8527f" })
end
c:fill(c:rect(31, 43, 32, 44), "#f5cf6a")
c:fill(c:line({ {33, 43}, {35, 40} }, 1), "#e0501f"); c:px(35, 39, "#f5cf6a")
c:ground(32, 57, 12, 1.5)
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
