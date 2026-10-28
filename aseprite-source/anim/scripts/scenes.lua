-- scenes.lua: animated activity scenes (6 frames, 6 fps, 144x108 on a 2px grid). Run:
--   "C:\Program Files\Aseprite\Aseprite.exe" -b --script aseprite-source/anim/scripts/scenes.lua
-- Pass --script-param only=<slug> to build one. Reads game/assets/img/acts/act-<slug>.png (frame 1 == static),
-- writes act-<slug>-anim.png (strip of 6 x 144x108) and aseprite-source/anim/act-<slug>-anim.aseprite.
-- All coordinates below are CELLS (2px) of the 72x54 grid; the picture frame (outer 5 cells) is never touched.
-- Method: every frame is the static picture with some existing pixels MOVED or RECOLOURED (never blended),
-- vacated pixels are refilled from the nearest background cell on the same row.
local D = "C:/Users/hello/OneDrive/Desktop/claude/Gnome Venture/gnome-venture/aseprite-source/anim/scripts/"
local A = dofile(D .. "animlib.lua")
local R = A.REPO
local N = 6
local ONLY = app.params.only

-- colours that make up a gnome (hat, outline, face, beard, shirt, hands); boots/ground are left out on purpose
local GNOME = { "#c0442e", "#8e2e1e", "#2a1a10", "#f0c8a0", "#e08a7a", "#f4eee0", "#cfc6b0", "#4a6e9a", "#34507a", "#d4a27a", "#74462a", "#4a2c1a" }

local function scene(slug, make, extra)
  if ONLY and ONLY ~= slug then return end
  local st = A.load(R .. "game/assets/img/acts/act-" .. slug .. ".png", 2)
  local frames = {}
  for i = 1, N do
    local f = st:copy()
    if i > 1 then make(f, i) end
    frames[i] = f
  end
  A.offPalette(st, frames, extra)
  A.export(slug, frames, R .. "game/assets/img/acts/act-" .. slug .. "-anim.png",
    R .. "aseprite-source/anim/act-" .. slug .. "-anim.aseprite")
end

local pattern = {
  breath = { 0, 0, 1, 1, 0, 0 },     -- idle stretch of the gnome (cells), frame 1 == rest
  sway = { 0, 1, 1, 0, -1, -1 },
}

