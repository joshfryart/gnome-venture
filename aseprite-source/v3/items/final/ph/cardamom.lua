-- cardamom (first draft, Sonnet). quirk: one pod has split open showing black seeds
local NAME = "cardamom"
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dB14.lua")
local B, H, HP, X = D.B, D.H, D.HP, D.X
local floor, max, min, abs, sqrt, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sqrt, math.sin, math.cos, math.pi
local LEAF = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local TAN = { "#3a2420", "#5e3a2c", "#84583c", "#a87a50", "#cca06a", "#ecc892" }

local c = D.new(NAME)
local GR = { "#24442a", "#3a6a34", "#5a9444", "#7cb450", "#a4cf66", "#d0e890" }
local pods = { {18, 46, 14, 5, -0.5}, {32, 38, 15, 5.4, -0.15}, {44, 24, 13, 4.8, 0.6} }
-- leaf behind
B.blade(c, 6, 20, 30, 8, 5, { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }, { veins = { 6, 12, 18 } })
for i, p in ipairs(pods) do
  local m = B.ell(p[1], p[2], p[3], p[4], p[5])
  -- spindle: cut the ends
  local sp = HP.mask() m:each(function(x, y) local dx, dy = x - p[1], y - p[2]
    local u = (dx * cos(p[5]) + dy * sin(p[5])) / p[3]
    local v = (-dx * sin(p[5]) + dy * cos(p[5])) / p[4]
    if abs(v) <= 1 - u * u * 0.55 then sp:set(x, y) end end)
  B.lit(c, sp, GR, 2.5)
  -- ridges
  for o = -1, 1, 1 do
    local ca, sa = cos(p[5]), sin(p[5])
    B.ln(c, p[1] - ca * (p[3] - 2) - sa * o * 1.7, p[2] - sa * (p[3] - 2) + ca * o * 1.7, p[1] + ca * (p[3] - 2) - sa * o * 1.7, p[2] + sa * (p[3] - 2) + ca * o * 1.7, GR[2], sp)
  end
  if i == 2 then
    -- split: dark gap with seeds
    local gap = B.ell(p[1] + 1, p[2] + 1, 8, 1.8, p[5]) gap:clip(sp)
    c:fillMask(gap, "#3a1c14")
    for k = -2, 2 do local sx, sy = p[1] + 1 + k * 3 * cos(p[5]), p[2] + 1 + k * 3 * sin(p[5]) c:px(floor(sx + .5), floor(sy + .5), "#2b1c26") c:px(floor(sx + .5), floor(sy - 0.5), "#6a4a3a") end
  end
end
D.fin()
