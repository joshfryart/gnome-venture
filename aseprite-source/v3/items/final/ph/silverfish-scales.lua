-- silverfish-scales (lean W2_18)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "silverfish-scales" }
local floor, rad, cos, sin, sqrt, atan2, abs = math.floor, math.rad, math.cos, math.sin, math.sqrt, math.atan, math.abs
local SIL = { "#4a4f78", "#6b7499", "#8f9bbb", "#b4c0d8", "#d8e0ee", "#f4f8fc" }
local VIO = { "#4d3f7a", "#6f5fa0", "#9482be", "#b7a8d8", "#d9cfee", "#f6f0fc" }
local TEA = { "#2f6b7c", "#3f93a0", "#6dbdb8", "#a2dccb", "#d2f1de", "#f2fff0" }
local PNK = { "#8a4a82", "#b66aa0", "#d98fb8", "#efb8cc", "#f8d9de", "#fff2ee" }
local function scale(ox, oy, dir, r, ramp, half)
  half = half or 62
  local pts = { { ox, oy } }
  for k = 0, 14 do
    local a = rad(dir - half + 2 * half * k / 14)
    local rr = (k == 0 or k == 14) and r * 0.85 or r
    pts[#pts + 1] = { floor(ox + cos(a) * rr + 0.5), floor(oy + sin(a) * rr + 0.5) }
  end
  local m = c:poly(pts)
  local rim = m:copy():cut(m:copy():shrink(1))
  m:each(function(x, y)
    local dx, dy = x - ox, y - oy
    local d = sqrt(dx * dx + dy * dy) / r
    local ang = math.deg(math.atan(dy, dx)) - dir
    local i = 4
    if d < 0.35 then i = 2
    elseif d > 0.78 then i = (dx * cos(rad(dir + 90)) + dy * sin(rad(dir + 90)) < 0) and 5 or 3 end
    if d > 0.4 then
      local fr = ((ang + half) / (2 * half) * 6) % 1
      if fr < 0.16 then i = i - 1 end
    end
    if rim:has(x, y) then i = 1 end
    c:put(x, y, ramp[math.max(1, i)], { r = { name = "scale" } })
  end)
  local sx, sy = floor(ox + cos(rad(dir - 25)) * r * 0.8 + 0.5), floor(oy + sin(rad(dir - 25)) * r * 0.8 + 0.5)
  c:px(sx, sy, ramp[6])
end
c:groundShadow(32, 56, 19, 2)
local rows = {
  { 48, { 26, 38 } }, { 40, { 20, 32, 44 } }, { 32, { 14, 26, 38, 50 } }, { 24, { 20, 32, 44 } }, { 16, { 26, 38 } },
}
local n = 0
for _, row in ipairs(rows) do
  for _, x in ipairs(row[2]) do
    n = n + 1
    local ramp = (n % 4 == 0) and VIO or SIL
    local j = (X.hash(x, row[1], 5) - 0.5) * 18
    scale(x, row[1], 90 + j, 7 + floor(X.hash(x, row[1], 6) * 2), ramp)
  end
end
-- quirk: a loose iridescent scale standing off the patch, with a dew drop
scale(47, 13, -40, 8, TEA, 55)
c:px(55, 9, PNK[4]) c:px(56, 10, PNK[3]) c:px(55, 11, PNK[2])
c:px(10, 24, "#cdd5e8") c:px(8, 30, "#cdd5e8") c:px(55, 44, "#cdd5e8") c:px(51, 54, "#cdd5e8") c:px(12, 50, "#cdd5e8")
G.fin(c, "silverfish-scales")
