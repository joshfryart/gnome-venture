-- Hearth Pop v3: grassland road rest stop, gate view (480x270 native), one-point perspective, VP (240,112)
local HP = dofile("/home/user/gnome-venture/aseprite-source/v3/lib/hp.lua")
local OUT = app.params.out or "/home/user/gnome-venture/aseprite-source/v3/here-gate/"
if OUT:sub(-1) ~= "/" then OUT = OUT .. "/" end
local NAME = "here-stop-grassland-m"
local W, H, HZ, VX, F = 480, 270, 112, 240, 240
local c = HP.canvas{ w = W, h = H, scale = 1, name = NAME }
local floor, abs, sin, cos, sqrt, max, min = math.floor, math.abs, math.sin, math.cos, math.sqrt, math.max, math.min

local function hash(x, y, s) local n = sin(x * 12.9898 + y * 78.233 + (s or 0) * 37.719) * 43758.5453 return n - floor(n) end
local function put(x, y, col) x, y = floor(x), floor(y) if col and x >= 0 and y >= 0 and x < W and y < H then c:put(x, y, col) end end
local function R(x0, y0, x1, y1, col) for y = floor(y0), floor(y1) do for x = floor(x0), floor(x1) do put(x, y, col) end end end
local function FM(m, col) m:each(function(x, y) put(x, y, col) end) end
local function poly(pts) local q = {} for i, p in ipairs(pts) do q[i] = { floor(p[1] + 0.5), floor(p[2] + 0.5) } end return c:poly(q) end
local function line(pts, w, col) FM(c:line(pts, w or 1), col) end
local function P(X, Y, Z) return VX + X * F / Z, HZ + (1 - Y) * F / Z end
local function edgeIn(m, col) FM(m:edge(), col) end
local function oct(cx, cy, r)
  local p = {} for k = 0, 7 do local a = (k * 45 + 22.5) * math.pi / 180 p[#p + 1] = { cx + r * cos(a), cy + r * sin(a) } end return poly(p)
end

-- wall plane X = const, Z in [za,zb], Y in [ya,yb]; fn(Z,Y,sx,sy,pz,py) -> colour
local function wall(X, za, zb, ya, yb, fn)
  local xs, ys = {}, {}
  for _, z in ipairs{ za, zb } do for _, yy in ipairs{ ya, yb } do local sx, sy = P(X, yy, z) xs[#xs + 1] = sx ys[#ys + 1] = sy end end
  local x0, x1 = max(0, floor(min(table.unpack(xs)))), min(W - 1, floor(max(table.unpack(xs))) + 1)
  local y0, y1 = max(0, floor(min(table.unpack(ys)))), min(H - 1, floor(max(table.unpack(ys))) + 1)
  for sy = y0, y1 do for sx = x0, x1 do
    local a = sx + 0.5 - VX
    if abs(a) > 0.01 then
      local Z = X * F / a
      if Z >= za and Z <= zb then
        local Y = 1 - (sy + 0.5 - HZ) * Z / F
        if Y >= ya and Y <= yb then
          put(sx, sy, fn(Z, Y, sx, sy, abs(X) * F / (Z * Z), F / Z))
        end
      end
    end
  end end
end
-- sloped roof plane from eave (Xe,Ye) to ridge (Xr,Yr) along Z; fn(Z,t,sx,sy)
local function roof(Xe, Ye, Xr, Yr, za, zb, fn)
  local xs, ys = {}, {}
  for _, z in ipairs{ za, zb } do for _, p in ipairs{ { Xe, Ye }, { Xr, Yr } } do local sx, sy = P(p[1], p[2], z) xs[#xs + 1] = sx ys[#ys + 1] = sy end end
  local x0, x1 = max(0, floor(min(table.unpack(xs)))), min(W - 1, floor(max(table.unpack(xs))) + 1)
  local y0, y1 = max(0, floor(min(table.unpack(ys)))), min(H - 1, floor(max(table.unpack(ys))) + 1)
  local dX, dY = Xr - Xe, Yr - Ye
  for sy = y0, y1 do for sx = x0, x1 do
    local a, b = sx + 0.5 - VX, HZ - (sy + 0.5)
    local den = a * dY - b * dX
    if abs(den) > 1e-6 then
      local t = (b * Xe - a * (Ye - 1)) / den
      if t >= 0 and t <= 1 then
        local X = Xe + t * dX
        local Z = abs(a) > 0.01 and X * F / a or (Ye + t * dY - 1) * F / b
        if Z >= za and Z <= zb then put(sx, sy, fn(Z, t, sx, sy)) end
      end
    end
  end end
end

---------------------------------------------------------------- sky
c:stripes(0, 112, { "#8fb3da", "#a6c2e2", "#c2cfe2", "#e2d6c6", "#f2d8b0", "#f8e2ac" }, { 3, 3, 3, 3, 3, 2 })
c:cloud(146, 44, 36, "#fbeedc", "#e2c8c8")
c:cloud(322, 30, 28, "#fbeedc", "#e2c8c8")
c:cloud(196, 18, 22, "#fbeedc", "#e2c8c8")
-- far rolling hills (haze then gold)
c:terrain(function(x) return floor(98 + 4 * sin(x / 31) + 3 * sin(x / 11 + 1)) end, "#dcc4a0", 112)
c:terrain(function(x) return floor(104 + 3 * sin(x / 23 + 2) + 2 * sin(x / 9)) end, "#e4bc6a", 112)
for x = 0, W - 1 do if hash(x, 7, 2) > 0.7 then put(x, floor(104 + 3 * sin(x / 23 + 2) + 2 * sin(x / 9)) + 2, "#f2d488") end end

---------------------------------------------------------------- windmill (far, behind oak/trader)
do
  local tower = poly{ { 302, 108 }, { 316, 108 }, { 314, 58 }, { 304, 58 } }
  FM(tower, "#ecdcbc")
  tower:each(function(x, y) if x >= 312 then put(x, y, "#c8b0a8") elseif x <= 304 then put(x, y, "#f8ecd0") end end)
  edgeIn(tower, "#9a7a74")
  R(307, 70, 310, 76, "#8a6060")
  local cap = poly{ { 301, 59 }, { 317, 59 }, { 309, 50 } } FM(cap, "#a8503c") edgeIn(cap, "#6e3034")
  local hx, hy = 309, 55
  for k = 0, 3 do
    local a = (25 + k * 90) * math.pi / 180
    local ex, ey = hx + 24 * cos(a), hy + 24 * sin(a)
    local px, py = -sin(a), cos(a)
    local sail = poly{ { hx + 5 * cos(a), hy + 5 * sin(a) }, { ex, ey }, { ex + 4 * px, ey + 4 * py }, { hx + 5 * cos(a) + 4 * px, hy + 5 * sin(a) + 4 * py } }
    FM(sail, "#f4e6c8") edgeIn(sail, "#a88470")
    line({ { hx, hy }, { floor(ex), floor(ey) } }, 1, "#7a5040")
  end
  R(308, 54, 310, 56, "#6e3a30")
end

---------------------------------------------------------------- ground
local FL = { j = "#7e6a64", a = "#c9b49a", b = "#bca78e", c = "#d6c4a6", hi = "#e8d8b8" }
local FS = { j = "#5c4e66", a = "#a0929e", b = "#958898", c = "#ab9eaa", hi = "#bcb0be" }
local DL = { a = "#cfa070", rut = "#ad8256", hi = "#e2bc88", peb = "#b8946c" }
local DS = { a = "#a68a8a", rut = "#8a7080", hi = "#b8a0a0", peb = "#9a8290" }
local SL = { a = "#dcc296", b = "#d4b88c", hi = "#ead4a8", tuft = "#b8a050" }
local SS = { a = "#b4a2a6", b = "#aa98a2", hi = "#c4b4b4", tuft = "#8a8a6a" }
local GL = { a = "#cba84c", b = "#d8b85a", c = "#e2c466", sh = "#a88a40", d = "#8a6e3a" }
local function stone(X, Z, sz, rowH, T)
  local r = floor(Z / rowH) local fz = Z / rowH - r
  local u = X / sz + (r % 2) * 0.5 local cu = floor(u) local fu = u - cu
  local pX, pZ = F / Z * sz, F / (Z * Z) * rowH
  if fu * pX < 1 or fz * pZ < 1 then return T.j end
  if fu * pX < 2.2 or (1 - fz) * pZ < 1.5 then return T.hi end
  local h = hash(cu, r, 5)
  return h < 0.33 and T.a or (h < 0.66 and T.b or T.c)
end
local function groundCol(X, Z, sx, sy)
  local sh = Z < 4.75 and X < -0.85 and not (Z > 3.28 and Z < 3.86)
  if Z < 4.75 and abs(X) <= 0.6 then
    if Z < 3.7 then return stone(X, Z, 0.3, 0.24, sh and FS or FL) end
    local T = sh and DS or DL
    if abs(abs(X) - 0.28) * F / Z < 1.6 then return T.rut end
    local h = hash(sx, sy, 7) if h > 0.94 then return T.hi elseif h < 0.05 then return T.peb end
    return T.a
  end
  if Z < 4.75 and abs(X) <= 2.05 then
    if abs(abs(X) - 0.6) * F / Z < 1.3 then return sh and FS.j or FL.j end
    local T = sh and SS or SL
    local h = hash(floor(sx / 2), floor(sy / 2), 9)
    if h > 0.9 then return T.hi elseif h < 0.05 then return T.tuft end
    return h < 0.5 and T.a or T.b
  end
  if Z >= 4.75 and Z < 7.0 and abs(X) < 4.5 then return stone(X, Z, 0.55, 0.5, FL) end
  if Z >= 7.0 and Z < 11.6 and abs(X) <= 0.45 then
    local h = hash(sx, sy, 7) if h > 0.9 then return DL.hi end return DL.a
  end
  local h = hash(sx, floor(sy / 2), 11)
  if Z > 8.5 then
    local b = floor(Z * 0.8) % 3
    if h > 0.86 then return GL.sh end
    return b == 0 and GL.a or (b == 1 and GL.b or GL.c)
  end
  if h > 0.88 then return GL.c elseif h < 0.1 then return GL.sh elseif h < 0.14 then return GL.d end
  return GL.a
end
for sy = HZ + 1, H - 1 do
  local Z = F / (sy + 0.5 - HZ)
  for sx = 0, W - 1 do put(sx, sy, groundCol((sx + 0.5 - VX) * Z / F, Z, sx, sy)) end
end
-- wheat tufts on far field
for i = 0, 140 do
  local x, y = floor(hash(i, 1, 3) * 480), 113 + floor(hash(i, 2, 3) * 14)
  if abs(x - 240) > 20 then put(x, y, "#f0d27a") put(x, y - 1, "#e8c060") end
end

---------------------------------------------------------------- great oak (landmark)
do
  local trunk = poly{ { 231, 136 }, { 249, 136 }, { 245, 124 }, { 244, 96 }, { 237, 96 }, { 236, 124 } }
  FM(trunk, "#6a4636")
  trunk:each(function(x, y) if x <= 238 then put(x, y, "#8a6248") elseif x >= 243 then put(x, y, "#4e3434") end
    if hash(x, floor(y / 3), 4) > 0.8 then put(x, y, "#4e3434") end end)
  edgeIn(trunk, "#3e2a30")
  line({ { 240, 100 }, { 214, 76 } }, 3, "#5a3c34") line({ { 241, 100 }, { 268, 74 } }, 3, "#5a3c34")
  local can = HP.mask()
  for _, b in ipairs{ { 240, 62, 46, 30 }, { 204, 72, 20, 15 }, { 276, 70, 22, 16 }, { 224, 40, 24, 17 }, { 258, 36, 24, 17 },
                      { 240, 26, 18, 10 }, { 196, 54, 14, 12 }, { 286, 50, 12, 12 } } do can:add(c:ellipse(b[1], b[2], b[3], b[4])) end
  local cut = HP.mask() can:edge():each(function(x, y) if hash(x, y, 21) > 0.55 then cut:set(x, y) end end) can:cut(cut)
  -- holes showing branches
  local ramp = { "#2e5a40", "#3f7a44", "#5a9a46", "#82b650", "#b4d266" }
  local cw, ch = 9, 7
  can:each(function(x, y)
    local ry = floor(y / ch) local ox = (ry % 2) * 4
    local cx = floor((x + ox) / cw)
    local lx, ly = (x + ox) - cx * cw - cw / 2, y - ry * ch - ch / 2
    local g = -(x - 230) / 70 * 0.5 - (y - 56) / 40 * 0.6
    local v = 0.5 * g - 0.45 * (lx / cw + ly / ch) + (hash(cx, ry, 13) - 0.5) * 0.5
    local i = v < -0.45 and 1 or (v < -0.12 and 2 or (v < 0.18 and 3 or (v < 0.45 and 4 or 5)))
    if ly > ch / 2 - 1.2 and i > 1 then i = i - 1 end
    local col = ramp[i]
    if hash(x, y, 31) > 0.975 then col = "#e0b040" end
    put(x, y, col)
  end)
  edgeIn(can, "#24443a")
  -- kite caught in the oak
  local k1 = poly{ { 284, 14 }, { 292, 25 }, { 284, 25 } } FM(k1, "#e8493b")
  local k2 = poly{ { 284, 14 }, { 284, 25 }, { 276, 25 } } FM(k2, "#ff8a5c")
  local k3 = poly{ { 276, 25 }, { 292, 25 }, { 284, 38 } } FM(k3, "#f5b82e")
  local kite = k1:copy():add(k2):add(k3) edgeIn(kite, "#6e2038")
  line({ { 284, 15 }, { 284, 37 } }, 1, "#8f4a1f") line({ { 277, 25 }, { 291, 25 } }, 1, "#8f4a1f")
  local tail = { { 284, 38 }, { 287, 43 }, { 285, 48 }, { 289, 53 }, { 293, 56 }, { 297, 62 } }
  for i = 1, #tail - 1 do line({ tail[i], tail[i + 1] }, 1, "#6e2038") end
  for i, p in ipairs{ { 287, 43 }, { 289, 53 }, { 297, 62 } } do
    local col = ({ "#5fc4c8", "#f5809f", "#7cc35a" })[i]
    put(p[1] - 1, p[2], col) put(p[1] + 1, p[2], col) put(p[1] - 1, p[2] + 1, col) put(p[1] + 1, p[2] - 1, col)
  end
end

---------------------------------------------------------------- plaza: long-table pavilion  [154,58,200,158]
do
  for _, px in ipairs{ 159, 177, 195 } do R(px, 92, px + 2, 156, "#8a5a38") R(px, 92, px, 156, "#b07a48") R(px + 2, 92, px + 2, 156, "#5e3a2c") end
  R(158, 93, 198, 96, "#5a4058")
  local rf = poly{ { 154, 93 }, { 200, 93 }, { 192, 70 }, { 162, 70 } }
  local gb = poly{ { 165, 71 }, { 189, 71 }, { 177, 58 } }
  rf:add(gb)
  rf:each(function(x, y)
    local col = "#3a9a98"
    if (y - 58) % 5 == 0 then col = "#2a7276" elseif x < 170 and y < 85 then col = "#6cc4b8" elseif x > 186 then col = "#2f8284" end
    if (y - 58) % 5 ~= 0 and (x + floor((y - 58) / 5) * 3) % 7 == 0 then col = "#2a7276" end
    put(x, y, col)
  end)
  edgeIn(rf, "#1e4e56")
  -- lantern under roof
  R(177, 97, 177, 99, "#51302b") R(175, 100, 179, 105, "#8f4a1f") R(176, 101, 178, 104, "#ffe38a")
  -- table top + checked cloth
  R(158, 128, 198, 130, "#b97a4a") R(158, 128, 198, 128, "#e8b982")
  for y = 131, 138 do for x = 158, 198 do
    local ch = (floor((x - 158) / 3) + floor((y - 131) / 3)) % 2 == 0
    put(x, y, ch and "#e8493b" or "#f4e2c8")
  end end
  R(158, 138, 198, 138, "#b52e3f")
  R(161, 139, 162, 150, "#51302b") R(194, 139, 195, 150, "#51302b")
  -- benches
  R(156, 146, 200, 148, "#b97a4a") R(156, 146, 200, 146, "#e8b982") R(156, 148, 200, 148, "#864c33")
  R(158, 149, 159, 154, "#51302b") R(197, 149, 198, 154, "#51302b")
  -- bread loaves, jam, cups
  for _, bx in ipairs{ 161, 183 } do
    local loaf = c:rrect(bx, 122, bx + 8, 127, 2) FM(loaf, "#d98322")
    R(bx + 1, 123, bx + 3, 123, "#ffe38a") R(bx + 2, 125, bx + 2, 126, "#8f4a1f") R(bx + 5, 124, bx + 5, 125, "#8f4a1f")
    edgeIn(loaf, "#8f4a1f")
  end
  R(173, 121, 177, 127, "#b52e3f") R(174, 122, 175, 125, "#e8493b") R(173, 120, 177, 120, "#f4e2c8") R(174, 122, 174, 122, "#ffc4d8")
  for _, cx in ipairs{ 170, 180, 194 } do R(cx, 124, cx + 2, 127, "#3a86b0") R(cx, 124, cx, 125, "#b6f0e0") R(cx + 3, 125, cx + 3, 126, "#3a86b0") end
end

---------------------------------------------------------------- plaza: wishing well  [212,80,236,160]
do
  local body = c:rect(214, 136, 234, 157)
  body:each(function(x, y)
    local r = floor((y - 136) / 4) local u = (x - 214 + (r % 2) * 3)
    local col = "#aaa9b8"
    if (y - 136) % 4 == 3 or u % 6 == 5 then col = "#5a5a74"
    elseif x >= 229 then col = "#7e7f96" elseif x <= 218 and (y - 136) % 4 == 0 then col = "#c8c6d4" end
    put(x, y, col)
  end)
  edgeIn(body, "#444663")
  R(213, 132, 235, 135, "#c8c6d4") R(213, 135, 235, 135, "#74758c") R(216, 133, 232, 134, "#2e2a44")
  R(215, 96, 216, 132, "#864c33") R(215, 96, 215, 132, "#b97a4a") R(232, 96, 233, 132, "#864c33") R(232, 96, 232, 132, "#b97a4a")
  R(216, 103, 232, 104, "#51302b") R(234, 102, 236, 103, "#51302b") R(236, 104, 236, 107, "#51302b")
  R(224, 105, 224, 116, "#d98322")
  local bucket = poly{ { 220, 117 }, { 228, 117 }, { 227, 124 }, { 221, 124 } } FM(bucket, "#b97a4a")
  R(220, 119, 228, 119, "#444663") R(221, 118, 222, 118, "#e8b982") edgeIn(bucket, "#51302b")
  local rf = poly{ { 211, 98 }, { 237, 98 }, { 230, 87 }, { 218, 87 } } rf:add(poly{ { 218, 88 }, { 230, 88 }, { 224, 80 } })
  rf:each(function(x, y)
    local col = "#5a62c0"
    if (y - 80) % 4 == 3 then col = "#3e4490" elseif x < 220 and y < 94 then col = "#8a90e0" elseif x > 230 then col = "#4a50a8" end
    put(x, y, col)
  end)
  edgeIn(rf, "#2a2c6a")
end

---------------------------------------------------------------- plaza: notice board gable  [248,48,280,158]
do
  R(251, 70, 253, 156, "#5e3a2c") R(251, 70, 251, 156, "#864c33") R(275, 70, 277, 156, "#5e3a2c") R(275, 70, 275, 156, "#864c33")
  local rf = poly{ { 247, 73 }, { 281, 73 }, { 264, 50 } }
  rf:each(function(x, y)
    local col = "#c0503a"
    if (y - 50) % 4 == 3 then col = "#8e3434" elseif x < 262 and y < 66 then col = "#e87a5a" elseif x > 270 then col = "#a84038" end
    put(x, y, col)
  end)
  edgeIn(rf, "#5e2430")
  R(259, 62, 269, 64, "#5e3a2c") R(260, 63, 268, 63, "#f5b82e")
  local brd = c:rect(249, 74, 279, 128)
  FM(brd, "#5a3a2a") R(249, 74, 279, 74, "#864c33")
  for y = 76, 126 do for x = 251, 277 do put(x, y, hash(x, y, 41) > 0.85 and "#9a6a3a" or "#b8844a") end end
  edgeIn(brd, "#3a2228")
  local papers = { { 253, 78, 259, 87, "#f6e8c8" }, { 262, 77, 270, 84, "#ffc4d8" }, { 272, 79, 276, 89, "#b9e2f5" },
                   { 253, 91, 261, 99, "#ffe38a" }, { 264, 88, 275, 97, "#f6e8c8" }, { 253, 103, 258, 111, "#b6f0e0" },
                   { 261, 101, 268, 110, "#f6e8c8" }, { 271, 100, 276, 107, "#ffc4d8" }, { 255, 114, 263, 123, "#f6e8c8" },
                   { 267, 112, 275, 123, "#c4e07a" } }
  for _, p in ipairs(papers) do
    R(p[1], p[2], p[3], p[4], p[5]) R(p[3], p[2] + 1, p[3], p[4], "#b8a088") R(p[1] + 1, p[4], p[3], p[4], "#b8a088")
    for yy = p[2] + 2, p[4] - 2, 2 do R(p[1] + 1, yy, p[3] - 2, yy, "#8a7a8a") end
    put(floor((p[1] + p[3]) / 2), p[2], "#e8493b")
  end
end

---------------------------------------------------------------- plaza: trader wagon  [294,80,324,160]
do
  local hood = poly{ { 296, 132 }, { 296, 104 }, { 300, 96 }, { 308, 93 }, { 316, 96 }, { 320, 104 }, { 320, 132 } }
  hood:each(function(x, y) put(x, y, x > 315 and "#d0bca0" or (x < 300 and y < 110 and "#fff2d4" or "#f2e2c0")) end)
  for _, hx in ipairs{ 301, 308, 315 } do R(hx, 96, hx, 131, "#a88a6a") end
  edgeIn(hood, "#8a6a5a")
  R(314, 84, 315, 94, "#444663")
  local aw = poly{ { 294, 108 }, { 324, 108 }, { 324, 119 }, { 294, 119 } }
  aw:each(function(x, y) put(x, y, floor((x - 294) / 4) % 2 == 0 and "#e04a3a" or "#f6e8c8") end)
  for x = 294, 324 do if (x - 294) % 4 < 2 then put(x, 120, floor((x - 294) / 4) % 2 == 0 and "#b52e3f" or "#d8c8a8") end end
  R(294, 108, 324, 108, "#b52e3f") edgeIn(aw, "#6e2038")
  R(298, 122, 318, 131, "#51302b")
  for i, gx in ipairs{ 299, 305, 311 } do
    R(gx, 125, gx + 4, 131, "#b97a4a") R(gx, 125, gx + 4, 125, "#e8b982")
    local col = ({ "#e8493b", "#f5b82e", "#7cc35a" })[i]
    put(gx + 1, 124, col) put(gx + 3, 124, col) put(gx + 2, 123, col) put(gx + 1, 123, "#ffe38a")
  end
  R(316, 123, 318, 128, "#5fc4c8") R(316, 123, 316, 124, "#b6f0e0")
  local body = c:rect(295, 132, 321, 145)
  body:each(function(x, y) put(x, y, (y - 132) % 4 == 3 and "#963436" or (x > 316 and "#a83c3a" or "#c84a3a")) end)
  R(295, 132, 321, 132, "#e8785a") R(296, 138, 320, 138, "#f5b82e") edgeIn(body, "#5e2430")
  for _, wx in ipairs{ 301, 315 } do
    local wh = oct(wx, 150, 6) FM(wh, "#864c33") FM(oct(wx, 150, 4), "#b97a4a") FM(oct(wx, 150, 3), "#864c33")
    line({ { wx - 4, 150 }, { wx + 4, 150 } }, 1, "#51302b") line({ { wx, 146 }, { wx, 154 } }, 1, "#51302b")
    R(wx - 1, 149, wx, 150, "#f5b82e") edgeIn(wh, "#51302b")
  end
end

---------------------------------------------------------------- left mid wall: SEED SHOP (X=-2, Z 3.95-4.7)  [118,30,146,184]
roof(-1.9, 2.3, -3.3, 3.5, 3.9, 4.75, function(Z, t, sx, sy)
  if t < 0.05 then return "#5e2a30" end
  if (t * 9) % 1 < 0.2 then return "#7a3434" end
  return hash(floor(Z * 20), floor(t * 9), 3) > 0.7 and "#a85240" or "#8e4038"
end)
wall(-2, 3.95, 4.7, 0, 2.3, function(Z, Y, sx, sy, pz, py)
  if (Z - 3.95) * pz < 1 or (4.7 - Z) * pz < 1 or (2.3 - Y) * py < 1 then return "#24382e" end
  if Y < 0.2 then return ((Z * 10) % 1) * pz / 10 < 1 and "#4a5450" or "#7a8478" end
  if Z > 3.99 and Z < 4.17 and Y < 1.05 then
    if Z < 4.01 or Z > 4.15 or Y > 1.01 then return "#c8b880" end
    if abs(Z - 4.12) * pz < 1 and abs(Y - 0.55) * py < 1 then return "#f5b82e" end
    return "#24382e"
  end
  if Z > 4.24 and Z < 4.62 and Y > 0.5 and Y < 1.06 then
    if (Z - 4.24) * pz < 1.5 or (4.62 - Z) * pz < 1.5 or (Y - 0.5) * py < 1.5 or (1.06 - Y) * py < 1.5 then return "#c8b880" end
    local cols = { "#f5809f", "#f5b82e", "#5fc4c8", "#e8493b", "#c4e07a", "#c9b2f0" }
    local cx, cy = floor(sx / 3), floor(sy / 4)
    if sy % 4 == 3 then return "#ffd36a" end
    return cols[1 + floor(hash(cx, cy, 8) * 6)]
  end
  if Z > 4.22 and Z < 4.64 and Y > 0.34 and Y <= 0.5 then
    if Y > 0.44 then return hash(sx, sy, 2) > 0.5 and "#7cc35a" or "#c4e07a" end
    return Y > 0.42 and "#d26a46" or "#a84a32"
  end
  if Y > 1.12 and Y < 1.2 then return "#3a3a30" end
  if Y >= 1.2 then
    for _, zw in ipairs{ { 4.05, 4.24 }, { 4.42, 4.6 } } do
      if Z > zw[1] and Z < zw[2] and Y > 1.45 and Y < 1.9 then
        if (Z - zw[1]) * pz < 1.2 or (zw[2] - Z) * pz < 1.2 or (Y - 1.45) * py < 1.2 or (1.9 - Y) * py < 1.2 or abs(Y - 1.67) * py < 0.6 then return "#3a3a30" end
        return Y > 1.75 and "#fff0a8" or "#ffd36a"
      end
    end
    for _, zp in ipairs{ 3.97, 4.33, 4.68 } do if abs(Z - zp) * pz < 1.5 then return "#3a3a30" end end
    if Y < 1.9 and abs((Z - 4.33) / 0.35 - (Y - 1.2) / 0.7) * pz * 0.35 < 1.2 and Z > 4.33 and Y > 1.9 then return "#3a3a30" end
    return hash(sx, sy, 6) > 0.9 and "#d8dab0" or "#bcc496"
  end
  -- green boards
  if ((Z * 9) % 1) * pz / 9 < 1 then return "#2f5e44" end
  return hash(sx, floor(sy / 3), 5) > 0.85 and "#5a9a64" or "#3e7a52"
end)
do -- seed shop hanging sign (face-on) with sprout icon + chimney smoke
  line({ { 118, 82 }, { 142, 82 } }, 1, "#3a3a30")
  R(124, 82, 124, 85, "#3a3a30") R(140, 82, 140, 85, "#3a3a30")
  local s = c:rect(122, 85, 142, 101) FM(s, "#f2e2b8") edgeIn(s, "#24544a")
  R(131, 91, 132, 98, "#3f9150") R(127, 97, 136, 98, "#864c33")
  local l1 = poly{ { 131, 92 }, { 126, 88 }, { 124, 91 }, { 128, 93 } } FM(l1, "#7cc35a")
  local l2 = poly{ { 132, 91 }, { 137, 87 }, { 140, 89 }, { 135, 92 } } FM(l2, "#7cc35a")
  put(126, 89, "#c4e07a") put(136, 88, "#c4e07a")
  R(119, 22, 124, 34, "#8e4038") R(119, 22, 120, 34, "#a85240") R(118, 21, 125, 22, "#5e2a30")
end

---------------------------------------------------------------- right mid wall: WILD TRAIL hedge arch (X=2, Z 3.75-4.65)  [336,58,370,184]
wall(2, 3.75, 4.65, 0, 1.75, function(Z, Y, sx, sy, pz, py)
  local top = 1.6 + 0.08 * sin(Z * 47)
  if Y > top then return nil end
  local dz = (Z - 4.2) / 0.22
  if abs(dz) < 1 then
    local ay = 0.85 + 0.3 * sqrt(1 - dz * dz)
    if Y < ay then
      if (ay - Y) * py < 1.3 then return hash(sx, sy, 3) > 0.5 and "#f5809f" or "#ffc4d8" end
      if Y < 0.14 then return "#e8c48a" end
      if Y < 0.5 then return hash(sx, sy, 4) > 0.75 and "#e2a83c" or "#f2cc66" end
      if Y < 0.56 then return "#d8c890" end
      return Y > 0.8 and "#bcd2e6" or "#f8e2ac"
    end
  end
  if (top - Y) * py < 1 or (Z - 3.75) * pz < 1 then return "#24504a" end
  local cx = floor(sx / 3) local cy = floor((sy + (cx % 2)) / 3)
  local h = hash(cx, cy, 17)
  local lx, ly = sx % 3, (sy + (cx % 2)) % 3
  if ly == 2 and h < 0.6 then return "#3f7a40" end
  if lx == 0 and ly == 0 then return h > 0.5 and "#b4d266" or "#8cc060" end
  if hash(sx, sy, 19) > 0.97 then return "#f5809f" end
  return h > 0.45 and "#6aa848" or "#5a9a48"
end)
do -- double-pointing signpost
  R(349, 102, 351, 177, "#864c33") R(349, 102, 349, 177, "#b97a4a") R(351, 102, 351, 177, "#51302b")
  local b = poly{ { 336, 109 }, { 341, 104 }, { 359, 104 }, { 364, 109 }, { 359, 114 }, { 341, 114 } }
  FM(b, "#e8b982") b:each(function(x, y) if y >= 112 then put(x, y, "#b97a4a") end end)
  R(342, 107, 358, 107, "#b97a4a") R(344, 110, 356, 110, "#b97a4a") edgeIn(b, "#51302b")
  put(345, 102, "#7cc35a") put(346, 101, "#7cc35a") put(347, 101, "#c4e07a")
end

---------------------------------------------------------------- left near wall: REST HOUSE (X=-2, Z 2.1-3.2)  [12,10,108,216]
roof(-1.88, 2.2, -3.3, 3.4, 2.05, 3.3, function(Z, t, sx, sy)
  if t < 0.05 then return "#2e3456" end
  if (t * 10) % 1 < 0.2 then return "#3e4670" end
  return hash(floor(Z * 25), floor(t * 10), 7) > 0.7 and "#6a76a0" or "#58628c"
end)
local RH = { pl = "#a8b4d6", plS = "#98a2c8", plH = "#bcc6e2", tim = "#4c3036", plin = "#8a849c", plinJ = "#5e5870", door = "#4a2234" }
wall(-2, 2.1, 3.2, 0, 2.2, function(Z, Y, sx, sy, pz, py)
  if (3.2 - Z) * pz < 1 then return "#2e2030" end
  if Y < 0.26 then
    local r = floor(Y / 0.13) local u = Z * 6 + (r % 2) * 0.5
    if (u % 1) * pz / 6 < 1 or ((Y / 0.13) % 1) * py * 0.13 < 1 then return RH.plinJ end
    return RH.plin
  end
  if Z > 2.3 and Z < 2.56 and Y < 1.28 then
    if Z < 2.33 or Z > 2.53 or Y > 1.23 then return RH.tim end
    if abs(Z - 2.49) * pz < 1.2 and abs(Y - 0.7) * py < 1.2 then return "#f5b82e" end
    if ((Z - 2.33) * pz) % 5 < 1 then return "#3a1a2a" end
    return RH.door
  end
  for _, w in ipairs{ { 2.62, 2.82, 1.48, 1.95 }, { 2.95, 3.12, 1.48, 1.95 }, { 2.92, 3.12, 0.62, 1.08 } } do
    if Z > w[1] and Z < w[2] and Y > w[3] and Y < w[4] then
      if (Z - w[1]) * pz < 1.5 or (w[2] - Z) * pz < 1.5 or (Y - w[3]) * py < 1.5 or (w[4] - Y) * py < 1.5
         or abs(Z - (w[1] + w[2]) / 2) * pz < 0.7 or abs(Y - (w[3] + w[4]) / 2) * py < 0.7 then return "#3e2830" end
      return Y > (w[3] + w[4]) / 2 and "#fff0a8" or "#ffd36a"
    end
    -- blue shutters
    if Y > w[3] and Y < w[4] and ((Z > w[1] - 0.07 and Z <= w[1]) or (Z >= w[2] and Z < w[2] + 0.07)) then
      return ((Y * 20) % 1) * py / 20 < 1 and "#2a4a7a" or "#3a86b0"
    end
  end
  if (Y > 0.26 and Y < 0.32) or (Y > 1.3 and Y < 1.4) or Y > 2.13 then return RH.tim end
  for _, zp in ipairs{ 2.12, 2.3, 2.56, 2.88, 3.17 } do if abs(Z - zp) * pz < 2 then return RH.tim end end
  if Y > 1.4 and Z > 2.12 and Z < 2.56 then
    local f = (Z - 2.12) / 0.44 local g = (Y - 1.4) / 0.73
    if abs(f - g) * 0.44 * pz < 1.6 or abs(f - (1 - g)) * 0.44 * pz < 1.6 then return RH.tim end
  end
  local h = hash(sx, sy, 23)
  if h > 0.93 then return RH.plH elseif h < 0.08 then return RH.plS end
  return RH.pl
end)
-- bench (on wall plane just off the wall) + quilt
wall(-1.82, 2.62, 3.02, 0, 0.72, function(Z, Y, sx, sy, pz, py)
  if Z > 2.72 and Z < 2.94 and Y > 0.16 and Y < 0.7 then
    local qx, qy = floor((Z - 2.72) * pz / 3), floor((Y - 0.16) * py / 3)
    local cols = { "#c9b2f0", "#f5809f", "#ffe38a", "#8a6fd0" }
    if ((Y - 0.16) * py) % 3 < 0.8 then return "#5a459e" end
    return cols[1 + (qx + qy * 2) % 4]
  end
  if Y > 0.4 and Y < 0.48 then return (Y > 0.45) and "#e8b982" or "#b97a4a" end
  if Y > 0.58 and Y < 0.7 then return (Y > 0.66) and "#e8b982" or "#864c33" end
  if (abs(Z - 2.65) * pz < 1.2 or abs(Z - 2.99) * pz < 1.2) then return "#51302b" end
  return nil
end)
do -- teapot on a stool + steam; rest sign (face-on) with teacup icon
  R(92, 160, 104, 161, "#b97a4a") R(92, 160, 104, 160, "#e8b982") R(93, 162, 94, 176, "#51302b") R(102, 162, 103, 176, "#51302b")
  local tp = c:rrect(93, 150, 103, 159, 3) FM(tp, "#e8493b")
  tp:each(function(x, y) if x >= 101 or y >= 158 then put(x, y, "#b52e3f") end end)
  R(95, 152, 96, 153, "#ff8a5c") put(98, 154, "#f4e2c8") put(100, 156, "#f4e2c8") put(96, 156, "#f4e2c8")
  edgeIn(tp, "#6e2038")
  R(96, 148, 100, 149, "#b52e3f") R(98, 147, 98, 147, "#f5b82e")
  line({ { 103, 155 }, { 106, 152 }, { 107, 150 } }, 1, "#b52e3f") R(90, 152, 91, 156, "#b52e3f") put(92, 152, "#b52e3f") put(92, 156, "#b52e3f")
  put(107, 146, "#e8dcef") put(106, 145, "#e8dcef") put(107, 144, "#e8dcef") put(108, 143, "#e8dcef") put(107, 142, "#c4b8d4")
  -- hanging sign
  line({ { 32, 72 }, { 78, 72 } }, 1, "#4c3036") R(40, 72, 40, 75, "#4c3036") R(72, 72, 72, 75, "#4c3036")
  local s = c:rect(36, 75, 76, 101) FM(s, "#f2e2b8") edgeIn(s, "#2a4a7a") R(37, 76, 75, 76, "#fff0c8")
  local cup = c:rrect(48, 84, 62, 96, 3) FM(cup, "#5fc4c8") R(49, 85, 51, 86, "#b6f0e0") cup:each(function(x, y) if x >= 60 then put(x, y, "#3a86b0") end end)
  R(63, 87, 65, 87, "#3a86b0") R(65, 88, 65, 91, "#3a86b0") R(63, 92, 65, 92, "#3a86b0") edgeIn(cup, "#2a4a7a")
  R(45, 97, 65, 98, "#3a86b0")
  for _, sx in ipairs{ 51, 56 } do put(sx, 82, "#8a6fd0") put(sx + 1, 81, "#8a6fd0") put(sx, 80, "#8a6fd0") put(sx + 1, 79, "#8a6fd0") end
  -- wall lantern
  R(62, 64, 62, 67, "#3e2830") R(59, 67, 65, 76, "#8f4a1f") R(60, 68, 64, 75, "#ffe38a") R(60, 68, 61, 69, "#fff0a8")
end

---------------------------------------------------------------- right near wall: two thatched COTTAGES (X=2, Z 2.1-3.2)  [384,8,462,216]
local function cottageWall(z0, z1, pl, plH, plS, door, dz)
  wall(2, z0, z1, 0, 1.35, function(Z, Y, sx, sy, pz, py)
    if (Z - z0) * pz < 1 or (z1 - Z) * pz < 1 then return "#5a3428" end
    if Y < 0.18 then return ((Z * 8) % 1) * pz / 8 < 1 and "#74758c" or "#aaa9b8" end
    if Z > dz[1] and Z < dz[2] and Y < 0.98 then
      if (Z - dz[1]) * pz < 1.5 or (dz[2] - Z) * pz < 1.5 or (0.98 - Y) * py < 1.5 then return "#7a4a34" end
      if abs(Z - dz[2] + 0.03) * pz < 1.2 and abs(Y - 0.5) * py < 1.2 then return "#f5b82e" end
      return door
    end
    local wz0 = dz[2] + 0.07 local wz1 = wz0 + 0.12
    if Z > wz0 and Z < wz1 and Y > 0.45 and Y < 0.92 then
      if (Z - wz0) * pz < 1.5 or (wz1 - Z) * pz < 1.5 or (Y - 0.45) * py < 1.5 or (0.92 - Y) * py < 1.5 or abs(Y - 0.68) * py < 0.7 then return "#5a3428" end
      return Y > 0.68 and "#fff0a8" or "#ffd36a"
    end
    if Z > wz0 - 0.02 and Z < wz1 + 0.02 and Y > 0.34 and Y <= 0.45 then
      if Y > 0.4 then return hash(sx, sy, 3) > 0.5 and "#f5809f" or "#7cc35a" end
      return "#864c33"
    end
    if Y > 1.28 then return "#7a4a34" end
    local h = hash(sx, sy, 29)
    if h > 0.92 then return plH elseif h < 0.08 then return plS end
    return pl
  end)
end
local function thatch(Xe, za, zb)
  roof(Xe, 1.25, 3.1, 2.6, za, zb, function(Z, t, sx, sy)
    if t < 0.06 then return (sx % 2 == 0) and "#8a5a2e" or "#b8863a" end
    if (t * 8) % 1 < 0.16 then return "#b8863a" end
    local h = hash(sx, floor(t * 8), 31)
    if h > 0.78 then return "#f4d070" elseif h < 0.12 then return "#c89640" end
    return "#e0b050"
  end)
end
wall(2, 3.18, 3.75, 0, 0.5, function(Z, Y, sx, sy, pz, py) -- low stone garden wall beyond cottage B
  if (0.5 - Y) * py < 1.2 then return "#e2e0e6" end
  if ((Y / 0.16) % 1) * py * 0.16 < 1 or ((Z * 6 + floor(Y / 0.16) * 0.5) % 1) * pz / 6 < 1 then return "#74758c" end
  return "#c4c2ce"
end)
cottageWall(2.72, 3.18, "#f6dca6", "#ffeec0", "#dcbc8c", "#5a2a30", { 2.8, 2.94 })
thatch(1.95, 2.7, 3.2)
wall(2, 2.6, 2.72, 0, 1.35, function(Z, Y) return Y < 0.5 and "#aaa9b8" or nil end)
cottageWall(2.1, 2.6, "#f4b4a4", "#ffd0bc", "#d8948c", "#2e4a52", { 2.22, 2.4 })
thatch(1.8, 2.05, 2.65)
do -- cottage wall lantern + snail mailbox (quirk)
  R(422, 86, 422, 90, "#5a3428") R(419, 90, 425, 99, "#8f4a1f") R(420, 91, 424, 98, "#ffe38a") R(420, 91, 421, 92, "#fff0a8")
  R(397, 193, 398, 213, "#864c33") R(397, 193, 397, 213, "#b97a4a")
  local shell = c:rrect(391, 181, 403, 193, 4)
  FM(shell, "#e09a3a")
  shell:each(function(x, y) if x >= 400 or y >= 191 then put(x, y, "#b86a2a") end end)
  for _, p in ipairs{ { 397, 184 }, { 398, 184 }, { 399, 184 }, { 400, 185 }, { 400, 186 }, { 400, 187 }, { 399, 188 }, { 398, 188 }, { 397, 188 },
                      { 396, 188 }, { 395, 187 }, { 395, 186 }, { 396, 185 }, { 397, 186 }, { 398, 186 } } do put(p[1], p[2], "#7d3a1f") end
  R(393, 183, 394, 183, "#ffe38a") edgeIn(shell, "#6e3420")
  local bod = poly{ { 389, 191 }, { 403, 191 }, { 408, 189 }, { 409, 193 }, { 389, 194 } } FM(bod, "#9ac07a") edgeIn(bod, "#3f7a50")
  R(406, 184, 406, 189, "#3f7a50") R(409, 185, 409, 189, "#3f7a50") put(406, 183, "#24544a") put(409, 184, "#24544a")
  R(391, 192, 401, 192, "#c4e07a")
end

---------------------------------------------------------------- foreground quirks / areas
-- haystack with a tiny door (quirk)
do
  local hs = poly{ { 110, 214 }, { 110, 201 }, { 114, 193 }, { 121, 190 }, { 128, 193 }, { 132, 201 }, { 132, 214 } }
  hs:each(function(x, y)
    local col = "#e0b050"
    if x > 126 or y > 211 then col = "#b8863a" elseif x < 117 and y < 200 then col = "#f4d070" end
    if hash(x, floor(y / 2), 37) > 0.82 then col = "#c89640" end
    put(x, y, col)
  end)
  edgeIn(hs, "#8a5a2e")
  R(118, 205, 123, 213, "#51302b") R(119, 204, 122, 204, "#51302b") R(119, 206, 122, 213, "#6e3a2c") put(122, 209, "#f5b82e")
  put(115, 198, "#ffe38a") put(126, 197, "#ffe38a")
end
-- puddle on the flagstones
do
  local pd = poly{ { 258, 212 }, { 268, 208 }, { 284, 209 }, { 289, 213 }, { 277, 217 }, { 262, 216 } }
  FM(pd, "#a8c4e2") pd:each(function(x, y) if y >= 215 then put(x, y, "#8bb0d8") end end)
  R(266, 211, 274, 211, "#e4f0f4") R(278, 213, 282, 213, "#f8e2ac") edgeIn(pd, "#6f84a8")
end
-- FISHING POND  [18,228,148,266]
do
  local bank = poly{ { 18, 246 }, { 30, 234 }, { 60, 229 }, { 104, 229 }, { 140, 233 }, { 148, 246 }, { 140, 262 }, { 96, 266 }, { 40, 266 }, { 20, 259 } }
  FM(bank, "#8a6a4a") edgeIn(bank, "#5e4436")
  local wat = bank:shrink(2)
  wat:each(function(x, y)
    local col = y < 238 and "#5fa0c8" or (y < 250 and "#4a8ab8" or "#3a72a6")
    if (y % 4 == 0) and hash(floor(x / 6), y, 3) > 0.55 then col = "#a8d8e8" end
    if y > 256 then col = "#2e5a8a" end
    put(x, y, col)
  end)
  R(50, 236, 64, 236, "#f8e2ac") R(70, 244, 78, 244, "#f8e2ac")
  edgeIn(wat, "#2a4a7a")
  -- lily pads
  for _, lp in ipairs{ { 44, 248 }, { 84, 254 }, { 60, 258 } } do R(lp[1], lp[2], lp[1] + 5, lp[2] + 1, "#3f9150") R(lp[1], lp[2], lp[1] + 2, lp[2], "#7cc35a") put(lp[1] + 3, lp[2], "#3a72a6") end
  put(86, 253, "#f5809f") put(87, 253, "#ffc4d8")
  -- reeds
  for i = 0, 9 do
    local rx = 20 + i * 2 + (i % 3) local top = 226 + floor(hash(i, 1, 9) * 10)
    R(rx, top, rx, 252, i % 2 == 0 and "#3f9150" or "#7cc35a")
    if i % 3 == 0 then R(rx, top - 4, rx + 1, top, "#864c33") put(rx, top - 4, "#b97a4a") end
  end
  for i = 0, 5 do local rx = 136 + i * 2 R(rx, 232 + i % 3 * 2, rx, 252, i % 2 == 0 and "#3f9150" or "#7cc35a") end
  -- jetty
  local jt = poly{ { 96, 266 }, { 100, 246 }, { 124, 246 }, { 122, 266 } }
  jt:each(function(x, y) put(x, y, (y % 3 == 0) and "#864c33" or (x < 104 and "#e8b982" or "#b97a4a")) end)
  edgeIn(jt, "#51302b")
  R(99, 247, 100, 262, "#51302b") R(121, 247, 122, 262, "#51302b")
  -- propped rod, line, float
  line({ { 116, 252 }, { 78, 230 } }, 1, "#51302b") R(114, 250, 118, 254, "#864c33")
  line({ { 78, 230 }, { 72, 246 } }, 1, "#d8e4ee") R(71, 246, 72, 247, "#e8493b") put(71, 248, "#f4e2c8")
  -- bucket on jetty
  R(106, 248, 111, 253, "#5fc4c8") R(106, 248, 111, 248, "#b6f0e0") R(106, 253, 111, 253, "#3a86b0")
end
-- FORAGE PATCH (fenced herb & berry bed + mushrooms + teapot-hat scarecrow)  [304,212,376,266]
do
  local bed = poly{ { 308, 240 }, { 372, 240 }, { 374, 264 }, { 306, 264 } }
  bed:each(function(x, y) put(x, y, ((y - 240) % 5 == 0) and "#4e3434" or (hash(x, y, 3) > 0.85 and "#8a6a4a" or "#6a4a3a")) end)
  -- berry bushes
  for _, bb in ipairs{ { 316, 248 }, { 346, 252 } } do
    local bu = c:ellipse(bb[1], bb[2], 8, 6)
    bu:each(function(x, y) put(x, y, (x - bb[1]) + (y - bb[2]) < -4 and "#7cc35a" or ((x - bb[1]) + (y - bb[2]) > 4 and "#24544a" or "#3f9150")) end)
    edgeIn(bu, "#24443a")
    for k = 0, 5 do local bx, by = bb[1] - 5 + floor(hash(k, bb[1], 1) * 10), bb[2] - 3 + floor(hash(k, bb[2], 2) * 6)
      put(bx, by, k % 2 == 0 and "#e8493b" or "#5a459e") put(bx, by - 1, "#ffc4d8") end
  end
  -- herbs
  for i = 0, 6 do local hx = 327 + i * 2 R(hx, 248 + (i % 2) * 2, hx, 258, "#7cc35a") put(hx, 247 + (i % 2) * 2, "#c4e07a") put(hx - 1, 252, "#3f9150") end
  -- mushrooms
  for _, m in ipairs{ { 358, 256 }, { 364, 250 }, { 338, 260 } } do
    R(m[1], m[2], m[1] + 1, m[2] + 3, "#f4e2c8")
    R(m[1] - 2, m[2] - 2, m[1] + 3, m[2], "#e8493b") R(m[1] - 1, m[2] - 3, m[1] + 2, m[2] - 3, "#e8493b")
    put(m[1] - 1, m[2] - 2, "#f4e2c8") put(m[1] + 2, m[2] - 1, "#f4e2c8") R(m[1] - 2, m[2], m[1] + 3, m[2], "#b52e3f")
  end
  -- picket fence (front + back rails)
  for _, fy in ipairs{ 238, 262 } do
    R(304, fy, 376, fy + 1, "#b97a4a") R(304, fy, 376, fy, "#e8b982")
    for x = 304, 376, 5 do R(x, fy - 5, x + 1, fy + 4, "#e8b982") R(x + 1, fy - 5, x + 1, fy + 4, "#864c33") put(x, fy - 6, "#e8b982") end
  end
  R(304, 238, 305, 266, "#864c33") R(375, 238, 376, 266, "#864c33")
  -- scarecrow with teapot hat
  R(367, 222, 368, 252, "#864c33") R(359, 228, 377, 229, "#864c33")
  local shirt = poly{ { 362, 228 }, { 373, 228 }, { 372, 240 }, { 363, 240 } } FM(shirt, "#5fc4c8")
  R(365, 232, 368, 235, "#f5b82e") R(362, 228, 373, 229, "#3a86b0") edgeIn(shirt, "#2a4a7a")
  local head = c:rrect(364, 219, 371, 226, 2) FM(head, "#e8b982") put(366, 222, "#51302b") put(369, 222, "#51302b") R(366, 224, 369, 224, "#864c33") edgeIn(head, "#864c33")
  local pot = c:rrect(363, 212, 372, 218, 2) FM(pot, "#c9b2f0") R(364, 213, 365, 214, "#ffc4d8") pot:each(function(x, y) if x >= 370 then put(x, y, "#8a6fd0") end end)
  edgeIn(pot, "#5a459e") R(366, 210, 369, 211, "#8a6fd0") put(367, 209, "#f5b82e")
  line({ { 372, 215 }, { 375, 212 } }, 1, "#8a6fd0") R(361, 213, 362, 216, "#8a6fd0")
end

---------------------------------------------------------------- smoke curls
local function smoke(x, y, n)
  for i = 0, n - 1 do
    local cx, cy = x - i * 3 + floor(2 * sin(i * 1.7)), y - i * 4
    put(cx, cy, "#ece2f2") put(cx + 1, cy - 1, "#ece2f2") put(cx + 2, cy, "#d4c8e2") put(cx + 1, cy + 1, "#d4c8e2")
  end
end
smoke(122, 19, 3)
smoke(315, 82, 4)

---------------------------------------------------------------- gate frame, braces, lanterns, bunting
-- bunting
local function sag(x) return 13 + 20 * (1 - ((x - 240) / 228) ^ 2) end
local flagCols = { "#e8493b", "#f5b82e", "#5fc4c8", "#f5809f", "#7cc35a", "#8a6fd0" }
for x = 12, 467 do put(x, floor(sag(x)), "#6a4a3a") end
local fi = 0
for x = 20, 456, 13 do
  fi = fi + 1
  local y = floor(sag(x + 4))
  local fl = poly{ { x, y }, { x + 8, y }, { x + 4, y + 9 } }
  local col = flagCols[(fi - 1) % 6 + 1]
  FM(fl, col) put(x + 1, y + 1, "#fff0c8") put(x + 2, y + 1, "#fff0c8")
  fl:each(function(px, py) if px >= x + 6 - (py - y) / 2 and py > y + 1 then put(px, py, "#6e2038") end end)
  FM(fl:edge():clip(poly{ { x + 4, y + 9 }, { x + 8, y }, { x + 8, y + 9 } }), "#6e2038")
  for px = x, x + 8 do put(px, y, col) end
end
-- posts
local function post(x0, x1)
  for y = 0, H - 1 do for x = x0, x1 do
    local col = "#7a4a30"
    if x == x0 or x == x0 + 1 then col = "#a06a44" elseif x >= x1 - 1 then col = "#583428" end
    if (x - x0) % 4 == 2 and hash(x, floor(y / 6), 3) > 0.5 then col = "#583428" end
    if y > 236 then col = (x - x0) < 3 and "#c8c6d4" or ((y % 6 == 0) and "#5a5a74" or "#9a99aa") end
    put(x, y, col)
  end end
  R(x0, 0, x0, H - 1, "#3a2228") R(x1, 0, x1, H - 1, "#3a2228")
end
post(0, 11) post(468, 479)
for y = 0, 11 do for x = 0, W - 1 do
  local col = y < 2 and "#a06a44" or (y > 8 and "#583428" or "#7a4a30")
  if y > 2 and y < 9 and hash(floor(x / 7), y, 5) > 0.8 then col = "#583428" end
  put(x, y, col)
end end
R(0, 11, W - 1, 11, "#3a2228")
for x = 30, 450, 60 do R(x, 4, x + 1, 5, "#f5b82e") end
-- corner braces
line({ { 12, 44 }, { 40, 12 } }, 4, "#7a4a30") line({ { 12, 42 }, { 38, 12 } }, 1, "#a06a44")
line({ { 467, 44 }, { 439, 12 } }, 4, "#7a4a30") line({ { 467, 46 }, { 441, 14 } }, 1, "#583428")
-- hanging lanterns
for _, lx in ipairs{ 58, 420 } do
  R(lx, 12, lx, 19, "#3a2228")
  R(lx - 3, 20, lx + 3, 20, "#51302b")
  local lb = c:rect(lx - 3, 21, lx + 3, 31) FM(lb, "#ffe38a") R(lx - 2, 22, lx - 1, 24, "#fff0c8") R(lx + 2, 22, lx + 2, 30, "#f5b82e")
  R(lx, 21, lx, 31, "#8f4a1f") edgeIn(lb, "#8f4a1f")
  R(lx - 2, 32, lx + 2, 32, "#51302b") put(lx, 33, "#e8493b")
end

---------------------------------------------------------------- falling seed fluff
for i = 0, 54 do
  local x, y = 16 + floor(hash(i, 3, 51) * 448), 16 + floor(hash(i, 4, 52) * 210)
  if not (x >= 380 and y >= 226) then
    put(x, y, "#fff4d8") put(x + 1, y, "#fff4d8") put(x, y + 1, "#e8d4a8") put(x - 1, y + 1, "#e8d4a8")
  end
end

c:finish{ outline = false }
HP.assertClean(c)
c:save{ aseprite = OUT .. NAME .. ".aseprite", png = OUT .. NAME .. ".png", scale = 1 }

---------------------------------------------------------------- layout json
local spots = {
  { "rest", "Rest House", { 12, 10, 108, 216 } },
  { "seeds", "Seed Swap", { 118, 30, 146, 184 } },
  { "table", "Long Table", { 154, 58, 200, 158 } },
  { "well", "Wishing Well", { 212, 80, 236, 160 } },
  { "notice", "Notice Board", { 248, 48, 280, 158 } },
  { "trader", "Trader Stall", { 294, 80, 324, 160 } },
  { "trail", "Wild Trail", { 336, 58, 370, 184 } },
  { "cottages", "Cottages", { 384, 8, 462, 216 } },
  { "pond", "Fishing Pond", { 18, 228, 148, 266 } },
  { "forage", "Forage Patch", { 304, 208, 376, 266 } },
}
local stand = { { 240, 248 }, { 162, 216 }, { 346, 196 }, { 232, 186 }, { 186, 168 }, { 296, 172 } }
local parts = {}
for _, s in ipairs(spots) do
  local b = s[3]
  parts[#parts + 1] = string.format('{"k":"%s","name":"%s","x":%d,"y":%d,"box":[%d,%d,%d,%d]}', s[1], s[2],
    floor((b[1] + b[3]) / 2), floor((b[2] + b[4]) / 2), b[1], b[2], b[3], b[4])
end
local st = {}
for _, p in ipairs(stand) do st[#st + 1] = string.format('{"x":%d,"y":%d}', p[1], p[2]) end
local f = io.open(OUT .. NAME .. ".layout.json", "w")
f:write('{"w":480,"h":270,"horizon":112,"view":"gate","spots":[' .. table.concat(parts, ",") .. '],"stand":[' .. table.concat(st, ",") ..
  '],"compass_clear":[380,230,480,270]}\n')
f:close()
print("done " .. NAME)
