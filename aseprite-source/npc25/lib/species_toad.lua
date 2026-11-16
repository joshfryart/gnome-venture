-- toad (hopper) tables from specs/toad.md. Opus: replace S.draw_figure only (body-plan helper: D.hopper).
local N = dofile((app.params.root or "npc25") .. "/lib/npc25.lua")
local D = dofile((app.params.root or "npc25") .. "/lib/draft_common.lua")
local S = {name = "toad", feet_y = 71, outline = "#2b1c26", plan = "hopper", T = 9, W = 38}
S.ramps = {main = {"#a3b85a", "#7f9a40", "#566e44", "#383c4e"}}  -- hi, base, shade, deep
S.palette_list = {"#2b1c26", "#a3b85a", "#7f9a40", "#566e44", "#383c4e", "#6c8aba", "#4c5a8c", "#34365e", "#deb658", "#a87e44", "#c45230", "#dcc47c", "#aaa9b8", "#74758c"}
-- {body y, head y, footL, footR, armL, armR}
S.idle = {{0, 0, 0, 0, 0, 0}, {-1, -1, 0, 0, 0, 0}}
S.walk = {{1, 1, 0, 0, -1, -1}, {-2, -2, -2, -2, 1, 1}, {-3, -3, -3, -3, 2, 2}, {-1, -1, -1, -1, 1, 1}, {0, 0, 0, 0, -2, -2}, {0, -1, 0, 0, -1, -1}}
local h = N.hex
S.c = {
  body = h"#7f9a40",
  bshade = h"#566e44",
  bhi = h"#a3b85a",
  deep = h"#383c4e",
  head = h"#7f9a40",
  hat = h"#deb658",
  hatshade = h"#a87e44",
  wing = h"#566e44",
  belly = h"#c45230",
  acc = h"#6c8aba",
  accs = h"#4c5a8c",
  eye = h"#c45230",
  q = h"#566e44",
  qshade = h"#7f9a40",
  qhi = h"#a87e44",
  ink = h"#383c4e", arm = h"#7f9a40", fbase = h"#566e44", fshade = h"#383c4e"}
S.bw, S.top = 20, 10
S.quirk = {w = 5, h = 3, anchor = "crown", hex = "#566e44"}

