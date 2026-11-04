-- greigs-tulip-seed (dC10 first draft): flat papery D-shaped tulip seeds on a leaf scrap, one sprouted with a single folded grey-green blade.
-- quirk: a tiny red bud-tip already peeks from the blade.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dC10.lua")
local B, H, HP, X, K = D.B, D.H, D.HP, D.X, D.K
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
local c = D.new('greigs-tulip-seed')
D.scrap(c, 31, 47, 22, 9, -0.1, 'moss')
local SD = { '#5a3a2a', '#8a5a34', '#b07a42', '#d09c58', '#e8c47a', '#f8e4a8' }
-- sprout: broad upright blade with fold
B.ln(c, 40, 44, 40, 38, '#b8dc92')
local bl = D.blade(c, 40, 42, 40, 10, 5, { '#1f3f46', '#2c5a58', '#3f7a64', '#5a9a74', '#86bb8c', '#bcdcaa' }, { veins = { 6, 12, 18 }, slant = 1.4 })
-- bud tip
c:fillMask(c:rect(39, 8, 41, 10), '#e8493b') c:px(40, 7, '#e8493b') c:px(39, 8, '#ff8a5c') c:px(41, 10, '#b52e3f')
for _, s in ipairs{ {15,48,0.3}, {26,51,-0.2}, {50,47,0.5}, {35,49,0} } do
  local m = B.seed(c, s[1], s[2], 4, 3, s[3], SD, '#1f553f', '#fff4d6')
  c:px(floor(s[1] - 2), floor(s[2] + 1), SD[1]) c:px(floor(s[1] + 3), floor(s[2]), SD[6])
end
D.fin()
