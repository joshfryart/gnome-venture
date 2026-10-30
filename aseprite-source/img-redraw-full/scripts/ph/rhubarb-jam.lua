-- ph/rhubarb-jam (Pantry jam): top-heavy tumbler (wide mouth, narrow foot) of pink jam with strand lines, ribbed pink enamel lid
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "rhubarb-jam"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local glass = c:poly({ {16, 20}, {49, 20}, {44, 52}, {41, 55}, {24, 55}, {21, 52} })
local fill  = c:poly({ {18, 24}, {47, 24}, {42, 51}, {40, 53}, {25, 53}, {23, 51} })
c:build{
  { "glass", glass, "glass" },
  { "jam",   fill, "#d85a70", { contour = "#8a2a4a", gloss = { 21, 27 } } },
  { "label", c:rect(23, 33, 41, 45), "cream", { gloss = false, contact = false } },
  { "lid",   c:rrect(14, 11, 50, 21, 3), "#e46a9b", { gloss = { 18, 13 } } },
}
-- rhubarb strands slanting down the jam (skip the label)
for _, x0 in ipairs({ 21, 27, 34, 40, 45 }) do
  for i = 0, 28 do
    local x, y = x0 - math.floor(i / 7), 24 + i
    if fill:has(x, y) and not (y >= 33 and y <= 45 and x >= 23 and x <= 41) and c:get(x, y) ~= "#8a2a4a" then c:px(x, y, "#e88a98") end
  end
end
for x = 18, 47, 3 do c:fill(c:rect(x, 14, x, 19), "#c04a7a") end   -- enamel ribs
c:seam({ {15, 20}, {49, 20} })
-- label: rhubarb stalk with its leaf fan
c:paint({
  "gg.gLg.gg",
  ".gggggggs",
  "..ggggs..",
  "....r....",
  "....rr...",
  "...rr....",
  "...rq....",
  "...rq....",
  "...qq....",
}, 28, 34, { g = "#4f9a45", L = "#a4b86a", s = "#2f6a3a", r = "#d6322b", q = "#ae2a2a" })
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
