-- travel-cloak-fine: Fine rank of the Travel Cloak (Opus richness pass, opus3). 64x64.
-- Base: opus2/travel-cloak-fine.png (read only): moss wool cloak on its peg, gold clasp bar,
-- 2 px gold piping on both front edges, gold hem band, lit shoulder sheen.
-- opus3 adds: a 9x7 cast gold brooch on the clasp bar with a 3x3 faceted garnet (4 tones +
-- cream glint; the opus2 garnet was a 2x2 dot), 6-tone gold, gold filigree scrolls
-- embroidered either side of the V just above the hem, the same twill fleck in the wool as
-- Lined, a yellow-green rim light on the lit left edge and shoulder, a cool teal bounce line
-- on the lower right.
-- quirk: base orange leaf on the hem, plus a tiny gold-thread bee stitched on the shaded
-- right shoulder, as if it landed there.
local O = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_o3.lua")
local G = O.GOLD6
local img = O.base("travel-cloak-fine")

-- 0. twill fleck in the moss wool
local UP = { ["#5e9452"] = "#6a9e58", ["#45784b"] = "#507f50", ["#335f43"] = "#3c6a48", ["#264a3c"] = "#2d5442" }
O.each(img, 4, 13, 58, 58, function(x, y, h)
  if UP[h] and (x - y * 2) % 5 == 0 and y % 2 == 0 then return UP[h] end
end)

-- 1. gold brooch over the clasp bar: rim lit upper left, garnet set in the middle
O.paint(img, 26, 23, {
  "..udddu..",
  ".dhpbbsd.",
  "dhbWRRbsd",
  "dbbRRSssd",
  "dbsSSTsdu",
  ".dssssdu.",
  "..uddu...",
}, { u = G.umber, d = G.deep, s = G.shade, b = G.base, h = G.hi, p = G.pale,
     W = "#fff4d6", R = "#d0304a", S = "#9a1f3e", T = "#5e1430" })

-- 2. gold filigree scrolls on the wool either side of the V, above the hem band
O.paint(img, 18, 46, {
  "..hbb.",
  ".h...s",
  ".b.b.s",
  ".b..s.",
  "..ss..",
}, { h = G.hi, b = G.base, s = G.shade })
O.paint(img, 37, 46, {
  ".bss..",
  "s...d.",
  "s.s.d.",
  ".d..d.",
  "..dd..",
}, { b = G.base, s = G.shade, d = G.deep })

-- 3. rim light on the lit left edge and shoulders, bounce on the lower right
O.rim(img, "left", "#a8cc7a", { ["#86b464"] = 1, ["#5e9452"] = 1, ["#6a9e58"] = 1, ["#45784b"] = 1 }, { 4, 24, 26, 49 })
O.rim(img, "top", "#a8cc7a", { ["#86b464"] = 1, ["#5e9452"] = 1, ["#6a9e58"] = 1 }, { 6, 12, 22, 40 })
O.rim(img, "right", "#2f6a64", { ["#1c3530"] = 1, ["#264a3c"] = 1, ["#2d5442"] = 1 }, { 40, 40, 58, 56 })

-- 4. quirk: a gold-thread bee on the shaded right shoulder (pale wings, umber stripes)
O.paint(img, 41, 31, {
  ".pp.",
  "hbub",
  ".s.s",
}, { p = G.pale, h = G.hi, b = G.base, u = G.umber, s = G.shade })

O.reink(img)
O.save(img, "travel-cloak-fine")
