-- hollowheart-tree (lean W2_6)
local NAME = "hollowheart-tree"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local function shade(c, m, R, ramp, amb, wrap)
  local n = X.pillow(m, R)
  local v = X.light(n, { amb = amb or 0.1, wrap = wrap or 0.25 })
  X.tone(c, m, v, ramp, { cuts = {.22,.4,.56,.72,.86} })
  return v, n
end
local c = HP.canvas{ w=64, h=64, scale=1, name=NAME }
local BARK = { "#2f1d2a", "#4e3033", "#704630", "#93603c", "#b78250", "#d9a96c" }
local LEAF = { "#1b3b3c", "#255644", "#32764b", "#4b9650", "#70b45a", "#a4d46c" }
local GLOW = { "#7a2c1c", "#c4561e", "#f08a28", "#ffc450", "#fff0a0", "#fffbd0" }
c:groundShadow(32, 58, 16, 2)
-- trunk: twisted, flared roots
local trunk = HP.mask()
for y = 24, 56 do
  local t = (y - 24) / 32
  local hw = 5.5 + 9 * max(0, t - 0.7)^1.3 * 3.2 + sin(t*5) * 0.8
  local cx = 31 + sin(t * 3.2) * 1.8
  for x = floor(cx - hw), floor(cx + hw) do trunk:set(x, y) end
end
local v = shade(c, trunk, 9, BARK, 0.12, 0.25)
trunk:each(function(x, y) if y > 28 and (x*3 + floor(y*0.7)) % 6 == 0 and X.hash(x,y,9) > 0.35 then c:px(x, y, BARK[2]) end end)
-- hollow heart: dark heart-shaped cavity with warm glow inside
local heart = HP.mask()
heart:add(c:ellipse(29, 39, 3, 3)):add(c:ellipse(35, 39, 3, 3)):add(c:poly{ {26,41}, {38,41}, {32,48} })
c:fillMask(heart, GLOW[1])
local inner = heart:copy():shrink(1)
c:fillMask(inner, GLOW[2])
inner:each(function(x, y) if y >= 40 then c:px(x, y, GLOW[3]) end end)
c:px(32, 44, GLOW[4]) c:px(32, 45, GLOW[5]) c:px(31, 44, GLOW[4]) c:px(33, 44, GLOW[4])
heart:edge():each(function(x, y) if y < 40 then c:px(x, y, BARK[1]) end end)
-- canopy: lumpy clusters of leaf blobs
local blobs = { {32,13,11,8}, {21,18,8,7}, {43,18,8,7}, {26,10,7,6}, {38,10,7,6}, {17,24,5,4}, {47,24,5,4}, {32,22,10,5} }
local can = HP.mask()
for _, b in ipairs(blobs) do can:add(c:ellipse(b[1], b[2], b[3], b[4])) end
shade(c, can, 11, LEAF, 0.08, 0.2)
can:each(function(x, y)
  local h = X.hash(x, y, 13)
  if h > 0.9 then c:px(x, y, LEAF[6]) elseif h < 0.08 and y > 14 then c:px(x, y, LEAF[1]) end
end)
-- branch hint where canopy meets trunk
c:px(30, 25, BARK[1]) c:px(33, 25, BARK[1])
-- quirk: a single glowing firefly-leaf drifting out of the hollow
c:px(44, 36, GLOW[5]) c:px(45, 36, GLOW[4]) c:px(44, 37, GLOW[3])
G.save(c, NAME)
