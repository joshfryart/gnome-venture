-- batch.lua: seven DELVE pictures, 480x270. Param: name=<picture> or all
local d = debug.getinfo(1,"S").source:match("^@(.*)[/\\][^/\\]*$")
local GX = dofile(d.."/../../gather/gx.lua")
local HP, X = GX.HP, GX.X
local floor, max, min, abs, sin, cos, sqrt, log = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.sqrt, math.log
local H, INK, mix, vn = X.hash, GX.INK, GX.mix, GX.vn
local NAME = app.params.name or "all"
local GOLD = "#e8b84a"
local function clamp(v, a, b) return max(a, min(b, v)) end

local function build(name, fn)
local c = HP.canvas{ w = 480, h = 270, scale = 1, name = name }
local function mk() return HP.mask() end
local function E(m, cx, cy, rx, ry) return GX.disc(m, cx, cy, rx, ry or rx) end
local function R6(R) return GX.ramp6(R) end
local function pick(r6, v) return r6[clamp(floor(v * 6) + 1, 1, 6)] end
-- lit blob
local function blob(cx, cy, rx, ry, R, seed, o)
  local m = mk(); E(m, cx, cy, rx, ry); m = GX.rough(m, seed, 1)
  o = o or {}; o.R = o.R or max(rx, ry) * .9; o.rimlight = true; o.tex = o.tex or .35; o.seed = seed; o.sc = o.sc or 3
  GX.lit(c, m, R6(R), o); return m
end
local function poly(pts, R, seed, o)
  local m = c:poly(pts); m = GX.rough(m, seed, 1)
  o = o or {}; o.R = o.R or 9; o.rimlight = true; o.tex = o.tex or .4; o.seed = seed
  GX.lit(c, m, R6(R), o); return m
