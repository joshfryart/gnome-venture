-- turnip (pass A, Opus). Slim, upright: a small purple-shouldered bulb on a long tap root, three lyrate leaves on
-- thin stalks rising out of a sunken crown.
-- Material: per-pixel bulb light (6-tone purple + 6-tone cool cream), purple streaking down into the cream,
-- waxy bloom + one specular on the shoulder, cool reflected light lower-right, faint growth rings,
-- AO in the crown, leaf midrib + veins with lobes along the stalk.
-- quirk: the tap root ends in a little pigtail curl.
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "turnip" }
local floor, abs, sin, pi, max, min = math.floor, math.abs, math.sin, math.pi, math.max, math.min

local PURP  = { "#3a2153", "#5a2a70", "#7d3a8c", "#a052a6", "#c47cc0", "#e2aad8" }
local CREAM = { "#7f7099", "#a698b8", "#cbbfd0", "#e9e0e0", "#f8f1e6", "#fffaf0" }
local LEAF  = { "#1d3f3a", "#285a43", "#357a4a", "#4f9a4f", "#74b85a", "#9fd070" }
local STALK = { "#3d6a4a", "#5b8f5a", "#86b56c", "#b4d58e" }
local SPEC, BOUNCE = "#fff6f4", "#8f9fd0"

-- leaves first (behind the bulb top). lyrate: two small side lobes on the stalk, big round end lobe
local function leaf(ax, ay, bx, by, wmax)
  local m, n, T, S = X.cyl(ax, ay, bx, by, function(t)
    if t > 0.985 then return -1 end
    local w = 0.7
    local l1 = 2.4 * max(0, 1 - abs(t - 0.36) / 0.07)
    local l2 = 2.8 * max(0, 1 - abs(t - 0.5) / 0.07)
    local blade = 0
    if t > 0.55 then blade = wmax * sin(pi * min(1, (t - 0.55) / 0.45 * 0.92 + 0.08)) ^ 0.6 end
    return max(w, l1, l2, blade)
  end)
  local v = X.light(n, { amb = 0.12, wrap = 0.25 })
  local tok = { r = { name = "leaf" } }
  G.tone(c, m, v, LEAF, { 0.2, 0.38, 0.55, 0.7, 0.86 }, nil, tok)
  local len = math.sqrt((bx - ax)^2 + (by - ay)^2)
  m:each(function(x, y) local k = K(x, y)
    local s, t = S[k], T[k]
    if t < 0.32 then c:put(x, y, s <= 0 and STALK[3] or STALK[1], tok)
    elseif abs(s) < 0.22 and t < 0.92 then c:put(x, y, s <= 0 and LEAF[6] or LEAF[3], tok) end
    if t > 0.6 then
      for _, vt in ipairs{ 0.66, 0.76, 0.85 } do
        local d = (t - vt) * len - abs(s) * 2.2
        if d > -0.5 and d < 0.5 and abs(s) > 0.3 and abs(s) < 0.8 then c:put(x, y, s < 0 and LEAF[5] or LEAF[2], tok) end
      end
    end
  end)
  return m
end
leaf(30, 29, 11, 8, 4.4)
leaf(34, 29, 54, 10, 4.2)
leaf(32, 29, 33, 4, 3.6)

-- tap root + pigtail (quirk)
local rootR = { "#6c5d84", "#988aa8", "#c2b6c4", "#e2d8d6" }
local rm, rn = G.tube({ {32, 46}, {32, 50}, {33, 53}, {34, 56} }, function(t) return 2.2 * (1 - t) + 0.5 end)
G.tone(c, rm, X.light(rn, { amb = 0.15, wrap = 0.3 }), rootR, { 0.3, 0.55, 0.8 })
local pig = { {34, 56}, {34, 58}, {35, 59}, {37, 59}, {38, 58}, {38, 57}, {37, 56}, {36, 57} }
G.line(c, pig, rootR[2])
c:px(34, 57, rootR[3]) c:px(35, 59, rootR[3])

-- bulb
local bulb = c:ellipse(32, 38, 10, 9):add(c:poly{ {25, 42}, {39, 42}, {34, 48}, {30, 48} })
bulb:cut(c:rect(20, 28, 44, 28))
local n, d = X.pillow(bulb, 8)
local v = X.light(n, { amb = 0.06, wrap = 0.2 })
local bias = {}
-- AO under the crown, where the stalks enter
X.ao(bias, bulb, c:rect(29, 26, 35, 28), 2, -1)
local purple, cream = HP.mask(), HP.mask()
bulb:each(function(x, y)
  local edge = 38 + floor(1.5 * sin(x * 0.7)) + floor((x - 32) * 0.12)
  local streak = floor(X.hash(x, 0, 9) * 5) - 1
  if (x % 2 == 0) then streak = max(0, streak - 2) end
  if y < edge or (y < edge + streak) then purple:set(x, y) else cream:set(x, y) end
end)
G.tone(c, purple, v, PURP, { 0.24, 0.42, 0.58, 0.74, 0.88 }, bias)
local cb = {}
cream:each(function(x, y)       -- faint growth rings
  local k = K(x, y)
  if (y - 0.05 * (x - 32)^2) % 3.4 < 0.8 and X.hash(x, y, 4) > 0.4 then cb[k] = -1 end
end)
G.tone(c, cream, v, CREAM, { 0.18, 0.34, 0.5, 0.66, 0.82 }, cb)
-- cool reflected light lower-right
local rim = X.rim(n)
bulb:edge():each(function(x, y) local k = K(x, y) if rim[k] > 0.72 and y > 37 then c:px(x, y, BOUNCE) end end)
-- waxy bloom on the purple shoulder (lighter pale specks), specular
purple:each(function(x, y) local k = K(x, y) if v[k] > 0.75 and X.hash(x, y, 11) > 0.8 then c:px(x, y, PURP[6]) end end)
c:px(26, 31, SPEC) c:px(27, 31, SPEC) c:px(26, 32, PURP[6])
-- crown: sunken dark cup + stalk bases
c:fillMask(c:rect(30, 28, 34, 28), PURP[1])
c:px(31, 29, PURP[2]) c:px(33, 29, PURP[2]) c:px(32, 29, PURP[1])
G.line(c, { {30, 27}, {29, 25} }, STALK[2]) G.line(c, { {34, 27}, {35, 25} }, STALK[1]) G.line(c, { {32, 27}, {32, 24} }, STALK[3])
G.fin(c, "turnip.pA")
