-- trek-bang (family 6, marker, 24x24): objective mark. Red round badge, umber outline by light,
-- lower-right crescent, enamel gloss comma, bold cream exclamation mark.
local ROOT = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(ROOT .. "gvlib/gvlib.lua")
local NAME, W, H = "trek-bang", 24, 24

---------------------------------------------------------------- tiny pixel helpers
local P = {}
local function key(x, y) return y * W + x end
local function set(x, y, h) if x >= 0 and y >= 0 and x < W and y < H then P[key(x, y)] = h end end
local function has(m, x, y) return x >= 0 and y >= 0 and x < W and y < H and m[key(x, y)] end
local function adj4(m, x, y) return has(m, x + 1, y) or has(m, x - 1, y) or has(m, x, y + 1) or has(m, x, y - 1) end
local function mdisc(cx, cy, r)
  local m = {}
  for y = 0, H - 1 do for x = 0, W - 1 do
    local dx, dy = x - cx, y - cy
    if dx * dx + dy * dy <= r * r then m[key(x, y)] = true end
  end end
  return m
end
local function edge(m)
  local e = {}
  for k in pairs(m) do
    local x, y = k % W, k // W
    if not (has(m, x + 1, y) and has(m, x - 1, y) and has(m, x, y + 1) and has(m, x, y - 1)) then e[k] = true end
  end
  return e
end
local function save()
  local c = GV.canvas{ w = W, h = H, mode = "scene" }
  for k, h in pairs(P) do c:px(k % W, k // W, h) end
  local t = c:save(ROOT .. "trek-pixel/aseprite/" .. NAME .. ".aseprite", ROOT .. "trek-pixel/png/" .. NAME .. ".png")
  print(NAME .. ": " .. GV.report(t))
end

---------------------------------------------------------------- palette (palette.md)
local U1, U2, U3 = "#74462a", "#4a2c1a", "#2a1a10"
local RD = { gloss = "#ff9158", rim = "#f2793a", base = "#dd3a2a", bounce = "#b8452f", shade = "#ae2a2a", deep = "#6b1b2c" }
local CREAM, CR_SHADE = "#f4f0e0", "#cfc3a2"

---------------------------------------------------------------- badge
local cx, cy = 11.5, 11.5
local function s(x, y) return (x - cx) + (y - cy) end
local disc = mdisc(cx, cy, 11)                 -- x1..22, y1..22
local outline = edge(disc)
local body = {}
for k in pairs(disc) do if not outline[k] then body[k] = true end end
-- crescent: body pixels not covered by the body shifted 3 px toward the light
local function inShift(x, y, d) return has(body, x + d, y + d) end
for k in pairs(disc) do
  local x, y = k % W, k // W
  local sv = s(x, y)
  if outline[k] then
    set(x, y, sv < -6 and U1 or (sv > 6 and U3 or U2))
  else
    local h = RD.base
    if adj4(outline, x, y) and sv < -4 then h = RD.rim end
    if not inShift(x, y, 3) and sv > 0 then
      h = adj4(outline, x, y) and RD.bounce or RD.shade   -- 2 px shade, 1 px bounce at the edge
    end
    set(x, y, h)
  end
end
-- deep: the bottom-right extreme edge pixel(s)
local best = -99
for k in pairs(body) do local x, y = k % W, k // W if adj4(outline, x, y) then best = math.max(best, s(x, y)) end end
for k in pairs(body) do local x, y = k % W, k // W if adj4(outline, x, y) and s(x, y) >= best and math.abs(x - y) <= 1 then set(x, y, RD.deep) end end
-- gloss comma (3 px) on the lit upper-left
set(4, 5, RD.gloss); set(5, 5, RD.gloss); set(6, 5, RD.gloss)

---------------------------------------------------------------- exclamation mark (cream, centred on x=11.5)
for y = 5, 9 do for x = 10, 13 do set(x, y, CREAM) end end      -- bar, 4 wide
for y = 10, 13 do for x = 11, 12 do set(x, y, CREAM) end end    -- bar tapers to 2 wide
set(11, 16, CREAM); set(12, 16, CREAM)                          -- dot 4 x 3, cut corners
for x = 10, 13 do set(x, 17, CREAM) end
set(11, 18, CREAM); set(12, 18, CREAM)
-- cr_shade 1 px on the right and bottom of the bar and dot
for y = 6, 9 do set(13, y, CR_SHADE) end
set(12, 13, CR_SHADE)
set(13, 17, CR_SHADE); set(12, 18, CR_SHADE)

save()
