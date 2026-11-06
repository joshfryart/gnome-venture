-- holly-hedge-tee (final, Opus single pass aC12_2). A T-junction of clipped holly hedge in 3/4 view: the long arm runs
-- left-right at the back, the stem arm runs down toward the viewer from its middle. Lit top faces and darker front
-- faces tiled with glossy cupped holly leaves (per-leaf tilted normals, pale midribs, glossy flecks), spines on the
-- outer silhouette, AO in both inside bends where the back arm's face tucks behind the stem, AO toward each base,
-- woody stems in the shadow and a ground shadow. Berry clusters scattered over the tops.
-- quirk: a hedgehog snuffles out from under the back arm in the left inside bend.
local NAME = "holly-hedge-tee"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC12_2.lua")
local HP, X, K = A.HP, A.X, A.K
local c = A.new(NAME)
local BARK = { "#2e1b1f", "#4a2c28", "#6c4130", "#8f5a3a" }
local btok = { r = { name = "bark" } }

c:groundShadow(32, 34, 24, 2)
c:groundShadow(32, 56, 9, 2)
for _, sx in ipairs{ 12, 52 } do
  local m, n = A.tube({ { sx, 30 }, { sx, 31 }, { sx + 0.2, 32 }, { sx + 0.3, 34 } }, function(t) return 1.1 end)
  A.shade(c, m, n, BARK, { amb = 0.1, wrap = 0.3, cuts = { 0.3, 0.55, 0.8 }, tok = btok })
end
for _, sx in ipairs{ 28, 36 } do
  local m, n = A.tube({ { sx, 51 }, { sx, 52 }, { sx + 0.2, 53 }, { sx + 0.3, 55 } }, function(t) return 1.1 end)
  A.shade(c, m, n, BARK, { amb = 0.1, wrap = 0.3, cuts = { 0.3, 0.55, 0.8 }, tok = btok })
end
-- back arm top 8..56 x 12..20, its front face 21..31 ; stem arm top 25..39 x 21..44, front 45..52
local top = c:rrect(9, 12, 56, 20, 3):add(c:rect(25, 18, 39, 43))
local front = c:rect(9, 21, 24, 31):add(c:rect(40, 21, 56, 31)):add(c:rect(25, 44, 39, 52))
for _, p in ipairs{ { 9, 31 }, { 56, 31 }, { 25, 52 }, { 39, 52 } } do front:cut(c:rect(p[1], p[2], p[1], p[2])) end
local stemM = c:rect(25, 21, 39, 52)
local ao = {}
X.ao(ao, front, stemM, 3, -1)
local hedge, ltok = A.hedge(c, top, front, { seed = 3, spineMaxY = 46, ao = ao,
  baseAO = function(bias, h) h:each(function(x, y) local k = K(x, y)
    if (y >= 29 and y <= 31 and (x < 25 or x > 39)) or y >= 50 then bias[k] = (bias[k] or 0) - ((y == 31 or y >= 52) and 2 or 1) end end) end })
for _, cl in ipairs{ { 11, 13 }, { 43, 12 }, { 27, 27 }, { 30, 38 }, { 46, 23 }, { 12, 23 } } do A.cluster(c, hedge, ltok, cl[1], cl[2]) end

-- quirk: hedgehog in the left inside bend, nose out toward the light
local HH = { S = "#3a2420", s = "#5e3a2a", m = "#84583a", t = "#c99e6c", f = "#e8c896", F = "#f0d2a8", e = "#2b1c26", n = "#2b1c26", g = "#fff4d6", k = "#d9a070" }
local htok = { r = { name = "hedgehog" } }
A.paint(c, {
  "..t.m.t...",
  ".tmsmtms..",
  "tmsmSmsmS.",
  "msmsmSmsSs",
  ".FfmsmSsSS",
  "nfkFmSsSS.",
  ".kkfsSS...",
}, 15, 28, HH, htok)
c:put(16, 32, HH.e, htok) c:put(15, 33, HH.n, htok) c:put(15, 32, HH.F, htok)
A.save(c, NAME)
