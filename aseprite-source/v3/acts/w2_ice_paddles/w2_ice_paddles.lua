-- act-w2_ice_paddles (v3 Hearth Pop 2.5D): a gnome knocks the ice off a frozen mill wheel with a mallet.
-- Motion: the mallet taps, ice chips fly, the freed wheel creeps round (one paddle step per loop), meltwater drips.
-- quirk: a little icicle beard hangs off the mill's window sill.
local DIR = (debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")) or "."
local A = dofile(DIR .. "/../actlib.lua")
local P, HP = A.P, A.HP
local floor, atan, sqrt, pi = math.floor, math.atan, math.sqrt, math.pi

local G = A.gnome{ view = "front", hat = "#e8493b", tunic = "#3a86b0", scarf = "#f5b82e" }
local SNOW, SNOW2, SNOW3 = "#f4fbff", "#dbe9f4", "#b9cfe4"
local ICE = { hi = "#eefaff", base = "#bfe6f4", shade = "#8bc4ea", deep = "#5f9ad0" }
local CX, CY = 80, 56

local function bg(c, f)
  c:stripes(10, 46, { "#b9cfe4", "#c9dbec", "#d8e6f2", "#e4eef7" })
  c:terrain(function(x) return 38 + math.sin(x / 9) * 2 + math.sin(x / 4) end, "#c9d9ea", 50)
  A.pine(c, 18, 60, 30, { snow = true })
  for y = 50, 99 do for x = 10, 137 do c:put(x, y, y < 53 and SNOW2 or SNOW) end end
  -- mill wall on the right
  local wall = HP.rect(104, 24, 137, 84)
  c:rim(wall, P.ink, HP.rect(10, 10, 137, 99))
  wall:each(function(x, y)
    local col = (y - 24) % 6 == 5 and "#9c8e96" or ((x == 104 or (y - 24) % 6 == 0) and "#e2dcd8" or "#c9bfbd")
    if (x * 7 + floor((y - 24) / 6) * 11) % 23 == 0 and (y - 24) % 6 ~= 5 then col = "#9c8e96" end
    c:put(x, y, col)
  end)
  local roof = HP.poly{ { 100, 26 }, { 138, 14 }, { 138, 26 } }
  c:fillMask(roof, SNOW) for x = 100, 137 do c:put(x, 26, SNOW2) c:put(x, 27, "#8bc4ea") end
  -- window with warm light, icicles under the sill (quirk)
  local win = HP.rect(116, 36, 127, 48)
  c:fillMask(win, P.wood.deep)
  c:fillMask(HP.rect(117, 37, 126, 47), "#ffe38a") c:fillMask(HP.rect(117, 37, 120, 39), "#fff4d6")
  c:fillMask(HP.rect(121, 37, 121, 47), P.wood.deep) c:fillMask(HP.rect(117, 42, 126, 42), P.wood.deep)
  c:fillMask(HP.rect(115, 49, 128, 50), P.wood.base)
  for i, x in ipairs({ 116, 118, 121, 123, 126 }) do
    local h = ({ 3, 5, 2, 4, 3 })[i]
    for y = 51, 50 + h do c:put(x, y, y == 51 and ICE.base or ICE.shade) end
  end
  -- frozen stream across the bottom
  local st = HP.poly{ { 10, 82 }, { 137, 78 }, { 137, 94 }, { 10, 98 } }
  st:each(function(x, y) c:put(x, y, y < 84 and ICE.hi or ICE.base) end)
  for x = 10, 137 do c:put(x, floor(82 - (x - 10) * 4 / 125 + .5), ICE.deep) end
  for _, cr in ipairs({ { { 30, 88 }, { 38, 86 }, { 44, 90 } }, { { 96, 86 }, { 104, 89 }, { 112, 85 } }, { { 62, 92 }, { 70, 90 } } }) do
    c:line(cr, 1):each(function(x, y) c:put(x, y, ICE.shade) end)
  end
end

local function wheel(c, f)
  local a0 = f * (pi / 4) / 6   -- 45 degrees per loop = one paddle step, so it loops
  local pts = {}
  for y = CY - 32, CY + 32 do for x = CX - 32, CX + 32 do
    local dx, dy = x + .5 - CX, y + .5 - CY
    local r = sqrt(dx * dx + dy * dy)
    local th = (atan(dy, dx) - a0) % (2 * pi)
    local k = th / (pi / 4)
    local fr = k - floor(k + .5)               -- distance to the nearest spoke, in steps
    local col
    if r < 4 then col = (dx + dy < -1) and P.wood.hi or P.wood.shade
    elseif r < 5 then col = P.ink
    elseif r < 16 and math.abs(fr) * r * (pi / 4) < 1.1 then col = (fr < 0) and P.wood.base or P.wood.shade
    elseif r >= 16 and r < 19 then
      col = (r < 17 or r >= 18) and P.wood.deep or ((dy < 0) and P.wood.base or P.wood.shade)
    elseif r >= 24 and r < 26 then col = (r < 25) and P.wood.deep or ((dy < 0) and P.wood.base or P.wood.shade)
    elseif r >= 19 and r < 31 and math.abs(fr) * r * (pi / 4) < 3 then
      local tw = math.abs(fr) * r * (pi / 4)
      if r >= 27 then col = (tw < 1.5) and ICE.hi or ICE.base
      elseif tw >= 2.2 then col = P.wood.deep
      else col = (fr < 0) and P.wood.hi or P.wood.base end
    end
    if col then pts[#pts + 1] = { x, y, col } end
  end end
  -- ink outline round the whole wheel shape
  local m = HP.mask() for _, p in ipairs(pts) do m:set(p[1], p[2]) end
  c:rim(m, P.ink)
  for _, p in ipairs(pts) do c:put(p[1], p[2], p[3]) end
  -- axle post on the wall side
  c:fillMask(HP.rect(CX + 2, CY - 1, 104, CY + 1), P.wood.deep)
  c:fillMask(HP.rect(CX + 4, CY - 1, 103, CY - 1), P.wood.shade)
end

-- mallet poses: raised, raised, mid, hit, mid, raised
local MAL = { { 47, 58 }, { 47, 58 }, { 53, 62 }, { 57, 70 }, { 53, 62 }, { 47, 58 } }

return A.run("w2_ice_paddles", function(f)
  local c = A.canvas("w2_ice_paddles")
  bg(c, f)
  wheel(c, f)
  -- drips from the paddle at the bottom into the stream (loop)
  A.lanes{ lanes = { { x = 80, ph = 0 }, { x = 92, ph = 7 } }, ytop = 84, L = 12, s = 2, D = 12, f = f,
    put = function(x, y) if A.ainside(x, y) and y < 92 then c:put(x, y, ICE.deep) end end }
  -- gnome on the bank, feet at y 94
  A.stamp(c, G, -2, 23)
  -- mallet from the gnome's right hand (~(45,80))
  local hx, hy = 45, 79
  local hd = MAL[f + 1]
  local handle = c:line({ { hx, hy }, hd }, 2)
  c:rim(handle, P.ink)
  handle:each(function(x, y) c:put(x, y, P.wood.base) end)
  local head = HP.rect(hd[1] - 3, hd[2] - 3, hd[1] + 3, hd[2] + 2)
  c:rim(head, P.ink)
  head:each(function(x, y) c:put(x, y, (y == hd[2] - 3) and P.wood.hi or (x >= hd[1] + 2 and P.wood.shade or P.wood.base)) end)
  c:put(hx, hy, "#f0b98d") c:put(hx + 1, hy, "#c98462")
  -- ice chips burst on the hit and fly out on the next frame
  if f == 3 or f == 4 then
    local t = f - 2
    for i, d in ipairs({ { 1, -1 }, { 2, -2 }, { 2, 0 }, { 0, -2 }, { 3, -1 }, { 1, 1 } }) do
      local x, y = 60 + d[1] * t * 2, 68 + d[2] * t * 2 + (t == 2 and 1 or 0)
      if i % 2 == 0 then c:put(x, y, ICE.hi) c:put(x + 1, y, ICE.base) else c:put(x, y, ICE.base) end
    end
  end
  A.snow(c, f, { n = 10, seed = 2, col = SNOW, col2 = SNOW2 })
  return c
end)
