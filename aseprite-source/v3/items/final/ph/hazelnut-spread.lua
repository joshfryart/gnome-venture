-- hazelnut-spread (dC11 first draft): squat glass jar of glossy chocolate-hazelnut spread, scarlet screw lid, cream label with a nut.
-- quirk: a fat blob of spread has dripped over the lid rim and runs down the glass.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dC11.lua")
local c = D.new("hazelnut-spread")
local P = D.P
c:groundShadow(32, 57, 16, 3)
local GLASS = D.r4("#f0fbff", "#b6e6f0", "#7fb8d4", "#3f6e92")
local CHOC = D.r4("#a2704f", "#6e4533", "#4a2c2b", "#2a1822")
local jar = c:rrect(16, 23, 48, 56, 5)
D.part(c, jar, GLASS, 4)
local fill = c:rrect(18, 25, 46, 54, 4)
D.part(c, fill, CHOC, 5)
-- swirl highlight
for _, p in ipairs{ {22,29},{23,29},{24,30},{25,30} } do c:px(p[1], p[2], "#d9a982") end
-- label
local lab = c:rrect(22, 35, 42, 49, 2)
D.part(c, lab, D.r4("#fffaf0", "#f4e3b8", "#d6b98a", "#8f6e55"), 2)
D.part(c, D.ell(32, 43, 4, 4.6), D.r4("#e8b982", "#b97a4a", "#864c33", "#51302b"), 2)
c:fillMask(c:rect(29, 38, 35, 39), "#3f9150")
-- lid
local lid = c:rrect(14, 15, 50, 24, 2)
D.part(c, lid, "ember", 2)
for x = 17, 47, 3 do c:px(x, 20, P.ember.shade) c:px(x, 21, P.ember.deep) end
-- drip
local drip = c:rrect(40, 22, 44, 32, 2):add(D.ell(42, 34, 2.6, 3))
D.part(c, drip, CHOC, 2)
c:px(41, 32, "#d9a982") c:px(41, 23, "#d9a982")
D.fin()