end
local function eye(x, y) c:fillMask(c:rect(x, y, x + 1, y + 2), INK); c:px(x, y, "#fff0d8") end
local function glow(cx, cy, r, cols)
  for i = 1, #cols do
    local m = mk(); E(m, cx, cy, r - (i - 1) * floor(r / #cols), r - (i - 1) * floor(r / #cols))
    c:fillMask(m, cols[i])
  end
end
local function lantern(x, y, s)
  s = s or 1
  glow(x, y, 14 * s, { "#6a4a50", "#9a6a4a", "#d49a48", "#f4d070" })
  local m = c:rect(x - 3, y - 4, x + 3, y + 4); c:rim(m, INK)
  c:fillMask(m, "#f8e080"); c:fillMask(c:rect(x - 1, y - 2, x + 1, y + 2), "#fffbd0")
  c:fillMask(c:rect(x - 4, y - 6, x + 4, y - 5), INK); c:fillMask(c:rect(x - 3, y + 5, x + 3, y + 5), INK)
end
local function mist(y0, y1, col, seed, amt)
  for y = y0, y1 do for x = 0, 479 do
    local t = (y - y0) / max(1, y1 - y0)
    if vn(x, y, 14, seed) * amt > t * .9 + .05 and ((x + y) % 2 == 0 or t < .5) then c:px(x, y, col) end
  end end
end
local function crystals_tip(m, col) end


local function leafmass(cx, cy, rw, rh, R, seed, ink)
  local m = mk()
  local n = floor(rw * rh / 40) + 5
  for i = 1, n do
    local a = H(i, seed, 1) * 6.283; local rr = sqrt(H(i, seed, 2))
    GX.disc(m, floor(cx + math.cos(a) * rw * rr * .92), floor(cy + math.sin(a) * rh * rr * .92), 5 + floor(H(i, seed, 3) * 7))
  end
  for i = 1, 5 do GX.disc(m, floor(cx - rw * .8 + H(i, seed, 8) * rw * 1.6), floor(cy + rh * .8 + H(i, seed, 9) * 5), 4 + floor(H(i, seed, 4) * 3), 4) end
  m = GX.rough(m, seed, 1)
  GX.lit(c, m, R6(R), { R = 9, tex = .6, sc = 3.2, seed = seed, amb = .28, rimlight = ink, ink = ink and GX.INK or false,
    fn = function(x, y) return (H(x // 3, y // 2, seed) - .5) * .28 end })
  return m
end
local function crystal(x, y, h, w, R)
  local m = c:poly({ { x - w, y }, { x - w, y - h }, { x - w // 2, y - h - w }, { x + w // 2, y - h - w }, { x + w, y - h }, { x + w, y } })
  c:rim(m, INK)
  m:each(function(xx, yy)
    local u = (xx - (x - w)) / (2 * w)
    local col = u < .28 and R[6] or (u < .6 and R[5] or (u < .85 and R[3] or R[2]))
    if yy < y - h and yy > y - h - w and u > .5 then col = R[4] end
    c:px(xx, yy, col)
  end)
  for yy = y - h - w + 1, y - h do c:px(x - w // 2 + 1, yy, R[6]) end
  c:px(x - w + 1, y - h + 2, "#fff6fc")
end
local function cluster(x, y, s, R, seed)
  local specs = { { -9, 0, 20, 4 }, { 0, 2, 30, 5 }, { 9, 0, 16, 4 }, { -3, -2, 12, 3 }, { 14, 3, 10, 3 }, { -15, 3, 9, 3 } }
  for i, p in ipairs(specs) do crystal(x + floor(p[1] * s), y + floor(p[2] * s), floor(p[3] * s), max(2, floor(p[4] * s)), R) end
end

local S = {}

---------------------------------------------------------------- 1 rose red canyon city
function S.rose()
  local ROSE = { hi = "#f4b8a0", base = "#d07a78", shade = "#9a4a66", deep = "#5e2c4c" }
  local FAR  = { hi = "#f8d4b8", base = "#e8a898", shade = "#c47e86", deep = "#9a5a74" }
  local SAND = { hi = "#fbe2b0", base = "#e8b880", shade = "#c08068", deep = "#7a4658" }
  GX.bands(c, 0, 200, { "#8c7cb8", "#b890b4", "#e8a8a4", "#f6c8a0", "#fbe2b8" }, 3, .2)
  -- far wall with temple
  local far = mk()
  for x = 120, 360 do local top = 58 + floor((vn(x, 0, 18, 7) - .5) * 20) + floor(abs(x - 240) * .12)
    for y = top, 200 do far:set(x, y) end end
  GX.lit(c, far, R6(FAR), { R = 40, tex = .5, sc = 5, seed = 4, amb = .35, ink = false })
  mist(60, 120, "#f6c8a8", 5, .9)
  -- temple facade carved in far wall
  local fx0, fx1, fy0, fy1 = 192, 290, 100, 196
  local fac = c:rect(fx0, fy0, fx1, fy1); c:rim(fac, INK)
  c:fillMask(fac, "#f2c4a4")
  c:fillMask(c:rect(fx0, fy0, fx1, fy0 + 8), "#e8a898"); c:fillMask(c:rect(fx0, fy0 + 9, fx1, fy0 + 9), "#c47e86")
  local ped = poly({ { fx0 - 6, fy0 }, { 241, fy0 - 26 }, { fx1 + 6, fy0 } }, ROSE, 12, { R = 14 })
  c:fillMask(c:rect(236, fy0 - 14, 246, fy0 - 7), "#5e2c4c"); c:fillMask(c:rect(238, fy0 - 12, 244, fy0 - 9), "#f4d070")
  for i = 0, 4 do   -- columns
    local x = fx0 + 6 + i * 20
    local m = c:rect(x, fy0 + 11, x + 9, fy1 - 2); GX.lit(c, m, R6(ROSE), { R = 6, tex = .2, sc = 8, seed = i })
    c:fillMask(c:rect(x - 2, fy0 + 11, x + 11, fy0 + 14), "#f4b8a0"); c:fillMask(c:rect(x - 2, fy1 - 4, x + 11, fy1 - 2), "#9a4a66")
  end
  local door = HP.mask(); for y = 140, fy1 - 2 do for x = 228, 254 do if y > 152 or ((x - 241) / 13) ^ 2 + ((y - 152) / 12) ^ 2 <= 1 then door:set(x, y) end end end
  c:rim(door, INK); c:fillMask(door, "#4a2440")
  for y = 160, fy1 - 2 do for x = 232, 250 do if abs(x - 241) < 9 - (y - 160) * .05 then c:px(x, y, y < 180 and "#f4d070" or "#d49a48") end end end
  c:fillMask(c:rect(236, 176, 246, fy1 - 2), "#fbe2b0")
  -- floor
  GX.ground(c, function(x) return 196 + floor((vn(x, 0, 30, 9) - .5) * 6) end, SAND, 11, { top = .85, fall = .55, tex = .3, sc = 9 })
  -- walls
  local function wall(pts, seed, dark)
    local m = c:poly(pts); m = GX.rough(m, seed, 2)
    GX.lit(c, m, R6(ROSE), { R = 22, tex = .5, sc = 5, seed = seed, amb = dark and .12 or .3,
      fn = function(x, y) return sin(y * .35 + vn(x, y, 20, seed) * 6) * .09 + (H(x // 2, y // 6, seed) - .5) * .1 end })
    return m
  end
  local wl = wall({ { 0, 0 }, { 146, 0 }, { 128, 56 }, { 116, 126 }, { 100, 196 }, { 62, 238 }, { 0, 256 } }, 21)
  local wr = wall({ { 480, 0 }, { 346, 0 }, { 360, 50 }, { 372, 118 }, { 388, 190 }, { 430, 234 }, { 480, 252 } }, 22, true)
  -- carved windows (arched, with lintel, sill and a warm lit interior)
  local function cwin(x, y, w, h)
    local m = mk(); for yy = y, y + h do for xx = x, x + w do
      if yy >= y + w // 2 or ((xx - (x + w / 2)) / (w / 2 + .5)) ^ 2 + ((yy - (y + w // 2)) / (w // 2 + .5)) ^ 2 <= 1 then m:set(xx, yy) end end end
    if not ((wl:has(x - 2, y - 2) and wl:has(x + w + 2, y + h + 4)) or (wr:has(x - 2, y - 2) and wr:has(x + w + 2, y + h + 4))) then return end
    local fr = c:rect(x - 2, y - 3, x + w + 2, y + h + 3)
    c:fillMask(c:rect(x - 2, y - 1, x + w + 2, y + h), ROSE.hi); c:rim(c:rect(x - 2, y - 1, x + w + 2, y + h), INK)
    c:fillMask(m, "#5e2c4c")
    m:each(function(xx, yy) local t = (yy - y) / h; c:px(xx, yy, t < .3 and "#7a3a58" or (t < .6 and "#c8784c" or (t < .85 and "#f0b858" or "#f8dc88"))) end)
    c:rim(m, INK)
    c:fillMask(c:rect(x + w // 2, y + 2, x + w // 2, y + h), "#7a3a58")
    c:fillMask(c:rect(x - 3, y + h + 1, x + w + 3, y + h + 2), "#f4b8a0"); c:fillMask(c:rect(x - 3, y + h + 3, x + w + 3, y + h + 3), "#7a3a58")
    c:px(x + 1, y + 3, "#fff0b0")
  end
  for _, w in ipairs{ { 36, 30, 8, 12 }, { 78, 66, 8, 12 }, { 30, 108, 8, 12 }, { 88, 122, 8, 12 }, { 56, 156, 8, 12 }, { 22, 186, 8, 12 }, { 402, 34, 8, 12 }, { 442, 78, 8, 12 }, { 410, 122, 8, 12 }, { 452, 150, 8, 12 }, { 428, 190, 8, 12 }, { 384, 84, 8, 12 } } do cwin(w[1], w[2], w[3], w[4]) end
  -- bunting lantern strings
  local function string_(x0, y0, x1, y1, sag, n)
    local last
    for i = 0, 60 do local t = i / 60; local x = floor(x0 + (x1 - x0) * t); local y = floor(y0 + (y1 - y0) * t + sin(t * 3.1416) * sag)
      c:px(x, y, INK); last = { x, y } end
    for i = 1, n - 1 do local t = i / n; local x = floor(x0 + (x1 - x0) * t); local y = floor(y0 + (y1 - y0) * t + sin(t * 3.1416) * sag)
      local cols = { "#e0505a", "#f4d070", "#4aa8a0" }; local col = cols[i % 3 + 1]
      c:fillMask(c:poly({ { x - 3, y + 1 }, { x + 3, y + 1 }, { x, y + 8 } }), col); c:px(x, y + 8, INK) end
  end
  string_(112, 70, 368, 56, 26, 9); string_(104, 128, 376, 126, 30, 8)
  lantern(240, 112, .8)
  -- rocks and fennec fox
  for _, r in ipairs{ { 150, 230, 8 }, { 330, 226, 6 }, { 100, 256, 5 } } do blob(r[1], r[2], r[3], floor(r[3] * .6), SAND, r[1], { R = 5 }) end
  local fx, fy = 336, 236
  c:fillMask(c:ellipse(fx, fy + 22, 36, 5), SAND.deep)
  local FOX = { hi = "#fff0c8", base = "#f0b870", shade = "#c47e56", deep = "#7a4650" }
  local tail = poly({ { fx - 22, fy + 12 }, { fx - 50, fy + 6 }, { fx - 56, fy + 14 }, { fx - 40, fy + 22 }, { fx - 22, fy + 22 } }, FOX, 31, { R = 7 })
  blob(fx, fy + 8, 26, 17, FOX, 32, { R = 18 })
  blob(fx - 6, fy + 14, 9, 8, { hi = "#fff8e0", base = "#f4e0c0", shade = "#d0a888", deep = "#9a6a60" }, 33, { R = 6 })
  poly({ { fx + 4, fy - 20 }, { fx + 10, fy - 46 }, { fx + 18, fy - 20 } }, FOX, 34, { R = 8 })
  poly({ { fx + 22, fy - 20 }, { fx + 36, fy - 44 }, { fx + 36, fy - 18 } }, FOX, 35, { R = 8 })
  c:fillMask(c:poly({ { fx + 8, fy - 24 }, { fx + 10, fy - 38 }, { fx + 14, fy - 24 } }), "#e49090")
  blob(fx + 18, fy - 8, 17, 14, FOX, 36, { R = 14 })
  blob(fx + 30, fy - 1, 8, 6, { hi = "#fff8e0", base = "#f4e0c0", shade = "#d0a888", deep = "#9a6a60" }, 37, { R = 5 })
  c:fillMask(c:rect(fx + 35, fy - 4, fx + 37, fy - 2), INK)
  eye(fx + 20, fy - 14); eye(fx + 30, fy - 13)
  c:px(fx + 14, fy - 6, "#e49090"); c:px(fx + 15, fy - 6, "#e49090")
  blob(fx + 8, fy + 20, 5, 4, FOX, 38, { R = 4 }); blob(fx + 22, fy + 20, 5, 4, FOX, 39, { R = 4 })
  -- tiny lantern held on a cord at the fox's collar (quirk)
  lantern(fx - 4, fy + 2, .5)
  -- cactus-like agave left
  for i = -3, 3 do c:fillMask(c:poly({ { 40, 252 }, { 40 + i * 8 - 2, 232 - (3 - abs(i)) * 3 }, { 40 + i * 8 + 2, 232 - (3 - abs(i)) * 3 }, { 44, 252 } }), i % 2 == 0 and "#5a9a6a" or "#3e7a5a") end
end

---------------------------------------------------------------- 2 salt mine galleries
function S.salt()
  local SALT = R6{ hi = "#fff4f0", base = "#e8c8d0", shade = "#b09ac0", deep = "#5c4a7c" }
  local DIRT = R6{ hi = "#a08878", base = "#6e5a62", shade = "#463a50", deep = "#2c2238" }
  local WOOD = R6{ hi = "#e0a860", base = "#a86a3c", shade = "#6e3e38", deep = "#3a2430" }
  local vx, vy, iw, ih = 240, 112, 46, 36
  for y = 0, 269 do for x = 0, 479 do
    local dx, dy = x - vx, y - vy
    local ax, ay = abs(dx) / iw, abs(dy) / ih
    local col
    if ax <= 1 and ay <= 1 then
      local t = sqrt(dx * dx / (iw * iw) + dy * dy / (ih * ih))
      col = mix("#fff0b8", "#6a3e48", clamp(t * .9, 0, 1)); if t > .75 then col = "#6a3e48" end
    else
      local wall, s, u
      if ax > ay then wall = dx < 0 and "L" or "R"; s = ax; u = dy / s else wall = dy < 0 and "C" or "F"; s = ay; u = dx / s end
      local r = log(s) / log(1.5); local fr = r - floor(r)
      local nz = vn(x, y, 11, 3) * .35 + vn(x, y, 24, 8) * .65
      if wall == "F" then
        local v = .55 - .08 * s + (nz - .5) * .3 + (fr < .08 and -.12 or 0)
        col = pick(DIRT, v)
        local rail = abs(abs(dx) / s - 14) < 1.2 / s * 2 + .5
        if abs(abs(dx) - 12 * s) < max(1.2, s * .9) then col = pick(DIRT, .95) end
        if abs(abs(dx) - 12 * s) < max(.6, s * .35) and wall == "F" then col = "#c4b8c8" end
        if fr > .5 and fr < .6 and abs(dx) < 17 * s then col = pick(WOOD, .35 + nz * .2) end
      else
        local beam = fr < .11 or (wall ~= "C" and false)
        local sed = sin(u * .09 + (wall == "C" and 2 or 0) + nz * 3) * .1
        local v = .78 - .07 * s + (nz - .5) * .3 + sed + (wall == "R" and -.1 or 0) + (wall == "C" and -.12 or 0)
        v = v - ((fr < .16 and not beam) and .12 or 0)
        col = pick(SALT, v)
        if beam then col = pick(WOOD, .62 - .05 * s + (nz - .5) * .3 - (fr < .03 and .2 or 0)) end
        if H(x, y, 9) > .997 then col = SALT[6] end
      end
    end
    c:px(x, y, col)
  end end
  -- salt stalactites
  for _, s in ipairs{ { 120, 60, 22, 6 }, { 168, 78, 16, 4 }, { 310, 80, 18, 5 }, { 360, 58, 24, 7 }, { 60, 36, 18, 6 }, { 410, 34, 20, 6 }, { 204, 90, 11, 3 }, { 276, 92, 9, 3 } } do
    local cx, y0, len, hw = s[1], s[2], s[3], s[4]
    local m = mk(); for y = y0, y0 + len do local w = floor(hw * (1 - (y - y0) / len) + .5); for x = cx - w, cx + w do m:set(x, y) end end
    GX.lit(c, GX.rough(m, cx, 1), SALT, { R = hw, tex = .3, seed = cx, rimlight = true })
  end
  local CR = { "#6a5a8c", "#8c78b0", "#b8a0d0", "#d8c4e4", "#f4e4f4", "#fff6fc" }
  cluster(34, 150, 1.5, CR, 1); cluster(92, 214, 1.2, CR, 2); cluster(448, 120, 1.4, CR, 3); cluster(420, 186, 1.0, CR, 4); cluster(26, 238, 1.0, CR, 5); cluster(168, 128, .8, CR, 6)
  -- hanging lantern chandelier
  for y = 0, 38 do c:px(240, y, INK) end
  lantern(240, 48, 1.2)
  -- mine cart
  local cx, cy = 360, 216
  c:fillMask(c:ellipse(cx, cy + 26, 52, 6), DIRT[1])
  local heap = blob(cx, cy - 12, 36, 18, { hi = "#ffffff", base = "#f0d8de", shade = "#b8a2c8", deep = "#7a6a98" }, 41, { R = 24, tex = .5 })
  local box = poly({ { cx - 46, cy - 6 }, { cx + 46, cy - 6 }, { cx + 36, cy + 22 }, { cx - 36, cy + 22 } }, { hi = "#c8744a", base = "#8c4a3c", shade = "#5a2c3a", deep = "#321a2c" }, 42, { R = 20, tex = .25 })
  c:fillMask(c:rect(cx - 44, cy - 6, cx + 44, cy - 3), "#6c7a8c"); c:fillMask(c:rect(cx - 44, cy - 6, cx + 44, cy - 5), "#a8b4c4")
  for i = -2, 2 do c:px(cx + i * 16, cy + 8, "#c8c0d0"); c:px(cx + i * 16, cy + 9, "#6c7a8c") end
  for _, wx in ipairs{ cx - 26, cx + 26 } do local w = blob(wx, cy + 24, 10, 10, { hi = "#b4c0d0", base = "#6c7a8c", shade = "#44506c", deep = "#2c3050" }, wx, { R = 8, tex = .2 }); c:fillMask(c:rect(wx - 1, cy + 23, wx + 1, cy + 25), INK) end
  for i = 0, 5 do c:px(cx - 24 + i * 9, cy - 28 + (i % 3) * 2, "#ffffff") end
  -- mole miner with helmet
  local mx, my = 130, 226
  c:fillMask(c:ellipse(mx, my + 24, 30, 5), DIRT[1])
  local MOLE = { hi = "#8a7a9c", base = "#5e4e78", shade = "#3e3258", deep = "#241c3c" }
  blob(mx, my, 22, 22, MOLE, 51, { R = 20 })
  blob(mx, my + 6, 12, 14, { hi = "#a89ab8", base = "#7e6e96", shade = "#5a4a78", deep = "#3a2c58" }, 52, { R = 9 })
  blob(mx - 22, my + 6, 8, 6, { hi = "#f4b8b0", base = "#e08c94", shade = "#a85a78", deep = "#6a3a5c" }, 53, { R = 5 })
  blob(mx + 22, my + 6, 8, 6, { hi = "#f4b8b0", base = "#e08c94", shade = "#a85a78", deep = "#6a3a5c" }, 54, { R = 5 })
  for i = -1, 1 do c:px(mx - 28 + i * 2, my + 10, "#fff0d8"); c:px(mx + 28 + i * 2, my + 10, "#fff0d8") end
  blob(mx, my - 14, 18, 13, MOLE, 55, { R = 12 })
  blob(mx, my - 6, 7, 5, { hi = "#f4b8b0", base = "#e08c94", shade = "#a85a78", deep = "#6a3a5c" }, 56, { R = 5 })
  c:px(mx - 2, my - 8, "#fff0f0")
  c:px(mx - 9, my - 15, INK); c:px(mx - 9, my - 14, INK); c:px(mx + 9, my - 15, INK); c:px(mx + 9, my - 14, INK)
  local hat = poly({ { mx - 17, my - 20 }, { mx - 12, my - 32 }, { mx + 12, my - 32 }, { mx + 17, my - 20 } }, { hi = "#ffe884", base = "#f0b830", shade = "#b87a2c", deep = "#6e4430" }, 57, { R = 12 })
  c:fillMask(c:rect(mx - 3, my - 36, mx + 3, my - 31), "#fffbd0"); c:rim(c:rect(mx - 3, my - 36, mx + 3, my - 31), INK)
  glow(mx, my - 34, 11, { "#6a5a6a", "#a08a6a", "#e0c070" })
  c:fillMask(c:rect(mx - 3, my - 36, mx + 3, my - 31), "#fffbd0")
  -- pickaxe
  for i = 0, 22 do c:px(mx + 34 + floor(i * .3), my + 20 - i, WOOD[3]); c:px(mx + 35 + floor(i * .3), my + 20 - i, WOOD[4]) end
  c:fillMask(c:poly({ { mx + 28, my - 2 }, { mx + 48, my - 6 }, { mx + 40, my + 1 } }), "#9aa6b8"); c:px(mx + 30, my - 2, "#e0e8f0")
end

---------------------------------------------------------------- 3 sea cave smuggler's run
function S.sea()
  local ROCK = { hi = "#5a7a98", base = "#38526e", shade = "#26384e", deep = "#161e34" }
  local hx0, hx1, hy0, hy1 = 150, 350, 26, 176
  local function inhole(x, y) local cx, hw = 250, 100
    if y < hy0 + hw then return (x - cx) ^ 2 + (y - (hy0 + hw)) ^ 2 <= hw * hw end
    return x >= hx0 and x <= hx1 and y <= hy1 end
  -- night view through the mouth
  GX.bands(c, 0, 140, { "#1c2250", "#243064", "#2e4078", "#3c5890", "#5878a8" }, 4, .2)
  for i = 0, 40 do local x, y = 150 + floor(H(i, 1, 4) * 200), 20 + floor(H(i, 2, 4) * 100); c:px(x, y, "#e8f0ff") end
  for y = 140, 200 do for x = 0, 479 do
    local t = (y - 140) / 60
    local v = .35 + t * .1 + (vn(x * .4, y, 5, 3) - .5) * .3
    local col = pick(R6{ hi = "#4e80a8", base = "#2e5882", shade = "#1e3a60", deep = "#142448" }, v)
    if abs(x - 292) < 22 - t * 6 and (y + floor(H(x // 6, y, 4) * 3)) % 3 == 0 and H(x // 5, y, 4) > .3 + t * .3 then col = "#f4ecc4" end
    c:px(x, y, col) end end
  local moon = blob(292, 56, 14, 14, { hi = "#fffbe0", base = "#f4ecc4", shade = "#d4c8b0", deep = "#a8a0b8" }, 5, { R = 14, ink = false, tex = .15 })
  glow(292, 56, 26, {}) 
  -- sea stack
  local ss = poly({ { 170, 142 }, { 180, 104 }, { 196, 100 }, { 204, 142 } }, { hi = "#5a6e98", base = "#384a74", shade = "#26345a", deep = "#1a2244" }, 6, { R = 8 })
  -- cave rock
  local rock = mk()
  for y = 0, 269 do for x = 0, 479 do
    local ledge = 196 + floor((vn(x, 0, 14, 7) - .5) * 8)
    if y < ledge and not inhole(x, y) then rock:set(x, y) end
  end end
  rock = GX.rough(rock, 8, 1)
  GX.lit(c, rock, R6(ROCK), { R = 16, tex = .8, sc = 4, seed = 5, amb = .22, fn = function(x, y) return (H(x // 3, y // 5, 8) - .5) * .18 - (y > 150 and (y - 150) * .002 or 0) end })
  -- water
  for y = 190, 269 do for x = 0, 479 do
    local rock_ = rock:has(x, y)
    if not rock_ then
      local t = (y - 190) / 80
      local v = .42 - t * .22 + (vn(x * .3, y, 4, 2) - .5) * .35
      if abs(x - 290) < 30 - t * 10 and vn(x * .5, y * 1.6, 3, 5) > .52 then v = .95 end
      c:px(x, y, pick(R6{ hi = "#5aa0b8", base = "#2c6888", shade = "#1c4468", deep = "#102a48" }, v))
    end
  end end
  for i = 0, 50 do local x, y = floor(H(i, 1, 8) * 470), 200 + floor(H(i, 2, 8) * 66)
    c:fillMask(c:rect(x, y, x + 5 + floor(H(i, 3, 8) * 12), y), i % 3 == 0 and "#6ab0c8" or "#12304c") end
  -- stalactites
  for _, s in ipairs{ { 60, 22, 40, 10 }, { 112, 40, 28, 8 }, { 360, 40, 30, 8 }, { 404, 24, 42, 10 }, { 450, 50, 24, 7 }, { 20, 60, 34, 7 } } do
    local cx, y0, len, hw = s[1], s[2], s[3], s[4]
    local m = mk(); for y = y0, y0 + len do local w = floor(hw * (1 - (y - y0) / len) + .5); for x = cx - w, cx + w do m:set(x, y) end end
    GX.lit(c, GX.rough(m, cx, 1), R6{ hi = "#7a9ab8", base = "#486a88", shade = "#2e4868", deep = "#1c2848" }, { R = hw, tex = .5, seed = cx, rimlight = true })
    c:px(cx, y0 + len + 2, "#a8e0f0")
  end
  -- left outcrop + crab with lantern
  local oc = poly({ { 0, 200 }, { 70, 206 }, { 96, 226 }, { 70, 246 }, { 0, 252 } }, { hi = "#6a8aa8", base = "#44627e", shade = "#2c445e", deep = "#1a2840" }, 11, { R = 14, tex = .6 })
  local CR = { hi = "#ffa880", base = "#e0584a", shade = "#a02c4c", deep = "#5c1c44" }
  local kx, ky = 52, 196
  for _, s in ipairs{ -1, 1 } do for i = 0, 3 do c:px(kx + s * (14 + i * 3), ky + 8 + (i % 2) * 2, INK); c:px(kx + s * (14 + i * 3), ky + 9 + (i % 2) * 2, CR.shade) end end
  blob(kx, ky, 20, 11, CR, 61, { R = 14 })
  blob(kx - 24, ky - 10, 8, 7, CR, 62, { R = 6 }); blob(kx + 26, ky - 14, 8, 7, CR, 63, { R = 6 })
  c:fillMask(c:rect(kx - 24, ky - 10, kx - 22, ky - 8), CR.deep); c:fillMask(c:rect(kx + 26, ky - 14, kx + 28, ky - 12), CR.deep)
  for _, s in ipairs{ -1, 1 } do c:px(kx + s * 6, ky - 12, INK); c:px(kx + s * 6, ky - 13, INK); blob(kx + s * 6, ky - 15, 3, 3, { hi = "#ffffff", base = "#fff0d8", shade = "#d8b8a0", deep = "#a07a80" }, 64 + s, { R = 3, tex = 0 }); c:px(kx + s * 6, ky - 15, INK) end
  lantern(kx + 28, ky - 28, .7); for y = ky - 22, ky - 14 do c:px(kx + 28, y, INK) end
  -- boat
  local bx, by = 340, 238
  c:fillMask(c:ellipse(bx + 20, by + 18, 70, 4), "#0c1e3c")
  local boat = poly({ { bx - 62, by - 18 }, { bx + 100, by - 18 }, { bx + 80, by + 12 }, { bx - 40, by + 12 }, { bx - 70, by - 6 } }, { hi = "#d09a5a", base = "#8c5438", shade = "#5c3436", deep = "#34202c" }, 71, { R = 18, tex = .5, sc = 3 })
  c:fillMask(c:rect(bx - 56, by - 14, bx + 96, by - 12), "#a43c48")
  for x = bx - 40, bx + 76, 18 do c:px(x, by - 2, "#34202c"); c:px(x, by - 1, "#34202c") end
  for k, bar in ipairs{ { bx - 30, by - 36, 15 }, { bx + 6, by - 40, 17 }, { bx + 44, by - 34, 15 } } do
    blob(bar[1], bar[2] + 8, bar[3], 17, { hi = "#d8a868", base = "#9a6840", shade = "#643c38", deep = "#38222e" }, 80 + k, { R = 13, tex = .3 })
    c:fillMask(c:rect(bar[1] - bar[3] + 2, bar[2] + 3, bar[1] + bar[3] - 2, bar[2] + 4), "#4e3440")
    c:fillMask(c:rect(bar[1] - bar[3] + 2, bar[2] + 15, bar[1] + bar[3] - 2, bar[2] + 16), "#4e3440")
  end
  for y = by - 62, by - 36 do c:px(bx + 84, y, INK); c:px(bx + 85, y, "#8c5438") end
  lantern(bx + 90, by - 58, 1)
  c:fillMask(c:rect(bx - 64, by + 4, bx - 20, by + 6), "#5c3436")  -- oar
  c:hem(2); c:hem(267)
end
-- (sea hem is drawn inside; others use common finish)

---------------------------------------------------------------- 4 snow leopard ledges
function S.snow()
  GX.bands(c, 0, 200, { "#4e4a98", "#7a5ca8", "#b878b0", "#e898a8", "#f8b8a0", "#fcd8b0" }, 3, .22)
  c:fillMask(c:rect(0, 200, 479, 269), "#5a4478")
  for i = 0, 30 do c:px(floor(H(i, 1, 2) * 478), floor(H(i, 2, 2) * 60), "#f4e8f8") end
  glow(380, 108, 40, {})
  local function peak(cx, by, h, w, seed, R)
    local m = mk()
    for x = cx - w, cx + w do local t = abs(x - cx) / w; local top = by - floor(h * (1 - t) ^ .9 + (vn(x, 0, 5, seed) - .5) * 6)
      for y = top, by do m:set(x, y) end end
    GX.lit(c, m, R6(R), { R = 30, tex = .4, sc = 4, seed = seed, ink = false, amb = .3 })
    m:each(function(x, y) if y < by - h * .62 + (vn(x, y, 3, seed) - .5) * 8 and x < cx + 6 then c:px(x, y, "#fff4f4") elseif y < by - h * .62 + 4 then c:px(x, y, "#e8d0ec") end end)
  end
  peak(110, 160, 96, 110, 3, { hi = "#c8a8d8", base = "#8268b0", shade = "#5a4890", deep = "#3a3070" })
  peak(380, 160, 74, 100, 4, { hi = "#d0b0d8", base = "#9070b4", shade = "#684c94", deep = "#443478" })
  mist(130, 168, "#e8a8c0", 7, 1)
  -- far, mid, near ledges
  local function ledge(x0, x1, ytop, depth, R, seed, snow)
    local pts = { { x0, ytop + 4 }, { x0 + 10, ytop }, { x1 - 10, ytop - 2 }, { x1, ytop + 6 }, { x1 - 6, ytop + depth }, { x0 + 6, ytop + depth } }
    local m = poly(pts, R, seed, { R = 22, tex = .6, sc = 4 })
    for x = x0 + 6, x1 - 6 do local top = ytop - 1 + floor((vn(x, 0, 6, seed) - .5) * 4)
      for y = top, top + 5 do if m:has(x, y) then c:px(x, y, y < top + 3 and "#fff4f4" or "#d8c8e8") end end end
    return m
  end
  ledge(300, 480, 168, 120, { hi = "#a88cb8", base = "#745c98", shade = "#4e4078", deep = "#30285a" }, 11)
  mist(165, 200, "#f0b0b8", 8, .8)
  ledge(150, 340, 202, 80, { hi = "#c0a0b8", base = "#8a6a8c", shade = "#5e4670", deep = "#3a2c58" }, 12)
  mist(198, 226, "#f6b8b0", 9, .7)
  local near = ledge(-20, 400, 238, 60, { hi = "#d8b0b0", base = "#a07880", shade = "#6e4e6c", deep = "#46345c" }, 13)
  -- leopard
  local SL = { hi = "#f4f0ec", base = "#c4bcc0", shade = "#8c849c", deep = "#544c70" }
  local lx, ly = 180, 218
  local tail = c:line({ { lx + 30, ly + 20 }, { lx + 60, ly + 24 }, { lx + 86, ly + 18 }, { lx + 100, ly + 4 }, { lx + 98, ly - 12 } }, 8)
  tail = GX.rough(tail, 14, 1); GX.lit(c, tail, R6(SL), { R = 4, tex = .3, seed = 14, rimlight = true })
  tail:each(function(x, y) if (x // 6 + y // 5) % 3 == 0 and x > lx + 34 then c:px(x, y, SL.deep) end end)
  blob(lx, ly - 4, 40, 30, SL, 15, { R = 30, tex = .3 })
  for i = 0, 22 do local x, y = lx - 30 + floor(H(i, 1, 15) * 62), ly - 28 + floor(H(i, 2, 15) * 50)
    c:fillMask(c:rect(x, y, x + 3, y + 2), SL.deep); c:px(x + 1, y + 1, SL.base) end
  blob(lx - 18, ly + 22, 11, 8, SL, 16, { R = 8 }); blob(lx + 10, ly + 24, 11, 8, SL, 17, { R = 8 })
  for _, x in ipairs{ lx - 24, lx - 18, lx - 12, lx + 4, lx + 10, lx + 16 } do c:px(x, ly + 28, SL.deep) end
  poly({ { lx - 26, ly - 42 }, { lx - 22, ly - 60 }, { lx - 10, ly - 44 } }, SL, 18, { R = 7 })
  poly({ { lx + 8, ly - 44 }, { lx + 20, ly - 60 }, { lx + 24, ly - 40 } }, SL, 19, { R = 7 })
  blob(lx - 2, ly - 34, 26, 21, SL, 20, { R = 22, tex = .25 })
  blob(lx - 2, ly - 24, 10, 7, { hi = "#ffe4e0", base = "#e8bcc0", shade = "#b08a9c", deep = "#7a5a78" }, 21, { R = 6, tex = 0 })
  c:fillMask(c:rect(lx - 4, ly - 28, lx, ly - 26), INK)
  for _, s in ipairs{ -1, 1 } do c:fillMask(c:rect(lx - 2 + s * 11, ly - 40, lx - 1 + s * 11, ly - 36), "#7ac8c0"); c:fillMask(c:rect(lx - 2 + s * 11, ly - 39, lx - 2 + s * 11, ly - 38), INK)
    c:px(lx - 1 + s * 13, ly - 33, SL.deep); c:px(lx + s * 13, ly - 31, SL.deep) end
  for i = 0, 6 do c:px(lx - 12 + i * 4, ly - 48 + (i % 2), SL.deep) end
  -- cairn with prayer flags (quirk)
  local cx = 60
  for i, w in ipairs{ 26, 20, 15, 10 } do blob(cx, 238 - (i - 1) * 12 - 6, w, 8, { hi = "#d8d0d8", base = "#9a92a4", shade = "#6a6088", deep = "#40386a" }, 30 + i, { R = 8 }) end
  for y = 160, 206 do c:px(cx, y, INK) end
  for i = 0, 40 do local t = i / 40; c:px(floor(cx + t * 110), floor(166 + t * 36 + sin(t * 3.14) * 8) - 4, INK) end
  for i = 1, 7 do local t = i / 8; local x, y = floor(cx + t * 110), floor(166 + t * 36 + sin(t * 3.14) * 8) - 3
    c:fillMask(c:rect(x - 2, y, x + 2, y + 5), ({ "#e0505a", "#f4d070", "#4aa8c8", "#f8f0e0", "#58b070" })[i % 5 + 1]) end
end

---------------------------------------------------------------- 5 the canopy bridges
function S.canopy()
  GX.bands(c, 0, 269, { "#4a9a80", "#6cb88a", "#98d098", "#c4e49c", "#eef4b0" }, 3, .25, function(x, y) return y > 30 and abs(x - 240 - (y - 100) * .3) < 30 end, "#fff8b8")
  local FAR = { hi = "#b8e0a4", base = "#8cc89a", shade = "#6aae90", deep = "#58987e" }
  local MID = { hi = "#8cd08c", base = "#5aaa78", shade = "#3e8a6c", deep = "#2e6e5e" }
  local NEAR = { hi = "#70b870", base = "#3e8a60", shade = "#2c6c58", deep = "#1e4c48" }
  for i = 0, 7 do local x = 30 + i * 64 + (H(i, 1, 3) - .5) * 20; c:fillMask(c:rect(floor(x), 70 + (i % 3) * 8, floor(x) + 4, 200), "#7ab496") end
  for i = 0, 13 do leafmass(floor(-10 + i * 40 + (H(i, 1, 4) - .5) * 20), 96 + floor((H(i, 2, 4) - .5) * 24), 34 + floor(H(i, 3, 4) * 12), 18 + floor(H(i, 4, 4) * 6), FAR, 100 + i, false) end
  mist(100, 160, "#d4ecb0", 6, 1.1)
  for i = 0, 11 do leafmass(floor(i * 46 + (H(i, 1, 5) - .5) * 30), 140 + floor((H(i, 2, 5) - .5) * 26), 38 + floor(H(i, 3, 5) * 14), 22 + floor(H(i, 4, 5) * 8), MID, 200 + i, false) end
  mist(160, 200, "#b8e0a0", 9, .8)
  for i = 0, 8 do leafmass(floor(i * 62 + (H(i, 1, 6) - .5) * 40), 186 + floor((H(i, 2, 6) - .5) * 22), 40 + floor(H(i, 3, 6) * 12), 20 + floor(H(i, 4, 6) * 8), NEAR, 300 + i, false) end
  -- bridge deck in perspective, vanishing (240,126)
  local function Lx(y, side) local t = (y - 126) / (270 - 126); return 240 + side * (6 + t * 124) end
  local BR = R6{ hi = "#e0a860", base = "#a86a3c", shade = "#6e3e38", deep = "#3a2430" }
  local deck = c:poly({ { Lx(126, -1), 126 }, { Lx(126, 1), 126 }, { Lx(270, 1), 270 }, { Lx(270, -1), 270 } })
  c:fillMask(deck, "#3a2430")
  for k = 0, 20 do
    local t0, t1 = (k / 21) ^ 1.8, ((k + .72) / 21) ^ 1.8
    local y0, y1 = floor(126 + t0 * 144), floor(126 + t1 * 144)
    for y = y0, y1 do for x = floor(Lx(y, -1)) + 1, floor(Lx(y, 1)) - 1 do
      local v = .7 - (y - y0) / max(1, y1 - y0 + 1) * .5 + (vn(x, y, 3, k) - .5) * .35 - .06 * (1 - t0)
      c:px(x, y, pick(BR, v)) end end
  end
  -- rope rails
  for _, s in ipairs{ -1, 1 } do
    for y = 126, 269 do
      local t = (y - 126) / 144; local x = floor(Lx(y, s) + s * (2 + t * 6)); local yy = y - floor(10 + t * 78)
      c:fillMask(c:rect(x, yy, x + (t > .5 and 2 or 1), yy + (t > .5 and 2 or 1)), t > .4 and "#e8c890" or "#c8a070")
      c:px(x, yy + 1 + (t > .5 and 2 or 0), INK)
    end
    for k = 0, 5 do
      local t = (k / 6) ^ 1.6 * .98 + .02; local y = floor(126 + t * 144); local x = floor(Lx(y, s) + s * (2 + t * 6)); local top = y - floor(10 + t * 78)
      local w = max(1, floor(1 + t * 3))
      c:fillMask(c:rect(x - w, top, x + w, y), BR[3]); c:fillMask(c:rect(x - w, top, x - w, y), BR[5])
      for yy = top + 6, y, 8 do c:px(x + s * 3, yy, "#c8a070") end
    end
  end
  -- giant trunks
  local TR = { hi = "#d8985a", base = "#9a5e3e", shade = "#64363c", deep = "#3a2030" }
  local function trunk(x0, x1, seed)
    local m = mk(); for y = 0, 269 do local wob = floor((vn(0, y, 16, seed) - .5) * 8); for x = x0 + wob, x1 + wob do m:set(x, y) end end
    GX.lit(c, GX.rough(m, seed, 1), R6(TR), { R = (x1 - x0) / 2, tex = .7, sc = 3, seed = seed, rimlight = true,
      fn = function(x, y) return sin(x * .8 + vn(x, y, 14, seed) * 4) * .12 end })
    return m
  end
  local tl, tr = trunk(-10, 50, 71), trunk(432, 492, 72)
  poly({ { 48, 150 }, { 130, 156 }, { 128, 164 }, { 48, 170 } }, TR, 73, { R = 6 })   -- branch the bridge hangs from
  poly({ { 432, 150 }, { 350, 156 }, { 352, 164 }, { 432, 170 } }, TR, 74, { R = 6 })
  -- foliage canopy
  for _, f in ipairs{ { 40, 20, 80, 36 }, { 150, 6, 70, 26 }, { 330, 8, 70, 28 }, { 440, 22, 80, 38 }, { 240, 0, 60, 18 } } do
    GX.foliage(c, f[1], f[2], f[3], f[4], { hi = "#a8e070", base = "#58b058", shade = "#2e8058", deep = "#1e5a4a" }, f[1], {})
  end
  -- hanging lantern + red panda-ish squirrel
  for y = 0, 70 do c:px(240, y, INK) end
  lantern(240, 80, 1)
  local SQ = { hi = "#f4a868", base = "#c8683c", shade = "#8e3c3c", deep = "#4e2438" }
  local sx, sy = 316, 232
  c:fillMask(c:ellipse(sx, sy + 20, 28, 3), "#2a1824")
  local tail = poly({ { sx + 14, sy + 14 }, { sx + 50, sy + 10 }, { sx + 60, sy - 14 }, { sx + 48, sy - 38 }, { sx + 30, sy - 30 }, { sx + 36, sy - 8 }, { sx + 20, sy } }, SQ, 81, { R = 12 })
  tail:each(function(x, y) if (y // 6) % 2 == 0 and x > sx + 24 then c:px(x, y, SQ.shade) end end)
  blob(sx, sy, 22, 20, SQ, 82, { R = 18 }); blob(sx, sy + 6, 11, 11, { hi = "#fff0d0", base = "#f4d0a0", shade = "#c89878", deep = "#8a5a68" }, 83, { R = 8 })
  blob(sx - 10, sy + 20, 7, 4, SQ, 84, { R = 4 }); blob(sx + 8, sy + 20, 7, 4, SQ, 85, { R = 4 })
  poly({ { sx - 14, sy - 30 }, { sx - 12, sy - 44 }, { sx - 2, sy - 32 } }, SQ, 86, { R = 6 }); poly({ { sx + 4, sy - 32 }, { sx + 12, sy - 44 }, { sx + 16, sy - 28 } }, SQ, 87, { R = 6 })
  blob(sx - 4, sy - 22, 17, 14, SQ, 88, { R = 14 })
  blob(sx - 10, sy - 16, 8, 6, { hi = "#fff0d0", base = "#f4d0a0", shade = "#c89878", deep = "#8a5a68" }, 89, { R = 5, tex = 0 })
  eye(sx - 12, sy - 26); eye(sx + 2, sy - 26); c:fillMask(c:rect(sx - 8, sy - 18, sx - 6, sy - 17), INK)
  -- acorn in paws
  blob(sx - 10, sy + 4, 5, 5, { hi = "#e8c070", base = "#b88440", shade = "#7a4c38", deep = "#442a34" }, 90, { R = 4 }); c:fillMask(c:rect(sx - 14, sy - 1, sx - 6, sy), "#6a3e34")
end

---------------------------------------------------------------- 6 the long wall walk
function S.wall()
  GX.bands(c, 0, 160, { "#5a98d0", "#7cb4dc", "#a8d0e4", "#d0e4e8", "#f4ecd8" }, 3, .2)
  c:cloud(60, 36, 60, "#fffaf0", "#d8e4ec"); c:cloud(380, 24, 50, "#fffaf0", "#d8e4ec")
  for i = 0, 4 do local x = 100 + i * 70; c:px(x, 50 + (i % 3) * 8, INK); c:px(x + 1, 49 + (i % 3) * 8, INK); c:px(x - 1, 49 + (i % 3) * 8, INK) end
  local function hills(top, R, seed, a)
    local m = mk(); for x = 0, 479 do local t = top + floor(sin(x * .018 + seed) * a + (vn(x, 0, 18, seed) - .5) * a); for y = t, 170 do m:set(x, y) end end
    GX.lit(c, m, R6(R), { R = 40, tex = .4, ink = false, seed = seed, amb = .4 })
  end
  hills(104, { hi = "#c8dcd8", base = "#9ac0c4", shade = "#7ca4b8", deep = "#6488a8" }, 3, 14)
  mist(124, 156, "#e8eee0", 4, 1)
  hills(128, { hi = "#8cc8a0", base = "#5ca88c", shade = "#428478", deep = "#306468" }, 6, 10)
  -- autumn trees on hills
  for i = 0, 22 do local x = floor(H(i, 1, 6) * 470); local y = 142 + floor(H(i, 2, 6) * 20)
    blob(x, y, 6, 5, i % 2 == 0 and { hi = "#f8c060", base = "#e0803c", shade = "#a8483c", deep = "#6a2c40" } or { hi = "#f4a070", base = "#d05a48", shade = "#963c50", deep = "#5a2448" }, i * 7, { R = 4, tex = .3 }) end
  -- landscape beyond the parapets: perspective fields, hedges, stream, trees
  local vx, vy = 292, 148
  local FLD = { { "#8cc07a", "#a0cc88" }, { "#d8c070", "#e6d488" }, { "#6ca06a", "#80b476" }, { "#c8a060", "#d8b474" }, { "#a8b86a", "#bccc80" }, { "#c07a5c", "#d08e70" } }
  local hazeC = {}
  for y = vy, 269 do
    local dz = y - vy + 3; local row = floor(log(dz) * 3.6)
    local hz = floor(clamp(1 - dz / 50, 0, 1) * 4) / 4
    for x = 0, 479 do
      local u = (x - vx) / dz * 1.7; local ch = floor(u + 500)
      local f = FLD[1 + floor(H(row, ch, 5) * 6) % 6]
      local col = (((x - vx) / dz * 5 + 1000) % 2 < 1) and f[1] or f[2]
      local rowE = floor(log(dz - 1 > 0 and dz - 1 or 1) * 3.6)
      if row ~= rowE then col = "#3c7050" elseif floor((x - 1 - vx) / dz * 1.7 + 500) ~= ch then col = "#4c8058" end
      if hz > 0 then local k = col .. hz; hazeC[k] = hazeC[k] or mix(col, "#e8eee0", hz * .65); col = hazeC[k] end
      c:px(x, y, col)
    end
    local xr = floor(vx - 250 + 20 * sin(y * .09) - (y - vy) * 1.3); local wr = max(1, floor(dz * .12))
    for x = xr - wr, xr + wr do c:px(x, y, abs(x - xr) >= wr and "#cfeaf0" or ((x + y) % 7 == 0 and "#b8e0ec" or "#6cb8d8")) end
  end
  for i = 0, 70 do
    local y = vy + 8 + floor(H(i, 2, 6) * 112); local x = floor(H(i, 1, 6) * 480); local r = 2 + floor((y - vy) * .05)
    local tm = GX.disc(mk(), x, y, r, r - 1); GX.lit(c, tm, R6{ hi = "#8cd070", base = "#3c8a50", shade = "#2c6648", deep = "#1e4a3c" }, { R = r, ink = false, rimlight = false, tex = .2 })
  end
  for _, hs in ipairs{ { 40, 200, 1.3 }, { 120, 170, .8 }, { 440, 190, 1.1 } } do
    local x, y, s = hs[1], hs[2], hs[3]
    c:fillMask(c:rect(x - floor(7 * s), y - floor(6 * s), x + floor(7 * s), y), "#f4e4c4"); c:rim(c:rect(x - floor(7 * s), y - floor(6 * s), x + floor(7 * s), y), INK)
    c:fillMask(c:poly({ { x - floor(9 * s), y - floor(6 * s) }, { x, y - floor(14 * s) }, { x + floor(9 * s), y - floor(6 * s) } }), "#d0503c"); c:fillMask(c:rect(x - 1, y - floor(3 * s), x + 1, y), "#6a3c2c")
  end
  local ST = R6{ hi = "#eadfca", base = "#c4b2a0", shade = "#907f90", deep = "#5a4c6a" }
  local function ex_(y, side) local t = (y - vy) / (270 - vy); return vx + side * (14 + t * 186) end
  local floorm = c:poly({ { ex_(vy, -1), vy }, { ex_(vy, 1), vy }, { ex_(270, 1), 270 }, { ex_(270, -1), 270 } })
  floorm:each(function(x, y)
    local t = (y - vy) / (270 - vy); local k = (x - vx) / (14 + t * 186)
    local row = log(1 + t * 14) * 5; local rr = row - floor(row)
    local col = floor((k + 1) * 5 + (floor(row) % 2) * .5)
    local v = .62 + t * .06 + (H(floor(row), col, 3) - .5) * .3 + (vn(x, y, 14, 4) - .5) * .12 - abs(k) * .06
    if rr < .09 or (((k + 1) * 5 + (floor(row) % 2) * .5) % 1) < .05 * (1 - t * .5) then v = v - .24 end
    if rr > .09 and rr < .17 and H(floor(row), col, 5) > .4 then v = v + .1 end
    c:px(x, y, pick(ST, v)) end)
  -- parapets: brick faces and merlons, built column by column in perspective
  local BRK0 = { hi = "#e0a8a0", base = "#b8706c", shade = "#845068", deep = "#52344e" }
  local BRK = R6{ hi = "#ecb4a8", base = "#c07470", shade = "#8c5470", deep = "#563650" }
  local BRL = R6{ hi = "#d49890", base = "#a46068", shade = "#744a68", deep = "#4a3048" }
  for _, side in ipairs{ -1, 1 } do
    local B = side < 0 and BRL or BRK
    for x = 0, 479 do
      local ax = (x - vx) * side
      if ax >= 14 then
        local t = (ax - 14) / 186; local ye = vy + t * (270 - vy)
        local h = 6 + t * 46; local cp = max(2, floor(t * 5)); local u = log(1 + t * 14) * 5
        local ph = (u / 2) % 1; local mh = h * .5
        local rowh = h / 4
        for y = floor(ye - h), floor(ye) do
          if y >= vy - 12 and y <= 269 then
            local py = ye - y; local r = floor(py / rowh); local bu = u * 1.5 + (r % 2) * .5
            local hv = H(floor(bu), r, 7)
            local v = .62 + (hv - .5) * .3 - (side < 0 and .08 or 0) + (py < 2 and -.15 or 0)
            if py % rowh < 1 or (bu % 1) < .07 then v = .2 end
            c:px(x, y, pick(B, v))
          end
        end
        for y = floor(ye - h - cp), floor(ye - h) - 1 do if y <= 269 then c:px(x, y, y == floor(ye - h - cp) and B[6] or B[5]) end end
        local top = floor(ye - h - cp)
        if ph < .5 then
          for y = floor(top - mh), top - 1 do if y <= 269 then
            local py = top - y; local bu = u * 1.5; local v = .64 + (H(floor(bu), floor(py / 5), 9) - .5) * .25 - (side < 0 and .08 or 0)
            if py % 5 == 0 or (bu % 1) < .07 then v = .22 end
            if y == floor(top - mh) then v = 1.0 end
            c:px(x, y, pick(B, v)) end end
        elseif ph < .6 then
          for y = floor(top - mh), top - 1 do if y <= 269 then c:px(x, y, B[2]) end end
        end
        for y = floor(top - mh - 1), floor(top - mh - 1) do if ph < .5 and y <= 269 then c:px(x, y, INK) end end
      end
    end
  end
  BRK = BRK0
  -- watch tower at the end
  local tx, ty = 292, 146
  local base = c:rect(tx - 26, ty - 24, tx + 26, ty); c:rim(base, INK); GX.lit(c, base, R6(BRK), { R = 22, tex = .4, ink = false, seed = 5, amb = .3 })
  c:fillMask(c:rect(tx - 7, ty - 14, tx + 7, ty), "#3a2438"); c:fillMask(c:rect(tx - 5, ty - 10, tx + 5, ty), "#f4d070")
  local wall = c:rect(tx - 20, ty - 52, tx + 20, ty - 24); c:rim(wall, INK); GX.lit(c, wall, R6{ hi = "#f08868", base = "#d04c50", shade = "#963c52", deep = "#5a2848" }, { R = 18, tex = .3, ink = false, seed = 6, amb = .3 })
  for i = -1, 1 do c:fillMask(c:rect(tx + i * 12 - 3, ty - 46, tx + i * 12 + 3, ty - 36), "#f4d070") end
  local ROOF = { hi = "#6ad0b8", base = "#2e9a9c", shade = "#1e6a82", deep = "#16405e" }
  poly({ { tx - 36, ty - 52 }, { tx - 24, ty - 62 }, { tx + 24, ty - 62 }, { tx + 36, ty - 52 }, { tx + 18, ty - 54 }, { tx - 18, ty - 54 } }, ROOF, 7, { R = 8 })
  c:fillMask(c:rect(tx - 14, ty - 76, tx + 14, ty - 62), "#d04c50"); c:rim(c:rect(tx - 14, ty - 76, tx + 14, ty - 62), INK)
  poly({ { tx - 26, ty - 76 }, { tx - 14, ty - 86 }, { tx + 14, ty - 86 }, { tx + 26, ty - 76 }, { tx + 10, ty - 78 }, { tx - 10, ty - 78 } }, ROOF, 8, { R = 8 })
  for y = ty - 100, ty - 86 do c:px(tx, y, INK) end
  poly({ { tx, ty - 100 }, { tx + 24, ty - 96 }, { tx, ty - 90 } }, { hi = "#ffe890", base = "#f0b030", shade = "#b87a2c", deep = "#6e4430" }, 9, { R = 4 })
  -- red panda sitting on the walk
  local RP = { hi = "#f4a070", base = "#c8583c", shade = "#8e3446", deep = "#4e2040" }
  local px, py = 360, 226
  c:fillMask(c:ellipse(px, py + 26, 36, 5), "#6a5a74")
  local tail = poly({ { px - 20, py + 14 }, { px - 52, py + 18 }, { px - 66, py + 4 }, { px - 60, py - 14 }, { px - 44, py - 8 }, { px - 44, py + 4 }, { px - 24, py + 4 } }, RP, 91, { R = 9 })
  tail:each(function(x, y) if (x // 5) % 2 == 0 and x < px - 28 then c:px(x, y, "#f0d0a0") end end)
  blob(px, py + 4, 26, 24, RP, 92, { R = 22 }); blob(px, py + 10, 13, 14, { hi = "#6a4a5a", base = "#4a3248", shade = "#34223c", deep = "#241830" }, 93, { R = 9, tex = .1 })
  blob(px - 14, py + 26, 8, 4, { hi = "#6a4a5a", base = "#4a3248", shade = "#34223c", deep = "#241830" }, 94, { R = 4 }); blob(px + 12, py + 26, 8, 4, { hi = "#6a4a5a", base = "#4a3248", shade = "#34223c", deep = "#241830" }, 95, { R = 4 })
  poly({ { px - 24, py - 28 }, { px - 24, py - 46 }, { px - 8, py - 34 } }, RP, 96, { R = 6 }); poly({ { px + 8, py - 34 }, { px + 22, py - 46 }, { px + 26, py - 26 } }, RP, 97, { R = 6 })
  c:fillMask(c:rect(px - 22, py - 42, px - 18, py - 36), "#fff0e0"); c:fillMask(c:rect(px + 18, py - 42, px + 22, py - 36), "#fff0e0")
  blob(px, py - 22, 24, 18, RP, 98, { R = 18, tex = .25 })
  blob(px, py - 14, 14, 9, { hi = "#ffffff", base = "#f6e8d8", shade = "#d0b0a0", deep = "#8a6a78" }, 99, { R = 8, tex = 0 })
  for _, s in ipairs{ -1, 1 } do c:fillMask(c:rect(px + s * 10 - 1, py - 28, px + s * 10 + 2, py - 22), "#fff0e0"); c:fillMask(c:rect(px + s * 10, py - 26, px + s * 10 + 1, py - 24), INK)
    c:px(px + s * 14, py - 18, "#4a3248"); c:px(px + s * 14, py - 17, "#4a3248") end
  c:fillMask(c:rect(px - 2, py - 18, px + 1, py - 16), INK)
  -- quirk: a tiny dumpling in its paws
  blob(px + 22, py + 4, 6, 5, { hi = "#fffaf0", base = "#f0e0c8", shade = "#c8a8a0", deep = "#8a6a78" }, 100, { R = 4, tex = 0 })
end

---------------------------------------------------------------- 7 the red rock songlines
function S.songlines()
  local RR = { hi = "#e8784a", base = "#b04440", shade = "#7a2c44", deep = "#421c3c" }
  local inhole = function(x, y) local cx, hw, top = 240, 118, 22
    if y < top + hw then return (x - cx) ^ 2 + (y - (top + hw)) ^ 2 <= hw * hw end
    return abs(x - cx) <= hw and y <= 170 end
  GX.bands(c, 0, 130, { "#7a5ca8", "#c8689c", "#f08a80", "#f8b070", "#fcd890" }, 3, .2)
  glow(240, 128, 44, { "#f8a868", "#fcc880", "#fde4a0", "#fff4c8" })
  -- distant red mound
  local mound = mk(); for x = 60, 420 do local t = (x - 240) / 180; local top = 128 - floor(22 * (1 - t * t) ^ .6 + (vn(x, 0, 6, 3) - .5) * 3)
    for y = top, 172 do mound:set(x, y) end end
  GX.lit(c, mound, R6{ hi = "#f08868", base = "#c8585a", shade = "#8e3c5c", deep = "#5c2a52" }, { R = 30, tex = .4, ink = false, seed = 3, amb = .4 })
  GX.ground(c, function(x) return 160 + floor((vn(x, 0, 24, 4) - .5) * 6) end, { hi = "#fcc880", base = "#e8905a", shade = "#b05a50", deep = "#6e3450" }, 5, { top = .9, fall = .6, tex = .3, sc = 8 })
  -- songlines: winding dotted paths to the mouth
  local function path(pts, col1, col2, seed)
    for i = 1, #pts - 1 do
      local a, b = pts[i], pts[i + 1]; local n = max(abs(b[1] - a[1]), abs(b[2] - a[2]))
      for s = 0, n, 4 do
        local t = s / n; local x, y = a[1] + (b[1] - a[1]) * t, a[2] + (b[2] - a[2]) * t
        local sc = clamp((y - 150) / 120, .3, 1.2); local r = max(1, floor(1 + sc * 2.2))
        local m = c:ellipse(floor(x), floor(y), r, max(1, floor(r * .6)))
        c:fillMask(m, (floor(s / 4) + i) % 3 == 0 and col2 or col1)
      end
    end
  end
  path({ { 240, 172 }, { 226, 190 }, { 270, 206 }, { 190, 226 }, { 150, 250 }, { 130, 272 } }, "#fff0c0", "#f8b848", 1)
  path({ { 244, 172 }, { 262, 188 }, { 230, 204 }, { 320, 224 }, { 380, 250 }, { 410, 272 } }, "#fff0c0", "#58c0b8", 2)
  for _, cc in ipairs{ { 100, 214 }, { 380, 196 }, { 60, 258 } } do   -- concentric waterhole circles
    for r = 3, 12, 3 do for a = 0, 20 do local ang = a / 20 * 6.283; c:px(floor(cc[1] + cos(ang) * r * 1.8), floor(cc[2] + sin(ang) * r * .7), (r % 6 == 0) and "#f8b848" or "#fff0c0") end end
  end
  -- rock mass with arch
  local rock = mk()
  for y = 0, 269 do for x = 0, 479 do
    local ledge = 178 + floor((vn(x, 0, 12, 7) - .5) * 8) + floor(max(0, abs(x - 240) - 118) * .3)
    if y < ledge and not inhole(x, y) then rock:set(x, y) end
  end end
  rock = GX.rough(rock, 8, 1)
  GX.lit(c, rock, R6(RR), { R = 18, tex = .7, sc = 4, seed = 5, amb = .26,
    fn = function(x, y) return sin(y * .3 + vn(x, y, 16, 5) * 5) * .07 + (H(x // 3, y // 6, 8) - .5) * .14 end })
  -- dot art on the walls
  local function dots(cx, cy, w, h, seed)
    for i = 0, 70 do local a = i / 70 * 6.283 * 3; local rr = i / 70 * min(w, h)
      local x, y = floor(cx + cos(a) * rr * w / min(w, h)), floor(cy + sin(a) * rr * h / min(w, h))
      if rock:has(x, y) and rock:has(x + 1, y + 1) then c:fillMask(c:rect(x, y, x + 1, y + 1), i % 4 == 0 and "#f8b848" or "#fff0c0") end end
  end
  dots(54, 80, 40, 40, 1); dots(430, 90, 36, 44, 2); dots(60, 150, 30, 14, 3); dots(420, 156, 30, 14, 4)
  for _, h in ipairs{ { 100, 120 }, { 380, 130 } } do   -- hand prints
    local m = c:rect(h[1], h[2], h[1] + 7, h[2] + 8); if rock:has(h[1], h[2]) and rock:has(h[1] + 7, h[2] + 8) then
      c:fillMask(m, "#fff0c0"); for i = 0, 3 do c:fillMask(c:rect(h[1] + i * 2, h[2] - 4 + ((i == 1 or i == 2) and 0 or 1), h[1] + i * 2, h[2] - 1), "#fff0c0") end end
  end
  -- spinifex tufts
  for _, p in ipairs{ { 40, 232 }, { 440, 226 }, { 300, 244 }, { 180, 196 } } do
    for i = -4, 4 do for j = 0, 16 - abs(i) * 2 do c:px(p[1] + i * 2 + floor(i * j * .12), p[2] - j, j > 10 and "#e8d070" or (j > 4 and "#c0a048" or "#7a6a3c")) end end
  end
  -- bilby
  local B = { hi = "#c8b4bc", base = "#9a8498", shade = "#6e5878", deep = "#443458" }
  local bx, by = 250, 236
  c:fillMask(c:ellipse(bx, by + 24, 34, 5), "#6e3450")
  local tail = c:line({ { bx - 20, by + 14 }, { bx - 44, by + 16 }, { bx - 60, by + 4 }, { bx - 62, by - 12 } }, 6)
  tail = GX.rough(tail, 20, 1); GX.lit(c, tail, R6{ hi = "#fff4e8", base = "#f0e0d8", shade = "#b8a0b0", deep = "#6a4a68" }, { R = 3, tex = .2, rimlight = true })
  tail:each(function(x, y) if y > by - 4 or x < bx - 56 then if (x // 5) % 3 == 0 then c:px(x, y, "#3a2a48") end end end)
  blob(bx, by + 2, 24, 22, B, 21, { R = 20 }); blob(bx + 2, by + 10, 11, 11, { hi = "#f4e8e0", base = "#d8c4c8", shade = "#a08aa0", deep = "#6a5280" }, 22, { R = 8 })
  blob(bx - 12, by + 22, 8, 4, B, 23, { R = 4 }); blob(bx + 12, by + 22, 8, 4, B, 24, { R = 4 })
  local EAR = { hi = "#ffd0d0", base = "#e898a8", shade = "#b8647c", deep = "#7a3e5c" }
  poly({ { bx - 18, by - 22 }, { bx - 28, by - 56 }, { bx - 6, by - 28 } }, B, 25, { R = 8 }); poly({ { bx + 6, by - 28 }, { bx + 22, by - 58 }, { bx + 24, by - 20 } }, B, 26, { R = 8 })
  c:fillMask(c:poly({ { bx - 18, by - 28 }, { bx - 24, by - 48 }, { bx - 10, by - 30 } }), EAR.base); c:fillMask(c:poly({ { bx + 10, by - 32 }, { bx + 20, by - 50 }, { bx + 20, by - 26 } }), EAR.base)
  blob(bx - 2, by - 18, 20, 15, B, 27, { R = 16 })
  blob(bx - 18, by - 12, 12, 6, B, 28, { R = 6, tex = .2 }); c:fillMask(c:rect(bx - 30, by - 14, bx - 28, by - 12), INK); c:px(bx - 29, by - 14, "#f4d0d0")
  eye(bx - 8, by - 24); eye(bx + 6, by - 24)
  for _, p in ipairs{ { bx - 14, by - 6 }, { bx - 12, by - 5 } } do c:px(p[1], p[2], "#e898a8") end
end

fn = S[fn]
local ok, e = xpcall(fn, debug.traceback); if not ok then print(e) end
c:hem(2); c:hem(267)
c:save{ aseprite = d.."/out/delve-"..name..".aseprite", png = d.."/out/delve-"..name..".png", scale = 1 }
end

local list = {
  { "rose-red-canyon-city", "rose" }, { "salt-mine-galleries", "salt" }, { "the-canopy-bridges", "canopy" }, { "the-long-wall-walk", "wall" } }
for _, e in ipairs(list) do if NAME == "all" or NAME == e[1] or NAME == e[2] then build(e[1], e[2]) end end
