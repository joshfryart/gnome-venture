-- bell-pepper-seed: flat cream kidney-disc pepper seeds on a leaf scrap; sprout has two pointed lance leaves and a stem. quirk: one seed still clings to a sliver of white pith.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA15.lua")
local HP, X, K = D.HP, D.X, D.K
local floor, max, min, abs, sqrt, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sqrt, math.sin, math.cos, math.pi
local c = D.new("bell-pepper-seed")
local SD = { "#8a6a3a", "#b4934e", "#d8b878", "#ecd49a", "#f8ecc0", "#fffaea" }
D.scrap(4, 55, 58, 52, 8, D.GRN, { norib = false })
local function disc(cx, cy, a)
  c:fillMask(D.ell(cx + 1, cy + 1.2, 5, 4.4, a), "#1f4a3a")
  local m = D.ell(cx, cy, 4.8, 4, a)
  D.lit(m, SD, 2.4)
  -- notch
  local nx, ny = floor(cx + cos(a + 2.6) * 4), floor(cy + sin(a + 2.6) * 3.6)
  c:px(nx, ny, SD[1]) c:px(nx + 1, ny, SD[2])
  c:px(floor(cx - 2), floor(cy - 1.5), "#fff4d6")
  return m
end
D.lf(36, 23, 2.4, 6.5, -.7, D.LEAF2) D.lf(48, 22, 2.4, 6.5, .75, D.LEAF2)
D.ln(42, 46, 42, 24, "#86b86c") D.ln(43, 46, 43, 24, "#5a9a50")
D.ln(35, 28, 41, 25, "#c8e898") D.ln(49, 27, 43, 25, "#c8e898")
D.lf(42, 19, 1.6, 4.2, 0, D.LEAF2)
disc(14, 50, .3) disc(27, 52, -.2) disc(42, 48, .1)
-- pith sliver
c:paint({ "xxxx.", ".yyyyx" }, 17, 56, { x = "#fffaea", y = "#e6dfc8" })
D.fin()
