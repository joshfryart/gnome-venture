-- batch.lua: restyles the 16 underground map pictures (hearth-pop v3). Param: name=<CA|CB|...|world|world-regions> or all
-- Old picture -> class grid (DARK rock / FLOOR / PATH / DETAIL); floor and rock repainted, paths+details kept, ink rim, props on plain floor.
-- map-world-regions is the game's flat-colour hit mask (never restyled): copied pixel for pixel.
local d = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local V3 = d .. "/.."
local HP = dofile(V3 .. "/../lib/hp.lua")
local GX = dofile(V3 .. "/../gather/gx.lua")
local floor, max, min, abs, sin, cos, sqrt = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.sqrt
local INK = "#2b1c26"
local SRC = d .. "/../../../../game/assets/img/scenes/map-"
local NAME = app.params.name or "all"

local function hash(x, y, s)
  local n = (x * 374761393 + y * 668265263 + (s or 0) * 2147483647) % 4294967296
  n = ((n ~ (n >> 13)) * 1274126177) % 4294967296
  return ((n ~ (n >> 16)) % 65536) / 65536
end
local function hex(r, g, b) return string.format("#%02x%02x%02x", r, g, b) end

-- six-tone ramps dark -> light
local RAMP = {
  forest = { "#1f3a2a", "#2f5a35", "#3f7a3f", "#5a9a44", "#7cb852", "#a6d070" },
  desert = { "#6a4426", "#8f6234", "#b88646", "#d4a85a", "#e8c47a", "#f4dc9e" },
  snow   = { "#46607a", "#6a86a0", "#8fa9bf", "#b6cbdc", "#d8e6ef", "#f0f5f2" },
  grass  = { "#2f6a36", "#468a3e", "#62a844", "#86c24e", "#a8d862", "#c8e888" },
  ember  = { "#5a2a22", "#7e3a2a", "#a4502f", "#c86a3a", "#e08a4a", "#f0aa68" },
  violet = { "#3e2e6a", "#5a468e", "#7a62b0", "#9a82c8", "#b8a2dc", "#d8c8ee" },
  teal   = { "#1e4a58", "#2a6a7a", "#3a8a9a", "#58a8b4", "#86c4c8", "#b4dcd8" },
  savanna= { "#7a4c20", "#a06a28", "#c28a34", "#dca848", "#ecc468", "#f6dc90" },
  slate  = { "#3a4452", "#546070", "#707e8c", "#8f9ca8", "#b0bcc4", "#d0d8dc" },
  gold   = { "#7a5a14", "#a07a1c", "#c49a24", "#e0b838", "#f0d060", "#f8e68a" },
  jungle = { "#1a4a30", "#20683a", "#2a8844", "#3ca850", "#62c460", "#92dc78" },
  moss   = { "#264a40", "#345e46", "#4a7a50", "#6a9858", "#8eb468", "#b2cc84" },
  adobe  = { "#5a3030", "#7e4a42", "#a06656", "#c0846a", "#dca484", "#f0c8a4" },
  tundra = { "#3a5a48", "#587a5a", "#7a9a70", "#9ab88a", "#bcd2aa", "#dce8cc" },
  lagoon = { "#1e5a50", "#2a7a64", "#3c9a78", "#5cb890", "#88d0a8", "#b8e8c4" },
}
local ROCK = {  -- base, mid, chip
  warm = { "#34222d", "#402c38", "#5a4150" }, blue = { "#262c3c", "#303850", "#46506a" },
  grey = { "#2e2a34", "#3a3642", "#524e5e" }, red = { "#3a1e26", "#4a2a30", "#68403e" },
  green = { "#232a28", "#2e3a34", "#445850" }, plum = { "#2e2038", "#3a2a48", "#544066" },
}

