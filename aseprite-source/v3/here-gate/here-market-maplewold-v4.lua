-- Maplewold market, gate view, v4 (single pass): v2 warmth + v3 readability. 480x270 native.
local ROOT = "/home/user/gnome-venture/aseprite-source/v3/"
local HP = dofile(ROOT .. "lib/hp.lua")
local OUT = (app.params and app.params["out"]) or (ROOT .. "here-gate/")
local W, H = 480, 270
local floor, abs, max, min = math.floor, math.abs, math.max, math.min
local B = {}
local function px(x, y, c) x = floor(x) y = floor(y) if x >= 0 and x < W and y >= 0 and y < H then B[y*W+x+1] = c end end
local function rect(x0, y0, x1, y1, c) for y = y0, y1 do for x = x0, x1 do px(x, y, c) end end end
local function hash(x, y, s) local n = math.sin(x*12.9898 + y*78.233 + (s or 0)*37.719) * 43758.5453 return n - floor(n) end
local function frac(v) return v - floor(v) end
local function clamp(v, a, b) if v < a then return a elseif v > b then return b end return v end
-- masks
local function Mask() return { s = {}, n = 0 } end
local function madd(m, x, y) if x >= 0 and x < W and y >= 0 and y < H then local k = y*W+x if not m.s[k] then m.s[k] = true m.n = m.n + 1 end end end
local function mhas(m, x, y) if x < 0 or x >= W or y < 0 or y >= H then return false end return m.s[y*W+x] == true end
local function mrect(m, x0, y0, x1, y1) for y = y0, y1 do for x = x0, x1 do madd(m, x, y) end end return m end
local function inpoly(p, x, y)
  local c, j = false, #p
  for i = 1, #p do
    local xi, yi, xj, yj = p[i][1], p[i][2], p[j][1], p[j][2]
    if ((yi > y) ~= (yj > y)) and (x < (xj - xi) * (y - yi) / (yj - yi) + xi) then c = not c end
    j = i
  end
  return c
end
local function mpoly(m, p)
  local x0, y0, x1, y1 = 9999, 9999, -9999, -9999
  for _, q in ipairs(p) do x0 = min(x0, q[1]) y0 = min(y0, q[2]) x1 = max(x1, q[1]) y1 = max(y1, q[2]) end
  for y = floor(y0), math.ceil(y1) do for x = floor(x0), math.ceil(x1) do
    if inpoly(p, x + 0.5, y + 0.5) then madd(m, x, y) end end end
  return m
end
local function mline(m, p, w)
  for i = 1, #p - 1 do
    local ax, ay, bx, by = p[i][1], p[i][2], p[i+1][1], p[i+1][2]
    local n = max(abs(bx - ax), abs(by - ay)) * 2 + 1
    for s = 0, n do
      local t = s / n
      local cx, cy = ax + (bx - ax)*t, ay + (by - ay)*t
      local sx, sy = floor(cx - (w - 1)/2 + 0.5), floor(cy - (w - 1)/2 + 0.5)
      for yy = 0, w - 1 do for xx = 0, w - 1 do madd(m, sx + xx, sy + yy) end end
    end
  end
  return m
end
local function blob(m, cx, cy, rx, ry, seed)
  for y = floor(cy - ry - 1), floor(cy + ry + 1) do for x = floor(cx - rx - 1), floor(cx + rx + 1) do
    local dx, dy = (x + 0.5 - cx)/rx, (y + 0.5 - cy)/ry
    if dx*dx + dy*dy < 1 - 0.3*hash(floor(x/2), floor(y/2), seed) then madd(m, x, y) end
  end end
  return m
