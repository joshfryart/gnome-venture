-- tile-brick-path (lean D3o_2)
-- Seamless basket-weave brick path: 16px blocks alternate flat pairs and upright pairs, dusty terracotta and plum bricks, grey lime mortar with moss. Quirk: one brick stamped with a tiny sun.
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "tile-brick-path" }
local floor = math.floor
local MORT = { "#7d7a82", "#a29ea0", "#c4bfba" }
local PALS = {
  { "#7e3430", "#a24a3c", "#c46a48", "#e0905c" },
  { "#6a2c3c", "#8c4050", "#ae5a5e", "#cc7c72" },
  { "#8a4228", "#b0603a", "#cf8250", "#e8a468" },
}
for y = 0, 63 do for x = 0, 63 do c:put(x, y, MORT[(X.hash(x, y, 5) > 0.75) and 3 or 2]) end end
local function brick(x0, y0, w, h, id)
  local pal = PALS[1 + floor(X.hash(id, 1, 77) * 2.999)]
  for dy = 0, h - 1 do for dx = 0, w - 1 do
    local i = 3
    if dy == 0 or dx == 0 then i = 4 end
    if dy == h - 1 or dx == w - 1 then i = 1 end
    if (dy == 0 and dx == w - 1) or (dx == 0 and dy == h - 1) then i = 2 end
    if i == 3 then
      local hh = X.hash(x0 + dx, y0 + dy, id)
      if hh > 0.88 then i = 2 elseif hh < 0.07 then i = 4 end
    end
    c:put((x0 + dx) % 64, (y0 + dy) % 64, pal[i])
  end end
end
local id = 0
for by = 0, 3 do for bx = 0, 3 do
  local x0, y0 = bx * 16, by * 16
  id = id + 1
  if (bx + by) % 2 == 0 then
    brick(x0 + 1, y0 + 1, 14, 6, id) brick(x0 + 1, y0 + 9, 14, 6, id + 50)
  else
    brick(x0 + 1, y0 + 1, 6, 14, id) brick(x0 + 9, y0 + 1, 6, 14, id + 50)
  end
end end
-- hairline cracks and moss in mortar
for _, p in ipairs{ {16,8},{16,9},{48,24},{48,25},{32,40},{32,41},{0,56},{1,56},{24,16},{25,16},{40,48},{41,48} } do c:put(p[1], p[2], MORT[1]) end
for _, p in ipairs{ {16,40},{16,41},{40,16},{39,16},{56,32},{8,24} } do c:put(p[1], p[2], "#5e8a4a") c:put(p[1] + 1, p[2], "#7fae5a") end
c:put(20, 51, "#3c1c24") c:put(21, 52, "#3c1c24")
-- sun stamp quirk on one flat brick (x 17..30, y 1..6)
local sx, sy = 24, 4
c:put(sx, sy, "#f2c46a") c:put(sx - 1, sy, "#e0a248") c:put(sx + 1, sy, "#e0a248") c:put(sx, sy - 1, "#e0a248") c:put(sx, sy + 1, "#e0a248")
c:put(sx - 2, sy - 1, "#c88a3c") c:put(sx + 2, sy + 1, "#c88a3c") c:put(sx + 2, sy - 1, "#c88a3c") c:put(sx - 2, sy + 1, "#c88a3c")
c:finish{ outline = false }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = G.out .. "tile-brick-path.aseprite", png = G.out .. "tile-brick-path.png", scale = 1 }
