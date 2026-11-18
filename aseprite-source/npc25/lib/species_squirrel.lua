-- squirrel (biped (mammal)) tables from specs/squirrel.md. Opus: S.draw_figure is the final art.
local N = dofile((app.params.root or "npc25") .. "/lib/npc25.lua")
local S = {name = "squirrel", feet_y = 71, outline = "#2b1c26", plan = "draw", T = 8, W = 42}
S.ramps = {
  fur = {"#ec8a44", "#d26a36", "#a8452e", "#6e2a2c"},  -- hi, base, shade, deep
  cream = {"#f3e2bf", "#d9b98c"},
  vest = {"#6a9a48", "#46704a", "#2f4a42"},
  sack = {"#e6cc90", "#c9a86a", "#a07a48"}, nut = "#8f5f3a", cheek = "#f5809f",
}
S.palette_list = {"#2b1c26", "#ec8a44", "#d26a36", "#a8452e", "#6e2a2c", "#f3e2bf", "#d9b98c",
  "#6a9a48", "#46704a", "#2f4a42", "#e6cc90", "#c9a86a", "#a07a48", "#8f5f3a", "#f5809f"}
-- {body y, head y, footL, footR, armL, armR}
S.idle = {{0, 0, 0, 0, 0, 0}, {-1, -1, 0, 0, 0, 0}}
S.walk = {{0, 0, 0, -2, 2, -2}, {-1, -1, 0, -1, 1, -1}, {-1, -1, -1, 0, 0, 0},
          {0, 0, -2, 0, -2, 2}, {-1, -1, -1, 0, -1, 1}, {-1, -1, 0, -1, 0, 0}}
S.quirk = {w = 7, h = 8, y = 53, x = {front = 40, back = 17, side = 18}, anchor = "hip", hex = "#c9a86a"}

