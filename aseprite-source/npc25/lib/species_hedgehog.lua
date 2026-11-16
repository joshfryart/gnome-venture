-- hedgehog tables from specs/hedgehog.md. Opus: replace draw_figure only.
local N = dofile((app.params.root or "npc25") .. "/lib/npc25.lua")
local D = dofile((app.params.root or "npc25") .. "/lib/draft_common.lua")
local S = {name = "hedgehog", feet_y = 71, outline = "#2b1c26"}
S.ramps = {  -- hi, base, shade, deep
  fur = {"#d89a5c", "#8f5f3a", "#5e3a35", "#3d2532"},
  skin = {"#f0d8a8", "#e0b986", "#b38469", "#7d5763"},
  hat = {"#ffe38a", "#e0b453", "#d89a5c"}, band = "#6188bc",
  vest = {"#6a9a48", "#46704a", "#2f4a42"},
  lantern = {gold = "#f5b82e", hi = "#ffe38a", metal = "#aaa9b8", flame = "#fff4d6"},
}
S.palette_list = {"#2b1c26", "#d89a5c", "#8f5f3a", "#5e3a35", "#3d2532", "#f0d8a8", "#e0b986", "#b38469",
  "#7d5763", "#ffe38a", "#e0b453", "#6188bc", "#6a9a48", "#46704a", "#2f4a42", "#f5b82e", "#aaa9b8", "#fff4d6"}
-- {body y, head y, footL, footR, armL, armR}
S.idle = {{0, 0, 0, 0, 0, 0}, {-1, -1, 0, 0, 0, 0}}
S.walk = {{0, 0, 0, -2, 2, -2}, {-1, -1, 0, -1, 1, -1}, {-1, -1, -1, 0, 0, 0},
          {0, 0, -2, 0, -2, 2}, {-1, -1, -1, 0, -1, 1}, {-1, -1, 0, -1, 0, 0}}
local h = N.hex
S.c = {body = h"#8f5f3a", bshade = h"#5e3a35", bhi = h"#d89a5c", belly = h"#e0b986", arm = h"#e0b986",
  head = h"#e0b986", hat = h"#e0b453", ink = h"#3d2532", fbase = h"#e0b986", fshade = h"#b38469",
  q = h"#f5b82e", qhi = h"#fff4d6"}
S.bw, S.top = 28, 10
S.quirk = {w = 3, h = 3, y = 52, x = {front = 44, back = 17, side = 38}}

