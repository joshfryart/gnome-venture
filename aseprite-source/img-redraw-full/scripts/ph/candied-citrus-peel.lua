-- ph/candied-citrus-peel (Pantry candied): round gathered muslin pouch tied with a pink satin bow, sugared orange peel curls spilling out
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "candied-citrus-peel"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- peel curls rising from the neck (behind the gather)
local function curl(pts)
  c:part(c:line(pts, 3), "#f08a24", { gloss = false, cres = 2, deep = 0 })
end
curl({ {29, 24}, {26, 19}, {22, 16}, {18, 17}, {17, 21}, {20, 23} })
curl({ {35, 24}, {38, 19}, {42, 16}, {46, 17}, {47, 21}, {44, 23} })
curl({ {31, 23}, {29, 17}, {30, 12}, {34, 9}, {37, 11}, {36, 14} })
curl({ {34, 23}, {35, 18} })
for _, p in ipairs({ {25, 17}, {21, 16}, {17, 19}, {39, 17}, {43, 16}, {46, 19}, {29, 14}, {32, 9}, {36, 10}, {34, 20} }) do c:px(p[1], p[2], "#fbf6e8") end
for _, p in ipairs({ {19, 22}, {45, 22}, {37, 13}, {28, 20}, {37, 20} }) do c:px(p[1], p[2], "#c8561c") end
-- round muslin pouch
local pouch = c:ellipse(32, 41, 15, 14)
c:part(pouch, "#f4e8c0", { gloss = { 21, 33 } })
for _, l in ipairs({ { {27, 30}, {20, 36} }, { {38, 30}, {45, 36} } }) do
  c:fill(c:line(l, 1), "#c9a96e")
end
-- gathered neck with edge stitch dashes
c:part(c:poly({ {27, 22}, {38, 22}, {41, 30}, {24, 30} }), "#e8d8b0", { gloss = false, cres = 2, deep = 0 })
for x = 27, 38, 3 do c:fill(c:rect(x, 23, x, 29), "#c9a96e") end
for x = 26, 39, 3 do c:px(x, 30, "#e8a317") end
-- satin ribbon and bow
c:part(c:rect(24, 27, 41, 28), "petal", { flat = true, contact = false })
c:part(c:poly({ {32, 27}, {25, 24}, {24, 31} }):add(c:poly({ {33, 27}, {40, 24}, {41, 31} })), "petal", { gloss = false, cres = 2, deep = 0 })
c:part(c:line({ {31, 29}, {28, 35} }, 2):add(c:line({ {34, 29}, {37, 35} }, 2)), "petal", { flat = true, contact = false })
c:part(c:rect(31, 26, 34, 29), "#c04a7a", { flat = true, contact = false })
-- patch with an orange slice
c:part(c:rrect(26, 39, 40, 52, 2), "cream", { gloss = false, contact = false })
c:paint({
  "..ooooo..",
  ".oyyyyyo.",
  "oyoyoyoyo",
  "oyyyoyyyo",
  "ooooooooo",
  "oyyyoyyyo",
  "oyoyoyoyo",
  ".oyyyyyo.",
  "..ooooo..",
}, 29, 41, { o = "#f08a24", y = "#f5cf6a" })
for x = 27, 39, 3 do c:px(x, 40, "#e8a317"); c:px(x + 1, 51, "#e8a317") end
c:ground(32, 56, 14, 1.5)
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 1, N .. " failed checks")
