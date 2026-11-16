-- fight (32x32 trail map marker, Opus pass). A round plank shield with an iron rim, rivets and a gold
-- boss, held up in front of a short steel sword (tip up-right, gold crossguard and pommel, wrapped grip
-- lower-left). One clear read: "shield and sword = a creature fight here".
-- quirk: something has taken a big bite out of the shield's rim (tooth marks and all).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local T = dofile(DIR .. "/_trail.lua")
local c = T.new("fight")
local sqrt = math.sqrt

-- sword behind the shield: blade, crossguard, grip, pommel
local ST = { "#444663", "#74758c", "#aaa9b8", "#d4d3de", "#eef0f6" }
local ax, ay, bx, by = 3, 29, 29, 3 -- pommel end to tip
local len = sqrt((bx - ax) ^ 2 + (by - ay) ^ 2)
local ux, uy = (bx - ax) / len, (by - ay) / len
local nx, ny = -uy, ux
if ny > 0 then nx, ny = -nx, -ny end
local GO = { "#8f4a1f", "#d98322", "#f5b82e", "#ffe38a" }
local GR = { "#3a1e26", "#5a2a2c", "#7a3a30", "#9a5038" }
for y = 0, 31 do for x = 0, 31 do
  local px, py = x - ax, y - ay
  local t = (px * ux + py * uy)
  local s = px * nx + py * ny
  local col
  if t >= 0 and t <= len then
    if t < 2 and math.abs(s) <= 1.6 then col = (s > 0.3) and GO[4] or (s > -0.5 and GO[3] or GO[2]) -- pommel
    elseif t < 7 and math.abs(s) <= 0.9 then col = ((math.floor(t) % 2 == 0) and GR[4] or GR[2]) -- grip wrap
    elseif t >= 7 and t < 8.6 and math.abs(s) <= 3.6 then col = (s > 0.5) and GO[4] or (s > -1.5 and GO[3] or GO[2]) -- guard
    elseif math.abs(s) <= 1.6 - math.max(0, (t - (len - 3))) * 0.55 then
      if s > 0.7 then col = ST[5] elseif s > 0 then col = ST[4] elseif s > -0.8 then col = ST[3] else col = ST[2] end
      if math.abs(s) < 0.25 and t > 10 then col = ST[3] end -- fuller
    end
  end
  if col then c:put(x, y, col) end
end end

-- shield
local cx, cy, R = 16, 15.5, 9.5
local WD = { "#51302b", "#6e4030", "#864c33", "#a2643e", "#b97a4a", "#d89a62" }
local IR = { "#2e2f48", "#444663", "#74758c", "#aaa9b8", "#d4d3de" }
local disc = c:ellipse(cx, cy, R, R)
-- the bite: overlapping round notches on the upper-right rim
local bite = c:ellipse(7.5, 12, 2, 2):add(c:ellipse(9.5, 8.5, 2, 2)):add(c:ellipse(13, 6.5, 2, 2)):add(c:poly{ { 4, 11 }, { 8, 6 }, { 13, 3 }, { 4, 3 } })
disc:cut(bite)
disc:each(function(x, y)
  local dx, dy = (x - cx) / (R + 0.5), (y - cy) / (R + 0.5)
  local d = sqrt(dx * dx + dy * dy)
  local L = -0.6 * dx - 0.7 * dy
  if d > 0.8 then -- iron rim
    local i = L > 0.45 and 5 or L > 0.1 and 4 or L > -0.35 and 3 or 2
    c:put(x, y, IR[i])
  else -- planks
    local i = L > 0.35 and 6 or L > 0.05 and 5 or L > -0.3 and 4 or 3
    c:put(x, y, WD[i])
  end
end)
-- plank seams
for _, sx in ipairs{ 11, 16, 21 } do
  for y = 0, 31 do if disc:has(sx, y) and c:get(sx, y) and not ({ ["#2e2f48"] = 1, ["#444663"] = 1, ["#74758c"] = 1, ["#aaa9b8"] = 1, ["#d4d3de"] = 1 })[c:get(sx, y)] then c:put(sx, y, WD[1]) end end
end
-- inner edge of the rim (dark) to separate it from the wood
disc:each(function(x, y)
  local dx, dy = (x - cx) / (R + 0.5), (y - cy) / (R + 0.5)
  local d = sqrt(dx * dx + dy * dy)
  if d <= 0.8 and d > 0.7 then c:put(x, y, WD[1]) end
end)
-- bitten edge: raw pale splintered wood + tooth marks
bite:grow(1):each(function(x, y) if disc:has(x, y) and not bite:has(x, y) then c:put(x, y, "#e8b982") end end)
for _, p in ipairs{ } do if disc:has(p[1], p[2]) then c:put(p[1], p[2], WD[2]) end end
-- rivets on the rim
for _, a in ipairs{ 0.6, 2.2, 3.6, 4.4, 5.6 } do
  local x, y = math.floor(cx + math.cos(a) * 8.7 + 0.5), math.floor(cy + math.sin(a) * 8.7 + 0.5)
  if disc:has(x, y) then c:put(x, y, IR[1]) end
end
-- gold boss
local boss = c:ellipse(16, 15.5, 2, 2)
boss:grow(1):each(function(x, y) c:put(x, y, WD[1]) end)
boss:each(function(x, y)
  local L = -(x - 16) * 0.6 - (y - 15.5) * 0.7
  c:put(x, y, L > 1 and GO[4] or (L > -0.5 and GO[3] or GO[2]))
end)
c:put(15, 14, "#fff4d6")

T.done(c)
