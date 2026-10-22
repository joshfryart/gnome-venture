local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- straw tufts: spikes poking out each side below the brim
local tl = c:poly({{22,27},{11,26},{17,29},{10,31},{17,33},{12,37},{22,35}})
local tr = c:poly({{42,27},{53,26},{47,29},{54,31},{47,33},{52,37},{42,35}})
local shirt = c:poly({{20,41},{44,41},{51,57},{13,57}})
local head = c:ellipse(32, 31, 12, 12)
local brim = c:ellipse(32, 21, 23, 5)
local crown = c:rrect(21, 6, 43, 20, 5)
local p = c:build{
  { "tuftL", tl, "#ecc58a", { flat = true } },
  { "tuftR", tr, "#ecc58a", { flat = true } },
  { "shirt", shirt, "stone", { stitch = { side = "lit" } } },
  { "patch", c:rect(36, 46, 42, 52), "#b07a45", { flat = true } },
  { "head", head, "#d6c9b6", { gloss = { 23, 26 } } },
  { "brim", brim, "#d9a660" },
  { "crown", crown, "#b07a45", { gloss = { 25, 9 } } },
  { "band", c:rect(22, 15, 42, 18), "gold", { flat = true } },
}
-- straw texture lines on brim
c:paint({ "w...w...w...w...w...w...w...w" }, 18, 23, { w = "#b07a45" })
-- patch seam
c:seam({ {36,46},{42,46},{42,52},{36,52},{36,46} }, { free = true })
c:button(30, 41)
c:eye(24, 28); c:eye(35, 28)
-- stitched grin
c:paint({
  "u...........u",
  ".uuuuuuuuuuu.",
  "..u..u..u..u.",
}, 26, 36, { u = "umber" })
local t = c:save(O .. "aseprite/ph/scarecrow.aseprite", O .. "png/ph/scarecrow.png")
print(GV.report(t))
