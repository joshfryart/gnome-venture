-- Silverback Spool (pl-sbs-6), yard 64x64. Haiku first pass.
-- Seedkeeper, rare. A spare spool with a spider's legs, humming.
-- quirk: two music notes drift off the top right.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(dir .. "/../../../lib/hp.lua")
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "pl-sbs-6-yard" }
for _, pts in ipairs({
  { {22,28},{14,22} }, { {28,27},{22,18} }, { {37,27},{41,18} }, { {42,28},{50,22} },
  { {22,37},{14,43} }, { {28,38},{22,46} }, { {37,38},{41,46} }, { {42,37},{50,43} } }) do
  c:part(c:line(pts, 1), "wood", {})
end
c:part(c:rect(17, 27, 47, 38), "dusk", {})
c:part(c:rect(17, 30, 47, 30), "sky", { noshade = true })
c:part(c:rect(17, 35, 47, 35), "sky", { noshade = true })
c:part(c:ellipse(16, 32, 3, 12), "wood", {})
c:part(c:ellipse(48, 32, 3, 12), "wood", {})
c:part(c:rect(21, 27, 22, 38), "gold", {})
c:part(c:rect(43, 27, 44, 38), "gold", {})
c:part(c:rect(31, 24, 33, 26), "wood", {})
c:part(c:ellipse(32, 22, 3, 3), "gold", {})
c:eyeLocked(26, 31)
c:eyeLocked(36, 31)
c:paint({ "iii" }, 30, 39, { i = "#2b1c26" })
c:part(c:rect(56, 6, 57, 9), "sea", {})
c:part(c:rect(59, 4, 60, 7), "sea", {})
c:finish{ outline = true }
HP.assertClean(c)
local out = app.params.out or (dir .. "/")
c:save{ aseprite = out .. "pl-sbs-6-yard.aseprite", png = out .. "pl-sbs-6-yard.png" }
