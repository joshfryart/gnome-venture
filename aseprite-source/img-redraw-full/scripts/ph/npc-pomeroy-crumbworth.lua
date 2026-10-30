-- ph/npc-pomeroy-crumbworth (Gourmand bust): round honey-brown dormouse food writer, big ears, white napkin
-- tucked at the chin, mustard waistcoat with a row of little pockets, silver tasting spoon on a watch chain
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local R = GV.R
local N, MARGIN = "npc-pomeroy-crumbworth", 2
local c = GV.canvas{ w = 80, h = 100, mode = "bust" }
-- backdrop: spec #c9a96e read as a lion mane against the honey fur; pale lilac keeps the head clear
c:part(c:ellipse(39.5, 50, 34, 34), GV.ramp("#b9a6d6"), { gloss = false, rim = false, bounce = false, solid = true, contact = false })
-- waistcoat body, bleeding off the bottom
local body = c:rrect(8, 74, 72, 104, 14)
local mustard = GV.ramp("#d9a21a", { shade = "#b07a10", deep = "#7a4a10" })
local bp = c:part(body, mustard, { gloss = { 16, 80 } })
-- lapels: darker V either side of the napkin
c:part(c:poly({ {22, 74}, {30, 74}, {40, 96}, {36, 100}, {24, 100} }), GV.ramp("#b07a10", { shade = "#8a5a10", deep = "#5e3a10" }), { gloss = false, contact = false, cres = 3, deep = 0 })
c:part(c:poly({ {50, 74}, {58, 74}, {56, 100}, {44, 100}, {40, 96} }), GV.ramp("#b07a10", { shade = "#8a5a10", deep = "#5e3a10" }), { gloss = false, contact = false, cres = 3, deep = 0 })
c:seam({ {29, 75}, {39, 95} }); c:seam({ {51, 75}, {41, 95} })
c:button(38, 95)
-- pockets: five little squares with cream label ticks
for i, x in ipairs({ 12, 18, 58, 64, 69 }) do
  if x <= 70 then
    c:fill(c:rect(x, 88, x + 3, 91), "#8c4a1a"); c:fill(c:rect(x, 88, x + 3, 88), "#a8582f")
    c:fill(c:rect(x + 1, 86, x + 2, 86), "#f1ece0")
  end
end
-- napkin bib tucked under the chin, knots at the two top corners
local nap = c:poly({ {16, 70}, {65, 70}, {40, 99} })
local np = c:part(nap, GV.ramp("#f8f4ea", { shade = "#d7d0bd", bounce = "#e6dccb", deep = "#b8a888" }), { stitch = true, gloss = { 32, 75 } })
c:fill(c:line({ {40, 76}, {40, 94} }, 1), "#d7d0bd")
c:part(c:ellipse(18.5, 71.5, 3, 3), "cream", { gloss = false, contact = false })
c:part(c:ellipse(62, 71.5, 3, 3), "cream", { gloss = false, contact = false })
-- watch chain and tasting spoon at the right
c:fill(c:line({ {60, 77}, {62, 82}, {61, 87}, {58, 91} }, 1), "#c9d0d6")
for _, p in ipairs({ {61, 79}, {62, 84}, {60, 89} }) do c:px(p[1], p[2], "#8d97a0") end
local silver = GV.ramp("#dfe5ea", { shade = "#a9b3bc", deep = "#7d8791", bounce = "#b9c2ca", rim = "#f4f7f9", gloss = "#f8fbfc", dot = "#fbfdfe", pale = false })
c:part(c:rect(57, 90, 58, 92), silver, { flat = true, contact = false })
c:part(c:ellipse(57.5, 96, 3, 3.5), silver, { gloss = false, contact = false })
c:px(56, 95, "#fbfdfe"); c:px(56, 96, "#fbfdfe")
-- ears (behind the head), pink inner
local ears = c:ellipse(21, 31, 10, 10):add(c:ellipse(59, 31, 10, 10))
c:part(ears, "wood", { gloss = false })
c:fill(c:ellipse(21, 32, 5.5, 5.5), "#e0a8a0"); c:fill(c:ellipse(59, 32, 5.5, 5.5), "#e0a8a0")
c:fill(c:ellipse(22, 34, 3, 3), "#c4838a"); c:fill(c:ellipse(60, 34, 3, 3), "#c4838a")
-- head: wide round honey-brown, pale muzzle
local head = c:ellipse(40, 50, 25.5, 23)
c:part(head, "wood", { gloss = { 22, 36 } })
c:part(c:ellipse(40, 60, 13, 9), GV.ramp("#f1e2c4", { shade = "#d9c49a", bounce = "#e6d4ac", deep = "#b09a70" }), { gloss = false, contact = false })
-- fussy raised brows
-- spec drew the outer ends raised, which reads cross; a short arch with the inner end lifted reads fussy instead
c:fill(c:line({ {25, 40}, {27, 38}, {31, 38}, {32, 39} }, 1), "#3a2410"); c:fill(c:line({ {25, 41}, {27, 39} }, 1), "#3a2410")
c:fill(c:line({ {55, 40}, {53, 38}, {49, 38}, {48, 39} }, 1), "#3a2410"); c:fill(c:line({ {55, 41}, {53, 39} }, 1), "#3a2410")
-- locked eyes, set wide
c:eye(27, 44); c:eye(48, 44)
-- nose, whiskers, prim mouth
c:paint({ ".nn.", "nNnn", "nnns", ".ss." }, 38, 53, { n = "#c4636b", N = "#e8a0a0", s = "#8a3a44" })
for _, w in ipairs({ { {33, 58}, {22, 55} }, { {33, 60}, {21, 61} }, { {34, 62}, {23, 66} }, { {47, 58}, {58, 55} }, { {47, 60}, {59, 61} }, { {46, 62}, {57, 66} } }) do
  c:fill(c:line(w, 1), "#6b4528")
end
c:fill(c:rect(37, 65, 43, 65), "#6b4528"); c:px(36, 64, "#6b4528"); c:px(44, 64, "#6b4528")
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
local side = math.min(t.bbox[1], t.bbox[2], t.w - 1 - t.bbox[3])   -- bust bleeds off the bottom
assert(t.semi == 0 and side >= MARGIN and t.bw <= 4, N .. " failed checks")
