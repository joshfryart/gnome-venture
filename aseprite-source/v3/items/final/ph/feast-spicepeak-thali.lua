-- feast-spicepeak-thali (lean W2_3)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local function T(c, m, R, ramp, amb) local n = X.pillow(m, R) local v = X.light(n, {amb = amb or 0.1, wrap = 0.25}) X.tone(c, m, v, ramp, {cuts = {.22,.4,.56,.72,.86}}) return n, v end
local NAME = "feast-spicepeak-thali"
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local STEEL = { "#4d4f78", "#6f77a3", "#97a3c6", "#bfcbe0", "#e2eaf4", "#fbfdff" }
local RICE = { "#b9803f", "#d9a24e", "#efc466", "#f8dc88", "#fdeeb0", "#fffbe0" }
local CURRY = { "#6e2a1e", "#9a3b22", "#c75a2a", "#e5822f", "#f3a94a", "#fbd27a" }
local GREEN = { "#1f4a35", "#2f6e44", "#47934f", "#6fb85a", "#9bd36e", "#c6ec94" }
local RED = { "#6b1420", "#9c1f2a", "#cc3030", "#ea5a3a", "#f78b5a", "#ffc08a" }
c:groundShadow(32, 52, 24, 4)
local plate = c:ellipse(32, 41, 24, 12)
T(c, plate, 14, STEEL)
local well = c:ellipse(32, 42, 19, 8.5)
T(c, well, 10, { STEEL[2], STEEL[3], STEEL[4], STEEL[5], STEEL[5], STEEL[6] }, 0.3)
-- three katori bowls (back row) with curry
local function bowl(cx, cy, rx, ry, ramp)
  local body = c:ellipse(cx, cy + 2, rx, ry + 1)
  T(c, body, 5, STEEL)
  local top = c:ellipse(cx, cy, rx - 1, ry)
  T(c, top, 4, ramp, 0.2)
  c:px(cx - 2, cy - 1, ramp[6]) c:px(cx - 1, cy - 1, ramp[5])
end
bowl(17, 38, 6, 3, CURRY)
bowl(47, 38, 6, 3, GREEN)
bowl(32, 33, 5, 2.5, RED)
-- naan wedge front-left
local naan = c:poly{{13,46},{24,43},{27,48},{19,51}}
T(c, naan, 4, RICE, 0.2)
c:px(18, 46, RICE[1]) c:px(22, 47, RICE[1]) c:px(20, 49, RICE[1])
-- rice cone (spicepeak)
local cone = HP.mask()
for y = 20, 47 do local t = (y - 20) / 27 local h = 1 + t * 10.5 for x = floor(34 - h), floor(34 + h) do cone:set(x, y) end end
cone:add(c:ellipse(34, 46, 11.5, 3.5))
local n = X.pillow(cone, 8)
local v = X.light(n, {amb = 0.08, wrap = 0.25})
X.tone(c, cone, v, RICE, {cuts = {.2,.38,.54,.7,.86}})
cone:each(function(x, y) if X.hash(x, y, 3) > 0.9 and v[K(x, y)] > 0.4 then c:px(x, y, RICE[6]) elseif X.hash(x, y, 8) > 0.93 then c:px(x, y, RICE[1]) end end)
-- red spice drizzle bands down the cone
for _, s in ipairs{{30,30},{37,34},{33,40}} do c:px(s[1], s[2], RED[3]) c:px(s[1]+1, s[2], RED[2]) c:px(s[1]+1, s[2]+1, RED[4]) end
-- chili on the peak (quirk: curled tip)
local ch = G.tube({{34,21},{35,16},{33,12},{35,8}}, function(t) return 2.0 * (1 - t) + 0.6 end)
local cm, cn = ch
T(c, cm, 2.2, RED)
c:px(34, 14, RED[6]) c:px(35, 21, GREEN[3]) c:px(34, 22, GREEN[2]) c:px(33, 21, GREEN[4])
c:sparkle(14, 36)
G.save(c, NAME)
