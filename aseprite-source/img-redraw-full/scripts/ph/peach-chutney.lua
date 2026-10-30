-- ph/peach-chutney (Pantry chutney): round jar with three embossed bands, crimped gold lid, mini chili tied on a string that hangs clear of the jar
-- redraw A: jar moved left and narrowed so the chili tag hangs in its own space on the right, with a gap between the two outlines
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "peach-chutney"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
-- jar with three raised bands that bump out past the silhouette
local glass = c:rrect(9, 22, 41, 55, 6)
for _, y in ipairs({ 29, 37, 45 }) do glass:add(c:rect(8, y, 42, y + 1)) end
c:build{
  { "glass", glass, "glass" },
  { "fill",  c:rrect(11, 27, 39, 53, 5), "#e89a50", { contour = "#a8561a", gloss = { 14, 31 } } },
}
-- chunks and onion bits
for _, p in ipairs({ {15,32}, {22,30}, {31,31}, {36,33}, {14,48}, {21,50}, {29,49}, {35,47} }) do
  c:paint({ "ab", "bb" }, p[1], p[2], { a = "#f0b070", b = "#c8702a" })
end
for _, p in ipairs({ {19,33}, {34,30}, {25,48}, {38,50} }) do c:px(p[1], p[2], "#f1ece0") end
-- embossed bands across the fill (pale glass ridges)
for _, y in ipairs({ 29, 45 }) do c:fill(c:rect(11, y, 39, y), "#c9e6f2"); c:fill(c:rect(11, y + 1, 39, y + 1), "#7fb0cc") end
c:part(c:rrect(15, 33, 35, 43, 2), "cream", { gloss = false, contact = false })
-- emblem: a peach with leaf and cleft (the chili now lives on the tag, so the label carries the peach alone)
c:paint({
  "....ug..",
  "..ppugg.",
  ".pPpcpp.",
  "pPppcppp",
  "ppppcpps",
  ".pppcss.",
  "..psss..",
}, 21, 35, { p = "#f0a070", P = "#ffd0a8", s = "#d0684a", c = "#d88058", u = "umber", g = "#4f9a45" })
-- crimped lid
c:part(c:rrect(8, 14, 42, 24, 4), "gold")
for x = 11, 39, 3 do c:px(x, 15, "#f5cf6a"); c:px(x, 23, "#b8661a") end
c:seam({ {10, 22}, {40, 22} })
-- string from the lid's knot, out across the gap, down to the chili
c:fill(c:line({ {41, 19}, {46, 19}, {51, 24}, {51, 27} }, 1), "#c9a96e")
c:part(c:rect(49, 27, 53, 29), "leaf", { flat = true })
local chili = c:poly({ {48, 30}, {55, 30}, {55, 35}, {54, 41}, {52, 47}, {50, 44}, {49, 38} })
c:part(chili, "red", { flat = true, contour = "#7a1a14" })
c:fill(chili:copy():cut(chili:copy():shift(-2, 0)), "#ae2a2a")          -- shaded right side
c:fill(c:rect(50, 31, 50, 37), "#ff9158"); c:px(50, 32, "#ffc27a")
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 4, N .. " failed checks")
