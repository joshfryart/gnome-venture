-- Hovel window layers 48x48 (slot 56,62): plain, curtain, ivy. Same frame in all three; transparent outside the frame.
local SRC = "/home/user/gnome-venture/aseprite-source"
local HP = dofile(SRC .. "/v3/lib/hp.lua")
local OUT = app.params.out or (SRC .. "/v3/hovel/")
local floor, max, min, abs = math.floor, math.max, math.min, math.abs
local INK = "#2b1c26"
local function new(name)
  local c = HP.canvas{ w = 48, h = 48, scale = 1, name = name }
  return c, dofile(SRC .. "/v3/tree-yard/common.lua").setup(c)
end
local function R(c, x0, y0, x1, y1, col) for y = y0, y1 do for x = x0, x1 do c:put(x, y, col) end end end
local function save(c, n) c:finish{ outline = true }; HP.assertClean(c); c:save{ aseprite = OUT .. n .. ".aseprite", png = OUT .. n .. ".png" } end
local SKY = {"#5f9ad0", "#8bc4ea", "#a8d6f2", "#b9e2f5", "#d2eefa", "#e4f6ff"}

-- frame: arched-top oak casement 5..42 x 4..41, four panes, a deep sill 3..44 x 41..44
local function window(c, S, o)
  o = o or {}
  local OAK = S.OAK
  local outer = c:rrect(6, 4, 41, 41, 9)
  local inner = c:rrect(10, 8, 37, 38, 6)
  -- glass: sky bands, a cloud, far green hill, diagonal glints
  inner:each(function(x, y)
    local col = SKY[(y < 14) and 3 or ((y < 22) and 4 or 5)]
    if y >= 31 then col = (y == 31) and "#78b064" or "#529054" end
    if y >= 29 and y < 31 and x > 22 then col = (y == 29 and x > 28) and "#78b064" or (y == 30 and "#78b064" or col) end
    c:put(x, y, col)
  end)
  for _, p in ipairs{{14, 17, 8}, {16, 16, 4}} do for x = p[1], p[1] + p[3] do c:put(x, p[2], "#f4f8f6"); c:put(x, p[2] + 1, "#d2e4ee") end end
  c:put(15, 15, "#f4f8f6"); c:put(17, 15, "#f4f8f6"); c:put(18, 15, "#f4f8f6"); c:put(16, 14, "#f4f8f6")
  for i = 0, 5 do c:put(27 + i, 26 - i, SKY[6]); c:put(28 + i, 26 - i, SKY[6]) end      -- glint on the lower-right pane
  for i = 0, 3 do c:put(13 + i, 12 - i, SKY[6]) end
  -- frame wood
  outer:each(function(x, y)
    if not inner:has(x, y) then
      local tone = 4
      if x <= 7 or y <= 5 then tone = 5 end
      if x >= 40 or y >= 40 then tone = 2 end
      if (x == 9 and y > 9) or (y == 37 and x > 9) then tone = 5 end                 -- lit inner lip low/left catches light? keep subtle
      if (x == 38 and y < 38) or (y == 38 and x > 10) then tone = 2 end
      c:put(x, y, OAK[tone])
    end
  end)
  -- recess: inner deep line on the top/left of the glass (the frame's shadow)
  inner:each(function(x, y) if not inner:has(x - 1, y) or not inner:has(x, y - 1) then c:put(x, y, SKY[1]) end end)
  -- mullions
  for y = 8, 38 do c:put(23, y, OAK[4]); c:put(24, y, OAK[2]) end
  for x = 10, 37 do c:put(x, 23, OAK[4]); c:put(x, 24, OAK[2]) end
  c:put(23, 23, OAK[5])
  -- iron latch on the right stile
  c:put(35, 25, "#9696a8"); c:put(35, 26, "#545066"); c:put(36, 26, "#3a3446")
  -- sill
  R(c, 3, 41, 44, 44, OAK[4]); R(c, 3, 41, 44, 41, OAK[6]); R(c, 3, 44, 44, 44, OAK[2]); R(c, 43, 42, 44, 43, OAK[3])
  R(c, 6, 42, 41, 42, OAK[3])
  c:put(9, 41, "#fff0c8"); c:put(10, 41, "#fff0c8")
end

-- plain: quirk = a pebble left on the sill
do
  local c, S = new("hovel-window-plain")
  window(c, S)
  R(c, 34, 39, 37, 40, "#9a8e90"); c:put(34, 39, "#d6cabc"); c:put(37, 40, "#5a4e5c"); c:put(35, 39, "#b8aca6")
  save(c, "hovel-window-plain")
end

-- curtain: rose gingham curtains on a rod, tied back with gold cord; quirk: one tie has slipped so the right curtain hangs lower
do
  local c, S = new("hovel-window-curtain")
  window(c, S)
  local ROS = {"#4e2840", "#7c4458", "#aa6670", "#cc8a88", "#e6ae9e", "#f6d0bc"}
  local function gingham(x, y, shade)
    local a, b = (floor(x / 2) % 2 == 0), (floor(y / 2) % 2 == 0)
    local t = (a and b) and 3 or ((a or b) and 4 or 5)
    return ROS[max(1, t - shade)]
  end
  -- left curtain: full at top, gathered at y 26 by a gold tie, flares below
  for y = 4, 40 do
    local wdt
    if y < 26 then wdt = 12 - floor((y - 4) * 7 / 22) else wdt = 5 + floor((y - 26) * 5 / 14) end
    for x = 2, 2 + wdt do
      local sh = (x == 2 + wdt) and 1 or 0
      if (x - 2) % 4 == 3 then sh = sh + 1 end                                         -- fold lines
      c:put(x, y, gingham(x, y, sh))
    end
  end
  -- right curtain: hangs straighter, its tie lower (y 32)
  for y = 4, 40 do
    local wdt
    if y < 32 then wdt = 11 - floor((y - 4) * 6 / 28) else wdt = 5 + floor((y - 32) * 4 / 8) end
    for x = 45 - wdt, 45 do
      local sh = (x == 45) and 1 or 0
      if (45 - x) % 4 == 3 then sh = sh + 1 end
      if x == 45 - wdt then sh = sh + 1 end
      c:put(x, y, gingham(x, y, sh))
    end
  end
  -- ties
  local GD = {"#5a3a14", "#8a5a1a", "#bc8420", "#e0aa2c", "#f4cc4a", "#fce67c"}
  for x = 2, 8 do c:put(x, 26, GD[4]); c:put(x, 27, GD[2]) end; c:put(9, 27, GD[4]); c:put(9, 28, GD[3]); c:put(3, 26, GD[6])
  for x = 39, 45 do c:put(x, 32, GD[4]); c:put(x, 33, GD[2]) end; c:put(38, 33, GD[4]); c:put(38, 34, GD[3])
  -- rod with finials
  R(c, 1, 2, 46, 3, "#545066"); R(c, 1, 2, 46, 2, "#9696a8")
  R(c, 0, 1, 1, 4, GD[3]); c:put(0, 1, GD[5]); R(c, 46, 1, 47, 4, GD[3]); c:put(46, 1, GD[5])
  for x = 4, 44, 5 do c:put(x, 4, "#3a3446") end                                         -- rings on the rod
  save(c, "hovel-window-curtain")
end

-- ivy: a vine climbs from the sill up the left and over the arch; quirk: one leaf has turned red
do
  local c, S = new("hovel-window-ivy")
  window(c, S)
  local GR = {"#1c3434", "#2a5240", "#3a704a", "#529054", "#78b064", "#a8d080"}
  local path = {}
  for y = 44, 14, -1 do path[#path + 1] = {5 + floor(1.5 * math.sin(y / 3)), y} end
  for i = 0, 30 do path[#path + 1] = {7 + i, 9 - floor(4 * math.sin(i / 30 * math.pi)) + floor(math.sin(i / 2))} end
  for y = 10, 22 do path[#path + 1] = {38 + floor(math.sin(y / 2.5)), y} end
  for _, p in ipairs(path) do c:put(p[1], p[2], "#6a502e") end
  -- leaves: little 3-point ivy leaves every few steps, alternating sides
  local function leaf(x, y, flip, red)
    local L = red and {"#5c2428", "#843230", "#a6483a", "#c66648", "#e08c62", "#f4b080"} or GR
    local rows = {{-1, 1}, {-2, 2}, {-3, 3}, {-2, 2}, {-1, 1}, {0, 0}}
    for k, r in ipairs(rows) do
      for dx = r[1], r[2] do
        local tone = (dx < 0) and 5 or 4
        if k >= 5 then tone = 3 end
        if dx == 0 and k > 1 then tone = 2 end
        c:put(x + dx, y - 3 + k * (flip and -1 or 1), L[tone])
      end
    end
    c:put(x - 1, y - 2 * (flip and -1 or 1), L[6])
  end
  local n = 0
  for i = 3, #path, 4 do
    n = n + 1
    local p = path[i]
    local side = (n % 2 == 0) and 3 or -3
    leaf(p[1] + side, p[2], (p[2] < 12 and n % 2 == 0), n == 9)
  end
  save(c, "hovel-window-ivy")
end
print("ok")
