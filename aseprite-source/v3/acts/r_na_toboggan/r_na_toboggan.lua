-- act-r_na_toboggan (v3 Hearth Pop 2.5D): three gnomes ride one long toboggan down a snowy slope past a lookout hut.
-- Motion: the sled bumps, snow sprays off the curled nose, speed streaks slide back over the snow, snow falls slantwise.
-- quirk: the last rider's scarf flies out straight behind.
local DIR = (debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")) or "."
local A = dofile(DIR .. "/../actlib.lua")
local P, HP = A.P, A.HP
local floor = math.floor

local SNOW, SNOW2, SNOW3 = "#f4fbff", "#dbe9f4", "#b9cfe4"
local RIDERS = {
  A.gnome{ view = "side", hat = "#3f7fd6", tunic = "#e8493b", scarf = "#7cc35a", skip = { shadow = true } },
  A.gnome{ view = "side", hat = "#e8493b", tunic = "#3a86b0", scarf = "#f5b82e", skip = { shadow = true } },
  A.gnome{ view = "side", hat = "#f5b82e", tunic = "#8a6fd0", scarf = "#e8493b", skip = { shadow = true } },
}
local function slope(x) return 60 + (x - 10) * 0.24 end
local BOB = { 0, -1, 0, 0, -1, 0 }

local function bg(c, f)
  c:stripes(10, 44, { "#b9cfe4", "#c9dbec", "#d8e6f2", "#e4eef7" })
  c:terrain(function(x) return 30 + math.abs(((x + 30) % 50) - 25) * .5 end, "#c9d9ea", 60)
  c:terrain(function(x) return 33 + math.abs(((x + 30) % 50) - 25) * .5 end, "#aec3da", 60)
  -- far snowfield behind the slope
  for y = 44, 99 do for x = 10, 137 do c:put(x, y, y < 47 and "#c9dbec" or "#e4eef7") end end
  for i = 1, 14 do local x, y = 12 + floor(A.hash(i, 4, 2) * 120), 48 + floor(A.hash(i, 5, 2) * 20) c:put(x, y, "#d8e6f2") c:put(x + 1, y, "#d8e6f2") end
  -- pines on the far side of the slope
  A.pine(c, 110, 64, 32, { snow = true })
  A.pine(c, 127, 70, 42, { snow = true })
  A.pine(c, 94, 58, 20, { snow = true })
  -- the slope
  local s = c:terrain(slope, SNOW, 99, 10, 137)
  for x = 10, 137 do local y = floor(slope(x) + .5) c:put(x, y, "#c9dbec") c:put(x, y + 1, SNOW2) end
  for i = 1, 30 do
    local x = 12 + floor(A.hash(i, 1, 8) * 122)
    local y = floor(slope(x) + 6 + A.hash(i, 2, 8) * 40)
    if y < 99 then c:put(x, y, SNOW2) c:put(x + 1, y, SNOW2) c:put(x + 2, y + 1, SNOW3) end
  end
  -- lookout hut, top left, on short legs
  local hx, hy = 14, 34
  c:fillMask(HP.rect(hx + 2, hy + 14, hx + 3, 62), P.wood.deep)
  c:fillMask(HP.rect(hx + 18, hy + 14, hx + 19, 65), P.wood.deep)
  local wall = HP.rect(hx, hy + 4, hx + 21, hy + 15)
  local roof = HP.poly{ { hx - 3, hy + 5 }, { hx + 10.5, hy - 3 }, { hx + 24, hy + 5 } }
  c:rim(wall:copy():add(roof), P.ink)
  wall:each(function(x, y) c:put(x, y, (y - hy) % 3 == 0 and P.wood.shade or (x > hx + 17 and P.wood.shade or P.wood.base)) end)
  roof:each(function(x, y) c:put(x, y, y < hy + 3 and SNOW or (y == hy + 3 and SNOW2 or "#c9dbec")) end)
  local win = HP.rect(hx + 7, hy + 7, hx + 13, hy + 12)
  c:fillMask(win, P.wood.deep) c:fillMask(HP.rect(hx + 8, hy + 8, hx + 12, hy + 11), "#ffe38a") c:put(hx + 8, hy + 8, "#fff4d6")
  c:fillMask(HP.rect(hx + 10, hy + 8, hx + 10, hy + 11), P.wood.deep)
  -- speed streaks on the snow, sliding up-left (back along the slope) 2 px per frame on a 12 px pattern
  for r = 0, 3 do
    for x = 12, 132 do
      local y = floor(slope(x) + 8 + r * 7 + .5)
      if y <= 97 and (x + f * 2 + r * 5) % 24 < 5 and x < 120 then c:put(x, y, SNOW3) end
    end
  end
end

local function sled(c, b)
  -- deck along the slope from x 30 to 118, curled nose at the right
  local m = HP.mask()
  for x = 30, 118 do local y = floor(slope(x) - 4 + .5) + b for yy = y, y + 2 do m:set(x, yy) end end
  local nx, ny = 118, floor(slope(118) - 4 + .5) + b
  local nose = HP.ellipse(nx + 2, ny - 2, 3, 3):cut(HP.ellipse(nx + 1, ny - 2, 1.5, 1.5))
  m:add(nose)
  c:rim(m, P.ink)
  m:each(function(x, y)
    local top = floor(slope(x) - 4 + .5) + b
    local col = (y == top) and P.wood.hi or (y == top + 2 and P.wood.shade or P.wood.base)
    if nose:has(x, y) then col = P.wood.base end
    c:put(x, y, col)
  end)
  -- rope rail
  for x = 34, 114, 2 do c:put(x, floor(slope(x) - 5 + .5) + b, "#d98322") end
end

return A.run("r_na_toboggan", function(f)
  local c = A.canvas("r_na_toboggan")
  bg(c, f)
  local b = BOB[f + 1]
  -- riders, rear first; hips sit on the deck
  local xs = { 50, 76, 102 }
  for i, g in ipairs(RIDERS) do
    local x = xs[i]
    local hip = floor(slope(x) - 4 + .5) + b
    A.stamp(c, g, x - 32, hip - 60, { clip = function(_, y) return y < hip end })
  end
  sled(c, b)
  -- quirk: the last rider's scarf streams out behind
  local sy = floor(slope(50) - 4 + .5) + b - 12
  local flap = (f % 2 == 0) and 0 or 1
  for k = 0, 7 do c:put(37 - k, sy + floor(k / 3) + ((k % 2 == 1) and flap or 0), (k % 3 == 2) and "#3f9150" or "#7cc35a") end
  -- snow spray off the nose: rising up-left
  local nx, ny = 122, floor(slope(122) - 6 + .5) + b
  A.lanes{ lanes = { { x = nx - 18, ph = 0 }, { x = nx - 12, ph = 4 } }, ytop = ny - 12, L = 12, s = -2, D = 12, f = f, dx = 1.5,
    put = function(x, y)
      if A.ainside(x, y) then c:put(x, y, SNOW) if y > ny - 6 then c:put(x + 1, y, SNOW2) c:put(x, y + 1, SNOW) end end
    end }
  A.snow(c, f, { n = 12, seed = 5, dx = -.25, col = SNOW, col2 = SNOW2 })
  return c
end)
