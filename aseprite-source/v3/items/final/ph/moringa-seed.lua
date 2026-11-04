-- moringa-seed: two round brown seeds with three papery cream wings on a leaf scrap, sprout with a pinnate leaf of tiny leaflets. quirk: one wing is curled up like a sail.
local D = dofile(debug.getinfo(1,"S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dC24.lua")
local H, HP, B, X = D.H, D.HP, D.B, D.X
local floor, sin, cos, pi, max, min, abs = math.floor, math.sin, math.cos, math.pi, math.max, math.min, math.abs
local c = D.new("moringa-seed")
D.scrap(c, { ramp = "moss" })
local LF = D.R("#d4f08a", "#8ccb4e", "#3f9150", "#24544a")
D.stem(c, { {34,48}, {33,36}, {35,24}, {38,14} }, 1, "#7a8a48", "#b7c46a")
for i, p in ipairs{ {34,44,1}, {33,38,-1}, {34,32,1}, {35,27,-1}, {36,22,1}, {37,18,-1} } do
  local s = 2.6 - i * 0.2
  B.lit(c, B.ell(p[1] + p[3] * (s + 1), p[2], s, s * .7, p[3] > 0 and -0.3 or 0.3), LF, 1.6)
end
B.lit(c, B.ell(39, 11, 2.6, 2, -0.8), LF, 1.6)
local WING = D.R("#fffbea", "#f2e6c6", "#d4c098", "#9a8460")
local function seed(cx, cy, ang, sail)
  for k = 0, 2 do
    local a = ang + k * 2.094
    local w = B.ell(cx + cos(a) * 5.5, cy + sin(a) * 4.2, 4.6, 2.1, a)
    if not (sail and k == 1) then B.lit(c, w, WING, 1.8) B.ln(c, cx + cos(a) * 3, cy + sin(a) * 2.2, cx + cos(a) * 8.5, cy + sin(a) * 6.2, WING.deep, w)
    else B.lit(c, B.ell(cx + cos(a) * 3, cy + sin(a) * 6, 2.0, 4.6, a + 1.2), WING, 1.8) end
  end
  B.seed(c, cx, cy, 3.6, 3.4, 0, D.R("#e8c08a", "#a86a3c", "#6c3f30", "#3c2224"), "#1f553f")
end
seed(18, 46, 0.2) seed(48, 47, 3.3, true)
D.fin()
