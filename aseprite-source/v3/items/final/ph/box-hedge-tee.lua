-- box-hedge-tee (final, Opus aB10_2). A T-junction of clipped boxwood in 3/4 view: a long arm runs left-right at the
-- back, the stem arm runs down toward the viewer from its middle. Sheared top faces lit upper-left with leaf-clump
-- texture, rounded clipped edges, darker front faces with cavities, AO in both inside bends where the back arm's face
-- tucks behind the stem, woody stems at the base, bark-mulch strip and ground shadow.
-- quirk: a small orange butterfly has landed on the top of the stem arm, wings half open.
local NAME = "box-hedge-tee"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB10_2.lua")
local HP, X, K = A.HP, A.X, A.K
local c = A.new(NAME)
local BOX = { "#14362f", "#1f5238", "#2d6e40", "#438c47", "#66ad52", "#9ccf68" }
local MULCH = { "#3a2226", "#5a3428", "#7a4a30", "#9a6a42", "#b98a5a" }
local WOOD = { "#4a2c26", "#6e4430" }

c:groundShadow(32, 36, 24, 1.5)
c:groundShadow(32, 53, 8, 1.5)
local plan = c:rrect(7, 22, 56, 31, 2):add(c:rrect(27, 22, 37, 50, 2))
local Hh = 11
A.mulch(c, plan, MULCH, 13)
local all, top, front, Z, idx, tok = A.hedge(c, plan, Hh, BOX, { seed = 41, R = 2.5 })
-- inside-bend AO on both sides of the stem arm (back arm's front face in its shadow)
front:each(function(x, y) local i = idx[K(x, y)]
  if x >= 24 and x <= 26 then c:put(x, y, BOX[math.max(1, i - (x == 26 and 2 or 1))], tok) end
  if x >= 38 and x <= 39 then c:put(x, y, BOX[math.max(1, i - (x == 38 and 2 or 1))], tok) end
end)
-- sprigs poking above the clipped top line
for _, s in ipairs{ { 12, 1, 6 }, { 19, 2, 5 }, { 20, 1, 6 }, { 44, 1, 6 }, { 51, 2, 5 } } do
  local x, yt = s[1]
  for y = 0, 63 do if top:has(x, y) then yt = y break end end
  if yt then for d = 1, s[2] do c:put(x, yt - d, BOX[s[3] - (d - 1)], tok) end end
end
-- woody stems at the base
for _, x in ipairs{ 11, 17, 22, 41, 47, 53, 30, 34 } do
  for y = 0, 63 do local z = Z[K(x, y)]
    if front:has(x, y) and z and z >= 1 and z <= 2 then c:put(x, y, WOOD[z == 1 and 1 or 2], tok) end end
end

-- quirk: orange butterfly on the stem top
local btok = { r = { name = "butterfly" } }
A.map(c, 29, 30, {
  "..d.d..",
  "hhodohh",
  "hoosooh",
  ".so.os.",
}, { h = "#ffe08a", o = "#f59a2e", s = "#c85a2a", d = "#3a2226" }, btok)
-- contact shadow under the wings
for _, q in ipairs{ { 30, 34 }, { 31, 34 }, { 33, 34 }, { 34, 34 } } do if top:has(q[1], q[2]) then c:put(q[1], q[2], BOX[2], tok) end end

A.save(c, NAME)
