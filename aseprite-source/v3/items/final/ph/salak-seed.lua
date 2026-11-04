-- salak-seed (first draft, Sonnet). Three big glossy chestnut-brown salak seeds (pale hilum scar) on a spiny palm-frond
-- scrap (midrib with narrow leaflets); the right seed sprouted a single spear leaf and a rolled second leaf.
-- quirk: a tiny brown scale from the fruit skin and a spine sit on the stem.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dD14.lua")
local c = A.new("salak-seed")
local floor = math.floor
-- frond: midrib from (4,58) to (58,44), leaflets both sides
local ax, ay, bx, by = 4, 58, 58, 44
A.rod(c, ax, ay, bx, by, 1.1, "#8a7a3a", { amb = .1 })
for i = 1, 8 do
  local t = (i - .3) / 8.6
  local mx, my = ax + (bx - ax) * t, ay + (by - ay) * t
  A.blade(c, mx, my, mx + 10, my + 12 - i * .2, 1.7, "#4f8a45", { veins = {}, norib = false })
  A.blade(c, mx, my, mx + 9, my - 12 + i * .2, 1.7, "#6aa650", { veins = {}, norib = false })
end
local sd = A.R("#7a3f26")
for _, s in ipairs{ { 14, 54, 4.2, 3.0, -.28 }, { 25, 52, 4.3, 3.1, -.3 }, { 37, 49, 4.2, 3.2, -.3 } } do
  A.seed(c, s[1], s[2], s[3], s[4], s[5], sd, "#2a4a30", "#ffe0b0")
  c:px(s[1] + 3, s[2], "#e8c9a0") c:px(s[1] + 3, s[2] + 1, "#c9a070")
end
-- sprout: stem + spear leaf
A.sprout(c, { { 37, 46 }, { 37, 38 }, { 38, 30 }, { 38, 24 } }, "#9aa855", {
  { 38, 30, 38, 8, 3.2, "#5fa04a", { 4, 8, 12 }, },
  { 37, 38, 49, 29, 2.4, "#7cb85a", { 3, 6 } } })
c:px(36, 40, "#b8864a") c:px(36, 41, "#7a4a28") c:px(39, 35, "#2a3a28") -- scale + spine
A.fin()