local function cat(...)
  local t = {}
  for _, l in ipairs({ ... }) do for _, v in ipairs(l) do t[#t + 1] = v end end
  return t
end
local SKY = { "#a8d4e0", "#cfe8e6", "#e8a87a", "#f4cf98", "#bcdde4" }
local HILL = { "#5e8a44", "#7ea85a", "#9cc070", "#4e8a3c", "#6f9c52", "#4f9a45" }
local BGSET = cat(SKY, HILL, { "#c9a96e", "#d9bc84", "#7f9a7e", "#9db89a", "#6b4328", "#d17b35", "#d9a660", "#cfe2cc", "#3f6a32", "#6a9a48", "#8ab868", "#d9b57a" })

-- Idle: the gnome's upper body rises one cell on the beat (feet stay planted), joined by keepLast.
-- g = { x0, x1, top, split }
local function breathe(f, g, i)
  local d = pattern.breath[i]
  if d == 0 then return end
  f:move({ box = { g.x0, g.top, g.x1, g.split }, pred = GNOME, bg = A.bgNear(BGSET, 14), dx = 0, dy = -d, keepLast = true })
end

-- the standard (7+ cells wide) red hat k of a scene
local function hats(st)
  local out = {}
  for _, b in ipairs(st:components({ "#c0442e" })) do
    if b[3] - b[1] + 1 >= 7 and b[4] - b[2] + 1 >= 6 and b[2] >= 18 then out[#out + 1] = b end
  end
  return out
end
local function gnome(st, k, splitOff)
  local b = hats(st)[k or 1]
  return { x0 = b[1] - 2, x1 = b[3] + 3, top = b[2] - 1, split = b[2] + (splitOff or 13) }
end

-- cloud (cream blob, <= 7 rows tall, >= 10 wide, in the sky) drifts one cell right and back
local function cloud(st, f, i)
  local d = ({ 0, 0, 1, 1, 1, 0 })[i]
  if d == 0 then return end
  for _, b in ipairs(st:components({ "#f4eee0" })) do
    if b[3] - b[1] + 1 >= 10 and b[4] - b[2] + 1 <= 7 and b[2] <= 12 then
      f:move({ box = { b[1] - 1, b[2], b[3] + 1, b[4] }, pred = { "#f4eee0" }, bg = A.bgNear(SKY, 6), dx = d })
    end
  end
end

-- hanging bunting: each pennant (a flag-coloured blob in rows y0..y1) flutters a cell sideways
local function bunting(st, f, i, y0, y1, skip, maxX)
  local keepOut = {}
  for _, h in ipairs(skip or {}) do keepOut[A.hex(h)] = true end
  local amp = ({ 0, 1, 1, 0, 0, 0 })[i]
  if amp == 0 then return end
  local cols = {}
  for cy = y0, y1 do
    for cx = 6, 66 do
      local v = st:cget(cx, cy)
      if v ~= 0 and not keepOut[v] then cols[v] = (cols[v] or 0) + 1 end
    end
  end
  local comps = {}
  for v, n in pairs(cols) do
    if n >= 3 then
      for _, b in ipairs(st:components(function(x) return x == v end)) do
        if b[2] >= y0 - 1 and b[4] <= y1 + 3 and b[1] >= 5 and b[3] <= (maxX or 67) and b[5] >= 3 and b[5] <= 14 then comps[#comps + 1] = { v, b } end
      end
    end
  end
  table.sort(comps, function(a, b) return a[2][1] < b[2][1] end)
  for idx, c in ipairs(comps) do
    local b = c[2]
    local sign = (idx % 2 == 0) and 1 or -1
    -- the pennant = its fill cells + the dark outline cells touching them (but not the string row above)
    local fill, mine = c[1], {}
    for cy = b[2], b[4] do
      for cx = b[1], b[3] do
        if st:cget(cx, cy) == fill then
          for dy = -1, 1 do for dx = -1, 1 do mine[(cy + dy) * 100 + cx + dx] = true end end
        end
      end
    end
    local dark = { [A.hex("#2a1a10")] = true, [A.hex("#4a2c1a")] = true, [A.hex("#74462a")] = true }
    f:move({ box = { b[1] - 1, b[2], b[3] + 1, b[4] + 1 }, pred = function(v, cx, cy) return v == fill or (dark[v] and mine[cy * 100 + cx] == true) end,
      bg = A.bgNear(SKY, 6), dx = amp * sign })
  end
end

local function sunBob(st, f, i)
  local d = ({ 0, 0, 1, 1, 0, 0 })[i]
  if d == 0 then return end
  for _, b in ipairs(st:components({ "#f4c84a" })) do
    if b[5] >= 90 then
      f:move({ box = { b[1] - 1, b[2] - 1, b[3] + 1, b[4] + 2 }, pred = { "#f4c84a" }, bg = A.bgNear(SKY, 14), dy = -d })
    end
  end
end

-- ===================================================================== TRAIL SIGNS (check; the "Follow the scout's trail signs" card)
local TRAIL_SKY = { "#cfe2cc", "#dce8c8", "#3f6a32", "#4e8a3c", "#b9d9d0" }
scene("w5_trail_signs", function(f, i)
  breathe(f, { x0 = 42, x1 = 57, top = 30, split = 45 }, i)
  local up = pattern.breath[i]                       -- hand rides the stretch
  local wave = pattern.sway[i]
  -- waving hand: slides side to side at the end of the raised arm
  f:move({ box = { 53, 35 - up, 57, 38 - up }, pred = { "#f0c8a0", "#2a1a10" }, bg = A.bgNear(BGSET, 8), dx = wave })
  -- gift: hops one cell, bottom outline stays put (a stretch)
  local hop = ({ 0, 1, 1, 0, 0, 0 })[i]
  if hop > 0 then
    f:move({ box = { 59, 20, 66, 28 }, pred = { "#2a1a10", "#f5cf6a", "#c0442e" }, bg = A.bgNear(TRAIL_SKY, 8), dy = -hop, keepLast = true })
  end
  -- gift sparkles come and go
  local sp = A.hex("#ffe08a")
  if i == 3 or i == 4 then f:cput(58, 20, f:cget(57, 20)); f:cput(66, 21, f:cget(67, 21)) end
  if i == 2 or i == 5 then f:cput(62, 19, sp); f:cput(57, 24, sp) end
  if i == 3 then f:cput(66, 18, sp) end
end, { "#ffe08a" })

-- ===================================================================== KIND: check -> hand
scene("hand", function(f, i)
  breathe(f, gnome(f, 1), i)
  cloud(f, f, i)
end)

-- ===================================================================== KIND: buy/snack -> basket
scene("basket", function(f, i)
  breathe(f, gnome(f, 1), i)
  cloud(f, f, i)
end)

-- ===================================================================== fallback -> any (signpost with a star)
scene("any", function(f, i)
  breathe(f, gnome(f, 1), i)
  cloud(f, f, i)
  -- star gleams: its body brightens in a diagonal sweep
  local k = ({ 0, 38, 44, 50, 0, 0 })[i]
  if k > 0 then
    f:recolor({ 32, 4, 46, 16 }, { ["#f4c84a"] = "#fff2b0", ["#c89a2a"] = "#f4c84a" }, function(cx, cy) return math.abs((cx + cy) - k) <= 2 end)
  end
end, { "#fff2b0" })

-- ===================================================================== KIND: rest (sunset bench, Zzz)
scene("rest", function(f, i)
  breathe(f, gnome(f, 1, 10), i)
  sunBob(f, f, i)
  local z = ({ 0, 0, 1, 1, 1, 0 })[i]               -- the Zs float up a cell
  if z > 0 then
    f:move({ box = { 38, 5, 55, 18 }, pred = { "#f4eee0" }, bg = A.bgNear(SKY, 20), dy = -z })
  end
end)

-- ===================================================================== KIND: pick -> shells (bunting, trestle table)
scene("shells", function(f, i)
  breathe(f, gnome(f, 1), i)
  -- (bunting flutter was tried here and dropped: the pennants are multi-tone, moving them tears them)
  cloud(f, f, i)
end)

-- ===================================================================== KIND: power -> ringtoss (floating coin)
scene("ringtoss", function(f, i)
  breathe(f, gnome(f, 1), i)
  cloud(f, f, i)
  local d = ({ 0, -1, -1, 0, 1, 1 })[i]
  if d ~= 0 then
    f:move({ box = { 31, 9, 40, 19 }, pred = { "#e8a317", "#edc449", "#2a1a10", "#4a2c1a", "#74462a" }, bg = A.bgNear(SKY, 8), dy = d })
  end
end)

-- ===================================================================== KIND: lore -> story (speech bubble, lantern, sun)
scene("story", function(f, i)
  breathe(f, gnome(f, 1), i)
  sunBob(f, f, i)
  local d = ({ 0, 0, 1, 1, 0, 0 })[i]
  if d > 0 then                                      -- the star bubble bobs a cell down
    f:move({ box = { 33, 5, 53, 20 }, pred = { "#f4eee0", "#f4c84a", "#2a1a10", "#4a2c1a", "#74462a", "#c89a2a", "#fff2b0" }, bg = A.bgNear(SKY, 10), dy = d })
  end
  if i == 3 or i == 4 then                           -- lantern flickers
    f:recolor({ 60, 32, 64, 38 }, { ["#f4c84a"] = "#fff2b0" }, function(cx, cy) return (cx + cy) % 2 == 0 end)
  end
end, { "#fff2b0" })

-- ===================================================================== KIND: gossip -> chat (typing dots)
scene("chat", function(f, i)
  breathe(f, gnome(f, 1), i)
  cloud(f, f, i)
  local who = ({ 0, 1, 2, 3, 0, 0 })[i]              -- each dot hops in turn
  if who > 0 then
    local x0 = ({ 32, 36, 40 })[who]
    f:move({ box = { x0, 13, x0 + 1, 14 }, pred = { "#74462a" }, bg = A.hex("#f4eee0"), dy = -1 })
  end
end)

-- ===================================================================== KIND: seedswap -> seeds (shelf of jars)
scene("seeds", function(f, i)
  breathe(f, gnome(f, 1), i)
  cloud(f, f, i)
end)

-- ===================================================================== KIND: swap (two arrows)
scene("swap", function(f, i)
  breathe(f, gnome(f, 1), i)
  cloud(f, f, i)
  local d = ({ 0, 1, 1, 0, 0, 0 })[i]
  if d > 0 then
    f:move({ box = { 35, 23, 44, 30 }, pred = { "#f4c84a", "#2a1a10", "#4a2c1a", "#c89a2a" }, bg = A.bgNear(BGSET, 8), dx = d })
    f:move({ box = { 35, 31, 44, 38 }, pred = { "#4e8a3c", "#2a1a10", "#4a2c1a", "#386a2a" }, bg = A.bgNear(BGSET, 8), dx = -d })
  end
end)

-- ===================================================================== KIND: craft (workbench, sparkles, hanging cloths)
scene("craft", function(f, i)
  breathe(f, gnome(f, 1, 15), i)
  local wall = A.bgNear({ "#d9bc84" }, 6)
  local gold = { { 33, 19 }, { 32, 19 }, { 34, 19 }, { 33, 18 }, { 33, 20 }, { 45, 22 }, { 44, 23 }, { 46, 23 }, { 45, 24 }, { 45, 23 } }
  if i == 3 or i == 4 then                           -- sparkle blinks off
    for _, c in ipairs(gold) do
      if f:cget(c[1], c[2]) == A.hex("#f5cf6a") then f:cput(c[1], c[2], f:cget(c[1] + 3, c[2])) end
    end
  end
  local sw = ({ 0, 1, 1, 0, -1, -1 })[i]
  if sw ~= 0 then                                    -- hanging cloths swing from the bottom
    for k, bx in ipairs({ { 44, 50 }, { 52, 57 }, { 59, 64 } }) do
      f:move({ box = { bx[1], 18, bx[2], 22 }, pred = function(v) return v ~= A.hex("#d9bc84") and v ~= A.hex("#c4a468") end, bg = wall, dx = (k % 2 == 0) and -sw or sw })
    end
  end
end)

-- ===================================================================== KIND: collect (shelves of jars)
scene("collect", function(f, i)
  breathe(f, gnome(f, 1, 15), i)
  if i == 3 or i == 4 then                           -- sparkle twinkles
    for _, c in ipairs({ { 60, 28 }, { 59, 29 }, { 61, 29 }, { 60, 30 } }) do
      if f:cget(c[1], c[2]) == A.hex("#f5cf6a") then f:cput(c[1], c[2], f:cget(c[1], c[2] - 3)) end
    end
  end
end)

-- ===================================================================== KIND: tend (watering the sprout)
scene("tend", function(f, i)
  breathe(f, gnome(f, 1, 15), i)
  cloud(f, f, i)
  if i == 3 or i == 4 then                           -- the flower's halo gleams
    f:recolor({ 55, 7, 65, 11 }, { ["#f5e6a8"] = "#fff2b0" })
  end
end, { "#fff2b0" })

-- ===================================================================== KIND: contest (flags + gnome)
scene("contest", function(f, i)
  breathe(f, gnome(f, 1), i)
  bunting(f, f, i, 8, 16, { "#a8d4e0", "#bcdde4", "#f4eee0", "#2a1a10", "#4a2c1a", "#74462a", "#5e3f28", "#3f6fb0", "#5a8ad0", "#cfe8e6" }, 51)
end)
