-- ph/rhubarb-chutney (Pantry chutney): broad flat pocket flask with sloping shoulders, narrow neck, brass cap, pink thread
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "rhubarb-chutney"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local flask = c:rrect(13, 30, 51, 55, 7):add(c:poly({ {25, 21}, {40, 21}, {51, 33}, {13, 33} })):add(c:rect(25, 13, 39, 24)):closed(2)
c:build{
  { "glass", flask, "glass" },
  { "fill",  flask:shrink(2):cut(c:rect(0, 0, 63, 19)), "#b0604a", { contour = "#6a2a20", gloss = { 18, 33 } } },
}
-- pink stalk bits
for _, l in ipairs({ { {18,35}, {21,33} }, { {43,33}, {46,35} }, { {17,50}, {20,52} }, { {44,50}, {47,48} }, { {29,24}, {32,26} } }) do
  c:fill(c:line(l, 2), "#e46a9b")
end
c:part(c:rrect(21, 34, 43, 48, 2), "cream", { gloss = false, contact = false })
-- emblem: rhubarb leaf on a red-pink stalk
c:paint({
  ".gggg.....",
  "gGgggg....",
  "ggvgggg...",
  ".ggvggg...",
  "..gggvg...",
  "....ggr...",
  ".....rr...",
  "......r...",
  "......rr..",
  ".......r..",
}, 24, 36, { g = "#4f9a45", G = "#7ab55c", v = "#2f5a2a", r = "#d6322b" })
c:paint({ "uuuu", "", "uuu", "", "uu" }, 36, 39, { u = "#7a5a3a" })
c:part(c:rrect(24, 7, 40, 14, 2), "#b07a10")
for x = 26, 38, 2 do c:px(x, 8, "#e8c060") end
c:seam({ {26, 14}, {38, 14} })
-- pink waxed thread round the neck with a tail
c:fill(c:rect(25, 20, 39, 20), "#e46a9b")
c:fill(c:line({ {39, 20}, {42, 24}, {44, 28} }, 1), "#e46a9b")
c:px(44, 29, "#b0406a")
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 4, N .. " failed checks")
