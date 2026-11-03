-- black-bean: an open bean pod showing three glossy black beans with pale hilum slits, a green husk shell and a curled tip. quirk: one bean has rolled out in front and its hilum looks like a sleepy eye.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA15.lua")
local HP, X, K = D.HP, D.X, D.K
local floor, max, min, abs, sqrt, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sqrt, math.sin, math.cos, math.pi
local c = D.new("black-bean")
local BK = D.BLK or { "#120d16", "#1d1523", "#2c2030", "#3e2f44", "#58475e", "#7c6a82" }
local PD = { "#2a2a12", "#4a4a1c", "#6a6a28", "#8a8a3a", "#a8a850", "#cccc78" }
local m, n, T, S = D.tube({ {8,40}, {20,22}, {40,22}, {56,36} }, function(t) return 6.2 * sin(pi * (t * .96 + .02)) ^ .5 + .5 end)
D.tn(m, n, PD)
-- inner lining
local inn, nn = D.tube({ {12,38}, {22,25}, {40,25}, {52,36} }, function(t) return 3.6 * sin(pi * (t * .92 + .04)) ^ .5 + .3 end)
D.tn(inn, nn, { "#6a7a30", "#8a9a44", "#aebc60", "#cdd884", "#e4ecaa", "#f6f8d0" }, nil, { wrap = .5 })
-- beans in the pod
for _, b in ipairs{ {22,29}, {32,27}, {43,30} } do
  local bm = D.ell(b[1], b[2], 5, 4, .1)
  c:fillMask(D.ell(b[1] + 1, b[2] + 1.5, 5, 4, .1), "#4a5a22")
  D.lit(bm, BK, 3.5, { wrap = .3 })
  c:px(b[1] - 2, b[2] - 2, "#e6e0f0") c:px(b[1] - 1, b[2] - 2, BK[6])
  c:px(b[1] + 1, b[2] + 2, "#f4efe6") c:px(b[1] + 2, b[2] + 2, "#f4efe6")
end
-- curled tip
for a = 0, 7, .5 do c:px(floor(57 + cos(a) * (2 - a * .15) + .5), floor(39 + 2 + sin(a) * (2 - a * .15) + .5), PD[4]) end
-- escaped bean
c:fillMask(D.ell(31, 49, 7, 4.6, .15), "#1d1523")
local eb = D.ell(30, 48, 7, 4.6, .15)
D.lit(eb, BK, 3.5, { wrap = .3 })
c:px(26, 45, "#e6e0f0") c:px(27, 45, "#e6e0f0") c:px(25, 46, BK[6])
c:paint({ "xxxx", ".yy." }, 30, 49, { x = "#f4efe6", y = "#c8c0b8" })
c:px(33, 50, "#2b1c26")
D.fin()