-- Stage 3 (Opus) replaces this with the real art: one 64x80 frame (transparent bg, hard pixels, outline included).
-- img: Image 64x80 RGBA, view: "front"|"back"|"side", frame: 1..8, species: this table.
function S.draw_figure(img, view, frame, species)
  -- Toad farmhand: wide warty head, heavy-lidded gold eyes, throat that puffs while breathing,
  -- blue overalls, folded hind legs, and a mound of moss (two pebbles) growing on the straw hat.
  local o = N.offsets(species, frame)
  local H = N.hex
  local INK = H(species.outline)
  local BELLY, WART = H"#dcc47c", H"#c45230"
  local K = {hl = H"#a3b85a", hi = H"#a3b85a", base = H"#7f9a40", shade = H"#566e44", deep = H"#383c4e"}
  local KF = {hl = K.base, hi = K.base, base = K.shade, shade = K.deep, deep = K.deep}
  local OV = {hl = H"#6c8aba", hi = H"#6c8aba", base = H"#4c5a8c", shade = H"#34365e", deep = H"#34365e"}
  local OVL = {hl = OV.hi, hi = OV.hi, base = OV.hi, shade = OV.base, deep = OV.deep}
  local HAT = {hl = BELLY, hi = H"#deb658", base = H"#deb658", shade = H"#a87e44", deep = K.deep}
  local MOSS, MOSSHI, PEBBLE = H"#566e44", H"#7f9a40", H"#a87e44"
  local SHL, SHD = H"#aaa9b8", H"#74758c"
  local b, hd = o.body, o.head
  local lift = -math.min(o.footL, o.footR)
  local G = {}
  local floor, ceil, sqrt, abs = math.floor, math.ceil, math.sqrt, math.abs
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
  -- warty skin: lit ramp plus red warts and darker mottling on a fixed hash (warts stay put on the body)
  local function skin(r, oy, warts)
    return function(x, y, nx, ny)
      local c = lit(nx, ny, r)
      local yy = y - oy
      if warts and nx * nx + ny * ny < 0.8 then
        local hsh = (x * 7 + yy * 13) % 37
        if hsh == 0 then return WART end
        if (x * 5 + yy * 11) % 19 == 0 and c ~= r.deep then return r.shade end
      end
      return c
    end
  end
  local sway = ({0, 0, 0, 0, 1, 1, 0, -1})[frame]
  local breathe = (frame == 2 or frame == 8) and 1 or 0
  local function moss(cx, top)
    ell(cx, top + 2.42, 3.7, 2.5, function(x, y, nx, ny)
      if y > top + 3 then return nil end
      if nx * 0.55 + ny * 0.83 < -0.3 then return MOSSHI end
      if (x + y) % 3 == 0 and ny < 0.4 then return MOSSHI end
      return MOSS
    end)
    P(cx - 1.6, top + 2, PEBBLE); P(cx + 1.4, top + 1, PEBBLE)
  end
  local function hat(cx, by, crx, brx, band)
    local x1, x2 = floor(cx - crx + 0.5), floor(cx + crx - 0.5)
    for y = by - 5, by - 1 do
      for x = x1, x2 do
        local yy = y - (by - 5)
        if not (yy == 0 and (x == x1 or x == x2)) then
          local c = HAT.base
          if (x + 2 * y) % 5 == 0 then c = HAT.shade end
          if x >= x2 - 1 then c = HAT.shade end
          if yy == 0 and x > x1 and x < x2 - 2 then c = HAT.hl end
          if yy == 3 and band then c = WART end
          if yy == 4 and band then c = HAT.shade end
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
  -- gold eye with heavy upper lid, horizontal pupil; look = -1/0/1 iris shift
  local function eye(cx, cy, look, front)
    ell(cx, cy, 4.6, 4.4, function(x, y, nx, ny) return lit(nx, ny, K) end)
    if not front then
      P(cx - 1, cy - 2, K.hi); P(cx, cy - 2, K.hi); P(cx - 2, cy - 1, K.hi)
      return
    end
    ell(cx + look * 0.7, cy + 0.5, 3.2, 3.1, function(x, y, nx, ny)
      if ny < -0.62 then return K.shade end -- heavy lid
      if ny > 0.5 or (nx > 0.6 and ny > 0) then return HAT.shade end
      return HAT.base
    end)
    local px = floor(cx + look * 0.7 + 0.5)
    for k = -1, 1 do P(px + k, cy + 1, INK) end
    P(px - 1, cy - 0, HAT.hl); P(px - 2, cy, HAT.hl)
  end

  -- ground shadow (shrinks while airborne)
  ell(31.5, 68, 14 - lift, 2.6, function(x, y, nx, ny)
    if ((nx + 0.12) ^ 2 + (ny + 0.25) ^ 2) < 0.55 then return SHL end
    return SHD
  end)

  if view == "front" or view == "back" then
    local front = view == "front"
    local CX = 31.5
    local function mx(x) return 63 - x end
    -- hind legs folded at the sides: thigh, then a webbed foot that points out
    local splay = ({0, 0, 0.5, 0, 1.5, 0.5, 0, 0})[frame]
    for _, s in ipairs({-1, 1}) do
      local ft = s < 0 and (front and o.footR or o.footL) or (front and o.footL or o.footR)
      local up = ft < 0
      local tx = 21.5 - splay
      local fx = 20 - splay
      if s > 0 then tx, fx = mx(tx), mx(fx) end
      ell(tx, 59.5 + b, 5.2, 4.6, skin(front and K or K, b, true))
      if up then
        cap(tx, 61 + b, fx, 66 + ft, 2.2, function(x, y, nx, ny) return lit(nx, ny, K) end)
      end
      local fy = 69 + ft
      ell(fx, fy, up and 3.6 or 4.8, up and 2.0 or 1.7, function(x, y, nx, ny)
        if not front then return ny > 0 and K.deep or K.shade end
        if ny > 0.3 then return K.shade end
        return K.hi
      end)
      if not up then
        -- three spread toes
        local d = s
        P(fx + d * 5, fy, K.shade); P(fx + d * 5, fy + 1, K.shade)
        P(fx - d * 4, fy + 1, K.shade)
      end
    end
    -- torso
    ell(CX, 48.5 + b, 11.8, 11.4, function(x, y, nx, ny)
      local yy = y - b
      local ax = abs(x - CX)
      if front then
        if yy <= 39 and ax <= 4 then return BELLY end
        if yy >= 40 and ax <= 5.5 and yy <= 50 then
          if x == 37 then return OV.base end
          if yy == 45 and ax <= 2 then return OV.base end
          if yy == 46 and ax <= 1.5 then return HAT.base end
          return OV.hi
        end
        if yy >= 50 then
          if yy >= 57 and x == 32 then return OV.deep end
          return lit(nx, ny, OVL)
        end
        return skin(K, b, true)(x, y, nx, ny)
      end
      if yy >= 49 then return lit(nx, ny, OVL) end
      return skin(K, b, true)(x, y, nx, ny)
    end)
    if front then
      for i = 0, 2 do P(26 - floor(i / 2), 40 - i + b, OV.hi); P(mx(26 - floor(i / 2)), 40 - i + b, OV.base) end
      P(26, 40 + b, HAT.base); P(37, 40 + b, HAT.base)
    else
      for i = 0, 9 do P(25 + i, 39 + i + b, OV.base); P(38 - i, 39 + i + b, OV.hi) end
      for x = 28, 35 do P(x, 52 + b, OV.base) end
      P(28, 53 + b, OV.base); P(35, 53 + b, OV.base); for x = 28, 35 do P(x, 54 + b, OV.base) end
    end
    -- arms with three-toed hands
    for _, s in ipairs({-1, 1}) do
      local a = (s < 0) == front and o.armR or o.armL
      local spread = math.max(a, 0)
      local hx = s < 0 and (19.5 - spread) or mx(19.5 - spread)
      local hy = 52.5 + b - a * 1.2
      cap(s < 0 and 22 or mx(22), 41.5 + b, hx, hy - 1, 2.4, function(x, y, nx, ny) return lit(nx, ny, K) end)
      ell(hx, hy, 2.4, 2.0, function(x, y, nx, ny) return lit(nx, ny, K) end)
      for k = -1, 1 do P(hx + k * 1.6 - s * 0.2, hy + 2 + (k == 0 and 0.6 or 0), K.shade) end
    end
    -- head
    ell(CX, 28 + hd, 14.6, 9.2, skin(K, hd, true))
    if front then
      -- mouth line and throat
      for x = 20, 43 do P(x, 32 + hd, K.deep) end
      P(19, 31 + hd, K.deep); P(44, 31 + hd, K.deep); P(18, 30 + hd, K.deep); P(45, 30 + hd, K.deep)
      for x = 21, 42 do P(x, 33 + hd, K.shade) end
      ell(CX, 35.6 + hd, 6.5 + breathe, 2.4 + breathe * 0.6, function(x, y, nx, ny)
        if y <= floor(33 + hd) then return nil end
        if ny > 0.5 and nx > 0.2 then return HAT.base end
        return BELLY
      end)
      P(29, 27 + hd, K.deep); P(34, 27 + hd, K.deep)
      P(28, 26 + hd, K.hl); P(33, 26 + hd, K.hl)
    else
      for x = 22, 41 do P(x, 36 + hd, K.shade) end
    end
    hat(CX, 18 + hd, 4.5, 7.6, true)
    moss(CX + sway, 10 + hd)
    eye(22.5, 21.5 + hd, 0, front)
    eye(40.5, 21.5 + hd, 0, front)
  else
    -- side, facing right; near side = creature right
    local pose = ({
      {31, 62, 24, 67.4, 18, 68.6}, {31, 62, 24, 67.4, 18, 68.6}, {32, 62.5, 24, 67.6, 17, 68.6},
      {28, 62.5, 21, 65.2, 15, 66.6}, {26, 61.5, 19, 63.4, 13, 64.6}, {30, 62, 23, 66.0, 17, 67.6},
      {31, 62, 24, 67.4, 18, 68.6}, {31, 62, 24, 67.4, 18, 68.6},
    })[frame]
    local function hind(dx, dy, r)
      ell(25 + dx, 56.5 + b + dy, 6.2, 5.2, skin(r, b, r == K))
      cap(25 + dx, 58 + b + dy, pose[1] + dx, pose[2] + b + dy, 2.6, function(x, y, nx, ny) return lit(nx, ny, r) end)
      cap(pose[1] + dx, pose[2] + b + dy, pose[3] + dx, pose[4] + dy, 2.0, function(x, y, nx, ny) return lit(nx, ny, r) end)
      cap(pose[3] + dx, pose[4] + dy, pose[5] + dx, pose[6] + dy, 1.5, function(x, y, nx, ny, t)
        if ny > 0.2 then return r.shade end
        return r.hi
      end)
      P(pose[5] + dx - 1, pose[6] + dy + 1, r.shade)
    end
    hind(3, 0, KF)
    -- far arm
    local a = o.armR
    ell(42 + a * 0.8, 52.4 + b - a, 2.2, 1.8, function(x, y, nx, ny) return lit(nx, ny, KF) end)
    -- body
    ell(29, 48.5 + b, 11.4, 11.6, function(x, y, nx, ny)
      local yy = y - b
      if yy >= 49 then return lit(nx, ny, OVL) end
      if x >= 35 and yy >= 43 then
        if yy == 43 then return OV.hi end
        return x >= 39 and OV.base or OV.hi
      end
      return skin(K, b, true)(x, y, nx, ny)
    end)
    for i = 0, 3 do P(35 - i, 43 - i + b, OV.hi) end
    P(35, 43 + b, HAT.base)
    hind(0, 0, K)
    -- near arm
    local hx, hy = 39 + a * 1.2, 53 + b - a
    cap(35, 43 + b, hx, hy - 1, 2.3, function(x, y, nx, ny) return lit(nx, ny, K) end)
    ell(hx, hy, 2.4, 2.0, function(x, y, nx, ny) return lit(nx, ny, K) end)
    P(hx + 2.2, hy + 1.6, K.shade); P(hx + 0.6, hy + 2.4, K.shade)
    -- head, throat bulge below the chin
    ell(38.2, 30 + hd, 10.4, 8.6, skin(K, hd, true))
    ell(41.5, 37 + hd, 5.4 + breathe, 2.8 + breathe * 0.6, function(x, y, nx, ny)
      if ny > 0.45 and nx > -0.2 then return HAT.base end
      return BELLY
    end)
    for x = 35, 47 do P(x, 33 + hd, K.deep) end
    P(34, 32 + hd, K.deep); P(33, 31 + hd, K.deep)
    P(47, 28 + hd, K.deep); P(47, 27 + hd, K.hl)
    hat(33, 19 + hd, 4.5, 7.4, true)
    moss(33 + sway, 10 + hd)
    eye(41.5, 22.5 + hd, 1, true)
  end
  for k, c in pairs(G) do img:putPixel(k % 64, k // 64, c) end
  N.outline(img, INK)
end
return S
