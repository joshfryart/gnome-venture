-- trek-me (family 6, marker, 38x40): the player. Gnome head with a tall bent red hat on a cream disc in a
-- gold ring, standing on its own stepped umber2 ground shadow (the only marker with a shadow).
local ROOT = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(ROOT .. "gvlib/gvlib.lua")
local NAME, W, H = "trek-me", 38, 40

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
local function spans(rows) -- rows = { {y, x0, x1}, ... } -> mask, row table
  local m, r = {}, {}
  for _, s in ipairs(rows) do
    r[s[1]] = { s[2], s[3] }
    for x = s[2], s[3] do m[key(x, s[1])] = true end
  end
  return m, r
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
local GD = { gloss = "#fff1c8", rim = "#f5cf6a", base = "#e8a317", shade = "#b8661a" }
local THREAD = "#f5cf6a"
local CREAM, CR_SHADE, CR_GLOSS = "#f4f0e0", "#cfc3a2", "#fff3c8"
local RD = { gloss = "#ff9158", rim = "#f2793a", base = "#dd3a2a", shade = "#ae2a2a", deep = "#6b1b2c" }
local SK = { rim = "#f9d49c", base = "#e9b98a", bounce = "#d9885a", shade = "#c47a52" }

---------------------------------------------------------------- 1. ground shadow (bottom layer, flat umber2)
for _, r in ipairs({ {32, 14, 23}, {33, 10, 27}, {34, 8, 29}, {35, 7, 30}, {36, 7, 30}, {37, 8, 29}, {38, 10, 27}, {39, 14, 23} }) do
  for x = r[2], r[3] do set(x, r[1], U2) end
end

---------------------------------------------------------------- 2. disc: outline, 2 px gold ring, cream
local cx, cy = 18.5, 16.5
local function s(x, y) return (x - cx) + (y - cy) end
local disc = mdisc(cx, cy, 17)          -- x2..35, y0..33
local outline = edge(disc)
local inner = mdisc(cx, cy, 14)         -- cream interior
for k in pairs(disc) do
  local x, y = k % W, k // W
  local sv = s(x, y)
  if outline[k] then
    set(x, y, sv < -8 and U1 or (sv > 8 and U3 or U2))
  elseif inner[k] then
    set(x, y, CREAM)
  else
    local outer = adj4(outline, x, y)
    local h
    if outer then h = sv < -6 and GD.rim or (sv > 6 and GD.shade or GD.base)
    else h = sv > 13 and GD.shade or GD.base end
    set(x, y, h)
  end
end
for k in pairs(edge(inner)) do          -- 1 px cr_shade on the lower-right edge of the cream
  local x, y = k % W, k // W
  if s(x, y) >= 7 then set(x, y, CR_SHADE) end
end
for _, p in ipairs({ {7, 6}, {8, 5}, {6, 7} }) do set(p[1], p[2], GD.gloss) end -- gloss comma on the ring

---------------------------------------------------------------- 3. hat (bent tip), rd ramp, umber outline
local hat, hr = spans({ {3, 24, 25}, {4, 24, 25}, {5, 21, 24}, {6, 20, 25}, {7, 19, 25}, {8, 18, 26}, {9, 17, 26},
  {10, 16, 27}, {11, 15, 27}, {12, 14, 28}, {13, 13, 28}, {14, 12, 28}, {15, 9, 28}, {16, 9, 28} })
for k in pairs(hat) do
  local x, y = k % W, k // W
  local r = hr[y]
  local h = RD.base
  if x == r[1] then h = RD.rim end
  if x >= r[2] - 1 then h = RD.shade end
  if y == 16 then h = RD.deep end
  set(x, y, h)
end
-- outline: umber1 on the left and top, umber3 on the right; the brim's deep row is its bottom edge
for y = 1, 16 do for x = 0, W - 1 do
  if not hat[key(x, y)] and adj4(hat, x, y) and not (y >= 17) then
    local r = hr[y]
    local right = r and x > r[2] or (not r and x >= 24)
    if not r and y < 3 then right = false end
    -- pixels above a row (row y+1 exists) right of this row's end belong to the right side
    if r and x > r[2] then right = true elseif r and x < r[1] then right = false
    elseif not r then right = false end
    set(x, y, right and U3 or U1)
  end
end end
-- gloss: 1 px comma just inside the lit left edge of the cone
set(18, 9, RD.gloss); set(17, 10, RD.gloss); set(16, 11, RD.gloss)
-- brim stitch: hat-to-head join, thread 2 on / 1 off along y=15, x11..26
for x = 11, 26 do if ((x - 11) % 3) < 2 then set(x, 15, THREAD) end end

---------------------------------------------------------------- 4. head (14 x 8 oval, x12..25 y17..24)
local head, hd = spans({ {17, 14, 23}, {18, 13, 24}, {19, 12, 25}, {20, 12, 25}, {21, 12, 25}, {22, 12, 25},
  {23, 13, 24}, {24, 14, 23} })
for k in pairs(head) do
  local x, y = k % W, k // W
  local r = hd[y]
  local h = SK.base
  if (x == r[1] and y <= 21) or (y == 17 and x <= 18) then h = SK.rim end
  if (x >= r[2] - 1 and y >= 20) or (y >= 23 and x >= 19) then h = SK.shade end
  set(x, y, h)
end
for _, p in ipairs({ {18, 20}, {19, 20}, {18, 21}, {19, 21} }) do set(p[1], p[2], SK.bounce) end -- nose
-- pale-rule side outline (umber2) so the light face separates from the cream disc; the brim caps it
for y = 17, 23 do local r = hd[y]; set(r[1] - 1, y, U2); set(r[2] + 1, y, U2) end
-- eyes, small version: 3x3 cream disc with cut corners, 2x2 umber3 pupil, 1 px cream glint
local function eye(x, y)
  set(x + 1, y, CREAM); set(x, y + 1, CREAM); set(x + 1, y + 1, CREAM); set(x + 2, y + 1, CREAM); set(x + 1, y + 2, CREAM)
  set(x + 1, y + 1, U3); set(x + 2, y + 1, U3); set(x + 1, y + 2, U3); set(x + 2, y + 2, U3)
  set(x + 1, y + 1, CREAM) -- glint on the pupil's upper-left
end
eye(14, 18); eye(21, 18)

---------------------------------------------------------------- 5. beard (pale rule: cream with umber2 outline)
local brows = {}
for y = 24, 31 do
  local l = 12 + math.floor((y - 24) * 5 / 7 + 0.5)
  brows[#brows + 1] = { y, l, 37 - l }
end
local beard, bd = spans(brows)
for k in pairs(beard) do
  local x, y = k % W, k // W
  local r = bd[y]
  local isEdge = not (has(beard, x - 1, y) or has(head, x - 1, y)) or not (has(beard, x + 1, y) or has(head, x + 1, y))
    or not (has(beard, x, y + 1)) or not (has(beard, x, y - 1) or has(head, x, y - 1))
  if isEdge then set(x, y, U2)
  elseif x >= r[2] - 2 then set(x, y, CR_SHADE)
  else set(x, y, CREAM) end
end
set(14, 26, CR_GLOSS)

save()
