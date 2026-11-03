local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA4.lua")
local HP, X, INK, CR = D.HP, D.X, D.INK, D.CR
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- ico-feather: one slanted blue feather with a quill and a gold eye-spot.
-- quirk: a loose split in the vane near the tip, with a stray barb.
local c = D.new("ico-feather")
local TEAL = { "#14485a", "#1f6a7a", "#2a8a96", "#3aaab0", "#6cc8c8", "#b6ece0" }
D.B.blade(c, 14, 52, 54, 10, 11, TEAL, { veins = { 6, 11, 16, 21, 26, 31 }, slant = 2.4 })
c:part(c:line({ {8,58},{16,50} }, 3), D.CREAM, { noshade = true, nopop = true })
-- eye-spot
D.fill(D.disc(36, 26, 4), "#e8b028") D.fill(D.disc(36, 26, 2), "#2a4a7a") c:px(34, 24, CR)
-- split notch + stray barb
for _, p in ipairs{ {44,30},{45,29},{46,28},{47,27} } do c:px(p[1], p[2], "#14485a") end
c:part(c:line({ {47,29},{54,32} }, 2), TEAL, { noshade = true, nopop = true })
D.fin()
