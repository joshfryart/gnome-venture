-- leech-slime (lean E2_02)
local NAME = "leech-slime"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local CUTS = { 0.22, 0.4, 0.56, 0.72, 0.86 }
local function shade(m, ramp, R, nm, o)
  o = o or {}
  local n = X.pillow(m, R or 4)
  local v = X.light(n, { amb = o.amb or 0.08, wrap = o.wrap or 0.25 })
  local idx = X.tone(c, m, v, ramp, { cuts = CUTS, tok = { r = { name = nm or "p" } } })
  return idx, n
end
local function px(x, y, col, nm) c:put(x, y, col, { r = { name = nm or "d" } }) end
local function spec(m, n, col)
  local x, y = G.specAt(m, n, 30)
  if x then px(x, y, col or "#fff4dc", "spec") end
end
c:groundShadow(32, 55, 24, 3)
local SL = { "#0f3a30", "#1a5c3c", "#2a8a48", "#4cb85c", "#86dc78", "#c8f4a8" }
local LE = { "#1c1a10", "#3a3a1c", "#585a2a", "#7c7c3a", "#a8a050", "#d0c070" }
local PK = { "#5a1428", "#8a2440", "#c04060", "#e07088", "#f4a0b0", "#ffd0d8" }
-- leech tail curling up behind
local tm, tn, TT = G.tube({ {40,32},{46,22},{54,24},{51,12} }, function(t) return 3.2 - 1.8 * t end)
local ti = X.tone(c, tm, X.light(tn, { amb = 0.08, wrap = 0.25 }), LE, { cuts = CUTS, tok = { r = { name = "tail" } } })
tm:each(function(x, y) local k = K(x, y) if floor(TT[k] * 9) % 2 == 1 then px(x, y, LE[max(1, (ti[k] or 3) - 1)], "seg") end end)
px(52, 12, LE[6], "tip")
-- slime body
local body = c:ellipse(32, 40, 23, 15); body:cut(c:rect(0, 52, 63, 63))
local idx, n = shade(body, SL, 12, "slime", { amb = 0.12, wrap = 0.3 })
-- gloss streaks
for _, p in ipairs{ {16,34},{17,33},{18,32},{19,31},{20,31} } do px(p[1], p[2], SL[6], "gl") end
for _, p in ipairs{ {14,38},{14,39} } do px(p[1], p[2], SL[5], "gl") end
-- eyes
for _, e in ipairs{ {23,33},{41,33} } do
  local m = c:ellipse(e[1], e[2], 4, 4)
  shade(m, { "#8a9a70", "#b4c098", "#d8e0b8", "#eef2d0", "#f6f8e4", "#ffffee" }, 3, "eye" .. e[1], { amb = 0.3 })
  px(e[1] + 1, e[2] + 1, "#1a1018", "pup"); px(e[1] + 2, e[2] + 1, "#1a1018", "pup"); px(e[1] + 1, e[2] + 2, "#1a1018", "pup"); px(e[1] + 2, e[2] + 2, "#1a1018", "pup")
  px(e[1], e[2] - 1, "#ffffee", "gl")
end
-- sucker mouth ring
local ring = c:ellipse(32, 45, 10, 7)
shade(ring, PK, 4, "ring")
local inn = c:ellipse(32, 45, 6, 4)
inn:each(function(x, y) px(x, y, "#2a0a16", "maw") end)
for a = 0, 11 do local ang = a * pi / 6
  px(floor(32 + cos(ang) * 6 + 0.5), floor(45 + sin(ang) * 4 + 0.5), "#f4ecd0", "tooth") end
px(32, 44, "#6a1a30", "y"); px(32, 45, "#6a1a30", "y"); px(31, 46, "#6a1a30", "y"); px(33, 46, "#6a1a30", "y")
-- slime drip
local dr = c:ellipse(11, 52, 2, 3); dr:add(c:rect(10, 49, 12, 51))
shade(dr, SL, 2, "drip")
G.save(c, NAME)
