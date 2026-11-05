-- wander-generic: Hearth Pop v3 wander banner, 480x64 native. A gentle meadow edge: a side path
-- leaves the trail toward soft hills, wildflowers, a fence. Centre third kept calm for the card title.
local ROOT = "/home/user/gnome-venture/aseprite-source/v3/"
local HP = dofile(ROOT .. "lib/hp.lua")
local K = dofile(ROOT .. "here-gate/places/_wander-kit.lua")
local OUT = app.params.out or (ROOT .. "here-gate/places/")
local NAME = "wander-generic"
local floor, sin, abs, max, min = math.floor, math.sin, math.abs, math.max, math.min
local hash = K.hash
local W, H = 480, 64
local c = HP.canvas{ w = W, h = H, scale = 1, name = NAME }
local S = K.new(W, H)

local INK = "#2b1c26"
local GR = { "#2f4f30", "#3f6a36", "#548540", "#6ea24a", "#8fbd58", "#b8d672" }
local LEAF = { "#24402c", "#2f5a32", "#41753a", "#5a9242", "#7bb04e", "#a5cc66" }
local AUT = { "#5a2a22", "#8a3a26", "#b85a2a", "#d9822e", "#eeaa44", "#f6cf6a" }
local BARK = { "#3a2420", "#5a3828", "#7a4e30", "#9a6a3e", "#b98a52" }
local DIRT = { "#5a3a2a", "#7a5034", "#9c6c40", "#bd8c54", "#d8ae72" }
local ROCK = { "#4a4a5a", "#666678", "#8a8a96", "#adacb2", "#cbc6c4" }
local CLOUD = { "#c9b8c8", "#ddd0d4", "#efe6dc", "#f8f0e2" }
local function side(x) return x < 160 or x >= 320 end

-- sky
S:sky{ { 0, "#6fa3cf" }, { 7, "#86b6d8" }, { 14, "#a3c8dc" }, { 20, "#c4d9d6" }, { 25, "#e6dcbc" }, { 30, "#f2d6a6" } }

-- clouds (flat bottoms)
local function cloud(x, y, w, seed)
  local g = 900 + seed
  S:blob(x + w * 0.28, y - w * 0.1, w * 0.24, w * 0.15, seed, CLOUD, { ol = "#9a87a3", inner = "#d8c8cc", group = g, ycut = y, amp = 0.1 })
  S:blob(x + w * 0.56, y - w * 0.17, w * 0.26, w * 0.2, seed + 1, CLOUD, { ol = "#9a87a3", inner = "#d8c8cc", group = g, ycut = y, amp = 0.1 })
  S:blob(x + w * 0.82, y - w * 0.08, w * 0.17, w * 0.11, seed + 2, CLOUD, { ol = "#9a87a3", inner = "#d8c8cc", group = g, ycut = y, amp = 0.1 })
end
cloud(10, 21, 54, 3)
cloud(96, 12, 30, 7)
cloud(392, 19, 60, 11)
cloud(338, 9, 24, 15)

-- far hills (calmer in the centre)
local function farTop(x)
  local k = side(x) and 1 or 0.55
  return 31 + k * (4 * sin(x / 41 + 0.5) + 2.5 * sin(x / 17 + 2))
end
S:terrain(farTop, { "#4a6474", "#5b7a86", "#6f9192", "#88a89c" }, { ol = "#3a4a5e", base = 0.45, fall = 0.02,
  tex = function(x, y, d, v) return v + (hash(floor(x / 3), y, 2) - 0.5) * 0.18 end })
-- distant tree line on the far hills, sides only
for x = 2, W - 3, 7 do
  if side(x) and hash(x, 5) > 0.3 then
    local r = 3 + hash(x, 6) * 2.5
    S:blob(x, farTop(x) - r * 0.4, r, r * 0.9, x, { "#3e5a5e", "#4f6f6a", "#628274" }, { ol = "#33424f", inner = "#3a5256", group = 77, leaf = true })
  end
end

-- mid hills
local function midTop(x) return 40 + 3 * sin(x / 53 + 2.2) + 1.5 * sin(x / 23) end
S:terrain(midTop, GR, { ol = "#2a3a26", base = 0.6, fall = 0.03,
  tex = function(x, y, d, v) return v + (hash(x, floor(y / 2), 3) - 0.5) * 0.16 end })

-- trees
local function tree(x, base, h, w, seed, leaf)
  S:tube({ { x - 1, base }, { x, base - h * 0.2 }, { x + 1, base - h * 0.4 }, { x, base - h * 0.62 } },
    function(t) return 4.5 - t * 2 end, BARK, { ol = INK, grain = 3, seed = seed })
  S:canopy(x, base - h * 0.68, w, h * 0.62, seed, leaf, INK)
