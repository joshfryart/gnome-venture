-- snail (crawler) tables from specs/snail.md. Opus: replace S.draw_figure only (body-plan helper: D.crawler).
local N = dofile((app.params.root or "npc25") .. "/lib/npc25.lua")
local D = dofile((app.params.root or "npc25") .. "/lib/draft_common.lua")
local S = {name = "snail", feet_y = 71, outline = "#2b1c26", plan = "crawler", T = 8, W = 44}
S.ramps = {main = {"#d2cb94", "#a09e6e", "#726c60", "#4a4256"}}  -- hi, base, shade, deep
S.palette_list = {"#2b1c26", "#d2cb94", "#a09e6e", "#726c60", "#4a4256", "#d48e3e", "#9e5c3c", "#5e3446", "#dab65c", "#5ca24c", "#ecdab2", "#aaa9b8", "#74758c"}
-- {body y, head y, footL, footR, armL, armR}
S.idle = {{0, 0, 0, 0, 0, 0}, {-1, -1, 0, 0, 0, 0}}
S.walk = {{0, -1, 0, 0, 1, 0}, {1, 0, 0, 0, 0, 0}, {0, -1, 0, 0, -1, 0}, {1, 0, 0, 0, -1, 1}, {0, -1, 0, 0, 0, 0}, {1, 0, 0, 0, 0, 1}}
local h = N.hex
S.c = {
  body = h"#a09e6e",
  bshade = h"#726c60",
  bhi = h"#d2cb94",
  deep = h"#4a4256",
  head = h"#a09e6e",
  hat = h"#dab65c",
  hatshade = h"#5ca24c",
  wing = h"#726c60",
  belly = h"#d48e3e",
  acc = h"#d48e3e",
  accs = h"#9e5c3c",
  eye = h"#d48e3e",
  q = h"#9e5c3c",
  qshade = h"#5e3446",
  qhi = h"#ecdab2",
  ink = h"#4a4256", arm = h"#a09e6e", fbase = h"#726c60", fshade = h"#4a4256"}
S.bw, S.top = 20, 9
S.quirk = {w = 4, h = 4, anchor = "shell", hex = "#9e5c3c"}

