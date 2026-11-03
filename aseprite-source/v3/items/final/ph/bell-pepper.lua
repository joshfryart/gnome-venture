-- bell-pepper: a purple three-lobed bell pepper, glossy, curved green stem and calyx. quirk: a ladybird is sunning itself on the shoulder.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA15.lua")
local HP, X, K = D.HP, D.X, D.K
local floor, max, min, abs, sqrt, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sqrt, math.sin, math.cos, math.pi
local c = D.new("bell-pepper")
local P = D.PEP
local m = D.ell(24, 38, 8, 12, .1):add(D.ell(32, 40, 9, 13, 0)):add(D.ell(40, 38, 8, 12, -.1))
m:add(c:rect(18, 28, 46, 44)):cut(c:rect(0, 0, 63, 25))
m = m:copy()
-- trim bottom corners to lobes
D.lit(m, P, 6, { wrap = .35 })
-- groove lines between lobes
for y = 30, 51 do c:px(28, y, P[2]) c:px(36, y, P[2]) end
for y = 33, 48 do c:px(29, y, P[3]) c:px(37, y, P[3]) end
-- bottom notches
-- waxy specular
c:paint({ "xx", "x." }, 20, 31, { x = "#f4e0ff" })
c:px(19, 34, P[6]) c:px(19, 35, P[5])
c:px(39, 32, P[6]) c:px(40, 32, P[6])
-- shoulder dip + calyx
local cal = D.ell(32, 28, 7, 3, 0)
D.lit(cal, D.GRN, 2.5)
-- stem curve
local sm, sn = D.tube({ {32,28}, {31,22}, {34,17}, {40,15} }, function(t) return 2.4 - t * 1.2 end)
D.tn(sm, sn, { "#1c5238", "#2c7440", "#42944a", "#68b454", "#9ccc68", "#c8e898" })
c:px(41, 14, "#1c5238") c:px(41, 15, "#1c5238")
-- ladybird
c:paint({ ".xxx.", "xxdxx", "xdxdx", ".xxx." }, 41, 31, { x = "#e8493b", d = "#2b1c26" })
c:px(41, 31, "#2b1c26") c:px(44, 30, "#2b1c26")
c:px(42, 32, "#ff8a5c")
D.fin()
