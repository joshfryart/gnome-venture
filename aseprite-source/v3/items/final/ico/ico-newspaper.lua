-- ico-newspaper (final pass, Opus single pass). Bold icon: a folded daily paper. Front page with a bold NEWS
-- masthead, rule, thick headline bar, a colour photo (sky, sun, hill) and text columns; a horizontal fold crease
-- (upper half tilted to the light, lower half a step darker, a pale lip under the crease); inner pages peeking out
-- right and bottom as a stack of page edges with a contact shadow; the top-right corner dog-eared with a cast shadow.
-- quirk: somebody set their coffee mug on it, leaving a brown ring and a drip.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA7_2.lua")
local HP, X, K = A.HP, A.X, A.K
local max, min, sqrt, abs, floor = math.max, math.min, math.sqrt, math.abs, math.floor
local c = A.new("ico-newspaper")
local PAP = { "#5e4f5a", "#8c7d84", "#b8aca6", "#d8cdbc", "#ece3cf", "#faf4e4" }
local PR = { "#2b2638", "#433d54", "#625c76" }
local ptok, rtok = { r = { name = "paper" } }, { r = { name = "print" } }
local CREASE = 32

-- inner pages behind (offset right/down), shown as stacked page edges
local front = c:rect(11, 9, 48, 54)
local ear = c:poly{ { 41, 9 }, { 48, 9 }, { 48, 16 } }
front:cut(ear)
local back = c:rect(13, 11, 51, 57):cut(c:rect(11, 9, 48, 54))
back:each(function(x, y)
  local i
  if x > 48 then i = ((x % 2 == 0) and 3 or 4) else i = ((y % 2 == 0) and 3 or 4) end
  if (x == 49 or y == 55) then i = 2 end            -- contact shadow next to the front page
  if y < 14 or x < 16 then i = 2 end
  c:put(x, y, PAP[i], ptok)
end)
-- front page: fold halves + slight edge curl
local fn = {}
front:each(function(x, y)
  local ny = (y < CREASE) and -0.32 or 0.14
  local nx = 0
  if x <= 12 then nx = -0.35 elseif x >= 47 then nx = 0.4 end
  if y <= 10 then ny = ny - 0.3 elseif y >= 53 then ny = ny + 0.35 end
  fn[K(x, y)] = { A.norm(nx, ny, 1) }
end)
local fb = {}
local fidx = A.shade(c, front, fn, PAP, { amb = 0.1, wrap = 0.3, tok = ptok, bias = fb, cuts = { 0.3, 0.5, 0.66, 0.8, 0.9 } })
-- crease: dark line, pale lip below
for x = 11, 48 do c:put(x, CREASE, PAP[2], ptok) c:put(x, CREASE + 1, PAP[6], ptok) c:put(x, CREASE - 1, PAP[4], ptok) end
-- print colour for a pixel (lower half one step darker)
local function pr(y, t) t = t or 3 return PR[max(1, (y > CREASE) and t - 1 or t)] end
local function px(x, y, h) if front:has(x, y) and y ~= CREASE and y ~= CREASE + 1 then c:put(x, y, h, rtok) end end
-- masthead band with NEWS in cream
for y = 12, 18 do for x = 14, 38 do px(x, y, PR[1]) end end
for x = 14, 38 do px(x, 12, PR[2]) end
local G = {
  N = { "1..1", "11.1", "1.11", "1..1", "1..1" },
  E = { "111", "1..", "11.", "1..", "111" },
  W = { "1...1", "1...1", "1.1.1", "11.11", "1...1" },
  S = { "111", "1..", "111", "..1", "111" },
}
local gx = 17
for _, ch in ipairs{ "N", "E", "W", "S" } do
  for r, row in ipairs(G[ch]) do for i = 1, #row do
    if row:sub(i, i) == "1" then px(gx + i - 1, 12 + r, A.CREAM) end end end
  gx = gx + #G[ch][1] + 1
end
-- date box beside the masthead
for y = 14, 17 do for x = 40, 45 do px(x, y, PAP[3]) end end
px(41, 15, pr(15, 3)) px(42, 15, pr(15, 3)) px(43, 15, pr(15, 3)) px(41, 17, pr(17, 3)) px(42, 17, pr(17, 3))
-- double rule
for x = 14, 45 do px(x, 20, pr(20, 2)) if x % 2 == 0 then px(x, 21, pr(21, 3)) end end
-- headline bar (bold) + subhead
for y = 23, 25 do for x = 14, 41 do px(x, y, pr(y, 1)) end end
for x = 14, 33 do px(x, 28, pr(28, 3)) end
for x = 36, 45 do px(x, 28, pr(28, 3)) end
-- photo: sky, sun, hill, framed
local ph = c:rect(14, 35, 28, 46)
ph:each(function(x, y)
  local col = (y < 41) and "#8bc4ea" or "#7cc35a"
  if y < 38 then col = "#b9e2f5" end
  local hill = 41 - floor(3 * math.sin((x - 14) / 14 * 3.14))
  if y >= hill then col = (y <= hill) and "#c4e07a" or "#3f9150" end
  if (x - 24) ^ 2 + (y - 38) ^ 2 <= 4 then col = "#f5b82e" end
  if x == 14 or x == 28 or y == 35 or y == 46 then col = pr(y, 2) end
  px(x, y, col)
end)
px(23, 37, "#ffe38a")
-- text columns
for _, y in ipairs{ 35, 37, 39, 41, 43, 45 } do
  local L = 31 + floor(X.hash(3, y, 1) * 2)
  local R = 45 - floor(X.hash(5, y, 2) * 4)
  for x = L, R do if (x + y) % 9 ~= 0 then px(x, y, pr(y, 3)) end end
end
for _, y in ipairs{ 49, 51 } do
  for x = 14, 45 - (y == 51 and 9 or 0) do if (x * 3 + y) % 11 ~= 0 then px(x, y, pr(y, 3)) end end
end
-- quirk: coffee ring stain (broken ring) + a drip
for a = 0, 359, 6 do
  if a < 300 or a > 340 then
    local x = floor(41 + 4.6 * math.cos(math.rad(a)) + 0.5)
    local y = floor(47 + 4.0 * math.sin(math.rad(a)) + 0.5)
    px(x, y, (a > 200 and a < 290) and "#c08a58" or "#9a6440")
  end
end
px(46, 52, "#9a6440") px(47, 53, "#c08a58")
-- dog-eared corner: flap shows the paper back, casts a shadow onto the page
local flap = c:poly{ { 41, 9 }, { 41, 16 }, { 48, 16 } }
flap:each(function(x, y)
  local i = 5
  if x - 41 > y - 9 - 1 then i = 4 end
  if x == 41 then i = 6 end
  c:put(x, y, PAP[i], ptok)
end)
for _, p in ipairs{ { 42, 17 }, { 43, 17 }, { 44, 17 }, { 45, 17 }, { 46, 17 }, { 47, 17 }, { 48, 17 }, { 40, 10 }, { 40, 11 } } do
  if front:has(p[1], p[2]) and not flap:has(p[1], p[2]) then c:put(p[1], p[2], PAP[3], ptok) end end
c:put(42, 15, PAP[6], ptok) c:put(43, 15, PAP[6], ptok)
A.save(c, "ico-newspaper", "ico")