-- per map: ramp, rock, keep (0..1 old hue kept), props {kind,count,colour/ramp}
local MAPS = {
  CA   = { ramp = "adobe",  rock = "warm",  props = { { "rock", 4 }, { "cactus", 3 }, { "beetle", 1 } } },
  CB   = { ramp = "teal",   rock = "blue",  props = { { "crystal", 7, "ice" }, { "peak", 2, "snow" }, { "rock", 3 } } },
  CSA  = { ramp = "ember",  rock = "red",   props = { { "peak", 3 }, { "rock", 4 }, { "cactus", 2 }, { "bush", 2, "ember" } } },
  EA   = { ramp = "violet", rock = "plum",  props = { { "bush", 5, "pink" }, { "crystal", 3, "violet" }, { "shroom", 2 } } },
  EE   = { ramp = "slate",  rock = "grey",  props = { { "peak", 5, "snow" }, { "rock", 3 }, { "bush", 2, "tundra" } } },
  ESA  = { ramp = "savanna",rock = "red",   props = { { "bush", 4, "savanna" }, { "rock", 4 }, { "beetle", 1 } } },
  MENA = { ramp = "desert", rock = "warm",  props = { { "cactus", 5 }, { "rock", 3 }, { "peak", 1 } } },
  NA   = { ramp = "forest", rock = "green", props = { { "bush", 8, "forest" }, { "shroom", 2 } } },
  NWE  = { ramp = "tundra", rock = "grey",  props = { { "bush", 5, "grass" }, { "peak", 3, "snow" }, { "rock", 2 } } },
  OC   = { ramp = "lagoon", rock = "blue",  props = { { "bush", 4, "lagoon" }, { "crystal", 3, "ice" }, { "shroom", 2 }, { "beetle", 1 } } },
  SA   = { ramp = "jungle", rock = "green", props = { { "bush", 9, "jungle" }, { "shroom", 1 } } },
  SE   = { ramp = "gold",   rock = "warm",  props = { { "bush", 4, "savanna" }, { "rock", 3 }, { "cactus", 2 }, { "beetle", 1 } } },
  SEA  = { ramp = "grass",  rock = "green", props = { { "bush", 8, "grass" }, { "shroom", 2 } } },
  WCA  = { ramp = "moss",   rock = "green", props = { { "bush", 4, "moss" }, { "peak", 2 }, { "rock", 3 }, { "shroom", 1 } } },
  world = { ramp = "grass", rock = "warm",  keep = .6, scale = 1.5, props = { { "bush", 12, "forest" }, { "peak", 6, "snow" }, { "crystal", 4, "ice" }, { "rock", 6 } } },
}
local ORDER = { "CA", "CB", "CSA", "EA", "EE", "ESA", "MENA", "NA", "NWE", "OC", "SA", "SE", "SEA", "WCA", "world" }

local function isDark(r, g, b) return r <= 75 and g <= 45 and b <= 30 end
local PATHC = { [hex(201,169,110)] = "#d9a85c", [hex(216,196,154)] = "#ecc989", [hex(242,228,192)] = "#f6e3b4", [hex(245,207,106)] = "#f5c95a" }
local function lum(r, g, b) return .3 * r + .59 * g + .11 * b end

-------------------------------------------------------------- prop drawing
local function lit(c, m, hi, base, sh, cx, cy, rr)
  m:each(function(x, y)
    local l = -((x - cx) + (y - cy)) / (rr * 1.6)
    c:put(x, y, l > .38 and hi or (l > -.2 and base or sh))
  end)
  c:rim(m, INK)
end
local PAL = {
  ice = { "#d6f2f4", "#7ccad8", "#3a8aa6" }, violet = { "#e0cef6", "#a98ae0", "#6c52b0" },
  snow = { "#f4efe4", "#c4cfdc", "#8a9ab4" },
}
local function bush(c, x, y, r, R, seed)
  local m = HP.mask()
  m:add(c:ellipse(x, y, r, r - 1)); m:add(c:ellipse(x - r + 2, y + 2, r - 2, r - 3)); m:add(c:ellipse(x + r - 2, y + 2, r - 2, r - 3))
  lit(c, m, R[5], R[4], R[2], x - 1, y - 1, r)
  c:put(x - 2, y - 2, R[6]); c:put(x - 1, y - 2, R[6])
  for i = 1, 3 do local bx, by = x - r + 1 + floor(hash(i, seed, 5) * (2 * r - 2)), y - 1 + floor(hash(i, seed, 6) * r)
    if m:has(bx, by) then c:put(bx, by, i == 1 and "#e8506a" or "#f6d46a") end end