-- Stage 3 (Opus) replaces this with the real art: one 64x80 frame (transparent bg, hard pixels, outline included).
-- img: Image 64x80 RGBA, view: "front"|"back"|"side", frame: 1..8, species: this table.
function S.draw_figure(img, view, frame, species)
  local o = N.offsets(species, frame)
  local b, hd, aL, aR = o.body, o.head, o.armL, o.armR
  local floor, abs, sqrt, atan = math.floor, math.abs, math.sqrt, math.atan
  local K = h(species.outline)
  local SK = {hi = h"#d2cb94", base = h"#a09e6e", shade = h"#726c60", deep = h"#4a4256"}
  -- shell: 5 tones (straw-gold glint, orange, rust, plum groove, ink)
  local SHL = {hi = h"#dab65c", base = h"#d48e3e", shade = h"#9e5c3c", deep = h"#5e3446"}
  local STRAW = {hi = h"#ecdab2", base = h"#dab65c", shade = h"#d48e3e", deep = h"#9e5c3c"}
  local GREEN, CREAM = h"#5ca24c", h"#ecdab2"
  local SL, SD = h"#aaa9b8", h"#74758c"
  local walking = frame >= 3
  local wi = frame - 2
  local sway = (frame == 4 or frame == 5) and 1 or ((frame == 7 or frame == 8) and -1 or 0)
  local G = {}
  local function P(x, y, c)
    x, y = floor(x), floor(y)
    if c and x >= 0 and x <= 63 and y >= 0 and y <= 79 then G[y * 64 + x] = c end
  end
  local function get(x, y) return G[floor(y) * 64 + floor(x)] end
  local function ell(cx, cy, rx, ry, fn)
    for y = floor(cy - ry - 1), floor(cy + ry + 1) do
      for x = floor(cx - rx - 1), floor(cx + rx + 1) do
        local nx, ny = (x - cx) / rx, (y - cy) / ry
        local d = nx * nx + ny * ny
        if d <= 1 then P(x, y, fn(x, y, nx, ny, d)) end
      end
    end
  end
  local function lit(nx, ny, r)
    local s = nx * 0.6 + ny * 0.8
    if s > 0.88 and r.deep then return r.deep end
    if s > 0.55 then return r.shade end
    if s < -0.72 then return r.hi end
    return r.base
  end
  local function E(cx, cy, rx, ry, r)
    ell(cx, cy, rx, ry, function(x, y, nx, ny) return type(r) == "table" and lit(nx, ny, r) or r end)
  end
  local function line(x0, y0, x1, y1, c)
    local n = math.max(abs(x1 - x0), abs(y1 - y0), 1)
    for i = 0, n do P(floor(x0 + (x1 - x0) * i / n + 0.5), floor(y0 + (y1 - y0) * i / n + 0.5), c) end
  end
  local function rows(x0, y0, t, map)
    for j, row in ipairs(t) do
      for i = 1, #row do
        local c = map[row:sub(i, i)]
        if c then P(x0 + i - 1, y0 + j - 1, c) end
      end
    end
  end
  -- spiral shell: lit upper-left, rim shade, a plum groove with a rust lip, glint
  local function shell(cx, cy, r, turns, dir)
    local sp = r / turns
    for y = floor(cy - r - 1), floor(cy + r + 1) do
      for x = floor(cx - r - 1), floor(cx + r + 1) do
        local dx, dy = x + 0.5 - cx, y + 0.5 - cy
        local d = sqrt(dx * dx + dy * dy)
        if d <= r then
          local s = (0.6 * dx + 0.8 * dy) / r
          local c = SHL.base
          if s < -0.45 then c = SHL.hi elseif s > 0.35 then c = SHL.shade end
          if d > r - 1.2 and s > -0.2 then c = SHL.shade end
          if d > r - 1.2 and s > 0.6 then c = SHL.deep end
          local th = atan(dy, dir * dx) / (2 * math.pi)
          local u = d / sp + th
          local fr = u - floor(u)
          if d < r - 1.3 then
            if fr < 1.15 / sp then c = SHL.deep
            elseif fr < 2.2 / sp and s > -0.6 then c = SHL.shade end
          end
          if d < 1.3 then c = SHL.deep end
          P(x, y, c)
        end
      end
    end
    P(cx - r * 0.45, cy - r * 0.62, CREAM)
    P(cx - r * 0.45 + 1, cy - r * 0.62, STRAW.base)
  end
  -- quirk: mail satchel (rust bag, plum seams, gold clasp, cream letter peeking)
  local function satchel(x, y)
    rows(x + sway, y, {
      ".cc...",
      "dqqqqd",
      "dqhhqd",
      "dqqqqd",
      "dddddd",
    }, {c = CREAM, d = SHL.deep, q = SHL.shade, h = STRAW.base})
  end
  -- eye bulb on a stalk: round, lit, ink pill pupil with a cream glint
  local function bulb(cx, cy, look, far)
    local r = far and {hi = SK.base, base = SK.shade, shade = SK.deep, deep = SK.deep} or SK
    E(cx, cy, 3.4, 3.4, r)
    if look then
      local px = floor(cx) + look
      P(px, cy - 1, K); P(px + 1, cy - 1, K)
      P(px, cy, K); P(px + 1, cy, K)
      P(px, cy + 1, K); P(px + 1, cy + 1, K)
      P(px, cy - 1, CREAM)
    end
  end
  local function stalk(x0, y0, x1, y1, far)
    line(x0, y0, x1, y1, far and SK.shade or SK.base)
    line(x0 + 1, y0, x1 + 1, y1, far and SK.deep or SK.shade)
  end
  local function speckle(x0, x1, y0, y1)
    for y = y0, y1 do for x = x0, x1 do
      if (x * 5 + y * 3) % 11 == 0 and get(x, y) == SK.base then P(x, y, SK.shade) end
    end end
  end
  -- straw hat: woven brim (cream rim, straw, gold weave ticks), crown with green band
  local function hat(cx, by, brx, cw, back, prof)
    ell(cx, by, brx, 2.4, function(x, y, nx, ny)
      if ny < -0.45 then return STRAW.hi end
      if ny > 0.5 then return STRAW.deep end
      if (x + y) % 3 == 0 then return STRAW.shade end
      return STRAW.base
    end)
    local x1 = floor(cx - cw / 2 + 0.5)
    local x2 = x1 + cw - 1
    for y = by - 6, by - 1 do
      for x = x1, x2 do
        local yy = y - (by - 6)
        if not (yy == 0 and (x == x1 or x == x2)) then
          local c = STRAW.base
          if x == x1 then c = STRAW.hi elseif x >= x2 - 1 then c = STRAW.shade end
          if yy == 0 and x > x1 and x < x2 - 1 then c = STRAW.hi end
          if (x + yy) % 3 == 0 and yy > 0 and yy < 3 and c == STRAW.base then c = STRAW.shade end
          if yy == 3 or yy == 4 then c = GREEN end
          if yy == 4 and x == x2 then c = SK.deep end
          P(x, y, c)
        end
      end
    end
    if back then P(x2 - 1, by - 1, GREEN); P(x2, by, GREEN); P(x2 + 1, by + 1, GREEN) end
    if prof then P(x1 - 1, by - 2, GREEN); P(x1 - 2, by - 1, GREEN) end  -- band bow trailing
  end
  -- envelope held in a hand nub
  local function letter(x, y)
    rows(x, y, {"ccccc", "cdcdc", "ccdcc", "ccccc"}, {c = CREAM, d = SHL.shade})
  end

  if view == "front" or view == "back" then
    local front = view == "front"
    local CX = 31.5
    local wide = (walking and b == 1) and 1 or 0
    -- ground shadow
    ell(32, 67.5, 16.5, 3, function(x, y, nx, ny) return ny < -0.2 and SL or SD end)
    -- shell behind (front: peeking on the left; back: the big dome)
    if front then shell(19.5, 47 + b, 10.5, 2.2, 1) end
    -- foot skirt: wide soft base, lit on top, sole rows darker
    ell(CX, 66.5, 17 + wide, 4.2, function(x, y, nx, ny)
      if y >= 70 then return SK.deep end
      if y >= 69 then return SK.shade end
      if nx > 0.7 then return SK.shade end
      if ny < -0.5 and nx < 0.2 then return SK.hi end
      return SK.base
    end)
    if walking then  -- ripple waves travelling along the sole
      for x = 16, 47 do if (x + wi * 2) % 7 == 0 then P(x, 67, SK.shade); P(x + 1, 68, SK.shade) end end
    end
    -- body trunk, gently flaring into the foot
    local top = 30 + b
    for y = top, 66 do
      local hw = 7.5 + (y - top) * 0.11 + math.max(0, y - (56 + b)) * 0.25 + wide * 0.5
      for x = floor(CX - hw + 0.5), floor(CX + hw + 0.5) - 1 do
        local nx = (x + 0.5 - CX) / hw
        local c = SK.base
        if nx < -0.72 then c = SK.hi elseif nx > 0.82 then c = SK.deep elseif nx > 0.55 then c = SK.shade end
        P(x, y, c)
      end
    end
    speckle(21, 42, top + 8, 63)
    for x = 24, 39 do P(x, 65, SK.shade) end  -- where the trunk meets the foot
    -- head (one soft blob with the trunk)
    E(CX, 27 + hd, 12.6, 9.2, SK)
    if front then
      -- arm nubs
      E(21.5, 46 + b, 2.6, 4, SK)
      E(42, 47 + b - aR, 2.6, 4, SK)
      letter(40, 49 + b - aR)
      -- satchel strap across the chest, satchel on the shell
      line(18 + sway, 46 + b, 40, 37 + b, SHL.deep)
      satchel(10, 46 + b)
      -- face: muzzle, ink nose with glint, smile, cheeks
      E(CX, 30.5 + hd, 4.6, 2.6, SK.hi)
      P(31, 29 + hd, SHL.deep); P(32, 29 + hd, SHL.deep); P(31, 29 + hd, CREAM)
      P(29, 32 + hd, K); P(30, 33 + hd, K); P(31, 33 + hd, K); P(32, 33 + hd, K); P(33, 33 + hd, K); P(34, 32 + hd, K)
      P(23, 30 + hd, SHL.base); P(24, 30 + hd, SHL.base); P(39, 30 + hd, SHL.base); P(40, 30 + hd, SHL.base)
      -- brim shadow on the forehead
      for x = 22, 41 do if get(x, 23 + hd) then P(x, 23 + hd, SK.shade) end end
      -- green spotted scarf: a knotted triangle under the chin
      for j = 0, 7 do
        local w = 22 - j * 3
        if w < 2 then w = 2 end
        local x0 = floor(CX - w / 2 + 0.5)
        for x = x0, x0 + w - 1 do
          local c = GREEN
          if (x * 2 + j * 3) % 7 == 0 then c = SK.hi end
          if j == 0 or x == x0 + w - 1 and w > 2 then c = (j == 0) and SK.deep or SK.shade end
          P(x, 36 + j + b, c)
        end
      end
      P(36, 36 + b, GREEN); P(37, 35 + b, GREEN)  -- knot tip
      hat(CX, 22 + hd, 12.5, 8, false, false)
      -- eyestalks through the brim, bulbs looking at you
      stalk(26, 21 + hd, 25 + aL, 14 + hd, false)
      stalk(36, 21 + hd, 37 + aR, 14 + hd, false)
      bulb(25 + aL, 12 + hd, 0, false)
      bulb(38 + aR, 12 + hd, -1, false)
    else
      -- back: stalks behind the hat (no pupils), shell dome, strap, scarf tails
      stalk(26, 21 + hd, 25 + aL, 14 + hd, true)
      stalk(36, 21 + hd, 37 + aR, 14 + hd, true)
      bulb(25 + aL, 12 + hd, nil, false)
      bulb(38 + aR, 12 + hd, nil, false)
      E(20.5, 46 + b, 2.6, 4, SK)
      E(42.5, 46 + b, 2.6, 4, SK)
      shell(CX, 48 + b, 12.5, 2.6, -1)
      line(20, 38 + b, 37 + sway, 52 + b, SHL.deep)
      line(21, 38 + b, 38 + sway, 52 + b, SHL.deep)
      satchel(35, 52 + b)
      for x = 22, 41 do P(x, 34 + b, GREEN); P(x, 35 + b, (x % 4 == 0) and SK.hi or GREEN); P(x, 36 + b, SK.deep) end
      local t = sway
      rows(24, 36 + b, {"gg", "gg", ".gg", ".gg", "..g"}, {g = GREEN})
      rows(27 + t, 36 + b, {"gg", "gg", "gg", "g.", "g."}, {g = GREEN})
      P(25, 37 + b, SK.hi); P(28 + t, 38 + b, SK.hi)
      hat(CX, 22 + hd, 12.5, 8, true, false)
    end

  else -- side, facing right
    local stretch = walking and b == 0
    ell(31, 67.5, 18, 3, function(x, y, nx, ny) return ny < -0.2 and SL or SD end)
    -- far eyestalk behind everything
    stalk(39 + (stretch and 1 or 0), 21 + hd, 38 + aL, 14 + hd, true)
    bulb(38 + aL, 12 + hd, 1, true)
    -- long foot: tapered tail on the left, rounded nose on the right
    local tip = 49 + (stretch and 1 or 0)
    for x = 11, tip do
      local t = 62
      if x < 21 then t = 62 + (21 - x) // 2 end
      if x >= tip - 1 then t = 64 end
      if x == tip then t = 66 end
      for y = t, 70 do
        local c = SK.base
        if y == t and x < 34 then c = SK.hi end
        if y >= 69 then c = SK.shade end
        if y == 70 and x > 12 and x < tip then c = SK.deep end
        P(x, y, c)
      end
    end
    if walking then
      for x = 14, tip - 3 do if (x + wi * 2) % 7 == 0 then P(x, 66, SK.shade); P(x + 1, 67, SK.shade) end end
    end
    -- mantle hump that the shell sits on
    E(26, 60 + b, 12, 4, SK)
    -- neck rising at the front, leaning forward (more on the stretch frames)
    local L = stretch and 1 or 0
    local top = 33 + b
    local function nx0(y) return 35 + floor((66 - y) * (2 + L) / 36) end
    for y = top, 66 do
      local x0 = nx0(y)
      for x = x0, x0 + 9 do
        local c = SK.base
        if x <= x0 + 1 then c = SK.hi elseif x == x0 + 9 then c = SK.deep elseif x >= x0 + 8 then c = SK.shade end
        P(x, y, c)
      end
    end
    speckle(37, 47, top + 10, 63)
    -- head: round, snout forward
    local hx = 43 + L
    ell(hx, 26.5 + hd, 8.4, 7.8, function(x, y, nx, ny)
      local sv = nx * 0.5 + ny * 0.85
      if sv > 0.75 then return SK.shade end
      if sv < -0.6 then return SK.hi end
      return SK.base
    end)
    local sx = floor(hx + 0.5)
    for y = 26, 29 do for x = sx + 3, sx + 7 do
      if get(x, y + hd) and not (y == 29 and x == sx + 3) then P(x, y + hd, y == 26 and SK.hi or ((y == 29 or x == sx + 7) and SK.base or SK.hi)) end
    end end
    P(sx + 7, 27 + hd, SHL.deep); P(sx + 8, 27 + hd, SHL.deep); P(sx + 8, 28 + hd, SHL.deep); P(sx + 7, 27 + hd, CREAM)
    P(sx + 3, 30 + hd, K); P(sx + 4, 31 + hd, K); P(sx + 5, 31 + hd, K); P(sx + 6, 30 + hd, K)
    P(sx, 28 + hd, SHL.base); P(sx + 1, 28 + hd, SHL.base)
    for x = 36, 52 do if get(x, 23 + hd) then P(x, 23 + hd, SK.shade) end end
    -- shell on the back
    shell(24.5, 47 + b, 12.5, 2.4, 1)
    -- strap from the neck to the satchel on the shell flank
    line(37, 36 + b, 21 + sway, 51 + b, SHL.deep)
    satchel(14, 51 + b)
    -- scarf at the neck, tail streaming back over the shell
    for y = 35, 37 do for x = nx0(y + b), nx0(y + b) + 9 do
      P(x, y + b, y == 37 and SK.deep or ((y == 36 and x % 4 == 1) and SK.hi or GREEN))
    end end
    local tw = (wi >= 1 and wi % 2 == 0) and 1 or 0
    rows(30, 34 + b + tw, {"..gggggg", ".gggg...", "gg.g....", "g.......", }, {g = GREEN})
    P(33, 35 + b + tw, SK.hi)
    -- arm nub with the letter
    E(44, 45 + b, 2.6, 3.6, SK)
    letter(44 + (aL > 0 and 1 or 0), 46 + b)
    -- hat in profile
    hat(hx - 1, 22 + hd, 9, 7, false, true)
    -- near eyestalk leaning forward, eye looking ahead
    stalk(sx + 1, 21 + hd, sx + 2 + aL, 14 + hd, false)
    bulb(sx + 2 + aL, 12 + hd, 1, false)
  end
  for k, c in pairs(G) do img:putPixel(k % 64, k // 64, c) end
  N.outline(img, K)
end
return S
