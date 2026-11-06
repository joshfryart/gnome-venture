-- wyrm-fang (lean D3o_15)
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
c = HP.canvas{ w = 64, h = 64, scale = 1, name = "wyrm-fang" }
local IV = { "#5e4a62", "#8e7488", "#bda3a0", "#e2cdb8", "#f6e8cf", "#fffaee" }
local CORD = { "#2e1a14", "#58341f", "#8a5a30", "#b88448" }
c:groundShadow(30, 56, 14, 2)
local P = { {20,53},{12,30},{28,15},{50,9} }
local m, n, T, S, sm = G.tube(P, function(t) return 0.4 + 7.0 * (1 - t) ^ 1.1 end)
m:cut(c:rect(0, 54, 63, 63))
paint(m, n, IV, function(x, y, k)
  local t, s = T[k], S[k]
  if (t * 24) % 1 < 0.14 and t > 0.25 and t < 0.9 and s > -0.5 and G.X.hash(x, y, 2) > 0.25 then return -1 end
  if s < -0.35 and s > -0.55 and t > 0.3 and t < 0.8 then return 1 end   -- enamel streak
  if t < 0.04 then return -1 end                                         -- rough root break
end)
-- spec glint streak
for _, p in ipairs{ {26,26},{27,24},{28,22},{30,20} } do if m:has(p[1], p[2]) then c:px(p[1], p[2], IV[6]) end end
-- hairline crack
hline({ {17,44},{19,41},{18,38} }, IV[2])
-- cord wrap near root
local cw = HP.mask()
m:each(function(x, y) local t = T[K(x, y)] if t > 0.12 and t < 0.21 then cw:set(x, y) end end)
cw:each(function(x, y) local t = T[K(x, y)] c:put(x, y, floor(t * 90 + S[K(x, y)] * 1.2) % 2 == 0 and CORD[3] or CORD[2], TOK) end)
cw:edge():each(function(x, y) end)
-- bead + tails
local bx, by = G.bez(P, 0.165)
c:px(floor(bx + 5.5), floor(by + 0.5), CORD[4])
hline({ {floor(bx), floor(by + 7)},{floor(bx - 2), floor(by + 11)},{floor(bx - 1), floor(by + 14)} }, CORD[3])
hline({ {floor(bx + 2), floor(by + 7)},{floor(bx + 4), floor(by + 10)} }, CORD[2])
c:px(floor(bx - 1), floor(by + 14), CORD[4])
G.fin(c, "wyrm-fang")
