local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dD15.lua")
local HP, X, K, R = D.HP, D.X, D.K, D.R
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
-- shea-seed (D15 first draft). Three big glossy brown shea nuts with a pale scar on a broad dark oblong leaf; sprout carries two long glossy parallel-veined leaves.
-- quirk: a pale butter-coloured thumbprint pressed into one nut.
D.seedScene("shea-seed", {
  leaf = R.leaf, la = { 6, 50 }, lb = { 56, 50 }, lw = 9, veins = { 6, 11, 16, 21, 26, 31, 36, 41, 46 }, seed = R.brown, shadow = "#163a35",
  seeds = { { 18, 50, 5.4, 4, -0.3 }, { 32, 54, 5, 3.8, 0.4 }, { 45, 50, 5.2, 3.9, 0.1 } },
  sprout = function(c)
    D.ln(c, 32, 46, 32, 28, "#8a5a38")
    D.ln(c, 33, 46, 33, 30, "#a4743f")
    D.blade(c, 32, 30, 14, 12, 4, R.fresh, { veins = { 3, 5, 7, 9, 11, 13, 15 }, slant = 1.6 })
    D.blade(c, 33, 30, 52, 14, 4, R.fresh, { veins = { 3, 5, 7, 9, 11, 13, 15 }, slant = 1.6 })
  end,
  extra = function(c)
    for _, s in ipairs{ { 18, 50 }, { 32, 54 }, { 45, 50 } } do
      for _, p in ipairs{ { 0, 2 }, { 1, 2 }, { 2, 2 }, { 1, 3 } } do c:px(s[1] - 1 + p[1], s[2] + p[2] - 1, "#dcb07a") end
    end
    c:px(44, 48, "#ffd9a0") c:px(45, 48, "#ffd9a0")
  end,
})
