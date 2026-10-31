-- ph/pickled-bamboo-shoots, redraw A (2.2.1 leftovers, Opus medium): upright green bamboo tube with two raised
-- node rings, a cut window showing ivory shoot slices, a leaf cap tied with twine and one long leaf sweeping right.
local HERE = debug.getinfo(1, "S").source:sub(2):match("(.*/)")
local D = HERE .. "../../../"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N, V = "pickled-bamboo-shoots", "A"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local bam = GV.ramp("#8cbc4c", { gloss = "#e4f0a0", dot = "#f4f8d0" })
local leaf = GV.ramp("#3f8a3e")
-- long leaf behind, sweeping up to the right
c:part(c:poly({ {34, 16}, {44, 8}, {56, 5}, {50, 12}, {40, 19} }), leaf, { flat = true, contact = false })
c:fill(c:line({ {38, 15}, {54, 6} }, 1), "#7ab55c")
local tube = c:rrect(19, 18, 43, 56, 3)
c:part(tube, bam, { gloss = { 22, 24 } })
-- node rings
for _, y in ipairs({ 30, 47 }) do
  c:part(c:rrect(18, y, 44, y + 2, 1), bam, { flat = true, contact = false })
  c:fill(c:rect(19, y + 2, 43, y + 2), "#4a8a3e")
end
-- window with shoot slices
c:part(c:rrect(24, 35, 38, 44, 2), "#5e3a1e", { flat = true, rim = false, contact = false, contour = "#2a1a10" })
local ivory = GV.ramp("#f2e6c0", { rim = "#fff3c8" })
for _, s in ipairs({ {27, 38}, {32, 37}, {35, 41}, {29, 42} }) do
  c:part(c:poly({ {s[1] - 2, s[2] + 2}, {s[1] + 3, s[2] + 2}, {s[1] + 1, s[2] - 2} }), ivory, { flat = true, contact = false, contour = false })
end
-- leaf cap over the mouth, twine
c:part(c:ellipse(31, 17, 14, 6):cut(c:rect(0, 21, 63, 63)):add(c:rect(17, 17, 45, 21)), leaf, { gloss = false, cres = 2 })
c:fill(c:rect(18, 21, 44, 22), "#c9a96e")
c:fill(c:line({ {21, 21}, {23, 25} }, 1), "#c9a96e")
c:ground(31, 57, 15, 1.5)
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph-redraw-" .. V .. "/") .. N .. ".aseprite", (P.out or D .. "img-redraw-full/redraw-2.2.1/" .. V .. "/") .. N .. ".png")
print(N, V, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
