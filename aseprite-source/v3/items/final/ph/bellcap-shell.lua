-- bellcap-shell: a ribbed slate-blue bell-shaped shell with flared scalloped rim and open hollow, apex loop. quirk: three pale barnacles cling to the shoulder.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA15.lua")
local HP, X, K = D.HP, D.X, D.K
local floor, max, min, abs, sqrt, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sqrt, math.sin, math.cos, math.pi
local c = D.new("bellcap-shell")
local S = { "#1c2040", "#2c3560", "#3e4c84", "#5668a8", "#7e8ccc", "#b0bcec" }
D.sh(32, 53, 20, 3)
-- hollow underside
local under = D.ell(32, 47, 19, 5, 0)
D.lit(under, { "#0e1028", "#1c2040", "#2c3560", "#2c3560", "#3e4c84", "#3e4c84" }, 3)
-- bell body: tapered dome
local body = c:poly{ {26,10}, {38,10}, {41,18}, {44,30}, {49,42}, {51,47}, {13,47}, {15,42}, {20,30}, {23,18} }
body:add(D.ell(32, 12, 7, 3, 0))
-- scallop rim
for x = 13, 51 do
  local s = floor(sin(x * .8) * 1.5 + .5)
  body:set(x, 47 + max(0, s))
end
D.lit(body, S, 7, { wrap = .35 })
-- ribs
for _, r in ipairs{ -9, -4, 0, 4, 9 } do
  for y = 14, 47 do
    local t = (y - 12) / 35
    local x = floor(32 + r * (.3 + t * 2.0) + .5)
    if body:has(x, y) then c:px(x, y, r < 0 and S[5] or S[2]) end
  end
end
-- apex loop
local lp = D.ell(32, 8, 3.2, 2.2, 0):cut(D.ell(32, 8, 1.2, .8, 0))
D.lit(lp, { "#8a5a1c", "#b8821e", "#dcac2c", "#f6d24c", "#fff0a0", "#fff8c8" }, 1.6)
-- rim band
for x = 14, 50 do if body:has(x, 46) then c:px(x, 46, S[1]) end end
c:px(24, 20, "#e6eeff") c:px(24, 21, "#e6eeff") c:px(25, 20, S[6])
-- barnacles
for _, p in ipairs{ {38,28}, {41,31}, {36,32} } do
  c:paint({ ".x.", "xyx" }, p[1], p[2], { x = "#f4f0e6", y = "#b8b0a0" })
  c:px(p[1] + 1, p[2], "#8a8478")
end
D.fin()
