-- miss-joaquim-seed: dust-fine tan seeds spilling from a small split capsule on a thick strap-like orchid leaf scrap; sprout is a fat strap leaf with a tiny magenta bloom. quirk: the capsule is cracked open.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dC23.lua")
local B, R, P = D.B, D.R, D.P
local c = D.new("miss-joaquim-seed")
D.scrap(c, { ax = 7, ay = 56, bx = 54, by = 46, w = 8, leaf = { "#1c4a38", "#2a6a48", "#3e8a58", "#5aaa68", "#86c886", "#b4e4a0" }, veins = { 8, 16, 24, 32, 40 }, prof = function(t) return 0.8 end })
-- capsule
local cap = B.ell(21, 50, 6, 3, -0.3)
B.lit(c, cap, { "#3a4a1c", "#586a2a", "#7e8c3a", "#a0ac52", "#c4cc78", "#e4e8a8" }, 2.8)
B.ln(c, 17, 52, 25, 48, "#2b2a18")
-- fine seeds spilled
for i = 0, 18 do local x, y = 27 + (i * 7) % 15, 51 + (i * 5) % 5 c:px(x, y, i % 3 == 0 and "#e8cc8a" or "#c8a460") end
-- strap leaf sprout + bloom
B.ln(c, 36, 47, 36, 36, "#4a8a50")
B.blade(c, 36, 44, 24, 20, 3, R.leaf, { veins = { 4, 8, 12, 16 } })
B.blade(c, 37, 44, 46, 18, 3, R.leaf, { veins = { 4, 8, 12, 16 } })
local M = { "#6a1a4a", "#962a6c", "#c24490", "#e064aa", "#f08ec6", "#ffc4e4" }
for _, p in ipairs{ { 33, 24 }, { 38, 24 }, { 36, 21 }, { 36, 27 } } do D.el(c, p[1], p[2], 2.4, 2.4, M, 1.3) end
c:px(36, 24, "#f5b82e") c:px(36, 25, "#f5b82e")
D.fin()