-- one 64x80 frame (transparent bg, hard pixels, outline included)
function S.draw_figure(img, view, frame, species)
  local o = N.offsets(species, frame)
  local H = N.hex
  local INK = H(species.outline)
  local F = {hi = H"#ec8a44", base = H"#d26a36", shade = H"#a8452e", deep = H"#6e2a2c"}
  local FS = {hi = F.base, base = F.shade, shade = F.deep, deep = F.deep}
  local V = {hi = H"#6a9a48", base = H"#6a9a48", shade = H"#46704a", deep = H"#2f4a42"}
  local K = {hi = H"#e6cc90", base = H"#c9a86a", shade = H"#a07a48"}
  local CREAM, CRS, PINK, NUT = H"#f3e2bf", H"#d9b98c", H"#f5809f", H"#8f5f3a"
  local b, hd = o.body, o.head
  local top = 9 + hd
  local k = frame - 2
  local LX = ({1, -1, -3, -1, 1, 3})[k] or 0
  local RX = ({-1, 1, 3, 1, -1, -3})[k] or 0
  local sw = (o.armL > 0 and 1) or (o.armL < 0 and -1) or 0
  local G = {}
  local function P(x, y, c)
    x, y = math.floor(x), math.floor(y)
    if c and x >= 8 and x <= 55 and y >= top and y <= 70 then G[y * 64 + x] = c end
  end
  local function get(x, y) return G[y * 64 + x] end
  local function ell(cx, cy, rx, ry, fn)
    for y = math.floor(cy - ry) - 1, math.ceil(cy + ry) + 1 do
      for x = math.floor(cx - rx) - 1, math.ceil(cx + rx) + 1 do
        local nx, ny = (x - cx) / rx, (y - cy) / ry
        local d = nx * nx + ny * ny
        if d <= 1 then P(x, y, fn(x, y, nx, ny, d)) end
      end
    end
  end
  local function lit(nx, ny, r)
    local s = nx * 0.55 + ny * 0.83
    if s > 0.88 and r.deep then return r.deep end
    if s > 0.4 then return r.shade end
    if s < -0.5 then return r.hi end
    return r.base
  end
  local function E(cx, cy, rx, ry, r)
    ell(cx, cy, rx, ry, function(x, y, nx, ny) return type(r) == "table" and lit(nx, ny, r) or r end)
  end
  local function stamp(x0, y0, rows, map)
    for j, row in ipairs(rows) do
      for i = 1, #row do
        local ch = row:sub(i, i)
        if ch ~= "." then P(x0 + i - 1, y0 + j - 1, map[ch]) end
      end
    end
  end
  local function line(x0, y0, x1, y1, c)
    local n = math.max(math.abs(x1 - x0), math.abs(y1 - y0))
    for i = 0, n do P(math.floor(x0 + (x1 - x0) * i / n + 0.5), math.floor(y0 + (y1 - y0) * i / n + 0.5), c) end
  end
  -- bushy tail along a path: thick in the middle, fur strands in shade, light tip flick
  local function tail(pts, r)
    local n = #pts
    for i = 1, n - 1 do
      local a, c = pts[i], pts[i + 1]
      for s = 0, 5 do
        local t = s / 6
        local px, py = a[1] + (c[1] - a[1]) * t, a[2] + (c[2] - a[2]) * t
        local u = (i - 1 + t) / (n - 1)
        local rr = r * (0.5 + 0.5 * math.sin(math.min(1, u * 1.2) * math.pi)) * (1 + 0.1 * math.sin(u * 37))
        ell(px, py, rr, rr, function(x, y, nx, ny)
          return lit(nx, ny, F)
        end)
      end
    end
    -- strands: a shade tick every few steps along the path
    for i = 2, n - 1 do
      local p = pts[i]
      P(p[1] + 1, p[2], F.shade); P(p[1], p[2] + 1, F.shade)
    end
  end
  -- hazelnut sack: x0,y0 = top-left of the stamp
  local function sack(x0, y0, mir)
    local rows = {"..nh...", ".snns..", "..sss..", ".hbbbs.", "hbbbbbs", "hbbbbbs", "bbbbbss", ".bbbss."}
    if mir then
      local m = {}
      for j, r in ipairs(rows) do m[j] = r:reverse():gsub("h", "x"):gsub("s", "h"):gsub("x", "s") end
      for j = 1, 3 do m[j] = rows[j] end
      rows = m
    end
    stamp(x0, y0, rows, {n = NUT, h = K.hi, s = K.shade, b = K.base})
  end
  -- tufted ear: rows {y, x1, x2} for the viewer-left ear (head offset applied); mir flips about CX
  local EAR = {{13, 22, 22}, {14, 21, 23}, {15, 21, 23}, {16, 20, 24}, {17, 20, 24}, {18, 20, 25},
    {19, 19, 25}, {20, 19, 25}, {21, 19, 26}}
  local function ear(mir, dx, inner, shade)
    local function X(x) return mir and (63 - x + dx) or (x + dx) end
    for _, r in ipairs(EAR) do
      local y, x1, x2 = r[1], r[2], r[3]
      for x = x1, x2 do
        local c = F.base
        if x == x1 then c = mir and F.shade or F.hi end
        if x == x2 then c = mir and F.hi or F.shade end
        if inner and y >= 16 and x > x1 and x < x2 then c = inner end
        if shade then c = (x == x1 or x == x2) and F.shade or F.base end
        P(X(x), y + hd, c)
      end
    end
    -- tuft
    for _, t in ipairs({{21, 9}, {21, 10}, {22, 10}, {21, 11}, {22, 11}, {22, 12}}) do P(X(t[1]), t[2] + hd, F.deep) end
    P(X(22), 13 + hd, F.shade)
  end
  local CX = 31.5
  local tsw = sw * 0.7

  if view == "front" or view == "back" then
    local front = view == "front"
    local ftVL, ftVR, armVL, armVR = o.footR, o.footL, o.armR, o.armL
    if not front then ftVL, ftVR, armVL, armVR = o.footL, o.footR, o.armL, o.armR end
    if front then
      tail({{28, 63 + b}, {20, 62 + b}, {15.5, 56 + b}, {14, 48 + b}, {14, 40 + b}, {15, 32 + b},
        {17 + tsw, 25 + b}, {17 + tsw, 19 + b}, {14 + tsw, 15.5 + b}}, 6.5)
    end
    local function foot(cx, lift)
      local bot = 70 + lift
      for y = 61 + b, bot - 2 do for x = cx - 2, cx + 1 do P(x, y, x >= cx and F.shade or F.base) end end
      ell(cx - 0.5, bot - 1.5, 3, 2, function(x, y, nx, ny)
        if front then
          if y >= bot - 1 and (x == cx - 2 or x == cx) then return F.deep end
          if y == bot - 2 then return F.hi end
          return nx > 0.4 and F.shade or F.base
        end
        if y == bot - 2 then return F.shade end
        return lift < 0 and F.deep or F.shade
      end)
    end
    foot(26, ftVL); foot(38, ftVR)
    -- neck / chest
    for y = 36, 43 do for x = 25, 38 do P(x, y + b, front and ((x <= 26 or x >= 37) and F.shade or CREAM) or (x >= 36 and F.shade or F.base)) end end
    -- body with waistcoat
    ell(CX, 54 + b, 11, 12.5, function(x, y, nx, ny)
      local yy = y - b
      local ax = math.abs(x - CX)
      if front then
        local hem = 60 - math.floor(ax / 5)
        local open = 2.5 + (yy - 42) * 0.22
        if yy <= hem and ax >= open then
          if ax < open + 1 then return V.deep end
          if yy == hem then return V.deep end
          return lit(nx, ny, V)
        end
        local bx, by = (x - CX) / 6.5, (yy - 54) / 11
        if yy < 48 and ax < open + 0.5 then return CREAM end
        if bx * bx + by * by <= 1 then return (nx > 0.3 and ny > 0.1) and CRS or CREAM end
        return lit(nx, ny, F)
      end
      if yy >= 61 then return lit(nx, ny, F) end
      if yy == 60 then return V.deep end
      if ax <= 0.5 and yy >= 50 then return V.shade end
      return lit(nx, ny, V)
    end)
    -- strap (front: viewer-left shoulder to viewer-right hip)
    if front then line(24, 44 + b, 41, 54 + b, K.shade)
    else line(39, 44 + b, 22, 54 + b, K.shade) end
    -- arms
    local function arm(a, side)
      local dy = front and a or -a
      local ax = side < 0 and 19.5 or 43.5
      E(ax + (side < 0 and 1 or -1), 48 + b + dy / 2, 2.6, 4, side < 0 and F or FS)
      ell(ax, 52.5 + b + dy, 2.2, 2, function(x, y, nx, ny)
        if not front then return F.shade end
        if nx > 0.3 and ny > 0 then return F.shade end
        if nx < -0.3 and ny < -0.2 then return F.hi end
        return F.base
      end)
    end
    arm(armVL, -1); arm(armVR, 1)
    if front then sack(41 + sw, 53 + b, false) else sack(16 - sw, 53 + b, true) end
    local function backtail()
      tail({{31, 65 + b}, {37, 63 + b}, {41, 58 + b}, {42.5, 50 + b}, {42, 42 + b}, {42, 34 + b},
        {44 - tsw, 27 + b}, {46 - tsw, 21 + b}, {49 - tsw, 17.5 + b}}, 7)
    end
    -- ears
    ear(false, 0, front and F.shade or nil, not front)
    ear(true, 0, front and F.shade or nil, not front)
    -- head
    ell(CX, 29 + hd, 11.5, 9.5, function(x, y, nx, ny) return lit(nx, ny, F) end)
    -- cheek fluff
    if front then P(19, 32 + hd, F.base); P(44, 32 + hd, F.shade) end
    if front then
      P(23, 22 + hd, F.hi); P(24, 21 + hd, F.hi)
      ell(CX, 33.5 + hd, 6.2, 3.8, function(x, y, nx, ny)
        if ny > 0.5 and nx > 0.2 then return CRS end
        return CREAM
      end)
      for _, ex in ipairs({25, 37}) do
        for y = 25, 27 do P(ex, y + hd, INK); P(ex + 1, y + hd, INK) end
        P(ex, 25 + hd, CREAM)
      end
      P(22, 31 + hd, PINK); P(23, 31 + hd, PINK); P(40, 31 + hd, PINK); P(41, 31 + hd, PINK)
      stamp(30, 30 + hd, {".dd.", "..k.", ".k.k"}, {d = F.deep, k = INK})
      P(31, 32 + hd, INK)
    else
      for _, t in ipairs({{25, 24}, {26, 23}, {30, 23}, {31, 22}, {35, 23}, {28, 28}, {29, 27}}) do
        local c = get(t[1], t[2] + hd)
        if c == F.base or c == F.hi then P(t[1], t[2] + hd, F.hi) end
      end
      for _, t in ipairs({{38, 31}, {39, 30}, {27, 34}, {33, 35}, {34, 34}}) do P(t[1], t[2] + hd, F.shade) end
    end
    if not front then backtail() end
  else
    -- side view, facing right
    local function foot(cx, lift, far)
      local bot = 70 + lift
      for y = 62 + b, bot - 2 do for x = cx - 1, cx + 1 do P(x, y, far and F.deep or (x == cx + 1 and F.shade or F.base)) end end
      ell(cx + 1, bot - 1.5, 3.6, 1.9, function(x, y, nx, ny)
        if far then return F.shade end
        if y == bot and x >= cx + 3 then return F.deep end
        if y == bot - 2 then return F.hi end
        return F.base
      end)
    end
    tail({{26, 63 + b}, {19, 62.5 + b}, {15, 58 + b}, {13.5, 50 + b}, {13.5, 42 + b}, {14.5, 34 + b},
      {17 - tsw, 27 + b}, {20.5 - tsw, 22 + b}, {24 - tsw, 19.5 + b}}, 6.5)
    foot(27 + LX, o.footL, true)
    local fax = -LX
    E(38 + fax, 51 + b, 2.2, 2, F.shade)
    -- neck
    for y = 36, 43 do for x = 25, 36 do P(x, y + b, x >= 34 and CREAM or (x <= 26 and F.shade or F.base)) end end
    -- body
    ell(30, 54 + b, 10, 12.5, function(x, y, nx, ny)
      local yy = y - b
      local hem = 60 + math.floor(math.max(0, x - 30) / 3)
      if x >= 36 - math.floor((yy - 42) / 6) or (yy > hem) then
        if yy > hem and x < 34 then return lit(nx, ny, F) end
        return (nx > 0.6 and ny > 0.3) and CRS or CREAM
      end
      if x == 35 - math.floor((yy - 42) / 6) then return V.deep end
      if yy == hem then return V.deep end
      return lit(nx, ny, V)
    end)
    sack(18 - sw, 52 + b, false)
    line(34, 44 + b, 23, 53 + b, K.shade)
    foot(31 + RX, o.footR, false)
    -- near arm
    local ax = -RX
    for t = 0, 5 do
      local xx = math.floor(32 + ax * t / 5 + 0.5)
      P(xx - 1, 46 + t + b, F.hi); P(xx, 46 + t + b, F.base); P(xx + 1, 46 + t + b, F.shade); P(xx + 2, 46 + t + b, F.deep)
    end
    ell(34 + ax, 52.5 + b, 2.3, 2.1, function(x, y, nx, ny)
      if nx > 0.3 and ny > 0 then return F.shade end
      if nx < -0.3 and ny < -0.2 then return F.hi end
      return F.base
    end)
    -- head
    ell(31, 29 + hd, 10, 9, function(x, y, nx, ny) return lit(nx, ny, F) end)
    -- ear with tuft
    local SE = {{13, 27, 27}, {14, 26, 28}, {15, 26, 28}, {16, 25, 29}, {17, 25, 29}, {18, 25, 30}, {19, 24, 30}, {20, 24, 30}}
    for _, r in ipairs(SE) do
      for x = r[2], r[3] do
        local c = F.base
        if x == r[2] then c = F.hi elseif x == r[3] then c = F.shade elseif r[1] >= 16 and x == r[2] + 2 then c = F.shade end
        P(x, r[1] + hd, c)
      end
    end
    for _, t in ipairs({{26, 9}, {26, 10}, {27, 10}, {26, 11}, {27, 11}, {27, 12}}) do P(t[1], t[2] + hd, F.deep) end
    P(27, 13 + hd, F.shade)
    -- snout with cream lower jaw
    ell(39.5, 31.5 + hd, 6, 4, function(x, y, nx, ny)
      if ny > 0.3 then return (nx > 0.5) and CRS or CREAM end
      return ny < -0.5 and F.hi or F.base
    end)
    P(45, 30 + hd, F.deep); P(46, 30 + hd, F.deep); P(45, 31 + hd, F.deep)
    P(43, 33 + hd, INK)
    -- eye
    for y = 25, 27 do P(36, y + hd, INK); P(37, y + hd, INK) end
    P(36, 25 + hd, CREAM)
    P(35, 31 + hd, PINK); P(36, 31 + hd, PINK)
    P(23, 25 + hd, F.hi); P(22, 26 + hd, F.hi)
  end
  for key, c in pairs(G) do img:putPixel(key % 64, key // 64, c) end
  N.outline(img, INK)
end
return S
