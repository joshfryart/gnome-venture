-- Whirl Pincer (pl-hcr-4), perch sprite 36x36. Opus second pass (c14/opus2), hand-built at this size.
-- Four crab arms curling the same way round a sandy carapace hub, each with an open pincer (dark tips);
-- 2x3 pill eyes on the hub.
-- quirk: swish arcs trailing the spin.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("pl-hcr-4-perch", 36)
local cos, sin, pi, floor = math.cos, math.sin, math.pi, math.floor

local CRAB = { "#5c1626", "#962a30", "#c8443a", "#e8683e", "#f69460", "#fcc494" }
local TIP  = { "#2e1a24", "#4a2830", "#6a3a3a", "#8c5048" }
local BELY = { "#5e3424", "#94562c", "#c47e38", "#e2a650", "#f2c878", "#fae4a8" }
local SWSH = "#e4ecf0"
local HX, HY = 18, 17
local function D(a, r) return HX + r * cos(a * pi / 180), HY + r * sin(a * pi / 180) end

c:groundShadow(18, 32, 8, 1.5)
for i = 0, 3 do
  local a = -60 + 90 * i
  local x0, y0 = D(a, 3) local x1, y1 = D(a, 6.5) local x2, y2 = D(a + 22, 8.5) local x3, y3 = D(a + 40, 9.5)
  local m, n = O.tube({ { x0, y0 }, { x1, y1 }, { x2, y2 }, { x3, y3 } }, function(t) return 1.9 - .5 * t end)
  O.shadeN(c, m, n, CRAB, { amb = .36, wrap = .45, rim = true })
  local ex, ey = D(a + 48, 10.3)
  local ta = (a + 48 + 90) * pi / 180
  O.shade(c, c:ellipse(ex, ey, 2.6, 2.6), CRAB, { sphere = { ex - 1, ey - 1, 4 }, amb = .4, wrap = .5 })
  for _, s in ipairs({ { -50, 1.6, 3.4 }, { 50, 1.2, 2.8 } }) do
    local fa = ta + s[1] * pi / 180
    local bx, by = ex + 1.4 * cos(fa), ey + 1.4 * sin(fa)
    local qx, qy = ex + s[3] * cos(fa) + 2 * cos(ta), ey + s[3] * sin(fa) + 2 * sin(ta)
    local fm, fn, fT = O.tube({ { bx, by }, { bx, by }, { qx, qy }, { qx, qy } }, function(t) return s[2] * (1 - t) ^ .8 + .4 end)
    local _, fTk = O.shadeN(c, fm, fn, CRAB, { amb = .4, wrap = .5 })
    fm:each(function(x, y) local t = fT[K(x, y)] if t and t > .6 and c.own[y * 36 + x] == fTk then c.pix[y * 36 + x] = TIP[3] end end)
  end
  -- open the pincer: clear the gap between the two fingers
  for d = 2.2, 5, .4 do
    local gx, gy = floor(ex + d * cos(ta) + .5), floor(ey + d * sin(ta) + .5)
    c.pix[gy * 36 + gx] = nil c.own[gy * 36 + gx] = nil
  end
end
local hub = c:ellipse(HX, HY, 6, 5.5)
O.shade(c, hub, BELY, { sphere = { HX - 2, HY - 3, 9 }, amb = .3, wrap = .45, rim = true, sep = BELY[1] })
c:eyeSmall(15, 15)
c:eyeSmall(20, 15)
O.dot(c, 13, 19, P.petal.base) O.dot(c, 23, 19, P.petal.base)
O.dots(c, { { 17, 20 }, { 18, 20 }, { 19, 20 } }, P.ink) O.dots(c, { { 16, 19 }, { 20, 19 } }, P.ink)

O.done(c, "pl-hcr-4-perch", function(c)
  for i = 0, 3 do
    local a = -60 + 90 * i
    for k = 0, 4 do
      local x, y = D(a + 6 - k * 7, 14)
      x, y = floor(x + .5), floor(y + .5)
      if not c:get(x, y) and k ~= 2 then O.dot(c, x, y, SWSH) end
    end
  end
end)
