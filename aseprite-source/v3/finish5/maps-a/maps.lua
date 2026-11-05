-- finish5/maps-a/maps.lua : richness pass 2 on 7 region maps (480x270). Base = base/map-XX.png (the finish3 output, was live).
-- Only plain ground is repainted: roads (path colours), details (houses, icons, rivers, pools, ink) and the cave rock stay.
-- Keep-clear: textures stay 3 px off roads, landmarks stay r+7 px off roads and r+3 off details, so pins and labels read.
-- Param: name=<NA|CA|CB|SA|NWE|SE|EE|all>, out=<dir>/
local d = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local V3 = d .. "/../.."
local HP = dofile(V3 .. "/lib/hp.lua")
local GX = dofile(V3 .. "/gather/gx.lua")
local floor, max, min, abs, sin, cos, sqrt, pi = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.sqrt, math.pi
local INK, SHC = "#2b1c26", "#35295f"
local mix = GX.mix
local OUT = app.params.out or (d .. "/out/")
local NAME = app.params.name or "all"

local function hash(x, y, s)
  local n = (x * 374761393 + y * 668265263 + (s or 0) * 2147483647) % 4294967296
  n = ((n ~ (n >> 13)) * 1274126177) % 4294967296
  return ((n ~ (n >> 16)) % 65536) / 65536
end
local function hex(r, g, b) return string.format("#%02x%02x%02x", r, g, b) end
local function set(t) local s = {} for _, k in ipairs(t) do s[k] = true end return s end
local function lumh(h) return .3 * tonumber(h:sub(2, 3), 16) + .59 * tonumber(h:sub(4, 5), 16) + .11 * tonumber(h:sub(6, 7), 16) end

local ROCK = set{ "#34222d", "#402c38", "#5a4150", "#262c3c", "#303850", "#46506a", "#2e2a34", "#3a3642", "#524e5e",
  "#232a28", "#2e3a34", "#445850" }
local PATH = set{ "#d9a85c", "#ecc989", "#f6e3b4", "#f5c95a", "#a8743a" }
local DX = set{ "#3f8fb0", "#25637d", "#a9d6ea", "#e46a9b", "#c8d77a", "#e0501f", "#f08a24", "#8b8f96", "#5b6470", "#74462a",
  "#8a4f2a", "#eef8f2", "#fff3c8", "#a2d2d2", "#9a6b3f", "#dd3a2a", "#f2793a" }
local WATER = set{ "#3f8fb0", "#25637d", "#a9d6ea", "#a2d2d2" }

---------------------------------------------------------------- palettes
local TR = {
  oak    = { "#a8d860", "#64a845", "#3c7c3e", "#245038" },
  pine   = { "#74b878", "#3e8e58", "#26623f", "#163a2e" },
  maple  = { "#ffbd62", "#ec7a3c", "#b44c32", "#6e2a2e" },
  aspen  = { "#ffe070", "#e0aa30", "#a8742a", "#6a4426" },
  birch  = { "#dcef90", "#a8cc5e", "#6c9c48", "#3e6a3a" },
  cypress= { "#6aa864", "#346e48", "#1f4c36", "#14302a" },
  olive  = { "#d4dca4", "#9eac76", "#6a7a52", "#454e3a" },
  palm   = { "#a8e474", "#56ac4a", "#2e7038", "#1c4a30" },
  jungle = { "#a4e872", "#46b052", "#22743c", "#154a2c" },
  ceiba  = { "#ffb8d4", "#f07aa8", "#c04c84", "#7a2c5e" },
  ipe    = { "#fff07a", "#f2c83a", "#c0902a", "#7a5a26" },
  fruit  = { "#b4e068", "#70b048", "#447e3c", "#28503a" },
  fir    = { "#6aa88a", "#3a7a62", "#245a4a", "#163a34" },
}
local TRUNK = { "#b07a4a", "#7a4e30" }
local HOUSE = {
  cabin  = { w = { "#d49a62", "#a86c40", "#74462c" }, r = { "#7aa070", "#4e7a50", "#2f5440", "#1e3a30" } },
  thatch = { w = { "#f4e4c4", "#d8c09a", "#a88a6a" }, r = { "#ecc670", "#c89a44", "#8e6630", "#5a4024" } },
  terra  = { w = { "#f6ead2", "#e0caa6", "#b09878" }, r = { "#f48a5a", "#d4583a", "#9a3a32", "#62262a" } },
  adobe  = { w = { "#f0be8e", "#d0905e", "#9a6040" }, r = { "#f6d0a4", "#d8a070", "#a06a48", "#6a4030" }, flat = true },
  pink   = { w = { "#ffc8dc", "#f08cb0", "#b85a84" }, r = { "#f48a5a", "#d4583a", "#9a3a32", "#62262a" } },
  lemon  = { w = { "#fff0a0", "#f2d050", "#b8963a" }, r = { "#6ad0d0", "#3a9ab0", "#2a6a8a", "#1e4466" } },
  sky    = { w = { "#c8ecff", "#82c4ec", "#5a8ac0" }, r = { "#f48a5a", "#d4583a", "#9a3a32", "#62262a" } },
  stilt  = { w = { "#d8b070", "#a8803e", "#76582c" }, r = { "#e8d070", "#c0a040", "#8a7030", "#5a4824" }, stilt = true },
  timber = { w = { "#f4ead8", "#ddd0b8", "#a89a86" }, r = { "#c86a4a", "#9a4434", "#6e2e2e", "#4a2228" }, beams = true },
  izba   = { w = { "#e8b47a", "#c08450", "#8a5a3a" }, r = { "#b4dcf0", "#78a8cc", "#4e78a0", "#34506e" }, trim = "#5ac0e0" },
}
local CROP = {
  wheat = { "#f2d274", "#d4ae4c" }, green = { "#a4d66a", "#7cb854" }, rape = { "#f8e25c", "#d8c040" },
  tulipR = { "#ee5a5e", "#78b452" }, tulipY = { "#f8d44c", "#78b452" }, tulipP = { "#f794b4", "#78b452" },
  soil = { "#ac784c", "#865a3a" }, hay = { "#e2c274", "#b89a52" }, corn = { "#cad462", "#94a848" },
  maize = { "#dcc462", "#a89042" }, chili = { "#dc4e3c", "#6a9a44" }, cane = { "#b8e27c", "#78ba58" },
  banana = { "#62b252", "#3e8442" }, coffee = { "#52a04c", "#2f703e" }, lav = { "#ac94de", "#7c66b6" },
  sun = { "#f8cc3c", "#7a9a3a" }, rye = { "#cfc094", "#a89a72" }, past = { "#a0d06c", "#8abc5c" },
  vine = { "#c89c5c", "#5a9a3e" }, agave = { "#b88c62", "#6aa8a0" }, tea = { "#6ab85a", "#3c8a48" },
}

