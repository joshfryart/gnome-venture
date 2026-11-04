-- scotch-quail-eggs (first draft, Sonnet). Two whole breadcrumb-crusted scotch eggs behind one cut open to show a
-- speckled-free white ring around an orange yolk inside a sausage layer; on a slim wooden board with a mustard dab.
-- quirk: a tiny speckled quail egg waits unpeeled beside the board dip.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dD14.lua")
local c = A.new("scotch-quail-eggs")
local floor = math.floor
c:groundShadow(32, 56, 24, 3)
-- board
local board = c:rrect(6, 48, 57, 55, 3)
A.lit(c, board, A.R("#b97a4a"), 3, { amb = .1 })
for x = 10, 52, 9 do c:px(x, 51, "#864c33") c:px(x + 1, 51, "#864c33") end
-- crumb balls
local cr = A.R("#d8982e")
local function crumb(cx, cy, r)
  local m = c:ellipse(cx, cy, r, r)
  A.lit(c, m, cr, r, { amb = .08, wrap = .3 })
  A.speck(c, m, { cr[2], cr[6], cr[5] }, .25, cx + cy)
  return m
end
crumb(19, 36, 10) crumb(44, 36, 9)
-- cut one in front
local cut = c:ellipse(32, 38, 11, 11)
A.lit(c, cut, A.R("#b8683a"), 5, { amb = .08 })      -- sausage layer
A.speck(c, cut, { "#8a4a2a", "#e08a52" }, .2, 3)
c:fillMask(c:ellipse(32, 38, 7, 7), "#fff4e0")        -- egg white
c:fillMask(c:ellipse(32, 38, 7, 7):shrink(0):shift(0, 0), "#fff4e0")
local y = c:ellipse(32, 39, 3.6, 3.6)
A.lit(c, y, A.R("#f08a28"), 2.5, { amb = .1 })
c:px(30, 37, "#ffe38a") c:px(31, 37, "#ffe38a")
-- mustard dab
local d = c:ellipse(53, 45, 4, 2.5)
A.lit(c, d, A.R("#f5d22e"), 2, {})
-- quail egg
local qe = A.egg(c, 9, 43, 3.6, 4.6, "#e8d6b0", { nospec = true })
for _, p in ipairs{ { 8, 42 }, { 10, 44 }, { 9, 46 }, { 7, 44 } } do c:px(p[1], p[2], "#6a4a2a") end
c:px(8, 41, "#fff4d6")
A.fin()
