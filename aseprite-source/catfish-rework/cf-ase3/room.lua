-- room.lua: Cat Fish room base + 8 upgrade overlays + yarn patch, Hearth Pop pass (hard pixels, 1px ink on props,
-- lamp light from upper-left via tone-index banding, material cues: plaster, wood grain, beadboard, rag rug, sisal).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local L = dofile(DIR .. "/cflib.lua")
local OUT = app.params["out"] or (DIR .. "/out/")
local W, H = 320, 200
local floor, max, min, sin, sqrt, abs = math.floor, math.max, math.min, math.sin, math.sqrt, math.abs
local K = L.K
local function mixc(a, b, t)
  local function ch(h, i) return tonumber(h:sub(i, i + 1), 16) end
  return string.format("#%02x%02x%02x", floor(ch(a, 2) + (ch(b, 2) - ch(a, 2)) * t + .5), floor(ch(a, 4) + (ch(b, 4) - ch(a, 4)) * t + .5), floor(ch(a, 6) + (ch(b, 6) - ch(a, 6)) * t + .5))
end
local function R(D, s, m, l, Lh, g) return { D = D, s = mixc(D, s, .5), b = s, m = m, l = l, L = Lh, g = g } end
local function rng(seed) local s = (seed * 7919 + 13) % 2147483648 return function() s = (s * 1103515245 + 12345) % 2147483648 return s / 2147483648 end end
local function H2(x, y, s) local n = (x * 374761393 + y * 668265263 + (s or 0) * 2147483) % 4294967296 n = ((n ~ (n >> 13)) * 1274126177) % 4294967296 return ((n ~ (n >> 16)) % 10007) / 10007 end

-- 7-tone material ramps (1 deep .. 5 highlight, 6-7 only for sunbeam light); cool-violet shade, warm light
local MAT = {
  wall  = { "#9a6f6c", "#c79c88", "#ecce9e", "#f8e2b4", "#fff0cc", "#fff6d6", "#fffae2" },
  trim  = { "#3d2314", "#6a4128", "#8a5a34", "#b07a48", "#cf9a62", "#e4b472", "#f4cc8e" },
  wain  = { "#2f3f66", "#48668f", "#6f93b4", "#93b6cf", "#b8d4e4", "#d2e6e4", "#e8f4e2" },
  floor = { "#6e3f2a", "#9a5a36", "#c9803f", "#e0a058", "#f2c07a", "#f8d690", "#fee8ae" },
}
local META = {}      -- base pixel -> {mat, idx} for the sunbeam
local function glow(x, y)
  local d = sqrt((x - 24) ^ 2 * 0.55 + (y - 14) ^ 2) + 2 * sin(x / 6 + y / 4) + 3 * sin(y / 9 - x / 13)
  if d < 85 then return 1 elseif d > 250 then return -1 else return 0 end
end
local function clamp(v, a, b) return max(a, min(b, v)) end
local function bg(c, x, y, mat, idx, lay)
  if x < 0 or y < 0 or x >= W or y >= H then return end
  local i = clamp(idx + glow(x, y), 1, 5)
  c.curLayer = lay
  c:put(x, y, MAT[mat][i], nil, true)
  META[K(x, y)] = { mat, i }
  c.curLayer = nil
end
local function bgRect(c, x0, y0, x1, y1, mat, idx, lay) for y = y0, y1 do for x = x0, x1 do bg(c, x, y, mat, idx, lay) end end end

local function px(c, list, col, lay) for _, p in ipairs(list) do c:put(p[1], p[2], p[3] or col, lay or "detail") end end
local function part(c, m, ramp, ws, wl, o) o = o or {} o.ws, o.wl, o.ramp, o.ao = ws or 1, wl or 1, ramp, false c:part(m, o) end
local function ink(c, m, lay)
  local ring = m:grow(1):cut(m)
  ring:each(function(x, y) if x >= 0 and y >= 0 and x < W and y < H then c.curLayer = "ink" c:put(x, y, '#', nil, true) c.curLayer = nil end end)
end
local function rrect(x0, y0, x1, y1, r)
  local m = L.rect(x0, y0, x1, y1)
  for _, cr in ipairs({ { x0, y0, 1, 1 }, { x1, y0, -1, 1 }, { x0, y1, 1, -1 }, { x1, y1, -1, -1 } }) do
    for j = 0, r - 1 do for i = 0, r - 1 do
      local dx, dy = r - 0.5 - i, r - 0.5 - j
      if dx * dx + dy * dy > r * r then m:unset(cr[1] + cr[3] * i, cr[2] + cr[4] * j) end
    end end
  end
  return m
end
local function layer(c, name) c.curLayer = name end

-- prop ramps
local PINK = R("#6e2850", "#b8446e", "#e0608c", "#f080a4", "#f9a8c0", "#fff0f4")
local GREEN = R("#1f4a3a", "#2f7a48", "#4a9a4c", "#72b858", "#9ad06a", "#d4f09a")
local SISAL = R("#6a4a2a", "#a07a44", "#c8a064", "#dcbc80", "#ecd29c", "#fcf0c8")
local CREAM = R("#9a7a78", "#cdb092", "#f0dcae", "#f8ebc6", "#fff4d8", "#ffffff")
local TERRA = R("#6e2c20", "#a8482e", "#d0643a", "#e8844a", "#f4a468", "#ffd4a0")
local GOLD = R("#7a3e18", "#c47a22", "#f0b030", "#ffd257", "#ffe68c", "#fff8d0")
local WOOD = R("#3d2314", "#6a4128", "#8a5a34", "#b07a48", "#cf9a62", "#efc990")
local GREY = R("#3d3654", "#6e6684", "#9890b0", "#b8b2cc", "#d4d0e0", "#f4f0fa")   -- yarn / mouse
local BLUE = R("#2a3a7a", "#3a5ab0", "#4f8fd8", "#7cb4ee", "#a8d4ff", "#e4f6ff")
local PLUM = R("#4a2048", "#7a3a6e", "#a85c92", "#c880b0", "#e0a4c8", "#f8d8ec")
local ORANGE = R("#8f3a1f", "#c4532a", "#ee8a34", "#f6a94e", "#ffd27a", "#fff1c8")
local RED = R("#7a1f2a", "#b8353a", "#e0523f", "#f07a52", "#ff9d70", "#ffd0a8")
local BROWN = R("#3a1f12", "#6a3a1e", "#9a5e2e", "#c08040", "#dda35a", "#f4cf8a")
local STEEL = R("#2f3a5a", "#566a8c", "#8098b8", "#a8bcd4", "#cfdcec", "#f4f8ff")

