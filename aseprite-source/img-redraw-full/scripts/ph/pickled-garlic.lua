-- ph/pickled-garlic (Pantry pickle): bulb-shaped pot-belly jar tapering to a twisted paper neck tied with red string.
-- Redraw B: one big whole garlic bulb (segmented, purple-streaked, pointed neck, roots) in amber brine plus two loose
-- cloves lying on their sides, instead of a row of upright cloves (they read as teeth or flames).
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "pickled-garlic"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local body = c:ellipse(32, 41, 17, 15):add(c:poly({ {19, 33}, {27, 22}, {38, 22}, {46, 33} }))
local brine = c:ellipse(32, 41, 15, 13):cut(c:rect(0, 0, 63, 29))
c:build{
  { "glass", body, "glass" },
  { "brine", brine, GV.ramp("#d9a84a", { shade = "#b07a2a", deep = "#8a5a1f", bounce = "#c08a30" }), { contour = "#7a4a1f", gloss = false } },
}
c:fill(c:rect(18, 29, 46, 29):clip(c:ellipse(32, 41, 15, 13)), "#f0cc78")   -- lit brine surface
-- the bulb: fat round base, pointed papery neck, roots
local bulbR = GV.ramp("#f4f0e0", { shade = "#d8c4b8", deep = "#b89aa8", bounce = "#e0ccc0", rim = "#fbf6e8", pale = false })
local bulb = c:ellipse(32, 43, 10.5, 8.5):add(c:poly({ {27, 37}, {38, 37}, {34, 30}, {33, 27}, {32, 27}, {31, 30} }))
c:part(bulb, bulbR, { cres = 3, deep = 1, gloss = false, contact = false, contour = "#4a2c1a" })
-- clove segment lines (curved, converging at the neck and the base) with purple streaks beside them
c:fill(c:line({ {30, 33}, {26, 37}, {24, 42}, {25, 47}, {28, 50} }, 1), "#9a6a88")
c:fill(c:line({ {34, 33}, {38, 37}, {40, 42}, {39, 47}, {36, 50} }, 1), "#9a6a88")
c:fill(c:line({ {32, 31}, {32, 51} }, 1), "#b88aa8")
c:fill(c:line({ {29, 37}, {28, 42}, {29, 47} }, 1), "#c9a0b8")
c:fill(c:line({ {36, 38}, {37, 43}, {36, 47} }, 1), "#c9a0b8")
c:px(26, 40, "#fbf6e8"); c:px(26, 41, "#fbf6e8"); c:px(30, 36, "#fbf6e8")   -- sheen on the lit clove
c:paint({ "r.r.r", ".r.r." }, 30, 52, { r = "#9a6b3f" })                     -- root tuft
-- two loose cloves lying on their sides in the brine (crescents, tips pointing outward)
local cl = GV.ramp("#f4f0e0", { shade = "#d8c4b8", deep = "#b89aa8", pale = false })
c:part(c:poly({ {17, 48}, {19, 45}, {23, 45}, {25, 47}, {24, 50}, {19, 50} }), cl, { flat = true, contact = false, contour = "#4a2c1a" })
c:part(c:poly({ {40, 47}, {45, 45}, {48, 46}, {47, 50}, {42, 50}, {40, 49} }), cl, { flat = true, contact = false, contour = "#4a2c1a" })
c:px(17, 47, "#c9a070"); c:px(48, 46, "#c9a070")
-- twisted paper neck, frayed top, and red string bow
local twist = c:poly({ {26, 23}, {39, 23}, {36, 14}, {37, 10}, {28, 10}, {29, 14} })
c:part(twist, GV.ramp("#e8d8b0", { shade = "#c9b878" }), { cres = 2, deep = 1, contour = "#7a5a3a", gloss = false })
c:fill(c:line({ {30, 12}, {31, 16}, {30, 21} }, 1), "#c9b878")
c:fill(c:line({ {34, 12}, {35, 17}, {35, 21} }, 1), "#c9b878")
c:paint({ "f.f.f.f.f", ".f.f.f.f." }, 28, 8, { f = "#e8d8b0" })
c:part(c:rect(26, 21, 38, 22), "red", { flat = true, contour = false })
c:paint({ "rr...rr", ".rrkrr.", "r.....r" }, 35, 19, { r = "#d6322b", k = "#ae2a2a" })
c:gloss(body, "glass", { 20, 37 })
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
