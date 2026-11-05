-- stone-wall-tee (lean P1b_O15)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local H = X.hash
local NAME = "stone-wall-tee"
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local ST = { "#443a52", "#61546d", "#807085", "#a08f98", "#c3b3ae", "#e6d8cc" }
local MORT = "#32283d"
local MOSS = { "#1f3b2c", "#2f5a34", "#4b8040", "#76a84c", "#a6cc66" }
c:groundShadow(32, 55, 26, 3)
local bar = c:rect(6, 14, 57, 31)
local stem = c:rect(21, 32, 42, 52)
local shape = bar:copy():add(stem)
-- courses: {ya, yb, offset, seed}
local courses = { {14,22,0,1}, {23,31,7,2}, {32,39,3,3}, {40,46,9,4}, {47,52,5,5} }
for _, cr in ipairs(courses) do
  local ya, yb, off, sd = cr[1], cr[2], cr[3], cr[4]
  local xs, x = {}, 6 - off
  while x < 60 do xs[#xs + 1] = x x = x + 11 + floor(H(x, ya, sd) * 6) end
  xs[#xs + 1] = x
  for i = 1, #xs - 1 do
    local bx0, bx1 = xs[i] + 1, xs[i + 1] - 1
    local base = 3 + floor(H(i, sd, 7) * 2.2)
    for y = ya, yb do for xx = bx0 - 1, bx1 do
      if shape:has(xx, y) then
        local idx
        if y == yb or xx == bx0 - 1 then idx = 0
        elseif y == ya then idx = 6
        elseif y == ya + 1 then idx = 5
        elseif xx == bx0 then idx = base + 1
        elseif xx == bx1 or y == yb - 1 then idx = base - 1
        else idx = base; local h = H(xx, y, 9) if h > 0.9 then idx = base + 1 elseif h < 0.08 then idx = base - 1 end end
        if idx >= 1 and y >= 32 and y <= 34 then idx = idx - (35 - y > 2 and 2 or 1) end
        if idx >= 1 and xx >= 36 and y >= 32 then idx = idx - 1 end
        if idx == 0 then c:put(xx, y, MORT) else c:put(xx, y, ST[max(1, min(6, idx))]) end
      end
    end end
  end
end
-- right-end shading of the bar
for y = 14, 31 do c:put(57, y, ST[2]) c:put(56, y, ST[3]) end
-- cracks / chips
for _, p in ipairs{ {16,18},{17,19},{42,26},{43,27},{44,27},{30,36},{31,37},{27,43} } do c:put(p[1], p[2], ST[1]) end
-- moss tufts on top
local function tuft(x0, x1, h, seed)
  local n = x1 - x0 + 1
  for x = x0, x1 do
    local hh = max(1, floor(h * sin(pi * (x - x0 + 0.5) / n) + H(x, 1, seed) * 1.2 + 0.3))
    for dy = 0, hh do
      local y = 14 - dy
      local i = (dy == hh) and 5 or (dy >= hh - 1 and 4 or 3)
      c:put(x, y, MOSS[i])
    end
    c:put(x, 15, MOSS[2]) if H(x, 2, seed) > 0.5 then c:put(x, 16, MOSS[3]) end
  end
end
tuft(11, 17, 3, 1) tuft(29, 36, 4, 2) tuft(49, 54, 3, 3)
-- moss creeping in crevices
for _, p in ipairs{ {22,50},{23,50},{24,51},{22,51},{23,51},{22,52},{23,52},{24,52},{25,52},{40,52},{41,52},{41,51},{8,31},{9,31},{10,31},{9,30},{46,23},{47,23},{47,22},{26,39},{27,39},{27,38} } do
  c:put(p[1], p[2], MOSS[H(p[1], p[2], 3) > 0.5 and 3 or 2])
end
c:put(22, 49, MOSS[4]) c:put(41, 50, MOSS[4])
-- quirk: tiny pink flower on the tallest tuft
c:put(33, 10, MOSS[3]) c:put(33, 11, MOSS[3])
c:put(33, 8, "#ffffff" == "" and "" or "#f5a3c0") c:put(32, 9, "#f5a3c0") c:put(34, 9, "#e0709f") c:put(33, 10, "#e0709f")
c:put(33, 9, "#ffd966") c:put(32, 8, "#ffd0e0")
G.save(c, NAME)
