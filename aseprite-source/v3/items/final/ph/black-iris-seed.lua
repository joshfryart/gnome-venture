-- black-iris-seed: flat glossy D-shaped dark violet-brown seeds, each with a pale cream cap, on a sword-leaf scrap; the sprout is a flat fan of two blade leaves. quirk: one seed is capped by a tiny purple petal sliver.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA15.lua")
local HP, X, K = D.HP, D.X, D.K
local floor, max, min, abs, sqrt, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sqrt, math.sin, math.cos, math.pi
local c = D.new("black-iris-seed")
local SD = { "#1a0c1c", "#2c1630", "#44244a", "#5e3868", "#80548c", "#a88ab8" }
-- sword-shaped scrap
D.scrap(4, 57, 58, 47, 6, { "#1c3a4a", "#2a5a5c", "#3a7a68", "#58a078", "#80c490", "#b0e4b0" }, { veins = {}, norib = false })
for i = 0, 9 do D.ln(8 + i * 5, 55 - floor(i * .7), 8 + i * 5, 53 - floor(i * .7), "#3a7a68") end
-- fan of blades
local function blade(x, y, ex, ey, w)
  local m = D.B.blade(c, x, y, ex, ey, w, { "#1c3a4a", "#2a5a5c", "#3a8a68", "#58b078", "#88d090", "#b8f0b0" }, { norib = false })
end
blade(42, 46, 30, 12, 4.4) blade(43, 46, 48, 8, 4.4)
blade(42, 46, 36, 20, 3.2)
c:paint({ "xxx" }, 40, 45, { x = "#c8e898" })
local function seed(cx, cy, a, petal)
  c:fillMask(D.ell(cx + 1, cy + 1.2, 4.6, 3.8, a), "#1f4a3a")
  local m = D.ell(cx, cy, 4.4, 3.6, a)
  D.lit(m, SD, 3, { wrap = .3 })
  c:px(floor(cx - 2), floor(cy - 2), "#f0e0ff") c:px(floor(cx - 1), floor(cy - 2), SD[6])
  local capx, capy = floor(cx + 3 * cos(a + .3)), floor(cy + 3 * sin(a + .3))
  c:paint({ "xx", "xx" }, capx - 1, capy, { x = petal and "#b080e0" or "#f4e8c8" })
  c:px(capx, capy + 1, petal and "#7a50b0" or "#c8b890")
end
seed(14, 51, .2, false) seed(27, 52, -.3, false) seed(36, 54, .4, true)
-- seed under the fan
seed(44, 51, .1, false)
D.fin()