-- ------------------------------------------------------------------------------------------------------
local function drawBase(c, withYarn)
  META = {}
  -- WALL: plaster with paper seams ------------------------------------------------------------------
  layer(c, "wall")
  for y = 8, 68 do for x = 0, W - 1 do
    local idx = 3
    local sx = (x - 8) % 24
    if sx == 0 then idx = 2 elseif sx == 1 then idx = 4 end
    local hsh = H2(x, y, 3)
    if idx == 3 then
      if hsh < 0.012 then idx = 2 elseif hsh > 0.99 then idx = 4 end
    end
    -- tiny stitched diamond sprig, one tone off, every 24px, staggered
    local cx, cy = (x - 8) // 24, 0
    local lx, ly = sx - 12, (y - 8 + ((cx % 2) * 8)) % 16 - 8
    
    bg(c, x, y, "wall", idx)
  end end
  -- shadow under the crown
  for x = 0, W - 1 do bg(c, x, 8, "wall", 1) bg(c, x, 9, "wall", 2) end
  -- CROWN MOULDING y0..7
  layer(c, "trim")
  for y = 0, 7 do for x = 0, W - 1 do
    local idx = ({ 5, 4, 3, 3, 3, 3, 2, 1 })[y + 1]
    local runs = H2(x // 11, y, 5)
    if idx == 3 and runs > 0.8 then idx = 2 elseif idx == 3 and runs < 0.12 then idx = 4 end
    bg(c, x, y, "trim", idx)
  end end
  -- CHAIR RAIL y69..78
  for x = 0, W - 1 do
    bg(c, x, 69, "trim", 5) bg(c, x, 70, "trim", 4)
    for y = 71, 76 do
      local idx = 3
      local rr = H2(x // 13 + y, y, 7)
      if rr > 0.78 then idx = 4 elseif rr < 0.1 then idx = 2 end
      bg(c, x, y, "trim", idx)
    end
    bg(c, x, 77, "trim", 2) bg(c, x, 78, "trim", 1)
  end
  -- WAINSCOT beadboard y79..111
  layer(c, "wainscot")
  for y = 79, 111 do for x = 0, W - 1 do
    local m4 = x % 4
    local idx = 3
    if m4 == 0 then idx = 2 end
    if y == 79 then idx = 1 elseif y == 80 then idx = 2 end
    bg(c, x, y, "wain", idx)
  end end
  -- raised panels (stride 40, 28 wide) y88..105
  for k = 0, 7 do
    local x0 = 6 + 40 * k
    for y = 88, 105 do for x = x0, x0 + 27 do
      local idx = 3
      if y == 88 or x == x0 then idx = 4 elseif y == 105 or x == x0 + 27 then idx = 1 end
      if y == 89 or x == x0 + 1 then if idx == 3 then idx = 2 end end
      if y == 104 or x == x0 + 26 then if idx == 3 then idx = 4 end end
      if idx == 3 and (y > 90 and y < 103 and x > x0 + 2 and x < x0 + 25) then idx = 3 + ((x % 4 == 0) and -1 or ((x % 4 == 1) and 1 or 0)) end
      bg(c, x, y, "wain", idx)
    end end
  end
  -- dado cap y112, skirting y113..122
  layer(c, "trim")
  for x = 0, W - 1 do
    bg(c, x, 111, "trim", 5) bg(c, x, 112, "trim", 4)
    for y = 113, 120 do
      local idx = 3
      local rr = H2(x // 9 + y, y, 11)
      if y == 113 or y == 114 then idx = 4 end
      if rr > 0.8 and y > 114 then idx = 4 elseif rr < 0.1 and y > 114 then idx = 2 end
      if y >= 119 then idx = 2 end
      bg(c, x, y, "trim", idx)
    end
    bg(c, x, 121, "trim", 1) bg(c, x, 122, "trim", 1)
  end
  -- FLOOR planks y123..199 ---------------------------------------------------------------------------
  layer(c, "floor")
  local rows = { { 123, 137 }, { 138, 153 }, { 154, 171 }, { 172, 191 }, { 192, 199 } }
  local lens = { 100, 86, 112, 94, 104 }
  local offs = { 30, 70, 10, 52, 90 }
  for ri, rw in ipairs(rows) do
    local r = rng(ri * 31)
    -- grain segments per scanline
    for y = rw[1], rw[2] do
      local x = 0
      local seg = {}
      while x < W do
        local len = 5 + floor(r() * 22)
        local v = r()
        local off = 0
        if v > 0.9 then off = 1 elseif v < 0.08 then off = -1 end
        seg[#seg + 1] = { x, x + len - 1, off } x = x + len
      end
      for _, s in ipairs(seg) do for xx = s[1], min(s[2], W - 1) do
        local pk = floor((xx + offs[ri]) / lens[ri])
        local pv = H2(pk, ri, 2)
        local pidx = 3
        if pv > 0.8 then pidx = 4 elseif pv < 0.2 then pidx = 2 end
        local idx = pidx + s[3]
        local top = y - rw[1]
        if ri == 1 then idx = idx - 1 end            -- far row sits in the baseboard shadow
        if top == 0 then idx = 1 elseif top == 1 then idx = 5 end
        if ri == 1 and top == 1 then idx = 3 end
        if ri == 1 and top <= 2 and top > 1 then idx = 1 end
        if (xx + offs[ri]) % lens[ri] == 0 then idx = 1 elseif (xx + offs[ri]) % lens[ri] == 1 and top > 1 then idx = 5 end
        bg(c, xx, y, "floor", clamp(idx, 1, 5))
      end end
    end
    -- nails near the joints
    for k = -1, floor(W / lens[ri]) + 1 do
      local jx = k * lens[ri] - offs[ri] % lens[ri] + (offs[ri] % lens[ri] == 0 and 0 or 0)
      for _, nx in ipairs({ jx + 4, jx + lens[ri] - 6 }) do
        local ny = rw[1] + 4
        if nx > 0 and nx < W - 1 and ny < rw[2] then c.curLayer = "floor" c:put(nx, ny, MAT.floor[1], nil, true) c:put(nx, ny - 1, MAT.floor[5], nil, true) end
      end
    end
  end
  -- knot (quirk) at 264,146: elliptical rings with grain bending round
  do
    local kx, ky = 262, 146
    for _, e in ipairs({ { 5, 3, 2 }, { 3, 2, 1 }, { 1, 1, 1 } }) do
      L.ellipse(kx, ky, e[1], e[2]):each(function(x, y) bg(c, x, y, "floor", e[3] == 1 and 1 or 2) end)
    end
    bg(c, kx - 1, ky - 1, "floor", 4) bg(c, kx, ky, "floor", 1)
    for dx = -9, 9 do if abs(dx) > 5 then bg(c, kx + dx, ky - 3, "floor", 2) bg(c, kx + dx, ky + 3, "floor", 2) end end
  end

  -- WINDOW (x0..37, y10..77) ----------------------------------------------------------------------------
  layer(c, "window")
  local function wp(x, y, t) c:put(x, y, t, nil, true) end
  -- outer casing (wood) right post and lintel
  for y = 10, 77 do for x = 29, 37 do
    local idx = 3
    if x == 29 then idx = 4 elseif x >= 35 then idx = 2 elseif x == 34 then idx = 3 end
    if (y + x) % 17 == 0 then idx = idx - 1 end
    bg(c, x, y, "trim", clamp(idx, 1, 5))
  end end
  for x = 0, 37 do bg(c, x, 10, "trim", 5) bg(c, x, 11, "trim", 4) bg(c, x, 12, "trim", 2) end
  -- awning valance y13..26: terracotta/cream stripes with scalloped hem
  do
    local TS = { "#6e2c20", "#a8482e", "#d0643a", "#e8844a", "#f4a468" }
    local CS = { "#9a7a78", "#cdb092", "#f0dcae", "#f8ebc6", "#fff4d8" }
    for x = 0, 30 do
      local stripe = (x // 5) % 2 == 0
      local ramp = stripe and TS or CS
      local hem = 24 + ((x % 5 == 0 or x % 5 == 4) and 0 or ((x % 5 == 2) and 2 or 1))
      for y = 13, hem do
        local idx = 3
        if y == 13 then idx = 5 elseif y == 14 then idx = 4 elseif y >= hem - 1 then idx = 2 end
        if y == hem then idx = 1 end
        if x % 5 == 4 and y > 14 then idx = clamp(idx - 1, 1, 5) end
        c.curLayer = "window" c:put(x, y, ramp[clamp(idx + glow(x, y), 1, 5)], nil, true)
      end
      for y = hem + 1, hem + 2 do if y <= 27 then bg(c, x, y, "wall", 1) end end
    end
  end
  -- green sash x0..28 y27..65 (shade under awning)
  local SAGE = { "#1f4a3a", "#2f7a48", "#4a9a4c", "#72b858", "#9ad06a" }
  for y = 27, 67 do for x = 0, 28 do
    local idx = 3
    if x >= 25 then idx = 2 end
    if x == 24 then idx = 4 end
    if y == 27 then idx = 1 elseif y == 28 then idx = 2 end
    c.curLayer = "window" c:put(x, y, SAGE[clamp(idx, 1, 5)], nil, true)
  end end
  -- panes
  local SKY = { "#7cc0f0", "#8ccaf4", "#a4d8f8", "#c0e6fa" }
  local function pane(x0, y0, x1, y1, lower)
    for y = y0, y1 do for x = x0, x1 do
      local t = (y - y0) / max(1, (y1 - y0))
      local col = SKY[clamp(floor(t * 4) + 1, 1, 4)]
      if lower then
        if y > y0 + 8 then col = (y > y0 + 12) and "#58a040" or "#72b858"          -- hills / meadow
        elseif y > y0 + 6 and ((x + y) % 7 < 3) then col = "#72b858" end
      end
      wp(x, y, col)
    end end
    -- inner frame shadow (top and left cast by muntins) and a lit glint
    for x = x0, x1 do wp(x, y0, "#3a6a98") end
    for y = y0, y1 do wp(x0, y, "#5a88b8") end
  end
  pane(0, 28, 8, 41, false) pane(13, 28, 21, 41, false) pane(0, 46, 21, 63, true)
  -- clouds and glints
  px(c, { { 3, 31, "#fff8e8" }, { 4, 31, "#fff8e8" }, { 5, 31, "#fff8e8" }, { 4, 30, "#fff8e8" }, { 16, 34, "#fff8e8" }, { 17, 34, "#fff8e8" }, { 18, 34, "#fff8e8" }, { 17, 33, "#fff8e8" },
    { 3, 50, "#fff8e8" }, { 4, 50, "#fff8e8" }, { 5, 50, "#fff8e8" }, { 6, 50, "#fff8e8" }, { 4, 49, "#fff8e8" }, { 5, 49, "#fff8e8" }, { 9, 53, "#fff8e8" }, { 10, 53, "#fff8e8" } })
  px(c, { { 14, 30, "#e4f6ff" }, { 15, 31, "#e4f6ff" }, { 1, 30, "#e4f6ff" }, { 2, 31, "#e4f6ff" } })
  -- a lone tree on the hill
  px(c, { { 16, 56, "#2f7a48" }, { 17, 56, "#2f7a48" }, { 15, 57, "#2f7a48" }, { 16, 57, "#4a9a4c" }, { 17, 57, "#4a9a4c" }, { 18, 57, "#2f7a48" }, { 16, 58, "#6a4128" }, { 17, 58, "#6a4128" } })
  -- nose print quirk on the lower glass: a smudge pad and two toe dots
  px(c, { { 13, 60, "#e4f6ff" }, { 14, 60, "#e4f6ff" }, { 12, 61, "#e4f6ff" }, { 13, 61, "#e4f6ff" }, { 14, 61, "#e4f6ff" }, { 15, 61, "#e4f6ff" } })
  -- rails (mullion + bottom) bevel
  for x = 9, 12 do for y = 28, 41 do end end
  for x = 0, 21 do wp(x, 42, "#9ad06a") wp(x, 45, "#1f4a3a") wp(x, 64, "#9ad06a") end
  for y = 28, 41 do wp(9, y, "#9ad06a") wp(12, y, "#1f4a3a") end
  for y = 46, 63 do wp(22, y, "#1f4a3a") end
  for x = 0, 28 do wp(x, 66, "#1f4a3a") wp(x, 67, "#1f4a3a") end
  -- sill y68..77
  layer(c, "sill")
  for x = 0, 36 do
    bg(c, x, 68, "trim", 5) bg(c, x, 69, "trim", 4)
    for y = 70, 74 do
      local idx = 3
      local rr = H2(x // 8 + y, y, 4)
      if rr > 0.78 then idx = 4 elseif rr < 0.12 then idx = 2 end
      if x > 33 then idx = 2 end
      bg(c, x, y, "trim", idx)
    end
    bg(c, x, 75, "trim", 2) bg(c, x, 76, "trim", 1) bg(c, x, 77, "trim", 1)
  end
  for y = 68, 77 do bg(c, 36, y, "trim", 1) bg(c, 37, y, "trim", 1) end
  -- drop shadow of the sill on the wainscot
  for x = 0, 37 do bg(c, x, 78, "trim", 1) end
  -- brass hook + pink thread knot (the wand hangs here)
  layer(c, "hook")
  do
    local brass = R("#5a3010", "#b26a1c", "#e8a030", "#ffd257", "#ffe68c", "#fff8d0")
    local m = L.mask()
    for y = 6, 9 do m:set(66, y) m:set(67, y) end
    for _, p in ipairs({ { 66, 10 }, { 67, 10 }, { 66, 11 }, { 67, 11 }, { 67, 12 }, { 67, 13 }, { 68, 14 }, { 69, 14 }, { 70, 13 }, { 70, 12 } }) do m:set(p[1], p[2]) end
    m:each(function(x, y) local t = (x == 66 and y < 12) and brass.L or brass.m if y >= 13 then t = brass.s end if x == 66 and y >= 10 and y < 13 then t = brass.l end if x == 67 and y < 12 then t = brass.s end if y == 14 then t = brass.l end c:put(x, y, t, 'hook') end)
    ink(c, m)
    px(c, { { 66, 7, brass.g }, { 66, 12, "#e8609c" }, { 67, 12, "#c94f84" }, { 66, 13, "#c94f84" }, { 66, 14, "#e8609c" }, { 66, 15, "#c94f84" } })
    c:put(66, 12, "#f7a9c2", "hook") c:put(67, 12, "#e8609c", "hook") c:put(66, 13, "#c94f84", "hook") c:put(67, 13, "#c94f84", "hook")
  end

  -- SHELF (280..319, 12..39) ---------------------------------------------------------------------------
  layer(c, "shelf")
  -- cast shadow on the wall (lower right)
  for y = 14, 44 do for x = 283, 319 do if META[K(x, y)] and META[K(x, y)][1] == "wall" and ((x - 283) + (y - 14) > 0) and y > 33 and y < 44 then bg(c, x, y, "wall", 1) end end end
  do
    -- plant: round-leaf jade in terracotta pot
    local pot = rrect(283, 25, 295, 32, 2)
    part(c, pot, TERRA, 2, 2)
    for x = 283, 295 do c:put(x, 25, TERRA.L, "light") c:put(x, 26, TERRA.l, "light") end
    px(c, { { 284, 27, TERRA.g }, { 289, 29, TERRA.s }, { 290, 29, TERRA.s }, { 291, 29, TERRA.s } })
    local stem = L.rect(288, 18, 289, 25)
    part(c, stem, GREEN, 1, 1)
    local leaves = { { 285, 20, 3.2, 2.4 }, { 292, 20, 3.2, 2.4 }, { 288, 14, 3.4, 3 }, { 284, 15, 2.6, 2 }, { 293, 15, 2.6, 2 }, { 289, 21, 3, 2.2 } }
    local all = L.mask()
    for _, l in ipairs(leaves) do local m = L.ellipse(l[1], l[2], l[3], l[4]) all:add(m) part(c, m, GREEN, 1, 1) px(c, { { l[1] - 1, l[2] - 1, GREEN.g } }) end
    ink(c, all:copy():add(stem):add(pot)) ink(c, pot)
    -- quirk: a pink blossom
    px(c, { { 288, 11, "#ff9ec0" }, { 287, 12, "#ff9ec0" }, { 289, 12, "#ff9ec0" }, { 288, 12, "#ffe68c" }, { 288, 13, "#ff9ec0" } })
    ink(c, L.mask():set(288, 11):set(287, 12):set(289, 12):set(288, 12):set(288, 13))
    -- books (leaning set) with spines
    local cols = { { 302, 311, "#c4532a", "#8f3a1f", "#e8844a" }, { 305, 318, "#3a5ab0", "#2a3a7a", "#7cb4ee" }, { 313, 317, "#e8609c", "#7d2c5e", "#f7a9c2" } }
    local bks = { { 302, 17, 305, 31, RED }, { 306, 15, 309, 31, BLUE }, { 310, 19, 313, 31, GREEN }, { 314, 16, 317, 31, GOLD } }
    for _, b in ipairs(bks) do
      local m = L.rect(b[1], b[2], b[3], b[4])
      part(c, m, b[5], 1, 1)
      c:put(b[1], b[2] + 3, b[5].g, "detail") c:put(b[3] - 1, b[2] + 3, b[5].g, "detail")
      for x = b[1], b[3] do c:put(x, b[2] + 2, b[5].g, "detail") end
      ink(c, m)
    end
    -- board and brackets
    local board = L.rect(280, 32, 319, 36)
    for x = 280, 319 do
      c:put(x, 32, WOOD.g, "light") c:put(x, 33, WOOD.L, "light")
      for y = 34, 35 do c:put(x, y, ((x // 7 + y) % 5 == 0) and WOOD.l or WOOD.m, "body") end
      c:put(x, 36, WOOD.s, "shade")
    end
    ink(c, board)
    local br = { { 284, 37, 4, 4 }, { 309, 37, 4, 4 } }
    for _, b in ipairs(br) do
      local m = L.poly({ { b[1], b[2] }, { b[1] + b[3], b[2] }, { b[1], b[2] + b[4] + 1 } })
      part(c, m, WOOD, 1, 1) ink(c, m)
    end
  end
  -- PICTURE (282..317, 42..73): gold frame, fish painting
  layer(c, "picture")
  for y = 44, 78 do for x = 284, 319 do if META[K(x, y)] and META[K(x, y)][1] == "wall" and (x > 316 or y > 73) then bg(c, x, y, "wall", 1) end end end
  do
    local fr = L.rect(282, 42, 317, 73)
    part(c, fr, GOLD, 2, 2)
    px(c, { { 283, 43, GOLD.g } })
    local inner = L.rect(287, 47, 312, 68)
    -- water mat
    inner:each(function(x, y)
      local t = (y - 47) / 21
      c:put(x, y, (t < 0.5) and "#7cb4ee" or "#6a9ed8", "detail")
    end)
    for x = 287, 312 do c:put(x, 47, "#3a5ab0", "shade") end
    for y = 47, 68 do c:put(287, y, "#3a5ab0", "shade") end
    for x = 288, 312 do c:put(x, 68, "#a8d4ff", "light") end
    -- fish: round orange body, tail, eye, fin
    local body = L.ellipse(298, 57, 7, 4.2)
    part(c, body, ORANGE, 1, 1)
    local tail = L.poly({ { 304, 57 }, { 310, 52 }, { 310, 62 } })
    part(c, tail, ORANGE, 1, 1)
    local fin = L.poly({ { 296, 53 }, { 300, 50 }, { 301, 54 } }) part(c, fin, ORANGE, 1, 1, { lift = -1 })
    px(c, { { 293, 56, '#' }, { 292, 55, "#fff4d6" }, { 298, 55, ORANGE.L }, { 297, 54, ORANGE.g }, { 300, 58, ORANGE.s }, { 301, 59, ORANGE.s } })
    -- bubbles
    px(c, { { 289, 52, "#e4f6ff" }, { 290, 50, "#e4f6ff" }, { 289, 49, "#a8d4ff" } })
    -- gold bevel inside the frame
    for x = 285, 314 do c:put(x, 45, GOLD.L, "light") c:put(x, 70, GOLD.s, "shade") end
    for y = 45, 70 do c:put(285, y, GOLD.L, "light") c:put(314, y, GOLD.s, "shade") end
    -- corner fleurons
    for _, p in ipairs({ { 283, 43 }, { 316, 43 }, { 283, 72 }, { 316, 72 } }) do c:put(p[1], p[2], GOLD.g, "detail") end
    ink(c, fr)
  end

  -- CUSHION (0..62, 166..197) ------------------------------------------------------------------------
  layer(c, "cushion")
  do
    -- contact shadow on the floor
    L.ellipse(30, 192, 34, 5):each(function(x, y) if META[K(x, y)] then bg(c, x, y, "floor", 1) end end)
    local body = L.ellipse(28, 180, 33, 12)
    part(c, body, PINK, 3, 3)
    local top = L.ellipse(26, 175, 28, 7)
    part(c, top, PINK, 2, 3, { lift = 0 })
    -- quilted diamonds on the top face
    for k = -3, 3 do
      for t = -8, 8 do
        local x, y = 26 + k * 8 + t, 175 + floor(t * 0.5 + 0.5)
        if top:has(x, y) then c:put(x, y, PINK.s, "detail") end
        local x2, y2 = 26 + k * 8 - t, 175 + floor(t * 0.5 + 0.5)
        if top:has(x2, y2) then c:put(x2, y2, PINK.s, "detail") end
      end
    end
    -- piping along the seam (gold cord) under the top face
    for x = 0, 58 do
      local dx = (x - 26) / 28
      if abs(dx) < 1 then
        local y = floor(175 + 7 * sqrt(1 - dx * dx) + 0.5) + 1
        c:put(x, y, GOLD.m, "detail") c:put(x, y + 1, GOLD.s, "detail")
        if x % 3 == 0 then c:put(x, y, GOLD.g, "detail") end
      end
    end
    -- button
    px(c, { { 26, 175, GOLD.m }, { 27, 175, GOLD.l }, { 26, 176, GOLD.s }, { 27, 176, GOLD.m }, { 25, 175, PINK.D }, { 28, 176, PINK.D } })
    -- tassel at the right
    local ta = L.rect(59, 179, 61, 183) part(c, ta, GOLD, 1, 1)
    px(c, { { 60, 178, GOLD.g }, { 59, 184, GOLD.s }, { 61, 184, GOLD.s }, { 60, 185, GOLD.m } })
    ink(c, body:copy():add(ta):add(L.rect(59, 184, 61, 185)))
  end
  -- YARN BALL (sprite 58,178 16x16) + loose thread ---------------------------------------------------------
  local snapshot = {}
  if withYarn then
    layer(c, "yarn")
    L.ellipse(66, 192, 10, 3):each(function(x, y) if META[K(x, y)] and (META[K(x, y)][1] == "floor") then bg(c, x, y, "floor", 1) end end)
    local YA = R("#3d4a6e", "#6a82a8", "#8aa4c4", "#a8c0d8", "#c8dcec", "#f0f8ff")
    local thread = L.tube({ { 60, 192 }, { 54, 195 }, { 47, 194 }, { 42, 196 }, { 40, 194 } }, function() return 0.8 end)
    part(c, thread, YA, 1, 1) ink(c, thread)
    local ball = L.ellipse(65.5, 185.5, 7.6, 7.6)
    part(c, ball, YA, 3, 3)
    for _, off in ipairs({ -5, -1, 3 }) do
      for t = -7, 7 do
        local x, y = floor(65.5 + t + 0.5), floor(185.5 + off - t * 0.6 + 0.5)
        if ball:has(x, y) and ball:has(x + 1, y + 1) and ball:has(x - 1, y - 1) then c:put(x, y, YA.s, "detail") if ball:has(x, y - 1) then c:put(x, y - 1, YA.L, "detail") end end
      end
    end
    px(c, { { 61, 181, YA.g }, { 62, 180, YA.g }, { 60, 182, YA.L } })
    ink(c, ball)
  end

  -- BOWL (282..316, 176..199), plain and empty --------------------------------------------------------------
  layer(c, "bowl")
  do
    L.ellipse(299, 197, 17, 3):each(function(x, y) if META[K(x, y)] then bg(c, x, y, "floor", 1) end end)
    local body = L.poly({ { 285, 183 }, { 313, 183 }, { 310, 194 }, { 305, 197 }, { 293, 197 }, { 288, 194 } })
    part(c, body, TERRA, 3, 3)
    local rim = L.ellipse(299, 183, 15, 4.4)
    part(c, rim, TERRA, 2, 2, { lift = 1 })
    local hole = L.ellipse(299, 183.5, 12, 2.8)
    part(c, hole, TERRA, 1, 1, { lift = -2 })
    -- cream paw band
    for x = 290, 308 do c:put(x, 190, CREAM.m, "detail") end
    px(c, { { 297, 187, CREAM.L }, { 299, 187, CREAM.L }, { 301, 187, CREAM.L }, { 298, 188, CREAM.L }, { 300, 188, CREAM.L }, { 299, 189, CREAM.L } })
    ink(c, body:copy():add(rim))
  end
end

-- ------------------------------------------------------------------------------------------------------
local function newc(ordered) return L.canvas(W, H, true) end
local function save(c, name) c:save(OUT, name) print(name, c:colours()) end

local base = L.canvas(W, H, true) drawBase(base, true) save(base, "cf-room")
local noyarn = L.canvas(W, H, true) drawBase(noyarn, false)
do   -- yarn patch (38x20 at 40,178)
  local p = L.canvas(38, 20, true)
  for y = 0, 19 do for x = 0, 37 do local t = noyarn:get(40 + x, 178 + y) if t then p:put(x, y, t, "patch", true) end end end
  p:save(OUT, "cf-room-yarnpatch")
end
-- OVERLAYS

local function arch(x0, x1, ytop, ybot)
  local r = (x1 - x0 + 1) / 2
  local cx, cy = (x0 + x1) / 2, ytop + r
  local m = L.rect(x0, floor(cy), x1, ybot)
  L.ellipse(cx, cy, r, r):each(function(x, y) if y < floor(cy) then m:set(x, y) end end)
  return m
end
local function newo() return L.canvas(W, H, true) end

-- SUNBEAM ---------------------------------------------------------------------------------------------
do
  local o = newo() o.curLayer = "beam"
  local function litpx(x, y, lv) local m = META[K(x, y)] if m then o:put(x, y, MAT[m[1]][clamp(m[2] + lv, 1, 7)], nil, true) end end
  local shaft = L.poly({ { 8, 78 }, { 38, 78 }, { 128, 123 }, { 98, 123 } })
  shaft:each(function(x, y)
    local u = x - 2.05 * (y - 78)
    local lv = 1
    if u >= 8 and u < 10 then lv = 1 end
    if u >= 10 and u < 22 then lv = 2 elseif u >= 22 and u < 25 then lv = 0 elseif u >= 25 and u < 36 then lv = 2 end
    if lv > 0 then litpx(x, y, lv) end
  end)
  o.curLayer = "pool"
  for y = 124, 167 do
    local v = (y - 124) / 43
    local xl, xr = 112 + 66 * v, 172 + 66 * v
    for x = floor(xl), floor(xr) do
      local u = (x - xl) / (xr - xl)
      local lv = 2
      if u < 0.03 or u > 0.97 or v < 0.04 or v > 0.96 then lv = 1 end
      if (u > 0.455 and u < 0.545) or (v > 0.47 and v < 0.55) then lv = 0 end
      if lv > 0 then litpx(x, y, lv) end
    end
  end
  -- dust motes (quirk)
  o.curLayer = "motes"
  for _, p in ipairs({ { 50, 94 }, { 70, 101 }, { 41, 88 }, { 88, 108 }, { 142, 140 }, { 166, 151 }, { 196, 150 }, { 211, 160 }, { 152, 131 }, { 120, 146 } }) do
    o:put(p[1], p[2], "#fffbe6", nil, true)
    if (p[1] + p[2]) % 3 == 0 then o:put(p[1] + 1, p[2], "#fff0b8", nil, true) end
  end
  save(o, "cf-room-sunbeam")
end

-- RUG -------------------------------------------------------------------------------------------------
do
  local o = newo() o.curLayer = "rug"
  local cx, cy, rx, ry = 160.5, 185.5, 81, 14.2
  local m = L.ellipse(cx, cy, rx, ry):filter(function(x, y) return y <= 199 end)
  local chev = { TERRA, CREAM, GOLD }
  m:each(function(x, y)
    local dx, dy = (x - cx) / rx, (y - cy) / ry
    local r = sqrt(dx * dx + dy * dy)
    local t
    if r > 0.86 then
      local th = math.atan(dy * 1.0, dx)
      local seg = floor((th + math.pi) / (2 * math.pi) * 72)
      local ramp = chev[seg % 3 + 1]
      local key = 'm'
      if r > 0.95 then key = (dy > 0.2) and 's' or 'l' elseif r < 0.89 then key = (dy > 0) and 'b' or 'l' end
      if (seg % 3 == 1) and r > 0.9 and r < 0.94 then key = 'L' end
      t = ramp[key]
    elseif r > 0.79 then
      t = (r > 0.82) and CREAM.m or CREAM.b
      if dy < -0.3 and r < 0.82 then t = CREAM.l end
    else
      -- green field: rag rows
      local key = 'm'
      if y % 3 == 0 then key = 'b' elseif y % 6 == 1 then key = 'l' end
      t = GREEN[key]
      if r > 0.5 and r < 0.54 then t = CREAM.m end
      if r > 0.27 and r < 0.3 then t = GOLD.m end
      if r < 0.12 then t = TERRA.m end
    end
    o:put(x, y, t, nil, true)
  end)
  -- shade on the lower-right edge, light on the upper-left (rolled rim)
  m:each(function(x, y)
    local dx, dy = (x - cx) / rx, (y - cy) / ry
    local r = sqrt(dx * dx + dy * dy)
    if r > 0.96 and dy > 0.35 then o:put(x, y, TERRA.D, nil, true) end
  end)
  -- quirk: a stitched-on fish patch
  do
    local pm = rrect(99, 182, 111, 189, 2)
    o.curLayer = "patch"
    pm:each(function(x, y) o:put(x, y, CREAM.l, nil, true) end)
    pm:edge():each(function(x, y) o:put(x, y, ((x + y) % 2 == 0) and GOLD.s or CREAM.l, nil, true) end)
    for _, p in ipairs({ { 102, 185 }, { 103, 184 }, { 104, 184 }, { 105, 184 }, { 106, 185 }, { 105, 186 }, { 104, 186 }, { 103, 186 } }) do o:put(p[1], p[2], ORANGE.m, nil, true) end
    px(o, { { 107, 184, ORANGE.l }, { 107, 186, ORANGE.l }, { 108, 183, ORANGE.m }, { 108, 187, ORANGE.m }, { 108, 185, ORANGE.m }, { 103, 185, '#' }, { 105, 184, ORANGE.L } }, nil, "patch")
  end
  o.curLayer = "ink"
  ink(o, m)
  save(o, "cf-room-rug")
end

-- SCRATCH POST ---------------------------------------------------------------------------------------
local function sisal(o, m, tw)
  m:each(function(x, y)
    local v = (x + y * tw) % 6
    if v == 0 then o:put(x, y, SISAL.b, "detail", true) elseif v == 1 and x < 300 then o:put(x, y, SISAL.L, "detail", true) end
  end)
end
do
  local o = newo()
  o.curLayer = "post"
  -- base slab
  local slab = rrect(276, 164, 319, 177, 3)
  part(o, slab, GREEN, 3, 2)
  for x = 278, 317, 4 do o:put(x, 166, GREEN.l, "detail") o:put(x + 2, 169, GREEN.b, "detail") end
  ink(o, slab)
  -- post
  local post = L.rect(291, 94, 306, 166)
  part(o, post, SISAL, 3, 2)
  sisal(o, post, 2)
  -- worn tufts (quirk): frayed strands sticking out where claws raked
  local tuft = { { 306, 128 }, { 307, 127 }, { 308, 126 }, { 307, 129 }, { 308, 130 }, { 309, 131 }, { 291, 142 }, { 290, 141 }, { 289, 142 }, { 290, 143 } }
  for _, p in ipairs(tuft) do o:put(p[1], p[2], SISAL.l, "detail") end
  ink(o, post)
  for _, p in ipairs(tuft) do o:put(p[1], p[2], SISAL.m, "detail") end
  for _, p in ipairs({ { 295, 118 }, { 296, 120 }, { 297, 122 }, { 300, 130 }, { 301, 132 }, { 302, 134 } }) do o:put(p[1], p[2], SISAL.D, "detail") end
  -- top perch
  local perch = rrect(278, 78, 319, 96, 4)
  part(o, perch, GREEN, 3, 3)
  for x = 281, 316, 3 do o:put(x, 80 + (x % 2) * 2, GREEN.L, "detail") end
  for x = 280, 316, 3 do o:put(x + 1, 90, GREEN.b, "detail") end
  ink(o, perch)
  -- dangling pompom on a rope from the perch
  local rope = L.line({ { 283, 97 }, { 283, 112 } })
  rope:each(function(x, y) o:put(x, y, SISAL.m, "detail") end)
  ink(o, rope)
  local pom = L.ellipse(283.5, 115, 3.6, 3.6) part(o, pom, PINK, 2, 2)
  px(o, { { 282, 113, PINK.g }, { 283, 112, PINK.L } })
  ink(o, pom)
  save(o, "cf-room-scratch")
end

-- CAT TREE ---------------------------------------------------------------------------------------------
do
  local o = newo() o.curLayer = "tree"
  local function pole(x0, y0, x1, y1) local m = L.rect(x0, y0, x1, y1) part(o, m, SISAL, 2, 2) sisal(o, m, 2) ink(o, m) end
  pole(216, 90, 225, 110) pole(216, 122, 225, 141)
  local function plat(x0, y0, x1, y1, r) local m = rrect(x0, y0, x1, y1, r) part(o, m, PINK, 3, 2)
    for x = x0 + 3, x1 - 3, 4 do o:put(x, y0 + 2, PINK.l, "detail") o:put(x + 2, y0 + 5, PINK.b, "detail") end
    for x = x0 + 2, x1 - 2 do o:put(x, y0, PINK.g, "light") end
    ink(o, m) end
  plat(201, 140, 241, 153, 4)
  plat(203, 108, 239, 121, 4)
  -- top bed
  local bowl = L.ellipse(221.5, 86, 17.4, 8) part(o, bowl, PINK, 3, 3)
  local inner = L.ellipse(221.5, 83.5, 13.4, 4.8) part(o, inner, CREAM, 2, 2)
  for x = 212, 232, 4 do o:put(x, 84, CREAM.s, "detail") o:put(x + 1, 82, CREAM.L, "detail") end
  ink(o, bowl)
  -- bell on a string (quirk), hanging from the mid platform
  local str = L.line({ { 207, 122 }, { 207, 130 } }) str:each(function(x, y) o:put(x, y, GOLD.s, "detail") end)
  local bell = L.ellipse(207, 133, 3, 3) part(o, bell, GOLD, 1, 1)
  px(o, { { 206, 132, GOLD.g }, { 207, 135, GOLD.D }, { 208, 133, GOLD.D } })
  ink(o, bell:copy():add(str))
  save(o, "cf-room-cattree")
end

-- CAT FLAP --------------------------------------------------------------------------------------------
do
  local o = newo() o.curLayer = "flap"
  local outer = arch(244, 276, 84, 121)
  part(o, outer, WOOD, 3, 2)
  for y = 100, 120 do o:put(246, y, WOOD.L, "detail") end
  local inner = arch(248, 272, 88, 118)
  inner:each(function(x, y) o:put(x, y, "#2a1a28", "shade", true) end)
  -- daylight under the flap
  L.rect(249, 115, 271, 118):each(function(x, y) if inner:has(x, y) then o:put(x, y, (y == 115) and GOLD.L or GOLD.m, "detail", true) end end)
  local flap = L.poly({ { 250, 92 }, { 271, 92 }, { 269, 114 }, { 252, 114 } })
  part(o, flap, STEEL, 2, 2)
  for t = 0, 9 do o:put(254 + t, 110 - t, STEEL.g, "detail") end
  for t = 0, 5 do o:put(259 + t, 112 - t, STEEL.L, "detail") end
  -- paw emblem on the flap
  for _, p in ipairs({ { 0, 1 }, { 2, 0 }, { 4, 0 }, { 6, 1 }, { 2, 3 }, { 3, 3 }, { 4, 3 }, { 1, 4 }, { 2, 4 }, { 3, 4 }, { 4, 4 }, { 5, 4 }, { 2, 5 }, { 3, 5 }, { 4, 5 } }) do
    o:put(257 + p[1], 98 + p[2], CREAM.L, "detail")
  end
  for _, p in ipairs({ { 5, 4 }, { 4, 5 }, { 6, 1 } }) do o:put(257 + p[1], 98 + p[2], CREAM.m, "detail") end
  -- hinge bar
  L.rect(254, 90, 267, 92):each(function(x, y) o:put(x, y, (y == 90) and GOLD.L or ((y == 91) and GOLD.m or GOLD.s), "detail") end)
  px(o, { { 255, 91, GOLD.g }, { 266, 91, GOLD.D } })
  ink(o, outer)
  -- quirk: a fish-shaped tag hung from a brass pin on the frame
  px(o, { { 277, 103, GOLD.m } })
  local th = L.line({ { 277, 104 }, { 277, 107 } }) th:each(function(x, y) o:put(x, y, CREAM.m, "detail") end)
  local tag = L.ellipse(276.5, 111, 2.4, 3.4) part(o, tag, ORANGE, 1, 1)
  local tt = L.poly({ { 274, 114 }, { 279, 114 }, { 276.5, 117 } }) part(o, tt, ORANGE, 1, 1)
  px(o, { { 275, 109, '#' }, { 276, 108, ORANGE.g } })
  ink(o, tag:copy():add(tt):add(th))
  save(o, "cf-room-catflap")
end

-- BOWL ------------------------------------------------------------------------------------------------
do
  local o = newo() o.curLayer = "mat"
  local mat = L.poly({ { 281, 190 }, { 316, 190 }, { 319, 199 }, { 278, 199 } })
  part(o, mat, CREAM, 1, 1)
  mat:each(function(x, y) if (y == 192 or y == 197) then o:put(x, y, BLUE.m, "detail") end end)
  for x = 282, 316, 3 do o:put(x, 194, BLUE.l, "detail") o:put(x + 1, 195, BLUE.l, "detail") end
  ink(o, mat)
  o.curLayer = "bowl"
  local body = L.poly({ { 281, 184 }, { 316, 184 }, { 312, 194 }, { 306, 198 }, { 291, 198 }, { 285, 194 } })
  part(o, body, PINK, 3, 3)
  local rim = L.ellipse(298.5, 184, 17.5, 5) part(o, rim, PINK, 2, 2, { lift = 1 })
  local hole = L.ellipse(298.5, 184.5, 14.4, 3.4) part(o, hole, PINK, 1, 1, { lift = -2 })
  ink(o, body:copy():add(rim))
  -- fish emblem
  local fe = L.ellipse(297.5, 191, 4.4, 2.2) part(o, fe, CREAM, 1, 1)
  local ft = L.poly({ { 301, 191 }, { 305, 188 }, { 305, 194 } }) part(o, ft, CREAM, 1, 1)
  px(o, { { 294, 190, '#' } })
  for x = 283, 314 do local k = o:get(x, 196) if k == PINK.s or k == PINK.m then o:put(x, 196, PINK.D, "detail") end end
  -- kibble heap
  o.curLayer = "kibble"
  local heap = L.mask()
  local ns = { { 292, 180, 3.8, 2.8 }, { 298, 178, 3.8, 3 }, { 304, 180, 3.8, 2.8 }, { 309, 182, 3, 2.4 }, { 287, 182, 3, 2.4 }, { 295, 183, 3.6, 2.6 }, { 301, 183, 3.6, 2.6 }, { 298, 174, 3.4, 2.6 } }
  for _, n in ipairs(ns) do local m = L.ellipse(n[1], n[2], n[3], n[4]) heap:add(m) part(o, m, BROWN, 1, 1) px(o, { { n[1] - 1, floor(n[2] - 1), BROWN.g } }) ink(o, m) end
  -- front lip back over the heap
  rim:each(function(x, y) if y >= 185 and not hole:has(x, y) then o:put(x, y, (y <= 186) and PINK.L or PINK.m, "bowl", true) end end)
  -- quirk: a fish-shaped biscuit stuck in the top, plus one stray kibble on the mat
  local bis = L.ellipse(305.5, 176, 4, 2.4) part(o, bis, ORANGE, 1, 1)
  local bt = L.poly({ { 309, 176 }, { 312, 173 }, { 312, 179 } }) part(o, bt, ORANGE, 1, 1)
  px(o, { { 303, 175, '#' }, { 305, 174, ORANGE.g } })
  ink(o, bis:copy():add(bt))
  local st = L.ellipse(279.5, 197, 1.8, 1.4) part(o, st, BROWN, 1, 1) ink(o, st)
  save(o, "cf-room-bowl")
end

-- TOYBOX ---------------------------------------------------------------------------------------------
do
  local o = newo() o.curLayer = "toys"
  -- feather wand poking out
  local wand = L.tube({ { 238, 178 }, { 242, 170 } }, function() return 0.7 end)
  part(o, wand, WOOD, 1, 1) ink(o, wand)
  local fea = L.ellipse(242.5, 167, 2.2, 3.4) part(o, fea, BLUE, 1, 1) px(o, { { 242, 165, BLUE.g } }) ink(o, fea)
  -- yarn ball
  local yb = L.ellipse(222, 172, 5.4, 5.4) part(o, yb, PINK, 2, 2)
  for t = -4, 4 do local x, y = 222 + t, floor(172 + t * 0.5 + 0.5) if yb:has(x, y) then o:put(x, y, PINK.s, "detail") end end
  px(o, { { 219, 169, PINK.g }, { 220, 168, PINK.L } })
  ink(o, yb)
  -- toy mouse, head up
  local mh = L.ellipse(231, 173, 4, 3.4) part(o, mh, GREY, 1, 1)
  local e1 = L.ellipse(228, 169, 2, 2) part(o, e1, PINK, 1, 1)
  local e2 = L.ellipse(234, 169, 2, 2) part(o, e2, PINK, 1, 1)
  px(o, { { 229, 173, '#' }, { 233, 173, '#' }, { 231, 175, PINK.P or "#c66a80" }, { 230, 171, GREY.g } })
  ink(o, mh:copy():add(e1):add(e2))
  -- crate
  o.curLayer = "crate"
  local crate = rrect(213, 177, 243, 199, 2)
  part(o, crate, WOOD, 2, 2)
  for x = 213, 243 do o:put(x, 177, WOOD.g, "light") o:put(x, 178, WOOD.L, "light") o:put(x, 183, WOOD.D, "shade") o:put(x, 190, WOOD.D, "shade") o:put(x, 184, WOOD.l, "light") o:put(x, 191, WOOD.l, "light") end
  for _, p in ipairs({ { 218, 180 }, { 224, 181 }, { 236, 180 }, { 222, 187 }, { 238, 188 }, { 217, 194 }, { 232, 195 }, { 240, 196 } }) do o:put(p[1], p[2], WOOD.s, "detail") o:put(p[1] + 1, p[2], WOOD.s, "detail") o:put(p[1] + 2, p[2], WOOD.s, "detail") end
  -- iron corner straps
  for _, sx in ipairs({ 214, 240 }) do
    L.rect(sx, 178, sx + 2, 198):each(function(x, y) o:put(x, y, (x == sx) and STEEL.L or ((x == sx + 2) and STEEL.s or STEEL.m), "detail") end)
    for y = 181, 197, 8 do o:put(sx + 1, y, STEEL.g, "detail") end
  end
  -- heart (raised pink patch) on the front
  local heart = { "..##.##..", ".#######.", ".#######.", "..#####..", "...###...", "....#...." }
  for j, row in ipairs(heart) do for i = 1, #row do if row:sub(i, i) == '#' then o:put(224 + i - 1, 185 + j - 1, (j == 1 and i < 4) and PINK.L or ((j > 3) and PINK.s or PINK.m), "detail") end end end
  ink(o, crate)
  -- quirk: the mouse's tail hangs over the front
  local tail = L.line({ { 234, 177 }, { 235, 181 }, { 238, 182 }, { 237, 186 } })
  tail:each(function(x, y) o:put(x, y, PINK.m, "detail") end)
  save(o, "cf-room-toybox")
end

-- WINDOW (bird view): pane + branch; the robin is cf-bird-1 at 2x so the flit frames land on it ---------------
do
  local o = newo() o.curLayer = "view"
  local SKY = { "#7cc0f0", "#8ccaf4", "#a4d8f8", "#c0e6fa" }
  for y = 46, 63 do for x = 0, 21 do
    local t = (y - 46) / 17
    local col = SKY[clamp(floor(t * 4) + 1, 1, 4)]
    if y > 56 then col = "#58a040" elseif y > 54 then col = "#72b858" end
    o:put(x, y, col, nil, true)
  end end
  for x = 0, 21 do o:put(x, 46, "#3a6a98", nil, true) end
  for y = 46, 63 do o:put(0, y, "#5a88b8", nil, true) end
  -- branch with leaves and a pink blossom
  o.curLayer = "branch"
  for x = 0, 21 do o:put(x, 61 - (x // 9), "#6a4128", nil, true) o:put(x, 62 - (x // 9), "#3d2314", nil, true) end
  for _, p in ipairs({ { 18, 58 }, { 19, 57 }, { 19, 58 }, { 20, 58 }, { 10, 58 }, { 11, 57 }, { 11, 58 }, { 12, 58 } }) do o:put(p[1], p[2], "#4a9a4c", nil, true) end
  px(o, { { 19, 57, "#9ad06a" }, { 11, 57, "#9ad06a" }, { 14, 56, "#ff9ec0" }, { 13, 57, "#ff9ec0" }, { 15, 57, "#ff9ec0" }, { 14, 57, "#ffe68c" }, { 14, 58, "#ff9ec0" } })
  o.curLayer = "robin"
  local img = Image { fromFile = "/home/user/gnome-venture/game/assets/img/catfish/cf-bird-1.png" }
  for y = 0, 9 do for x = 0, 11 do
    local pv = img:getPixel(x, y)
    if app.pixelColor.rgbaA(pv) > 0 then
      local hex = string.format("#%02x%02x%02x", app.pixelColor.rgbaR(pv), app.pixelColor.rgbaG(pv), app.pixelColor.rgbaB(pv))
      for dy = 0, 1 do for dx = 0, 1 do o:put(-2 + x * 2 + dx, 44 + y * 2 + dy, hex, nil, true) end end
    end
  end end
  save(o, "cf-room-window")
  local e = newo() e:save(OUT, "cf-room-window-nobird", true)
end
