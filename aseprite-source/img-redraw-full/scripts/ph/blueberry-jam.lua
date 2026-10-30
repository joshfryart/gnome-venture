-- ph/blueberry-jam (Pantry jam): wide squat jar under a gingham cloth cap tied with string, berries pressed to the glass
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "blueberry-jam"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
-- cloth: puffed crown, gathered at the neck, a skirt with scalloped hem and two square corners hanging past the rim
local cap = c:ellipse(32, 20, 14, 6):add(c:rect(20, 21, 44, 26))
cap:add(c:poly({ {19, 25}, {46, 25}, {54, 33}, {10, 33} }))
for _, x in ipairs({ 15, 21, 27, 33, 39, 45, 50 }) do cap:add(c:ellipse(x, 33, 3, 2)) end
cap:add(c:poly({ {8, 31}, {15, 31}, {9, 40} })):add(c:poly({ {50, 31}, {57, 31}, {55, 40} }))
local p = c:build{
  { "glass", c:rrect(12, 30, 52, 54, 9), "glass" },
  { "jam",   c:rrect(14, 33, 50, 52, 7), "#4e3a8a", { contour = "#291d4a", gloss = false } },
  { "label", c:rrect(19, 39, 45, 49, 2), "cream", { gloss = false, contact = false } },
  { "cap",   cap, "#a894dc", { gloss = false } },
}
-- whole berries pressed to the glass: 3 px beads with one glint each
for _, b in ipairs({ {16, 38}, {16, 46}, {21, 50}, {29, 51}, {37, 51}, {44, 50}, {48, 44}, {47, 37} }) do
  c:paint({ ".b.", "bgb", ".b." }, b[1], b[2], { b = "#7a5cc0", g = "#c3b2ea" })
end
-- gingham: 3 px checks, darker where the crescent shades the cloth
local R = p.cap.r
cap:each(function(x, y)
  local cur = c:get(x, y)
  local a = (x // 3) % 2 + (y // 3) % 2
  if cur == R.base or cur == R.rim then
    c:px(x, y, ({ "#e6defa", "#c3b2ea", "#7a5cc0" })[a + 1])
  elseif cur == R.shade or cur == R.deep or cur == R.bounce then
    c:px(x, y, ({ "#a894dc", "#7b66b4", "#54447f" })[a + 1])
  end
end)
-- string round the gathered neck, bow on the right
c:fill(c:rect(19, 26, 46, 26), "#c9a96e")
c:paint({
  ".bb...bb.",
  "b..b.b..b",
  "b...k...b",
  ".bbskbbs.",
  "...s.s...",
  "..s...s..",
}, 37, 23, { b = "#c9a96e", s = "#9a6b3f", k = "#7a4a1f" })
-- label (redraw A): one big side-view blueberry with its crown sticking up, a small one behind, and a leaf.
-- Side view on purpose: a dark disc centred in an oval read as an eye at 1x.
c:paint({
  "...gg",
  ".gggg",
  "ggggG",
  "gggG.",
  ".gG..",
}, 21, 41, { g = "#4f9a45", G = "#2f6a3a" })
c:paint({
  "..k.k.k..",
  "..kkkkk..",
  ".bbbbbbb.",
  "bLLbbbbbb",
  "bLbbbbbbs",
  "bbbbbbbbs",
  "bbbbbbbss",
  ".bbbbbss.",
}, 27, 40, { b = "#5a4aa0", L = "#a894dc", s = "#2e2260", k = "#2a1a10" })
c:paint({
  ".k.k.",
  ".kkk.",
  "bbbbb",
  "bLbbs",
  "bbbbs",
  ".bss.",
}, 37, 42, { b = "#5a4aa0", L = "#a894dc", s = "#2e2260", k = "#2a1a10" })
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
