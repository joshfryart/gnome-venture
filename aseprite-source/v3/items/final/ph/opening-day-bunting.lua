-- opening-day-bunting (lean W2_12)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "opening-day-bunting" }
local cuts = { 0.25, 0.5, 0.75 }
local RP = { "#5a3a1e", "#7d5429", "#a47838", "#c9a05a" }
local FL = {
  { "#7a1226", "#b8203a", "#e84a52", "#ff8a80" },
  { "#9a5a08", "#d98c10", "#f5bd2a", "#ffe27a" },
  { "#14597a", "#2a8fb0", "#52c6dc", "#a6ecf0" },
  { "#8a2a6a", "#cc4c94", "#ef7fb4", "#ffbcd8" },
  { "#1f5a2a", "#37913c", "#6cc556", "#b6ee8a" },
}
-- rope: sagging swag, posts at both ends
local function ry(x) return 26 - 12 * (((x - 32) / 25) ^ 2) end
local pts = {}
for x = 7, 57 do pts[#pts + 1] = { x, floor(ry(x) + 0.5) } end
local function ropeY(x) return floor(ry(x) + 0.5) end
-- flags
local xs = { 11, 19, 27, 35, 43 }
local shapes = { 1, 2, 3, 1, 2 }
for i, x0 in ipairs(xs) do
  local top = ropeY(x0 + 3) + 1
  local len = ({ 20, 15, 22, 16, 19 })[i]
  local m = HP.mask()
  local shape = shapes[i]
  for y = top, top + len do
    local t = (y - top) / len
    local h
    if shape == 1 then h = 4 * (1 - t)               -- pennant point
    elseif shape == 2 then h = 4 * (1 - t * 0.5)     -- swallowtail
    else h = 4 * (1 - t ^ 2) end                     -- rounded drop
    for x = floor(x0 + 3 - h + 0.5), floor(x0 + 3 + h - 0.5) do m:set(x, y) end
    if shape == 2 and t > 0.7 then for x = x0 + 2, x0 + 4 do m:cut(HP.mask():add(c:rect(x, y, x, y))) end end
  end
  local n = X.pillow(m, 4)
  G.tone(c, m, X.light(n, { amb = 0.15, wrap = 0.3 }), FL[i], cuts)
  -- hem stripe / motif per flag
  if i == 1 then c:px(x0 + 3, top + 6, FL[i][4]) c:px(x0 + 2, top + 7, FL[i][4]) c:px(x0 + 4, top + 7, FL[i][4]) c:px(x0 + 3, top + 8, FL[i][4])
  elseif i == 2 then for k = 0, 2 do c:px(x0 + 1 + k * 2, top + 4, FL[i][1]) end
  elseif i == 3 then G.line(c, { {x0 + 1, top + 5}, {x0 + 5, top + 5} }, FL[i][4]) G.line(c, { {x0 + 2, top + 9}, {x0 + 4, top + 9} }, FL[i][1])
  elseif i == 4 then c:px(x0 + 2, top + 5, FL[i][4]) c:px(x0 + 4, top + 7, FL[i][4]) c:px(x0 + 3, top + 9, FL[i][1])
  else c:px(x0 + 3, top + 4, FL[i][4]) c:px(x0 + 3, top + 6, FL[i][4]) end
  -- tiny peg
  c:px(x0 + 3, top - 1, RP[1])
end
-- rope drawn after (over flag tops), twisted
for i, p in ipairs(pts) do
  c:px(p[1], p[2], (i % 3 == 0) and RP[4] or RP[3])
  c:px(p[1], p[2] + 1, (i % 3 == 1) and RP[1] or RP[2])
end
-- end posts: knotted twig stubs with leaf (quirk: a little tied bow on left, twig sprout right)
G.line(c, { {7, 14}, {6, 12}, {5, 10} }, RP[2]) G.line(c, { {8, 14}, {7, 12} }, RP[1])
G.line(c, { {57, 14}, {58, 12}, {59, 10} }, RP[2]) G.line(c, { {56, 14}, {57, 12} }, RP[1])
c:px(59, 9, "#6cc556") c:px(60, 9, "#37913c") c:px(60, 10, "#37913c")
c:px(5, 9, "#ff8a80") c:px(4, 10, "#e84a52") c:px(6, 10, "#e84a52")
G.fin(c, "opening-day-bunting")
