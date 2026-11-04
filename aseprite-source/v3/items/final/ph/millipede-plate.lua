-- millipede-plate (lean W2_9)
-- A banded armour plate: nine overlapping lacquered copper segments swept along an S curve like a flattened millipede,
-- tiny legs fringing the lower edge, a dark head cap with one amber eye at the upper end. Quirk: one bent leg.
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "millipede-plate" }
local CU = { "#3a1a16", "#5e2a1c", "#8c4222", "#b9622c", "#e08a3c", "#f8c070" }
local CU2 = { "#32161c", "#52243a", "#7c3a3e", "#a85a48", "#d0805a", "#f0b088" }
local HEAD = { "#1e1218", "#3a2230", "#5a3a46", "#7a5262", "#a07884", "#c8a8ae" }
local P = { {13,52}, {10,26}, {52,44}, {50,13} }
c:groundShadow(32, 57, 16, 2)
local N = 9
local segs = {}
for i = 0, N - 1 do
  local t = 0.04 + 0.86 * i / (N - 1)
  local x, y = G.bez(P, t)
  local x2, y2 = G.bez(P, t + 0.01)
  local x1, y1 = G.bez(P, t - 0.01)
  local ux, uy = x2 - x1, y2 - y1
  local l = sqrt(ux * ux + uy * uy) ux, uy = ux / l, uy / l
  segs[#segs + 1] = { x = x, y = y, ux = ux, uy = uy }
end
-- legs first (under plates)
for i, s in ipairs(segs) do
  local px, py = -s.uy, s.ux
  if px + py < 0 then px, py = -px, -py end
  local x0, y0 = s.x + px * 6.5, s.y + py * 6.5
  local bend = (i == 5) and 1 or 0
  G.line(c, { {floor(x0 + 0.5), floor(y0 + 0.5)}, {floor(x0 + px * 2.5 + 0.5 + bend), floor(y0 + py * 2.5 + 0.5)}, {floor(x0 + px * 3.5 + 0.5 + bend * 2), floor(y0 + py * 3.5 + 0.5 + bend)} }, i % 2 == 0 and CU[2] or CU[3])
end
for i = N, 1, -1 do
  local s = segs[i]
  local m = G.rell(s.x, s.y, s.ux, s.uy, 3.9, 7.4)
  local R = 4.2
  local n = X.pillow(m, R)
  local ramp = (i % 2 == 0) and CU or CU2
  local bias = {}
  G.tone(c, m, X.light(n, { amb = 0.08, wrap = 0.22 }), ramp, { 0.2, 0.38, 0.55, 0.72, 0.88 })
  -- dark seam on the trailing edge
  m:edge():each(function(x, y)
    local dx, dy = x - s.x, y - s.y
    if dx * s.ux + dy * s.uy < -1.5 then c:px(x, y, ramp[1]) end
  end)
  -- glint
  local gx, gy = floor(s.x - 2.5 + 0.5), floor(s.y - 2.5 + 0.5)
  if i % 2 == 1 then c:px(gx, gy, ramp[6]) end
end
-- head cap on the last segment
local h = segs[N]
local hm = G.rell(h.x + h.ux * 2.5, h.y + h.uy * 2.5, h.ux, h.uy, 4.6, 5.4)
G.tone(c, hm, X.light(X.pillow(hm, 5), { amb = 0.1, wrap = 0.25 }), HEAD, nil)
local ex, ey = floor(h.x + h.ux * 3 - 1.5 + 0.5), floor(h.y + h.uy * 3 - 0.5)
c:px(ex, ey, "#ffc23a") c:px(ex, ey + 1, "#c67a1a") c:px(ex - 1, ey - 1, HEAD[6])
G.fin(c, "millipede-plate")
