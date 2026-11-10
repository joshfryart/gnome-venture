-- act-night_fishing (v3 Hearth Pop 2.5D): a gnome fishes from a jetty under a crescent moon, a lantern on a post.
-- Motion: the hooked fish wriggles and drips, moon path and ripples shimmer, stars twinkle, the lantern flickers.
-- quirk: the fish is hooked by its lip and does not look pleased.
local DIR = (debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")) or "."
local A = dofile(DIR .. "/../actlib.lua")
local P, HP = A.P, A.HP
local floor = math.floor

local G = A.gnome{ view = "side", hat = "#e8493b", tunic = "#3a86b0", scarf = "#f5b82e" }
local WATER = { "#2a4a7a", "#24406e", "#1f3762" }

local function sky(c, f)
  c:stripes(10, 52, { "#221d45", "#2a2350", "#35295f", "#3f3373" }, { 2, 3, 3, 3 })
  -- crescent moon
  local moon = c:ellipse(30, 24, 7, 7):cut(c:ellipse(34, 21, 6, 6))
  moon:each(function(x, y) c:put(x, y, x < 27 and "#fff4d6" or "#ffe38a") end)
  c:put(25, 21, "#fff4d6")
  -- stars: tiny dots, three plus-stars twinkle (each frame a different one is bright)
  for i = 1, 22 do
    local x, y = 12 + floor(A.hash(i, 1, 9) * 120), 11 + floor(A.hash(i, 2, 9) * 34)
    if not (x > 20 and x < 40 and y < 34) then
      local on = (i + f) % 3 ~= 0 or i % 2 == 0
      c:put(x, y, on and "#c9b2f0" or "#5a459e")
    end
  end
  local pl = { { 60, 16 }, { 108, 13 }, { 84, 30 } }
  for i, p in ipairs(pl) do
    local ph = (f + i * 2) % 6
    local x, y = p[1], p[2]
    if ph < 2 then
      c:put(x, y, "#fff4d6") c:put(x - 1, y, "#c9b2f0") c:put(x + 1, y, "#c9b2f0") c:put(x, y - 1, "#c9b2f0") c:put(x, y + 1, "#c9b2f0")
    elseif ph < 4 then c:put(x, y, "#fff4d6")
    else c:put(x, y, "#c9b2f0") end
  end
  -- far hills: two dark planes
  c:terrain(function(x) return 42 + math.sin(x / 11) * 3 + math.sin(x / 4.5) end, "#2d3f66", 54)
  c:terrain(function(x) return 48 + math.sin((x + 20) / 15) * 3 end, "#243457", 54)
  for x = 10, 137, 1 do if A.hash(x, 5, 3) < .3 then c:put(x, floor(48 + math.sin((x + 20) / 15) * 3 + .5), "#35295f") end end
end

local function water(c, f)
  for y = 54, 99 do for x = 10, 137 do c:put(x, y, y < 60 and WATER[1] or (y < 76 and WATER[2] or WATER[3])) end end
  c:fillMask(c:rect(10, 54, 137, 54), "#3a5a8c")
  -- moon path: dashes under the moon that slide sideways and come back (loops in 6 frames)
  for r = 0, 9 do
    local y = 57 + r * 3 + floor(r / 3)
    local w = 10 - floor(r / 2)
    local off = floor(math.sin((f + r) * math.pi / 3) * 2 + .5)
    for x = 30 - floor(w / 2) + off, 30 + floor(w / 2) + off do
      if (x + r) % 5 ~= 0 then c:put(x, y, r < 4 and "#ffe38a" or "#d9c27a") end
    end
  end
  -- ripple dashes drifting left, 1 px per frame on a 6 px pattern (loops)
  for r = 0, 6 do
    local y = 60 + r * 5
    for x = 10, 133 do
      local u = (x + f + r * 7) % 18
      if u < 3 and not (x > 18 and x < 42) and x < 80 then c:put(x, y, "#3a5a8c") end
      if u == 9 and x < 78 and r % 2 == 1 then c:put(x, y, "#4a6ea0") end
    end
  end
end

local function jetty(c, f)
  -- posts in the water with broken reflections
  for _, px in ipairs({ 84, 104, 124 }) do
    c:fillMask(c:rect(px, 76, px + 3, 90), P.wood.deep)
    c:fillMask(c:rect(px, 76, px, 90), P.wood.shade)
    for y = 91, 96, 2 do local o = ((y + f) % 4 < 2) and 0 or 1 c:put(px + o, y, "#51302b") c:put(px + o + 1, y, "#51302b") end
  end
  -- deck (top face seen from above, planks)
  local deck = c:rect(76, 68, 137, 75)
  c:rim(deck, P.ink, c:rect(10, 10, 137, 99))
  deck:each(function(x, y)
    local col = P.wood.base
    if y == 68 then col = P.wood.hi elseif y >= 74 then col = P.wood.shade end
    if (x - 76) % 9 == 0 and y < 74 then col = P.wood.shade end
    c:put(x, y, col)
  end)
  c:fillMask(c:rect(76, 76, 137, 76), P.wood.deep)
  -- lantern post
  c:fillMask(c:rect(124, 26, 126, 67), P.wood.shade)
  c:fillMask(c:rect(124, 26, 124, 67), P.wood.base)
  c:fillMask(c:rect(116, 26, 126, 27), P.wood.shade)
  c:put(117, 28, P.ink) c:put(117, 29, P.ink)
  -- lantern: flicker by frame
  local glow = { "#ffe38a", "#f5b82e", "#ffe38a", "#fff4d6", "#f5b82e", "#ffe38a" }
  local L = c:rect(114, 30, 120, 39)
  c:rim(L, P.ink)
  L:each(function(x, y)
    local col = glow[f + 1]
    if x == 114 or x == 120 or y == 30 or y == 39 then col = "#51302b" end
    c:put(x, y, col)
  end)
  c:put(117, 33 + (f % 2), "#fff4d6") c:put(117, 34 + (f % 2), "#e8493b")
  -- warm halo dots that pulse
  local rr = (f % 3 == 1) and 7 or 6
  for a = 0, 15 do
    local x, y = floor(117 + math.cos(a * math.pi / 8) * rr + .5), floor(35 + math.sin(a * math.pi / 8) * rr + .5)
    if a % 2 == 0 then c:put(x, y, "#8f4a1f") end
  end
end

local function fish(c, f)
  local sw = ({ 0, 1, 1, 0, -1, -1 })[f + 1]
  local tip = { 52, 22 }
  local fx, fy = 46 + sw, 40
  -- line from rod tip to fish mouth
  local ln = c:line({ tip, { fx + 2, fy } }, 1)
  ln:each(function(x, y) c:put(x, y, "#c9b2f0") end)
  -- hanging fish, head up: body 5 wide, 12 tall
  local body = c:ellipse(fx + 2, fy + 7, 2.5, 6)
  local tailL = (f % 2 == 0) and -1 or 1
  local tail = c:poly{ { fx + 2, fy + 12 }, { fx - 1 + tailL, fy + 17 }, { fx + 5 + tailL, fy + 17 } }
  local all = body:copy():add(tail)
  c:rim(all, P.ink)
  body:each(function(x, y)
    local col = P.stone.base
    if x <= fx + 1 then col = P.stone.hi end
    if x >= fx + 4 then col = P.stone.shade end
    if y == fy + 8 or y == fy + 9 then col = (x <= fx + 2) and "#b6f0e0" or "#5fc4c8" end
    c:put(x, y, col)
  end)
  tail:each(function(x, y) c:put(x, y, (x + y) % 2 == 0 and P.stone.shade or "#5fc4c8") end)
  c:put(fx + 1, fy + 3, P.ink) c:put(fx + 3, fy + 3, P.ink)    -- two cross eyes
  c:put(fx + 2, fy + 1, "#e8493b")                            -- hooked lip
  -- drips falling from the tail (loop: 3 px per frame, 18 px lane)
  A.lanes{ lanes = { { x = fx + 2, ph = 0 } }, ytop = fy + 19, L = 18, s = 3, D = 18, f = f,
    put = function(x, y) if y < 54 then c:put(x - sw, y, "#b6f0e0") end end }
  -- splash ring on the water under the fish
  local r = (f % 3) + 2
  for x = fx + 2 - r, fx + 2 + r do if (x + f) % 2 == 0 then c:put(x, 56, "#5fc4c8") end end
end

local function rod(c)
  -- held at the gnome's front hand (~(88,58)), up and out to the left
  local m = c:line({ { 90, 60 }, { 72, 40 }, { 52, 22 } }, 1)
  m:each(function(x, y) c:put(x, y, P.wood.hi) end)
  c:line({ { 90, 60 }, { 80, 50 } }, 2):each(function(x, y) c:put(x, y, P.wood.shade) end)
  c:put(52, 22, P.ink)
end

return A.run("night_fishing", function(f)
  local c = A.canvas("night_fishing")
  sky(c, f)
  water(c, f)
  jetty(c, f)
  fish(c, f)
  -- gnome faces left on the jetty, feet at y 72
  A.stamp(c, G, 68, 1, { flip = true })
  rod(c)
  return c
end)
