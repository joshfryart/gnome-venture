-- ph/peach-chutney (Pantry chutney): round jar with three embossed bands, crimped gold lid, mini chili tied on string
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "peach-chutney"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
-- jar with three raised bands that bump out past the silhouette
local glass = c:rrect(15, 22, 49, 54, 6)
for _, y in ipairs({ 29, 37, 45 }) do glass:add(c:rect(14, y, 50, y + 1)) end
c:build{
  { "glass", glass, "glass" },
  { "fill",  c:rrect(17, 27, 47, 52, 5), "#e89a50", { contour = "#a8561a", gloss = { 20, 31 } } },
}
-- chunks and onion bits
for _, p in ipairs({ {21,32}, {28,30}, {37,31}, {43,33}, {20,48}, {27,50}, {35,49}, {42,47} }) do
  c:paint({ "ab", "bb" }, p[1], p[2], { a = "#f0b070", b = "#c8702a" })
end
for _, p in ipairs({ {25,33}, {40,30}, {31,48}, {45,50} }) do c:px(p[1], p[2], "#f1ece0") end
-- embossed bands across the fill (pale glass ridges)
for _, y in ipairs({ 29, 45 }) do c:fill(c:rect(17, y, 47, y), "#c9e6f2"); c:fill(c:rect(17, y + 1, 47, y + 1), "#7fb0cc") end
c:part(c:rrect(22, 33, 42, 43, 2), "cream", { gloss = false, contact = false })
-- emblem: peach + chili side by side
c:paint({
  "..ug.......",
  ".ppuppg..g.",
  "pPppppp..rr",
  "ppppppp.rr.",
  "pppppps.r..",
  ".pppss.rr..",
  "..sss..r...",
}, 24, 35, { p = "#f0a070", P = "#ffd0a8", s = "#d0684a", u = "umber", g = "#4f9a45", r = "#d6322b" })
c:paint({ "uu" }, 37, 41, { u = "#7a5a3a" })
-- crimped lid
c:part(c:rrect(14, 14, 50, 24, 4), "gold")
for x = 17, 47, 3 do c:px(x, 15, "#f5cf6a"); c:px(x, 23, "#b8661a") end
c:seam({ {16, 22}, {48, 22} })
-- string and dangling chili
c:fill(c:line({ {47, 23}, {53, 29} }, 1), "#c9a96e")
c:part(c:poly({ {50, 31}, {57, 31}, {57, 36}, {55, 42}, {52, 45}, {51, 40} }), "#d6322b", { contour = "#7a1a14", gloss = false })
c:part(c:rect(52, 28, 55, 31), "#4f9a45", { flat = true })
c:px(52, 33, "#f07060"); c:px(52, 34, "#f07060")
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 4, N .. " failed checks")
