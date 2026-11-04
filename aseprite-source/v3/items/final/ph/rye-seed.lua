-- rye-seed (first draft, Sonnet). Five slender grey-tan rye grains with a lengthwise crease on a long narrow
-- leaf scrap; the right grain has sprouted: a white curled rootlet on one end and three slim blue-green blades.
-- quirk: one grain's husk has split open to show the pale kernel.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dD13.lua")
local c = A.new("rye-seed")
local LF = A.R("#4f8a50")
A.scrap(c, 3, 57, 60, 43, 6.5, LF, { 6, 11, 16, 21, 26, 31, 36, 41, 46 })
local sd = A.R("#b09a70")
for _, s in ipairs{ { 12, 53, -.25 }, { 20, 54, .15 }, { 28, 52, -.1 }, { 36, 51, .3 } } do
  A.seed(c, s[1], s[2], 4.4, 1.7, s[3], sd, LF[1], "#f0e6c8")
  A.ln(c, s[1] - 3, s[2] + 1, s[1] + 3, s[2] + (s[3] > 0 and 1 or 0), "#6e5a40")
end
-- split grain
A.seed(c, 44, 48, 4.4, 1.8, -.1, sd, LF[1], "#f0e6c8")
for x = 41, 47 do c:px(x, 48, "#f4ecd0") end
-- rootlet
for _, p in ipairs{ { 39, 49 }, { 38, 50 }, { 37, 50 }, { 36, 49 }, { 36, 48 } } do c:px(p[1], p[2], "#fff4d6") end
A.blade(c, 46, 46, 41, 14, 1.8, "#6fae9a", { veins = {}, slant = 2 })
A.blade(c, 46, 46, 52, 18, 1.8, "#5a9a8a", { veins = {}, slant = 2 })
A.blade(c, 46, 46, 33, 24, 1.6, "#7fbfa0", { veins = {}, slant = 2 })
A.fin()
