local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dD15.lua")
local HP, X, K, R = D.HP, D.X, D.K, D.R
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
-- sea-thrift-seed (D15 first draft). Four small tan oval seeds on a scrap of narrow blue-green thrift leaf, one papery pink calyx cup, a sprout of three thin grass-like blades.
-- quirk: a crumpled papery calyx still clings to one seed like a tiny hat.
D.seedScene("sea-thrift-seed", {
  leaf = R.bluegr, la = { 6, 52 }, lb = { 54, 46 }, lw = 6, veins = { 8, 16, 24, 32, 40 }, seed = R.tan, shadow = "#173a45",
  seeds = { { 17, 50, 3, 2, -0.3 }, { 25, 53, 2.8, 1.9, 0.4 }, { 40, 49, 3, 2, 0.2 }, { 47, 50, 2.8, 1.9, -0.5 } },
  sprout = function(c)
    local H = D.H
    for _, b in ipairs{ { 31, 48, 20, 14 }, { 32, 48, 31, 9 }, { 33, 48, 43, 16 } } do
      D.blade(c, b[1], b[2], b[3], b[4], 1.7, R.bluegr, { norib = true })
    end
    D.seed(c, 32, 48, 3.2, 2.2, -0.2, R.tan, "#173a45")
    -- papery calyx cup over the seed
    local m = D.ell(32, 46, 4.2, 2.6, 0)
    D.lit(c, m, R.pink, 2)
    c:px(30, 45, "#ffd4e0")
  end,
})
