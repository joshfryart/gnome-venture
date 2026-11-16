-- wren (flyer) tables from specs/wren.md. Opus: replace S.draw_figure only (body-plan helper: D.flyer).
local N = dofile((app.params.root or "npc25") .. "/lib/npc25.lua")
local D = dofile((app.params.root or "npc25") .. "/lib/draft_common.lua")
local S = {name = "wren", feet_y = 71, outline = "#2b1c26", plan = "flyer", T = 9, W = 40}
S.ramps = {main = {"#c88050", "#b06a3a", "#7a4438", "#4e2c3a"}}  -- hi, base, shade, deep
S.palette_list = {"#2b1c26", "#c88050", "#b06a3a", "#7a4438", "#4e2c3a", "#e2b97e", "#cfb699", "#e0b052", "#a87a48", "#2c4848"}
-- {body y, head y, footL, footR, armL, armR}
S.idle = {{0, 0, 0, 0, 0, 0}, {-1, -1, 0, 0, 0, 0}}
S.walk = {{0, 0, 0, 0, 2, 2}, {-1, -1, 0, -1, 1, 1}, {-2, -2, 0, -1, -1, -1}, {-1, -1, 0, -2, 0, 0}, {0, 0, 0, -1, 2, 2}, {-1, -1, 0, 0, 1, 1}}
local h = N.hex
S.c = {
  body = h"#b06a3a",
  bshade = h"#7a4438",
  bhi = h"#c88050",
  deep = h"#4e2c3a",
  head = h"#b06a3a",
  hat = h"#e2b97e",
  hatshade = h"#cfb699",
  wing = h"#7a4438",
  belly = h"#e2b97e",
  acc = h"#2c4848",
  accs = h"#2c4848",
  eye = h"#e2b97e",
  q = h"#e2b97e",
  qshade = h"#b06a3a",
  qhi = h"#e2b97e",
  ink = h"#4e2c3a", arm = h"#b06a3a", fbase = h"#7a4438", fshade = h"#4e2c3a"}
S.bw, S.top = 16, 10
S.quirk = {w = 3, h = 3, anchor = "chest", hex = "#e2b97e"}

