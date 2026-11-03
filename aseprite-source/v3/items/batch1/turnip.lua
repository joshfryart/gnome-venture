-- turnip (pass B, final, Opus). Slim, upright: a small top-shaped bulb (purple shoulders streaking down into
-- cool cream) narrowing smoothly into a long tap root; three lyrate leaves on thin stalks out of a sunken crown.
-- Material: per-pixel bulb light (6-tone purple + 6-tone cream), tapered purple streaks, waxy bloom specks and one
-- specular on the shoulder, cool reflected light lower-right, faint growth rings, AO under the crown where the
-- stalks meet, two fine root hairs. Leaves: crinkled edge, midrib + angled veins, two little side lobes per stalk.
-- History: turnip.pA (pass A). Draft by Sonnet replaced.
-- quirk: the tap root ends in a little pigtail curl.
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "turnip" }
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt

local PURP  = { "#36204f", "#56286c", "#7a3689", "#9d4ea3", "#c178bd", "#e0a8d6" }
local CREAM = { "#76689a", "#9f92b8", "#c7bcd2", "#e7dee2", "#f7f0e6", "#fffaf0" }
local LEAF  = { "#1b3b3c", "#255644", "#32764b", "#4b9650", "#70b45a", "#9ccd6c" }
local STALK = { "#3b6449", "#5b8d5a", "#88b46e", "#b9d793" }
local SPEC, BOUNCE = "#fff6f2", "#8e9cd2"
local ltok = { r = { name = "leaf" } }

-- leaf: stalk + 2 side lobes + crinkled terminal blade
local function leaf(ax, ay, bx, by, wmax, lobes)
  local len = sqrt((bx - ax)^2 + (by - ay)^2)
  local m, n, T, S = X.cyl(ax, ay, bx, by, function(t)
    if t > 0.985 then return -1 end
    local blade = 0
    if t > 0.5 then
      blade = wmax * sin(pi * min(1, (t - 0.5) / 0.5 * 0.9 + 0.1)) ^ 0.6
      blade = blade + 0.45 * sin(t * len * 1.4)          -- crinkled edge
    end
    return max(0.6, blade)
  end)
  -- side lobes: small ovals hanging off the stalk
  local lob = HP.mask()
  for _, L in ipairs(lobes) do
    local t, side, r = L[1], L[2], L[3]
    local ux, uy = (bx - ax) / len, (by - ay) / len
    local px, py = -uy * side, ux * side
    local cx, cy = ax + (bx - ax) * t + px * (r + 0.2), ay + (by - ay) * t + py * (r + 0.2)
    lob:add(G.rell(cx, cy, ux, uy, r + 0.6, r))
  end
  lob:cut(m)
  local v = X.light(n, { amb = 0.12, wrap = 0.25 })
  G.tone(c, m, v, LEAF, { 0.2, 0.38, 0.55, 0.7, 0.86 }, nil, ltok)
  local ln = X.pillow(lob, 1.5)
  G.tone(c, lob, X.light(ln, { amb = 0.15, wrap = 0.3 }), LEAF, { 0.2, 0.38, 0.55, 0.7, 0.86 }, nil, ltok)
  m:each(function(x, y) local k = K(x, y)
    local s, t = S[k], T[k]
    if t < 0.5 then c:put(x, y, s <= 0 and STALK[3] or STALK[2], ltok)
    elseif abs(s) < 0.2 and t < 0.93 then c:put(x, y, s <= 0 and LEAF[6] or LEAF[3], ltok) end
    if t > 0.56 then
      for _, vt in ipairs{ 0.6, 0.7, 0.8, 0.88 } do
        local d = (t - vt) * len - abs(s) * 2.0
        if d > -0.5 and d < 0.5 and abs(s) > 0.32 and abs(s) < 0.78 then c:put(x, y, s < 0 and LEAF[5] or LEAF[2], ltok) end
      end
    end
  end)
  return m:add(lob)
end
leaf(31, 28, 10, 9, 4.3, { {0.3, -1, 1.3}, {0.4, 1, 1.5} })
leaf(33, 28, 54, 11, 4.0, { {0.3, 1, 1.3}, {0.42, -1, 1.4} })
leaf(32, 28, 34, 3, 3.4, {})

