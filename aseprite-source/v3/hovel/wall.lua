-- Hovel wall layers 40x32 (slot 150,80): a framed thing on the wall. Transparent outside, 1px ink outline from c:finish.
local SRC = "/home/user/gnome-venture/aseprite-source"
local HP = dofile(SRC .. "/v3/lib/hp.lua")
local OUT = app.params.out or (SRC .. "/v3/hovel/")
local floor, max, min, abs = math.floor, math.max, math.min, math.abs
local INK = "#2b1c26"
local function new(name)
  local c = HP.canvas{ w = 40, h = 32, scale = 1, name = name }
  return c, dofile(SRC .. "/v3/tree-yard/common.lua").setup(c)
end
local function R(c, x0, y0, x1, y1, col) for y = y0, y1 do for x = x0, x1 do c:put(x, y, col) end end end
local function save(c, n) c:finish{ outline = true }; HP.assertClean(c); c:save{ aseprite = OUT .. n .. ".aseprite", png = OUT .. n .. ".png" } end
-- a moulded frame: lit top/left, shaded bottom/right, inner deep lip
local function frame(c, x0, y0, x1, y1, ramp, wdt)
  for y = y0, y1 do for x = x0, x1 do
    local d = min(x - x0, y - y0, x1 - x, y1 - y)
    if d < wdt then
      local tl = (x - x0 <= y1 - y) and (y - y0 <= x1 - x)          -- upper-left half of the moulding
      local tone = (x - x0 == d or y - y0 == d) and 5 or 3
      if x1 - x == d or y1 - y == d then tone = 2 end
      if d == 1 then tone = tone + ((tl) and 1 or -0) end
      if d == wdt - 1 then tone = 1 end
      c:put(x, y, ramp[max(1, min(6, tone))])
    end
  end end
end
local function hanger(c, cx, y0, fx0, fx1)   -- nail + twine to the frame's top corners
  c:put(cx, 0, "#9696a8"); c:put(cx, 1, "#545066")
  for i = 1, cx - fx0 do local y = 1 + floor(i * (y0 - 1) / (cx - fx0) + .5); c:put(cx - i, y, "#a8825a") end
  for i = 1, fx1 - cx do local y = 1 + floor(i * (y0 - 1) / (fx1 - cx) + .5); c:put(cx + i, y, "#a8825a") end
end

-- 1. sampler: cross-stitch on linen, rose border, a little toadstool cottage in the middle; quirk: the needle still hangs on its red thread
do
  local c, S = new("hovel-wall-sampler")
  hanger(c, 19, 5, 6, 33)
  frame(c, 2, 5, 37, 30, S.OAK, 3)
  R(c, 5, 8, 34, 27, "#eee2c4")
  for y = 8, 27 do for x = 5, 34 do if (x + y) % 2 == 0 then c:put(x, y, "#e6d6b6") end end end   -- linen weave
  R(c, 5, 8, 34, 8, "#c8b494"); R(c, 5, 8, 5, 27, "#c8b494")                                        -- frame's shade on the linen
  local function X(x, y, a, b) c:put(x, y, a); c:put(x + 1, y + 1, a); c:put(x + 1, y, b); c:put(x, y + 1, b) end
  for x = 7, 31, 3 do X(x, 10, "#c94f84", "#aa3a6a"); X(x, 24, "#c94f84", "#aa3a6a") end         -- border rows
  for y = 13, 21, 4 do X(7, y, "#3f9150", "#2a6a40"); X(31, y, "#3f9150", "#2a6a40") end
  -- toadstool house: red cap with cream spots, cream stalk, a gold door
  local cap = {{18, 13, 21, 13}, {16, 14, 23, 14}, {15, 15, 24, 15}, {14, 16, 25, 16}}
  for _, r in ipairs(cap) do for x = r[1], r[3] do c:put(x, r[2], (x + r[2]) % 2 == 0 and "#e8493b" or "#b52e3f") end end
  c:put(17, 14, "#fff4d6"); c:put(22, 15, "#fff4d6"); c:put(19, 13, "#ff8a5c")
  R(c, 17, 17, 22, 21, "#f8eacc"); for y = 17, 21 do c:put(22, y, "#d6c4a0") end
  R(c, 19, 19, 20, 21, "#d98322"); c:put(19, 19, "#f5b82e")
  R(c, 13, 22, 26, 22, "#3f9150")
  -- needle on thread: thread runs from a stitch, over the frame, needle dangling below the frame's lip
  for y = 22, 29 do c:put(33 - (y > 26 and 1 or 0), y, "#d03030") end
  c:put(32, 30, "#bcbccc"); c:put(32, 31, "#9696a8")
  save(c, "hovel-wall-sampler")
end