-- Stage 3 (Opus): hand-placed pixel art for one 64x80 frame (transparent bg, hard pixels, outline included).
-- img: Image 64x80 RGBA, view: "front"|"back"|"side", frame: 1..8, species: this table.
function S.draw_figure(img, view, frame, species)
  local o = N.offsets(species, frame)
  local H = N.hex
  local INK = H(species.outline)
  local b, hd = o.body, o.head
  local walk = frame >= 3
  local s = o.armL                      -- wing spread: 2 open, 1 down-stroke, 0 half, -1 closed
  local top = species.T + 1 + hd         -- first painted row (outline sits one above)
  local G, TAG, cur = {}, {}, "x"
  local floor, ceil, sqrt, rad, cos, sin = math.floor, math.ceil, math.sqrt, math.rad, math.cos, math.sin
  local function P(x, y, c)
    if c and x >= 1 and x <= 62 and y >= top and y <= 70 then G[y * 64 + x] = c; TAG[y * 64 + x] = cur end
  end
  local function get(x, y) return G[y * 64 + x] end
  local function tag(x, y) return TAG[y * 64 + x] end
  local function mx(x) return 63 - x end
  local function lit(nx, ny, r)
    local d = nx * 0.55 + ny * 0.83
    if d > 0.92 and r.deep then return r.deep end
    if d > 0.42 then return r.shade end
    if d < -0.55 then return r.hi end
    return r.base
  end
  local function paint(r, x, y, nx, ny)
    if type(r) == "function" then return r(x, y, nx, ny) end
    if type(r) == "table" then return lit(nx, ny, r) end
    return r
  end
  local function E(cx, cy, rx, ry, r)
    for y = floor(cy - ry - 1), ceil(cy + ry + 1) do
      for x = floor(cx - rx - 1), ceil(cx + rx + 1) do
        local nx, ny = (x - cx) / rx, (y - cy) / ry
        if nx * nx + ny * ny <= 1 then P(x, y, paint(r, x, y, nx, ny)) end
      end
    end
  end
  -- rotated ellipse from (x0,y0) along (dx,dy), length L, half width w
  local function limb(x0, y0, dx, dy, L, w, r)
    local n = sqrt(dx * dx + dy * dy); dx, dy = dx / n, dy / n
    local cx, cy, R = x0 + dx * L / 2, y0 + dy * L / 2, L / 2 + w
    for y = floor(cy - R), ceil(cy + R) do
      for x = floor(cx - R), ceil(cx + R) do
        local px, py = x - cx, y - cy
        local u, v = (px * dx + py * dy) / (L / 2), (-px * dy + py * dx) / w
        if u * u + v * v <= 1 then P(x, y, paint(r, x, y, u * dx - v * dy, u * dy + v * dx)) end
      end
    end
  end
  local function line(x0, y0, x1, y1, c)
    local n = math.max(math.abs(x1 - x0), math.abs(y1 - y0), 1)
    for i = 0, n do P(floor(x0 + (x1 - x0) * i / n + 0.5), floor(y0 + (y1 - y0) * i / n + 0.5), c) end
  end
  local function stamp(x0, y0, rows, map)
    for j, row in ipairs(rows) do
      for i = 1, #row do
        local ch = row:sub(i, i)
        if ch ~= "." then P(x0 + i - 1, y0 + j - 1, map[ch]) end
      end
    end
  end
  -- paint pixels of part `back` that touch part `front` with colour c (inner separation line)
  local function sep(back, front, c)
    local list = {}
    for k, t in pairs(TAG) do
      if t == back then
        local x, y = k % 64, k // 64
        for _, d in ipairs({{1, 0}, {-1, 0}, {0, 1}, {0, -1}}) do
          if tag(x + d[1], y + d[2]) == front then list[#list + 1] = k; break end
        end
      end
    end
    for _, k in ipairs(list) do G[k] = c end
  end
  local function wingdir(sg, e) e = rad(e); return sg * cos(e), -sin(e) end
  -- wren: round russet ball, cream brow stripe, straw hat with a tail feather, teal vest, cocked tail, tiny scroll (quirk)
  local FE = {hi = H"#c88050", base = H"#b06a3a", shade = H"#7a4438", deep = H"#4e2c3a"}
  local BEL, BELS = H"#e2b97e", H"#cfb699"
  local HAT, HATS = H"#e0b052", H"#a87a48"
  local VEST = H"#2c4848"
  local EW = walk and ({[2] = 52, [1] = 16, [0] = -22, [-1] = -62})[s] or -72
  local sw = walk and (s >= 1 and -1 or (s < 0 and 1 or 0)) or 0
  local function scroll(x, y)   -- 4x3: rolled ends, cream sheet, ink line (one px wider than the spec so it reads)
    cur = "scroll"
    stamp(x, y, {"bccb", "ckkc", "bccb"}, {b = FE.base, c = BEL, k = INK})
  end
  local function eye(x, y)
    for j = 0, 2 do P(x, y + j, INK); P(x + 1, y + j, INK) end
    P(x, y, BEL)
  end
  local function bwing(sg, sx, sy, e, L, w)   -- barred wing, primaries darker at the tip
    local dx, dy = wingdir(sg, e)
    limb(sx, sy, dx, dy, L, w, function(x, y, nx, ny)
      local px, py = x - sx, y - sy
      local u = (px * dx + py * dy) / L
      local v = (-px * dy + py * dx) * sg
      if u > 0.72 then return (floor(v + 10) % 2 == 0) and FE.deep or FE.shade end
      if floor(u * L) % 3 == 0 and u > 0.2 then return FE.shade end
      return lit(nx, ny, FE)
    end)
  end
  local function tail(x0, y0, dx, dy, L)
    cur = "tail"
    limb(x0, y0, dx, dy, L, 2.6, function(x, y, nx, ny)
      local u = ((x - x0) * dx + (y - y0) * dy) / sqrt(dx * dx + dy * dy)
      if floor(u) % 3 == 2 then return FE.deep end
      return lit(nx, ny, FE)
    end)
  end
  local function leg(cx, lift, dark)
    local bot = 70 + lift
    cur = "leg"
    for y = 62 + b, bot do P(cx, y, dark and FE.shade or HATS) end
    P(cx - 1, bot, dark and FE.deep or HATS); P(cx + 1, bot, dark and FE.deep or HATS); P(cx + 2, bot, dark and FE.deep or HATS)
  end
  local function hat(cx, cy, flip)   -- cy = brim row; tucked feather rises to the head top
    cur = "feather"
    local fx = flip and floor(cx - 5) or ceil(cx + 5)
    local sg = flip and -1 or 1
    line(fx, cy - 4, fx + sg * 3, top, FE.base)
    line(fx + sg, cy - 4, fx + sg * 4, top + 1, FE.shade)
    P(fx + sg * 3, top, FE.hi)
    cur = "hat"
    E(cx, cy, 13.5, 2.6, function(x, y, nx, ny)
      if ny < -0.4 then return HAT end
      if ny > 0.3 or nx > 0.8 then return HATS end
      return HAT
    end)
    for y = cy - 6, cy - 1 do
      for x = floor(cx - 6.5), ceil(cx + 6.5) do
        local yy = y - (cy - 6)
        if not (yy == 0 and (x == floor(cx - 6.5) or x == ceil(cx + 6.5))) then
          local c = ((x - y) % 4 == 0) and HATS or HAT
          if x >= cx + 5 then c = HATS end
          if yy == 3 or yy == 4 then c = VEST end
          P(x, y, c)
        end
      end
    end
  end

  if view == "front" or view == "back" then
    local front = view == "front"
    local ftVL, ftVR = o.footR, o.footL
    if not front then ftVL, ftVR = o.footL, o.footR end
    leg(27, ftVL); leg(36, ftVR)
    cur = "body"
    E(31.5, 51 + b, 11.5, 12.5, FE)
    if front then
      cur = "belly"
      E(31.5, 53 + b, 6.5, 9.5, function(x, y, nx, ny) return (nx > 0.55 or ny > 0.7) and BELS or BEL end)
      cur = "vest"
      for y = 42, 58 do
        for x = 20, 43 do
          local ax = math.abs(x - 31.5)
          if tag(x, y + b) and (ax >= 5 + (y - 42) * 0.12) and (ax <= 5 + (y - 42) * 0.12 + 5.5) then P(x, y + b, VEST) end
        end
      end
      P(25, 50 + b, HAT); P(25, 54 + b, HAT)
    else
      for _, yy in ipairs({46, 50, 54, 58}) do
        for x = 22, 41 do if tag(x, yy + b) == "body" and (x + yy) % 5 ~= 0 then P(x, yy + b, FE.shade) end end
      end
      cur = "vest"
      for y = 42, 57 do for x = 21, 42 do
        if tag(x, y + b) == "body" and (x <= 24 or x >= 39) then P(x, y + b, VEST) end
      end end
      for x = 25, 38 do if tag(x, 42 + b) then P(x, 42 + b, VEST) end end
      tail(33, 57 + b, 0.5, -1, 15)
    end
    -- wings at the sides
    cur = "wing"
    bwing(-1, 22, 44 + b, EW, 13, 3.6); bwing(1, 41, 44 + b, EW, 13, 3.6)
    -- head (one round ball with the body)
    cur = "face"
    E(31.5, 31 + hd, 10.5, 9, function(x, y, nx, ny)
      local d = nx * 0.55 + ny * 0.83
      if d > 0.7 then return FE.shade end
      if d < -0.55 then return FE.hi end
      return FE.base
    end)
    if front then
      E(31.5, 38 + hd, 6.5, 2.4, function(x, y, nx, ny) return ny > 0.4 and BELS or BEL end)
      for x = 24, 28 do P(x, 26 + hd, BEL) end
      for x = 35, 39 do P(x, 26 + hd, BEL) end
      eye(26, 28 + hd); eye(36, 28 + hd)
      P(23, 32 + hd, FE.hi); P(24, 32 + hd, FE.hi); P(39, 32 + hd, FE.hi); P(40, 32 + hd, FE.hi)
      cur = "beak"
      stamp(30, 31 + hd, {"cccs", ".cs."}, {c = HAT, s = HATS})
      scroll(30 + sw, 33 + hd)
      cur = "band"
      for j = 0, 2 do for x = 27 + j, 36 - j do P(x, 40 + j + b, VEST) end end
    else
      for x = 22, 41 do if tag(x, 33 + hd) == "face" then P(x, 33 + hd, FE.shade) end end
    end
    hat(31.5, 22 + hd, not front)
    if not front then
      local hx = 44 + (walk and sw or 0)
      cur = "hand"; E(hx + 1, 55 + b, 1.6, 1.6, FE)
      scroll(hx - 1, 56 + b)
    end
    sep("wing", "body", FE.deep); sep("wing", "vest", FE.deep); sep("tail", "body", FE.deep)
    sep("face", "hat", HATS); sep("feather", "hat", FE.deep)
    sep("body", "scroll", FE.deep); sep("belly", "scroll", BELS)
    sep("face", "scroll", FE.deep); sep("face", "beak", FE.shade)
    sep("face", "body", FE.shade)
  else
    -- side, facing right
    local e = EW
    if walk then cur = "fwing"; local dx, dy = wingdir(-1, e + 14); limb(27, 44 + b, dx, dy, 12, 3.4, {hi = FE.shade, base = FE.shade, shade = FE.deep, deep = FE.deep}) end
    leg(30, o.footL, true); leg(34, o.footR)
    tail(23, 54 + b, -0.55, -1, 15)
    cur = "body"
    E(31.5, 52 + b, 11, 11.5, FE)
    cur = "belly"
    E(36, 54 + b, 5, 8.5, function(x, y, nx, ny)
      if tag(x, y) ~= "body" then return nil end
      return (ny > 0.6) and BELS or BEL
    end)
    cur = "vest"
    for y = 42, 58 do for x = 28, 43 do
      local t = tag(x, y + b)
      if (t == "body" or t == "belly") and x >= 30 and x <= 33 + floor((y - 42) * 0.1) then P(x, y + b, VEST) end
    end end
    P(32, 49 + b, HAT)
    cur = "face"
    E(33.5, 31 + hd, 9.5, 8.6, FE)
    E(37, 37.5 + hd, 5, 2.4, function(x, y, nx, ny) return ny > 0.4 and BELS or BEL end)
    for x = 37, 41 do P(x, 26 + hd, BEL) end
    eye(39, 28 + hd)
    cur = "beak"
    stamp(43, 31 + hd, {"cc..", "cccc", "ss.."}, {c = HAT, s = HATS})
    scroll(44 + sw, 33 + hd)
    hat(32.5, 22 + hd, true)
    cur = "wing"
    bwing(-1, 30, 44 + b, e, 14, 4)
    sep("wing", "body", FE.deep); sep("wing", "vest", FE.deep); sep("wing", "belly", FE.deep)
    sep("tail", "body", FE.deep); sep("fwing", "body", FE.deep)
    sep("face", "hat", HATS); sep("feather", "hat", FE.deep); sep("face", "body", FE.shade)
    sep("face", "scroll", FE.deep)
  end
  for k, c in pairs(G) do img:putPixel(k % 64, k // 64, c) end
  N.outline(img, INK)
end
return S
