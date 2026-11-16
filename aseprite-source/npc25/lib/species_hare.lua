-- hare (hopper) tables from specs/hare.md. Opus: replace S.draw_figure only (body-plan helper: D.hopper).
local N = dofile((app.params.root or "npc25") .. "/lib/npc25.lua")
local D = dofile((app.params.root or "npc25") .. "/lib/draft_common.lua")
local S = {name = "hare", feet_y = 71, outline = "#2b1c26", plan = "hopper", T = 7, W = 36}
S.ramps = {main = {"#e0b480", "#c99a62", "#946a58", "#76503e"}}  -- hi, base, shade, deep
S.palette_list = {"#2b1c26", "#e0b480", "#c99a62", "#946a58", "#76503e", "#6e9e5a", "#4a6e54", "#2f4448", "#e0b858", "#ae8044", "#e2929a", "#efdcb8", "#aaa9b8", "#74758c"}
-- {body y, head y, footL, footR, armL, armR}
S.idle = {{0, 0, 0, 0, 0, 0}, {-1, -1, 0, 0, 0, 0}}
S.walk = {{1, 1, 0, 0, -1, -1}, {-2, -2, -2, -2, 1, 1}, {-3, -3, -3, -3, 2, 2}, {-1, -1, -1, -1, 1, 1}, {0, 0, 0, 0, -2, -2}, {0, -1, 0, 0, -1, -1}}
local h = N.hex
S.c = {
  body = h"#c99a62",
  bshade = h"#946a58",
  bhi = h"#e0b480",
  deep = h"#76503e",
  head = h"#c99a62",
  hat = h"#e0b858",
  hatshade = h"#ae8044",
  wing = h"#946a58",
  belly = h"#e2929a",
  acc = h"#6e9e5a",
  accs = h"#4a6e54",
  eye = h"#e2929a",
  q = h"#ae8044",
  qshade = h"#76503e",
  qhi = h"#ae8044",
  ink = h"#76503e", arm = h"#c99a62", fbase = h"#946a58", fshade = h"#76503e"}
S.bw, S.top = 20, 8
S.quirk = {w = 1, h = 8, anchor = "hand", hex = "#ae8044"}

