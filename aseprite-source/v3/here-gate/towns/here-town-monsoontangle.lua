-- Hearth Pop v3 "here" gate view: The Monsoon Tangle (canal town on stilts, monsoon evening)
-- 480x270 native, one-point perspective to (240,112). Self-contained pixel buffer, pushed to an HP canvas.
local NAME = "here-town-monsoontangle"
local HP = dofile("/home/user/gnome-venture/aseprite-source/v3/lib/hp.lua")
local OUT = (app.params and app.params["out"]) or "/home/user/gnome-venture/aseprite-source/v3/here-gate/towns/"
local W, H = 480, 270
local VX, VY = 240, 112
local B = {}
local floor, sin, abs = math.floor, math.sin, math.abs

local function P(x, y, c)
  x = floor(x); y = floor(y)
  if x >= 0 and x < W and y >= 0 and y < H then B[y * W + x] = c end
end
local function hash(x, y, s)
  local n = sin(x * 12.9898 + y * 78.233 + (s or 0) * 37.719) * 43758.5453
  return n - floor(n)
end
local function rgb(h) return tonumber(h:sub(2, 3), 16), tonumber(h:sub(4, 5), 16), tonumber(h:sub(6, 7), 16) end
local function hex(r, g, b)
  r = math.max(1, math.min(254, floor(r + 0.5))); g = math.max(1, math.min(254, floor(g + 0.5))); b = math.max(1, math.min(254, floor(b + 0.5)))
  return string.format("#%02x%02x%02x", r, g, b)
end
local function mix(a, b, t)
  local r1, g1, b1 = rgb(a); local r2, g2, b2 = rgb(b)
  return hex(r1 + (r2 - r1) * t, g1 + (g2 - g1) * t, b1 + (b2 - b1) * t)
end

