-- naranjilla-seed: flat pale cream disc seeds with a notch, on a scrap; sprout with a broad fuzzy heart leaf with purple veins. quirk: the sprout leaf's fuzz catches a cream hair-tuft on the stem.
local D = dofile(debug.getinfo(1,"S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dC24.lua")
local H, HP, B, X = D.H, D.HP, D.B, D.X
local floor, sin, cos, pi, max, min, abs = math.floor, math.sin, math.cos, math.pi, math.max, math.min, math.abs
local c = D.new("naranjilla-seed")
D.scrap(c, { ramp = "moss", x0 = 6, y0 = 54, x1 = 58, y1 = 52, w = 6.4 })
local LF = D.R("#d4ec8a", "#8cc050", "#4a8a48", "#2a5240")
D.stem(c, { {30,48}, {30,38}, {32,28} }, 2, "#8a6aa8", "#c8a8e8")
for _, p in ipairs{ {28,44},{28,38},{31,34},{34,30},{29,41} } do c:px(p[1], p[2], "#e8d4f8") end
local m = D.heart(c, 33, 20, 12, -1.5, LF, false)
local PU = "#7a4ab8"
B.ln(c, 33, 29, 33, 11, PU, m)
for k = 0, 3 do local y = 27 - k * 4 B.ln(c, 33, y, 24 - k * .5, y - 4, PU, m) B.ln(c, 33, y, 42 + k * .5, y - 4, PU, m) end
m:edge():each(function(x, y) if X.hash(x, y, 2) > .6 then c:px(x, y, "#f0f8c0") end end)
B.lit(c, B.ell(22, 40, 4, 2.4, 0.3), LF, 1.6) 
local SD = D.R("#fffbe8", "#f4e4a4", "#d0b878", "#8a7048")
for _, s in ipairs{ {14,50}, {22,53}, {44,50}, {52,52} } do
  c:fillMask(B.ell(s[1] + 1, s[2] + 1.2, 3.4, 3, 0), "#1f553f")
  local d = c:ellipse(s[1], s[2], 3, 2.6):cut(c:rect(s[1] + 2, s[2] - 1, s[1] + 4, s[2] - 1))
  B.lit(c, d, SD, 2)
  c:px(s[1] - 1, s[2] - 1, "#fffaea")
end
D.fin()
