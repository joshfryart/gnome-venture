-- goat-cheese-salad (B3, Opus single pass, replaces the Sonnet draft). A shallow glazed teal bowl on a slim foot ring
-- (cream band with red dots under the rim) heaped with slim lettuce and radicchio leaves fanning up, topped with
-- three warm goat-cheese rounds (toasted gold tops, white rind sides), beet cubes and walnut halves.
-- Material: per-pixel glaze light with a vertical specular streak and a cool bounce, leaf midribs, contact shadows
-- between leaves and toppings, dark bowl interior where the food meets the rim, ground shadow.
-- quirk: a drip of golden dressing is running down the outside of the bowl.
local NAME = "goat-cheese-salad"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB34_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sqrt, max, min, abs, pi, sin = math.floor, math.sqrt, math.max, math.min, math.abs, math.pi, math.sin
local c = A.new(NAME)

local BW   = { "#1f3a5e", "#2a5580", "#3a7aa8", "#4f9fc6", "#7cc6d8", "#c2eef0" }
local CRM  = { "#8a7488", "#bba8a8", "#e2d2bc", "#f6ead0", "#fff6e2" }
local LEAF = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local RAD  = { "#3a1838", "#5e2149", "#86305c", "#ad4677", "#d06e96", "#eaa0bb" }
local RINDC = { "#8e86a2", "#b8b1c2", "#d9d3d6", "#efe9de", "#fffaee" }
local TOAST = { "#8f4a1f", "#c27a2c", "#e0a443", "#f3cf7a", "#fbe7b0" }
local BEET = { "#4a1036", "#7a1a4e", "#a8275f", "#d04a7c" }
local NUT  = { "#51302b", "#864c33", "#b97a4a", "#e0aa72" }
local GLD  = { "#9a5420", "#d98322", "#f5b82e", "#ffe38a" }
local CX, RIMY, RX, RY = 32, 37, 22, 5

c:groundShadow(CX, 53, 14, 1)
local function front(x) local u = (x - CX) / (RX + 0.5) return RIMY + RY * sqrt(max(0, 1 - u * u)) end

-- bowl interior (dark), seen inside the rim ellipse
local inner = c:ellipse(CX, RIMY, RX - 1, RY - 1)
inner:each(function(x, y) A.setp(c, x, y, BW, y < RIMY - 1 and 2 or 1) end)

-- leaves (back to front)
local leaves = {
  { 32, 36, 31, 24, 31, 12, 3.2, LEAF },
  { 30, 36, 23, 25, 18, 17, 3.0, RAD },
  { 34, 36, 41, 25, 46, 17, 3.0, LEAF },
  { 31, 37, 21, 30, 11, 27, 3.2, LEAF },
  { 33, 37, 43, 30, 53, 27, 3.2, RAD },
  { 29, 38, 19, 35, 13, 34, 2.4, RAD },
  { 35, 38, 45, 35, 52, 34, 2.4, LEAF },
}
local food = HP.mask()
local function clipBowl(m)
  m:each(function(x, y) if abs(x - CX) <= RX and y > front(x) - 1 then m.s[K(x, y)] = nil end end)
  return m
end
for i, L in ipairs(leaves) do
  local m, n, T, S = A.blade(L[1], L[2], L[3], L[4], L[5], L[6], function(t)
    if t > 0.97 then return -1 end
    return L[7] * sin(pi * min(1, t * 0.95 + 0.08)) ^ 0.6 end, { fold = 0.5 })
  clipBowl(m)
  -- frilly edge: knock out some edge pixels
  m:edge():each(function(x, y) if X.hash(x, y, i) > 0.72 then m.s[K(x, y)] = nil end end)
  A.contact(c, m, 1, 1, 1)
  A.tone(c, m, n, L[8], { cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, amb = 0.1, wrap = 0.3 })
  A.sep(c, m, 2)
  -- midrib
  m:each(function(x, y) local k = K(x, y) if abs(S[k]) < 0.14 and T[k] > 0.05 and T[k] < 0.9 then A.setp(c, x, y, L[8], 5) end end)
  food:add(m)
end

-- toppings
local function cheese(cx, cy)
  local top = c:ellipse(cx, cy, 4, 2.2)
  local side = c:ellipse(cx, cy + 1.5, 4, 2.2):cut(top)
  clipBowl(top) clipBowl(side)
  local both = top:copy():add(side)
  A.contact(c, both, 1, 1, 1)
  side:each(function(x, y) local u = (x - cx) / 4 A.setp(c, x, y, RINDC, u < -0.4 and 4 or (u < 0.4 and 3 or 2)) A.store[K(x, y)] = { RINDC, 3 } end)
  local e = top:edge()
  top:each(function(x, y)
    local u, v = (x - cx) / 4, (y - cy) / 2.2
    if e:has(x, y) then A.setp(c, x, y, RINDC, (u + v < 0) and 5 or 4)
    else
      local i = (u + v < -0.3) and 4 or 3
      if abs(u) < 0.35 and abs(v) < 0.5 then i = i - 1 end
      A.setp(c, x, y, TOAST, i)
    end
  end)
  c:put(floor(cx - 2), floor(cy - 1), TOAST[5])
