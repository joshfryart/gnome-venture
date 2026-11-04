-- morpho-scales: five iridescent blue wing scales fanned like cards, each ribbed with a tiny stalk. quirk: one scale is the orange-brown underside colour.
local D = dofile(debug.getinfo(1,"S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dC24.lua")
local H, HP, B, X = D.H, D.HP, D.B, D.X
local floor, sin, cos, pi, max, min, abs = math.floor, math.sin, math.cos, math.pi, math.max, math.min, math.abs
local c = D.new("morpho-scales")
local BL = D.R("#c8f4ff", "#3c8cf0", "#2450c0", "#1a2a6e")
local OR = D.R("#ffd08a", "#d47a2c", "#9a4a2c", "#5a2a28")
local ox, oy = 32, 56
local list = { {-1.25, BL}, {-0.62, BL}, {1.2, BL}, {0.6, OR}, {0.0, BL} }
for _, s in ipairs(list) do
  local a = s[1] - pi / 2
  local cx, cy = ox + cos(a) * 17, oy + sin(a) * 17
  c:fillMask(c:line({ {ox, oy}, {ox + cos(a) * 6, oy + sin(a) * 6} }, 1), "#5a2a28")
  local m = B.ell(cx, cy, 7.2, 10.5, a + pi / 2)
  B.lit(c, m, s[2], 4)
  for k = -4, 4 do
    local px, py = cx + cos(a + pi / 2) * k * 1.5, cy + sin(a + pi / 2) * k * 1.5
    B.ln(c, px - cos(a) * 9, py - sin(a) * 9, px + cos(a) * 9, py + sin(a) * 9, s[2] == BL and (k % 2 == 0 and "#58b8ff" or "#2a5ccc") or (k % 2 == 0 and "#f0a04c" or "#9a4a2c"), m)
  end
  -- dark rim
  m:edge():each(function(x, y) if y < cy - 3 then c:px(x, y, s[2].shade) end end)
  c:px(floor(cx - 2), floor(cy - 6), "#fff4d6") c:px(floor(cx - 1), floor(cy - 6), "#fff4d6")
end
c:sparkle(50, 10)
D.fin()