---------------------------------------------------------------- regions
local REG = {
  NA = { seed = 11, hedge = { "#2a5232", "#3e7038" },
    zones = { { .44, "forest", { "pine", "pine", "oak", "pine", "fir", "maple", "pine", "oak", "aspen", "fir" } }, { .55, "meadow" },
              { .70, "fields", { "corn", "hay", "soil", "green", "past" } }, { 1, "forest", { "pine", "oak", "fir", "pine", "maple", "fir" } } },
    flowers = { "#f5809f", "#ffe38a", "#c9b2f0" },
    marks = { { "pond", 9, 1, lodge = true }, { "village", 11, 2, style = "cabin" }, { "pond", 7, 1 }, { "rocks", 5, 3, moss = true } } },
  CA = { seed = 23, hedge = { "#8a5a3e", "#b07a52" },
    zones = { { .40, "scrub", { "agave", "cactus", "palm" } }, { .62, "fields", { "maize", "agave", "soil", "maize", "chili", "agave" } },
              { .74, "grove", { "palm", "oak", "palm" } }, { 1, "rocky" } },
    flowers = { "#ff8a5c", "#ffe38a", "#f5809f" },
    marks = { { "volcano", 13, 1 }, { "village", 11, 2, style = "adobe" }, { "rocks", 5, 3 }, { "mesa", 9, 1 } } },
  CB = { seed = 37, hedge = { "#2a6a46", "#3e8a4e" }, coast = true,
    zones = { { .42, "grove", { "palm", "palm", "jungle" } }, { .62, "fields", { "cane", "banana", "cane", "soil" } },
              { 1, "forest", { "jungle", "palm", "jungle", "jungle", "palm", "ceiba", "jungle", "fruit" } } },
    flowers = { "#f5809f", "#ffe38a", "#ff8a5c" },
    marks = { { "lighthouse", 7, 1 }, { "village", 11, 2, styles = { "pink", "lemon", "sky" } }, { "wreck", 7, 1 }, { "rocks", 4, 2 } },
    critter = "flamingo" },
  SA = { seed = 41, hedge = { "#1a5030", "#2a7040" },
    zones = { { .54, "forest", { "jungle", "jungle", "jungle", "ceiba", "jungle", "palm", "jungle", "ipe", "jungle" } }, { .66, "fields", { "coffee", "tea", "banana", "coffee" } },
              { 1, "forest", { "jungle", "palm", "jungle", "jungle", "ipe", "jungle" } } },
    flowers = { "#f5809f", "#ffe38a", "#ff8a5c" },
    marks = { { "pond", 9, 1, lily = true }, { "village", 9, 1, style = "stilt" }, { "peaks", 11, 1 }, { "rocks", 5, 2, moss = true } },
    bridges = 2, critter = "macaw" },
  NWE = { seed = 53, hedge = { "#2e6238", "#4c8a44" },
    zones = { { .36, "grove", { "oak", "oak", "birch" } }, { .76, "fields", { "wheat", "green", "rape", "tulipR", "past", "tulipY", "past", "tulipP" } },
              { 1, "meadow" } },
    flowers = { "#f5809f", "#ffe38a", "#fff0c0" },
    marks = { { "windmill", 8, 2 }, { "village", 11, 2, style = "timber" }, { "stones", 7, 1 }, { "pond", 7, 1 } },
    critter = "sheep" },
  SE = { seed = 67, hedge = { "#a89878", "#d6c8a4" },
    zones = { { .40, "orchard", "olive" }, { .70, "fields", { "vine", "wheat", "lav", "vine", "orchard:olive", "hay" } },
              { 1, "scrub", { "cypress", "olive", "cypress" } } },
    flowers = { "#ac94de", "#ffe38a", "#f5809f" },
    marks = { { "temple", 9, 1 }, { "village", 11, 2, style = "terra" }, { "rocks", 5, 2 }, { "cypressrow", 8, 2 } },
    bridges = 1, critter = "goat" },
  EE = { seed = 79, hedge = { "#6a5040", "#9a7858" }, snow = true,
    zones = { { .42, "forest", { "birch", "fir", "birch", "fir", "aspen" } }, { .70, "fields", { "sun", "wheat", "rye", "soil", "sun" } },
              { 1, "snowfield", { "fir", "fir", "birch" } } },
    flowers = { "#ffe38a", "#c9b2f0", "#e8eef0" },
    marks = { { "church", 9, 1 }, { "village", 11, 2, style = "izba" }, { "pond", 8, 1, ice = true }, { "stork", 5, 1 }, { "rocks", 4, 2, snow = true } } },
}
local ORDER = { "NA", "CA", "CB", "SA", "NWE", "SE", "EE" }

