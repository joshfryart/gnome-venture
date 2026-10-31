-- ph/tahini, redraw A (2.2.1 leftovers, Opus medium): tall silver tin, sesame-paper wrapper with a big seed
-- emblem, foil top peeled up to the right with a pull-ring.
local HERE = debug.getinfo(1, "S").source:sub(2):match("(.*/)")
local D = HERE .. "../../../"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N, V = "tahini", "A"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local tin = GV.ramp("#aab2bc", { rim = "#dfe4ea", gloss = "#f4f6f8", dot = "#fbfdfe" })
local paper = GV.ramp("#d6b98a")
local p = c:build{
  { "tin", c:rrect(19, 15, 45, 56, 3), tin, { gloss = false } },
  { "wrap", c:rect(19, 24, 45, 48), paper, { gloss = false, contact = false } },
}
-- tin rims top and bottom
c:fill(c:rect(20, 16, 44, 16), "#dfe4ea"); c:fill(c:rect(20, 51, 44, 51), "#dfe4ea")
c:fill(c:rect(21, 17, 22, 22), "#f4f6f8"); c:fill(c:rect(21, 50, 22, 54), "#f4f6f8")
-- big sesame seed emblem on the wrapper (teardrop, point up)
local seed = c:ellipse(32, 38, 6, 7):add(c:poly({ {28, 34}, {36, 34}, {32, 27} }))
c:part(seed, GV.ramp("#f4e6c4", { rim = "#fff3c8" }), { gloss = { 29, 34 }, contour = "#7a4a1f", contact = false })
c:fill(c:line({ {32, 31}, {32, 42} }, 1), "#c9a96e")
-- seed spray
for _, s in ipairs({ {23, 28}, {41, 29}, {24, 44}, {40, 44}, {22, 36}, {42, 37} }) do
  c:paint({ ".s", "ss", "s." }, s[1], s[2], { s = "#7a4a1f" })
end
-- foil top peeled back up to the right
local foil = c:poly({ {30, 15}, {44, 5}, {49, 8}, {46, 12}, {40, 16} })
c:part(foil, tin, { flat = true, contact = false })
c:fill(c:line({ {33, 14}, {44, 7} }, 1), "#f4f6f8")
-- pull ring on the lid
local ring = c:ellipse(25, 11, 5, 3.5):cut(c:ellipse(25, 11, 2.5, 1.5))
c:part(ring, tin, { flat = true, contact = false })
c:ground(32, 57, 15, 1.5)
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph-redraw-" .. V .. "/") .. N .. ".aseprite", (P.out or D .. "img-redraw-full/redraw-2.2.1/" .. V .. "/") .. N .. ".png")
print(N, V, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
