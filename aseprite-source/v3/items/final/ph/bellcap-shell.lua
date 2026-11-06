-- bellcap-shell (final, Opus single pass). The cast-off shell of a bellcap beetle: a tall, slim bell of glossy
-- chitin, seen from a touch below so the dark hollow shows under the flared lip.
-- Material: per-pixel surface-of-revolution light, 6-tone iridescent ramp (violet shade -> teal -> mint light),
-- a pronotum groove across the crown, the elytra seam down the front, punctate dimple rows (dark pit + lit lip),
-- a long specular streak on the lit flank, a bevelled lip ridge, cool reflected light lower-right, AO in the hollow.
-- quirk: someone has already knotted a red chime thread through the hole in the crown; one end is fraying.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR20_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sqrt, max, min, abs = math.floor, math.sqrt, math.max, math.min, math.abs
local c = A.new("bellcap-shell")
local SH = { "#1c1838", "#2a2c68", "#2c5490", "#3a82a8", "#5cb4b4", "#a8e6c8" }
local HOL = { "#160f26", "#231a3e", "#33285a" }
local THR = { "#6e2038", "#b52e3f", "#e8493b", "#ff8a5c" }
local CX, YT, YL = 32, 11, 50
local H = YL - YT
local function R(y)
  local t = (y - YT) / H
  if t < 0 then return 0 end
  local r = 6 + 4.5 * t + 3.5 * t ^ 4 + 2.2 * max(0, (t - 0.84) / 0.16) ^ 2
  return r * sqrt(min(1, (t + 0.02) / 0.16))
end
local RL = R(YL)
local body, n, TT, SS = HP.mask(), {}, {}, {}
for y = YT, YL + 3 do
  local yy = min(y, YL)
  local r = R(yy)
  local dr = (R(min(yy + 0.5, YL)) - R(yy - 0.5))
  if y == YL and dr == 0 then dr = 0.6 end
  for x = floor(CX - r - 1), floor(CX + r + 1) do
    local dx = x + 0.5 - CX
    local inside = abs(dx) <= r
    if y > YL then inside = (dx / RL) ^ 2 + ((y - YL) / 3.2) ^ 2 <= 1 end
    if inside then
      body:set(x, y)
      local s = max(-0.97, min(0.97, dx / (r + 0.5)))
      local k = K(x, y)
      n[k] = { A.norm(s, -dr * 1.2, sqrt(1 - s * s)) }
      TT[k], SS[k] = (yy - YT) / H, s
    end
  end
end
local tok = { r = { name = "shell" } }
local idx = A.tone(c, body, n, SH, { amb = 0.05, wrap = 0.2, tok = tok })
local function shift(x, y, d) local k = K(x, y) local i = idx[k] if i then c:put(x, y, SH[max(1, min(6, i + d))], tok) end end
-- pronotum groove (curves with the dome) + lit lip above it
local YG = YT + 0.24 * H
body:each(function(x, y) local k = K(x, y) local s = SS[k]
  local gy = floor(YG + 2.2 * (1 - s * s) + 0.5)
  if y == gy then shift(x, y, -2) elseif y == gy - 1 and s < 0.6 then shift(x, y, 1) end end)
-- elytra seam
for y = floor(YG + 3), YL - 2 do shift(CX, y, -2) shift(CX + 1, y, -1) shift(CX - 1, y, 1) end
-- punctate rows
for _, sr in ipairs{ -0.62, -0.32, 0.32, 0.62 } do
  for y = floor(YG + 5), YL - 6, 3 do
    local r = R(y)
    local x = floor(CX - 0.5 + sr * (r + 0.5) + 0.5)
    shift(x, y, -2) shift(x - 1, y - 1, 1)
  end
end
-- lip ridge: bright bevel where the flare starts
local YR = floor(YT + 0.86 * H)
body:each(function(x, y) if y == YR then shift(x, y, 2) elseif y == YR + 1 then shift(x, y, -1) end end)
-- hollow under the lip
local hol = c:ellipse(CX - 0.5, YL + 0.5, RL - 2.2, 2.2)
hol:clip(body)
hol:each(function(x, y) local dy = y - (YL + 0.5)
  c:put(x, y, dy < -0.8 and HOL[1] or (dy < 0.6 and HOL[2] or HOL[3]), tok) end)
-- cool bounce on the lower-right rim
local rim = X.rim(n)
body:edge():each(function(x, y) local k = K(x, y)
  if rim[k] > 0.62 and SS[k] > 0.7 and TT[k] > 0.3 and not hol:has(x, y) then c:put(x, y, "#6a5ab0", tok) end end)
-- specular streak down the lit flank + glint
for y = floor(YT + 0.34 * H), floor(YT + 0.7 * H) do
  local r = R(y)
  local x = floor(CX - 0.5 - 0.55 * (r + 0.5) + 0.5)
  c:put(x, y, SH[6], tok)
end
do local y = floor(YT + 0.4 * H) local x = floor(CX - 0.5 - 0.55 * (R(y) + 0.5) + 0.5)
  c:put(x, y, A.CREAM, tok) c:put(x, y + 1, A.CREAM, tok) end
c:put(CX - 4, YT + 3, SH[6], tok) c:put(CX - 3, YT + 3, SH[6], tok)
-- crown hole
c:put(CX - 1, YT + 1, HOL[1], tok) c:put(CX, YT + 1, HOL[2], tok)
-- quirk: red thread loop through the hole, twisted, with a fraying tail
local loop = { {30, 10}, {29, 9}, {29, 8}, {29, 7}, {30, 6}, {31, 5}, {32, 5}, {33, 6}, {34, 7}, {34, 8}, {34, 9}, {33, 10} }
for i, p in ipairs(loop) do c:put(p[1], p[2], i % 2 == 0 and THR[2] or THR[3]) end
c:put(30, 6, THR[4]) c:put(32, 5, THR[3])
-- knot + tail
c:put(34, 10, THR[1]) c:put(35, 10, THR[2]) c:put(35, 11, THR[3])
local tail = { {36, 11}, {37, 12}, {38, 13}, {38, 14}, {39, 15} }
for i, p in ipairs(tail) do c:put(p[1], p[2], i % 2 == 0 and THR[2] or THR[3]) end
c:put(40, 16, THR[4]) c:put(39, 16, THR[2])          -- frayed strands
A.fin(c, "bellcap-shell")
