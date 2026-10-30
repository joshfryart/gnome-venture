-- ph/quince-paste (Pantry jam): low wooden box, amber-pink slab inside, sliding lid pulled half out to the right, a cut slice leaning on the front
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "quince-paste"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local slice = c:poly({ {14, 41}, {26, 37}, {29, 55}, {17, 56} })
c:build{
  { "inside", c:rect(8, 22, 50, 34), "#7a4a1f", { gloss = false, rim = false } },
  { "slab",   c:rect(10, 24, 48, 34), "#c8704a", { gloss = false, contour = "#5e2f1e" } },
  { "paper",  c:poly({ {10, 24}, {19, 24}, {10, 31} }), "cream", { gloss = false } },
  { "box",    c:rrect(8, 35, 50, 54, 2), "soil", { gloss = false } },
  { "lid",    c:rrect(36, 19, 55, 25, 1), "#9a6b3f", { gloss = false } },
  { "slice",  slice, "#d98860", { gloss = false } },
  { "label",  c:rect(35, 40, 47, 50), "cream", { gloss = false, contact = false } },
}
c:fill(c:rect(19, 25, 35, 25), "#e0a070")              -- lit top edge of the slab
c:fill(c:rect(12, 32, 46, 32), "#e0a070")              -- cut face highlight
c:fill(c:rect(23, 28, 23, 33), "#a8461a"); c:fill(c:rect(24, 28, 24, 33), "#e0a070")   -- knife cut where the slice came out
for _, y in ipairs({ 40, 45, 50 }) do                  -- wood grain on the front
  for x = 10, 48 do if c:get(x, y) == "#9a6b3f" and (x + y) % 9 ~= 0 then c:px(x, y, "#b0623a") end end
end
for x = 38, 53, 4 do c:px(x, 23, "#7a4a1f") end         -- lid grain
c:paint({ "kk", "kk" }, 51, 21, { k = "#4e2a16" })      -- notch handle
c:fill(c:rect(37, 20, 54, 20), "#c98a4a")
-- slice: lit top face, cream wrapper strip at its foot
c:fill(c:line({ {15, 41}, {25, 38} }, 1), "#e0a070")
c:fill(c:poly({ {17, 53}, {29, 53}, {29, 55}, {17, 56} }):clip(slice), "#e6d4ac")
c:seam({ {9, 36}, {49, 36} })                          -- box joint
-- label: pear-shaped quince with a leaf
c:paint({
  "...kgg..",
  "...k.g..",
  "..yyy...",
  "..yOyy..",
  ".yyyyyy.",
  "yyyyyyys",
  "yyyyyyss",
  ".yyysss.",
  "..ssss..",
}, 37, 40, { y = "#e8a317", O = "#f5cf6a", s = "#d0862a", g = "#4f9a45", k = "#7a4a1f" })
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
