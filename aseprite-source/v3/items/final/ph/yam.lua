-- yam (lean D3o_15)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt, atan2 = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan2 or function(y,x) return math.atan(y,x) end
local CUTS = { 0.22, 0.4, 0.56, 0.72, 0.86 }
local TOK = { r = { name = "p" } }
local c
local function paint(m, n, ramp, tex, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.1, wrap = o.wrap or 0.25 })
  m:each(function(x, y)
    local k = K(x, y)
    local val = v[k] or 0.5
    local i = 1
    for _, ct in ipairs(CUTS) do if val > ct then i = i + 1 end end
    if tex then i = i + (tex(x, y, k, i) or 0) end
    c:put(x, y, ramp[max(1, min(#ramp, i))], TOK)
  end)
  return v
end
local function hline(pts, hex) G.line(c, pts, hex) end
c = HP.canvas{ w = 64, h = 64, scale = 1, name = "yam" }
local SKIN = { "#2a1a1c", "#46281f", "#6a3f2a", "#8c5a38", "#b07a4c", "#d09c68" }
local FLESH = { "#6a4a78", "#9a78a4", "#cdb4c4", "#efe0d8", "#fff6ec", "#ffffff" }
local LEAF = { "#1b3b3c", "#255644", "#32764b", "#4b9650", "#70b45a", "#9ccd6c" }
c:groundShadow(32, 56, 20, 2)
local P = { {11,46},{20,53},{36,36},{51,21} }
local m, n, T, S, sm = G.tube(P, function(t)
  local w = 5.2 + 1.6 * sin(t * 9 + 1) + 0.9 * sin(t * 23)
  if t < 0.3 then w = w * (0.3 + 0.7 * (t / 0.3) ^ 1.2) end
  return w
end)
-- diagonal cut face at the thick end
local ex, ey = G.bez(P, 0.94)
local tx, ty = G.bez(P, 0.96)
local ux, uy = tx - ex, ty - ey local ul = sqrt(ux * ux + uy * uy) ux, uy = ux / ul, uy / ul
local face = HP.mask()
m:each(function(x, y) if (x - ex) * ux + (y - ey) * uy > 0 then face:set(x, y) end end)
local skin = m:copy():cut(face)
paint(skin, n, SKIN, function(x, y, k)
  local t, s = T[k], S[k]
  if (t * 55 + s * 1.5) % 1 < 0.1 and G.X.hash(x, y, 4) > 0.4 then return -1 end
  if G.X.hash(x, y, 12) > 0.93 then return 1 end
  if G.X.hash(x, y, 13) > 0.95 then return -1 end
end)
face:each(function(x, y)
  local k = K(x, y) local i = 4 - floor(abs(S[k]) * 2.2)
  if G.X.hash(x, y, 6) > 0.86 then i = 1 end
  if (x - 3 * ux) and S[k] > 0.7 then i = 2 end
  c:put(x, y, FLESH[max(1, min(5, i))], TOK)
end)
-- rootlet hairs
for idx, tt in ipairs{ 0.08, 0.2, 0.33, 0.47, 0.6, 0.72, 0.5 } do
  local s = sm[floor(tt * 200) + 1]
  local sg = (idx % 2 == 0) and 1 or -1
  if tt > 0.4 then sg = 1 end
  local bx, by = s.x + s.px * sg * (s.w - 0.5), s.y + s.py * sg * (s.w - 0.5)
  local ex2, ey2 = bx + s.px * sg * 4 + (idx % 3 - 1) * 2, by + s.py * sg * 4 + 1
  hline({ {floor(bx + 0.5), floor(by + 0.5)}, {floor((bx + ex2) / 2 + 0.5), floor((by + ey2) / 2 + 0.5)}, {floor(ex2 + 0.5), floor(ey2 + 0.5)} }, SKIN[2])
end
-- quirk: a tiny sprout bud
local s = sm[floor(0.68 * 200) + 1]
local bx, by = s.x - s.px * (s.w - 0.5), s.y - s.py * (s.w - 0.5)
local sx, sy = floor(bx + 0.5), floor(by + 0.5)
hline({ {sx, sy}, {sx - 1, sy - 3} }, LEAF[3])
c:fillMask(G.rell(sx - 3, sy - 4, 1, 0, 2.2, 1.2), LEAF[4])
c:fillMask(G.rell(sx + 1, sy - 6, 0, -1, 2.2, 1.2), LEAF[5])
c:px(sx - 4, sy - 4, LEAF[6]) c:px(sx - 1, sy - 4, LEAF[2])
c:px(23, 42, SKIN[6]) c:px(24, 41, SKIN[6])
G.fin(c, "yam")
