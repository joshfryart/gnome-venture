-- samphire-salad (first draft, Sonnet). A shallow cream bowl heaped with bright green curled samphire sprigs (jointed
-- strands), red cherry-tomato halves and a few cream feta crumbs, a lemon wedge on the rim.
-- quirk: a single sprig loops out over the bowl like a handle and drips lemon juice.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dD14.lua")
local c = A.new("samphire-salad")
local floor = math.floor
c:groundShadow(32, 54, 22, 4)
-- bowl
local body = c:ellipse(32, 36, 24, 18):clip(c:rect(0, 36, 63, 54))
body:add(c:rect(8, 33, 55, 36))
A.lit(c, body, A.R("#efe2c8"), 8, { amb = .08, wrap = .3 })
c:fillMask(c:rect(14, 47, 49, 47), "#c9a070")
local rim = c:ellipse(32, 33, 24, 7)
A.lit(c, rim, A.R("#efe2c8"), 2.5, { amb = .06 })
-- salad heap
local heap = c:ellipse(32, 31, 20, 6)
heap:add(c:ellipse(32, 25, 14, 7))
A.lit(c, heap, A.R("#5fa04a"), 3, { amb = .1 })
local G = A.R("#4a9a4e")
-- curled sprigs
local sprigs = { { { 16, 30 }, { 18, 18 }, { 26, 18 }, { 24, 26 } }, { { 26, 30 }, { 28, 12 }, { 38, 14 }, { 36, 26 } },
                 { { 36, 30 }, { 40, 14 }, { 50, 20 }, { 46, 30 } }, { { 22, 28 }, { 30, 20 }, { 42, 22 }, { 48, 28 } } }
for i, s in ipairs(sprigs) do
  local pts = A.curve(s, 30)
  for j, p in ipairs(pts) do
    local x, y = floor(p[1] + .5), floor(p[2] + .5)
    c:px(x, y, G[4]) c:px(x + 1, y, G[3]) c:px(x, y - 1, G[5])
    if j % 4 == 0 then c:px(x, y, G[2]) end
  end
  A.sph(c, floor(pts[#pts][1]), floor(pts[#pts][2]), 1.4, "#c4e07a", { nospec = true })
end
-- tomato halves
for _, p in ipairs{ { 19, 31 }, { 44, 30 }, { 32, 33 } } do
  A.sph(c, p[1], p[2], 3.2, "#e8493b", {})
  c:px(p[1], p[2], "#ffc4a0") c:px(p[1] + 1, p[2] + 1, "#ffc4a0")
end
for _, p in ipairs{ { 25, 33 }, { 38, 34 }, { 51, 31 } } do c:px(p[1], p[2], "#fff4d6") c:px(p[1] + 1, p[2], "#e8dcc0") end
-- lemon wedge on rim
local lem = c:poly{ { 47, 24 }, { 58, 30 }, { 52, 36 } }
A.lit(c, lem, A.R("#f5d22e"), 2, { amb = .1 })
c:fillMask(c:poly{ { 49, 27 }, { 55, 30 }, { 52, 33 } }, "#ffe97a")
c:px(52, 30, "#fff4d6")
c:px(57, 37, "#ffe38a") c:px(57, 38, "#f5b82e")
A.fin()
