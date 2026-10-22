-- trek-crystal-o: gold glow crystal (map-key diamond) on a lit open-floor pad (family 1)
local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local NAME = "trek-crystal-o"
local c = GV.canvas{ w = 42, h = 42, mode = "scene" }
local P = {
  so_gloss = "#d9ba7c", so_rim = "#c9a96e", so_base = "#9a6b3f",
  gd_gloss = "#fff1c8", gd_rim = "#f5cf6a", gd_base = "#e8a317", gd_bounce = "#d0862a", gd_shade = "#b8661a",
  gd_deep = "#7a3a14", umber1 = "#74462a", umber2 = "#4a2c1a", umber3 = "#2a1a10",
}
local function px(x, y, k) c:px(x, y, P[k] or k) end
local function rect(x0, y0, x1, y1, k) for y = y0, y1 do for x = x0, x1 do px(x, y, k) end end end

rect(0, 0, 41, 41, "so_base")

-- lit floor pad: stepped octagon 28 wide (x7..34) x 26 tall (y8..33), centred ~(21,21)
for y = 8, 33 do for x = 7, 34 do
  local dx, dy = math.abs(x - 20.5), math.abs(y - 20.5)
  if dx + dy <= 18.5 then px(x, y, "so_rim") end
end end

-- crystal diamond: top (21,5), bottom (21,37), left (11,21), right (31,21)
local CX, CY = 21, 21
local function hw(y)
  if y < 5 or y > 37 then return -1 end
  local d = (y <= CY) and (y - 5) or (37 - y)
  return math.floor(d * 10 / 16 + 0.5)
end
local function inD(x, y) local h = hw(y) return h >= 0 and math.abs(x - CX) <= h end
local function edge(x, y) return inD(x, y) and not (inD(x - 1, y) and inD(x + 1, y) and inD(x, y - 1) and inD(x, y + 1)) end

-- distance (in px) from a pixel to the lower-right outline, measured along +x and +y
local function lrDist(x, y)
  for k = 1, 4 do
    if edge(x + k, y) or edge(x, y + k) or not inD(x + k, y) or not inD(x, y + k) then return k end
  end
  return 99
end

for y = 5, 37 do for x = 11, 31 do
  if inD(x, y) then
    if edge(x, y) then
      local col
      if y <= CY and x <= CX then col = "umber1"
      elseif y <= CY then col = "umber2"
      elseif x <= CX then col = "umber2"
      else col = "umber3" end
      px(x, y, col)
    else
      local col = (x <= CX) and "gd_rim" or "gd_base"
      if y > CY and x > CX - 2 then
        -- lower-right edge: 2 px shade band at the edge, 1 px bounce just inside
        local d = lrDist(x, y)
        if x > CX or y > CY + 3 then
          if d <= 2 then col = "gd_shade" elseif d == 3 then col = "gd_bounce" end
        end
      end
      px(x, y, col)
    end
  end
end end
-- bottom tip: deep
for _, p in ipairs({ {21,36}, {20,35}, {21,35} }) do if not edge(p[1], p[2]) then px(p[1], p[2], "gd_deep") end end
px(22, 35, "gd_deep")

-- inner table facet: 11 x 19 diamond centred (21,21), gd_deep outline, gloss upper half / rim lower half
local function ihw(y)
  if y < 12 or y > 30 then return -1 end
  local d = (y <= CY) and (y - 12) or (30 - y)
  return math.floor(d * 5 / 9 + 0.5)
end
local function inI(x, y) local h = ihw(y) return h >= 0 and math.abs(x - CX) <= h end
for y = 12, 30 do for x = 16, 26 do
  if inI(x, y) then
    local e = not (inI(x - 1, y) and inI(x + 1, y) and inI(x, y - 1) and inI(x, y + 1))
    if e then px(x, y, "gd_deep")
    elseif y < CY then px(x, y, "gd_gloss")
    else px(x, y, "gd_rim") end
  end
end end

-- facet line along x=22, y9..33 (inside the outer outline only)
for y = 9, 33 do if inD(22, y) and not edge(22, y) then px(22, y, "gd_deep") end end

-- gloss comma on the upper-left facet, along the left edge, x13..16, y14..22
for y = 14, 22 do
  local left = CX - hw(y) + 1           -- first inside pixel
  local wdt = (y <= 17) and 2 or 1      -- thicker head, tapering tail
  if y == 22 then wdt = 0 end
  for x = math.max(13, left), math.min(16, left + wdt) do
    if not edge(x, y) and not inI(x, y) then px(x, y, "gd_gloss") end
  end
end
px(15, 12, "gd_gloss") -- gloss dot above the comma

-- four sparks (plus, gd_gloss)
for _, s in ipairs({ {6,8}, {35,10}, {7,33}, {36,31} }) do
  local x, y = s[1], s[2]
  px(x, y, "gd_gloss"); px(x - 1, y, "gd_gloss"); px(x + 1, y, "gd_gloss"); px(x, y - 1, "gd_gloss"); px(x, y + 1, "gd_gloss")
end

local t = c:save(D .. "trek-pixel/aseprite/" .. NAME .. ".aseprite", D .. "trek-pixel/png/" .. NAME .. ".png")
print(NAME, GV.report(t))
