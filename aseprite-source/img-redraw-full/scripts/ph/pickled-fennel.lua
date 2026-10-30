-- ph/pickled-fennel (Pantry pickle): footed apothecary jar on a stem and round foot, bulbous onion-shaped glass lid with a gold finial, pale fennel slivers
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local N = "pickled-fennel"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
c:build{
  { "foot",  c:rrect(20, 53, 44, 56, 1):add(c:rect(28, 48, 36, 53)), "#c9e6f0", { gloss = false, contour = "#7fb6cc" } },
  { "glass", c:rrect(17, 25, 47, 49, 9), "glass" },
  { "brine", c:rrect(19, 30, 45, 47, 7), "#eef0c0", { contour = "#a4b86a", gloss = false } },
}
c:fill(c:rect(21, 30, 43, 30), "#a4b86a")
-- fennel slivers: pale curved crescents and feathery fronds
local sl = GV.ramp("#d8e0a0", { shade = "#a4b86a", deep = "#6a9a3a" })
for _, q in ipairs({ {24, 35}, {37, 34}, {28, 42}, {40, 42} }) do
  local m = c:ellipse(q[1], q[2], 4, 2.5):cut(c:ellipse(q[1] + 1, q[2] - 2, 4, 2.5))
  c:part(m, sl, { flat = true, contour = "#6a9a3a" })
  c:px(q[1] - 2, q[2], "#f4f0e0")
end
c:paint({ "g.g", ".g.", "g.g", ".g." }, 21, 38, { g = "#7ab55c" })
c:paint({ "g.g", ".g.", "g.g" }, 42, 36, { g = "#7ab55c" })
-- oval label with a fennel bulb emblem
c:part(c:ellipse(32, 41, 7, 5), "cream", { gloss = false, contact = false })
c:paint({
  "g.g.g",
  ".ggg.",
  "..g..",
  ".bwb.",
  "bwWwb",
  "bwwsb",
  ".bbb.",
}, 30, 37, { g = "#7ab55c", b = "#a4b86a", w = "#f4f0e0", W = "#fbf6e8", s = "#d8e0a0" })
-- bulbous glass lid wider than the mouth, gold finial
c:part(c:rect(24, 23, 40, 26), "#c9e6f0", { flat = true, contour = "#7fb6cc" })
c:part(c:ellipse(32, 17, 12, 7), "#c9e6f0", { gloss = { 25, 13 }, rim = false, contour = "#7fb6cc" })
c:fill(c:rect(23, 20, 41, 20):clip(c:ellipse(32, 17, 12, 7)), "#a9d6ea")
c:part(c:ellipse(32, 10, 3, 3), "gold", { cres = 2, deep = 1, gloss = false })
c:px(31, 9, "#fff1c8")
c:seam({ {24, 25}, {40, 25} })
c:gloss(c:rrect(17, 25, 47, 49, 9), "glass", { 21, 32 })
local P = app.params or {}
local t = c:save((P.ase or D .. "img-redraw-full/aseprite/ph/") .. N .. ".aseprite", (P.out or "/home/user/gnome-venture/game/assets/img/ph/") .. N .. ".png")
print(N, GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.bw <= 4, N .. " failed checks")
