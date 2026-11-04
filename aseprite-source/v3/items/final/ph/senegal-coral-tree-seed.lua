local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dD15.lua")
local HP, X, K, R = D.HP, D.X, D.K, D.R
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
-- senegal-coral-tree-seed (D15 first draft). Three glossy scarlet beans with a black eye on a scrap of green leaf; sprout with a thorny stem and a trifoliate leaf.
-- quirk: one bean wears its black eye spot like a tiny wink.
D.seedScene("senegal-coral-tree-seed", {
  leaf = R.leaf, la = { 6, 52 }, lb = { 50, 50 }, lw = 6, seed = R.red, shadow = "#163a35",
  seeds = { { 16, 50, 4, 3, -0.2 }, { 27, 52, 3.8, 2.8, 0.5 }, { 38, 48, 4, 3, 0.1 } },
  sprout = function(c)
    D.ln(c, 33, 50, 33, 24, "#7a3a30")
    D.seed(c, 33, 50, 3.6, 2.8, -0.9, R.red, "#163a35")
    c:px(31, 51, "#2a1020") c:px(32, 51, "#2a1020") c:px(32, 52, "#2a1020")
    c:px(34, 38, "#a8443e") c:px(32, 32, "#a8443e")
    for _, l in ipairs{ { 33, 12, 7, 5, 0.0 }, { 22, 22, 6, 4, -0.5 }, { 44, 22, 6, 4, 0.5 } } do
      local m = D.ell(l[1], l[2], l[3], l[4], l[5])
      D.lit(c, m, R.fresh, 2)
      D.ln(c, l[1] - floor(l[3] * .7), l[2] + 1, l[1] + floor(l[3] * .7), l[2] - 1, "#a8d877", m)
    end
  end,
  extra = function(c) D.ln(c, 16, 49, 16, 50, "#2a1020") c:px(15, 49, "#2a1020") end,
})