end
local function keys(m) local t = {} for k in pairs(m.s) do t[#t+1] = k end table.sort(t) return t end
local function meach(m, f) for _, k in ipairs(keys(m)) do f(k % W, floor(k / W)) end end
local function mfill(m, c) for k in pairs(m.s) do B[k+1] = c end end
local D4 = { {1,0}, {-1,0}, {0,1}, {0,-1} }
local function rim(m, c)
  local r = {}
  for k in pairs(m.s) do
    local x, y = k % W, floor(k / W)
    for _, d in ipairs(D4) do
      local nx, ny = x + d[1], y + d[2]
      if nx >= 0 and nx < W and ny >= 0 and ny < H and not m.s[ny*W+nx] then r[#r+1] = { nx, ny } end
    end
  end
  for _, q in ipairs(r) do px(q[1], q[2], c) end
end
local function union(...) local m = Mask() for _, a in ipairs({...}) do for k in pairs(a.s) do if not m.s[k] then m.s[k] = true m.n = m.n + 1 end end end return m end
local function part(m, r)
  meach(m, function(x, y)
    local c = r[3]
    if not mhas(m, x + 2, y) or not mhas(m, x, y + 2) then c = r[2] end
    if not mhas(m, x - 1, y) or not mhas(m, x, y - 1) then c = r[4] end
    px(x, y, c)
  end)
end
local function stamp(rows, x, y, map)
  for j, row in ipairs(rows) do for i = 1, #row do local c = map[row:sub(i, i)] if c then px(x + i - 1, y + j - 1, c) end end end
end

-- palette (from v2, extended ramps dark->light)
local INK = "#2b1c2e"
local COOL = { "#3a3048", "#55485e", "#766676", "#8a7a80", "#9a8a8e", "#ad9a94", "#bfaea6", "#cdb8a8" }
local WARM = { "#3e2636", "#58323a", "#6b5254", "#7e5a4a", "#8f6e5e", "#a07a58", "#b08c6a", "#c09a6a" }
local WOOD = { "#3a2232", "#58323a", "#764640", "#94604a", "#ab7563" }
local LWOOD = { "#58323a", "#9a5a32", "#c09a6a", "#d8b878", "#f0d488" }
local STONE = { "#3a3048", "#766676", "#9a8a8e", "#bfaea6", "#e0cfbe" }
local LIT = { "#d8962e", "#f2a73a", "#ffcd5c", "#ffe48a", "#fbeedc" }
local PL = {
  { "#6b5254", "#ad9a94", "#cdb8a8", "#e8dcc2", "#f6e4c6" },   -- cream
  { "#7e5a4a", "#b08c6a", "#d8b878", "#efbe72", "#f0d488" },   -- ochre
  { "#7e5562", "#ab7563", "#d4a088", "#ecc4a8", "#f6e4c6" },   -- salmon
  { "#4a5a3a", "#7f9a6a", "#b8cc98", "#d4e0b8", "#e8ecd0" },   -- sage
  { "#55485e", "#9a8a8e", "#c8b8aa", "#e0cfbe", "#f6e4c6" },   -- lavender stone
}
local RF = {
  { "#7f3142", "#cc5840", "#e67a4c", "#f88a52", "#ffc060" },   -- orange
  { "#4a1838", "#80223e", "#b8343c", "#e0523c", "#f88a52" },   -- red
  { "#33273e", "#7a4878", "#9a6286", "#bc8098", "#e0cfbe" },   -- purple
  { "#1f3a3c", "#3a7a6a", "#5aa088", "#7ec4a0", "#b8e0c8" },   -- teal
  { "#2f2c46", "#47405a", "#62617a", "#848296", "#b2a8b0" },   -- slate
  { "#3a2232", "#6a2a3e", "#9a3a36", "#ae5048", "#e67a4c" },   -- brown-red
}
local MAPLE = {
  { "#4a1838", "#80223e", "#b8343c", "#e0523c", "#f88a52", "#ffcd5c" },
  { "#7f3142", "#cc5840", "#e67a4c", "#f4923a", "#ffc060", "#ffe48a" },
  { "#9a5a32", "#d97e2c", "#f2a73a", "#f4c23e", "#ffcd5c", "#ffe492" },
}
local GREEN = { "#2e4a34", "#4a7a3a", "#68a050", "#8cbc5c", "#b8cc98" }

-- spot geometry (boxes as drawn)
local BOX = {
  sugarshack = { 22, 88, 84, 176 }, bakery = { 96, 104, 146, 162 }, tavern = { 158, 98, 198, 148 },
  hall = { 211, 18, 269, 124 }, stalls = { 282, 100, 322, 148 }, store = { 334, 104, 388, 162 },
  guild = { 400, 100, 456, 176 }, square = { 212, 170, 268, 222 }, board = { 34, 180, 92, 226 },
  orchard = { 320, 180, 378, 226 },
}
local STAND = { {180,172}, {296,170}, {150,208}, {290,212}, {116,186}, {404,200} }
local function inStand(x, y, mx, my)
  for _, s in ipairs(STAND) do local dx, dy = (x - s[1])/(mx or 17), (y - s[2])/(my or 9) if dx*dx + dy*dy < 1 then return true end end
  return false
end

------------------------------------------------------------------ sky
for y = 0, 125 do
  local c = (y < 22 and "#efbe72") or (y < 48 and "#f0d488") or (y < 80 and "#ffe48a") or "#f6e4c6"
  for x = 0, W - 1 do px(x, y, c) end
end
-- maple canopy filling the sky (far clumps first)
local clumps = {}
for i = 1, 70 do
  local cx = 30 + hash(i, 1, 3) * 420
  local cy = 6 + hash(i, 2, 3) * 70 + abs(cx - 240) * 0.05
  clumps[#clumps+1] = { cx, cy, 10 + hash(i, 3, 3) * 14, 8 + hash(i, 4, 3) * 9, 1 + floor(hash(i, 5, 3) * 3) }
end
for i = 1, 26 do -- giant maple behind the hall: crimson/orange
  local a = hash(i, 9, 1) * 6.283
  local r = hash(i, 8, 1)
  clumps[#clumps+1] = { 240 + math.cos(a) * 70 * r, 50 + math.sin(a) * 30 * r, 14 + hash(i, 7, 1) * 10, 10 + hash(i, 6, 1) * 6, (i % 3 == 0) and 2 or 1 }
end
table.sort(clumps, function(a, b) return a[2] < b[2] end)
for ci, k in ipairs(clumps) do
  local m = blob(Mask(), k[1], k[2], k[3], k[4], ci)
  local R = MAPLE[k[5]]
  meach(m, function(x, y)
    local dx, dy = (x - k[1]) / k[3], (y - k[2]) / k[4]
    local L = 0.5 - (dx*0.55 + dy*0.75) * 0.5 + (hash(floor(x/2), floor(y/2), ci + 50) - 0.5) * 0.35
    local i = clamp(floor(L * 6) + 1, 1, 6)
    if hash(x, y, ci) > 0.94 then i = clamp(i + 1, 1, 6) end
    px(x, y, R[i])
  end)
end
-- giant maple trunk + limbs between canopy and hall roof
local trunk = mline(Mask(), { {240,66}, {238,54}, {230,44} }, 4)
mline(trunk, { {239,56}, {252,44} }, 3)
part(trunk, WOOD)

------------------------------------------------------------------ ground (cobbles, dim shadows)
local DIM = Mask()
mpoly(DIM, { {84,176}, {84,148}, {98,158}, {100,179}, {24,179}, {24,176} })
mpoly(DIM, { {146,162}, {146,140}, {158,147}, {160,165}, {96,165}, {96,162} })
mpoly(DIM, { {198,148}, {198,128}, {207,134}, {208,151}, {158,151}, {158,148} })
mpoly(DIM, { {322,148}, {322,130}, {332,136}, {334,151}, {282,151}, {282,148} })
mpoly(DIM, { {388,162}, {388,140}, {398,147}, {398,165}, {334,165}, {334,162} })
mpoly(DIM, { {456,176}, {456,150}, {460,153}, {460,179}, {400,179}, {400,176} })
mrect(DIM, 208, 124, 274, 126)
mpoly(DIM, { {224,216}, {260,216}, {270,221}, {232,224} })
mpoly(DIM, { {36,226}, {92,226}, {100,230}, {44,230} })
mpoly(DIM, { {320,224}, {378,224}, {386,229}, {326,229} })
mpoly(DIM, { {0,232}, {22,232}, {30,238}, {0,238} })
mpoly(DIM, { {459,232}, {479,232}, {479,238} })

local courses = {}
do
  local y, t, k = 269, 12.5, 0
  while y > 112 do
    local y0 = max(112, y - floor(t + 0.5))
    courses[#courses+1] = { y0 = y0, y1 = y, k = k }
    y = y0 t = max(2, t * 0.88) k = k + 1
  end
end
for _, cr in ipairs(courses) do
  local th = cr.y1 - cr.y0
  local dy = (cr.y0 + cr.y1) / 2 - 112
  for y = cr.y0 + 1, cr.y1 do
    local r = y - cr.y0
    for x = 0, W - 1 do
      local lat = (x - 240) / 240
      local function sidAt(xx) return floor((xx - 240) / max(dy, 1) / 0.15 + (cr.k % 2) * 0.5) end
      local sid = sidAt(x)
      local calm = (x >= 380 and y >= 230)
      local idx = (cr.k % 2 == 0) and 5 or 4
      local hv = hash(sid, cr.k, 7)
      if not calm then idx = idx + ((hv < 0.25) and -1 or ((hv > 0.8) and 1 or 0)) end
      if lat < -0.25 then idx = idx + 1 elseif lat > 0.3 then idx = idx - 1 end
      if th >= 3 then
        if r == 1 then idx = calm and 4 or 2
        elseif r == 2 then idx = idx + 1
        elseif r == th then idx = idx - 1 end
        if r > 1 and dy * 0.15 >= 3 then
          if sidAt(x - 1) ~= sid then idx = calm and 4 or 2
          elseif sidAt(x + 1) ~= sid then idx = idx - 1
          elseif sidAt(x - 2) ~= sid then idx = idx + 1 end
        end
      else
        idx = (cr.k % 2 == 0) and 5 or 4
        if lat > 0.3 then idx = idx - 1 end
      end
      if dy < 16 then idx = clamp(idx, 4, 6) end
      if mhas(DIM, x, y) then idx = idx - 2 end
      idx = clamp(idx, 1, 8)
      local warm = hash(sid, cr.k, 3) < (0.3 + 0.5 * max(0, lat))
      px(x, y, (warm and WARM or COOL)[idx])
    end
  end
end
-- scattered maple leaves on the cobbles (never on stand spots or the UI corner)
local LEAFC = { "#e0523c", "#f4923a", "#ffc060", "#cc5840", "#f4c23e" }
for i = 1, 150 do
  local x = floor(hash(i, 11, 2) * 470) + 4
  local y = floor(122 + (hash(i, 12, 2) ^ 0.7) * 145)
  if not inStand(x, y, 22, 13) and not (x >= 372 and y >= 224) then
    local c = LEAFC[1 + floor(hash(i, 13, 2) * 5)]
    px(x, y, c) px(x + 1, y, c)
    if y > 170 then px(x, y + 1, "#9a3a36") px(x + 1, y - 1, c) end
  end
end

------------------------------------------------------------------ canyon walls (timber-frame, perspective)
local LH = {
  { d0 = 240, d1 = 182, t = -34, pl = 1, rf = 1, ch = 205 },
  { d0 = 182, d1 = 138, t = 2, pl = 2, rf = 3 },
  { d0 = 138, d1 = 104, t = -18, pl = 3, rf = 4, ch = 120 },
  { d0 = 104, d1 = 78, t = 10, pl = 4, rf = 2 },
  { d0 = 78, d1 = 56, t = -4, pl = 5, rf = 6, ch = 66 },
  { d0 = 56, d1 = 34, t = 16, pl = 1, rf = 5 },
}
local RHs = {
  { d0 = 240, d1 = 186, t = -26, pl = 3, rf = 3, ch = 210 },
  { d0 = 186, d1 = 140, t = -2, pl = 4, rf = 1 },
  { d0 = 140, d1 = 108, t = -20, pl = 2, rf = 6, ch = 124 },
  { d0 = 108, d1 = 80, t = 6, pl = 1, rf = 4 },
  { d0 = 80, d1 = 58, t = -8, pl = 3, rf = 5 },
  { d0 = 58, d1 = 34, t = 14, pl = 2, rf = 2, ch = 46 },
}
local Sp = 1.4
local function drawWall(side, HS)
  for d = 34, 240 do
    local x = 240 + side * d
    if x >= 0 and x < W then
      local h, hi
      for i, hh in ipairs(HS) do if d <= hh.d0 and d > hh.d1 then h = hh hi = i end end
      if h then
        local yb = 112 + 70 * d / 240
        local yt = 112 - (112 - h.t) * d / 240
        local hg = yb - yt
        local rh = 0.2 * hg
        local yr = yt - rh
        local q = 2400 / d
        local P, R = PL[h.pl], RF[h.rf]
        local lit = (side == 1)
        local boundary = (d - h.d1) < 1.5
        local Spe = (Sp * d * d / 2400 < 6) and Sp * 3 or Sp
        local bwe = Spe * d * d / 2400
        local s = q / Spe
        local bi, bf = floor(s), frac(s)
        if side == 1 then bf = 1 - bf end
        -- chimney
        if h.ch and abs(d - h.ch) <= max(1, d * 0.03) then
          local ctop = floor(yr - 0.1 * hg)
          for y = ctop, floor(yr) do px(x, y, (abs(d - h.ch) > d * 0.02) and "#6a2a3e" or "#9a3a36") end
          px(x, ctop, "#3a2232") px(x, ctop + 1, "#3a2232")
        end
        for y = floor(yr), floor(yb) do
          local c
          if y < yt then -- roof
            local r = (yt - y) / rh
            local cr = r * 5
            local ci = floor(cr)
            local base = lit and 4 or 3
            if (frac(cr) * rh / 5) < 0.8 then base = base - 1 end
            local s2 = q / (Sp * 0.5) + ci * 0.5
            if Sp * 0.5 * d * d / 2400 >= 3 and frac(s2) * Sp * 0.5 * d * d / 2400 < 0.9 then base = base - 1 end
            if hash(floor(s2), ci, hi) > 0.85 then base = base + 1 end
            if y == floor(yr) then base = 5 end
            if (yt - y) < 1.5 then c = "#3a2232" else c = R[clamp(base, 1, 5)] end
          else
            local v = (y - yt) / hg
            local bt = max(1, hg * 0.014)
            local fi = (v < 0.33) and 1 or ((v < 0.64) and 2 or 3)
            local f0 = (fi == 1) and 0 or ((fi == 2) and 0.33 or 0.64)
            local f1 = (fi == 1) and 0.33 or ((fi == 2) and 0.64 or 1.0)
            local ff = (v - f0) / (f1 - f0)
            local fh = (f1 - f0) * hg
            local beam = false
            for _, vk in ipairs({ 0, 0.33, 0.64 }) do local yy = yt + vk * hg if y >= yy - 0.5 and y < yy + bt then beam = true end end
            local postw = (bwe >= 14) and 2 or 1
            local post = (bf * bwe < postw)
            local base = lit and 3 or 2
            if v < 0.25 and lit then base = 4 end
            c = P[base]
            if hash(x, y, 9) > 0.93 then c = P[clamp(base + ((hash(y, x, 4) > 0.5) and 1 or -1), 1, 5)] end
            if v > 0.94 then c = (y % 3 == 0) and COOL[3] or COOL[lit and 6 or 5] end
            local wx0, wx1, wy0, wy1 = 0.3, 0.7, 0.22, 0.68
            local inWinX = bf > wx0 and bf < wx1
            local inWinY = ff > wy0 and ff < wy1
            if bwe >= 5 and fi <= 2 and not (fi == 2 and bi % 2 == 1) then
              if inWinX and inWinY then
                local ex = min((bf - wx0) * bwe, (wx1 - bf) * bwe)
                local ey = min((ff - wy0) * fh, (wy1 - ff) * fh)
                local on = hash(bi, fi, hi + side * 10) < 0.65
                if ex < 1 or ey < 1 or abs(bf - 0.5) * bwe < 0.5 or abs(ff - 0.45) * fh < 0.5 then c = "#3e2636"
                elseif on then c = (ff < 0.4 and bf < 0.5) and LIT[4] or ((ff > 0.55) and LIT[2] or LIT[3])
                else c = (ff < 0.4 and bf < 0.5) and "#56749e" or "#3a3048" end
              elseif inWinY and ((bf > 0.17 and bf <= wx0) or (bf >= wx1 and bf < 0.83)) then
                c = (floor(ff * fh) % 2 == 0) and R[2] or R[3]
              elseif bf > 0.26 and bf < 0.74 and ff >= 0.68 and ff < 0.8 then
                c = (ff < 0.73) and ((hash(x, y, 2) < 0.5) and "#e0523c" or ((hash(x, y, 3) < 0.5) and "#68a050" or "#ffcd5c")) or "#764640"
              end
            elseif bwe >= 5 and fi == 2 then -- cross braces
              if abs(bf - ff) * bwe < 0.8 or abs(bf - (1 - ff)) * bwe < 0.8 then beam = true end
            elseif bwe >= 5 and fi == 3 and v <= 0.94 then -- ground floor shops
              if bi % 3 == 0 and bf > 0.32 and bf < 0.68 and ff > 0.2 then
                c = (ff < 0.45 and abs(bf - 0.5) * bwe > 0.6) and LIT[3] or WOOD[2]
              elseif bf > 0.18 and bf < 0.82 and ff > 0.22 and ff < 0.7 then
                local ex = min((bf - 0.18) * bwe, (0.82 - bf) * bwe)
                c = (ex < 1 or abs(ff - 0.46) * fh < 0.5) and "#3e2636" or ((ff < 0.4) and LIT[4] or LIT[3])
              end
            end
            if post or beam then
              c = lit and "#58323a" or "#3e2636"
              if lit and post and bf * bwe >= 1 then c = "#764640" end
            end
            if boundary then c = ((d - h.d1) < 0.8) and "#3e2636" or (lit and "#848296" or "#62617a") end
            -- wall lantern on house boundary
            if (d - h.d1) >= 1.5 and (d - h.d1) < 1.5 + max(2, bwe * 0.25) and abs(v - 0.6) < 0.035 then c = LIT[4] end
          end
          px(x, y, c)
        end
      end
    end
  end
end
-- distant closing facades behind the hall
for x = 196, 284 do for y = 88, 122 do
  local c = ((x % 9) < 1) and "#8f6e5e" or "#cdb8a8"
  if y < 94 then c = (y % 2 == 0) and "#9a3a36" or "#ae5048" end
  if (x % 9) >= 3 and (x % 9) <= 5 and (y % 12) >= 2 and (y % 12) <= 6 and y > 96 then c = LIT[3] end
  px(x, y, c)
end end
drawWall(-1, LH)
drawWall(1, RHs)

------------------------------------------------------------------ helpers for fronts
local function gable(xl, xr, yb, ya, R)
  local mid = (xl + xr) / 2
  local m = mpoly(Mask(), { {xl, yb}, {mid, ya}, {xr, yb} })
  meach(m, function(x, y)
    local row = floor((y - ya) / 3)
    local i = (x < mid) and 4 or 3
    if (y - ya) % 3 == 2 then i = i - 1 end
    if (x + row * 2) % 5 == 0 then i = i - 1 end
    if not mhas(m, x, y + 1) then i = 1 end
    if not mhas(m, x - 1, y) or not mhas(m, x + 1, y) or not mhas(m, x, y - 1) then i = (x < mid) and 5 or 2 end
    px(x, y, R[clamp(i, 1, 5)])
  end)
  return m
end
local function win(x0, y0, x1, y1, on)
  rect(x0, y0, x1, y1, "#3e2636")
  for y = y0 + 1, y1 - 1 do for x = x0 + 1, x1 - 1 do
    local c
    if on then c = ((y - y0) < (y1 - y0) * 0.4 and (x - x0) < (x1 - x0) * 0.5) and LIT[4] or (((y1 - y) <= 2) and LIT[2] or LIT[3])
    else c = ((y - y0) < (y1 - y0) * 0.4) and "#56749e" or "#3a3048" end
    px(x, y, c)
  end end
  local mx, my = floor((x0 + x1) / 2), floor((y0 + y1) / 2)
  for y = y0, y1 do px(mx, y, "#3e2636") end
  for x = x0, x1 do px(x, my, "#3e2636") end
  rect(x0 - 1, y1 + 1, x1 + 1, y1 + 1, "#c09a6a")
end
local function steam(x, y, n)
  for i = 0, n - 1 do
    local ox = ((i % 4 == 1) and 1) or ((i % 4 == 3) and -1) or 0
    px(x + ox, y - i, (i % 3 == 2) and "#e8dcc2" or "#fbeedc")
  end
end
local function pie(x, y) -- 9x3 on a sill, steaming
  rect(x + 1, y, x + 7, y, "#f4c23e") rect(x, y + 1, x + 8, y + 1, "#d8962e") rect(x, y + 2, x + 8, y + 2, "#9a5a32")
  px(x + 2, y, "#ffe48a") px(x + 3, y + 1, "#9a5a32") px(x + 5, y + 1, "#9a5a32") px(x + 7, y + 1, "#9a5a32")
  steam(x + 3, y - 1, 6) steam(x + 6, y - 2, 5)
end
local MAP_LEAF = { "...a...", ".a.a.a.", ".aaaaa.", "aaaaaaa", ".aaaaa.", "..aaa..", "...b..." }
local function barrel(x0, y0, x1, y1)
  local m = Mask()
  for y = y0, y1 do local inset = (y == y0 or y == y1) and 1 or 0 for x = x0 + inset, x1 - inset do madd(m, x, y) end end
  rim(m, INK)
  meach(m, function(x, y)
    local u = (x - x0) / (x1 - x0)
    local c = (u < 0.3) and "#d97e2c" or ((u < 0.75) and "#ad6440" or "#83463a")
    if (x - x0) % 3 == 0 then c = "#83463a" end
    if y == y0 + 2 or y == y1 - 2 then c = (u < 0.3) and "#848296" or "#47405a" end
    if y == y0 then c = "#b07c58" end
    px(x, y, c)
  end)
end

------------------------------------------------------------------ town hall + leaning clock tower
do
  local function lo(y) return floor((64 - y) / 8) end
  local tower = Mask()
  for y = 30, 66 do for x = 231, 249 do madd(tower, x + lo(y), y) end end
  local spire = mpoly(Mask(), { {229 + lo(30), 31}, {251 + lo(30), 31}, {241 + lo(19), 18} })
  local roof = mpoly(Mask(), { {207, 71}, {240, 44}, {273, 71} })
  local body = mrect(Mask(), 212, 70, 268, 121)
  local steps = mrect(Mask(), 224, 121, 256, 124)
  local all = union(tower, spire, roof, body, steps)
  rim(all, "#3e2636")
  gable(207, 273, 71, 44, RF[2])
  -- tower
  meach(tower, function(x, y)
    local tx = x - lo(y) - 231
    local c = (tx < 6) and "#f6e4c6" or ((tx < 14) and "#e8dcc2" or "#cdb8a8")
    if tx == 0 or tx == 18 or y == 52 or y == 31 then c = "#4c2a3a" end
    if (tx == 1 or tx == 17) and y > 52 and (y % 4 == 0) then c = "#4c2a3a" end
    px(x, y, c)
  end)
  -- belfry with gold bell
  for y = 33, 38 do for x = 235, 245 do px(x + lo(y), y, (y == 33) and "#3e2636" or "#58323a") end end
  for y = 34, 38 do for x = 238, 242 do if not (y == 34 and (x == 238 or x == 242)) then px(x + lo(y), y, (x < 240) and "#ffe48a" or "#f4c23e") end end end
  -- octagonal clock face (no circle)
  local ccx, ccy = 240 + lo(44), 44
  local face = mpoly(Mask(), { {ccx-3,ccy-6}, {ccx+4,ccy-6}, {ccx+7,ccy-3}, {ccx+7,ccy+4}, {ccx+4,ccy+7}, {ccx-3,ccy+7}, {ccx-6,ccy+4}, {ccx-6,ccy-3} })
  rim(face, "#d8962e")
  mfill(face, "#fbeedc")
  meach(face, function(x, y) if not mhas(face, x + 1, y + 1) then px(x, y, "#e0cfbe") end end)
  for _, p in ipairs({ {0,-5}, {5,0}, {0,5}, {-5,0} }) do px(ccx + p[1], ccy + p[2], "#3e2636") end
  for i = 0, 3 do px(ccx, ccy - i, "#3e2636") end
  for i = 0, 3 do px(ccx + i, ccy + floor(i/2), "#3e2636") end
  px(ccx, ccy, "#b8343c")
  -- spire
  meach(spire, function(x, y)
    local c = (x < 241 + lo(25)) and "#9a6286" or "#7a4878"
    if y % 3 == 0 then c = "#33273e" end
    if not mhas(spire, x - 1, y) then c = "#bc8098" end
    px(x, y, c)
  end)
  px(241 + lo(19), 17, "#f4c23e") px(241 + lo(19), 16, "#f4c23e")
  -- body: stone lower, cream timber upper
  meach(body, function(x, y)
    local c
    if y >= 96 then
      local row = floor((y - 96) / 4)
      c = ((x - 212) < 20) and STONE[4] or (((x - 212) < 44) and "#ad9a94" or STONE[3])
      if (y - 96) % 4 == 0 or ((x + row * 4) % 8 == 0) then c = STONE[2] end
    else
      c = ((x - 212) < 22) and "#f6e4c6" or "#e8dcc2"
      if x == 212 or x == 213 or x == 226 or x == 254 or x == 267 or x == 268 or y == 82 or y == 95 or y == 70 then c = "#4c2a3a" end
      if (y < 82) and (abs((x - 213) - (y - 70)) < 1 or abs((267 - x) - (y - 70)) < 1) then c = "#4c2a3a" end
    end
    px(x, y, c)
  end)
  -- big arched doorway, open, glowing
  local arch = mpoly(Mask(), { {228,121}, {228,99}, {231,94}, {236,91}, {244,91}, {249,94}, {252,99}, {252,121} })
  mfill(arch, STONE[5]) rim(arch, "#3e2636")
  local door = mpoly(Mask(), { {230,121}, {230,100}, {233,95}, {237,93}, {243,93}, {247,95}, {250,100}, {250,121} })
  meach(door, function(x, y)
    local c = (y < 104) and LIT[4] or LIT[3]
    if x <= 233 or x >= 247 then c = (x % 2 == 0) and "#58323a" or "#764640" end
    if (x == 234 or x == 246) then c = "#3a2232" end
    if y >= 118 and x > 234 and x < 246 then c = LIT[2] end
    px(x, y, c)
  end)
  px(231, 108, "#f4c23e") px(249, 108, "#f4c23e")
  px(240, 92, "#f4c23e") px(239, 92, "#f4c23e")
  -- windows
  win(216, 100, 223, 113, true) win(257, 100, 264, 113, true)
  win(216, 73, 223, 80, true) win(257, 73, 264, 80, true)
  win(235, 84, 245, 89, true)
  -- maple banners
  for _, bx in ipairs({ 225, 253 }) do
    rect(bx, 98, bx + 2, 109, "#b8343c") px(bx, 98, "#e0523c") px(bx + 1, 104, "#f4c23e") px(bx + 1, 103, "#f4c23e")
    px(bx + 1, 110, "#b8343c") rect(bx - 1, 97, bx + 3, 97, "#3a2232")
  end
  -- steps
  for y = 121, 124 do for x = 224 + (124 - y), 256 - (124 - y) do px(x, y, (y % 2 == 0) and STONE[4] or STONE[3]) end end
  rect(224, 124, 256, 124, STONE[2])
end

------------------------------------------------------------------ sugar shack (red-brown plank barn, steam cupola, maple sign)
do
  local roof = mpoly(Mask(), { {22, 127}, {53, 104}, {84, 127} })
  local body = mrect(Mask(), 26, 125, 80, 175)
  local cup = mrect(Mask(), 48, 96, 58, 106)
  local cuproof = mpoly(Mask(), { {45, 97}, {53, 89}, {61, 97} })
  rim(union(roof, body, cup, cuproof), "#4c2a3a")
  meach(body, function(x, y)
    local c = ((x - 26) % 7 < 2) and "#94604a" or "#764640"
    if (x - 26) % 7 == 6 then c = "#58323a" end
    if (x - 26) % 7 == 0 then c = "#ab7563" end
    if hash(x, floor(y / 5), 4) > 0.9 then c = "#58323a" end
    if y >= 170 then c = (y == 170 or (x % 6 == 0)) and COOL[2] or COOL[4] end
    if x >= 76 and y < 170 then c = (c == "#ab7563") and "#94604a" or "#58323a" end
    px(x, y, c)
  end)
  gable(22, 84, 127, 104, RF[5])
  mfill(cup, "#764640")
  for y = 98, 105, 2 do rect(49, y, 57, y, "#3a2232") end
  rect(48, 96, 49, 106, "#94604a")
  gable(45, 61, 97, 89, RF[5])
  -- steam puffs
  local st = Mask() blob(st, 50, 84, 4, 3, 1) blob(st, 55, 79, 3.5, 3, 2) blob(st, 49, 75, 3, 2.5, 3)
  meach(st, function(x, y) px(x, y, (hash(x, y, 1) > 0.7 or not mhas(st, x + 1, y + 1)) and "#e8dcc2" or "#fbeedc") end)
  -- barn doors with X braces
  rect(43, 145, 63, 169, "#3a2232")
  for y = 146, 169 do for x = 44, 62 do
    local c = ((x - 44) % 3 == 0) and "#58323a" or "#764640"
    if x == 53 then c = "#3a2232" end
    local u, v = (x < 53) and (x - 44) or (x - 54), y - 146
    if abs(u * 24 / 8 - v) < 1.6 or abs((8 - u) * 24 / 8 - v) < 1.6 then c = "#c09a6a" end
    if y == 146 or y == 157 or y == 169 then c = "#a07a58" end
    px(x, y, c)
  end end
  -- lit window
  win(30, 133, 39, 142, true)
  -- maple-leaf sign on a bracket
  rect(66, 129, 79, 129, "#3a2232") rect(68, 130, 68, 131, "#3a2232") rect(77, 130, 77, 131, "#3a2232")
  rect(65, 132, 80, 144, "#3e2636") rect(66, 133, 79, 143, "#e8dcc2") rect(66, 143, 79, 143, "#cdb8a8")
  stamp(MAP_LEAF, 69, 134, { a = "#e0523c", b = "#80223e" }) px(70, 135, "#f88a52")
  -- sap buckets on taps
  for _, bx in ipairs({ 30, 68 }) do rect(bx, 152, bx + 4, 156, "#848296") rect(bx, 152, bx + 4, 152, "#b2a8b0") px(bx + 2, 151, "#47405a") px(bx + 4, 156, "#47405a") end
  -- firewood stack
  for i = 0, 2 do for j = 0, 3 - i do
    local x, y = 27 + j * 4 + i * 2, 171 - i * 3
    rect(x, y - 2, x + 3, y, "#58323a") rect(x + 1, y - 1, x + 2, y - 1, "#c09a6a")
  end end
  barrel(70, 162, 79, 175)
end

------------------------------------------------------------------ pie bakery (cream timber, orange tiles, pie sill)
do
  local roof = mpoly(Mask(), { {94, 127}, {121, 105}, {148, 127} })
  local body = mrect(Mask(), 98, 125, 144, 161)
  local chim = mrect(Mask(), 131, 104, 137, 116)
  rim(union(roof, body, chim), "#58323a")
  meach(chim, function(x, y) px(x, y, ((y % 3 == 0) or ((x + floor(y / 3)) % 3 == 0)) and "#6a2a3e" or "#9a3a36") end)
  rect(130, 104, 138, 105, "#3a2232")
  steam(134, 102, 7) steam(132, 98, 5)
  part(body, PL[1])
  -- timber frame
  for y = 125, 161 do px(98, y, "#4c2a3a") px(144, y, "#4c2a3a") px(121, y, "#4c2a3a") end
  for x = 98, 144 do px(x, 125, "#4c2a3a") px(x, 140, "#4c2a3a") px(x, 141, "#4c2a3a") end
  for i = 0, 13 do px(99 + i, 139 - i, "#4c2a3a") px(143 - i, 139 - i, "#4c2a3a") end
  gable(94, 148, 127, 105, RF[1])
  win(104, 128, 116, 136, true) rect(104, 138, 116, 139, "#764640") px(106, 137, "#e0523c") px(110, 137, "#68a050") px(114, 137, "#ffcd5c")
  win(126, 128, 139, 136, true)
  -- bay window with pies on sill
  win(101, 144, 118, 155, true)
  rect(100, 157, 119, 158, "#a07a58") rect(100, 158, 119, 158, "#764640")
  pie(101, 154) pie(110, 154)
  -- door + pie sign
  local door = mpoly(Mask(), { {125, 161}, {125, 147}, {128, 144}, {136, 144}, {139, 147}, {139, 161} })
  rim(door, "#3a2232")
  meach(door, function(x, y) px(x, y, ((x - 125) % 4 == 0) and "#764640" or "#94604a") end)
  win(129, 147, 135, 151, true) px(137, 154, "#f4c23e")
  rect(122, 140, 141, 141, "#4c2a3a")
  -- pie icon board above door
  rect(126, 117, 140, 124, "#3e2636") rect(127, 118, 139, 123, "#e8dcc2")
  stamp({ "..cccccc..", ".cdcdcdcc.", "cccccccccc", "dddddddddd" }, 128, 119, { c = "#f4c23e", d = "#9a5a32" })
end

------------------------------------------------------------------ tavern (ochre jettied timber-frame, purple roof, mug sign)
do
  local roof = mpoly(Mask(), { {155, 117}, {178, 98}, {201, 117} })
  local up = mrect(Mask(), 158, 115, 198, 130)
  local low = mrect(Mask(), 161, 131, 195, 147)
  rim(union(roof, up, low), "#4a1838")
  part(up, PL[2]) part(low, PL[2])
  for x = 158, 198 do px(x, 115, "#3e2636") px(x, 130, "#3e2636") end
  for x = 161, 195 do px(x, 131, "#58323a") end
  for _, x in ipairs({ 158, 168, 178, 188, 198 }) do for y = 115, 130 do px(x, y, "#3e2636") end end
  for _, x in ipairs({ 161, 172, 184, 195 }) do for y = 131, 147 do px(x, y, "#3e2636") end end
  for i = 0, 8 do px(169 + i, 129 - i, "#3e2636") px(187 - i, 129 - i, "#3e2636") end
  gable(155, 201, 117, 98, RF[3])
  win(160, 118, 166, 127, true) win(190, 118, 196, 127, true)
  win(173, 104, 183, 112, true)
  -- door with lantern
  rect(173, 135, 183, 147, "#3a2232")
  for y = 136, 147 do for x = 174, 182 do px(x, y, ((x - 174) % 3 == 0) and "#58323a" or "#764640") end end
  px(181, 141, "#f4c23e")
  rect(171, 134, 171, 135, "#3a2232") rect(170, 136, 172, 139, "#3e2636") px(171, 137, LIT[4]) px(171, 138, LIT[3])
  -- window with steaming pie
  win(163, 135, 170, 143, true) rect(162, 145, 171, 145, "#a07a58")
  pie(162, 142)
  -- mug sign on bracket
  rect(185, 132, 194, 132, "#3a2232") px(186, 133, "#3a2232") px(193, 133, "#3a2232")
  rect(185, 134, 194, 143, "#3e2636") rect(186, 135, 193, 142, "#e8dcc2")
  stamp({ "cccc..", "aaaa..", "aaaab.", "aaaa.b", "aaaabb", "aaaa.." }, 187, 136, { c = "#fbeedc", a = "#f4c23e", b = "#9a5a32" })
  px(187, 137, "#ffe48a")
  barrel(186, 145, 192, 147)
end

------------------------------------------------------------------ maple stalls (striped awning, bottles, pumpkin in a hat)
do
  local aw = mrect(Mask(), 282, 100, 322, 113)
  local scal = Mask()
  for x = 282, 322 do if ((x - 282) % 5) >= 1 and ((x - 282) % 5) <= 3 then madd(scal, x, 114) end end
  local posts = mrect(Mask(), 284, 114, 285, 147) mrect(posts, 319, 114, 320, 147)
  local back = mrect(Mask(), 286, 115, 318, 129)
  local counter = mrect(Mask(), 283, 130, 321, 147)
  rim(union(aw, scal, posts, back, counter), "#4a1838")
  meach(union(aw, scal), function(x, y)
    local red = floor((x - 282) / 5) % 2 == 0
    local c = red and ((y < 104) and "#e0523c" or "#b8343c") or ((y < 104) and "#fbeedc" or "#ecd3b0")
    if y == 100 then c = red and "#f88a52" or "#fbeedc" end
    if y == 113 or y == 114 then c = red and "#80223e" or "#cdb8a8" end
    px(x, y, c)
  end)
  rect(282, 100, 322, 100, "#7f3142")
  mfill(back, "#58323a")
  for x = 287, 317 do px(x, 121, "#94604a") end
  for i = 0, 7 do local x = 288 + i * 4 rect(x, 117, x + 1, 120, (i % 2 == 0) and "#d8962e" or "#f2a73a") px(x, 117, "#ffe48a") end
  part(posts, WOOD)
  meach(counter, function(x, y)
    local c = (y % 4 == 0) and "#58323a" or (((x < 300) and "#ab7563") or "#94604a")
    if y == 130 then c = "#c09a6a" end
    px(x, y, c)
  end)
  -- syrup bottles
  for i = 0, 3 do local x = 287 + i * 4
    rect(x, 125, x + 2, 129, "#d97e2c") px(x + 1, 123, "#3e2636") px(x + 1, 124, "#d97e2c") px(x, 126, "#ffcd5c")
  end
  -- apple crate
  rect(302, 125, 309, 129, "#764640")
  for _, p in ipairs({ {303,124}, {305,124}, {307,124}, {304,123}, {306,123} }) do px(p[1], p[2], "#b8343c") px(p[1] + 1, p[2], "#e0523c") end
  -- pumpkin with a hat
  local pk = Mask()
  local wd = { 7, 9, 11, 11, 11, 9, 7 }
  for j, w in ipairs(wd) do local x0 = 316 - floor(w / 2) - 1 for x = x0, x0 + w - 1 do madd(pk, x, 122 + j) end end
  rim(pk, INK)
  meach(pk, function(x, y)
    local u = x - 309
    local c = (u < 4) and "#f4923a" or ((u < 8) and "#d4642e" or "#9a3a36")
    if u == 3 or u == 6 then c = "#cc5840" end
    if u == 1 and y == 125 then c = "#ffc060" end
    px(x, y, c)
  end)
  rect(311, 122, 318, 122, "#33273e") rect(312, 116, 317, 121, "#33273e") rect(312, 120, 317, 120, "#b8343c")
  px(312, 117, "#55485e") px(312, 118, "#55485e")
  -- counter front icon: maple syrup jug
  rect(297, 135, 305, 144, "#3e2636") rect(298, 136, 304, 143, "#e8dcc2")
  stamp({ "..b..", ".aaa.", "aaaaa", "aaaaa", "aaaaa" }, 299, 138, { a = "#d97e2c", b = "#3e2636" }) px(300, 140, "#ffe48a")
end

------------------------------------------------------------------ general store (teal siding, shop window, sack sign)
do
  local roof = mpoly(Mask(), { {332, 125}, {361, 104}, {390, 125} })
  local body = mrect(Mask(), 336, 123, 386, 161)
  rim(union(roof, body), "#1f3a3c")
  local T = { "#1f3a3c", "#2f5a58", "#4a8a7a", "#7ec4a0", "#b8e0c8" }
  meach(body, function(x, y)
    local c = (x < 362) and T[3] or T[2]
    if (y - 123) % 3 == 0 then c = T[1] end
    if (y - 123) % 3 == 1 and x < 350 then c = T[4] end
    if x == 336 or x == 386 then c = "#3a2232" end
    px(x, y, c)
  end)
  gable(332, 390, 125, 104, RF[6])
  win(355, 109, 367, 118, true)
  -- shop window with goods + striped awning
  rect(339, 134, 361, 153, "#3a2232")
  for y = 135, 152 do for x = 340, 360 do px(x, y, (y < 141) and LIT[4] or LIT[3]) end end
  rect(340, 143, 360, 143, "#764640") rect(340, 151, 360, 152, "#764640")
  for i = 0, 6 do local x = 341 + i * 3
    rect(x, 139, x + 1, 142, ({ "#b8343c", "#5a8a4a", "#56749e", "#d97e2c" })[i % 4 + 1]) px(x, 139, "#fbeedc")
    rect(x, 147, x + 1, 150, ({ "#d8962e", "#9a6286", "#e0523c", "#68a050" })[i % 4 + 1])
  end
  for x = 338, 362 do for y = 128, 132 do px(x, y, (floor((x - 338) / 3) % 2 == 0) and ((y < 130) and "#7ec4a0" or "#5aa088") or ((y < 130) and "#fbeedc" or "#e0cfbe")) end end
  for x = 338, 362 do if (x - 338) % 3 ~= 2 then px(x, 133, ((floor((x - 338) / 3) % 2 == 0) and "#3a7a6a") or "#cdb8a8") end end
  -- door
  rect(366, 136, 379, 161, "#3a2232")
  for y = 137, 161 do for x = 367, 378 do px(x, y, ((x - 367) % 4 == 0) and "#47405a" or "#62617a") end end
  win(369, 139, 376, 146, true) px(377, 152, "#f4c23e")
  -- sack sign
  rect(365, 124, 380, 125, "#3a2232")
  rect(366, 126, 379, 134, "#3e2636") rect(367, 127, 378, 133, "#e8dcc2")
  stamp({ "..dd..", ".dbbd.", "..aa..", ".aaaa.", "aaaaaa", ".aaaa." }, 370, 127, { a = "#c09a6a", b = "#b8343c", d = "#58323a" })
  -- crates in front
  for _, x in ipairs({ 340, 349 }) do rect(x, 155, x + 7, 161, "#3a2232") rect(x + 1, 156, x + 6, 160, "#a07a58") rect(x + 1, 158, x + 6, 158, "#764640")
    for k = 0, 2 do px(x + 2 + k * 2, 155, (x == 340) and "#b8343c" or "#f4923a") end end
end

------------------------------------------------------------------ herbalist guild (sage timber, purple roof, herbs, pots)
do
  local roof = mpoly(Mask(), { {398, 127}, {428, 100}, {458, 127} })
  local body = mrect(Mask(), 402, 125, 454, 175)
  rim(union(roof, body), "#33273e")
  part(body, PL[4])
  for _, x in ipairs({ 402, 415, 441, 454 }) do for y = 125, 175 do px(x, y, "#3e2636") end end
  for x = 402, 454 do px(x, 125, "#3e2636") px(x, 146, "#3e2636") px(x, 147, "#3e2636") end
  for i = 0, 11 do px(416 + i, 145 - i, "#3e2636") px(440 - i, 145 - i, "#3e2636") end
  gable(398, 458, 127, 100, RF[3])
  win(421, 110, 435, 120, true)
  win(405, 130, 412, 140, true) win(444, 130, 451, 140, true)
  for _, x0 in ipairs({ 404, 443 }) do rect(x0, 142, x0 + 9, 144, "#764640")
    for k = 0, 4 do px(x0 + 1 + k * 2, 141, (k % 2 == 0) and "#e0523c" or "#9a6286") px(x0 + 2 + k * 2, 141, "#68a050") end end
  -- herb bundles under the eave
  for i = 0, 6 do local x = 418 + i * 3
    px(x, 128, "#3a2232") px(x, 129, (i % 2 == 0) and "#68a050" or "#9a6286") px(x, 130, (i % 2 == 0) and "#5a8a4a" or "#7a4878") px(x, 131, "#4a7a3a")
  end
  -- round-top green door
  local door = mpoly(Mask(), { {421, 175}, {421, 156}, {424, 151}, {428, 149}, {432, 151}, {435, 156}, {435, 175} })
  rim(door, "#2e4a34")
  meach(door, function(x, y) px(x, y, ((x - 421) % 4 == 0) and "#4a7a3a" or "#68a050") end)
  px(433, 164, "#f4c23e") rect(426, 155, 430, 158, LIT[3])
  -- sign: leaf over mortar
  rect(437, 150, 453, 161, "#2e4a34") rect(438, 151, 452, 160, "#e8ecd0")
  stamp({ "......g", "....ggg", "...gg.d", "..g..d.", "ddddddd", ".ddddd.", "..ddd.." }, 442, 152, { g = "#5a8a4a", d = "#764640" })
  -- pots with plants
  for _, x in ipairs({ 404, 410, 441, 447 }) do
    rect(x, 170, x + 4, 175, "#ad6440") rect(x, 170, x + 4, 170, "#d97e2c") px(x + 4, 174, "#83463a")
    for k = 0, 4 do px(x + k, 168 - (k % 2), "#68a050") px(x + k, 169, "#4a7a3a") end
    px(x + 2, 166, "#8cbc5c")
  end
end

------------------------------------------------------------------ syrup pipeline: shack cupola -> rooftops -> fountain
do
  local pts = { {58, 98}, {70, 62}, {203, 84}, {203, 150}, {236, 176} }
  local m = mline(Mask(), pts, 3)
  -- trestles down to the roofs
  local tr = Mask()
  for _, x in ipairs({ 100, 140, 178 }) do local y = 62 + (x - 70) * 22 / 133 mline(tr, { {x, y + 2}, {x - 3, y + 10} }, 1) mline(tr, { {x, y + 2}, {x + 3, y + 10} }, 1) end
  mline(tr, { {203, 150}, {203, 160} }, 2) mline(tr, { {219, 163}, {219, 172} }, 2)
  mfill(tr, "#58323a")
  rim(m, "#3a2232")
  local P = { "#4c2a3a", "#9a5a32", "#d97e2c", "#f2a73a", "#ffe48a" }
  meach(m, function(x, y)
    local c = P[3]
    if not mhas(m, x, y - 1) or not mhas(m, x - 1, y) then c = P[4] end
    if not mhas(m, x, y + 1) or not mhas(m, x + 1, y) then c = P[2] end
    if ((x + y) % 11) == 0 then c = P[1] end
    px(x, y, c)
  end)
  for _, p in ipairs({ {70, 62}, {203, 84}, {203, 150} }) do rect(p[1] - 2, p[2] - 2, p[1] + 2, p[2] + 2, "#47405a") px(p[1] - 1, p[2] - 1, "#848296") end
end

------------------------------------------------------------------ market square fountain with syrup barrel
do
  local outer = mpoly(Mask(), { {222,203}, {228,197}, {252,197}, {258,203}, {258,215}, {252,220}, {228,220}, {222,215} })
  rim(outer, "#3a3048")
  meach(outer, function(x, y)
    local c = STONE[4]
    if y >= 209 then c = ((x - 222) < 14) and STONE[3] or STONE[2]
      if (y - 209) % 4 == 0 or ((x + floor((y - 209) / 4) * 3) % 6 == 0) then c = STONE[1] end
    end
    if y < 209 and (not mhas(outer, x - 1, y) or not mhas(outer, x, y - 1)) then c = STONE[5] end
    px(x, y, c)
  end)
  local water = mpoly(Mask(), { {226,203}, {230,200}, {250,200}, {254,203}, {254,207}, {226,207} })
  meach(water, function(x, y)
    local c = (y <= 201) and "#56749e" or "#7ec4a0"
    if (y == 204 and (x % 7) < 3) or (y == 206 and (x % 9) > 5) then c = "#b8cce6" end
    if x > 246 and y >= 203 then c = (x % 2 == 0) and "#f2a73a" or "#d8962e" end
    px(x, y, c)
  end)
  rect(226, 208, 254, 208, STONE[5])
  -- column
  for y = 186, 205 do for x = 237, 243 do px(x, y, (x < 239) and STONE[5] or ((x > 241) and STONE[2] or STONE[3])) end end
  rect(235, 192, 245, 193, STONE[2]) rect(235, 191, 245, 191, STONE[4])
  barrel(232, 173, 248, 188)
  -- spout + syrup stream
  rect(249, 182, 251, 183, "#47405a")
  for y = 184, 203 do px(250, y, (y % 3 == 0) and "#ffcd5c" or "#d97e2c") end
  -- leaf floating
  px(232, 204, "#e0523c") px(233, 204, "#f4923a")
end

------------------------------------------------------------------ notice board with two-way sign
do
  local posts = mrect(Mask(), 41, 196, 43, 225) mrect(posts, 83, 196, 85, 225)
  local frame = mrect(Mask(), 37, 199, 89, 219)
  local roof = mpoly(Mask(), { {35, 199}, {63, 190}, {91, 199} })
  local spost = mrect(Mask(), 62, 186, 64, 191)
  local arrow = mpoly(Mask(), { {37,186}, {42,181}, {42,183}, {84,183}, {84,181}, {89,186}, {84,191}, {84,189}, {42,189}, {42,191} })
  rim(union(posts, frame, roof, spost, arrow), "#3a2232")
  part(posts, WOOD) mfill(spost, "#764640")
  part(frame, WOOD)
  for y = 201, 217 do for x = 39, 87 do px(x, y, (hash(x, y, 6) > 0.8) and "#b08c6a" or "#c09a6a") end end
  local notes = { {41,203,50,212,"#fbeedc"}, {53,202,61,209,"#f0d488"}, {64,204,73,214,"#b8cce6"}, {76,202,85,210,"#ecc4a8"}, {54,211,62,216,"#b8cc98"}, {77,212,84,216,"#fbeedc"} }
  for _, n in ipairs(notes) do
    rect(n[1], n[2], n[3], n[4], n[5]) rect(n[1] + 1, n[4], n[3], n[4], "#ad9a94")
    px(floor((n[1] + n[3]) / 2), n[2], "#b8343c")
  end
  stamp(MAP_LEAF, 42, 205, { a = "#e0523c", b = "#80223e" })
  stamp({ ".b.", "aaa", "aaa", ".a." }, 67, 207, { a = "#b8343c", b = "#5a8a4a" })
  stamp({ ".cccc.", "cdcdcc", "dddddd" }, 54, 204, { c = "#f4c23e", d = "#9a5a32" })
  for _, x in ipairs({ 78, 81 }) do px(x, 205, "#764640") px(x + 1, 205, "#764640") px(x, 207, "#764640") end
  gable(35, 91, 199, 190, RF[2])
  meach(arrow, function(x, y)
    local c = LWOOD[4]
    if y <= 184 then c = LWOOD[5] elseif y >= 188 then c = LWOOD[3] end
    if (x % 6 == 0) and y > 184 and y < 188 then c = LWOOD[3] end
    px(x, y, c)
  end)
end

------------------------------------------------------------------ orchard path: wooden arch gate + apple trees
do
  -- view through the gate: grass + tiny tree row
  local view = mrect(Mask(), 337, 192, 361, 225)
  local trees = Mask() blob(trees, 326, 192, 7, 11, 1) blob(trees, 371, 191, 7, 11, 2)
  local trunks = mrect(Mask(), 324, 200, 327, 225) mrect(trunks, 369, 200, 372, 225)
  local posts = mrect(Mask(), 333, 195, 336, 225) mrect(posts, 362, 195, 365, 225)
  local arch = mline(Mask(), { {334,197}, {335,190}, {340,185}, {349,183}, {358,185}, {363,190}, {364,197} }, 4)
  local all = union(view, trees, trunks, posts, arch)
  rim(all, "#3a2232")
  meach(view, function(x, y)
    local c = (y < 200) and "#b8cc98" or ((y < 209) and "#8cbc5c" or "#68a050")
    if y >= 199 and y <= 204 and (x % 6) < 4 then c = (y < 201) and "#5a8a4a" or "#4a7a3a" end
    if (x % 6) == 1 and y == 199 then c = "#b8343c" end
    if y > 210 and abs(x - 349) < (y - 205) / 3 then c = "#d8b878" end
    px(x, y, c)
  end)
  part(trunks, WOOD)
  meach(trees, function(x, y)
    local k = (x < 349) and { 326, 192 } or { 371, 191 }
    local L = 0.55 - ((x - k[1]) / 7 * 0.5 + (y - k[2]) / 11 * 0.6) * 0.5 + (hash(floor(x / 2), floor(y / 2), 9) - 0.5) * 0.3
    local c = GREEN[clamp(floor(L * 5) + 1, 1, 5)]
    if hash(x, y, 8) > 0.9 then c = "#d8b878" end
    px(x, y, c)
  end)
  for _, p in ipairs({ {323,188}, {328,195}, {324,199}, {329,187}, {368,186}, {373,193}, {369,197}, {374,188} }) do
    px(p[1], p[2], "#b8343c") px(p[1] + 1, p[2], "#b8343c") px(p[1], p[2] + 1, "#80223e") px(p[1] + 1, p[2] + 1, "#b8343c") px(p[1], p[2], "#f88a52")
  end
  part(posts, LWOOD)
  meach(arch, function(x, y)
    local c = LWOOD[3]
    if not mhas(arch, x, y - 1) then c = LWOOD[5] elseif not mhas(arch, x, y + 1) then c = LWOOD[2] end
    if hash(x, y, 4) > 0.8 then c = "#68a050" end
    px(x, y, c)
  end)
  -- hanging apple sign under the apex
  px(346, 187, "#3a2232") px(352, 187, "#3a2232")
  rect(344, 188, 354, 194, "#3a2232") rect(345, 189, 353, 193, "#e8dcc2")
  stamp({ "..b..", ".aaa.", ".aaa." }, 347, 190, { a = "#b8343c", b = "#5a8a4a" }) px(348, 191, "#f88a52")
  -- half-open picket gates
  for _, g in ipairs({ { 337, 343 }, { 355, 361 } }) do
    for x = g[1], g[2] do if (x - g[1]) % 3 ~= 2 then
      local top = 207 - (((x - g[1]) % 3 == 0) and 1 or 0)
      for y = top, 224 do px(x, y, (x % 3 == 0) and "#d8b878" or "#c09a6a") end
      px(x, top, "#f0d488")
    end end
    rect(g[1], 211, g[2], 211, "#9a5a32") rect(g[1], 220, g[2], 220, "#9a5a32")
  end
  -- basket of apples
  rect(366, 220, 375, 225, "#3a2232") rect(367, 221, 374, 224, "#a07a58") rect(367, 222, 374, 222, "#764640")
  for k = 0, 3 do px(367 + k * 2, 219, "#b8343c") px(368 + k * 2, 219, "#e0523c") end
end

------------------------------------------------------------------ leaf pile + puddle (front ground)
do
  local pile = mpoly(Mask(), { {0,269}, {1,254}, {8,246}, {18,243}, {28,248}, {33,258}, {35,269} })
  rim(pile, "#58323a")
  meach(pile, function(x, y)
    local L = 0.6 - (y - 243) / 30 + (hash(floor(x / 2), floor(y / 2), 3) - 0.5) * 0.6 - x * 0.006
    local R = MAPLE[1 + floor(hash(floor(x / 2), floor(y / 2), 4) * 3)]
    px(x, y, R[clamp(floor(L * 4) + 3, 2, 6)])
  end)
  local pud = mpoly(Mask(), { {182,251}, {190,247}, {212,247}, {224,250}, {217,255}, {194,256} })
  rim(pud, "#56749e")
  meach(pud, function(x, y)
    local c = (y < 251) and "#b8cce6" or "#9ccaec"
    if y == 253 and x > 196 and x < 212 then c = "#f2a73a" end
    if y == 252 and x > 200 and x < 206 then c = "#f88a52" end
    px(x, y, c)
  end)
  px(214, 250, "#e0523c") px(215, 250, "#f4923a")
end

------------------------------------------------------------------ gate frame (beam, posts, stone pillars), lanterns, bunting
do
  local beam = mrect(Mask(), 0, 0, 479, 15)
  meach(beam, function(x, y)
    local c = WOOD[3]
    if y <= 1 then c = WOOD[4] elseif y >= 13 then c = WOOD[2] end
    if y == 15 then c = WOOD[1] end
    if hash(floor(x / 7), y, 2) > 0.82 and y > 2 and y < 13 then c = WOOD[2] end
    if (x % 40 == 20) and (y == 7 or y == 8) then c = "#f4c23e" end
    px(x, y, c)
  end)
  rect(221, 2, 259, 13, "#4a1838") rect(222, 3, 258, 12, "#cc5840") rect(222, 3, 258, 3, "#e67a4c")
  stamp(MAP_LEAF, 237, 4, { a = "#f4c23e", b = "#9a5a32" }) px(238, 5, "#ffe48a")
  for _, s in ipairs({ { 0, 15 }, { 464, 479 } }) do
    for y = 16, 107 do for x = s[1], s[2] do
      local u = x - s[1]
      local c = (u < 4) and WOOD[4] or ((u < 11) and WOOD[3] or WOOD[2])
      if hash(u, floor(y / 6), 5) > 0.85 then c = WOOD[2] end
      if u == 15 or (s[1] > 0 and u == 0) then c = WOOD[1] end
      px(x, y, c)
    end end
  end
  for _, b in ipairs({ { {14,46}, {42,15} }, { {465,46}, {437,15} } }) do
    local m = mline(Mask(), b, 4) rim(m, WOOD[1]) part(m, WOOD)
  end
  -- stone pillars
  for _, s in ipairs({ { 0, 18, 0, 21 }, { 461, 479, 458, 479 } }) do
    local pil = mrect(Mask(), s[1], 108, s[2], 231)
    local cap = mrect(Mask(), s[3], 103, s[4], 108)
    local pl = mrect(Mask(), s[3], 224, s[4], 231)
    rim(union(pil, cap, pl), "#2f2c46")
    meach(pil, function(x, y)
      local row = floor((y - 108) / 7)
      local off = (row % 2 == 0) and 0 or 5
      local c = ((x - s[1]) < 7) and COOL[7] or COOL[5]
      if hash(floor((x - s[1] + off) / 10), row, 3) > 0.7 then c = ((x - s[1]) < 7) and COOL[8] or COOL[6] end
      if (y - 108) % 7 == 0 or (x - s[1] + off) % 10 == 0 then c = COOL[2] end
      if (y - 108) % 7 == 1 and (x - s[1] + off) % 10 ~= 0 then c = COOL[8] end
      if hash(x, y, 1) > 0.97 then c = "#5a8a4a" end
      px(x, y, c)
    end)
    part(cap, { "#3a3048", "#8a7a80", "#bfaea6", "#e0cfbe", "#fbeedc" })
    part(pl, { "#3a3048", "#766676", "#9a8a8e", "#bfaea6", "#cdb8a8" })
  end
  -- hanging lanterns
  for _, lx in ipairs({ 108, 372 }) do
    for y = 16, 40 do if y % 2 == 0 then px(lx, y, "#3a2232") end end
    rect(lx - 4, 41, lx + 4, 42, "#3a2232") rect(lx - 3, 43, lx + 3, 51, "#3a2232")
    rect(lx - 2, 44, lx + 2, 50, LIT[3]) rect(lx - 2, 44, lx - 1, 46, LIT[5]) px(lx, 44, "#3a2232") px(lx, 45, "#3a2232")
    for y = 44, 50 do px(lx, y, (y < 47) and LIT[4] or LIT[2]) end
    rect(lx - 2, 52, lx + 2, 52, "#3a2232")
  end
  -- mitten-and-leaf bunting
  local function string(x0, y0, x1, y1, sag, seed)
    local n = 0
    for x = x0, x1 do
      local t = (x - x0) / (x1 - x0)
      local y = floor(y0 + (y1 - y0) * t + sag * 4 * t * (1 - t) + 0.5)
      px(x, y, "#3a2232")
      if (x - x0) % 12 == 6 and x - x0 > 3 and x1 - x > 3 then
        n = n + 1
        if n % 2 == 1 then
          local col = ({ "#b8343c", "#3a7a6a", "#9a6286", "#d97e2c" })[(floor(n / 2) + seed) % 4 + 1]
          stamp({ ".aaa", ".aaa", "aaaa", "aaaa", ".aaa", ".ccc" }, x - 2, y + 1, { a = col, c = "#fbeedc" })
          px(x - 1, y + 1, "#fbeedc")
        else
          local R = MAPLE[(n + seed) % 3 + 1]
          stamp({ "..a..", "aaaaa", ".aaa.", "aaaaa", "..b.." }, x - 2, y + 1, { a = R[4], b = R[1] })
          px(x - 1, y + 2, R[6])
        end
      end
    end
  end
  string(16, 18, 206, 22, 16, 0)
  string(274, 22, 463, 18, 16, 1)
end

------------------------------------------------------------------ write out
local c = HP.canvas{ w = W, h = H, scale = 1, name = "here-market-maplewold-v4" }
for y = 0, H - 1 do for x = 0, W - 1 do local col = B[y*W+x+1] if col then c:px(x, y, col) end end end
c:finish{ outline = false }
HP.assertClean(c)
c:save{ aseprite = OUT .. "here-market-maplewold-v4.aseprite", png = OUT .. "here-market-maplewold-v4.png", scale = 1 }
print("ok v4")
