-- pickled-lotus-root (C34, Opus single pass). No jar: a small celadon-blue glazed bowl on a foot ring, seen from 3/4
-- above, heaped with four amber-glazed lotus-root slices (cream flesh, tan skin ring, seven airy holes round a centre
-- hole), sesame seeds and two red chili rings on top.
-- Material: bowl lathe-lit (6-tone glaze, bright rim lip, specular streak, cool bounce), dark sauce pool inside; slices
-- are thick coins (face + 2px cut side) with glossy glaze glints, hole shadows on the far lip and a lit near lip;
-- AO where slices overlap and against the bowl rim.
-- quirk: one slice has rolled out of the bowl and leans on its side against the bowl, like a little wheel.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC34_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, abs, sqrt, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sqrt, math.sin, math.cos, math.pi
local c = A.new("pickled-lotus-root")

local BOWL = { "#1c3456", "#2a5482", "#3a76aa", "#5a9cc8", "#8ec4e0", "#cdeaf6" }
local SAUCE = { "#3a1a1c", "#5a2a1e", "#7e4224" }
local FACE = { "#9a6a3a", "#d0a060", "#ecc888", "#f6e0aa", "#fdf0cc", "#fffaea" }
local SKIN = { "#5a3424", "#8a5a36", "#b88452" }
local HOLE = { "#4a2418", "#7a4626" }
local RED = { "#7a1a26", "#c8302e", "#f26a4a" }

c:groundShadow(31, 51, 15, 2)

-- bowl body (outer wall below the rim ellipse) + foot ring
local CX, CY, RX, RY = 31, 33, 19, 5.5
local body, bn = A.lathe(CX, CY, 47, function(y)
  local t = (y - CY) / (47 - CY)
  return RX * sqrt(max(0, 1 - t ^ 2.2)) + (t > .9 and 0 or 0)
end)
local foot, fn = A.lathe(CX, 46, 49, function(y) return 7.5 end)
A.tone(c, foot, fn, BOWL, { amb = .08, wrap = .25 })
for x = 24, 38 do c:put(x, 49, BOWL[1]) c:put(x, 46, BOWL[2]) end
local bi = A.tone(c, body, bn, BOWL, { amb = .1, wrap = .3 })
-- glaze drip band + specular streak + cool bounce
body:each(function(x, y) local k = K(x, y)
  if y == 40 and (x % 5 ~= 0) then c:put(x, y, BOWL[max(1, (bi[k] or 3) - 1)]) end
end)
for _, p in ipairs{ { 17, 36 }, { 17, 37 }, { 18, 38 }, { 18, 39 } } do c:put(p[1], p[2], BOWL[6]) end
c:put(17, 35, A.SPEC)
body:edge():each(function(x, y) if x > CX + 8 and y > 37 and y < 45 then c:put(x, y, "#7ab8c8") end end)
-- rim: outer ellipse, inner ellipse (sauce), lip
local rimO = c:ellipse(CX, CY, RX, RY)
local rimI = c:ellipse(CX, CY + .5, RX - 2, RY - 1.5)
rimO:each(function(x, y) local lit = x < CX - 4
  c:put(x, y, y <= CY - 4 and BOWL[3] or (lit and BOWL[6] or BOWL[5])) end)
rimI:each(function(x, y) c:put(x, y, (y < CY - 1) and SAUCE[1] or SAUCE[2]) end)
for x = CX - 14, CX - 6 do if rimI:has(x, CY + 2) then c:put(x, CY + 2, SAUCE[3]) end end
local occ = body:copy():add(rimO)

