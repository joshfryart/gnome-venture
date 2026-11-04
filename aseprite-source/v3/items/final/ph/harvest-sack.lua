-- harvest-sack (dC11 first draft): slim burlap sack, gathered neck tied with gold twine, wheat ears and a carrot top peeking out, stitched square patch.
-- quirk: a tiny mouse tail curls out of the folded-over top.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dC11.lua")
local c = D.new("harvest-sack")
local P = D.P
c:groundShadow(32, 56, 15, 3)
local BUR = D.r4("#f3d9a0", "#d9aa66", "#a9743f", "#5e3a2e")
-- wheat and carrot top behind the neck
for i, x in ipairs{ 25, 30, 36 } do
  local tx = x + (i - 2) * 4
  D.ln(c, 30 + i * 2, 26, tx, 8 + i * 2, P.gold.shade)
  for k = 0, 3 do
    c:fillMask(D.ell(tx + (k % 2 == 0 and -1 or 1), 10 + i * 2 + k * 2, 1.2, 1.6, 0), P.gold.base)
    c:px(tx + (k % 2 == 0 and -1 or 1), 9 + i * 2 + k * 2, P.gold.hi)
  end
end
for _, q in ipairs{ {41,12,36,25}, {44,16,38,26}, {39,8,35,24} } do D.ln(c, q[3], q[4], q[1], q[2], P.moss.shade) c:fillMask(D.ell(q[1], q[2], 1.6, 2.4, 0.4), P.moss.base) c:px(q[1] - 1, q[2] - 1, P.moss.hi) end
-- body
local body = D.ell(32, 43, 16, 13):add(c:poly{ {25,27},{39,27},{45,36},{19,36} })
D.part(c, body, BUR, 6)
-- weave texture
body:each(function(x, y) if (x + y) % 4 == 0 and (x * 3 + y) % 7 < 3 then c:px(x, y, BUR[3]) end end)
-- folded rim at the neck
local rim = c:poly{ {22,25},{42,25},{44,29},{20,29} }
D.part(c, rim, BUR, 2)
for x = 22, 42, 3 do c:px(x, 27, BUR[2]) end
-- twine
for x = 22, 42 do c:px(x, 31, P.gold.base) c:px(x, 32, (x % 2 == 0) and P.gold.shade or P.gold.deep) end
c:px(30, 33, P.gold.shade) c:px(29, 34, P.gold.shade) c:px(34, 33, P.gold.shade) c:px(35, 35, P.gold.deep)
-- patch
local pat = c:rrect(26, 40, 38, 49, 1)
D.part(c, pat, D.r4("#ffb8a0", "#e8756a", "#b5424f", "#6e2038"), 2)
c:stitch{ {26,40},{38,40},{38,49},{26,49},{26,40} }
-- mouse tail
D.ln(c, 41, 27, 46, 26, "#e8a8a8") D.ln(c, 46, 26, 48, 22, "#e8a8a8") c:px(48, 21, "#c97d8a")
D.fin()