end
tree(22, 46, 30, 26, 21, LEAF)
tree(64, 44, 22, 18, 22, AUT)
tree(132, 46, 17, 15, 23, LEAF)
tree(352, 45, 20, 18, 24, LEAF)
tree(424, 44, 32, 28, 25, AUT)
tree(468, 46, 24, 20, 26, LEAF)

-- foreground meadow
local function meadowTop(x) return 48 + 1.5 * sin(x / 31 + 1) + sin(x / 11) end
S:terrain(meadowTop, GR, { ol = "#2a3a26", base = 0.55, fall = 0.02,
  tex = function(x, y, d, v)
    return v + (hash(x, floor((y + hash(x, 1) * 4) / 3), 5) - 0.5) * 0.3
  end })

-- side path leaving the trail toward the hills
S:tube({ { 120, 66 }, { 104, 57 }, { 74, 51 }, { 46, 45 } }, function(t) return 17 * (1 - t) ^ 1.3 + 2 end, DIRT,
  { ol = "#4a2e24", lx = 0.15, ly = 0.25,
    tex = function(x, y, v) local hh = hash(x, y, 8); if hh > 0.93 then return v + 0.3 elseif hh < 0.05 then return v - 0.3 end return v end })

-- fence (right side)
local posts = {}
for px = 362, 404, 14 do posts[#posts + 1] = px end
for i = 1, #posts - 1 do
  for _, ry in ipairs({ 49, 53 }) do
    S:tube({ { posts[i], ry }, { posts[i] + 5, ry + 0.3 }, { posts[i + 1] - 5, ry + 0.3 }, { posts[i + 1], ry } },
      function() return 2 end, BARK, { ol = INK, ly = 1, lx = 0 })
  end
end
for _, px in ipairs(posts) do
  S:tube({ { px, 57 }, { px, 54 }, { px, 50 }, { px, 46 } }, function() return 3.2 end, BARK, { ol = INK, grain = 2, seed = px })
end

-- rocks
S:blob(142, 53, 5, 3.5, 31, ROCK, { ol = INK, tex = function(x, y, v) return v + (hash(x, y, 4) - 0.5) * 0.15 end })
S:blob(137, 55, 3, 2, 32, ROCK, { ol = INK })
S:blob(452, 55, 6, 4, 33, ROCK, { ol = INK, tex = function(x, y, v) return v + (hash(x, y, 4) - 0.5) * 0.15 end })

-- wildflowers
local PET = { "#e8586a", "#f2c14e", "#f4e9d8", "#9b7ad8", "#e98ad0", "#ef8a4a" }
S:obj(nil)
for x = 1, W - 2 do
  local thr = side(x) and 0.84 or 0.975
  if hash(x, 40) > thr then
    local top = floor(meadowTop(x)) + 2
    local y = top + floor(hash(x, 41) * max(1, 56 - top))
    local col = PET[1 + floor(hash(x, 42) * #PET)]
    S:put(x, y + 1, "#2f5a32"); S:put(x, y + 2, "#2f5a32")
    if side(x) and hash(x, 43) > 0.55 then
      S:put(x - 1, y, col); S:put(x + 1, y, col); S:put(x, y - 1, col); S:put(x, y + 1, col)
      S:put(x, y, "#f2c14e" == col and "#e8586a" or "#f2c14e")
    elseif side(x) then
      S:put(x, y, col); S:put(x + 1, y, col)
    else
      S:put(x, y, col)
    end
  end
end

-- trail along the bottom
local function trailTop(x) return 57 + 0.8 * sin(x / 23) + (hash(floor(x / 5), 1) > 0.75 and 1 or 0) end
S:terrain(trailTop, DIRT, { ol = INK, base = 0.5, fall = 0.0,
  tex = function(x, y, d, v)
    local hh = hash(x, y, 9)
    if hh > 0.94 then return v + 0.3 elseif hh < 0.05 then return v - 0.3 end
    if y == 61 and hash(floor(x / 4), 2) > 0.4 then return v - 0.18 end
    return v
  end })

-- grass tufts nibbling the trail edge
S:obj(nil)
for x = 1, W - 2 do
  if hash(x, 50) > (side(x) and 0.78 or 0.93) then
    local t = floor(trailTop(x))
    local hgt = 2 + floor(hash(x, 51) * 3)
    for k = 0, hgt - 1 do S:put(x, t + 1 - k, k == hgt - 1 and "#8fbd58" or "#3f6a36") end
    if hash(x, 52) > 0.5 then S:put(x + 1, t, "#548540"); S:put(x - 1, t, "#2f4f30") end
  end
end

S:edges()
S:flush(c)
c:finish{ outline = false }
HP.report(c)
HP.assertClean(c)
c:save{ aseprite = OUT .. NAME .. ".aseprite", png = OUT .. NAME .. ".png", scale = 1 }
