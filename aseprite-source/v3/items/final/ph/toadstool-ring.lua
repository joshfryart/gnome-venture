-- toadstool-ring (lean D3o_5)
-- A fairy ring: a grassy mound disc with six red spotted toadstools set around the rim, seen from above-front.
-- quirk: a single firefly glint hovers in the empty middle.
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "toadstool-ring" }
local sin, cos, pi, floor = math.sin, math.cos, math.pi, math.floor
local function sh(m, ramp, R, amb, wrap, bias, tok)
  local n = X.pillow(m, R)
  local v = X.light(n, { amb = amb or 0.1, wrap = wrap or 0.25 })
  G.tone(c, m, v, ramp, nil, bias, tok)
  return n, v
end
local GR = { "#1f4030", "#2e5e38", "#437f3e", "#5f9e48", "#88bf58", "#b4dc7c" }
local RED = { "#4a1228", "#7e1e3a", "#b82e3c", "#e04a3c", "#f5704c", "#ffa478" }
local CRM = { "#6e5a78", "#a08e98", "#cfc0b4", "#ece0cc", "#fbf2de", "#ffffee" }
local ground = c:ellipse(32, 46, 25, 10)
local _, gv = sh(ground, GR, 9, 0.1, 0.3)
-- grass flecks
ground:each(function(x, y)
  local h = X.hash(x, y, 7)
  if h > 0.9 then c:px(x, y, GR[6]) elseif h < 0.07 then c:px(x, y, GR[1]) end
end)
local ms = {}
for i = 0, 5 do
  local a = i * pi / 3 + 0.5
  ms[#ms + 1] = { x = 32 + 19 * cos(a), by = 45 + 7 * sin(a), s = 1.05 + 0.3 * sin(a) }
end
table.sort(ms, function(p, q) return p.by < q.by end)
for idx, M in ipairs(ms) do
  local cx, by, s = floor(M.x + 0.5), floor(M.by + 0.5), M.s
  local capY = floor(by - 5 * s)
  local rx, ry = floor(4.6 * s + 0.5), floor(3.8 * s + 0.5)
  -- shadow on grass
  c:fillMask(c:ellipse(cx + 2, by + 1, rx, 1), GR[1])
  local stem = c:rect(cx - 1, capY, cx + 1, by)
  sh(stem, CRM, 2, 0.15, 0.3)
  local cap = c:ellipse(cx, capY, rx, ry)
  cap:cut(c:rect(cx - rx - 1, capY + floor(ry * 0.45) + 1, cx + rx + 1, capY + ry + 2))
  sh(cap, RED, ry + 1, 0.08, 0.28)
  -- gills strip under cap
  c:fillMask(c:rect(cx - rx + 1, capY + floor(ry * 0.45) + 1, cx + rx - 1, capY + floor(ry * 0.45) + 1), CRM[1])
  -- spots
  c:px(cx - 1, capY - 1, CRM[6]) c:px(cx + 2, capY, CRM[5])
  if rx >= 5 then c:px(cx - 3, capY, CRM[5]) c:px(cx + 1, capY - 2, CRM[6]) end
  c:px(cx - rx + 1, capY - ry + 1 + 1, RED[6])
end
c:sparkle(33, 38)
G.fin(c, "toadstool-ring")
