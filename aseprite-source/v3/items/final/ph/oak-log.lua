-- oak-log (lean P1b_O5)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c
local function gline(cc, pts, col, w) cc:fillMask(cc:line(pts, w or 1), col) end
local function solid(m, rp, R, o) local n = X.pillow(m, R) local _, v = G.toneN(c, m, n, rp, o) return n, v end
local function cylN(m, cx, cy, r, horiz) local n = {} m:each(function(x, y) local t = horiz and (y - cy) / r or (x - cx) / r t = max(-0.97, min(0.97, t)) if horiz then n[K(x, y)] = { -0.35, t, sqrt(1 - t*t) } else n[K(x, y)] = { t, -0.35, sqrt(1 - t*t) } end end) return n end
local NAME = "nav-tasks"
c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local WOOD = { "#4a2a1c", "#6e4126", "#96602f", "#bc8240", "#dba856", "#f2cf80" }
local NAME = "oak-log"
c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local BARK = { "#2c1a14", "#4a2e20", "#6e4a30", "#8e6640", "#b08856", "#d0aa74" }
local WOOD = { "#a87a42", "#c8985a", "#e0b878", "#f0d098", "#fae4b4", "#fff4d4" }
local RING = "#8a5a2c"
local LEAF = { "#1b3b2c", "#27603a", "#3a8444", "#58a84c", "#86c862", "#b4e282" }
local MOSS = { "#1e4a30", "#2e7040", "#4c9c4c", "#8ac862" }
c:groundShadow(33, 53, 21, 3)
local cy, r = 38, 13
local body = c:rect(16, cy - r, 47, cy + r)
body:add(c:ellipse(47, cy, 5, r))
local n = cylN(body, 0, cy, r, true)
local _, v = G.toneN(c, body, n, BARK, { amb = 0.1 })
-- furrows along the length
for i = 0, 7 do
  local y = cy - r + 2 + i * 3 + floor(X.hash(i, 1, 4) * 2)
  local x = 20 + floor(X.hash(i, 2, 4) * 6)
  local len = 10 + floor(X.hash(i, 3, 4) * 14)
  for xx = x, x + len do local yy = y + floor(sin(xx * 0.3 + i) * 0.9 + 0.5) if body:has(xx, yy) then c:px(xx, yy, BARK[1]) if X.hash(xx, yy, 6) > 0.5 then c:px(xx, yy + 1, BARK[2]) end end end
  c:px(x + 1, y - 1, BARK[5])
end
-- lit highlight streak on upper bark
for x = 22, 42 do if X.hash(x, 0, 9) > 0.35 then c:px(x, cy - r + 3, BARK[6]) end end
-- cut end face (left)
local face = c:ellipse(16, cy, 6, r)
c:fillMask(face, WOOD[3])
local fn = X.pillow(face, 14)
face:each(function(x, y)
  local d = sqrt(((x - 16) / 6) ^ 2 + ((y - cy) / r) ^ 2)
  local col = (d < 0.2) and WOOD[1] or WOOD[3]
  if (floor(d * 5 + 0.3) % 2 == 0) and d > 0.25 then col = WOOD[2] end
  if d > 0.88 then col = BARK[3] end
  c:px(x, y, col)
end)
gline(c, {{16,cy},{15,cy},{14,cy-1}}, RING)
for _, p in ipairs{ {13,cy-6},{12,cy-2},{12,cy+3},{13,cy+7},{15,cy-8},{18,cy+8} } do c:px(p[1], p[2], RING) end
c:px(19, cy - 4, WOOD[6]) c:px(18, cy - 5, WOOD[5]) c:px(14, cy + 4, WOOD[2])
-- crack on face
gline(c, {{16,cy},{19,cy+2},{21,cy+5}}, "#6a4020")
-- moss patch on top right
for _, p in ipairs{ {34,cy-r},{35,cy-r},{36,cy-r},{37,cy-r},{38,cy-r},{35,cy-r+1},{36,cy-r+1},{37,cy-r+1},{33,cy-r+1},{36,cy-r+2},{39,cy-r+1} } do c:px(p[1], p[2], MOSS[2]) end
c:px(35, cy-r, MOSS[4]) c:px(36, cy-r, MOSS[3]) c:px(37, cy-r+1, MOSS[3]) c:px(36, cy-r+2, MOSS[1])
-- quirk: tiny oak sprout from the top with lobed leaves
gline(c, {{41,cy-r},{41,cy-r-4},{42,cy-r-7}}, LEAF[2])
c:px(42, cy-r-4, LEAF[4])
local function lobe(cx, cyy) c:fillMask(c:ellipse(cx, cyy, 3, 2), LEAF[3]) c:px(cx-2, cyy-1, LEAF[5]) c:px(cx-1, cyy-1, LEAF[5]) c:px(cx+2, cyy+1, LEAF[1]) c:px(cx, cyy-2, LEAF[4]) c:px(cx+1, cyy+2, LEAF[2]) end
lobe(38, cy - r - 8) lobe(46, cy - r - 9)
c:px(42, cy-r-8, LEAF[2]) c:px(42, cy-r-9, LEAF[3])
G.save(c, NAME)
