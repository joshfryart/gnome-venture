-- ph/sweetcorn-relish (Pantry relish): tall straight jar, kernel grid in rows, cream corn-husk wrap tied with string
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "sweetcorn-relish"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
c:build{
  { "glass", c:rrect(16, 18, 48, 56, 4), "glass" },
  { "fill",  c:rrect(18, 22, 46, 54, 3), "#e8c030", { contour = "#a8701a", gloss = false } },
}
-- kernel grid: 3 px kernels in rows 4 px apart, red pepper bits between
for y = 23, 52, 4 do
  for x = 19 + ((y // 4) % 2) * 2, 44, 4 do
    c:paint({ "ab", "bc" }, x, y, { a = "#fbe08a", b = "#f5cf6a", c = "#c8901a" })
  end
end
for _, p in ipairs({ {22,26}, {37,30}, {44,24}, {20,50}, {33,48}, {42,52} }) do c:px(p[1], p[2], "#d6322b"); c:px(p[1] + 1, p[2], "#d6322b") end
c:gloss(c:rrect(18, 22, 46, 54, 3), GV.ramp("#e8c030"), { 21, 33 })
c:part(c:rrect(22, 32, 42, 44, 2), "cream", { gloss = false, contact = false })
-- emblem: corn cob with three husk leaves
c:paint({
  "....yy....",
  "...yYyy...",
  "...yyyy...",
  "..gyyyyg..",
  "..gyyyyg..",
  ".ggyyyygg.",
  ".g.gyyg.g.",
  "....gg....",
}, 23, 34, { y = "#e8c030", Y = "#fff3a0", g = "#7ab55c" })
c:paint({ "uuu", "", "uu", "", "uuu" }, 36, 36, { u = "#7a5a3a" })
-- husk wrap draped over the top, three leaf tips standing up
local husk = c:rrect(15, 14, 49, 22, 3):add(c:poly({ {17, 15}, {19, 7}, {25, 15} })):add(c:poly({ {27, 15}, {32, 5}, {37, 15} })):add(c:poly({ {39, 15}, {45, 7}, {47, 15} }))
husk:add(c:poly({ {15, 21}, {21, 21}, {17, 27} })):add(c:poly({ {43, 21}, {49, 21}, {47, 27} }))
c:part(husk, "#e8e0cc", { contour = "#9a7a50", gloss = { 20, 16 } })
for _, l in ipairs({ { {19, 10}, {20, 20} }, { {32, 8}, {32, 20} }, { {44, 10}, {43, 20} }, { {26, 16}, {26, 20} }, { {38, 16}, {38, 20} } }) do
  c:fill(c:line(l, 1), "#c9a96e")
end
c:fill(c:rect(16, 20, 48, 20), "#7a4a1f")
c:px(32, 21, "#7a4a1f"); c:px(31, 22, "#7a4a1f"); c:px(33, 22, "#7a4a1f")
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 4, N .. " failed checks")