---------------------------------------------------------------- one map
local function build(name)
  local cfg = REG[name]
  local img = Image{ fromFile = d .. "/base/map-" .. name .. ".png" }
  local W, H = img.width, img.height
  local pc = app.pixelColor
  local pix, base, CL = {}, {}, {}   -- CL: 1 ground, 2 path, 3 detail, 4 rock
  local cnt = {}
  for y = 0, H - 1 do for x = 0, W - 1 do
    local v = img:getPixel(x, y)
    local k = hex(pc.rgbaR(v), pc.rgbaG(v), pc.rgbaB(v))
    pix[y * W + x] = k; base[y * W + x] = k; cnt[k] = (cnt[k] or 0) + 1
  end end
  for i = 0, W * H - 1 do
    local k = pix[i]
    if ROCK[k] then CL[i] = 4 elseif PATH[k] then CL[i] = 2
    elseif DX[k] or k == INK or cnt[k] < 400 then CL[i] = 3 else CL[i] = 1 end
  end
  for y = 0, H - 1 do for x = 0, W - 1 do   -- coast ink rim counts as rock
    local i = y * W + x
    if pix[i] == INK then
      for _, q in ipairs({ { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } }) do
        local xx, yy = x + q[1], y + q[2]
        if xx >= 0 and yy >= 0 and xx < W and yy < H and ROCK[pix[yy * W + xx]] then CL[i] = 4 break end
      end
    end
  end end
  local function dist(pred)
    local D = {}
    for i = 0, W * H - 1 do D[i] = pred(i) and 0 or 999 end
    for y = 0, H - 1 do for x = 0, W - 1 do
      local i = y * W + x; local v = D[i]
      if x > 0 then v = min(v, D[i - 1] + 1) end
      if y > 0 then v = min(v, D[i - W] + 1); if x > 0 then v = min(v, D[i - W - 1] + 1.41) end; if x < W - 1 then v = min(v, D[i - W + 1] + 1.41) end end
      D[i] = v
    end end
    for y = H - 1, 0, -1 do for x = W - 1, 0, -1 do
      local i = y * W + x; local v = D[i]
      if x < W - 1 then v = min(v, D[i + 1] + 1) end
      if y < H - 1 then v = min(v, D[i + W] + 1); if x < W - 1 then v = min(v, D[i + W + 1] + 1.41) end; if x > 0 then v = min(v, D[i + W - 1] + 1.41) end end
      D[i] = v
    end end
    return D
  end
  local dP = dist(function(i) return CL[i] == 2 end)
  local dD = dist(function(i) return CL[i] == 3 end)
  local dR = dist(function(i) return CL[i] == 4 end)
  local dW = dist(function(i) return WATER[base[i]] == true end)
  local RES = {}
  local S = cfg.seed

  local TEX = { p = 3, d = 2, res = true }
  local SPR = { p = 2, d = 1 }
  local function ok(x, y, lv)
    if x < 1 or y < 1 or x >= W - 1 or y >= H - 1 then return false end
    local i = y * W + x
    if CL[i] ~= 1 or dP[i] < lv.p or dD[i] < lv.d then return false end
    if lv.res and RES[i] then return false end
    return true
  end
  local function put(x, y, col, lv) if ok(x, y, lv or SPR) then pix[y * W + x] = col end end
  local function get(x, y) return pix[y * W + x] end
  local function shadeAt(x, y, t, lv) if ok(x, y, lv or SPR) then pix[y * W + x] = mix(pix[y * W + x], SHC, t) end end
  local function castShadow(m, t, len, lv)
    local done = {}
    m:each(function(x, y)
      for k = 1, len or 2 do
        local sx, sy = x + k, y + 1
        if not m:has(sx, sy) and not done[sy * W + sx] then done[sy * W + sx] = true shadeAt(sx, sy, t, lv) end
      end
    end)
  end
  local function rim(m, col, lv) m:grow(1):cut(m):each(function(x, y) put(x, y, col, lv) end) end
  local function lit(m, R, cx, cy, rr, nz, lv)
    m:each(function(x, y)
      local l = -((x - cx) + (y - cy) * 1.1) / (rr * 1.5) + ((hash(x, y, S + 3) - .5) * (nz or .3))
      local c = l > .38 and R[1] or (l > -.12 and R[2] or (l > -.55 and R[3] or R[4] or R[3]))
      if not m:has(x + 1, y + 1) and not m:has(x, y + 1) then c = R[4] or R[3] end
      put(x, y, c, lv)
    end)
  end
  local function zoneAt(x, y)
    return GX.vn(x, y, 34, S) * .7 + GX.vn(x, y, 11, S + 1) * .3
  end
  local function zoneKind(x, y)
    local n = zoneAt(x, y)
    for _, z in ipairs(cfg.zones) do if n <= z[1] then return z end end
    return cfg.zones[#cfg.zones]
  end

  ---------------------------------------------------------- sprites
  local function tree(x, y, kind, s, lv, opt)
    opt = opt or {}
    local R = TR[kind] or TR.oak
    local m = HP.mask()
    local cx, cy
    if kind == "pine" or kind == "fir" then
      local h = s * 2 + 2
      cx, cy = x, y - floor(h / 2) - 1
      for r = 0, h - 1 do
        local hw = floor((r + 1) * s / h + .5)
        if r % 3 == 0 and r > 0 then hw = hw - 1 end
        for xx = x - hw, x + hw do m:set(xx, y - 1 - h + r) end
      end
      m:each(function(xx, yy)
        local c = xx < x and R[1] or (xx == x and R[2] or R[3])
        if xx < x - 1 and hash(xx, yy, S) > .7 then c = R[2] end
        if not m:has(xx, yy + 1) then c = R[4] end
        if (cfg.snow or opt.snow) and xx <= x and (not m:has(xx, yy - 1) or not m:has(xx - 1, yy)) then c = "#e4ecf0" end
        m.c = m.c or {}; m.c[yy * W + xx] = c
      end)
      castShadow(m, .3, 2, lv)
      m:each(function(xx, yy) put(xx, yy, m.c[yy * W + xx], lv) end)
      put(x, y, TRUNK[2], lv)
      return m
    elseif kind == "cypress" then
      for yy = y - 2 * s - 1, y - 1 do
        local t = (yy - (y - 2 * s - 1)) / (2 * s)
        local hw = t < .15 and 0 or 1
        for xx = x - hw, x + hw do m:set(xx, yy) end
      end
      castShadow(m, .3, 3, lv)
      m:each(function(xx, yy) put(xx, yy, xx < x and R[1] or (xx == x and R[2] or R[3]), lv) end)
      put(x, y, TRUNK[2], lv)
      return m
    elseif kind == "palm" then
      local lean = (hash(x, y, S + 9) > .5) and 1 or -1
      local h = s + 3
      local tx, ty = x + lean * 2, y - h
      local tm = HP.line({ { x, y }, { x + lean, y - floor(h / 2) }, { tx, ty } }, 1)
      local fr = HP.mask()
      for _, f in ipairs({ { -4, 1 }, { 4, 1 }, { -3, -2 }, { 3, -2 }, { 0, -3 }, { -2, 2 }, { 2, 2 } }) do
        fr:add(HP.line({ { tx, ty }, { tx + f[1], ty + f[2] } }, 1))
      end
      local all = tm:copy():add(fr)
      castShadow(all, .28, 2, lv)
      tm:each(function(xx, yy) put(xx, yy, ((yy % 2 == 0) and TRUNK[1] or TRUNK[2]), lv) end)
      fr:each(function(xx, yy) put(xx, yy, yy < ty and R[1] or (yy == ty and R[2] or R[3]), lv) end)
      put(tx, ty, R[4], lv); put(tx + lean, ty + 1, "#8a5a2a", lv)
      return all
    elseif kind == "birch" then
      local th = s + 1
      local cm = HP.ellipse(x, y - th - s + 1, max(2, s - 1), s)
      local tm = HP.rect(x, y - th, x, y)
      local all = cm:copy():add(tm)
      castShadow(all, .28, 2, lv)
      tm:each(function(xx, yy) put(xx, yy, (yy % 3 == 0) and "#4a3c44" or "#e8e2d6", lv) end)
      lit(cm, R, x - 1, y - th - s, s, .5, lv)
      return all
    elseif kind == "cactus" then
      m:add(HP.rect(x, y - s - 2, x, y)); m:add(HP.rect(x - 2, y - s, x - 2, y - s + 2)); m:set(x - 1, y - s + 2)
      m:add(HP.rect(x + 2, y - s + 1, x + 2, y - s + 2)); m:set(x + 1, y - s + 2)
      castShadow(m, .3, 2, lv)
      m:each(function(xx, yy) put(xx, yy, xx < x and "#8ad060" or (xx == x and "#4a9a44" or "#2a6a36"), lv) end)
      put(x, y - s - 3, "#f08aa0", lv)
      return m
    elseif kind == "agave" then
      for _, f in ipairs({ { -2, -1 }, { -1, -2 }, { 0, -3 }, { 1, -2 }, { 2, -1 }, { -1, -1 }, { 0, -1 }, { 1, -1 }, { 0, -2 }, { -3, 0 }, { 3, 0 }, { -1, 0 }, { 0, 0 }, { 1, 0 } }) do m:set(x + f[1], y + f[2]) end
      castShadow(m, .25, 1, lv)
      m:each(function(xx, yy) put(xx, yy, (xx < x and yy < y) and "#a6dcc8" or (xx <= x and "#62a8a0" or "#3a7a7a"), lv) end)
      return m
    end
    -- round canopy (oak, maple, aspen, jungle, ceiba, olive, fruit, ipe)
    local ry = max(1, s - 1)
    cx, cy = x, y - s - 1
    m:add(HP.ellipse(cx, cy, s, ry))
    if s >= 3 then
      m:add(HP.ellipse(cx - s + 1, cy + 1, max(1, s - 2), max(1, ry - 1))); m:add(HP.ellipse(cx + s - 1, cy + 1, max(1, s - 2), max(1, ry - 1)))
    end
    local tm = HP.rect(x, cy + ry, x, y)
    if s >= 4 then tm:add(HP.rect(x - 1, y, x + 1, y)) end
    local all = m:copy():add(tm)
    castShadow(all, .3, 2, lv)
    tm:each(function(xx, yy) put(xx, yy, xx < x and TRUNK[1] or TRUNK[2], lv) end)
    lit(m, R, cx - 1, cy - 1, s, .45, lv)
    if s >= 3 then put(cx - floor(s / 2), cy - floor(ry / 2), mix(R[1], "#fff4d6", .45), lv) end
    if kind == "fruit" then
      for k = 1, 3 do local fx, fy = cx - s + 1 + floor(hash(x, k, S + 5) * (2 * s - 1)), cy - 1 + floor(hash(y, k, S + 6) * (ry + 1))
        if m:has(fx, fy) then put(fx, fy, k == 2 and "#f5b82e" or "#e8493b", lv) end end
    end
    if cfg.snow and opt.snow ~= false then m:each(function(xx, yy) if not m:has(xx, yy - 1) and xx <= cx then put(xx, yy, "#e4ecf0", lv) end end) end
    return all
  end

  local function house(x, y, st, w, smoke, lv)
    local Hs = HOUSE[st]
    w = w or 6
    local wh = Hs.flat and 4 or 3
    local rh = Hs.flat and 1 or floor(w / 2) + 1
    if Hs.stilt then y = y - 2 end
    local wall = HP.rect(x, y - wh + 1, x + w - 1, y)
    local roof = HP.mask()
    if Hs.flat then roof:add(HP.rect(x - 1, y - wh, x + w, y - wh))
    else for j = 0, rh - 1 do for xx = x - 1 + j, x + w - j do roof:set(xx, y - wh - j) end end end
    local chim = (not Hs.flat) and HP.rect(x + w - 2, y - wh - rh + 1, x + w - 2, y - wh - rh + 2) or HP.mask()
    local stl = HP.mask()
    if Hs.stilt then stl:add(HP.rect(x, y + 1, x, y + 2)); stl:add(HP.rect(x + w - 1, y + 1, x + w - 1, y + 2)) end
    local all = wall:copy():add(roof):add(chim):add(stl)
    castShadow(all, .34, 2, lv)
    wall:each(function(xx, yy)
      local c = xx == x and Hs.w[1] or (xx >= x + w - 2 and Hs.w[3] or Hs.w[2])
      if Hs.beams and (xx == x + 1 or xx == x + w - 2 or yy == y - wh + 1) then c = "#6a4436" end
      put(xx, yy, c, lv)
    end)
    roof:each(function(xx, yy)
      local c
      if Hs.flat then c = (xx < x + w - 1) and Hs.r[1] or Hs.r[2]
      else
        local mid = x + (w - 1) / 2
        c = (not roof:has(xx, yy - 1)) and Hs.r[1] or (xx < mid and Hs.r[2] or Hs.r[3])
        if yy == y - wh then c = Hs.r[4] end
        if (yy + xx) % 3 == 0 and c == Hs.r[2] then c = mix(Hs.r[2], Hs.r[3], .5) end
      end
      put(xx, yy, c, lv)
    end)
    if Hs.flat then for xx = x, x + w - 1, 2 do put(xx, y - wh + 1, Hs.w[3], lv) end end
    chim:each(function(xx, yy) put(xx, yy, yy == y - wh - rh + 1 and "#aaa9b8" or "#74758c", lv) end)
    stl:each(function(xx, yy) put(xx, yy, TRUNK[2], lv) end)
    local dx = x + floor(w / 2)
    put(dx, y, "#51302b", lv); put(dx, y - 1, "#51302b", lv)
    put(x + 1, y - 1, "#f5c95a", lv)
    if w >= 7 then put(x + w - 2, y - 1, "#f5c95a", lv) end
    if Hs.trim then put(x, y - wh + 1, Hs.trim, lv); put(x + w - 1, y - wh + 1, Hs.trim, lv) end
    rim(all, INK, lv)
    if smoke and not Hs.flat then
      local sx, sy = x + w - 2, y - wh - rh
      for k = 1, 5 do
        local px = sx + floor(sin(k * 1.2 + x) * 1.4 + k * .5)
        local py = sy - k * 2
        local c = (k % 2 == 1) and "#e6dfd8" or "#bfb6c0"
        put(px, py, c, lv); if k >= 2 then put(px + 1, py, c, lv); put(px, py - 1, mix(c, "#fff4d6", .3), lv) end
        if k >= 4 then put(px + 1, py - 1, "#bfb6c0", lv) end
      end
    end
    return all
  end

  local function rocks(cx, cy, r, opt, lv)
    opt = opt or {}
    local R = opt.R or { "#d8d2cc", "#a8a0a0", "#74707e", "#4a4658" }
    local n = r >= 5 and 3 or 2
    local all = HP.mask()
    local parts = {}
    for k = 1, n do
      local ox, oy = floor((hash(cx, k, S + 11) - .5) * r * 1.4), floor((hash(cy, k, S + 12) - .5) * r * .6)
      local rr = max(2, r - k)
      local pts = {}
      for a = 0, 5 do
        local ang = a / 6 * 2 * pi + hash(k, a, S) * .5
        local rad = rr * (.75 + hash(a, k, S + 13) * .35)
        pts[#pts + 1] = { cx + ox + cos(ang) * rad, cy + oy + sin(ang) * rad * .75 - rr * .3 }
      end
      local m = HP.poly(pts)
      parts[#parts + 1] = { m, cx + ox, cy + oy - floor(rr * .3), rr }
      all:add(m)
    end
    castShadow(all, .36, 2, lv)
    table.sort(parts, function(a, b) return a[3] < b[3] end)
    for _, p in ipairs(parts) do
      lit(p[1], R, p[2] - 1, p[3] - 1, p[4], .25, lv)
      p[1]:each(function(x, y)
        if not p[1]:has(x, y - 1) then
          if opt.moss then put(x, y, "#7cc35a", lv) elseif opt.snow then put(x, y, "#e8eef2", lv) end
        end
      end)
    end
    rim(all, INK, lv)
    return all
  end

  local function pond(cx, cy, r, opt, lv)
    opt = opt or {}
    local m = HP.mask()
    local ry = r * .62
    for y = floor(cy - ry - 2), floor(cy + ry + 2) do for x = floor(cx - r - 2), floor(cx + r + 2) do
      local a = math.atan(y - cy, x - cx)
      local rad = 1 + (sin(a * 3 + S) * .08 + sin(a * 5 + cx) * .06)
      if ((x - cx) / (r * rad)) ^ 2 + ((y - cy) / (ry * rad)) ^ 2 <= 1 then m:set(x, y) end
    end end
    local Wt = opt.ice and { "#e4f0f6", "#b6d8e8", "#8ab8d4", "#6a94b8" } or { "#b6f0e0", "#5fc4c8", "#3a86b0", "#2a5a8a" }
    local inner = m:shrink(2)
    local shore = m:grow(1):cut(m)
    shore:each(function(x, y) put(x, y, (y < cy) and "#5a4a3a" or "#c8b07a", lv) end)
    m:each(function(x, y)
      local c = inner:has(x, y) and Wt[3] or Wt[2]
      if inner:shrink(2):has(x, y) then c = Wt[4] end
      if not m:has(x, y - 1) then c = Wt[4] end   -- dark bank shadow at the top edge
      put(x, y, c, lv)
    end)
    -- reflection of the far shore tree
    local tx = floor(cx - r * .3)
    for k = 0, 2 do for j = -1, 1 do if m:has(tx + j, floor(cy - ry) + 2 + k) and (k < 2 or j == 0) then put(tx + j, floor(cy - ry) + 2 + k, mix(Wt[4], "#24503a", .5), lv) end end end
    -- ripples and glints (upper-left lit)
    for k = 0, 2 do
      local rx, ry2 = floor(cx - r * .45 + k * 3), floor(cy - 1 + k * 2 - (k == 2 and 3 or 0))
      if m:has(rx, ry2) and m:has(rx + 2, ry2) then put(rx, ry2, Wt[1], lv); put(rx + 1, ry2, Wt[1], lv); put(rx + 2, ry2, Wt[2], lv) end
    end
    -- foam on the lit shore
    m:each(function(x, y) if not opt.ice and (not m:has(x + 1, y) or not m:has(x, y + 1)) and hash(x, y, S + 21) > .45 then put(x, y, "#e2f2ea", lv) end end)
    if opt.ice then for k = 0, 3 do put(floor(cx - 2 + k), floor(cy - k + 1), "#f0f4f2", lv) end end
    tree(tx, floor(cy - ry) - 1, (cfg.snow and "fir") or (name == "SA" and "jungle") or "pine", 3, lv)
    if opt.lodge then
      local lm = HP.ellipse(cx + 2, cy + 1, 3, 2)
      lm:each(function(x, y) put(x, y, ((x + y) % 2 == 0) and "#8a5a36" or "#6a4430", lv) end)
      put(cx + 1, cy - 1, "#b07a4a", lv); put(cx + 3, cy - 1, "#b07a4a", lv); put(cx, cy + 3, "#51302b", lv)
      rim(lm, INK, lv)
      put(cx - 3, cy + 2, "#b6f0e0", lv); put(cx - 4, cy + 2, "#7a4e30", lv)   -- swimming beaver wake
    end
    if opt.lily then
      for k = 1, 6 do
        local lx, ly = floor(cx + (hash(k, 1, S) - .5) * r * 1.4), floor(cy + (hash(k, 2, S) - .5) * ry * 1.2)
        local pm = HP.ellipse(lx, ly, 2, 1)
        pm:each(function(x, y) if m:has(x, y) then put(x, y, (y < ly) and "#9ee470" or "#46b052", lv) end end)
        if m:has(lx + 2, ly) then put(lx + 2, ly, "#22743c", lv) end
        if k % 2 == 0 then put(lx, ly - 1, "#f590b0", lv) end
      end
    end
    return m
  end

  ---------------------------------------------------------- landmark sprites
  local function village(cx, cy, mk, lv)
    local styles = mk.styles or { mk.style }
    local spots = { { -6, -3 }, { 4, -5 }, { -1, 4 }, { 9, 3 }, { -10, 5 } }
    local n = 3 + floor(hash(cx, cy, S) * 2.99)
    -- garden plots and fence first
    for k = 0, 5 do put(cx - 12 + k * 2, cy + 8, "#8a5a36", lv); put(cx - 12 + k * 2, cy + 7, "#b07a4a", lv) end
    for yy = cy - 9, cy - 8 do for xx = cx - 12, cx - 7 do put(xx, yy, (xx % 2 == 0) and "#6aa848" or "#86583a", lv) end end
    local hs = {}
    for k = 1, n do hs[#hs + 1] = spots[k] end
    table.sort(hs, function(a, b) return a[2] < b[2] end)
    for k, s in ipairs(hs) do
      house(cx + s[1] - 3, cy + s[2], styles[1 + (k - 1) % #styles], 6 + (k == 2 and 1 or 0), k == 2, lv)
    end
  end
  local function windmill(cx, cy, lv)
    local tw = HP.poly({ { cx - 3, cy + 1 }, { cx - 2, cy - 9 }, { cx + 2, cy - 9 }, { cx + 3, cy + 1 } })
    local cap = HP.poly({ { cx - 3, cy - 9 }, { cx, cy - 13 }, { cx + 3, cy - 9 } })
    local sails = HP.mask()
    local hx, hy = cx, cy - 10
    for _, dd in ipairs({ { -1, -1 }, { 1, -1 }, { -1, 1 }, { 1, 1 } }) do
      for k = 1, 7 do sails:set(hx + dd[1] * k, hy + dd[2] * k) end
      for k = 3, 7 do sails:set(hx + dd[1] * k + dd[1], hy + dd[2] * k) end
    end
    local all = tw:copy():add(cap):add(sails)
    castShadow(tw:copy():add(cap), .34, 3, lv)
    tw:each(function(x, y) put(x, y, x < cx - 1 and "#f4e4c4" or (x <= cx and "#d8c09a" or "#a88a6a"), lv) end)
    cap:each(function(x, y) put(x, y, x < cx and "#c8584a" or "#8a3434", lv) end)
    sails:each(function(x, y) put(x, y, ((x + y) % 2 == 0) and "#e6dccc" or "#8a6a4a", lv) end)
    put(cx, cy, "#51302b", lv); put(cx, cy - 1, "#51302b", lv); put(cx - 1, cy - 5, "#f5c95a", lv)
    put(hx, hy, "#5a4a3a", lv)
    rim(all, INK, lv)
  end
  local function volcano(cx, cy, lv)
    local m = HP.poly({ { cx - 13, cy + 3 }, { cx - 3, cy - 11 }, { cx + 3, cy - 11 }, { cx + 13, cy + 3 } })
    castShadow(m, .3, 3, lv)
    local R = { "#c89a6c", "#9a6a4a", "#6e4836", "#4a2e2c" }
    m:each(function(x, y)
      local l = (cx - x) / 10 - (y - cy) / 30 + (hash(x, y, S) - .5) * .3
      local c = l > .35 and R[1] or (l > -.15 and R[2] or (l > -.6 and R[3] or R[4]))
      if (x + floor(y / 2)) % 5 == 0 and c ~= R[1] then c = mix(c, R[4], .4) end
      put(x, y, c, lv)
    end)
    for x = cx - 2, cx + 2 do put(x, cy - 11, "#f08a24", lv) end
    put(cx - 1, cy - 10, "#e8493b", lv); put(cx, cy - 10, "#ffe38a", lv); put(cx + 1, cy - 10, "#e8493b", lv)
    put(cx + 1, cy - 9, "#e8493b", lv); put(cx + 2, cy - 7, "#e8493b", lv); put(cx + 2, cy - 6, "#b52e3f", lv)  -- lava trickle
    rim(m, INK, lv)
    -- quirk: the smoke puff is a little heart
    local hp = { "..xx.xx..", ".xxxxxxx.", ".xxxxxxx.", "..xxxxx..", "...xxx...", "....x...." }
    for r, row in ipairs(hp) do for k = 1, #row do if row:sub(k, k) == "x" then
      local x, y = cx - 4 + k - 1 + 2, cy - 22 + r
      put(x, y, (k < 5 and r < 3) and "#e6dfd8" or "#c8bcc4", lv)
    end end end
    put(cx, cy - 13, "#bfb6c0", lv); put(cx + 1, cy - 14, "#bfb6c0", lv); put(cx + 1, cy - 15, "#e6dfd8", lv)
  end
  local function mesa(cx, cy, lv)
    local m = HP.poly({ { cx - 9, cy + 2 }, { cx - 7, cy - 6 }, { cx + 6, cy - 6 }, { cx + 9, cy + 2 } })
    castShadow(m, .3, 3, lv)
    m:each(function(x, y)
      local c = (y == cy - 6) and "#f0be8e" or (x < cx - 3 and "#d0905e" or (x < cx + 4 and "#b0704a" or "#7e4a36"))
      if (y - cy) % 3 == 0 and y > cy - 6 then c = mix(c, "#6e2038", .3) end
      put(x, y, c, lv)
    end)
    rim(m, INK, lv)
    tree(cx + 3, cy - 7, "cactus", 2, lv)
  end
  local function lighthouse(cx, cy, lv)
    local m = HP.poly({ { cx - 2, cy + 1 }, { cx - 1, cy - 11 }, { cx + 1, cy - 11 }, { cx + 2, cy + 1 } })
    local lamp = HP.rect(cx - 1, cy - 14, cx + 1, cy - 12)
    local all = m:copy():add(lamp):add(HP.rect(cx, cy - 15, cx, cy - 15))
    castShadow(all, .34, 3, lv)
    m:each(function(x, y)
      local red = floor((cy - y) / 3) % 2 == 0
      put(x, y, red and (x < cx and "#ff8a5c" or "#b52e3f") or (x < cx and "#fff4d6" or "#d8c8b4"), lv)
    end)
    lamp:each(function(x, y) put(x, y, (x == cx) and "#ffe38a" or "#f5b82e", lv) end)
    put(cx, cy - 15, "#b52e3f", lv)
    rim(all, INK, lv)
    for k = 2, 5 do put(cx - 1 - k, cy - 13 + floor(k / 3), "#ffe38a", lv); put(cx + 1 + k, cy - 13 + floor(k / 3), "#ffe38a", lv) end  -- beam
  end
  local function wreck(cx, cy, lv)
    local m = HP.poly({ { cx - 6, cy - 2 }, { cx + 5, cy - 1 }, { cx + 3, cy + 2 }, { cx - 4, cy + 2 } })
    local mast = HP.line({ { cx, cy - 2 }, { cx + 3, cy - 9 } }, 1)
    local all = m:copy():add(mast)
    for yy = cy - 2, cy + 4 do for xx = cx - 9, cx + 9 do if ((xx - cx) / 9) ^ 2 + ((yy - cy - 1) / 4) ^ 2 <= 1 then put(xx, yy, ((xx + yy) % 5 == 0) and "#d8c080" or "#ead292", lv) end end end
    castShadow(all, .3, 2, lv)
    m:each(function(x, y) put(x, y, (y <= cy - 1) and "#b97a4a" or ((x % 3 == 0) and "#51302b" or "#864c33"), lv) end)
    mast:each(function(x, y) put(x, y, "#e8b982", lv) end)
    put(cx + 2, cy - 7, "#e6dccc", lv); put(cx + 1, cy - 6, "#e6dccc", lv); put(cx + 2, cy - 6, "#bfb6c0", lv)
    rim(all, INK, lv)
    put(cx - 7, cy + 3, "#f5b82e", lv); put(cx - 8, cy + 3, "#8a4f2a", lv)   -- a spilled treasure chest corner
  end
  local function temple(cx, cy, lv)
    local base = HP.rect(cx - 7, cy - 1, cx + 7, cy + 1)
    local cols = HP.mask()
    for k = 0, 3 do if k ~= 2 then cols:add(HP.rect(cx - 6 + k * 4, cy - 8, cx - 5 + k * 4, cy - 2)) else cols:add(HP.rect(cx - 6 + k * 4, cy - 4, cx - 5 + k * 4, cy - 2)) end end
    local top = HP.rect(cx - 7, cy - 10, cx + 2, cy - 9)
    local ped = HP.poly({ { cx - 7, cy - 10 }, { cx - 3, cy - 13 }, { cx + 1, cy - 10 } })
    local all = base:copy():add(cols):add(top):add(ped)
    castShadow(all, .34, 3, lv)
    base:each(function(x, y) put(x, y, y == cy - 1 and "#f6ead2" or "#c8b494", lv) end)
    cols:each(function(x, y) put(x, y, ((x - cx) % 4 == 2) and "#f6ead2" or "#c8b494", lv) end)
    top:each(function(x, y) put(x, y, y == cy - 10 and "#f6ead2" or "#d8c8a8", lv) end)
    ped:each(function(x, y) put(x, y, x < cx - 3 and "#f6ead2" or "#c8b494", lv) end)
    rim(all, INK, lv)
    -- fallen drum and an amphora
    local dr = HP.rect(cx + 4, cy + 3, cx + 6, cy + 4); dr:each(function(x, y) put(x, y, y == cy + 3 and "#f6ead2" or "#b0a080", lv) end); rim(dr, INK, lv)
    put(cx - 9, cy, "#d4583a", lv); put(cx - 9, cy - 1, "#d4583a", lv); put(cx - 9, cy - 2, "#9a3a32", lv); put(cx - 10, cy, "#9a3a32", lv)
    put(cx - 3, cy - 14, "#7cc35a", lv)   -- a weed on the roof
  end
  local function church(cx, cy, lv)
    local body = HP.rect(cx - 5, cy - 5, cx + 5, cy)
    local tower = HP.rect(cx - 2, cy - 10, cx + 2, cy - 6)
    local dome = HP.mask()
    for _, r in ipairs({ { -13, 0, 0 }, { -12, -1, 1 }, { -11, -2, 2 }, { -10, -3, 3 }, { -9, -3, 3 }, { -8, -2, 2 } }) do for x = cx + r[2], cx + r[3] do dome:set(x, cy + r[1]) end end
    local all = body:copy():add(tower):add(dome)
    castShadow(all, .34, 3, lv)
    body:each(function(x, y) put(x, y, x < cx - 3 and "#f4ece0" or (x < cx + 3 and "#ddd2c4" or "#aa9e94"), lv) end)
    for x = cx - 6, cx + 6 do put(x, cy - 6, (x < cx) and "#5ac0c8" or "#3a86b0", lv) end
    tower:each(function(x, y) put(x, y, x < cx and "#f4ece0" or "#c8beb2", lv) end)
    dome:each(function(x, y) put(x, y, (x < cx and y < cy - 9) and "#ffe38a" or (x <= cx and "#f5b82e" or "#d98322"), lv) end)
    put(cx, cy - 14, "#f5b82e", lv); put(cx, cy - 15, "#f5b82e", lv); put(cx - 1, cy - 14, "#f5b82e", lv); put(cx + 1, cy - 14, "#f5b82e", lv)
    put(cx, cy, "#51302b", lv); put(cx, cy - 1, "#51302b", lv); put(cx - 3, cy - 3, "#5a7ea0", lv); put(cx + 3, cy - 3, "#5a7ea0", lv); put(cx, cy - 8, "#5a7ea0", lv)
    rim(all, INK, lv)
  end
  local function stones(cx, cy, lv)
    for yy = cy - 4, cy + 4 do for xx = cx - 7, cx + 7 do if ((xx - cx) / 7) ^ 2 + ((yy - cy) / 4) ^ 2 <= 1 then put(xx, yy, ((xx + yy) % 2 == 0) and "#a4d06a" or "#94c460", lv) end end end
    local all = HP.mask()
    for k = 0, 6 do
      local a = k / 7 * 2 * pi
      local sx, sy = floor(cx + cos(a) * 6 + .5), floor(cy + sin(a) * 3 + .5)
      local m = HP.rect(sx, sy - 3, sx + 1, sy)
      if k == 3 then m = HP.rect(sx - 1, sy - 1, sx + 2, sy) end   -- quirk: one has toppled over
      castShadow(m, .35, 2, lv)
      m:each(function(x, y) put(x, y, (x == sx and y < sy) and "#e2e0e6" or "#9a98a8", lv) end)
      all:add(m)
    end
    rim(all, INK, lv)
  end
  local function stork(cx, cy, lv)
    local pole = HP.rect(cx, cy - 7, cx, cy)
    local nest = HP.rect(cx - 3, cy - 9, cx + 3, cy - 8)
    local bird = HP.rect(cx - 1, cy - 12, cx + 1, cy - 10)
    local all = pole:copy():add(nest):add(bird)
    castShadow(all, .3, 3, lv)
    pole:each(function(x, y) put(x, y, "#864c33", lv) end)
    nest:each(function(x, y) put(x, y, ((x + y) % 2 == 0) and "#b97a4a" or "#6e4836", lv) end)
    bird:each(function(x, y) put(x, y, (x == cx + 1 and y == cy - 10) and "#3a3042" or "#ece6dc", lv) end)
    put(cx - 1, cy - 13, "#ece6dc", lv); put(cx - 2, cy - 13, "#e8493b", lv); put(cx - 3, cy - 13, "#e8493b", lv)
    rim(all, INK, lv)
  end
  local function peaks(cx, cy, lv)
    for k, p in ipairs({ { -6, 0, 7, 11 }, { 5, 2, 6, 8 }, { 0, 3, 5, 6 } }) do
      local x0, y0, w, h = cx + p[1], cy + p[2], p[3], p[4]
      local m = HP.poly({ { x0 - w, y0 + 1 }, { x0, y0 - h }, { x0 + w, y0 + 1 } })
      castShadow(m, .3, 3, lv)
      m:each(function(x, y)
        local left = x < x0 + (y0 - y) * .1
        local c = left and "#a8a0a0" or "#6a6478"
        if y < y0 - h * .55 then c = left and "#eef0f2" or "#b8c4d4" end
        put(x, y, c, lv)
      end)
      rim(m, INK, lv)
    end
  end
  local function cypressrow(cx, cy, lv)
    for k = -3, 3 do tree(cx + k * 3, cy + floor(k * .5), "cypress", 3, lv) end
  end

  ---------------------------------------------------------- 1. landmarks: pick spots (farthest-point spread)
  local C = {}
  for i = 0, W * H - 1 do C[i] = (CL[i] == 1) and min(dP[i] - 7, dD[i] - 3, dR[i] - 2) or -1 end
  local placed = {}
  local function far(x, y) local b = 1e9 for _, p in ipairs(placed) do b = min(b, sqrt((x - p[1]) ^ 2 + (y - p[2]) ^ 2) - p[3]) end return b end
  local marks = {}
  for _, mk in ipairs(cfg.marks) do
    for n = 1, mk[3] do
     for _, shrink in ipairs({ 0, 2, 3 }) do
      local r = mk[2] - shrink
      local best, bx, by = -1e9, nil, nil
      for y = 6, H - 7, 2 do for x = 6, W - 7, 2 do
        local i = y * W + x
        if C[i] >= r then
          local f = far(x, y) - r
          if mk[1] == "wreck" then f = (dR[i] < 22 and f > 4) and (f + 200 - dR[i]) or -1e8 end
          if f > 4 then
            local sc = min(f, 60) + hash(x, y, S + 17) * 20
            if sc > best then best, bx, by = sc, x, y end
          end
        end
      end end
      if bx then
        placed[#placed + 1] = { bx, by, r }
        marks[#marks + 1] = { mk, bx, by }
        for yy = by - r - 3, by + r + 3 do for xx = bx - r - 3, bx + r + 3 do
          if (xx - bx) ^ 2 + (yy - by) ^ 2 <= (r + 3) ^ 2 and xx >= 0 and yy >= 0 and xx < W and yy < H then RES[yy * W + xx] = true end
        end end
        print(name .. " " .. mk[1] .. " at " .. bx .. "," .. by .. " r" .. r)
        break
      end
     end
    end
  end

  ---------------------------------------------------------- 2. ground textures by zone
  -- coast (Caribbean): sand band and broken foam along the cave shore
  if cfg.coast then
    for y = 1, H - 2 do for x = 1, W - 2 do
      local i = y * W + x
      if ok(x, y, TEX) and dR[i] <= 4.5 then
        local c
        if dR[i] <= 1.5 then c = (hash(x, y, S + 31) > .4) and "#e2f2ea" or "#a8e0d8"
        elseif dR[i] <= 2.5 then c = (hash(x, y, S + 32) > .3) and "#f0dca0" or "#e2f2ea"
        else c = ((x + y) % 4 == 0) and "#dcc078" or "#ead292" end
        pix[i] = c
      end
    end end
  end
  -- shore foam and reeds round the old water (lakes, rivers, pools)
  for y = 1, H - 2 do for x = 1, W - 2 do
    local i = y * W + x
    if ok(x, y, TEX) and dW[i] <= 1.5 and hash(x, y, S + 33) > .35 then pix[i] = cfg.snow and "#e4ecf0" or "#d8eee4"
    elseif ok(x, y, TEX) and dW[i] <= 2.5 and hash(x, y, S + 34) > .82 then pix[i] = "#4e8a3e"; if ok(x, y - 1, TEX) then pix[i - W] = "#7cb852" end end
  end end

  -- fields: rotated parcels
  local ang = (hash(S, 1, 2) - .5) * .7
  local ca, sa = cos(ang), sin(ang)
  local PW, PH = 22, 13
  local function parcel(x, y)
    local u = x * ca + y * sa
    local v = -x * sa + y * ca
    local pu = floor(u / PW)
    local v2 = v + hash(pu, 7, S) * PH
    local pv = floor(v2 / PH)
    return pu, pv, u - pu * PW, v2 - pv * PH
  end
  local parcelOK = {}
  local cropOf = {}
  local fieldsZone
  for _, z in ipairs(cfg.zones) do if z[2] == "fields" then fieldsZone = z end end
  local zprev = 0
  for _, z in ipairs(cfg.zones) do z.lo = zprev; zprev = z[1] end
  local orchardTrees = {}
  local critters = {}
  for y = 2, H - 3 do for x = 2, W - 3 do
    local i = y * W + x
    if ok(x, y, TEX) then
      local z = zoneKind(x, y)
      if z[2] == "fields" or z[2] == "orchard" then
        local pu, pv, fu, fv = parcel(x, y)
        local key = pu * 1000 + pv
        if cropOf[key] == nil then
          if z[2] == "orchard" then cropOf[key] = "orchard:" .. z[3]
          else local L = z[3]; cropOf[key] = L[1 + floor(hash(pu, pv, S + 40) * #L)] end
        end
        local crop = cropOf[key]
        local b = base[i]
        local edgeR = fu >= PW - 1.2 or fv >= PH - 1.2
        local edgeL = fu < 1 or fv < 1
        local col
        if edgeR then
          col = (hash(x, y, S + 41) > .55) and cfg.hedge[2] or cfg.hedge[1]
          if name ~= "SE" and hash(x, y, S + 42) > .8 and ok(x, y - 1, TEX) then pix[i - W] = mix(cfg.hedge[2], "#c4e07a", .4) end
        elseif crop:sub(1, 8) == "orchard:" or crop == "past" then
          local g = (crop == "past") and CROP.past or { "#9cc860", "#88b454" }
          if name == "SE" then g = { "#d8c068", "#c4aa58" } end
          col = ((floor(fu) + floor(fv)) % 2 == 0) and g[1] or g[2]
          if crop ~= "past" and floor(fu) % 5 == 2 and floor(fv) % 5 == 3 then orchardTrees[#orchardTrees + 1] = { x, y + 1, crop:sub(9) } end
          if crop == "past" and floor(fu) % 7 == 3 and floor(fv) % 6 == 3 and hash(pu, pv, floor(fu)) > .4 then critters[#critters + 1] = { x, y } end
        else
          local P = CROP[crop] or CROP.green
          local along = (floor(hash(pu, pv, S + 43) * 2) == 0) and fu or fv
          local stripe = floor(along / 2) % 2
          if crop == "vine" or crop == "agave" or crop == "sun" or crop == "chili" then
            col = (floor(along) % 3 == 0) and P[2] or P[1]
            if crop == "sun" and floor(along) % 3 == 0 and (floor((crop == "sun") and fv or fu) % 2 == 0) then col = "#f8cc3c" end
            if crop == "sun" and floor(along) % 3 ~= 0 then col = "#7a9a3a" end
            if crop == "chili" then col = (floor(along) % 3 == 0) and "#86583a" or ((hash(x, y, 5) > .8) and "#dc4e3c" or "#6a9a44") end
          else
            col = stripe == 0 and P[1] or P[2]
            if crop:sub(1, 5) == "tulip" and stripe == 1 then col = P[2] end
          end
          if crop == "coffee" or crop == "tea" then if floor(fv) % 3 == 0 then col = mix(P[1], "#e8b982", .5) end end   -- terrace lips
          if edgeL then col = mix(col, "#fff4d6", .22) end
          col = mix(col, b, .18)
        end
        pix[i] = col
      end
    end
  end end
  -- orchard trees and grazing critters on top
  table.sort(orchardTrees, function(a, b) return a[2] < b[2] end)
  for _, t in ipairs(orchardTrees) do tree(t[1], t[2], t[3] == "olive" and "olive" or "fruit", 2, TEX) end

  -- forests, groves, scrub, snowfields, meadows, rocky ground
  local treesL = {}
  local function zoneDensity(kind) return ({ forest = (name == "NA" or name == "SA") and 5 or 4, grove = 7, scrub = 9, snowfield = 8 })[kind] end
  for _, z in ipairs(cfg.zones) do
    local step = zoneDensity(z[2])
    if step then
      for gy = 0, H, step do for gx = 0, W, step do
        local x = gx + floor(hash(gx, gy, S + 50) * step)
        local y = gy + floor(hash(gx, gy, S + 51) * step)
        if x > 3 and y > 6 and x < W - 4 and y < H - 3 then
          local zz = zoneKind(x, y)
          if zz == z and ok(x, y, TEX) and dP[y * W + x] >= 5 and dD[y * W + x] >= 4 then
            local L = z[3]
            local kind = L[1 + floor(hash(x, y, S + 52) * #L)]
            local s = (z[2] == "forest") and (3 + floor(hash(x, y, S + 53) * 2.2)) or (2 + floor(hash(x, y, S + 54) * 2))
            if kind == "jungle" or kind == "ceiba" or kind == "ipe" then s = s + 1 end
            treesL[#treesL + 1] = { x, y, kind, s, z[2] }
          end
        end
      end end
    end
  end
  -- forest floor darkened first (the dark value layer)
  for y = 1, H - 2 do for x = 1, W - 2 do
    local i = y * W + x
    if ok(x, y, TEX) then
      local z = zoneKind(x, y)
      if z[2] == "forest" then pix[i] = mix(pix[i], cfg.snow and "#3e4a5a" or "#1e3a2e", .42)
      elseif z[2] == "snowfield" then
        local v = GX.vn(x, y, 9, S + 60) * .8 + hash(x, y, S + 64) * .2
        pix[i] = v > .5 and ((hash(x, y, S + 65) > .9) and "#f0f4f2" or "#dce6ec") or (v > .4 and "#aebccc" or pix[i])
      elseif z[2] == "meadow" then
        local h = hash(x, y, S + 61)
        if h > .965 then pix[i] = cfg.flowers[1 + floor(hash(x, y, S + 62) * 3)]
        elseif h > .9 and ok(x, y + 1, TEX) then pix[i] = mix(pix[i], "#c4e07a", .45); pix[i + W] = mix(pix[i + W], SHC, .25) end
      elseif z[2] == "scrub" or z[2] == "rocky" then
        local h = hash(x, y, S + 63)
        if h > .94 then pix[i] = mix(pix[i], "#f6dc90", .4) elseif h < .05 then pix[i] = mix(pix[i], SHC, .3) end
      end
    end
  end end
  table.sort(treesL, function(a, b) return a[2] < b[2] end)
  for _, t in ipairs(treesL) do tree(t[1], t[2], t[3], t[4], TEX) end
  -- canopy critters: macaws (SA)
  if cfg.critter == "macaw" then
    for k = 1, 9 do local t = treesL[1 + floor(hash(k, 3, S) * #treesL)]
      if t and t[3] ~= "palm" then put(t[1] + 1, t[2] - t[4] * 2, k % 2 == 0 and "#e8493b" or "#3a86b0", TEX); put(t[1] + 2, t[2] - t[4] * 2, "#f5b82e", TEX) end end
  end
  -- rocky outcrops scattered in rocky zones
  for gy = 0, H, 18 do for gx = 0, W, 18 do
    local x, y = gx + floor(hash(gx, gy, S + 70) * 18), gy + floor(hash(gx, gy, S + 71) * 18)
    if x > 6 and y > 6 and x < W - 7 and y < H - 6 then
      local z = zoneKind(x, y)
      if (z[2] == "rocky" or (z[2] == "scrub" and hash(x, y, 4) > .7)) and ok(x, y, TEX) and dP[y * W + x] >= 7 and dD[y * W + x] >= 5 then
        rocks(x, y, 3, { moss = false }, TEX)
      end
    end
  end end
  -- critters: sheep, goats, flamingos
  for k, c in ipairs(critters) do
    if cfg.critter == "sheep" or cfg.critter == "goat" then
      local x, y = c[1], c[2]
      local body = HP.rect(x, y, x + 2, y + 1)
      castShadow(body, .3, 1, TEX)
      body:each(function(xx, yy) put(xx, yy, (yy == y) and "#f4ece0" or "#d6ccc0", TEX) end)
      put(x - 1, y, cfg.critter == "goat" and "#8a6a4a" or "#3a3042", TEX)
      put(x, y + 2, "#3a3042", TEX); put(x + 2, y + 2, "#3a3042", TEX)
    end
  end
  if cfg.critter == "flamingo" then
    local n = 0
    for y = 8, H - 8, 3 do for x = 8, W - 8, 3 do
      local i = y * W + x
      if n < 6 and dW[i] >= 2 and dW[i] <= 4 and ok(x, y, TEX) and ok(x, y - 4, TEX) and hash(x, y, S + 80) > .9 then
        n = n + 1
        put(x, y, "#c94f84", TEX); put(x, y - 1, "#c94f84", TEX)
        put(x, y - 2, "#f5809f", TEX); put(x + 1, y - 2, "#f5809f", TEX); put(x + 1, y - 3, "#ffc4d8", TEX); put(x - 1, y - 3, "#f5809f", TEX)
        put(x - 1, y - 4, "#f5809f", TEX); put(x - 2, y - 4, INK, TEX)
      end
    end end
  end

  ---------------------------------------------------------- 3. bridges over the old river
  if cfg.bridges then
    local made = {}
    for y = 10, H - 10, 3 do for x = 10, W - 10 do
      if #made < cfg.bridges then
        local i = y * W + x
        if WATER[base[i]] and CL[i] == 3 and dP[i] >= 14 and not WATER[base[i - 1]] then
          local xr = x
          while xr < x + 6 and WATER[base[y * W + xr + 1]] do xr = xr + 1 end
          local okb = CL[y * W + x - 2] == 1 and CL[y * W + xr + 2] == 1 and not WATER[base[y * W + xr + 1]]
          for _, m in ipairs(made) do if abs(m[2] - y) < 60 then okb = false end end
          if okb and xr - x <= 4 then
            made[#made + 1] = { x, y }
            local deck = HP.rect(x - 3, y - 1, xr + 3, y)
            for xx = x - 3, xr + 3 do
              pix[(y - 1) * W + xx] = (xx % 2 == 0) and "#e8b982" or "#d8a46c"
              pix[y * W + xx] = "#864c33"
              pix[(y + 1) * W + xx] = WATER[base[(y + 1) * W + xx]] and "#2a4a7a" or pix[(y + 1) * W + xx]
            end
            pix[(y - 2) * W + x - 3] = "#51302b"; pix[(y - 2) * W + xr + 3] = "#51302b"
            for xx = x - 4, xr + 4, xr - x + 8 do pix[(y - 1) * W + xx] = INK; pix[y * W + xx] = INK end
            for xx = x - 3, xr + 3 do if not WATER[base[(y - 2) * W + xx]] and CL[(y - 2) * W + xx] == 1 then pix[(y - 2) * W + xx] = INK end end
          end
        end
      end
    end end
  end

  ---------------------------------------------------------- 4. landmarks drawn over everything plain
  local LV = { p = 2, d = 1 }
  table.sort(marks, function(a, b) return a[3] < b[3] end)
  for _, m in ipairs(marks) do
    local mk, x, y = m[1], m[2], m[3]
    local k = mk[1]
    -- clear a little ground round the landmark (back to base, slightly lit) so it reads
    for yy = y - mk[2], y + mk[2] do for xx = x - mk[2], x + mk[2] do
      if (xx - x) ^ 2 + ((yy - y) * 1.3) ^ 2 <= mk[2] ^ 2 and ok(xx, yy, LV) then pix[yy * W + xx] = base[yy * W + xx] end
    end end
    if k == "village" then village(x, y, mk, LV)
    elseif k == "pond" then pond(x, y, mk[2] - 1, mk, LV)
    elseif k == "rocks" then rocks(x, y, mk[2], mk, LV)
    elseif k == "windmill" then windmill(x, y + 3, LV)
    elseif k == "volcano" then volcano(x, y + 4, LV)
    elseif k == "mesa" then mesa(x, y + 2, LV)
    elseif k == "lighthouse" then lighthouse(x, y + 5, LV)
    elseif k == "wreck" then wreck(x, y, LV)
    elseif k == "temple" then temple(x, y + 4, LV)
    elseif k == "church" then church(x, y + 5, LV)
    elseif k == "stones" then stones(x, y, LV)
    elseif k == "stork" then stork(x, y + 4, LV)
    elseif k == "peaks" then peaks(x, y + 3, LV)
    elseif k == "cypressrow" then cypressrow(x, y + 3, LV) end
  end
  -- wheel-rutted cart tracks from each village down to the nearest road
  for _, m in ipairs(marks) do
    if m[1][1] == "village" then
      local x, y = m[2], m[3] + 9
      for step = 1, 60 do
        local i = y * W + x
        if dP[i] <= 3 then break end
        local bx, by, bv = x, y, dP[i]
        for _, q in ipairs({ { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 }, { 1, 1 }, { -1, 1 }, { 1, -1 }, { -1, -1 } }) do
          local v = dP[(y + q[2]) * W + x + q[1]] + hash(x + q[1], y + q[2], S + 90) * .6
          if v < bv then bx, by, bv = x + q[1], y + q[2], v end
        end
        if bx == x and by == y then break end
        x, y = bx, by
        local TK = { p = 2, d = 2 }
        put(x, y, "#b08a5a", TK); put(x + 1, y, "#c8a06a", TK); put(x, y + 1, "#c8a06a", TK)
        if step % 2 == 0 then put(x + 1, y + 1, "#7a5634", TK) end
      end
    end
  end

  -- clean: no pure black / white
  for i = 0, W * H - 1 do
    if pix[i] == "#000000" then pix[i] = INK elseif pix[i] == "#ffffff" then pix[i] = "#fff4d6" end
  end
  local c = HP.canvas{ w = W, h = H, scale = 1, name = "map-" .. name }
  for i = 0, W * H - 1 do c.pix[i] = pix[i] end
  return c
end

local names = (NAME == "all") and ORDER or { NAME }
for _, n in ipairs(names) do
  local c = build(n)
  c:save{ png = OUT .. "map-" .. n .. ".png", aseprite = OUT .. "map-" .. n .. ".aseprite", scale = 1 }
end
