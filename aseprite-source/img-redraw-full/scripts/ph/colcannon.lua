-- ph/colcannon (Gourmand P2 dish): a round, soft dome of mashed potato on a small plate, flecked all over with
-- chopped kale, a butter pat melting in a well pressed into the top
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "colcannon"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- plate
local plate = c:ellipse(31.5, 47, 24, 6.5)
c:part(plate, GV.ramp("#e6e2d6", { dot = "#f6f2e6" }), { cres = 2, gloss = false })
c:fill(c:ellipse(31.5, 46, 18, 4):edge(), "#c9bfa8")                         -- plate well ring
c:seam({ {10, 49}, {53, 49} }, { gap = "#c9bfa8" })
-- mash: a round dome (half-ellipse) with soft scalloped lumps on its outline
local dome = c:ellipse(31.5, 36, 19, 15):clip(c:rect(0, 0, 63, 46))
for _, b in ipairs({ {15, 40, 2}, {48, 40, 2}, {22, 25, 2}, {41, 25, 2} }) do dome:add(c:ellipse(b[1], b[2], b[3], b[3])) end
c:part(dome, GV.ramp("#ecdcb0", { dot = "#fbf6e8" }), { contour = "#4a2c1a", gloss = { 19, 31 }, cres = 4 })
-- soft spoon swirls following the dome
for _, l in ipairs({ { {17, 41}, {20, 36}, {25, 33} }, { {38, 33}, {43, 36}, {46, 41} }, { {24, 44}, {31, 42}, {38, 44} } }) do
  c:fill(c:line(l, 1), "#d4bc88")
end
-- butter well: dark rim pressed into the top, melted pool, a small pat sitting in it
c:fill(c:ellipse(31.5, 27, 7, 2.5), "#c8a468")
c:fill(c:ellipse(31.5, 26, 7, 1.5):clip(c:rect(0, 0, 63, 26)), "#a8844a")   -- back wall of the well
local pool = c:ellipse(31.5, 27.5, 5.5, 1.5)
c:fill(pool, "#f2c230")
c:fill(pool:copy():cut(pool:shift(-1, -1)), "#d89a18")
c:paint({
  ".HHhh.",
  "Hhhhhs",
  "hhhhss",
}, 29, 24, { H = "#fff3c8", h = "#fbe27a", s = "#e8b830" })
c:px(30, 24, "#ffffff")                                                     -- the single white glint
c:fill(c:line({ {37, 29}, {38, 32}, {38, 34} }, 2), "#f2c230")               -- butter trickle
c:px(38, 34, "#d89a18")
-- chopped kale flecks folded all through the mash (dark leaf bits with a lit edge)
local fl = {
  {19, 32}, {25, 31}, {41, 31}, {44, 35}, {16, 38}, {22, 36}, {29, 34}, {35, 36}, {41, 39}, {46, 40},
  {20, 42}, {27, 40}, {33, 42}, {39, 43}, {24, 44}, {32, 38}, {36, 31},
}
for i, p in ipairs(fl) do
  if i % 3 == 0 then
    c:paint({ "gd", "dd" }, p[1], p[2], { g = "#5f9a45", d = "#2f5a2a" })
  elseif i % 3 == 1 then
    c:paint({ "gdd", ".dd" }, p[1], p[2], { g = "#5f9a45", d = "#2f5a2a" })
  else
    c:paint({ ".gd", "dd." }, p[1], p[2], { g = "#5f9a45", d = "#2f5a2a" })
  end
end
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