-- Stage 3 (Opus) replaces this with the real art: one 64x80 frame (transparent bg, hard pixels, outline included).
-- img: Image 64x80 RGBA, view: "front"|"back"|"side", frame: 1..8, species: this table.
function S.draw_figure(img, view, frame, species)
  -- Hare farmhand: tall pink-lined ears poking through a straw hat, green overalls,
  -- big hind feet, cream tail puff, and a crooked walking stick in the near (right) paw.
  local o = N.offsets(species, frame)
  local H = N.hex
  local INK = H(species.outline)
  local CREAM, PINK = H"#efdcb8", H"#e2929a"
  local F = {hl = CREAM, hi = H"#e0b480", base = H"#c99a62", shade = H"#946a58", deep = H"#76503e"}
  local FF = {hl = F.base, hi = F.base, base = F.shade, shade = F.deep, deep = F.deep}
  local OV = {hl = H"#6e9e5a", hi = H"#6e9e5a", base = H"#4a6e54", shade = H"#2f4448", deep = H"#2f4448"}
  local OVL = {hl = OV.hi, hi = OV.hi, base = OV.hi, shade = OV.base, deep = OV.deep}
  local HAT = {hl = CREAM, hi = H"#e0b858", base = H"#e0b858", shade = H"#ae8044", deep = F.deep}
  local WOOD, WOODS = H"#ae8044", H"#76503e"
  local SHL, SHD = H"#aaa9b8", H"#74758c"
  local b, hd = o.body, o.head
  local lift = -math.min(o.footL, o.footR)
  local G = {}
  local floor, ceil, sin, cos, sqrt, abs = math.floor, math.ceil, math.sin, math.cos, math.sqrt, math.abs
  local function P(x, y, c)
    x, y = floor(x + 0.5), floor(y + 0.5)
    if c and x >= 1 and x <= 62 and y >= 1 and y <= 70 then G[y * 64 + x] = c end
  end
  local function ell(cx, cy, rx, ry, fn)
    for y = floor(cy - ry - 1), ceil(cy + ry + 1) do
      for x = floor(cx - rx - 1), ceil(cx + rx + 1) do
        local nx, ny = (x - cx) / rx, (y - cy) / ry
        local d = nx * nx + ny * ny
        if d <= 1 then P(x, y, fn(x, y, nx, ny, d)) end
      end
    end
  end
  local function lit(nx, ny, r)
    local s = nx * 0.55 + ny * 0.83
    if s > 0.88 then return r.deep end
    if s > 0.38 then return r.shade end
    if s < -0.86 then return r.hl end
    if s < -0.34 then return r.hi end
    return r.base
  end
  local function E(cx, cy, rx, ry, r) ell(cx, cy, rx, ry, function(x, y, nx, ny) return lit(nx, ny, r) end) end
  -- capsule from (x1,y1) to (x2,y2), radius r
  local function cap(x1, y1, x2, y2, r, fn)
    local dx, dy = x2 - x1, y2 - y1
    local L2 = dx * dx + dy * dy + 1e-6
    for y = floor(math.min(y1, y2) - r - 1), ceil(math.max(y1, y2) + r + 1) do
      for x = floor(math.min(x1, x2) - r - 1), ceil(math.max(x1, x2) + r + 1) do
        local t = math.max(0, math.min(1, ((x - x1) * dx + (y - y1) * dy) / L2))
        local ex, ey = x - (x1 + dx * t), y - (y1 + dy * t)
        if ex * ex + ey * ey <= r * r then P(x, y, fn(x, y, ex / r, ey / r, t)) end
      end
    end
  end
  -- ellipse rotated by ang (radians from vertical, + leans right); u = along axis (+1 tip), v = across (+ right)
  local function rell(cx, cy, a, r, ang, fn)
    local ux, uy, px, py = sin(ang), -cos(ang), cos(ang), sin(ang)
    local R = math.max(a, r) + 1
    for y = floor(cy - R), ceil(cy + R) do
      for x = floor(cx - R), ceil(cx + R) do
        local dx, dy = x - cx, y - cy
        local u, v = (dx * ux + dy * uy) / a, (dx * px + dy * py) / r
        if u * u + v * v <= 1 then P(x, y, fn(x, y, u, v)) end
      end
    end
  end
  -- ear: top pixel row = top, base point (bx, by), length 2a
  local function ear(bx, by, top, ang, ramp, inner)
    local a, r = 7.6, 2.6
    local ext = sqrt((a * cos(ang)) ^ 2 + (r * sin(ang)) ^ 2)
    local cy = top + ext - 0.45
    local cx = bx + sin(ang) * (by - cy) / cos(ang)
    rell(cx, cy, a, r, ang, function(x, y, u, v)
      if u > 0.76 then return ramp.deep end
      if u > 0.6 and v > -0.2 then return ramp.deep end
      if inner and u > -0.8 and u < 0.62 and v > -0.55 and v < 0.25 then return PINK end
      if v < -0.45 then return ramp.hi end
      if v > 0.5 then return ramp.shade end
      return ramp.base
    end)
  end
  -- splay of the ears per frame: ears lag behind the hop (droop out at the apex)
  local lag = ({0, 0, -0.04, 0.1, 0.2, 0.12, 0.0, 0.04})[frame]

  -- ground shadow (shrinks while airborne); keeps row 71 inked
  local srx = 13 - lift
  ell(31.5, 68, srx, 2.6, function(x, y, nx, ny)
    if ((nx + 0.12) ^ 2 + (ny + 0.25) ^ 2) < 0.55 then return SHL end
    return SHD
  end)

  local function stick(sx, ty, bot, dir)
    sx = floor(sx + 0.5); ty = floor(ty + 0.5); bot = math.min(70, floor(bot + 0.5))
    for y = ty, bot do P(sx, y, ((y - ty) % 5 == 3 or y == bot) and WOODS or WOOD) end
    P(sx + dir, ty - 1, WOOD); P(sx, ty - 1, WOOD); P(sx + 2 * dir, ty, WOOD); P(sx + 2 * dir, ty + 1, WOODS)
  end
  local function hat(cx, by, crx, brx, back)
    local x1, x2 = floor(cx - crx + 0.5), floor(cx + crx - 0.5)
    for y = by - 5, by - 1 do
      for x = x1, x2 do
        local yy = y - (by - 5)
        if not (yy == 0 and (x == x1 or x == x2)) then
          local c = HAT.base
          if (x + 2 * y) % 5 == 0 then c = HAT.shade end
          if x >= x2 - 1 then c = HAT.shade end
          if yy == 0 and x > x1 and x < x2 - 2 then c = (x % 3 == 0) and HAT.base or HAT.hl end
          if yy == 3 then c = (x == x1 and not back) and OV.hi or OV.base end
          if yy == 4 then c = OV.shade end
          P(x, y, c)
        end
      end
    end
    ell(cx, by + 0.6, brx, 1.7, function(x, y, nx, ny)
      if ny > 0.3 or nx > 0.82 then return HAT.shade end
      if (x + y) % 4 == 0 then return HAT.shade end
      if ny < -0.3 and nx < -0.4 then return HAT.hl end
      return HAT.base
    end)
  end

  if view == "front" or view == "back" then
    local front = view == "front"
    local CX = 31.5
    local function mx(x) return 63 - x end
    -- legs + hind feet (big ovals)
    for _, s in ipairs({-1, 1}) do
      local ft = s < 0 and (front and o.footR or o.footL) or (front and o.footL or o.footR)
      local fx = s < 0 and 24.5 or mx(24.5)
      cap(s < 0 and 26.5 or mx(26.5), 60 + b, fx, 66 + ft, 2.8, function(x, y, nx, ny) return lit(nx, ny, F) end)
      local up = ft < 0
      local cy, rx, ry = 67.6 + ft, up and 3.6 or 4.6, up and 3.1 or 2.7
      if up then cy = 67.3 + ft end
      ell(fx, cy, rx, ry, function(x, y, nx, ny)
        if front then
          if ny > 0.55 and (x == floor(fx) - 1 or x == floor(fx) + 1) then return F.deep end
          if up and ny > 0.4 then return F.shade end
          return lit(nx, ny, F)
        end
        if ny > 0.35 then return up and F.deep or F.shade end
        return lit(nx, ny, FF)
      end)
    end
    -- torso with overalls
    ell(CX, 52 + b, 9.6, 10.4, function(x, y, nx, ny)
      local yy = y - b
      local ax = abs(x - CX)
      if front then
        if yy >= 47 and ax <= 4.5 and yy <= 53 then
          if x == 36 then return OV.base end
          if yy == 50 and ax <= 2 then return OV.base end
          if yy == 47 and x > 27 and x < 35 then return HAT.hi end
          return OV.hi
        end
        if yy >= 53 then
          if yy >= 59 and x == 32 then return OV.deep end
          return lit(nx, ny, OVL)
        end
        return lit(nx, ny, F)
      end
      if yy >= 51 then
        return lit(nx, ny, OVL)
      end
      return lit(nx, ny, F)
    end)
    if front then
      ell(CX, 44.2 + b, 3.6, 2.6, function() return CREAM end)
      for i = 0, 4 do
        local y = 47 - i
        local x = 27 - floor(i / 2)
        P(x, y + b, OV.hi); P(mx(x), y + b, OV.base)
      end
      P(27, 47 + b, HAT.base); P(36, 47 + b, HAT.base)
    else
      -- crossed straps
      for i = 0, 8 do
        P(26 + i, 43 + i + b, OV.base); P(37 - i, 43 + i + b, OV.hi)
      end
      P(31, 47 + b, HAT.base)
      -- tail puff
      ell(CX, 56.5 + b, 2.7, 2.5, function(x, y, nx, ny)
        if nx * 0.55 + ny * 0.83 > 0.5 then return F.hi end
        return CREAM
      end)
    end
    -- arms; stick in the creature's right paw (front: viewer-left, back: viewer-right)
    local stickSide = front and -1 or 1
    for _, s in ipairs({-1, 1}) do
      local a = (s < 0) == front and o.armR or o.armL
      local spread = math.max(a, 0)
      local px = s < 0 and (21.5 - spread * 0.8) or mx(21.5 - spread * 0.8)
      local py = 54 + b - a * 1.5
      local sx = s < 0 and 23.5 or mx(23.5)
      if s == stickSide then stick(px + s * 2, py - 7, py + 17, s) end
      cap(sx, 45 + b, px, py - 1, 2.3, function(x, y, nx, ny) return lit(nx, ny, F) end)
      ell(px, py, 2.5, 2.3, function(x, y, nx, ny)
        if not front and ny < 0.2 then return F.base end
        if ny > 0.55 and x == floor(px + 0.5) then return F.deep end
        return lit(nx, ny, F)
      end)
    end
    -- head
    ell(CX, 32 + hd, 10.4, 8.2, function(x, y, nx, ny) return lit(nx, ny, F) end)
    ell(21.6, 35.5 + hd, 2.3, 2.5, function(x, y, nx, ny) return lit(nx, ny, F) end)
    ell(mx(21.6), 35.5 + hd, 2.3, 2.5, function(x, y, nx, ny) return lit(nx, ny, F) end)
    if front then
      ell(CX, 36.4 + hd, 4.1, 2.3, function() return CREAM end)
      for x = 30, 33 do P(x, 34 + hd, PINK) end
      P(31, 35 + hd, PINK); P(32, 35 + hd, PINK)
      P(31, 36 + hd, F.deep); P(32, 36 + hd, F.deep)
      P(30, 37 + hd, F.deep); P(33, 37 + hd, F.deep)
      for _, ex in ipairs({26, 36}) do
        for y = 30, 32 do P(ex, y + hd, INK); P(ex + 1, y + hd, INK) end
        P(ex, 30 + hd, CREAM)
        P(ex, 29 + hd, F.hi); P(ex + 1, 29 + hd, F.hi)
      end
      P(23, 35 + hd, PINK); P(24, 35 + hd, PINK); P(39, 35 + hd, PINK); P(40, 35 + hd, PINK)
    else
      for x = 24, 39 do P(x, 39 + hd, F.shade) end
    end
    -- ears, then the hat over their roots
    local top = 8 + hd
    ear(27.2, 22 + hd, top, -0.12 - lag, F, front)
    ear(mx(27.2), 22 + hd, top, 0.12 + lag, F, front)
    hat(CX, 24 + hd, 5.5, 10.5, not front)
    if not front then P(31, 26 + hd, OV.base); P(32, 26 + hd, OV.base); P(31, 27 + hd, OV.shade) end
  else
    -- side, facing right; near side = creature right
    local poses = {
      {25, 68.6, 36, 68.6}, {25, 68.6, 36, 68.6}, {25, 68.6, 36, 68.6},
      {22, 63.4, 31.5, 66.6}, {20, 62.0, 29.5, 64.4}, {24, 65.6, 34.5, 67.6},
      {25, 68.6, 36, 68.6}, {25, 68.6, 36, 68.6},
    }
    local pz = poses[frame]
    local function hind(dx, dy, r, haunch)
      cap(27 + dx, 61 + b + dy, pz[1] + dx + 1, pz[2] + dy - 1, 2.2, function(x, y, nx, ny) return lit(nx, ny, r) end)
      cap(pz[1] + dx, pz[2] + dy, pz[3] + dx, pz[4] + dy, 1.9, function(x, y, nx, ny, t)
        if t > 0.86 and ny > -0.2 then return r.deep end
        return lit(nx, ny, r)
      end)
    end
    hind(2, -1, FF)
    -- tail puff
    ell(22.6, 55 + b, 2.7, 2.6, function(x, y, nx, ny)
      if nx * 0.55 + ny * 0.83 > 0.45 then return F.hi end
      return CREAM
    end)
    -- torso
    ell(30.5, 52 + b, 8.6, 10.2, function(x, y, nx, ny)
      local yy = y - b
      if yy >= 53 then return lit(nx, ny, OVL) end
      if x >= 34 and yy >= 47 then
        if yy == 47 then return OV.hi end
        return x >= 38 and OV.base or OV.hi
      end
      return lit(nx, ny, F)
    end)
    ell(36, 45.5 + b, 2.4, 2.8, function() return CREAM end)
    for i = 0, 4 do P(34 - i, 47 - i + b, OV.hi) end
    P(34, 47 + b, HAT.base)
    -- haunch in the overalls
    ell(27.5, 59 + b, 5.6, 4.8, function(x, y, nx, ny)
      if nx * 0.55 + ny * 0.83 > 0.86 then return OV.deep end
      if y - b == 56 and x <= 26 then return OV.hi end
      return lit(nx, ny, OVL)
    end)
    hind(0, 0, F)
    -- near arm + stick
    local a = o.armR
    local px, py = 37.5 + a * 1.2, 52 + b - a * 0.9
    stick(px + 0.5, py - 6, py + 18, 1)
    cap(33, 46 + b, px, py - 1, 2.3, function(x, y, nx, ny) return lit(nx, ny, F) end)
    ell(px, py, 2.4, 2.2, function(x, y, nx, ny)
      if ny > 0.5 and x == floor(px + 0.5) then return F.deep end
      return lit(nx, ny, F)
    end)
    -- neck + head
    ell(33.5, 41 + hd, 4.8, 3, function(x, y, nx, ny) return lit(nx, ny, F) end)
    ell(35, 32 + hd, 8.8, 7.6, function(x, y, nx, ny) return lit(nx, ny, F) end)
    ell(41.6, 35 + hd, 4.1, 3.0, function(x, y, nx, ny)
      if ny > 0.35 then return CREAM end
      return lit(nx, ny, F)
    end)
    P(45, 33 + hd, PINK); P(44, 33 + hd, PINK); P(45, 34 + hd, PINK)
    P(43, 36 + hd, F.deep); P(44, 35 + hd, F.deep)
    for y = 30, 32 do P(38, y + hd, INK); P(39, y + hd, INK) end
    P(38, 30 + hd, CREAM); P(38, 29 + hd, F.hi); P(39, 29 + hd, F.hi)
    P(39, 34 + hd, PINK); P(40, 34 + hd, PINK)
    P(30, 32 + hd, F.shade); P(30, 33 + hd, F.shade); P(31, 34 + hd, F.shade)
    -- ears laid back, far ear first
    local top = 8 + hd
    ear(35.4, 22 + hd, top + 1, -0.32 - lag, FF, false)
    ear(32.6, 22 + hd, top, -0.48 - lag, F, true)
    hat(34, 24 + hd, 4.5, 9.8, false)
  end
  for k, c in pairs(G) do img:putPixel(k % 64, k // 64, c) end
  N.outline(img, INK)
end
return S