-- 2. pressed leaf: slim walnut frame, pale paper, one big autumn oak leaf; quirk: its stem pokes out past the frame
do
  local c, S = new("hovel-wall-leaf")
  hanger(c, 20, 4, 8, 32)
  frame(c, 3, 4, 36, 30, {"#24161a", "#3e2624", "#5a3a30", "#7a5440", "#9a6e52", "#bc8e6c"}, 2)
  R(c, 5, 6, 34, 28, "#ece2c8"); R(c, 5, 6, 34, 6, "#cbbd9e"); R(c, 5, 6, 5, 28, "#cbbd9e")
  for y = 7, 28 do for x = 6, 34 do if S.hash(x, y, 5) > .96 then c:put(x, y, "#ddd0b0") end end end
  -- oak leaf: lobed outline built from offsets along the midrib (diagonal, lower-left to upper-right)
  local ORG = {"#5c2428", "#843230", "#b4503a", "#d8743e", "#ec9c4c", "#f8c470"}
  local lobes = {0, 3, 5, 3, 6, 4, 6, 4, 5, 3, 3, 1}
  local leaf = {}
  for i = 0, 22 do
    local mx, my = 10 + i * .9, 25 - i * .72                       -- midrib point
    local w = lobes[floor(i / 2) + 1] or 0
    w = floor(w * (1 - abs(i - 11) / 30) + .5)
    for s = -w, w do
      local x, y = floor(mx + s * .62 + .5), floor(my + s * .78 + .5)
      leaf[y * 64 + x] = s
    end
  end
  for k, s in pairs(leaf) do
    local x, y = k % 64, k // 64
    local tone = (s < 0) and 5 or 4
    if s > 2 then tone = 3 end
    if s == 0 then tone = 2 end
    if S.hash(x, y, 9) > .9 and s ~= 0 then tone = tone + 1 end
    c:put(x, y, ORG[tone])
  end
  for k, s in pairs(leaf) do                                       -- 1px dark edge where the leaf meets paper
    local x, y = k % 64, k // 64
    for _, d in ipairs{{1, 0}, {0, 1}, {-1, 0}, {0, -1}} do
      if not leaf[(y + d[2]) * 64 + x + d[1]] and x + d[1] >= 5 and x + d[1] <= 34 and y + d[2] >= 6 and y + d[2] <= 28 then c:put(x + d[1], y + d[2], ORG[1]) end
    end
  end
  c:put(16, 18, ORG[6]); c:put(17, 17, ORG[6])
  -- stem: down-left through the frame and out
  for i = 0, 6 do c:put(9 - i, 26 + floor(i / 2), "#6a3c22"); c:put(9 - i, 27 + floor(i / 2), "#3e2414") end
  save(c, "hovel-wall-leaf")
end

-- 3. old map: a parchment scroll tacked up, rolled top and bottom; coast, hills, dotted trail to a cross; quirk: torn lower-right corner
do
  local c, S = new("hovel-wall-map")
  local PA = {"#6a4a30", "#9a7448", "#c4a06a", "#dcc08a", "#ecd8a8", "#f6e8c4"}
  local function inMap(x, y) return x >= 4 and x <= 35 and y >= 5 and y <= 27 and not (x + y > 57 and y > 22) end
  for y = 5, 27 do for x = 4, 35 do if inMap(x, y) then
    local tone = 5
    if S.hash(floor(x / 3), floor(y / 3), 4) > .7 then tone = 4 end
    if x == 35 or y == 27 then tone = 3 end
    if x == 4 then tone = 6 end
    c:put(x, y, PA[tone])
  end end end
  -- rolls top and bottom
  for x = 2, 37 do c:put(x, 3, PA[6]); c:put(x, 4, PA[4]); c:put(x, 5, PA[2]) end
  for x = 2, 31 do c:put(x, 28, PA[5]); c:put(x, 29, PA[3]); c:put(x, 30, PA[2]) end
  c:put(2, 4, PA[3]); c:put(37, 4, PA[3]); c:put(2, 29, PA[3])
  -- sea on the left with a wavy coast
  for y = 6, 27 do
    local cx = 11 + floor(2 * math.sin(y / 2.3)) + floor((y - 6) / 7)
    for x = 5, cx do if inMap(x, y) then c:put(x, y, (x == cx) and "#3a86b0" or (((x + y * 2) % 7 == 0) and "#8acce0" or "#5fc4c8")) end end
    if inMap(cx + 1, y) then c:put(cx + 1, y, PA[3]) end
  end
  -- hills (little carets) and a wood (green dots)
  for _, h in ipairs{{20, 10}, {25, 9}, {29, 12}} do c:put(h[1], h[2], "#864c33"); c:put(h[1] - 1, h[2] + 1, "#864c33"); c:put(h[1] + 1, h[2] + 1, "#b97a4a") end
  for _, t in ipairs{{17, 18}, {19, 20}, {16, 21}, {20, 17}} do c:put(t[1], t[2], "#3f9150"); c:put(t[1], t[2] - 1, "#7cc35a") end
  -- dotted trail to a red cross
  local trail = {{14, 24}, {16, 23}, {18, 24}, {20, 23}, {22, 21}, {23, 19}, {25, 17}, {27, 16}}
  for _, p in ipairs(trail) do c:put(p[1], p[2], "#b52e3f") end
  c:put(29, 14, "#e8493b"); c:put(31, 14, "#e8493b"); c:put(30, 15, "#b52e3f"); c:put(29, 16, "#e8493b"); c:put(31, 16, "#e8493b")
  -- brass tack top centre
  c:put(19, 7, "#f4cc4a"); c:put(20, 7, "#bc8420"); c:put(19, 8, "#bc8420"); c:put(20, 8, "#8a5a1a")
  -- torn corner: ragged edge
  c:put(33, 25, PA[2]); c:put(34, 24, PA[2]); c:put(35, 23, PA[2]); c:put(32, 26, PA[3]); c:put(31, 27, PA[3])
  save(c, "hovel-wall-map")
end
print("ok")
