-- sight (32x32 trail map marker, Opus pass). A brass spyglass on a little wooden tripod, aimed up and to
-- the right: three telescoping brass sections with dark joint rings, a violet-leather grip on the barrel, a
-- flared objective with a blue glass glint. Per-pixel cylinder light (lit along the top edge).
-- quirk: a ladybird has climbed onto the barrel and is riding it, sitting right on the top edge.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local T = dofile(DIR .. "/_trail.lua")
local c = T.new("sight")
local sqrt, max, min, floor = math.sqrt, math.max, math.min, math.floor

local BR = { "#5a3418", "#8f4a1f", "#c07a2a", "#e3a63c", "#f5d06a", "#fff0b0" }
local LE = { "#2a2050", "#35295f", "#4a3a86", "#5f4ca8", "#7d68c8", "#a790e0" }
local WD = { "#51302b", "#864c33", "#b97a4a", "#e8b982" }

-- tripod (behind the tube)
for _, l in ipairs{ { { 15, 15 }, { 9, 29 } }, { { 17, 15 }, { 24, 29 } } } do
  local m = c:line(l, 2)
  m:each(function(x, y) c:put(x, y, (m:has(x - 1, y)) and WD[2] or WD[3]) end)
end
local back = c:line({ { 16, 15 }, { 17, 27 } }, 1)
back:each(function(x, y) c:put(x, y, WD[1]) end)
c:put(9, 29, WD[1]) c:put(10, 29, WD[1]) c:put(24, 29, WD[1]) c:put(25, 29, WD[1]) -- feet

-- spyglass tube
local ax, ay, bx, by = 4, 21, 27, 7
local dx, dy = bx - ax, by - ay
local len = sqrt(dx * dx + dy * dy)
local ux, uy = dx / len, dy / len
local nx, ny = uy, -ux -- normal; flip so it points up
if ny > 0 then nx, ny = -nx, -ny end
local function radius(t)
  if t < 0.16 then return 1.5 elseif t < 0.42 then return 2.1 elseif t < 0.9 then return 2.9 else return 3.5 end
end
local tube = HP and nil
local data = {}
for y = 0, 31 do for x = 0, 31 do
  local px, py = x - ax, y - ay
  local t = (px * ux + py * uy) / len
  local s = px * nx + py * ny
  if t >= 0 and t <= 1 then
    local r = radius(t)
    if math.abs(s) <= r then data[#data + 1] = { x, y, t, s / r } end
  end
end end
for _, p in ipairs(data) do
  local x, y, t, v = p[1], p[2], p[3], p[4] -- v: +1 top edge, -1 bottom edge
  local R = BR
  if t > 0.52 and t < 0.76 then R = LE end
  local i = v > 0.55 and 5 or v > 0.1 and 4 or v > -0.45 and 3 or 2
  if v < -0.8 then i = 1 end
  c:put(x, y, R[i])
end
-- joint rings (dark band + lit lip) and the bright specular along the top
local function ring(t0)
  for _, p in ipairs(data) do
    local t = p[3]
    if math.abs(t - t0) * len < 0.6 then c:put(p[1], p[2], p[4] > 0.3 and BR[3] or BR[1]) end
  end
end
ring(0.16) ring(0.42) ring(0.9)
for _, p in ipairs(data) do
  if p[4] > 0.62 and p[3] > 0.2 and p[3] < 0.36 then c:put(p[1], p[2], BR[6]) end
  if p[4] > 0.62 and p[3] > 0.78 and p[3] < 0.86 then c:put(p[1], p[2], BR[6]) end
end
-- objective glass on the end
for _, p in ipairs(data) do if p[3] > 0.965 then c:put(p[1], p[2], p[4] > 0.2 and "#b6f0e0" or "#5fc4c8") end end
-- eyepiece cap
for _, p in ipairs(data) do if p[3] < 0.05 then c:put(p[1], p[2], BR[2]) end end

-- ladybird riding the top of the barrel (spotted dome on the edge)
T.grid(c, 15, 5, {
  ".rrrr...",
  "rrkrRr..",
  "srrrrrkk",
  "ssrkrrkk",
}, { r = "#e8493b", R = "#ff8a5c", s = "#b52e3f", k = "#2b1c26" })
c:put(22, 7, "#fff4d6") -- eye glint, head toward the lens

-- glint off the lens
c:put(30, 3, "#fff4d6") c:put(30, 2, "#ffe38a") c:put(29, 3, "#ffe38a") c:put(30, 4, "#ffe38a") c:put(31, 3, "#ffe38a")

T.done(c)
