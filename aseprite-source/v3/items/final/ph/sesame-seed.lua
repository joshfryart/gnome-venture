local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dD15.lua")
local HP, X, K, R = D.HP, D.X, D.K, D.R
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
-- sesame-seed (D15 first draft). A handful of tiny flat cream teardrop seeds on a lance-shaped leaf scrap; sprout with two round seed leaves and a pair of lance leaves.
-- quirk: one seed sits upright on its edge, balanced.
D.seedScene("sesame-seed", {
  leaf = R.leaf, la = { 8, 50 }, lb = { 56, 56 }, lw = 7, veins = { 8, 14, 20, 26, 32, 38, 44 }, seed = R.cream, shadow = "#1f553f",
  seeds = { { 14, 51, 2.8, 1.7, -0.3 }, { 22, 54, 2.8, 1.7, 0.5 }, { 29, 50, 2.8, 1.7, 1.2 }, { 36, 55, 2.8, 1.7, -0.6 },
            { 43, 53, 2.8, 1.7, 0.2 }, { 49, 56, 2.6, 1.6, 0.9 }, { 24, 47, 2.4, 1.5, 0.1 } },
  sprout = function(c)
    D.ln(c, 33, 50, 33, 24, "#a8c258")
    D.ln(c, 34, 50, 34, 26, "#78bd5c")
    D.seed(c, 33, 50, 3, 2, 0, R.cream, "#1f553f")
    for _, l in ipairs{ { 25, 30, 4.6, 2.8, -0.2 }, { 42, 30, 4.6, 2.8, 0.2 } } do
      D.lit(c, D.ell(l[1], l[2], l[3], l[4], l[5]), R.fresh, 1.8)
    end
    D.blade(c, 33, 24, 21, 8, 3, R.leaf, { veins = { 4, 8 } })
    D.blade(c, 34, 24, 46, 8, 3, R.leaf, { veins = { 4, 8 } })
  end,
  extra = function(c) end,
})