end
local function peak(c, x, y, w, h, key)
  local P = PAL[key] or { "#d8b890", "#a8805a", "#6e4c3a" }
  local base = key and "#9aa4b8" or "#b08a64"
  local m = c:poly({ { x - w, y }, { x - 2, y - h + 3 }, { x, y - h }, { x + 2, y - h + 4 }, { x + w, y } })
  m:each(function(x2, y2)
    local left = x2 <= x + (y - y2) * .12
    local col = left and (key and "#c4cfdc" or "#c89a6c") or (key and "#8a9ab4" or "#8a6246")
    if key and y2 < y - h * .62 then col = left and "#f4efe4" or "#d0d8e6" end
    c:put(x2, y2, col)
  end)
  c:rim(m, INK)
end
local function cactus(c, x, y, h)
  local G = { "#8ad060", "#4a9a44", "#2a6a36" }
  local m = c:rect(x - 1, y - h, x + 1, y)
  m:add(c:rect(x - 4, y - h + 4, x - 3, y - h + 7)); m:add(c:rect(x - 4, y - h + 6, x - 1, y - h + 7))
  m:add(c:rect(x + 3, y - h + 2, x + 4, y - h + 5)); m:add(c:rect(x + 1, y - h + 4, x + 4, y - h + 5))
  m:each(function(x2, y2) c:put(x2, y2, x2 <= x - 1 and G[1] or (x2 == x and G[2] or G[3])) end)
  c:rim(m, INK); c:put(x, y - h - 1, "#f08aa0")
end
local function crystal(c, x, y, h, key)
  local P = PAL[key] or PAL.ice
  local function shard(sx, sh, sw)
    local m = c:poly({ { sx - sw, y }, { sx - sw, y - sh + 3 }, { sx, y - sh }, { sx + sw, y - sh + 3 }, { sx + sw, y } })
    m:each(function(x2, y2) c:put(x2, y2, x2 <= sx - 1 and P[1] or (x2 <= sx + 1 and P[2] or P[3])) end)
    c:rim(m, INK)
  end
  shard(x - 4, floor(h * .6), 2); shard(x + 3, floor(h * .75), 2); shard(x, h, 2)
end
local function shroom(c, x, y)
  local m = c:rect(x - 1, y - 4, x, y)
  m:each(function(x2, y2) c:put(x2, y2, x2 == x - 1 and "#f6e3b4" or "#d8b890") end); c:rim(m, INK)
  local cap = c:ellipse(x, y - 6, 4, 3)
  cap:each(function(x2, y2) c:put(x2, y2, (y2 > y - 4) and "#a82c3a" or ((x2 < x) and "#e8506a" or "#c8384c")) end)
  c:rim(cap, INK); c:put(x - 2, y - 7, "#f6e3b4"); c:put(x + 1, y - 6, "#f6e3b4")
end
local function rockp(c, x, y, r)
  local m = c:ellipse(x, y, r, floor(r * .65))
  lit(c, m, "#c8c0b4", "#968c88", "#665e66", x - 1, y - 1, r)
end
local function beetle(c, x, y)
  local m = c:ellipse(x, y, 4, 3)
  m:each(function(x2, y2) c:put(x2, y2, y2 < y and "#e8506a" or "#a82c3a") end)
  c:rim(m, INK); c:put(x, y - 3, INK); c:put(x, y - 2, INK); c:put(x - 1, y - 1, "#2b1c26"); c:put(x + 2, y - 1, "#2b1c26")
  c:put(x + 5, y - 1, INK); c:put(x + 5, y - 2, INK); c:put(x - 5, y + 3, INK); c:put(x + 4, y + 3, INK)
end
local PROPS = {
  bush = { w = 8, h = 7 }, peak = { w = 9, h = 12 }, cactus = { w = 6, h = 11 }, crystal = { w = 9, h = 12 },
  shroom = { w = 5, h = 9 }, rock = { w = 6, h = 4 }, beetle = { w = 6, h = 4 },
}

