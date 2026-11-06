-- holly-hedge-straight (final, Opus single pass aC12_2). A straight run of clipped holly hedge in 3/4 view: a lit top
-- face and a darker front face, both tiled with glossy cupped holly leaves (own tilted normal per leaf over the
-- rounded block form, pale midribs, dark gaps, glossy flecks), spiny leaf tips breaking the top and end silhouette,
-- AO deepening toward the base, three woody stems in the shadow underneath and a 2-tone ground shadow.
-- Berry clusters (4 px, glint, contact shadow) sit along the crest.
-- quirk: a little robin perches on the top, tail cocked, eyeing the berries.
local NAME = "holly-hedge-straight"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC12_2.lua")
local HP, X, K = A.HP, A.X, A.K
local c = A.new(NAME)
local BARK = { "#2e1b1f", "#4a2c28", "#6c4130", "#8f5a3a" }
local btok = { r = { name = "bark" } }

c:groundShadow(32, 47, 25, 2)
for _, sx in ipairs{ 16, 32, 48 } do
  local m, n = A.tube({ { sx, 41 }, { sx, 43 }, { sx + 0.3, 44 }, { sx + 0.5, 46 } }, function(t) return 1.1 end)
  A.shade(c, m, n, BARK, { amb = 0.1, wrap = 0.3, cuts = { 0.3, 0.55, 0.8 }, tok = btok })
  c:put(sx, 42, BARK[1], btok)
end
local top = c:rrect(8, 22, 56, 31, 3)
local front = c:rect(8, 32, 56, 42)
front:cut(c:rect(8, 42, 9, 42)):cut(c:rect(55, 42, 56, 42))
local hedge, ltok = A.hedge(c, top, front, { seed = 7, spineMaxY = 34,
  baseAO = function(bias, h) h:each(function(x, y) local k = K(x, y)
    if y >= 39 then bias[k] = (bias[k] or 0) - (y >= 41 and 2 or 1) end
    if y == 32 or y == 33 then bias[k] = (bias[k] or 0) - 0 end end) end })
for _, cl in ipairs{ { 11, 23 }, { 27, 25 }, { 44, 23 }, { 20, 33 }, { 40, 34 } } do A.cluster(c, hedge, ltok, cl[1], cl[2]) end

-- quirk: robin perched on the top, right of centre
local RO = { o = "#2b1c26", B = "#5e3a2a", b = "#84552f", l = "#a8794e", R = "#e8493b", r = "#ff8a5c", d = "#b52e3f",
  c = "#f3e6cf", e = "#2b1c26", g = "#fff4d6", y = "#f5b82e" }
local rtok = { r = { name = "robin" } }
A.paint(c, {
  "....lbB.....",
  "...lbbbB....",
  "..yglbbBB...",
  "...RrbbBBbB.",
  "...RRrbBBBBB",
  "...dRRbBBB..",
  "....dccBB...",
  ".....dc.....",
}, 33, 14, RO, rtok)
c:put(36, 16, RO.e, rtok)  -- eye
c:put(37, 16, RO.l, rtok)
for _, p in ipairs{ { 37, 22 }, { 38, 22 }, { 39, 22 }, { 40, 22 }, { 41, 22 } } do
  if hedge:has(p[1], p[2]) then c:put(p[1], p[2], A.HLEAF[1], ltok) end end
-- legs
c:put(37, 22, "#8f4a1f", rtok) c:put(39, 22, "#8f4a1f", rtok)
A.save(c, NAME)
