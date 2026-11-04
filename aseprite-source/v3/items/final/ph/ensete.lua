-- ensete (lean W2_1)
-- Ensete (false banana): swollen pale pseudostem with banded sheaths and a maroon stripe, two paddle leaves with red midribs, one frayed, a small sucker pup.
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "ensete" }
local LEAF = { "#1b3b3c", "#255644", "#32764b", "#4b9650", "#70b45a", "#a4d070" }
local STEM = { "#4a5a3c", "#6e8a52", "#97b573", "#bcd496", "#dceab8", "#f4f8d8" }
local ltok = { r = { name = "leaf" } }
local function paddle(ax, ay, bx, by, wmax, slits)
  local len = sqrt((bx - ax)^2 + (by - ay)^2)
  local m, n, T, S = X.cyl(ax, ay, bx, by, function(t)
    if t > 0.985 then return -1 end
    if t < 0.15 then return 0.7 end
    return max(0.7, wmax * sin(pi * min(1, (t - 0.1) / 0.9 * 0.95 + 0.05)) ^ 0.55)
  end)
  local cut = HP.mask()
  for _, s in ipairs(slits) do
    local t, side = s[1], s[2]
    local x0, y0 = ax + (bx - ax) * t, ay + (by - ay) * t
    local ux, uy = (bx - ax) / len, (by - ay) / len
    local px, py = -uy * side, ux * side
    for d = 2, 7 do cut:set(floor(x0 + px * d + ux * d * 0.5 + 0.5), floor(y0 + py * d + uy * d * 0.5 + 0.5)) end
  end
  m:cut(cut)
  local v = X.light(n, { amb = 0.12, wrap = 0.25 })
  G.tone(c, m, v, LEAF, { 0.2, 0.38, 0.55, 0.7, 0.86 }, nil, ltok)
  m:each(function(x, y) local k = K(x, y)
    local s, t = S[k], T[k]
    if abs(s) < 0.17 and t > 0.08 then c:put(x, y, s <= 0 and "#d0586a" or "#8a2a40", ltok)
    elseif t > 0.2 then
      local d = ((t * len) - abs(s) * 3.0) % 3.2
      if d < 0.8 and abs(s) > 0.3 then c:put(x, y, s < 0 and LEAF[5] or LEAF[2], ltok) end
    end
  end)
  return m
end
paddle(33, 25, 54, 9, 5.4, {})
paddle(31, 26, 10, 14, 5.0, { {0.55, 1}, {0.75, -1} })
-- pseudostem
local sm, sn, ST = G.tube({ {31,53},{30,44},{33,33},{32,24} }, function(t) return 7.2 - 4.4 * t^0.8 end)
G.tone(c, sm, X.light(sn, { amb = 0.1, wrap = 0.3 }), STEM, { 0.2, 0.36, 0.52, 0.68, 0.84 })
sm:each(function(x, y)
  if (y % 5 == 0) and X.hash(x, y, 7) > 0.2 then c:px(x, y, STEM[2]) end
  if x >= 32 and x <= 33 + floor((53 - y) / 12) and y > 30 and y < 52 and (y % 5 ~= 0) then c:px(x, y, "#7a3446") end
end)
c:px(27, 36, STEM[6]) c:px(27, 37, STEM[5]) c:px(26, 44, STEM[6])
-- sucker pup beside the base (quirk)
local pm, pn = G.tube({ {38,53},{39,50},{40,47},{39,44} }, function(t) return 2.2 - 1.6 * t end)
G.tone(c, pm, X.light(pn, { amb = 0.12, wrap = 0.3 }), LEAF, { 0.3, 0.55, 0.8 }, nil, ltok)
c:px(39, 44, LEAF[6]) c:px(40, 45, LEAF[5])
c:fillMask(c:rect(24, 54, 38, 54), "#3a3a2c")
G.fin(c, "ensete")