-- bulb: top shape by rows; half-width h(y), centre x 32
local Y0, Y1 = 27, 51
local function hw(y)
  local t = (y - Y0) / (Y1 - Y0)
  if t < 0.42 then return 9.6 * sin(min(1, (t + 0.06) / 0.48) * pi / 2) ^ 0.5 end
  return 9.6 * ((1 - t) / 0.58) ^ 0.95 + 0.3
end
local bulb = HP.mask()
for y = Y0, Y1 do local h = hw(y) for x = floor(32 - h + 0.5), floor(32 + h - 0.5 + 1) - 1 do bulb:set(x, y) end end
-- tap root + pigtail (quirk)
local rootR = { "#6a5b86", "#9688aa", "#c0b4c6", "#e0d6d8" }
local rm, rn = G.tube({ {32, 50}, {32, 52}, {33, 54}, {34, 56} }, function(t) return 1.2 * (1 - t) + 0.5 end)
rm:cut(bulb)
G.tone(c, rm, X.light(rn, { amb = 0.15, wrap = 0.3 }), rootR, { 0.3, 0.55, 0.8 })
G.line(c, { {34, 56}, {34, 58}, {35, 59}, {37, 59}, {38, 58}, {38, 57}, {37, 56} }, rootR[2])
c:px(34, 57, rootR[3]) c:px(36, 59, rootR[1]) c:px(37, 59, rootR[1])
-- fine root hairs off the lower bulb


local n = X.pillow(bulb, 7)
local v = X.light(n, { amb = 0.06, wrap = 0.2 })
local bias = {}
X.ao(bias, bulb, c:rect(28, 25, 36, Y0 - 1), 2, -1)
-- purple: smooth arc + tapered streaks
local purple, cream = HP.mask(), HP.mask()
local streaks = { {26, 3}, {31, 4}, {36, 3} }
bulb:each(function(x, y)
  local edge = 38 + floor((x - 32) * 0.12 + 0.5)
  local p = y < edge
  for _, s in ipairs(streaks) do
    local depth = y - edge
    if depth >= 0 and depth < s[2] then
      local wdt = (depth < 1) and 1 or 0
      if x >= s[1] and x <= s[1] + wdt then p = true end
    end
  end
  if p then purple:set(x, y) else cream:set(x, y) end
end)
G.tone(c, purple, v, PURP, { 0.22, 0.4, 0.56, 0.72, 0.87 }, bias)
local cb = {}
cream:each(function(x, y) local k = K(x, y)
  local ry = y - 0.06 * (x - 32)^2
  if ry % 3.6 < 0.9 and y < 47 and abs(x - 32) < hw(y) - 1.5 and X.hash(x, y, 4) > 0.3 then cb[k] = -1 end
end)
G.tone(c, cream, v, CREAM, { 0.17, 0.33, 0.49, 0.65, 0.8 }, cb)
-- cool reflected light lower-right
local rim = X.rim(n)
bulb:edge():each(function(x, y) if rim[K(x, y)] > 0.7 and y > 36 and y < 49 then c:px(x, y, BOUNCE) end end)
-- waxy bloom: pale specks on the lit purple, kept off the edge
local inner = purple:copy():shrink(1)
inner:each(function(x, y) if v[K(x, y)] > 0.7 and X.hash(x, y, 11) > 0.84 then c:px(x, y, PURP[6]) end end)
-- specular: 2x1 cream + 1 px glint
c:px(26, 31, SPEC) c:px(27, 31, SPEC) c:px(26, 32, PURP[6]) c:px(28, 30, PURP[6])
-- crown: sunken cup, stalk bases in AO
c:fillMask(c:rect(29, Y0, 35, Y0), PURP[1])
c:px(30, Y0 + 1, PURP[2]) c:px(34, Y0 + 1, PURP[2]) c:px(32, Y0 + 1, PURP[1]) c:px(31, Y0 + 1, PURP[2]) c:px(33, Y0 + 1, PURP[2])
for _, p in ipairs{ {30, 26, 3}, {31, 26, 2}, {32, 26, 3}, {33, 26, 2}, {34, 26, 1} } do c:px(p[1], p[2], STALK[p[3]]) end
G.fin(c, "turnip")