-- Stage 3 (Opus) fills this in: draw one 64x80 frame (transparent bg, hard pixels, outline included).
-- img: Image 64x80 RGBA, view: "front"|"back"|"side", frame: 1..8, species: this table.
function S.draw_figure(img, view, frame, species)
  local o = N.offsets(species, frame)
  local R, H = species.ramps, N.hex
  local INK = H(species.outline)
  -- spine ramp, 5 tones: deep, shade, base, hi, cream tip (skin hi)
  local FUR = {H(R.fur[4]), H(R.fur[3]), H(R.fur[2]), H(R.fur[1]), H(R.skin[1])}
  local SK = {hi = H(R.skin[1]), base = H(R.skin[2]), shade = H(R.skin[3]), deep = H(R.skin[4])}
  local SKF = {hi = SK.base, base = SK.shade, shade = SK.deep, deep = SK.deep} -- far limbs
  local HAT = {hi = H(R.hat[1]), base = H(R.hat[2]), shade = H(R.hat[3])}
  local BAND = H(R.band)
  local VE = {hi = H(R.vest[1]), base = H(R.vest[1]), shade = H(R.vest[2]), deep = H(R.vest[3])}
  local L = R.lantern
  local GOLD, GHI, METAL, CREAM = H(L.gold), H(L.hi), H(L.metal), H(L.flame)
  local CHEEK, NOSE = H("#f5809f"), H(R.fur[4])
  local b, hd = o.body, o.head
  local top = 10 + hd
  local G = {}
  local function P(x, y, c)
    if c and x >= 13 and x <= 50 and y >= top and y <= 70 then G[y * 64 + x] = c end
  end
  local function get(x, y) return G[y * 64 + x] end
  local function ell(cx, cy, rx, ry, fn)
    for y = math.floor(cy - ry - 4), math.ceil(cy + ry + 4) do
      for x = math.floor(cx - rx - 4), math.ceil(cx + rx + 4) do
        local nx, ny = (x - cx) / rx, (y - cy) / ry
        P(x, y, fn(x, y, nx, ny, nx * nx + ny * ny))
      end
    end
  end
  local function lit(nx, ny, r)
    local s = nx * 0.55 + ny * 0.83
    if s > 0.92 and r.deep then return r.deep end
    if s > 0.45 then return r.shade end
    if s < -0.55 then return r.hi end
    return r.base
  end
  local function E(cx, cy, rx, ry, r)
    ell(cx, cy, rx, ry, function(x, y, nx, ny, d)
      if d <= 1 then return type(r) == "table" and lit(nx, ny, r) or r end
    end)
  end
  -- spine mass: layered radiating quills from origin ox,oy, jagged edge
  local function spines(cx, cy, rx, ry, ox, oy, n, spike)
    ell(cx, cy, rx, ry, function(x, y, nx, ny, d)
      local dx, dy = x - ox, y - oy
      local r = math.sqrt(dx * dx + dy * dy) + 0.001
      local layer = math.floor(r / 5)
      local a = math.atan(dy, dx) * n / (2 * math.pi) + (layer % 2) * 0.5
      local u = a - math.floor(a)
      local tri = 1 - math.abs(2 * u - 1)
      local lim = 1 + spike * tri / math.min(rx, ry)
      if d > lim * lim then return nil end
      local v = r / 5 - layer
      local t = 3
      if u < 0.22 then t = 4 elseif u > 0.58 then t = 2 end
      if v < 0.3 then t = t - 1 end
      local s = nx * 0.55 + ny * 0.83
      if s > 0.3 then t = t - 1 end
      if s > 0.8 then t = t - 1 end
      if t == 4 and v > 0.7 and s < -0.45 then t = 5 end
      return FUR[math.max(1, math.min(5, t))]
    end)
  end
  local function lantern(x0, y0)
    local pat = {"..m..", ".m.m.", "oGGso", "oYcso", "oYYso", "oGsso", ".ooo."}
    local map = {m = METAL, G = GOLD, Y = GHI, c = CREAM, g = GOLD, s = HAT.shade}
    for j, row in ipairs(pat) do
      for i = 1, 5 do
        local ch = row:sub(i, i)
        local x, y = x0 + i - 1, y0 + j - 1
        if ch == "o" then
          if get(x, y) then P(x, y, INK) end
        elseif ch ~= "." then P(x, y, map[ch]) end
      end
    end
  end
  local function hat(cx, cy, crx, brx) -- cy = brim centre row (absolute)
    ell(cx, cy, brx, 2.2, function(x, y, nx, ny, d)
      if d <= 1 then
        if ny < -0.5 then return HAT.hi elseif ny > 0.4 or nx > 0.75 then return HAT.shade end
        return HAT.base
      end
    end)
    local x1, x2 = math.floor(cx - crx + 0.5), math.floor(cx + crx - 0.5)
    for y = cy - 6.5, cy - 1.5 do
      for x = x1, x2 do
        local yy = y - (cy - 6.5)
        if not (yy == 0 and (x == x1 or x == x2)) then
          local c = HAT.base
          if x <= x1 + 1 then c = HAT.hi elseif x >= x2 - 1 then c = HAT.shade end
          if yy == 0 and x > x1 + 1 and x < x2 - 2 then c = HAT.hi end
          if yy == 3 or yy == 4 then c = BAND end
          if yy == 4 and x >= x2 - 1 then c = INK end
          P(x, y, c)
        end
      end
    end
  end
  local CX = 31.5
  local function mx(x) return 63 - x end

  if view == "front" or view == "back" then
    local front = view == "front"
    -- limb mapping: front: viewer-right = creature left; back: viewer-left = creature left
    local armVL, armVR = o.armR, o.armL
    local ftVL, ftVR = o.footR, o.footL
    if not front then armVL, armVR, ftVL, ftVR = o.armL, o.armR, o.footL, o.footR end
    -- body spines behind
    spines(CX, 51 + b, 16, 12, CX, 38 + b, 22, 2.5)
    -- torso
    ell(CX, 55 + b, 11.5, 11.5, function(x, y, nx, ny, d)
      if d > 1 then return end
      local yy = y - b
      if yy == 54 then return (front and x >= 31 and x <= 32) and GOLD or VE.deep end
      if yy > 54 then
        if yy >= 63 and (x == 31 or x == 32) then return VE.deep end
        return lit(nx, ny, VE)
      end
      if front then
        local ax = math.abs(x - CX)
        if ax <= 5.5 and yy >= 47 then
          if yy == 49 and ax <= 2.5 then return VE.deep end
          if yy >= 50 and ax <= 2.5 then return VE.shade end
          return lit(nx, ny, VE)
        end
        if (ax == 4.5 or ax == 5.5) and yy >= 43 then return x > 32 and VE.shade or VE.base end
        return lit(nx, ny, SK)
      end
      return lit(nx, ny, VE)
    end)
    if front then P(26, 47 + b, GHI); P(37, 47 + b, GHI) end
    -- arms
    local function arm(a, side)
      local dy = front and a or -a
      local ax = side < 0 and 19.5 or mx(19.5)
      E(side < 0 and 20.5 or mx(20.5), 48 + b + dy / 2, 3, 4.5, FUR[1])
      E(ax, 52 + b + dy, 3.5, 3.3, FUR[1])
      E(side < 0 and 20.5 or mx(20.5), 48 + b + dy / 2, 2, 3.5, SK)
      E(ax, 52 + b + dy, 2.5, 2.3, SK)
      if front then P(math.floor(ax + 0.5) + (side < 0 and -1 or 0), 53 + b + dy, SK.shade) end
    end
    if not front then
      -- back spine skirt over the vest, straps over it
      spines(CX, 46 + b, 13.5, 9, CX, 34 + b, 22, 2)
      for yy = 43, 53 do
        local off = math.floor((53 - yy) / 4)
        for _, x in ipairs({25 + off, 26 + off}) do
          P(x, yy + b, VE.base); P(mx(x), yy + b, VE.shade)
        end
      end
    end
    arm(armVL, -1); arm(armVR, 1)
    -- feet
    local function foot(cx, lift)
      local bot = 70 + lift
      local lifted = lift < 0
      ell(cx, bot - 2.5, 3.2, 3, function(x, y, nx, ny, d)
        if d > 1 then return end
        if front then
          if (y >= bot - 1) and math.abs(x - cx) < 0.6 then return SK.deep end
          if lifted and y >= bot - 1 then return SK.shade end
          return lit(nx, ny, SK)
        end
        -- back: heels / soles
        if lifted then
          if y >= bot - 1 and math.abs(x - cx) <= 1 then return SK.deep end
          if y == bot - 4 and (x == cx - 2 or x == cx + 2) then return SK.deep end
          return SK.shade
        end
        if y == bot and math.abs(x - cx) <= 1 then return SK.deep end
        return lit(nx, ny, SKF)
      end)
    end
    foot(25, ftVL); foot(38, ftVR)
    -- lantern on the belt: front viewer-right, back viewer-left (creature's left)
    local sw = o.armL > 0 and 1 or (o.armL < 0 and -1 or 0)
    if front then lantern(41 + sw, 55 + b) else lantern(18 + sw, 55 + b) end
    -- head
    spines(CX, 27 + hd, 15.5, 14.5, CX, (front and 22 or 12) + hd, 26, 3.5)
    for _, s in ipairs({-1, 1}) do
      local ex = s < 0 and 18.5 or mx(18.5)
      E(ex, 23 + hd, 2.4, 2.4, front and SK or SKF)
      if front then P(s < 0 and 19 or 44, 23 + hd, SK.deep) end
    end
    if front then
      ell(CX, 31 + hd, 10, 9, function(x, y, nx, ny, d)
        if d > 1 then return end
        if y - hd < 26 - math.abs(x - CX) * 0.38 then return end
        if ny > 0.75 then return SK.shade end
        return lit(nx, ny, {hi = SK.hi, base = SK.base, shade = SK.shade})
      end)
      E(CX, 34 + hd, 4, 2.6, SK.hi)
      for x = 29, 34 do P(x, 37 + hd, SK.shade) end
      for x = 30, 33 do P(x, 35 + hd, NOSE) end
      P(31, 36 + hd, NOSE); P(32, 36 + hd, NOSE); P(31, 35 + hd, CREAM)
      P(30, 38 + hd, SK.deep); P(33, 38 + hd, SK.deep); P(31, 38 + hd, SK.shade); P(32, 38 + hd, SK.shade)
      for _, ex in ipairs({25, 37}) do
        for y = 28, 30 do P(ex, y + hd, INK); P(ex + 1, y + hd, INK) end
        P(ex, 28 + hd, CREAM)
      end
      P(23, 32 + hd, CHEEK); P(24, 32 + hd, CHEEK); P(39, 32 + hd, CHEEK); P(40, 32 + hd, CHEEK)
    end
    hat(CX, 16.5 + hd, 7, 12.5)
  else
    -- side, facing right. near side = creature right
    local sL, sR = -o.armL, -o.armR
    sL = sL + (sL > 0 and 1 or (sL < 0 and -1 or 0)) // 1
    sR = sR + (sR > 0 and 1 or (sR < 0 and -1 or 0)) // 1
    local function foot(cx, lift, far)
      local bot = 70 + lift
      local r = far and SKF or SK
      for y = 62 + b, bot - 3 do for x = cx - 1, cx + 1 do P(x, y, x == cx + 1 and r.shade or r.base) end end
      ell(cx + 0.5, bot - 2, 4, 2.6, function(x, y, nx, ny, d)
        if d > 1 then return end
        if y == bot and x >= cx + 2 then return r.deep end
        return lit(nx, ny, r)
      end)
      P(cx + 3, bot - 1, r.deep)
    end
    foot(31 + sL, o.footL, true)
    -- far arm
    E(40 + o.armL, 52 + b, 2, 2, SKF)
    -- back spines
    spines(25, 49 + b, 12, 14, 38, 38 + b, 22, 3)
    -- torso
    ell(32.5, 56 + b, 9, 10, function(x, y, nx, ny, d)
      if d > 1 then return end
      local yy = y - b
      if yy == 55 then return VE.deep end
      if yy > 55 then return lit(nx, ny, VE) end
      if x >= 35 and yy >= 48 then
        if yy == 50 and x >= 37 and x <= 39 then return VE.deep end
        return lit(nx, ny, VE)
      end
      return lit(nx, ny, SK)
    end)
    for yy = 45, 48 do local x = 30 + (yy - 45); P(x, yy + b, VE.base); P(x + 1, yy + b, VE.shade) end
    P(35, 48 + b, GHI)
    -- near leg + arm
    foot(35 + sR, o.footR, false)
    local ax = o.armR * 1.5
    for pass = 1, 2 do
      for t = 0, 6 do
        local yy = 46 + t
        local x = 32 + math.floor(t * ax / 6 + 0.5)
        if pass == 1 then for i = -2, 2 do P(x + i, yy + b, FUR[1]) end
        else P(x - 1, yy + b, SK.hi); P(x, yy + b, SK.base); P(x + 1, yy + b, SK.shade) end
      end
      if pass == 1 then E(32 + ax, 53.5 + b, 3.3, 3.3, FUR[1]) else E(32 + ax, 53.5 + b, 2.3, 2.3, SK) end
    end
    -- lantern hangs from belt on near hip
    local sw = o.armR > 0 and 1 or (o.armR < 0 and -1 or 0)
    lantern(27 + sw, 56 + b)
    -- head
    spines(28, 27 + hd, 14, 14, 39, 31 + hd, 24, 3.5)
    ell(38.5, 30 + hd, 7.5, 7, function(x, y, nx, ny, d)
      if d > 1 then return end
      local yy = y - hd
      if x < 35 - math.max(0, yy - 31) then return end
      return lit(nx, ny, {hi = SK.hi, base = SK.base, shade = SK.shade})
    end)
    ell(44, 31 + hd, 4.5, 2.8, function(x, y, nx, ny, d)
      if d > 1 then return end
      if ny < -0.4 then return SK.hi end
      if ny > 0.5 then return SK.shade end
      return SK.base
    end)
    P(48, 30 + hd, NOSE); P(49, 30 + hd, NOSE); P(48, 31 + hd, NOSE); P(49, 31 + hd, NOSE); P(48, 30 + hd, CREAM)
    P(44, 34 + hd, SK.deep); P(45, 34 + hd, SK.deep); P(46, 33 + hd, SK.deep)
    for y = 26, 28 do P(39, y + hd, INK); P(40, y + hd, INK) end
    P(39, 26 + hd, CREAM)
    P(40, 31 + hd, CHEEK); P(41, 31 + hd, CHEEK)
    E(33.5, 21 + hd, 2, 2.3, SK); P(33, 21 + hd, SK.deep); P(33, 22 + hd, SK.deep)
    hat(29.5, 16.5 + hd, 6, 12)
  end
  for k, c in pairs(G) do img:putPixel(k % 64, k // 64, c) end
  N.outline(img, INK)
end
return S
