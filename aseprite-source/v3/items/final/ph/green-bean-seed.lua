-- green-bean-seed (dC10 first draft): two kidney beans, mottled green-cream with a pale eye, on a leaf scrap.
-- The right bean has sprouted: a hooked white stem lifting two broad heart-shaped bean leaves.
-- quirk: the bean's white eye (hilum) looks back at you.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dC10.lua")
local B, H, HP, X, K = D.B, D.H, D.HP, D.X, D.K
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
local c = D.new('green-bean-seed')
D.scrap(c, 30, 47, 22, 9, 0.12, 'moss')
local SD = { '#4a5a2c', '#7a8a48', '#a2b068', '#c4d088', '#e0eaa8', '#f6fad0' }
-- sprout hook
B.ln(c, 41, 43, 41, 32, '#b8dc92') B.ln(c, 42, 43, 42, 31, '#e2f2bc')
B.ln(c, 41, 32, 43, 27, '#b8dc92') B.ln(c, 42, 31, 44, 27, '#e2f2bc')
D.leafE(c, 34, 24, 8, 5.4, -0.25, 'moss', 2)
D.leafE(c, 51, 22, 8, 5.4, 0.3, 'moss', 2)
D.leafE(c, 44, 18, 3, 3.5, 1.2, 'moss', 1)
for _, s in ipairs{ {17,49,-0.5}, {29,51,0.25}, {41,47,-0.1} } do
  B.seed(c, s[1], s[2], 5, 3, s[3], SD, '#1f553f', '#fff4d6')
  -- kidney notch + eye
  local ex, ey = floor(s[1] + 0.5), floor(s[2] + 0.5)
  c:px(ex, ey - 1, '#fff4d6') c:px(ex + 1, ey, '#f6fad0') c:px(ex, ey, '#e0eaa8')
  c:px(ex - 2, ey + 1, SD[2]) c:px(ex + 2, ey + 1, SD[2])
end
D.fin()
