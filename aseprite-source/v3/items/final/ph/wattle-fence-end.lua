-- wattle-fence-end (lean W2_38)
-- Four hazel stakes with three woven withy rows (over/under), pointed tops of uneven height, last withy curls out.
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "wattle-fence-end" }
local abs, sin, min, max = math.abs, math.sin, math.min, math.max
local STAKE = { "#3d2a2c", "#5e3d36", "#845a43", "#aa7c55", "#cfa570", "#ecd0a0" }
local WITHY = { "#4a2e24", "#74442c", "#a06a3a", "#c98f50", "#e8b56a", "#f8d896" }
local SOIL  = { "#3a2a2e", "#5a4036", "#7a5a44" }
local tok = { r = { name = "wood" } }
c:groundShadow(33, 53, 21, 3)
c:fillMask(c:ellipse(33, 52, 20, 3), SOIL[2])
c:fillMask(c:ellipse(31, 51, 17, 2), SOIL[3])
local function tone(m, n, ramp, cuts) G.tone(c, m, X.light(n, { amb = 0.1, wrap = 0.25 }), ramp, cuts or { 0.2, 0.38, 0.55, 0.72, 0.87 }, nil, tok) end
local xs, tops = { 20, 29, 38, 47 }, { 13, 9, 15, 11 }
local rows = { 21, 30, 39 }
local function withy(x0, x1, y, hw, ph)
  local pts = {}
  for i = 0, 3 do local t = i / 3; pts[#pts + 1] = { x0 + (x1 - x0) * t, y + sin(t * 6.3 + ph) * 0.8 } end
  local m, n = G.tube(pts, function(t) return hw end)
  tone(m, n, WITHY)
  return m
end
for r, y in ipairs(rows) do withy(15, 52, y, 1.7, r) end
for i, x in ipairs(xs) do
  local m, n = G.tube({ { x, tops[i] }, { x, tops[i] + 14 }, { x, 40 }, { x, 52 } }, function(t) return t < 0.12 and 0.8 + t * 12 or 2.2 end)
  tone(m, n, STAKE)
  for y = tops[i] + 6, 50, 5 do if X.hash(x, y, 3) > 0.4 then c:px(x - 1 + (y % 2), y, STAKE[2]) end end  -- grain
end
-- over crossings
for r, y in ipairs(rows) do
  for i, x in ipairs(xs) do
    if (i + r) % 2 == 0 then
      local m, n = G.tube({ { x - 4, y }, { x - 1, y }, { x + 1, y }, { x + 4, y } }, function(t) return 1.7 end)
      tone(m, n, WITHY)
    end
  end
end
-- shadow under withies on stakes
for _, y in ipairs(rows) do for _, x in ipairs(xs) do c:px(x + 2, y + 2, STAKE[1]) end end
-- quirk: curled withy end + a sprouted leaf on a stake
G.line(c, { { 52, 30 }, { 54, 29 }, { 55, 27 }, { 54, 25 }, { 52, 25 } }, WITHY[4])
c:px(53, 30, WITHY[2]) c:px(52, 26, WITHY[5])
c:fillMask(c:ellipse(25, 8, 3, 1.5), "#5fa34f") c:px(23, 8, "#9ccd6c") c:px(26, 9, "#2f6a46")
for _, p in ipairs{ {12,52}, {14,51}, {50,52}, {53,51}, {33,53} } do c:px(p[1], p[2], "#5fa34f") c:px(p[1], p[2]-1, "#9ccd6c") end
G.fin(c, "wattle-fence-end")