-- masks ----------------------------------------------------------------
local function M() return { p = {} } end
local function madd(m, x, y) x = floor(x); y = floor(y); if x >= 0 and x < W and y >= 0 and y < H then m.p[y * W + x] = true end end
local function mhas(m, x, y) return x >= 0 and x < W and y >= 0 and y < H and m.p[y * W + x] == true end
local function each(m, f) for k in pairs(m.p) do f(k % W, k // W) end end
local function rectM(x0, y0, x1, y1) local m = M(); for y = y0, y1 do for x = x0, x1 do madd(m, x, y) end end; return m end
local function ellM(cx, cy, rx, ry)
  local m = M()
  for y = floor(cy - ry) - 1, floor(cy + ry) + 1 do for x = floor(cx - rx) - 1, floor(cx + rx) + 1 do
    local dx, dy = (x + 0.5 - cx) / rx, (y + 0.5 - cy) / ry
    if dx * dx + dy * dy <= 1 then madd(m, x, y) end
  end end
  return m
end
local function polyM(pts)
  local m = M()
  local a, b, c, d = 1e9, 1e9, -1e9, -1e9
  for _, p in ipairs(pts) do a = math.min(a, p[1]); b = math.min(b, p[2]); c = math.max(c, p[1]); d = math.max(d, p[2]) end
  for y = floor(b), floor(d) + 1 do
    local py = y + 0.5
    for x = floor(a), floor(c) + 1 do
      local px = x + 0.5
      local inside = false
      local j = #pts
      for i = 1, #pts do
        local xi, yi, xj, yj = pts[i][1], pts[i][2], pts[j][1], pts[j][2]
        if ((yi > py) ~= (yj > py)) and (px < (xj - xi) * (py - yi) / (yj - yi) + xi) then inside = not inside end
        j = i
      end
      if inside then madd(m, x, y) end
    end
  end
  return m
end
local function lineM(pts, w, m)
  m = m or M()
  for i = 1, #pts - 1 do
    local a, b = pts[i], pts[i + 1]
    local dx, dy = b[1] - a[1], b[2] - a[2]
    local n = floor(math.max(abs(dx), abs(dy)) * 2) + 1
    for s = 0, n do
      local t = s / n
      local x0 = floor(a[1] + dx * t - (w - 1) / 2 + 0.5)
      local y0 = floor(a[2] + dy * t - (w - 1) / 2 + 0.5)
      for ox = 0, w - 1 do for oy = 0, w - 1 do madd(m, x0 + ox, y0 + oy) end end
    end
  end
  return m
end
local function madd2(m, o) for k in pairs(o.p) do m.p[k] = true end; return m end
local function mcut(m, o) for k in pairs(o.p) do m.p[k] = nil end; return m end
local function bbox(m)
  local a, b, c, d = 1e9, 1e9, -1e9, -1e9
  for k in pairs(m.p) do local x, y = k % W, k // W
    if x < a then a = x end; if y < b then b = y end; if x > c then c = x end; if y > d then d = y end end
  return a, b, c, d
end
local function edgeM(m)
  local e = M()
  for k in pairs(m.p) do local x, y = k % W, k // W
    if not (mhas(m, x - 1, y) and mhas(m, x + 1, y) and mhas(m, x, y - 1) and mhas(m, x, y + 1)) then e.p[k] = true end
  end
  return e
end
local function fill(m, c) each(m, function(x, y) P(x, y, c) end) end
local function edge(m, c) fill(edgeM(m), c) end
local SH = "#3b2c5e"
local function shadeM(m, amt) each(m, function(x, y) local k = y * W + x; if B[k] then B[k] = mix(B[k], SH, amt) end end) end
local function glow(cx, cy, r, amt)
  for dy = -r, r do for dx = -r, r do
    local d = abs(dx) + abs(dy) * 1.2
    if d <= r then
      local x, y = floor(cx + dx), floor(cy + dy)
      local k = y * W + x
      if x >= 0 and x < W and y >= 0 and y < H and B[k] then
        B[k] = mix(B[k], "#ffd27a", (d <= r * 0.5) and amt or amt * 0.5)
      end
    end
  end end
end

-- painters (ramps: 1 deep, 2 shade, 3 base, 4 light, 5 hi) --------------
local function clampi(i) if i < 2 then return 2 elseif i > 5 then return 5 end; return i end
local function blobTone(m, R, seed, noise, noEdge)
  local x0, y0, x1, y1 = bbox(m)
  local cx, cy = (x0 + x1) / 2, (y0 + y1) / 2
  local rx, ry = math.max(1, (x1 - x0) / 2), math.max(1, (y1 - y0) / 2)
  each(m, function(x, y)
    local nx, ny = (x - cx) / rx, (y - cy) / ry
    local l = -0.55 * nx - 0.75 * ny + (hash(x, y, seed) - 0.5) * (noise or 0.3)
    P(x, y, l > 0.75 and R[5] or l > 0.2 and R[4] or l > -0.35 and R[3] or R[2])
  end)
  if not noEdge then edge(m, R[1]) end
end
local function planks(m, R, w, seed, lev)
  local x0, y0, x1, y1 = bbox(m)
  each(m, function(x, y)
    local b = (x - x0) // w
    local hb = hash(b, 1, seed)
    local i = 3 + lev
    if hb > 0.68 then i = i + 1 elseif hb < 0.22 then i = i - 1 end
    if (x - x0) > (x1 - x0) * 0.82 then i = i - 1 end
    local hh = hash(x, y, seed + 3)
    if hh < 0.07 then i = i - 1 elseif hh > 0.96 then i = i + 1 end
    if (x - x0) % w == 0 and x ~= x0 then i = math.min(i, 2) end
    if y - y0 < 2 then i = 2 end
    P(x, y, R[clampi(i)])
  end)
  edge(m, R[1])
end
local function roofTex(m, R, kind, lev, seed)
  local x0, y0, x1, y1 = bbox(m)
  each(m, function(x, y)
    local i = 3 + lev
    if kind == "tin" then
      local k = x % 4
      if k == 0 then i = i - 1 elseif k == 2 then i = i + 1 end
      if hash(x // 3, y // 4, seed) > 0.94 then P(x, y, "#a65a3a"); return end
    else
      local h = hash(x, y // 3 + x % 2, seed)
      if h > 0.7 then i = i + 1 elseif h < 0.25 then i = i - 1 end
      if (y - y0) % 6 == 5 then i = i - 1 end
    end
    if (x - x0) < (x1 - x0) * 0.4 and (y - y0) < (y1 - y0) * 0.55 then i = i + 1 end
    P(x, y, R[clampi(i)])
  end)
  edge(m, R[1])
end
local function post(x0, y0, x1, y1, R)
  local m = rectM(x0, y0, x1, y1)
  each(m, function(x, y)
    local c = R[3]
    if x == x0 then c = R[4] elseif x == x1 then c = R[2] end
    if hash(x, y, 4) < 0.08 then c = R[2] end
    P(x, y, c)
  end)
  edge(m, R[1])
end
local function leaf(ax, ay, bx, by, w, bend, R, seed)
  local L, Rr, C = {}, {}, {}
  local dx, dy = bx - ax, by - ay
  local len = math.sqrt(dx * dx + dy * dy)
  local nx, ny = -dy / len, dx / len
  local n = 12
  for i = 0, n do
    local t = i / n
    local s = sin(math.pi * t)
    local cxp, cyp = ax + dx * t + nx * bend * s, ay + dy * t + ny * bend * s
    local ww = w * (s ^ 0.7)
    C[#C + 1] = { cxp, cyp }
    L[#L + 1] = { cxp + nx * ww, cyp + ny * ww }
    Rr[#Rr + 1] = { cxp - nx * ww, cyp - ny * ww }
  end
  local half1, half2 = {}, {}
  for i = 1, #L do half1[#half1 + 1] = L[i] end
  for i = #C, 1, -1 do half1[#half1 + 1] = C[i] end
  for i = 1, #C do half2[#half2 + 1] = C[i] end
  for i = #Rr, 1, -1 do half2[#half2 + 1] = Rr[i] end
  local m1, m2 = polyM(half1), polyM(half2)
  local lit1 = (nx + ny * 1.3) < 0  -- side facing upper-left
  each(m1, function(x, y) P(x, y, (hash(x, y, seed) > 0.9) and R[5] or (lit1 and R[4] or R[3])) end)
  each(m2, function(x, y) P(x, y, (hash(x, y, seed) > 0.93) and R[4] or (lit1 and R[3] or R[4])) end)
  -- veins
  for i = 2, n - 1, 2 do
    local c = C[i]
    P(c[1] + nx * 1.5, c[2] + ny * 1.5 + 1, R[2]); P(c[1] - nx * 1.5, c[2] - ny * 1.5 + 1, R[2])
  end
  local all = madd2(m1, m2)
  edge(all, R[1])
  fill(lineM(C, 1), R[2])
  return all
end
local function lantern(x, y, w, h, R, gr)
  glow(x + w / 2, y + h / 2, gr or 4, 0.35)
  local m = rectM(x, y, x + w - 1, y + h - 1)
  mcut(m, rectM(x, y, x, y)); mcut(m, rectM(x + w - 1, y, x + w - 1, y))
  mcut(m, rectM(x, y + h - 1, x, y + h - 1)); mcut(m, rectM(x + w - 1, y + h - 1, x + w - 1, y + h - 1))
  each(m, function(px, py)
    local c = R[3]
    if px == x + w - 1 or py == y + h - 1 then c = R[2] end
    if px == x + 1 and py > y and py < y + h - 2 then c = R[4] end
    if w >= 7 and (px - x) % 3 == 0 and px ~= x and px ~= x + w - 1 then c = R[2] end
    if w >= 5 and px >= x + 2 and px <= x + w - 3 and py >= y + 2 and py <= y + h - 3 and (px - x) % 3 ~= 0 then c = R[5] end
    P(px, py, c)
  end)
  if w >= 5 then
    for px = x + 1, x + w - 2 do P(px, y - 1, "#7a4a2a"); P(px, y + h, "#7a4a2a") end
    P(x + w // 2, y + h + 1, "#e8b04a")
  end
end
local LR = { red = { "#5a1e2a", "#a83236", "#e0503e", "#f8906a", "#ffcf86" },
  pink = { "#5a1e3a", "#b8405e", "#ee7a90", "#ffadb6", "#ffe0b0" },
  yel = { "#6a4a1e", "#cf9030", "#f6c850", "#ffe48a", "#fff0bc" },
  ora = { "#6a2e1e", "#cc602c", "#f6963e", "#ffc06a", "#ffe6a0" } }
local LCYC = { LR.red, LR.ora, LR.yel, LR.pink }

-- palette ramps
local GREEN = { "#1f3d36", "#2f5a40", "#3f7a45", "#5e9a4c", "#8cbd5a" }
local GRASS = { "#24493a", "#3a6a42", "#4c7d47", "#62964f", "#86b45a" }
local BARK = { "#3a2224", "#5a3a30", "#7a5440", "#9a7050", "#b88e64" }
local TEAK = { "#2a1820", "#4a2a26", "#6a3e2e", "#8a5638", "#a87048" }
local WOOD = { "#3e2626", "#6a4232", "#8c5a3e", "#a87250", "#c48e64" }
local THATCH = { "#5a3824", "#8a5e34", "#b48442", "#d2a656", "#ecca80" }

-- 1 SKY ------------------------------------------------------------------
local sky = { "#2f2552", "#3e2a63", "#55306f", "#723877", "#94437c", "#b8527e", "#d6687c", "#e9867a", "#f2a77c", "#f7c588", "#f9d99a" }
for y = 0, 111 do for x = 0, W - 1 do
  local yy = y + 2 * sin(x / 31) + 1.2 * sin(x / 13 + 2)
  local i = floor(yy / 10) + 1
  if i < 1 then i = 1 elseif i > #sky then i = #sky end
  P(x, y, sky[i])
end end
-- a few early stars
for i = 1, 30 do local x, y = floor(hash(i, 1, 2) * 470) + 5, floor(hash(i, 2, 2) * 26) + 14
  if hash(i, 3, 2) > 0.4 then P(x, y, "#c8b4e0") end end

local function cloud(blobs, yb)
  for _, b in ipairs(blobs) do
    local m = ellM(b[1], b[2], b[3], b[4]); mcut(m, rectM(0, yb + 1, W - 1, H - 1))
    each(m, function(x, y)
      local nx, ny = (x - b[1]) / b[3], (y - b[2]) / b[4]
      local l = -0.45 * nx - 0.85 * ny
      local c
      if y >= yb - 1 then c = "#9a6088" elseif l > 0.6 then c = "#fde0bc" elseif l > 0.12 then c = "#f4b6a6" elseif l > -0.38 then c = "#d98c9c" else c = "#b56c90" end
      P(x, y, c)
    end)
    each(edgeM(m), function(x, y) if (y - b[2]) > 0 or (x - b[1]) > b[3] * 0.4 then P(x, y, "#86507e") end end)
  end
end
cloud({ { 52, 60, 24, 12 }, { 84, 50, 26, 18 }, { 116, 56, 22, 13 }, { 140, 62, 14, 8 } }, 66)
cloud({ { 326, 50, 26, 13 }, { 358, 38, 28, 20 }, { 394, 46, 26, 15 }, { 422, 54, 18, 10 } }, 60)
cloud({ { 150, 86, 14, 6 }, { 170, 84, 16, 8 } }, 90)
cloud({ { 304, 88, 14, 6 }, { 322, 85, 12, 7 } }, 92)
-- wish lanterns drifting up (quirk: every lantern carries a wish)
for _, s in ipairs({ { 126, 34, LR.ora }, { 150, 20, LR.yel }, { 318, 70, LR.pink }, { 342, 16, LR.red }, { 108, 80, LR.yel } }) do
  lantern(s[1], s[2], 4, 5, s[3], 3)
  P(s[1] + 1, s[2] + 5, "#fff0bc")
end

-- 2 FAR HILLS + HAZE ---------------------------------------------------
for x = 0, W - 1 do
  local h1 = floor(84 + 5 * sin(x / 41 + 0.5) + 3 * sin(x / 17))
  for y = h1, 111 do P(x, y, (y == h1) and "#d0a8b8" or "#a8849f") end
  local h2 = floor(96 + 4 * sin(x / 29 + 2) + 2 * sin(x / 11))
  for y = h2, 111 do P(x, y, (y == h2) and "#9a82a2" or "#7f6a92") end
end
local function palmSil(x, top, c)
  fill(lineM({ { x, 112 }, { x + 2, top + 10 }, { x + 4, top } }, 2), c)
  for _, f in ipairs({ { -9, 5 }, { -6, 8 }, { 8, 5 }, { 6, 9 }, { 0, -4 }, { -10, 1 }, { 10, 1 } }) do
    fill(lineM({ { x + 4, top }, { x + 4 + f[1] * 0.6, top + f[2] * 0.3 - 2 }, { x + 4 + f[1], top + f[2] } }, 1), c)
  end
end
for _, p in ipairs({ { 40, 92 }, { 118, 90 }, { 150, 94 }, { 330, 92 }, { 360, 88 }, { 420, 92 }, { 452, 95 } }) do palmSil(p[1], p[2], "#635f86") end
for x = 0, W - 1 do
  local h3 = floor(106 + 2 * sin(x / 9) + hash(x // 3, 1, 9) * 2)
  for y = h3, 111 do P(x, y, (y == h3) and "#b897ac" or "#9c88a8") end
end

-- 3 GROUND (banks) -----------------------------------------------------
for y = 112, H - 1 do for x = 0, W - 1 do
  local h = hash(x, y, 21)
  local c = GRASS[3]
  if h > 0.82 then c = GRASS[4] elseif h < 0.16 then c = GRASS[2] end
  if y < 118 then c = (h > 0.5) and "#6f8a68" or "#5d7d5a" end
  if hash(x // 2, y // 3, 22) > 0.93 and y > 118 then c = GRASS[5] end
  P(x, y, c)
end end

-- 4 CANAL ----------------------------------------------------------------
local function Lx(y) return 226 - 86.5 * (y - 112) / 88 end
local function Rx(y) return 254 + 86.5 * (y - 112) / 88 end
local canal = polyM({ { 226, 112 }, { 254, 112 }, { 340.5, 200 }, { 139.5, 200 } })
each(canal, function(x, y)
  local t = (y - 112) / 88 + 0.03 * sin(x / 7)
  local c
  if t < 0.22 then c = "#b48aa6" elseif t < 0.45 then c = "#7c7ca0" elseif t < 0.72 then c = "#4f7590" else c = "#3a6478" end
  local h = hash(floor(x / 5), y, 7)
  if y % 2 == 0 and h > 0.84 then c = (t < 0.45) and "#e6b4b4" or "#7fb0b4" elseif h < 0.05 then c = "#2e4c64" end
  P(x, y, c)
end)
-- boardwalks along the canal
local function walk(pts, side)
  local m = polyM(pts)
  each(m, function(x, y)
    local r = floor(math.log(y - 108) * 18)
    local rp = floor(math.log(y - 109) * 18)
    local c = WOOD[4]
    if hash(r, 2, 31) > 0.6 then c = WOOD[3] end
    if r ~= rp then c = WOOD[2] end
    if hash(x, y, 33) < 0.05 then c = WOOD[2] end
    P(x, y, c)
  end)
  edge(m, WOOD[1])
  -- posts dipping in the water
  for y = 118, 196, 9 do
    local x = (side == "l") and floor(Lx(y)) + 1 or floor(Rx(y)) - 1
    local hgt = 2 + floor((y - 112) / 30)
    for yy = y, y + hgt do P(x, yy, WOOD[1]); P(x + ((side == "l") and 1 or -1), yy, WOOD[2]) end
  end
end
walk({ { 222, 112 }, { 226, 112 }, { 139.5, 200 }, { 114, 200 } }, "l")
walk({ { 254, 112 }, { 258, 112 }, { 366, 200 }, { 340.5, 200 } }, "r")
-- lotus pads (flat ellipses) + flowers
for _, l in ipairs({ { 178, 184, 6, 2 }, { 300, 166, 5, 2 }, { 206, 138, 4, 1.5 }, { 322, 192, 6, 2 } }) do
  local m = ellM(l[1], l[2], l[3], l[4]); fill(m, "#4f9a5a"); edge(m, "#2c5a46")
  P(l[1] - 1, l[2] - 1, "#86c46a")
end
for _, f in ipairs({ { 180, 182 }, { 302, 164 } }) do
  P(f[1], f[2] - 1, "#f6a8c0"); P(f[1] - 1, f[2], "#e2709a"); P(f[1] + 1, f[2], "#e2709a"); P(f[1], f[2], "#ffd8e0")
end

-- 5 FOREGROUND DECK (wide landing) ---------------------------------------
for y = 200, H - 1 do for x = 0, W - 1 do
  local a = (x - VX) / (y - VY)
  local pi = floor(a * 9)
  local pa = floor(((x - 1) - VX) / (y - VY) * 9)
  local hb = hash(pi, 3, 11)
  local c = hb > 0.7 and WOOD[4] or hb > 0.3 and "#986848" or WOOD[3]
  local row = floor(math.log(y - VY) * 12)
  local rowp = floor(math.log(y - 1 - VY) * 12)
  if pi ~= pa then c = "#5a382c" end
  if row ~= rowp and hash(pi, row, 5) > 0.55 then c = "#5a382c" end
  if hash(x, y, 9) < 0.04 then c = "#7a4e36" elseif hash(x, y, 10) > 0.985 then c = WOOD[5] end
  P(x, y, c)
end end
for x = 0, W - 1 do P(x, 200, "#3e2626"); P(x, 201, "#5a382c") end
-- wet puddles reflecting the pink sky
for _, p in ipairs({ { 196, 264, 10, 2 }, { 352, 238, 8, 1.5 }, { 120, 226, 7, 1.5 } }) do
  local m = ellM(p[1], p[2], p[3], p[4]); fill(m, "#c8909e"); P(p[1] - 3, p[2], "#f0c0b4"); P(p[1] - 2, p[2], "#f0c0b4")
  each(edgeM(m), function(x, y) if y > p[2] then P(x, y, "#7a5a6a") end end)
end

-- 6 THE BANYAN GREEN (island + giant banyan) ------------------------------
local island = polyM({ { 200, 113 }, { 280, 113 }, { 294, 133 }, { 186, 133 } })
each(island, function(x, y)
  local h = hash(x, y, 41)
  local c = (y < 118) and GRASS[4] or GRASS[3]
  if h > 0.85 then c = GRASS[5] elseif h < 0.15 then c = GRASS[2] end
  if x > 262 and y > 120 then c = (h > 0.5) and GRASS[3] or GRASS[2] end
  P(x, y, c)
end)
local wall = polyM({ { 189, 129 }, { 291, 129 }, { 294, 133 }, { 186, 133 } })
each(wall, function(x, y)
  local row = (y - 129) // 2
  local c = (((x + row * 3) // 6) % 2 == 0) and "#9a8fa6" or "#867b98"
  if (x + row * 3) % 6 == 0 or (y - 129) % 2 == 1 and y == 130 then c = "#5c5274" end
  P(x, y, c)
end)
edge(island, "#2a4a36")
fill(rectM(186, 133, 294, 134), "#2e4c64")
-- trunk + buttress roots + branches
local trunk = polyM({ { 226, 130 }, { 254, 130 }, { 250, 112 }, { 247, 96 }, { 245, 82 }, { 235, 82 }, { 233, 96 }, { 230, 112 } })
madd2(trunk, polyM({ { 212, 131 }, { 228, 120 }, { 234, 131 } }))
madd2(trunk, polyM({ { 248, 120 }, { 268, 131 }, { 252, 131 } }))
each(trunk, function(x, y)
  local c = BARK[3]
  local s = (x + floor(2 * sin(y / 5))) % 5
  if s == 0 then c = BARK[2] elseif s == 2 then c = BARK[4] end
  if x < 236 and s ~= 0 then c = BARK[4] end
  if x > 249 then c = BARK[2] end
  if hash(x, y, 43) > 0.95 then c = BARK[5] end
  P(x, y, c)
end)
edge(trunk, BARK[1])
for _, br in ipairs({ { { 238, 88 }, { 222, 78 }, { 200, 70 } }, { { 242, 88 }, { 260, 76 }, { 282, 68 } }, { { 240, 86 }, { 240, 60 } } }) do
  local m = lineM(br, 5); blobTone(m, BARK, 44, 0.2)
end
-- tiny door in the trunk (quirk)
local door = rectM(236, 117, 243, 128); madd2(door, rectM(237, 116, 242, 116))
each(door, function(x, y) P(x, y, (x % 3 == 0) and "#9a5430" or "#c8743c") end)
edge(door, "#3a2224"); P(241, 123, "#f6c850")
fill(rectM(238, 106, 240, 108), "#ffd27a"); edge(rectM(237, 105, 241, 109), BARK[1])
-- aerial roots
for i, rx in ipairs({ 191, 197, 203, 209, 215, 220, 260, 266, 272, 278, 284, 289 }) do
  local top = 84 + floor(hash(i, 1, 45) * 6)
  local bot = (rx < 240) and (124 + floor(hash(i, 2, 45) * 5)) or (124 + floor(hash(i, 3, 45) * 5))
  for y = top, bot do
    local x = rx + floor(1.2 * sin(y / 6 + i))
    P(x, y, "#9a7458"); P(x + 1, y, "#6e4a3a")
  end
  P(rx - 1 + floor(1.2 * sin(bot / 6 + i)), bot + 1, "#5a3a30"); P(rx + 2 + floor(1.2 * sin(bot / 6 + i)), bot + 1, "#5a3a30")
end
-- canopy clumps
local blobs = { { 240, 62, 62, 22 }, { 204, 72, 24, 12 }, { 276, 72, 24, 12 }, { 214, 52, 26, 14 }, { 266, 52, 26, 14 },
  { 240, 46, 28, 12 }, { 190, 62, 12, 10 }, { 290, 62, 12, 10 }, { 226, 78, 16, 8 }, { 256, 78, 16, 8 }, { 240, 70, 18, 9 } }
for i, b in ipairs(blobs) do
  local m = ellM(b[1], b[2], b[3], b[4])
  each(m, function(x, y)
    local nx, ny = (x - b[1]) / b[3], (y - b[2]) / b[4]
    local l = -0.5 * nx - 0.8 * ny + (hash(x // 2, y // 2, 50 + i) - 0.5) * 0.6
    P(x, y, l > 0.8 and GREEN[5] or l > 0.25 and GREEN[4] or l > -0.3 and GREEN[3] or GREEN[2])
  end)
  each(edgeM(m), function(x, y) if (y - b[2]) > -b[4] * 0.3 or (x - b[1]) > 0 then P(x, y, GREEN[1]) else P(x, y, GREEN[2]) end end)
end
for i = 1, 60 do local x, y = 190 + floor(hash(i, 1, 60) * 100), 38 + floor(hash(i, 2, 60) * 40)
  if B[y * W + x] == GREEN[4] then P(x, y, "#b8d870") end end
-- lanterns hanging in the banyan
for i, l in ipairs({ { 200, 86 }, { 222, 90 }, { 258, 90 }, { 280, 86 } }) do
  for y = l[2] - 6, l[2] - 1 do P(l[1] + 2, y, "#3a2224") end
  lantern(l[1], l[2], 5, 7, LCYC[i], 4)
end
-- marigold garlands draped on the roots
local function garland(x0, y0, x1, y1, sag)
  local n = floor(abs(x1 - x0))
  for i = 0, n do
    local t = i / n
    local x = x0 + (x1 - x0) * t
    local y = y0 + (y1 - y0) * t + sag * sin(math.pi * t)
    P(x, y, (i % 3 == 0) and "#ffc24a" or "#f08a2a"); P(x, y + 1, (i % 7 == 3) and "#4a8a3a" or "#c8601e")
  end
end
garland(191, 100, 220, 102, 5); garland(260, 102, 289, 100, 5)
-- offering flowers at the roots
for _, f in ipairs({ { 216, 126 }, { 222, 125 }, { 262, 126 } }) do
  P(f[1], f[2] - 1, "#ffd8e0"); P(f[1] - 1, f[2], "#f07a9a"); P(f[1] + 1, f[2], "#f07a9a"); P(f[1], f[2], "#ffc24a")
end

-- 7 LIBRARY (far left, stilts, thatch, open-book sign) --------------------
local LIB = { "#2b2a4e", "#3e4474", "#545e96", "#6f7cb2", "#93a2cc" }
shadeM(polyM({ { 22, 118 }, { 100, 118 }, { 108, 122 }, { 30, 122 } }), 0.4)
for _, sx in ipairs({ 26, 42, 72, 86 }) do post(sx, 105, sx + 2, 118, TEAK) end
fill(lineM({ { 28, 117 }, { 42, 107 } }, 1), TEAK[2]); fill(lineM({ { 74, 107 }, { 88, 117 } }, 1), TEAK[2])
local lside = polyM({ { 90, 68 }, { 100, 65 }, { 100, 104 }, { 90, 105 } })
planks(lside, LIB, 4, 71, -1)
local lfront = rectM(24, 66, 90, 104); planks(lfront, LIB, 5, 72, 0)
post(20, 103, 102, 106, TEAK)
-- windows with book spines
for _, wx in ipairs({ 30, 70 }) do
  local wm = rectM(wx, 76, wx + 14, 95)
  each(wm, function(x, y)
    local c = (y < 82) and "#e8944a" or "#f6c46a"
    if y >= 86 and y <= 93 and (x - wx) % 3 ~= 0 then
      local k = ((x - wx) // 3) % 5
      c = ({ "#c84a4a", "#4a7ac8", "#e8b04a", "#5aa060", "#a05ac0" })[k + 1]
      if y == 86 and (x + wx) % 2 == 0 then c = "#f6c46a" end
    end
    if y == 94 then c = TEAK[3] end
    P(x, y, c)
  end)
  edge(wm, LIB[1])
  fill(rectM(wx - 1, 96, wx + 15, 97), TEAK[3]); edge(rectM(wx - 1, 96, wx + 15, 97), TEAK[1])
  glow(wx + 7, 85, 6, 0.12)
end
local ldoor = rectM(51, 82, 62, 103); madd2(ldoor, rectM(52, 81, 61, 81))
each(ldoor, function(x, y) P(x, y, (y < 86) and "#f6c46a" or (((x - 51) % 4 == 0) and "#24545a" or "#2f6a6a")) end)
edge(ldoor, LIB[1]); P(59, 94, "#e8b04a")
-- ladder steps
for y = 107, 118 do P(52, y, TEAK[2]); P(61, y, TEAK[2]) end
for y = 108, 117, 3 do for x = 53, 60 do P(x, y, TEAK[4]) end end
-- thatch hip roof
local lroof = polyM({ { 14, 70 }, { 30, 43 }, { 86, 43 }, { 104, 70 } })
for x = 14, 104 do if hash(x, 1, 73) > 0.5 then madd(lroof, x, 70) end; if hash(x, 2, 73) > 0.75 then madd(lroof, x, 71) end end
roofTex(lroof, THATCH, "thatch", 0, 74)
fill(rectM(32, 42, 84, 44), THATCH[2]); edge(rectM(30, 42, 86, 44), THATCH[1])
lantern(18, 73, 5, 7, LR.ora, 4)
-- big open-book sign on the ridge
post(58, 34, 60, 42, TEAK)
local bcl = polyM({ { 36, 30 }, { 59, 35 }, { 59, 41 }, { 36, 36 } }); local bcr = polyM({ { 82, 30 }, { 59, 35 }, { 59, 41 }, { 82, 36 } })
fill(bcl, "#a83a3a"); fill(bcr, "#8a2e34"); edge(bcl, "#4a1a26"); edge(bcr, "#4a1a26")
local bpl = polyM({ { 38, 28 }, { 58, 32 }, { 58, 38 }, { 38, 34 } }); local bpr = polyM({ { 80, 28 }, { 60, 32 }, { 60, 38 }, { 80, 34 } })
fill(bpl, "#f2e6c8"); fill(bpr, "#ddd0b0")
for i = 0, 4 do
  for x = 41, 55 do if (x + i) % 5 ~= 0 then P(x, 31 + i + floor((x - 38) / 5.2) - 1 + 0, ((i % 2 == 0) and "#b8a888" or "#f2e6c8")) end end
end
fill(polyM({ { 38, 28 }, { 58, 32 }, { 58, 38 }, { 38, 34 } }), "#f2e6c8")
for i = 0, 2 do for x = 41, 55 do if (x % 4) ~= 0 then P(x, 30 + i * 2 + floor((x - 38) / 5), "#b8a888") end end end
for i = 0, 2 do for x = 63, 77 do if (x % 4) ~= 0 then P(x, 30 + i * 2 + floor((80 - x) / 5), "#a89878") end end end
edge(bpl, "#8a7a5a"); edge(bpr, "#8a7a5a")
fill(rectM(59, 32, 59, 40), "#6a5a44")
-- quirk: a sprout growing from the book's spine
P(59, 31, "#3f7a45"); P(59, 30, "#3f7a45"); P(59, 29, "#3f7a45")
P(57, 28, "#62964f"); P(58, 28, "#86b45a"); P(60, 27, "#86b45a"); P(61, 27, "#62964f"); P(58, 29, "#2f5a40"); P(61, 28, "#2f5a40")

-- banana clump (decor, left bank)
for _, lf in ipairs({ { 116, 118, 106, 96, 4, -3 }, { 118, 118, 128, 98, 4, 3 }, { 117, 118, 116, 92, 3, 2 } }) do
  leaf(lf[1], lf[2], lf[3], lf[4], lf[5], lf[6], GREEN, 80)
end

-- 8 NOTICE BOARD (towering, thatch cap, pinned papers) ---------------------
shadeM(polyM({ { 130, 152 }, { 168, 152 }, { 178, 158 }, { 140, 158 } }), 0.4)
post(132, 76, 135, 152, TEAK); post(163, 76, 166, 152, TEAK)
post(134, 134, 164, 136, TEAK)
fill(rectM(131, 149, 136, 152), "#867b98"); fill(rectM(162, 149, 167, 152), "#867b98")
local cork = rectM(137, 83, 162, 130)
each(cork, function(x, y) local h = hash(x, y, 90); P(x, y, h > 0.8 and "#c8955e" or h < 0.2 and "#94643a" or "#b5834e") end)
edge(rectM(136, 82, 163, 131), TEAK[1])
local papers = { { 139, 86, 147, 96, "#f2e6c8" }, { 149, 85, 160, 95, "#f6b0b8" }, { 139, 99, 149, 110, "#a8c8f0" }, { 151, 98, 160, 108, "#f6d870" },
  { 140, 113, 147, 126, "#b8e0a0" }, { 150, 111, 160, 121, "#f2e6c8" }, { 151, 123, 159, 128, "#e0b0f0" } }
for i, p in ipairs(papers) do
  local m = rectM(p[1], p[2], p[3], p[4])
  fill(m, p[5])
  for y = p[2] + 3, p[4] - 2, 2 do for x = p[1] + 2, p[3] - 2 do if hash(x // 3, y, i) > 0.3 then P(x, y, mix(p[5], "#3b2c5e", 0.35)) end end end
  each(edgeM(m), function(x, y) if x == p[3] or y == p[4] then P(x, y, mix(p[5], "#3b2c5e", 0.5)) end end)
  local px = (p[1] + p[3]) // 2
  P(px, p[2] + 1, (i % 2 == 0) and "#3a6ad0" or "#d83a3a")
end
-- thatch cap
local bcap = polyM({ { 128, 82 }, { 138, 68 }, { 160, 68 }, { 170, 82 } })
for x = 128, 170 do if hash(x, 5, 91) > 0.5 then madd(bcap, x, 82) end end
roofTex(bcap, THATCH, "thatch", 0, 92)
garland(137, 84, 162, 84, 3)
-- quirk: a vine climbing the post, already taller than the board
local vine = {}
for y = 150, 60, -1 do vine[#vine + 1] = { 131 + 2 * sin(y / 4), y } end
fill(lineM(vine, 1), "#3f7a45")
for y = 146, 66, -9 do local x = 131 + 2 * sin(y / 4); local s = (y // 9) % 2 == 0 and -1 or 1
  P(x + s, y, "#62964f"); P(x + 2 * s, y, "#86b45a"); P(x + 2 * s, y - 1, "#62964f"); P(x + 3 * s, y - 1, "#3f7a45") end
fill(rectM(129, 60, 132, 62), "#f07a9a"); P(130, 61, "#ffc24a"); P(131, 59, "#f6a8c0")

-- 9 RIGHT BANK DECOR: palms + bushes --------------------------------------
local function palm(bx, by, tx, ty, fronds)
  local tr = lineM({ { bx, by }, { (bx + tx) / 2 - 3, (by + ty) / 2 }, { tx, ty } }, 4)
  each(tr, function(x, y) P(x, y, (y % 4 == 0) and BARK[2] or ((x % 2 == 0) and BARK[4] or BARK[3])) end)
  edge(tr, BARK[1])
  for _, f in ipairs(fronds) do
    local ex, ey = tx + f[1], ty + f[2]
    local mx, my = tx + f[1] * 0.5, ty + f[2] * 0.5 - 6
    local pts = { { tx, ty }, { mx, my }, { ex, ey } }
    for i = 0, 12 do
      local t = i / 12
      local x = (1 - t) * (1 - t) * tx + 2 * (1 - t) * t * mx + t * t * ex
      local y = (1 - t) * (1 - t) * ty + 2 * (1 - t) * t * my + t * t * ey
      local l = 5 * sin(math.pi * (0.2 + 0.8 * t))
      fill(lineM({ { x, y }, { x - 1, y + l } }, 1), (f[1] < 0) and GREEN[4] or GREEN[3])
      fill(lineM({ { x, y }, { x + 1, y + l } }, 1), (f[1] < 0) and GREEN[3] or GREEN[2])
    end
    fill(lineM(pts, 1), GREEN[1])
  end
  fill(rectM(tx - 2, ty, tx + 1, ty + 3), "#7a5440")
end
palm(334, 124, 342, 64, { { -28, 10 }, { -20, -6 }, { 0, -12 }, { 20, -6 }, { 24, 12 }, { -10, 18 }, { 12, 18 } })
palm(358, 126, 360, 96, { { -14, 8 }, { -8, -6 }, { 8, -6 }, { 8, 10 } })
for _, b in ipairs({ { 290, 116, 10, 5 }, { 312, 120, 12, 6 }, { 276, 120, 6, 4 } }) do
  local m = ellM(b[1], b[2], b[3], b[4]); blobTone(m, GREEN, 95, 0.5)
  for i = 1, 4 do P(b[1] - b[3] + 2 + i * b[3] // 3, b[2] - 1 + (i % 2), "#f05a6a") end
end

-- 10 WILD TRAIL (bamboo arch, path leaving right, signpost) ----------------
local jungle = polyM({ { 380, 118 }, { 380, 62 }, { 392, 52 }, { 410, 48 }, { 432, 46 }, { 452, 50 }, { 463, 56 }, { 463, 118 } })
each(jungle, function(x, y)
  local h = hash(x // 2, y // 2, 101)
  P(x, y, h > 0.75 and "#2f5a40" or h < 0.2 and "#1a3330" or "#24493a")
end)
for i = 1, 9 do local b = ellM(382 + i * 9, 54 + (i % 3) * 3, 8, 6); blobTone(b, GREEN, 102 + i, 0.6) end
-- glowing opening through the arch + path
local open = polyM({ { 406, 118 }, { 406, 66 }, { 444, 66 }, { 444, 118 } })
each(open, function(x, y)
  local d = (y - 66) / 52
  local c = (d < 0.35) and "#f2c88a" or (d < 0.6) and "#a8c47a" or "#6f9a5e"
  if hash(x // 2, y // 2, 103) > 0.86 then c = "#4f7d4a" end
  P(x, y, c)
end)
for _, lf in ipairs({ { 408, 100, 414, 86, 3, -2 }, { 442, 96, 434, 82, 3, 2 }, { 420, 70, 432, 64, 2, 1 } }) do leaf(lf[1], lf[2], lf[3], lf[4], lf[5], lf[6], GREEN, 104) end
local path = polyM({ { 400, 118 }, { 450, 118 }, { 464, 104 }, { 464, 100 }, { 436, 104 }, { 420, 98 }, { 430, 92 }, { 420, 92 }, { 412, 100 } })
each(path, function(x, y) local h = hash(x, y, 105); P(x, y, h > 0.8 and "#e0b070" or h < 0.2 and "#a8784a" or "#c8955a") end)
edge(path, "#7a5034")
-- bamboo posts and beams
local BAM = { "#3a5a2a", "#5a7f34", "#86a43e", "#a8c24e", "#cfe07a" }
local function bamboo(x0, y0, x1, y1, horiz)
  local m = rectM(x0, y0, x1, y1)
  each(m, function(x, y)
    local a = horiz and (y - y0) or (x - x0)
    local span = horiz and (y1 - y0) or (x1 - x0)
    local c = (a == 0) and BAM[4] or (a == span) and BAM[2] or BAM[3]
    if a == 1 and span > 2 then c = BAM[5] end
    local n = horiz and x or y
    if n % 9 == 0 then c = BAM[2] end
    P(x, y, c)
  end)
  edge(m, BAM[1])
end
bamboo(400, 56, 405, 118); bamboo(445, 56, 450, 118)
bamboo(394, 52, 456, 56, true); bamboo(398, 60, 452, 62, true)
-- vine + flowers on top beam
for x = 394, 456, 4 do
  local y = 50 + floor(2 * sin(x / 5))
  P(x, y, GREEN[4]); P(x + 1, y, GREEN[3]); P(x + 1, y + 1, GREEN[2]); P(x + 2, y - 1, GREEN[4])
  if x % 12 == 2 then for _, d in ipairs({ { 0, -1 }, { -1, 0 }, { 1, 0 }, { 0, 1 } }) do P(x + 2 + d[1], y + 4 + d[2], "#f0702a") end; P(x + 2, y + 4, "#ffd24a") end
end
for x = 404, 446, 10 do for y = 63, 63 + 3 + (x % 3) do P(x, y, GREEN[3]) end; P(x, 67 + (x % 3), GREEN[4]) end
for y = 63, 67 do P(425, y, "#3a2224") end
lantern(423, 68, 5, 7, LR.yel, 5)
-- signpost with right-pointing arrows (icons only)
post(381, 64, 383, 118, TEAK)
local a1 = polyM({ { 372, 68 }, { 394, 68 }, { 399, 72.5 }, { 394, 77 }, { 372, 77 } })
local a2 = polyM({ { 374, 82 }, { 392, 82 }, { 397, 86.5 }, { 392, 91 }, { 374, 91 } })
blobTone(a1, WOOD, 106, 0.2); blobTone(a2, { "#3e2626", "#7a3a2e", "#a84e36", "#c86a46", "#e08a5a" }, 107, 0.2)
-- leaf icon on arrow 1, little peak icon on arrow 2
P(380, 72, "#3f7a45"); P(381, 71, "#62964f"); P(382, 71, "#86b45a"); P(383, 72, "#62964f"); P(381, 73, "#3f7a45"); P(382, 73, "#2f5a40"); P(384, 73, "#2f5a40")
P(382, 85, "#f2e6c8"); P(381, 86, "#f2e6c8"); P(383, 86, "#f2e6c8"); P(380, 87, "#f2e6c8"); P(384, 87, "#f2e6c8"); P(382, 86, "#cfe8f0")
shadeM(polyM({ { 398, 118 }, { 452, 118 }, { 460, 122 }, { 406, 122 } }), 0.3)

-- 11 LANTERN BRIDGE ---------------------------------------------------------
local RED = { "#4a1a26", "#7a2a30", "#a83c3a", "#cc5a44", "#e88a5a" }
local function yTop(x) return 150 + 7 * ((x - 240) / 56) ^ 2 end
local function yA(x) return 160 + 11 * ((x - 240) / 44) ^ 2 end
local bridge = M()
for x = 184, 296 do
  local yt = floor(yTop(x))
  local pier = (x <= 196) or (x >= 284)
  local yb = pier and 172 or math.min(172, floor(yA(x)))
  for y = yt, yb do madd(bridge, x, y) end
end
-- water shadow + lantern reflections under the arch
shadeM(polyM({ { 196, 168 }, { 284, 168 }, { 290, 176 }, { 192, 176 } }), 0.3)
each(bridge, function(x, y)
  local yt = floor(yTop(x))
  local c
  if y <= yt + 3 then
    c = (x % 6 == 0) and WOOD[2] or ((y == yt) and WOOD[5] or WOOD[4])
  else
    local d = y - yt
    c = (d < 7) and RED[4] or RED[3]
    if x > 270 or (x > 196 and x < 284 and y > floor(yA(x)) - 2) then c = RED[2] end
    if (x <= 196 or x >= 284) and y > yt + 8 and (y % 5 == 0) then c = RED[2] end
    if d == 4 then c = "#e8b04a" end
  end
  P(x, y, c)
end)
edge(bridge, RED[1])
for x = 197, 283, 3 do local y = floor(yA(x)) + 1; if y < 172 then P(x, y, "#e0b060") end end
-- railings
for x = 184, 296 do local yt = floor(yTop(x)); P(x, yt - 8, RED[4]); P(x, yt - 7, RED[2]); P(x, yt - 4, RED[3]) end
for x = 190, 290, 10 do local yt = floor(yTop(x)); for y = yt - 8, yt - 1 do P(x, y, RED[3]); P(x + 1, y, RED[2]) end; P(x, yt - 9, "#e8b04a"); P(x + 1, yt - 9, "#e8b04a") end
for _, px in ipairs({ 184, 294 }) do post(px, 136, px + 2, floor(yTop(px)) + 2, RED); fill(rectM(px - 1, 134, px + 3, 135), "#e8b04a"); edge(rectM(px - 1, 134, px + 3, 135), RED[1]) end
-- lantern string with lanterns (each carries a wish)
for x = 186, 294 do local y = 138 + 7 * (1 - ((x - 240) / 54) ^ 2); P(x, y, "#3a2224") end
for i, x in ipairs({ 198, 210, 222, 234, 246, 258, 270, 282 }) do
  local y = floor(138 + 7 * (1 - ((x - 240) / 54) ^ 2))
  P(x + 1, y + 1, "#3a2224")
  lantern(x, y + 2, 4, 5, LCYC[(i % 4) + 1], 3)
  for k = 0, 3 do P(x + 1 + ((k % 2 == 0) and 0 or 1), 174 + k * 2, (k < 2) and "#ffd27a" or "#e8944a") end
end
-- quirk: a flowering vine bursting out of the right pier
for y = 152, 171 do P(296 + floor(1.5 * sin(y / 3)), y, GREEN[3]) end
for _, f in ipairs({ { 297, 154 }, { 295, 161 }, { 298, 167 } }) do P(f[1], f[2], "#ffd24a"); P(f[1] - 1, f[2], "#f05a8a"); P(f[1] + 1, f[2], "#f05a8a"); P(f[1], f[2] - 1, "#f05a8a"); P(f[1], f[2] + 1, "#c83a6a") end

-- 12 FLOATING MARKET (boats) -----------------------------------------------
local function boat(x0, x1, yt, trim, seed)
  shadeM(polyM({ { x0 + 6, yt + 6 }, { x1 - 2, yt + 6 }, { x1 - 6, yt + 9 }, { x0 + 10, yt + 9 } }), 0.35)
  local hull = polyM({ { x0, yt - 3 }, { x0 + 6, yt }, { x1 - 6, yt }, { x1, yt - 3 }, { x1 - 9, yt + 7 }, { x0 + 9, yt + 7 } })
  each(hull, function(x, y)
    local c
    if y <= yt + 1 then c = (y == yt + 1) and trim[2] or trim[3]
      if x < x0 + 12 and y < yt then c = trim[4] end
    else
      local l = (y - yt) / 7
      c = l < 0.45 and "#8a5a3a" or l < 0.8 and "#6e4430" or "#523226"
      if x < (x0 + x1) / 2 - 10 and l < 0.45 then c = "#a06a44" end
      if (y - yt) % 3 == 0 and hash(x // 6, y, seed) > 0.5 then c = "#5a382a" end
    end
    P(x, y, c)
  end)
  edge(hull, "#3a2224")
  fill(polyM({ { x0 + 5, yt - 2 }, { x1 - 5, yt - 2 }, { x1 - 7, yt }, { x0 + 7, yt } }), "#4a2c26")
end
local function fruit(x, y, F)
  P(x + 1, y, F[2]); P(x + 2, y, F[3]); P(x, y + 1, F[2]); P(x + 1, y + 1, F[3]); P(x + 2, y + 1, F[2]); P(x + 3, y + 1, F[1])
  P(x + 1, y + 2, F[1]); P(x + 2, y + 2, F[1])
end
local function pile(x0, x1, yb, F, rows, extra)
  for r = 0, rows - 1 do
    for x = x0 + r * 2, x1 - r * 2 - 3, 3 do
      fruit(x, yb - 3 - r * 2, F)
      if extra and hash(x, r, 7) > 0.6 then P(x + 1, yb - 4 - r * 2, extra) end
    end
  end
end
local MANGO = { "#c8642a", "#f2a63a", "#ffd36a" }
local DRAGON = { "#a02a5a", "#e0407a", "#ff8ab0" }
local RAMB = { "#8a1e2a", "#d8343a", "#f07a5a" }
local LIME = { "#3a7a34", "#7ac04a", "#b8e070" }
-- boat B (back)
boat(216, 266, 184, { "#1e3e4e", "#2a6a6a", "#3a9a8a", "#6ac0a8" }, 121)
for _, bx in ipairs({ 222, 238 }) do
  local bk = rectM(bx, 178, bx + 11, 182)
  each(bk, function(x, y) P(x, y, (y % 2 == 0) and "#b08048" or "#8a5a34") end); edge(bk, "#4a2c26")
  for x = bx + 1, bx + 10, 3 do
    local col = (bx == 222) and "#f6a8c0" or "#f2e6c8"
    P(x, 176, col); P(x - 1, 177, col); P(x + 1, 177, col); P(x, 178, col); P(x, 177, (bx == 222) and "#e2709a" or "#ffd24a")
  end
end
fill(rectM(254, 176, 255, 183), TEAK[2])
garland(250, 177, 262, 178, 3)
-- boat A (left, striped canopy, mangoes + dragonfruit)
boat(150, 214, 190, { "#4a1a26", "#a83236", "#e0503e", "#f8906a" }, 122)
post(158, 177, 159, 189, TEAK); post(205, 177, 206, 189, TEAK)
local canopy = polyM({ { 154, 175 }, { 210, 175 }, { 207, 180 }, { 157, 180 } })
each(canopy, function(x, y) P(x, y, ((x // 5) % 2 == 0) and "#f2e2c0" or "#ec8a3a") end)
each(edgeM(canopy), function(x, y) if y >= 179 then P(x, y, ((x // 5) % 2 == 0) and "#c8a888" or "#a8502a") end end)
edge(canopy, "#6a2e1e")
for x = 157, 207, 5 do P(x, 181, "#ec8a3a") end
pile(162, 184, 189, MANGO, 3)
pile(185, 204, 189, DRAGON, 3, "#7ac04a")
-- boat C (right, rambutan + limes, quirk: it has taken root)
boat(268, 332, 191, { "#1e3e4e", "#2a5e8a", "#3a7ac8", "#7aaee0" }, 123)
for _, rx in ipairs({ 290, 300, 312, 320 }) do for y = 198, 199 do P(rx + (y % 2), y, "#7a5440") end end
pile(276, 296, 190, RAMB, 3, "#f6c0a0")
pile(298, 312, 190, LIME, 2)
-- little tree growing on the boat
fill(lineM({ { 321, 189 }, { 322, 182 } }, 2), BARK[3])
local tc = ellM(322, 179, 7, 4); blobTone(tc, GREEN, 124, 0.5)
P(320, 177, "#f6c850"); P(325, 179, "#f6c850")

-- 13 TEAHOUSE: The Kopi Corner (near left) + SHOPS (near right) ------------
local function house(o)
  local x0, x1, wy0, wy1, base, ay, e = o.x0, o.x1, o.wy0, o.wy1, o.base, o.ay, o.e
  local cx = (x0 + x1) / 2
  local r = (o.side == "r")
  shadeM(polyM({ { x0 - 2, base }, { x1 + 4, base }, { x1 + 14, base + 7 }, { x0 + 8, base + 7 } }), 0.42)
  for sx = x0 + 2, x1 - 3, 13 do post(sx, wy1, sx + 2, base, TEAK) end
  for sx = x0 + 2, x1 - 16, 26 do fill(lineM({ { sx + 2, wy1 + 2 }, { sx + 13, base - 2 } }, 1), TEAK[2]) end
  local t = o.t
  local function V(p) return { p[1] + (VX - p[1]) * t, p[2] + (VY - p[2]) * t } end
  local sx = r and x1 or x0
  local sw = polyM({ { sx, wy0 }, V({ sx, wy0 }), V({ sx, wy1 }), { sx, wy1 } })
  planks(sw, o.wallR, 4, o.seed + 1, r and -1 or 1)
  local tr = o.tr
  local function VR(p) return { p[1] + (VX - p[1]) * tr, p[2] + (VY - p[2]) * tr } end
  local ex = r and (x1 + e) or (x0 - e)
  local rs = polyM({ { cx, ay }, { ex, wy0 + 3 }, VR({ ex, wy0 + 3 }), VR({ cx, ay }) })
  roofTex(rs, o.roofR, o.roof, r and 0 or 1, o.seed + 2)
  local yl = wy0 + 3 - e * (wy0 + 2 - ay) / (cx - (x0 - e))
  local fw = polyM({ { x0, wy1 }, { x0, yl }, { cx, ay + 1 }, { x1, yl }, { x1, wy1 } })
  planks(fw, o.wallR, 5, o.seed, 0)
  local bb = lineM({ { x0 - e, wy0 + 3 }, { cx, ay + 1 }, { x1 + e, wy0 + 3 } }, 4)
  roofTex(bb, o.roofR, o.roof, 1, o.seed + 3)
  -- upturned gable finials
  fill(lineM({ { cx - 1, ay + 1 }, { cx - 4, ay - 3 } }, 2), o.roofR[2]); fill(lineM({ { cx + 1, ay + 1 }, { cx + 4, ay - 3 } }, 2), o.roofR[2])
  post(x0 - 3, wy1 - 1, x1 + 3, wy1 + 2, TEAK)
  return cx
end
local TEA = { "#1f4a4a", "#2c6a63", "#3a8a7a", "#5aa892", "#86c4a6" }
local TIN_R = { "#5a2030", "#8a2e36", "#b8443e", "#d8664c", "#f09468" }
house({ x0 = 24, x1 = 104, wy0 = 152, wy1 = 184, base = 198, ay = 128, e = 6, side = "r", t = 0.09, tr = 0.09,
  wallR = TEA, roofR = TIN_R, roof = "tin", seed = 130 })
-- counter window with warm interior
local tw = rectM(32, 162, 96, 177)
each(tw, function(x, y)
  local c = (y < 166) and "#c97a40" or "#f1b660"
  if y == 169 and x % 2 == 0 then c = "#a86a3a" end
  if y >= 166 and y <= 168 and (x % 7 == 3) then c = ({ "#e8f0d0", "#8ac0c8", "#d8a060" })[(x // 7) % 3 + 1] end
  P(x, y, c)
end)
edge(tw, TEA[1])
post(30, 177, 98, 179, WOOD)
-- iced coffee glasses + kettle on the counter
for _, gx in ipairs({ 42, 56, 82 }) do
  local g = rectM(gx, 170, gx + 3, 176); fill(g, "#8a4a2a"); fill(rectM(gx, 170, gx + 3, 171), "#f0dcb4"); P(gx + 1, 173, "#cfe8f0")
  edge(g, "#4a2a26"); P(gx + 3, 168, "#e85a5a"); P(gx + 3, 169, "#e85a5a")
end
local ket = rectM(66, 171, 73, 176); fill(ket, "#b8c0c8"); P(67, 172, "#e8eef0"); edge(ket, "#4a4a5a"); fill(lineM({ { 74, 173 }, { 77, 170 } }, 1), "#8a909a")
P(69, 169, "#e8eef0"); P(70, 168, "#e8eef0")
glow(64, 170, 10, 0.12)
-- striped awning
local aw = polyM({ { 28, 155 }, { 100, 155 }, { 102, 161 }, { 26, 161 } })
each(aw, function(x, y) P(x, y, ((x // 4) % 2 == 0) and "#f2e2c0" or "#c84a42") end)
each(edgeM(aw), function(x, y) if y >= 160 then P(x, y, ((x // 4) % 2 == 0) and "#c8b090" or "#8a2e36") end end)
edge(aw, "#5a2030")
for x = 26, 102, 4 do P(x + 1, 162, ((x // 4) % 2 == 0) and "#f2e2c0" or "#c84a42") end
-- gable sign: iced coffee glass
local tsb = rectM(54, 138, 74, 152); fill(tsb, "#3a2a2a"); edge(tsb, "#e8b04a")
local gl = polyM({ { 59, 141 }, { 70, 141 }, { 69, 151 }, { 60, 151 } })
fill(gl, "#dfeef0")
fill(polyM({ { 60.5, 144 }, { 68.5, 144 }, { 68, 150 }, { 61, 150 } }), "#a0603a")
fill(rectM(61, 144, 68, 145), "#f0dcb4"); fill(rectM(61, 149, 68, 150), "#6e3a24")
P(62, 147, "#cfe8f0"); P(63, 147, "#cfe8f0"); P(65, 148, "#cfe8f0"); P(66, 146, "#cfe8f0")
fill(lineM({ { 67, 145 }, { 71, 139 } }, 1), "#e85a5a")
lantern(19, 157, 4, 6, LR.red, 4); lantern(106, 155, 4, 6, LR.red, 4)
-- quirk: a vine racing up the teahouse with a giant hibiscus on the roof
for y = 196, 150, -1 do P(21 + floor(1.5 * sin(y / 3)), y, GREEN[3]) end
for y = 182, 152, -6 do P(23, y, GREEN[4]); P(24, y, GREEN[4]); P(19, y - 3, GREEN[4]) end
fill(lineM({ { 21, 150 }, { 26, 146 }, { 32, 144 } }, 1), GREEN[3])
for _, d in ipairs({ { 0, -3 }, { -3, 0 }, { 3, 0 }, { -2, 2 }, { 2, 2 } }) do local m = ellM(34 + d[1], 141 + d[2], 2.2, 2.2); fill(m, "#f05a6a") end
P(33, 140, "#ff9aa0"); P(34, 141, "#ffd24a"); P(35, 142, "#c83a4a"); P(32, 139, "#ff9aa0")
fill(rectM(18, 194, 25, 198), "#c86a3a"); edge(rectM(18, 194, 25, 198), "#5a2e1e")

-- SHOPS (seed shop)
local SHOP = { "#5a2e1e", "#8a4a2a", "#b8683a", "#d88e4c", "#f0b46a" }
local TIN_T = { "#1e3e4e", "#2a5e6a", "#3a8a8a", "#5ab0a0", "#8ad0b4" }
house({ x0 = 360, x1 = 450, wy0 = 152, wy1 = 184, base = 198, ay = 128, e = 6, side = "l", t = 0.1, tr = 0.09,
  wallR = SHOP, roofR = TIN_T, roof = "tin", seed = 140 })
local sf = rectM(368, 162, 442, 177)
each(sf, function(x, y)
  local c = (y < 165) and "#c97a40" or "#f1b660"
  if y == 169 or y == 174 then c = WOOD[3] end
  if (y >= 166 and y <= 168) or (y >= 171 and y <= 173) then
    if x % 4 ~= 0 then c = ({ "#e04a4a", "#4a8ad8", "#f6c850", "#5aa060", "#d86ad0", "#f08a3a" })[((x // 4) + y) % 6 + 1] end
    if (y == 166 or y == 171) and x % 4 == 2 then c = "#f2e6c8" end
  end
  P(x, y, c)
end)
edge(sf, SHOP[1])
post(364, 177, 446, 179, WOOD)
-- sprouts in pots on the counter
for _, px in ipairs({ 376, 392, 424, 436 }) do
  local pm = rectM(px, 172, px + 4, 176); fill(pm, "#c86a3a"); edge(pm, "#5a2e1e")
  P(px + 2, 171, GREEN[3]); P(px + 2, 170, GREEN[3]); P(px + 1, 169, GREEN[4]); P(px, 169, GREEN[5]); P(px + 3, 169, GREEN[4]); P(px + 4, 168, GREEN[3])
end
glow(405, 170, 10, 0.12)
local saw = polyM({ { 364, 155 }, { 446, 155 }, { 448, 161 }, { 362, 161 } })
each(saw, function(x, y) P(x, y, ((x // 4) % 2 == 0) and "#f2e2c0" or "#3a9a6a") end)
each(edgeM(saw), function(x, y) if y >= 160 then P(x, y, ((x // 4) % 2 == 0) and "#c8b090" or "#24684a") end end)
edge(saw, "#1e3e2e")
for x = 362, 448, 4 do P(x + 1, 162, ((x // 4) % 2 == 0) and "#f2e2c0" or "#3a9a6a") end
-- gable sign: seedling
local ssb = rectM(395, 137, 415, 151); fill(ssb, "#efe0b8"); edge(ssb, TEAK[1])
fill(rectM(400, 147, 410, 149), "#8a5a34"); fill(rectM(401, 146, 409, 146), "#a87048")
fill(rectM(405, 140, 405, 146), "#3f7a45")
fill(polyM({ { 397, 139 }, { 401, 137 }, { 405, 140 }, { 401, 142 } }), "#62964f"); P(399, 139, "#86b45a")
fill(polyM({ { 405, 140 }, { 409, 136.5 }, { 413, 138 }, { 409, 141 } }), "#4f8a45"); P(410, 138, "#86b45a")
lantern(354, 155, 4, 6, LR.ora, 4); lantern(452, 155, 4, 6, LR.ora, 4)
-- quirk: a seed sack bursting into a sprout as you watch
local sack = polyM({ { 366, 198 }, { 380, 198 }, { 381, 189 }, { 377, 186 }, { 369, 186 }, { 365, 189 } })
each(sack, function(x, y) P(x, y, (hash(x, y, 150) > 0.7) and "#d8bc88" or ((x > 375) and "#a8885a" or "#c8a870")) end)
edge(sack, "#5a4028")
fill(lineM({ { 373, 186 }, { 372, 178 }, { 374, 170 }, { 373, 166 } }, 2), GREEN[3])
leaf(373, 176, 364, 170, 3, -1, GREEN, 151); leaf(374, 172, 384, 166, 3, 1, GREEN, 152); leaf(373, 167, 370, 160, 2, -1, GREEN, 153)
-- crate of seedlings
local cr = rectM(436, 189, 456, 198); each(cr, function(x, y) P(x, y, ((y - 189) % 4 == 0) and WOOD[2] or WOOD[4]) end); edge(cr, WOOD[1])
for x = 438, 454, 4 do P(x, 188, GREEN[4]); P(x + 1, 187, GREEN[3]); P(x - 1, 187, GREEN[5]) end

-- 14 FOREGROUND PLANT (bottom-left corner) ---------------------------------
for _, lf in ipairs({ { 22, 270, 18, 232, 6, -3 }, { 26, 270, 48, 238, 6, 4 }, { 24, 270, 60, 258, 5, 3 } }) do
  leaf(lf[1], lf[2], lf[3], lf[4], lf[5], lf[6], GRASS, 160)
end

-- 15 GATE FRAME (carved teak, thatch eave, brackets, lanterns, garland) ----
local function carvedPost(x0, x1)
  local m = rectM(x0, 0, x1, H - 1)
  each(m, function(x, y)
    local a = x - x0
    local c = TEAK[3]
    if a <= 1 then c = TEAK[4] elseif a >= (x1 - x0) - 2 then c = TEAK[2] end
    if a == 2 and hash(x, y // 3, 170) > 0.5 then c = TEAK[5] end
    if hash(x, y, 171) < 0.06 then c = TEAK[2] end
    local band = (y - 30) % 56
    if band < 6 then
      c = (band == 0 or band == 5) and TEAK[1] or (((x + y) % 4 == 0) and "#a87a30" or "#d8a848")
    elseif band >= 20 and band <= 34 then
      local cxp = (x0 + x1) / 2
      local dd = abs(x - cxp) + abs(band - 27)
      if dd == 5 then c = TEAK[1] elseif dd == 3 then c = "#c83a3a" elseif dd < 2 then c = "#d8a848" end
    end
    P(x, y, c)
  end)
  edge(m, TEAK[1])
  -- garland spiral wrapped round the post
  for y = 40, 240, 12 do for k = 0, x1 - x0 do
    local x, yy = x0 + k, y + floor(k * 0.6)
    P(x, yy, (k % 3 == 0) and "#ffc24a" or "#f08a2a"); P(x, yy + 1, "#c8601e")
  end end
  -- stone plinth
  local pl = rectM(x0 - 2, 250, x1 + 2, H - 1)
  each(pl, function(x, y) P(x, y, (((x + ((y - 250) // 5) * 3) // 6) % 2 == 0) and "#9a8fa6" or "#867b98") end)
  edge(pl, "#4a4064")
end
carvedPost(0, 15); carvedPost(464, 479)
-- bow tied on the left post (quirk-ish charm)
fill(polyM({ { 6, 120 }, { 1, 116 }, { 1, 124 } }), "#e04a6a"); fill(polyM({ { 9, 120 }, { 14, 116 }, { 14, 124 } }), "#e04a6a")
fill(rectM(6, 118, 9, 122), "#f07a90"); P(5, 126, "#c83a5a"); P(4, 127, "#c83a5a"); P(10, 126, "#c83a5a"); P(11, 127, "#c83a5a")
-- lintel + thatch eave
local beam = rectM(0, 5, W - 1, 13)
each(beam, function(x, y)
  local c = TEAK[3]
  if y == 6 then c = TEAK[4] elseif y == 12 then c = TEAK[2] end
  if y == 9 then c = ((x // 3) % 2 == 0) and "#d8a848" or "#a87a30" end
  if (x % 24 == 12) and y >= 7 and y <= 11 then c = "#c83a3a" end
  P(x, y, c)
end)
edge(beam, TEAK[1])
local eave = rectM(0, 0, W - 1, 4)
for x = 0, W - 1 do if hash(x, 3, 172) > 0.4 then madd(eave, x, 5) end end
roofTex(eave, THATCH, "thatch", 0, 173)
-- carved corner brackets
for _, br in ipairs({ { { 16, 13 }, { 46, 13 }, { 16, 40 } }, { { 463, 13 }, { 433, 13 }, { 463, 40 } } }) do
  local m = polyM(br); blobTone(m, TEAK, 174, 0.2)
  local cx = (br[1][1] * 2 + br[2][1]) / 3; local cy = 20
  fill(rectM(cx - 2, cy - 1, cx + 1, cy + 1), TEAK[1]); P(cx - 1, cy, "#d8a848")
end
-- marigold garland with pennants across the top
for x = 16, 463 do
  local y = floor(14 + 9 * (1 - ((x - 240) / 224) ^ 2))
  P(x, y, (x % 3 == 0) and "#ffc24a" or "#f08a2a"); P(x, y + 1, (x % 7 == 3) and "#4a8a3a" or "#c8601e")
end
local PC = { "#f07a90", "#3a9a8a", "#f6c850", "#ec8a3a", "#7a8ad8" }
for i, x in ipairs((function() local t = {}; for x = 28, 452, 18 do t[#t + 1] = x end; return t end)()) do
  local y = floor(14 + 9 * (1 - ((x - 240) / 224) ^ 2)) + 2
  local m = polyM({ { x - 3, y }, { x + 4, y }, { x + 0.5, y + 7 } })
  local col = PC[(i % #PC) + 1]
  fill(m, col); edge(m, mix(col, "#2b1c26", 0.5)); P(x - 1, y + 1, mix(col, "#fff0d0", 0.4))
end
-- hanging gate lanterns
for _, lx in ipairs({ 48, 426 }) do
  for y = 14, 20 do P(lx + 3, y, "#3a2224") end
  glow(lx + 3, 29, 12, 0.22)
  lantern(lx, 21, 8, 16, LR.red, 7)
  fill(rectM(lx + 1, 19, lx + 6, 20), "#e8b04a"); fill(rectM(lx + 1, 37, lx + 6, 38), "#e8b04a")
  for y = 39, 43 do P(lx + 3, y, (y % 2 == 0) and "#f6c850" or "#e0503e") end
end
-- warm lantern glow onto the posts
glow(16, 40, 6, 0.18); glow(463, 40, 6, 0.18)

-- push to canvas --------------------------------------------------------------
local c = HP.canvas({ w = W, h = H, scale = 1, name = NAME })
for y = 0, H - 1 do for x = 0, W - 1 do c:px(x, y, B[y * W + x] or "#2f2552") end end
c:finish({ outline = false })
HP.assertClean(c)
c:save({ aseprite = OUT .. NAME .. ".aseprite", png = OUT .. NAME .. ".png", scale = 1 })
print("saved " .. NAME)
