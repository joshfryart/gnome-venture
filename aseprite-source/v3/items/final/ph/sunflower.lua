-- sunflower (lean D2o_16)
local NAME = "sunflower"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local function blob(m, ramp, R, o, cuts, bias)
  local n = X.pillow(m, R)
  local v = X.light(n, o or { amb = 0.1, wrap = 0.25 })
  G.tone(c, m, v, ramp, cuts, bias)
  return v, n
end
local function lines(pts, hex) G.line(c, pts, hex) end
local function hits(m, fn) m:each(fn) end

-- sunflower: ring of long petals around a seeded brown disc on a slim stem with two leaves; quirk: a little bee on a petal
local PET = { "#7a3a10", "#b0620e", "#dc8c10", "#f4b41c", "#ffd23c", "#fff08a" }
local DISC = { "#1e0f0c", "#3a1c12", "#5c3018", "#80481e", "#a86a2c", "#cf9448" }
local GR = { "#1b3b3c", "#255644", "#32764b", "#4b9650", "#70b45a", "#9ccd6c" }
local cx, cy = 31, 24
-- stem and leaves behind
local st, sn = G.tube({ { 31, 34 }, { 30, 42 }, { 33, 48 }, { 32, 55 } }, function(t) return 1.9 end)
blob(st, GR, 2, { amb = 0.15, wrap = 0.3 })
lines({ { 30, 36 }, { 29, 42 }, { 31, 50 } }, GR[5])
local l1 = G.rell(22, 46, 0.85, -0.5, 7, 3.2)
blob(l1, GR, 2.5, { amb = 0.1, wrap = 0.3 }) lines({ { 28, 49 }, { 17, 43 } }, GR[6])
local l2 = G.rell(42, 52, 0.85, 0.45, 7, 3.2)
blob(l2, GR, 2.5, { amb = 0.1, wrap = 0.3 }) lines({ { 35, 50 }, { 48, 55 } }, GR[2]) lines({ { 37, 50 }, { 44, 53 } }, GR[5])
-- back petals then front petals
local function petals(n, r, off, len, wd, amb)
  for i = 0, n - 1 do
    local a = off + i * 2 * pi / n
    local ux, uy = cos(a), sin(a)
    local m = G.rell(cx + ux * r, cy + uy * r, ux, uy, len, wd)
    local lit = 0.5 + 0.5 * (-(ux + uy) / 1.4142)
    blob(m, PET, 2, { amb = amb + 0.2 * lit, wrap = 0.4 })
    lines({ { floor(cx + ux * (r - len * 0.6) + 0.5), floor(cy + uy * (r - len * 0.6) + 0.5) }, { floor(cx + ux * (r + len * 0.7) + 0.5), floor(cy + uy * (r + len * 0.7) + 0.5) } }, PET[lit > 0.5 and 5 or 2])
  end
end
petals(14, 14, 0.2, 7, 2.6, -0.1)
petals(14, 12, 0.2 + pi / 14, 6.5, 2.7, 0.1)
-- disc
local disc = c:ellipse(cx, cy, 9, 9)
local dn = X.pillow(disc, 9)
local dv = X.light(dn, { amb = 0.1, wrap = 0.3 })
G.tone(c, disc, dv, DISC, { 0.2, 0.38, 0.55, 0.72, 0.9 })
disc:each(function(x, y)
  local dx, dy = x - cx, y - cy
  local r = sqrt(dx * dx + dy * dy)
  if r > 7 then c:px(x, y, DISC[4 + (X.hash(x, y, 2) > 0.6 and 1 or 0)]) end
  local a = atan(dy, dx)
  if r > 1 and r < 7 then
    local sp = (a * 2.2 + r * 0.9) % 1
    if sp < 0.2 then c:px(x, y, dv[K(x, y)] > 0.5 and DISC[5] or DISC[3]) end
    if (x + y) % 2 == 0 and r < 2.2 then c:px(x, y, DISC[1]) end
  end
end)
c:px(26, 19, DISC[6]) c:px(27, 18, DISC[5])
-- bee on a petal (quirk)
c:fillMask(c:rect(44, 12, 46, 13), "#f2c82c") c:px(45, 12, "#2a1a14") c:px(46, 13, "#2a1a14") c:px(44, 11, "#f4f8ff") c:px(45, 11, "#d8e4f4")

G.fin(c, NAME)