-- lotus slice: face ellipse + 2px cut side; holes ring
local function slice(cx, cy, rx, ry, o)
  o = o or {}
  local face = c:ellipse(cx, cy, rx, ry)
  local side = face:shift(0, 1):add(face:shift(0, 2)):cut(face)
  local all = face:copy():add(side)
  if o.clip then face:cut(o.clip) side:cut(o.clip) all:cut(o.clip) end
  side:each(function(x, y) c:put(x, y, x < cx - rx * .3 and SKIN[3] or (x > cx + rx * .4 and SKIN[1] or SKIN[2])) end)
  local fn = {}
  face:each(function(x, y)
    local dx, dy = (x + .5 - cx - .5) / rx, (y + .5 - cy - .5) / ry
    local d = min(.97, sqrt(dx * dx + dy * dy))
    fn[K(x, y)] = { A.norm(dx * .45, dy * .45, 1) }
  end)
  face:each(function(x, y)
    local dx, dy = (x + .5 - cx - .5) / rx, (y + .5 - cy - .5) / ry
    local l = dx + dy
    c:put(x, y, FACE[l < -.7 and 6 or (l < -.15 and 5 or (l < .5 and 4 or 3))])
  end)
  face:each(function(x, y)
    local dx, dy = (x + .5 - cx - .5) / rx, (y + .5 - cy - .5) / ry
    local d = sqrt(dx * dx + dy * dy)
    if d > .9 then c:put(x, y, (dx + dy < 0) and SKIN[3] or SKIN[2]) end
  end)
  -- holes: 7 round a centre one, foreshortened
  local holes = { { 0, 0, .9 } }
  for i = 0, 5 do local a = i / 6 * 2 * pi + (o.rot or 0) holes[#holes + 1] = { cos(a) * .6, sin(a) * .58, i % 2 == 0 and 1.25 or 1.0 } end
  for _, h in ipairs(holes) do
    local hx, hy = cx + .5 + h[1] * rx, cy + .5 + h[2] * ry
    local hr = h[3] * rx / 7.2
    local hm = HP.mask()
    for y = floor(hy - 2), floor(hy + 2) do for x = floor(hx - 3), floor(hx + 3) do
      local ddx, ddy = (x + .5 - hx) / (hr + .25), (y + .5 - hy) / (hr * .5 + .3)
      if ddx * ddx + ddy * ddy <= 1 then hm:set(x, y) end end end
    hm:clip(face)
    hm:each(function(x, y)
      -- far (upper) part of the hole is the dark inner wall, near part shows the lit lower wall
      c:put(x, y, (not hm:has(x, y - 1)) and HOLE[1] or HOLE[2]) end)
    hm:each(function(x, y) if not hm:has(x, y + 1) and face:has(x, y + 1) then c:put(x, y + 1, FACE[5]) end end)
  end
  -- glaze glint
  local gx, gy = floor(cx - rx * .5), floor(cy - ry * .55)
  if face:has(gx, gy) then c:put(gx, gy, A.SPEC) end
  if face:has(gx + 1, gy) then c:put(gx + 1, gy, FACE[6]) end
  -- separation + contact shadow
  all:edge():each(function(x, y)
    for _, d in ipairs{ { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } } do
      if occ:has(x + d[1], y + d[2]) and not all:has(x + d[1], y + d[2]) and not occ:has(x, y) then c:put(x, y, SKIN[1]) break end
    end end)
  local sh = all:shift(1, 1):add(all:shift(0, 1)):add(all:shift(1, 2)):cut(all)
  sh:each(function(x, y) if occ:has(x, y) then local h = c:get(x, y) if h then c.pix[y * c.w + x] = A.mix(h, "#1a0e1c", .35) end end end)
  occ:add(all)
  return face
end
-- heap (back to front)
slice(23.5, 28.5, 8.5, 4.8, { rot = .3 })
slice(39.5, 28.5, 8.5, 4.8, { rot = .9 })
slice(31.5, 24.5, 8.5, 4.8, { rot = .1 })
local top = slice(30.5, 31.5, 9, 5, { rot = .5 })
-- sesame and chili rings on top
for _, p in ipairs{ { 26, 30 }, { 33, 33 }, { 36, 27 }, { 29, 23 }, { 22, 27 }, { 41, 30 } } do c:put(p[1], p[2], "#fff4d6") c:put(p[1] + 1, p[2], "#e8d2a0") end
for _, r in ipairs{ { 35, 22 }, { 24, 33 } } do
  local x, y = r[1], r[2]
  c:put(x, y, RED[3]) c:put(x + 1, y, RED[2]) c:put(x + 2, y, RED[2])
  c:put(x - 1, y + 1, RED[2]) c:put(x + 3, y + 1, RED[1]) c:put(x, y + 2, RED[1]) c:put(x + 1, y + 2, RED[1]) c:put(x + 2, y + 2, RED[1])
  c:put(x + 1, y + 1, "#f6d27a")
end

-- quirk: a slice rolled out, standing on edge against the right of the bowl
do
  local cx, cy, rx, ry = 52.5, 43.5, 3.4, 6.2
  local edge = c:ellipse(cx - 1.5, cy, rx, ry)
  local face = c:ellipse(cx, cy, rx, ry)
  edge:cut(face)
  edge:each(function(x, y) c:put(x, y, y < cy - 2 and SKIN[3] or SKIN[1]) end)
  local fn = {} face:each(function(x, y) fn[K(x, y)] = { A.norm((x + .5 - cx) / rx * .45, (y + .5 - cy) / ry * .45, 1) } end)
  face:each(function(x, y) local l = (x + .5 - cx) / rx + (y + .5 - cy) / ry c:put(x, y, FACE[l < -.5 and 5 or (l < .3 and 4 or 3)]) end)
  face:edge():each(function(x, y) c:put(x, y, (y < cy) and SKIN[3] or SKIN[2]) end)
  for _, h in ipairs{ { 0, -3 }, { 0, 3 }, { -1, 0 }, { 1, 0 }, { 0, 0 } } do
    local x, y = floor(cx + h[1] * 1.5 + .5) - (h[1] == 0 and 0 or 0), floor(cy + h[2] * 1 + .5)
    if h[1] == 0 and h[2] == 0 then c:put(x, y, HOLE[1]) else c:put(x, y, HOLE[1]) c:put(x, y + 1, HOLE[2]) end
  end
  c:put(floor(cx) - 1, floor(cy) - 5, A.SPEC)
  -- contact with the bowl wall
  for y = floor(cy - 4), floor(cy + 5) do local x = floor(cx - rx - 2) if body:has(x, y) then c:put(x, y, BOWL[1]) end end
end

A.fin(c, "pickled-lotus-root")
