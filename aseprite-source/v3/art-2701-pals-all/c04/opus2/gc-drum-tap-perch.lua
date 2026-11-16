-- Drum Tap (gc-drum-tap), perch sprite 36x36. Opus second pass (c04/opus2), hand-built at this size:
-- the goblet drum (skin head, rope ring, red-wood bowl, a short zigzag of lacing, flared dark foot),
-- face on the bowl (2x3 pills, open ink smile, cheeks), the tapping arm raised on the left.
-- quirk: a rain drop splashing on the skin.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("gc-drum-tap-perch", 36)

local WOOD = { "#3e1a22", "#6e2a2a", "#9e3e32", "#c85a3a", "#e88a52", "#f5b77a" }
local SKIN = { "#8a6a4a", "#b8956a", "#dcc094", "#f0dcb4", "#f8ecd0" }
local ROPE = { "#7a5a3a", "#c9a46a", "#ecd8a8" }
local DROP = { "#2f8a9a", "#5fc4c8", "#b6f0e0" }

c:groundShadow(18, 32, 9, 1.5)
local CX = 18
local function hw(y)
  if y <= 17 then return 9.6 end
  if y <= 25 then local t = (y - 17) / 8 return 9.6 - 5.4 * math.sin(t * math.pi / 2) end
  local t = (y - 25) / 6 return 4.2 + 2.6 * t
end
local body, bn = HP.mask(), {}
for y = 10, 31 do
  local w = hw(y)
  for x = math.floor(CX - w), math.ceil(CX + w) - 1 do
    local nx = (x + .5 - CX) / w
    if math.abs(nx) <= 1 then
      body:set(x, y)
      local z = math.sqrt(math.max(.02, 1 - nx * nx))
      bn[K(x, y)] = { nx, 0, z }
    end
  end
end
local bI = O.shadeN(c, body, bn, WOOD, { amb = .15, wrap = .4, rim = true, bounce = "#7a5a9a", bmax = 2 })
for y = 28, 31 do for x = 0, 35 do if body:has(x, y) then c.pix[y * 36 + x] = WOOD[math.max(1, bI[K(x, y)] - 1)]:lower() end end end
for x = 13, 23 do if body:has(x, 28) then O.mark(c, { { x, 28 } }, WOOD[1]) end end
-- rope ring and lacing
for x = 0, 35 do
  if body:has(x, 10) then O.mark(c, { { x, 10 } }, (x % 2 == 0) and ROPE[2] or ROPE[3]) end
  if body:has(x, 24) then O.mark(c, { { x, 24 } }, (x % 2 == 0) and ROPE[2] or ROPE[3]) end
end
for _, p in ipairs({ { 12, 19 }, { 13, 20 }, { 14, 21 }, { 15, 22 }, { 16, 21 }, { 17, 20 }, { 18, 19 }, { 19, 20 }, { 20, 21 }, { 21, 22 }, { 22, 21 }, { 23, 20 }, { 24, 19 } }) do
  if body:has(p[1], p[2]) then O.mark(c, { p }, ROPE[3]) end
end
for x = 0, 35 do if body:has(x, 18) then O.mark(c, { { x, 18 } }, ROPE[2]) end end

-- skin head
local head = c:ellipse(CX, 9, 10, 2.2)
head:each(function(x, y) c:put(x, y, (y <= 8 and x < 22) and SKIN[5] or (y <= 9 and SKIN[4] or SKIN[3]), { r = { name = "skin" } }) end)

-- arm raised to tap
local arm, an = O.tube({ { 10, 15 }, { 6, 14 }, { 5, 9 }, { 8, 5 } }, function() return 1.2 end)
O.shadeN(c, arm, an, WOOD, { amb = .3, wrap = .4, sep = WOOD[1] })
O.flat(c, c:rect(8, 3, 10, 5), WOOD[5], "hand") O.dot(c, 8, 3, WOOD[6])

-- quirk: rain drop splash
O.flat(c, c:rect(25, 1, 25, 2), DROP[2], "drop") O.flat(c, c:rect(24, 3, 26, 4), DROP[2], "drop") O.dot(c, 24, 3, DROP[3])

c:eyeSmall(13, 12)
c:eyeSmall(21, 12)
O.dot(c, 11, 15, "#f5809f") O.dot(c, 25, 15, "#f5809f")
O.dots(c, { { 16, 15 }, { 17, 16 }, { 18, 16 }, { 19, 15 } }, P.ink)

O.shift(c, 0, 1)
O.done(c, "gc-drum-tap-perch", function(c)
  c:put(22, 6, DROP[2]) c:put(28, 6, DROP[2]) c:put(21, 5, DROP[3]) c:put(29, 5, DROP[3])
end)