end
local function beet(x, y)
  local m = c:rect(x, y, x + 2, y + 2) clipBowl(m)
  A.contact(c, m, 1, 1, 1)
  m:each(function(px, py)
    local i = 3
    if py == y then i = 4 elseif px == x + 2 or py == y + 2 then i = 2 end
    A.setp(c, px, py, BEET, i)
  end)
  A.setp(c, x + 2, y + 2, BEET, 1)
end
local function walnut(x, y)
  local m = c:ellipse(x, y, 2, 1.5) clipBowl(m)
  A.contact(c, m, 1, 1, 1)
  m:each(function(px, py)
    local u, v = (px - x) / 2, (py - y) / 1.5
    local i = (u + v < -0.3) and 4 or ((u + v > 0.6) and 2 or 3)
    if (px + py) % 3 == 0 then i = i - 1 end
    A.setp(c, px, py, NUT, i)
  end)
end
beet(21, 31) beet(41, 32) beet(30, 21)
walnut(37, 25) walnut(25, 26) walnut(16, 33)
cheese(24, 32) cheese(39, 29) cheese(31, 27)

-- bowl body
local body = HP.mask()
for x = CX - RX, CX + RX do
  local u = (x - CX) / (RX + 0.5)
  local yb = RIMY + 13 * (max(0, 1 - u * u)) ^ 0.75
  for y = RIMY, floor(yb) do
    if y >= front(x) - 1 or not inner:has(x, y) then body:set(x, y) end
  end
end
local bn = {}
body:each(function(x, y) local u = max(-0.97, min(0.97, (x - CX) / (RX + 0.5))) bn[K(x, y)] = A.norm(u, 0.35, sqrt(1 - u * u)) end)
local bb = {}
body:each(function(x, y) if y >= front(x) + 9 then bb[K(x, y)] = -1 end end)
A.tone(c, body, bn, BW, { bias = bb, cuts = { 0.18, 0.34, 0.5, 0.66, 0.84 }, amb = 0.1, wrap = 0.3 })
-- rim lip (lit) along the front edge
for x = CX - RX, CX + RX do
  local y = floor(front(x) + 0.5)
  local u = (x - CX) / RX
  if body:has(x, y) then A.setp(c, x, y, BW, u < 0.3 and 6 or 5) end
  if body:has(x, y - 1) and not food:has(x, y - 1) then A.setp(c, x, y - 1, BW, 4) end
end
-- cream band with dots
for x = CX - RX + 1, CX + RX - 1 do
  local y0 = floor(front(x) + 0.5) + 2
  local u = (x - CX) / RX
  local i = u < -0.4 and 5 or (u < 0.3 and 4 or (u < 0.7 and 3 or 2))
  for y = y0, y0 + 1 do if body:has(x, y) then A.setp(c, x, y, CRM, i) end end
  if (x - CX) % 4 == 0 and body:has(x, y0) then c:put(x, y0, u < 0.5 and "#e8493b" or "#b52e3f") end
end
-- glaze specular streak + cool bounce
for y = 0, 3 do local x = 18 local yy = floor(front(x) + 0.5) + 5 + y if body:has(x, yy) then c:put(x, yy, y < 2 and "#e8fbff" or BW[6]) end end
body:edge():each(function(x, y) if x > CX + 10 and y > RIMY + 4 then A.setp(c, x, y, BW, 3) end end)
-- foot ring
local foot = c:rrect(25, 49, 39, 51, 1)
A.tone(c, foot, A.vnorm(foot, 25, 39, 0.2), BW, { cuts = { 0.18, 0.34, 0.5, 0.66, 0.84 } })
for x = 26, 38 do A.setp(c, x, 49, BW, 1) end

-- quirk: a drip of dressing running down the outside of the bowl
local dx0 = 45
local dy0 = floor(front(dx0) + 0.5)
for y = dy0, dy0 + 5 do A.setp(c, dx0, y, GLD, y == dy0 and 4 or 3) end
A.setp(c, dx0 + 1, dy0 + 1, GLD, 2)
A.setp(c, dx0, dy0 + 6, GLD, 3) A.setp(c, dx0 + 1, dy0 + 6, GLD, 2)
A.setp(c, dx0, dy0 + 7, GLD, 2) A.setp(c, dx0 + 1, dy0 + 7, GLD, 1)
c:put(dx0, dy0 + 6, "#fff4d6")

A.save(c, NAME)