-------------------------------------------------------------- one map
local function build(name)
  local W, H = 480, 270
  local img = Image{ fromFile = SRC .. name .. ".png" }
  W, H = img.width, img.height
  local c = HP.canvas{ w = W, h = H, scale = 1, name = "map-" .. name }
  local px = app.pixelColor
  local old = {}
  for y = 0, H - 1 do for x = 0, W - 1 do
    local v = img:getPixel(x, y)
    old[y * W + x] = { px.rgbaR(v), px.rgbaG(v), px.rgbaB(v) }
  end end
  if name == "world-regions" then            -- flat hit-mask: copy exactly
    for y = 0, H - 1 do for x = 0, W - 1 do local o = old[y * W + x] c:put(x, y, hex(o[1], o[2], o[3])) end end
    return c
  end
  local cfg = MAPS[name]
  local R = RAMP[cfg.ramp]
  local RK = ROCK[cfg.rock]
  -- big non-dark non-path colours = floor; sort by luminance -> ramp index
  local cnt = {}
  for i = 0, W * H - 1 do local o = old[i]
    local k = hex(o[1], o[2], o[3])
    if not isDark(o[1], o[2], o[3]) and not PATHC[k] then cnt[k] = (cnt[k] or 0) + 1 end
  end
  local fl = {}
  for k, n in pairs(cnt) do if n > 1100 then local r, g, b = tonumber(k:sub(2,3),16), tonumber(k:sub(4,5),16), tonumber(k:sub(6,7),16) fl[#fl + 1] = { k = k, l = lum(r, g, b), r = r, g = g, b = b } end end
  table.sort(fl, function(a, b) return a.l < b.l end)
  local fmap = {}
  for i, e in ipairs(fl) do
    local t = (#fl == 1) and .5 or (i - 1) / (#fl - 1)
    local ri = 1 + t * 5 * (cfg.keep and 1 or .92)
    local lo, hi = floor(ri), min(6, floor(ri) + 1)
    local col = GX.mix(R[lo], R[hi], ri - lo)
    if cfg.keep then col = GX.mix(col, e.k, cfg.keep) end
    local dk = GX.mix(col, "#2b1c26", .16)
    fmap[e.k] = { col, dk }
  end
  -- classes: 1 floor, 2 dark, 3 path, 4 detail
  local cls = {}
  for i = 0, W * H - 1 do local o = old[i]; local k = hex(o[1], o[2], o[3])
    cls[i] = isDark(o[1], o[2], o[3]) and 2 or (PATHC[k] and 3 or (fmap[k] and 1 or 4))
  end
  -- smoothed "solid" mask: majority of 5x5 non-dark
  local solid = {}
  local function sol(x, y) if x < 0 or y < 0 or x >= W or y >= H then return 0 end return cls[y * W + x] ~= 2 and 1 or 0 end
  for y = 0, H - 1 do for x = 0, W - 1 do
    local n = 0
    for dy = -2, 2 do for dx = -2, 2 do n = n + sol(x + dx, y + dy) end end
    solid[y * W + x] = n >= 13
  end end
  local function S(x, y) if x < 0 or y < 0 or x >= W or y >= H then return false end return solid[y * W + x] end
  local seed = #name * 17 + 3
  for y = 0, H - 1 do for x = 0, W - 1 do
    local i, k = y * W + x, nil
    local o = old[i]; local ok = hex(o[1], o[2], o[3])
    local cl = cls[i]
    local out
    if S(x, y) then
      if cl == 1 then
        local f = fmap[ok]
        out = f[1]
        local h = hash(x, y, seed)
        if h > .93 then out = GX.mix(f[1], R[6], .35) elseif h < .05 then out = f[2] end
      elseif cl == 2 then
        out = ((x + y) % 2 == 0 and hash(x, y, seed + 1) > .35) and R[2] or R[1]     -- dark floor, dithered
      elseif cl == 3 then out = PATHC[ok]
      else out = ok end
    else
      if cl == 3 or cl == 4 then out = (cl == 3) and PATHC[ok] or ok
      else
        local v = GX.vn(x, y, 5, seed)
        local h = hash(x, y, seed + 2)
        out = RK[1]
        if v > .56 then out = ((x + y) % 2 == 0) and RK[2] or RK[1] end
        if v > .68 then out = RK[2] end
        if h > .985 then out = RK[3] end
        if y > 0 and not S(x, y - 1) and cls[(y - 1) * W + x] == 2 and v > .62 and h > .6 then out = RK[3] end
      end
    end
    c:put(x, y, out)
  end end
  -- ink rim along the floor edge (cave coast), shadowed path edges
  local isRock = function(x, y) return x >= 0 and y >= 0 and x < W and y < H and not solid[y * W + x] and cls[y * W + x] == 2 end
  local rim = {}
  for y = 0, H - 1 do for x = 0, W - 1 do
    if isRock(x, y) and (S(x - 1, y) or S(x + 1, y) or S(x, y - 1) or S(x, y + 1)) then rim[#rim + 1] = { x, y } end
    if cls[y * W + x] == 3 and not S(x, y) then end
  end end
  for _, p in ipairs(rim) do c:put(p[1], p[2], INK) end
  -- path outline: dark rock neighbours of off-floor path pixels, and shaded lower/right path edges
  local isPath = function(x, y) return x >= 0 and y >= 0 and x < W and y < H and cls[y * W + x] == 3 end
  for y = 0, H - 1 do for x = 0, W - 1 do
    if cls[y * W + x] == 3 then
      if isRock(x - 1, y) or isRock(x + 1, y) or isRock(x, y - 1) or isRock(x, y + 1) then
        for _, dd in ipairs({ { -1, 0 }, { 1, 0 }, { 0, -1 }, { 0, 1 } }) do
          if isRock(x + dd[1], y + dd[2]) and not isPath(x + dd[1], y + dd[2]) then c:put(x + dd[1], y + dd[2], INK) end
        end
      elseif S(x, y) and (not isPath(x, y + 1) or not isPath(x + 1, y)) and cls[min(H - 1, y + 1) * W + x] == 1 then
        c:put(x, y, "#a8743a")
      end
    end
  end end
  -- props on plain interior floor
  local occ = {}
  local function plain(x0, y0, x1, y1)
    for yy = y0, y1 do for xx = x0, x1 do
      if xx < 4 or yy < 4 or xx >= W - 4 or yy >= H - 4 then return false end
      local i = yy * W + xx
      if cls[i] ~= 1 or occ[i] or not S(xx, yy) or not S(xx - 3, yy) or not S(xx + 3, yy) or not S(xx, yy - 3) or not S(xx, yy + 3) then return false end
    end end
    return true
  end
  local tries = 0
  for pi, pr in ipairs(cfg.props) do
    local kind, n, key = pr[1], pr[2], pr[3]
    local pp = PROPS[kind]
    local placed, t = 0, 0
    while placed < n and t < 4000 do
      t = t + 1
      local x = 8 + floor(hash(t, pi, seed + 7) * (W - 16))
      local y = 10 + floor(hash(t, pi, seed + 9) * (H - 20))
      if plain(x - pp.w, y - pp.h, x + pp.w, y + 3) then
        for yy = y - pp.h - 2, y + 5 do for xx = x - pp.w - 2, x + pp.w + 2 do occ[yy * W + xx] = true end end
        placed = placed + 1
        local sd = placed * 13 + pi
        if kind == "bush" then
          local BR = RAMP[key or cfg.ramp]
          if key == "pink" then BR = { "#6a2a4a", "#9a3a62", "#c8527a", "#e87898", "#f4a0b4", "#fcc8d0" } end
          if key == "ember" then BR = { "#4a2a1e", "#6a3a22", "#8a5a2a", "#b0803a", "#d0a24a", "#ecc86a" } end
          bush(c, x, y, 5 + floor(hash(t, 1, 3) * 3), BR, sd)
        elseif kind == "peak" then peak(c, x, y, 7 + floor(hash(t, 2, 3) * 4), 9 + floor(hash(t, 3, 3) * 6), key)
        elseif kind == "cactus" then cactus(c, x, y, 8 + floor(hash(t, 4, 3) * 4))
        elseif kind == "crystal" then crystal(c, x, y, 9 + floor(hash(t, 5, 3) * 5), key)
        elseif kind == "shroom" then shroom(c, x, y)
        elseif kind == "rock" then rockp(c, x, y, 4 + floor(hash(t, 6, 3) * 3))
        elseif kind == "beetle" then beetle(c, x, y) end
      end
    end
  end
  return c
end

local names = (NAME == "all") and { table.unpack(ORDER) } or { NAME }
if NAME == "all" then names[#names + 1] = "world-regions" end
for _, n in ipairs(names) do
  local c = build(n)
  c:save{ png = d .. "/out/map-" .. n .. ".png", scale = 1 }
end
