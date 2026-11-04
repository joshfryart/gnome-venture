-- stone-wall-straight (lean W2_30)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "stone-wall-straight" }
local floor, abs = math.floor, math.abs
local S = { "#2e2940", "#4a4562", "#6a6483", "#8d86a0", "#b3acb8", "#d6cdc8" }
local WARM = { "#5b4a58", "#7d6a6c", "#a08a82", "#c5ae9c" }
local function px(x, y, col) if x >= 0 and x < 64 and y >= 0 and y < 64 then c:px(x, y, col) end end
-- masonry block: courses of 5px, staggered joints, per-brick tone + bevel
local function masonry(x0, y0, x1, y1, seed)
  for y = y0, y1 do for x = x0, x1 do px(x, y, S[1]) end end
  local row, y = 0, y0
  while y <= y1 do
    local h = math.min(4, y1 - y)
    local x = x0 - ((row * 3 + seed) % 5)
    while x <= x1 do
      local w = 6 + floor(X.hash(x, y, seed) * 5)
      local r = X.hash(x + 7, y + 3, seed + 1)
      local base = r < 0.25 and 3 or (r < 0.8 and 2 or 4)
      local warm = r > 0.86
      for yy = 0, h - 1 do for xx = 0, w - 2 do
        local X1, Y1 = x + xx, y + yy
        if X1 >= x0 and X1 <= x1 and Y1 <= y1 then
          local t = base
          if yy == 0 then t = t + 1 elseif yy == h - 1 and h > 2 then t = t - 1 end
          if xx == 0 then t = math.max(t, base + 1) end
          if xx == w - 2 then t = t - 1 end
          t = math.max(2, math.min(6, t))
          px(X1, Y1, warm and WARM[math.min(4, t - 1)] or S[t - 0 > 6 and 6 or t])
        end
      end end
      x = x + w
    end
    y = y + h + 1; row = row + 1
  end
end
local function capstone(x0, y0, x1, y1)
  for y = y0, y1 do for x = x0, x1 do
    local t = 5
    if y == y0 then t = 6 elseif y == y1 then t = 3 elseif y == y1 - 1 then t = 4 end
    if x == x1 then t = t - 1 end
    px(x, y, S[t])
  end end
  px(x0 + 2, y0 + 1, S[6]) px(x0 + 3, y0 + 2, S[4]) px(x1 - 3, y0 + 2, S[4])
end
local function moss(x, y, n) for i = 0, n - 1 do px(x + i, y, "#5f9a4c") px(x + i, y - 1 + (i % 2), "#8fc462") end px(x, y, "#3d6b3c") end

c:groundShadow(32, 50, 27, 3)
masonry(6, 24, 57, 46, 3)          -- front face
for x = 6, 57 do px(x, 20, S[6]) for y = 21, 23 do px(x, y, S[5]) end px(x, 23, S[4]) end  -- flat top slab
for x = 6, 57, 9 do px(x + (x % 2), 22, S[4]) end
for y = 20, 46 do px(57, y, S[2]) end
-- quirk: a daisy poking out of a missing stone
for y = 36, 40 do for x = 30, 33 do px(x, y, S[1]) end end
px(31, 40, "#4b8a46") px(31, 39, "#4b8a46") px(31, 38, "#4b8a46")
px(31, 35, "#f6d34a") px(30, 35, "#fff6f2") px(32, 35, "#fff6f2") px(31, 34, "#fff6f2") px(31, 36, "#fff6f2")
moss(10, 46, 4) moss(46, 46, 3)

G.fin(c, "stone-wall-straight")
