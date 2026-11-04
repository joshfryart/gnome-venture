-- stone-wall-gate (lean D2o_14)
-- Front-on stone gateway: two tall pillars joined by a stone lintel over a plank gate with iron strap hinges and a ring handle; a lantern-less little bell hangs from the lintel (quirk).
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "stone-wall-gate" }
local floor, min, max = math.floor, math.min, math.max
local COOL = { "#3d3650", "#5b546e", "#7d7690", "#a09ab0", "#c4bfd0", "#e6e2ee" }
local WARM = { "#443a3a", "#655858", "#887878", "#ab9c96", "#cfc2ba", "#ece2dc" }
local WOOD = { "#3a2216", "#5c3a22", "#7e5230", "#a06c3e", "#c48e54", "#e0b274" }
local IRON = { "#25252f", "#3c3c4c", "#5c5c72", "#8a8aa2", "#b8b8cc", "#e4e4f0" }
local MOSS = { "#2c4a30", "#3f6a3a", "#5c8c46", "#86b25a" }
local MORT = "#40354f"
local function clamp(i) return max(1, min(6, i)) end
local function blk(x0, y0, x1, y1, shift, seed)
  local R = X.hash(x0, y0, seed) > 0.5 and COOL or WARM
  local w, h = x1 - x0, y1 - y0
  for y = y0, y1 do for x = x0, x1 do
    local u, v = x - x0, y - y0
    local skip = (w > 3 and h > 2) and ((u == 0 or u == w) and (v == 0 or v == h))
    if not skip then
      local i = 3
      if v == 0 then i = 5 elseif u == 0 then i = 4 elseif v == h then i = 1 elseif u == w then i = 2 end
      local hs = X.hash(x, y, seed + 7)
      if i == 3 then if hs > 0.88 then i = 4 elseif hs < 0.1 then i = 2 end end
      if u == 1 and v == 1 and w > 4 and X.hash(x0, y0, seed + 3) > 0.55 then i = 6 end
      c:px(x, y, R[clamp(i + shift)])
    end
  end end
end
local function courses(x0, y0, x1, y1, ch, seed, shift, wmin, wmax)
  c:fillMask(c:rect(x0, y0, x1, y1), MORT)
  local y, r = y0, 0
  while y <= y1 do
    local yb = y + ch - 2
    if y1 - y < ch then yb = y1 end
    local x = x0 - ((r % 2 == 1) and floor(wmax / 2) or 0)
    while x <= x1 do
      local w = wmin + floor(X.hash(x, y, seed) * (wmax - wmin + 1))
      local bx1 = x + w - 2
      if bx1 >= x1 - 1 then bx1 = x1 end
      local bx0 = max(x, x0)
      if bx1 - bx0 >= 2 then blk(bx0, y, bx1, yb, shift, seed + r) end
      x = x + w
      if bx1 == x1 then break end
    end
    y = y + ch - 1 + 1 - 0 ; r = r + 1
    if yb == y1 then break end
  end
end
-- horizontal wall arm seen 3/4: top face (10 deep) + front face (11 high), base at B
local function harm(x0, x1, B)
  courses(x0, B - 20, x1, B - 11, 4, 11, 2, 3, 5)
  courses(x0, B - 10, x1, B, 5, 21, 0, 4, 7)
  for x = x0, x1 do c:px(x, B - 10, MORT) end
end
local function pillar(x0, B, w, H)
  local x1 = x0 + w - 1
  courses(x0, B - H + 1, x1, B, 5, 31, 0, 4, 6)
  c:fillMask(c:rect(x0, B - H - 9, x1, B - H), MORT)
  blk(x0, B - H - 9, x1, B - H, 2, 41)
  blk(x0 + 2, B - H - 7, x1 - 2, B - H - 2, 1, 43)
  for x = x0, x1 do c:px(x, B - H + 1, COOL[1]) end
end
local function varm(cx, y0, y1) -- top face strip (8 wide), no front
  courses(cx - 4, y0, cx + 3, y1, 4, 51, 2, 3, 5)
end
local function sarm(cx, B, ey) -- toward viewer: top face then end front
  varm(cx, B - 10, ey - 11)
  courses(cx - 4, ey - 10, cx + 3, ey, 5, 61, 0, 3, 5)
  for x = cx - 4, cx + 3 do c:px(x, ey - 10, MORT) end
end
local function tuft(x, y)
  c:px(x, y, MOSS[2]) c:px(x - 1, y - 1, MOSS[3]) c:px(x + 1, y - 1, MOSS[3]) c:px(x, y - 1, MOSS[2]) c:px(x, y - 2, MOSS[4])
end
local function flower(x, y, col)
  c:px(x, y, MOSS[2]) c:px(x, y - 1, MOSS[3])
  c:px(x, y - 3, "#ffe27a")
  c:px(x - 1, y - 3, col) c:px(x + 1, y - 3, col) c:px(x, y - 4, col) c:px(x, y - 2, col)
end
local function moss(x0, y0, x1, y1, seed)
  for y = y0, y1 do for x = x0, x1 do
    if X.hash(x, y, seed) > 0.45 then c:px(x, y, MOSS[1 + floor(X.hash(x, y, seed + 1) * 4) % 4]) end
  end end
end

c:groundShadow(32, 50, 28, 3)
local B = 50
-- gate planks
for x = 20, 43 do
  local pl = floor((x - 20) / 4)
  for y = 24, B do
    local i = 3
    if (x - 20) % 4 == 0 then i = 4 elseif (x - 20) % 4 == 3 then i = 2 end
    if X.hash(x, y, 77 + pl) > 0.9 then i = i - 1 end
    if y > B - 2 then i = 1 end
    c:px(x, y, WOOD[clamp(i)])
  end
end
for x = 20, 43 do for _, y in ipairs{ 29, 41 } do
  c:px(x, y, WOOD[5]) c:px(x, y + 1, WOOD[4]) c:px(x, y + 2, WOOD[2]) c:px(x, y + 3, WOOD[1])
end end
-- iron straps and hinges
for x = 20, 33 do for _, y in ipairs{ 30, 42 } do c:px(x, y, IRON[4]) c:px(x, y + 1, IRON[2]) end end
for _, y in ipairs{ 30, 42 } do c:px(21, y - 1, IRON[5]) c:px(21, y, IRON[6]) c:px(22, y, IRON[3]) c:px(21, y + 2, IRON[1]) end
-- ring handle
c:px(40, 36, IRON[5]) c:px(41, 36, IRON[4]) c:px(40, 37, IRON[3]) c:px(42, 37, IRON[3]) c:px(40, 38, IRON[4]) c:px(41, 39, IRON[2]) c:px(42, 38, IRON[2])
-- seam and shadow under lintel
for y = 24, B do c:px(31, y, WOOD[1]) c:px(32, y, WOOD[2]) end
for x = 20, 43 do c:px(x, 24, WOOD[1]) c:px(x, 25, WOOD[2]) end
-- lintel
courses(20, 16, 43, 23, 4, 81, 0, 4, 6)
courses(20, 10, 43, 15, 3, 83, 2, 4, 6)
-- pillars
pillar(8, B, 12, 32)
pillar(44, B, 12, 32)
-- stone sill
courses(20, B + 1, 43, B + 2, 3, 85, 0, 5, 7)
-- bell quirk
c:px(32, 24, IRON[2]) c:px(32, 25, IRON[3]) c:px(31, 26, "#e8b840") c:px(32, 26, "#ffe27a") c:px(33, 26, "#b8862a") c:px(32, 27, "#7a5418")
tuft(14, 22)
G.fin(c, "stone-wall-gate")
