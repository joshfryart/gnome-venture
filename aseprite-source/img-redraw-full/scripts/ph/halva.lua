-- ph/halva (Pantry spread): round paper tub of marbled halva standing tall above the rim, a quarter cut
-- away on the right down to the tub (step notch in the silhouette, bright striped cut face), wax-paper lid leaning behind on the left, string tie
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "halva"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- wax-paper lid leaning at the back left (kept clear of the cut-away notch on the right)
local wax = c:poly({ {10, 9}, {21, 5}, {25, 15}, {13, 18} })
c:part(wax, "#f4f0e0", { gloss = false })
c:fill(c:line({ {14, 9}, {17, 16} }, 1), "#c9c5bc"); c:fill(c:line({ {18, 7}, {21, 15} }, 1), "#c9c5bc")
-- halva cylinder standing above the tub; a quarter (the right sector) is cut away right down to the tub,
-- so the silhouette itself has a step-shaped notch and the bright striped cut face shows inside it
local Cx, Cy = 31, 21                       -- centre of the top
local Bb, Af = { 46, 16 }, { 36, 28 }       -- back-right and front rim points of the cut
local body = c:ellipse(Cx, Cy, 21, 7):add(c:rect(10, Cy, 52, 40))
local gone = c:poly({ {Cx, Cy}, {61, 11}, {64, 11}, {64, 64}, {Af[1], 64}, {Af[1], Af[2]} })
local block = body:copy():cut(gone)
-- the cut face (back cut plane, facing the viewer): bright cream with chocolate and caramel veins
local face = c:poly({ {Cx, Cy}, {Bb[1] + 1, Bb[2]}, {Bb[1] + 1, 40}, {Cx, 40} }):cut(block)
c:part(face, GV.ramp("#f4e4b8", { shade = "#e2c99a", deep = "#d6b98a", rim = "#fff3c8", bounce = "#e8d8a0" }), { gloss = false, cres = 2, deep = 0, contact = false, contour = false, pale = true })
for i, d in ipairs({ 4, 8, 12, 16 }) do
  local col = (i % 2 == 1) and "#5a3a1f" or "#a8742f"
  c:fill(c:line({ {Cx, Cy + d}, {Bb[1], Bb[2] + d} }, 1):clip(face), col)
end
c:fill(c:line({ {Cx + 1, Cy}, {Bb[1], Bb[2]} }, 1), "#fff3c8")   -- lit top edge of the cut
-- the remaining halva (front-left piece and back), marbled top and side
c:part(block, "#e8d8a0", { gloss = { 15, 18 }, contact = false, contour = "#5a3a1f" })
for _, l in ipairs({ { {14, 21}, {18, 19}, {23, 21}, {27, 23} }, { {21, 16}, {26, 17}, {30, 15} }, { {16, 25}, {22, 24}, {28, 26} }, { {34, 16}, {38, 15}, {42, 16} } }) do
  c:fill(c:line(l, 2):clip(block), "#8a5a2f")
end
c:fill(c:line({ {12, 32}, {20, 34}, {28, 33}, {35, 34} }, 1):clip(block), "#a8742f")
c:fill(c:line({ {Cx, Cy}, {Af[1], Af[2]} }, 1):clip(block), "#c9a96e")
-- dark tub interior where the slice was lifted out
c:part(c:rect(Af[1] + 1, 34, 52, 37), "#5e2f1e", { flat = true, rim = false, contact = false, contour = false })
-- paper tub, ribbed card, in front
local tub = c:rrect(10, 37, 54, 55, 4)
c:part(tub, "#c9a96e", { gloss = { 13, 41 }, contact = false })
for x = 14, 50, 4 do c:fill(c:rect(x, 42, x, 53):clip(tub), "#9a6b3f") end
c:fill(c:rect(11, 37, 53, 37):clip(tub), "#e8d8b0")
-- string tie round the tub
c:fill(c:rect(11, 40, 53, 40):clip(tub), "#7a4a1f"); c:paint({ "k.k", ".k.", "k.k" }, 13, 39, { k = "#7a4a1f" })
-- label with a ring of sesame seeds
c:part(c:rrect(18, 43, 36, 53, 2), "cream", { gloss = false, contact = false })
for _, p in ipairs({ {26, 44}, {31, 46}, {29, 49}, {23, 49}, {21, 46} }) do
  c:paint({ ".s.", "sSs", ".s." }, p[1], p[2], { s = "#c9a96e", S = "#ecc58a" })
end
c:px(26, 48, "#9a6b3f"); c:px(27, 48, "#9a6b3f")
c:ground(32, 56, 22, 1.5)
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
