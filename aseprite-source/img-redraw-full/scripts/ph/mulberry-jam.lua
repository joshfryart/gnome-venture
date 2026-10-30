-- ph/mulberry-jam (Pantry jam): wide square-sided jar with clipped corners, inky bumpy fill, glossy black bakelite lid with a hex knob
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "mulberry-jam"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local function chamfer(x0, y0, x1, y1, k)
  return c:poly({ {x0 + k, y0}, {x1 + 1 - k, y0}, {x1 + 1, y0 + k}, {x1 + 1, y1 + 1 - k}, {x1 + 1 - k, y1 + 1}, {x0 + k, y1 + 1}, {x0, y1 + 1 - k}, {x0, y0 + k} })
end
c:build{
  { "glass", chamfer(14, 21, 50, 54, 4), "glass" },
  { "jam",   chamfer(16, 24, 48, 52, 3), "#3a2a5a", { contour = "#1e1438", gloss = false } },
  { "label", c:rect(21, 33, 43, 45), "cream", { gloss = false, contact = false } },
  { "lid",   c:rrect(13, 13, 51, 22, 2), "#3d2a1c", { gloss = false } },
  { "knob",  c:poly({ {29, 7}, {35, 7}, {37, 10}, {35, 14}, {29, 14}, {27, 10} }), "#3d2a1c", { gloss = false } },
}
for _, b in ipairs({ {19, 27}, {25, 29}, {32, 27}, {39, 29}, {45, 27}, {19, 48}, {26, 48}, {33, 49}, {40, 48}, {45, 47} }) do
  c:paint({ "MM", "mM" }, b[1], b[2], { M = "#5a4a8a", m = "#7b66b4" })   -- drupelet bumps
end
c:fill(c:rect(16, 15, 30, 15), "#5b6470"); c:px(31, 15, "#8b8f96")          -- bakelite gloss streak
c:fill(c:rect(16, 21, 48, 21), "#291d4a")
c:px(30, 9, "#8b8f96"); c:px(31, 9, "#5b6470")
c:seam({ {15, 20}, {49, 20} })
c:fill(c:line({ {15, 24}, {17, 22} }, 1), "#eef8f2")   -- lit chamfer, upper left
-- label: long bumpy mulberry with a green stalk
c:paint({
  ".......gg",
  "......g..",
  "....mMm..",
  "...mMmMm.",
  "..mMmMmm.",
  ".mMmMmm..",
  "mmMmMm...",
  "mmmmm....",
  ".mm......",
}, 27, 34, { m = "#3a2a5a", M = "#7b66b4", g = "#4f9a45" })
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
