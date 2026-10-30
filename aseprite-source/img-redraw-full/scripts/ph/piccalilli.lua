-- ph/piccalilli (Pantry pickle): faceted hexagonal jar of mustard-yellow relish with cream florets, tall lacquered mustard lid with black pinstripes and a knob, dark lacquer label with a cream cauliflower
-- redraw A: new vessel (hex jar with chamfered shoulders and base, short neck, knobbed drum lid) so it no longer matches apricot-jam's wide jar; dark label so the cauliflower is bold
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "piccalilli"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local jar  = c:poly({ {19, 27}, {46, 27}, {52, 34}, {52, 50}, {47, 56}, {18, 56}, {12, 50}, {12, 34} }):add(c:rect(22, 24, 42, 27))
local fill = c:poly({ {20, 30}, {45, 30}, {50, 35}, {50, 49}, {46, 54}, {19, 54}, {14, 49}, {14, 35} })
c:build{
  { "glass", jar, "glass" },
  { "fill",  fill, "#e8b830", { contour = "#a8701a", gloss = { 17, 36 } } },
}
-- facet edges: the hexagon's front face between two side faces
for _, x in ipairs({ 20, 44 }) do
  for y = 31, 53 do if fill:has(x, y) then c:px(x, y, "#c8901a") end end
end
c:fill(c:rect(21, 31, 21, 52), "#f5cf6a")
-- cream floret bumps and cucumber bits on the side faces and top
for _, p in ipairs({ {15,37}, {15,45}, {46,37}, {46,45}, {24,31}, {36,31} }) do
  c:paint({ ".a.", "abb", ".b." }, p[1], p[2], { a = "#fbf6e8", b = "#e0d4b0" })
end
for _, p in ipairs({ {30,31}, {16,42}, {47,42}, {25,52}, {37,52} }) do c:paint({ "gg" }, p[1], p[2], { g = "#4f9a45" }) end
-- dark lacquer label with a gold rim
c:part(c:rrect(22, 35, 42, 50, 2), GV.ramp("#3d2a1c", { rim = "#5e3a24", shade = "#2a1a10", deep = "#2a1a10", bounce = "#3d2a1c" }), { gloss = false, contact = false })
c:fill(c:rrect(23, 36, 41, 49, 2):edge(), "#e8a317")
-- emblem: cauliflower, a lumpy cream head over cupping green leaves and a pale stalk
c:paint({
  "....cc.cc....",
  "..cCccccccc..",
  ".cCcccccccccs",
  "ccccscccsccss",
  "gcccccccccccg",
  "ggsscsscsscgg",
  ".gggg.t.gggg.",
  "..ggg.t.ggg..",
  "....g.t.g....",
}, 26, 38, { c = "#f1ece0", C = "#fbfdfe", s = "#c9b98a", t = "#d8e0b0", g = "#7ab55c" })
-- tall lacquered mustard drum lid, black pinstripes, round knob
c:part(c:rrect(18, 13, 46, 24, 2), "#e8a317")
c:part(c:rrect(29, 8, 35, 13, 2), "#e8a317", { gloss = false, flat = true })
c:fill(c:rect(19, 16, 45, 16), "#2a1a10")
c:fill(c:rect(19, 21, 45, 21), "#2a1a10")
c:seam({ {20, 24}, {44, 24} })
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 4, N .. " failed checks")
