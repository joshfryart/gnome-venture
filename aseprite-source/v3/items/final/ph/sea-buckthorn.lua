-- sea-buckthorn (first draft, Sonnet). A grey-brown thorny twig arching diagonally, its length clustered with bright
-- orange glossy berries (touching but separated), a few narrow silver-green leaves at the tips and sharp thorns.
-- quirk: a tiny ladybird sits on the topmost berry.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dD14.lua")
local c = A.new("sea-buckthorn")
local floor = math.floor
local pts = A.curve({ { 6, 50 }, { 16, 36 }, { 36, 40 }, { 56, 14 } }, 50)
-- twig
local tw = A.sweepM(pts, function(t) return 1.5 - t * .5 end)
A.lit(c, tw, A.R("#8a7a6a"), 1.5, { amb = .1 })
-- leaves behind
local lv = { { 20, 36, 10, 24 }, { 38, 42, 52, 52 }, { 50, 24, 60, 30 }, { 12, 46, 4, 58 }, { 44, 28, 36, 12 } }
for _, l in ipairs(lv) do A.blade(c, l[1], l[2], l[3], l[4], 2.1, "#9ab88a", { veins = {}, norib = false }) end
-- berries along twig, both sides
local pos = { 3, 6, 9, 12, 15, 18, 21, 24, 27, 30, 33, 36, 39, 42, 45 }
local R = A.R("#f08a22")
local order = {}
for i, k in ipairs(pos) do
  local p = pts[k + 1]
  local nx, ny = -p[4], p[3]
  local side = (i % 2 == 0) and 1 or -1
  order[#order + 1] = { floor(p[1] + nx * 3.4 * side + .5), floor(p[2] + ny * 3.4 * side + .5) }
end
for _, o in ipairs(order) do
  A.sph(c, o[1], o[2], 2.9, R, { spec = "#fff4d6" })
end
-- thorns
for _, k in ipairs{ 8, 19, 31, 40 } do local p = pts[k + 1] local x, y = floor(p[1] + .5), floor(p[2] + .5)
  c:px(x + 1, y + 2, "#4a3a3c") c:px(x + 2, y + 3, "#2b1c26") end
-- ladybird on topmost berry
local top = order[#order]
local lx, ly = top[1], top[2]
A.sph(c, lx, ly - 1, 2.2, "#d82a28", { nospec = true })
c:px(lx, ly - 3, "#2b1c26") c:px(lx - 1, ly - 1, "#2b1c26") c:px(lx + 1, ly, "#2b1c26")
c:px(lx - 1, ly - 2, "#ff8a5c")
A.fin()
