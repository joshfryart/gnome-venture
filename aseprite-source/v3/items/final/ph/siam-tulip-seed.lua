local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dD15.lua")
local HP, X, K, R = D.HP, D.X, D.K, D.R
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
-- siam-tulip-seed (D15 first draft). Four small knobby mauve rhizome seeds on a broad pleated leaf scrap; sprout shows one wide pleated lance leaf and a pink bract bud.
-- quirk: the bud's pink bracts are folded like a paper tulip.
D.seedScene("siam-tulip-seed", {
  leaf = R.fresh, la = { 7, 56 }, lb = { 52, 46 }, lw = 8, veins = { 6, 11, 16, 21, 26, 31, 36, 41 }, seed = R.mauve, shadow = "#255f43",
  seeds = { { 17, 54, 3.2, 2.6, -0.5 }, { 26, 53, 3, 2.4, 0.8 }, { 35, 51, 3.2, 2.6, 0.2 }, { 44, 48, 3, 2.4, -0.3 } },
  sprout = function(c)
    D.ln(c, 30, 51, 31, 30, "#78bd5c")
    D.seed(c, 30, 51, 3, 2.4, 0, R.mauve, "#255f43")
    D.blade(c, 31, 34, 14, 12, 6, R.leaf, { veins = { 3, 6, 9, 12, 15, 18 }, slant = 1.8 })
    -- bud: three folded bracts
    D.lit(c, D.ell(35, 19, 3, 7, 0.3), R.pink, 2.2)
    D.lit(c, D.ell(32, 21, 2.6, 5, -0.4), R.pink, 2)
    D.ln(c, 31, 30, 34, 24, "#78bd5c")
  end,
})
