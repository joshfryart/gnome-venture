-- beet-seed: corky beet seed clusters (knobby, pitted) on a beet-leaf scrap; sprout has red stalks and two oval red-veined leaves. quirk: the sprouting cluster still wears its cork cap.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA15.lua")
local HP, X, K = D.HP, D.X, D.K
local floor, max, min, abs, sqrt, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sqrt, math.sin, math.cos, math.pi
local c = D.new("beet-seed")
local CK = { "#4a3020", "#6e4a2c", "#94683c", "#b8885a", "#d8aa78", "#eed0a0" }
local R = D.BEET
D.scrap(5, 57, 57, 49, 8, D.GRN, {})
local function cluster(cx, cy, k)
  local m = D.ell(cx, cy, 4.4, 3.6, 0)
  m:add(D.ell(cx + 3, cy - 1, 3, 3, 0)):add(D.ell(cx - 2, cy + 2, 3, 2.4, 0))
  c:fillMask(m:shift(1, 1), "#1f4a3a")
  D.lit(m, CK, 3, { amb = .1 })
  m:each(function(x, y) if X.hash(x, y, k) > .86 then c:px(x, y, CK[1]) elseif X.hash(x, y, k + 3) > .93 then c:px(x, y, CK[6]) end end)
  c:px(cx - 2, cy - 2, "#fff4d6")
  return m
end
-- sprout first (stem behind the last cluster)
D.ln(42, 46, 42, 26, R[4]) D.ln(43, 46, 43, 26, R[3])
D.lf(35, 25, 6, 3, -.5, D.LEAF2) D.lf(50, 22, 6, 3, .5, D.LEAF2) D.lf(42, 18, 2.2, 4.2, 0, D.LEAF2)
D.ln(42, 26, 34, 23, R[4]) D.ln(43, 26, 50, 21, R[4]) D.ln(42, 22, 42, 16, R[4])
cluster(14, 51, 1) cluster(27, 53, 2) cluster(42, 49, 3)
-- cork cap tilting off the sprouting cluster
c:paint({ ".xxx.", "xyyyx" }, 38, 43, { x = CK[5], y = CK[3] })
D.fin()
