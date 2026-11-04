-- heartwood (dC11 first draft): short cut log, rough bark on the side, cut end face with ring pattern and a deep red-brown core.
-- quirk: the innermost rings form a tiny heart.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dC11.lua")
local c = D.new("heartwood")
local P = D.P
c:groundShadow(30, 55, 22, 3)
local BARK = D.r4("#a87e5a", "#7a4a36", "#52302c", "#2e1c24")
local body = c:rrect(7, 25, 44, 52, 4)
D.part(c, body, BARK, 7)
-- bark furrows
for _, f in ipairs{ {10,30,40,30},{9,36,38,36},{12,42,42,42},{10,47,36,47} } do
  for x = f[1], f[3] do if (x * 7) % 5 ~= 0 then c:px(x, f[2] + ((x // 4) % 2), BARK[1]) end end
end
for _, p in ipairs{ {16,28},{28,34},{20,40},{33,45},{12,50} } do c:px(p[1], p[2], BARK[5]) end
-- knot
c:fillMask(D.ell(20, 33, 2, 1.4), BARK[1]) c:px(20, 33, "#2e1c24")
-- end face
local face = D.ell(45, 38, 9, 14)
D.part(c, face, D.r4("#f4d2a0", "#d9a06a", "#b9783f", "#7a4a36"), 6)
for _, r in ipairs{ {7.6,12}, {5.8,9.4}, {4,6.6} } do
  local rm = D.ell(45, 38, r[1], r[2])
  rm:edge():each(function(x, y) if face:has(x, y) then c:px(x, y, "#9a5a3f") end end)
end
-- core in red-brown
D.part(c, D.ell(45, 38, 3, 4.6), D.r4("#c06a52", "#9a3f3f", "#6e2038", "#3f1830"), 1)
-- tiny heart
c:px(44, 37, "#f0a090") c:px(46, 37, "#f0a090") c:px(44, 38, "#f0a090") c:px(45, 38, "#f0a090") c:px(46, 38, "#f0a090") c:px(45, 39, "#f0a090")
-- bark ring
face:edge():each(function(x, y) if x > 44 and not face:has(x, y) then end end)
D.fin()
