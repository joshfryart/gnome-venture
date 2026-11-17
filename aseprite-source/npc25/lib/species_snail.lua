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

-- Stage 3 (Opus): soft slug body on a frilled foot, big spiral shell on the back, eyestalks, mail satchel quirk.
-- img: Image 64x80 RGBA, view: "front"|"back"|"side", frame: 1..8, species: this table.
function S.draw_figure(img, view, frame, species)
  local o = N.offsets(species, frame)
  local b, hd, aL, aR = o.body, o.head, o.armL, o.armR
  local floor, abs, sqrt, atan, max, min = math.floor, math.abs, math.sqrt, math.atan, math.max, math.min
  local K = h(species.outline)
  local SK = {hi = h"#d2cb94", base = h"#a09e6e", shade = h"#726c60", deep = h"#4a4256"}
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
        if nx * nx + ny * ny <= 1 then P(x, y, fn(x, y, nx, ny)) end
      end
    end
  end
  local function lit(nx, ny, r)
    local s = nx * 0.6 + ny * 0.8
    if s > 0.88 and r.deep then return r.deep end
    if s > 0.5 then return r.shade end
    if s < -0.62 then return r.hi end
    return r.base
  end
  local function E(cx, cy, rx, ry, r)
    ell(cx, cy, rx, ry, function(x, y, nx, ny) return type(r) == "table" and lit(nx, ny, r) or r end)
  end
  local function line(x0, y0, x1, y1, c)
    local n = max(abs(x1 - x0), abs(y1 - y0), 1)
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
  -- big spiral shell: disc lit upper-left; the whorl centre (cx+ox, cy+oy) can sit off-centre (3/4 turn)
  local function shell(cx, cy, r, turns, dir, ox, oy)
    ox, oy = ox or 0, oy or 0
    local wx, wy = cx + ox, cy + oy
    local R = r + sqrt(ox * ox + oy * oy) * 0.6
    local sp = R / turns
    for y = floor(cy - r - 1), floor(cy + r + 1) do
      for x = floor(cx - r - 1), floor(cx + r + 1) do
        local dx, dy = x + 0.5 - cx, y + 0.5 - cy
        local d = sqrt(dx * dx + dy * dy)
        if d <= r then
          local s = (0.6 * dx + 0.8 * dy) / r
          local c = SHL.base
          if s < -0.5 then c = SHL.hi elseif s > 0.4 then c = SHL.shade end
          if d > r - 1.3 and s > -0.25 then c = SHL.shade end
          if d > r - 1.3 and s > 0.55 then c = SHL.deep end
          local ex, ey = x + 0.5 - wx, y + 0.5 - wy
          local e = sqrt(ex * ex + ey * ey)
          local th = atan(ey, dir * ex) / (2 * math.pi)
          local u = e / sp + th
          local fr = u - floor(u)
          if d < r - 1.4 then
            if fr < 1.25 / sp then c = SHL.deep
            elseif fr < 2.4 / sp then c = (s > -0.5) and SHL.shade or SHL.base
            elseif fr > 1 - 1.1 / sp and s < 0.3 then c = (c == SHL.hi) and CREAM or SHL.hi end
          end
          if e < 1.2 then c = SHL.deep end
          P(x, y, c)
        end
      end
    end
    P(cx - r * 0.5, cy - r * 0.6, CREAM)
    P(cx - r * 0.5 + 1, cy - r * 0.6, CREAM)
    P(cx - r * 0.5, cy - r * 0.6 + 1, STRAW.base)
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
  -- straw hat: woven brim, crown with green band
  local function hat(cx, by, brx, cw, back, prof)
    ell(cx, by, brx, 2.2, function(x, y, nx, ny)
      if ny < -0.45 then return STRAW.hi end
      if ny > 0.5 then return STRAW.deep end
      if (x + y) % 3 == 0 then return STRAW.shade end
      return STRAW.base
    end)
    local x1 = floor(cx - cw / 2 + 0.5)
    local x2 = x1 + cw - 1
    for y = by - 5, by - 1 do
      for x = x1, x2 do
        local yy = y - (by - 5)
        if not (yy == 0 and (x == x1 or x == x2)) then
          local c = STRAW.base
          if x == x1 then c = STRAW.hi elseif x >= x2 - 1 then c = STRAW.shade end
          if yy == 0 and x > x1 and x < x2 - 1 then c = STRAW.hi end
          if (x + yy) % 3 == 0 and yy == 1 and c == STRAW.base then c = STRAW.shade end
          if yy == 2 or yy == 3 then c = GREEN end
          if yy == 3 and x == x2 then c = SK.deep end
          P(x, y, c)
        end
      end
    end
    if back then P(x2, by - 1, GREEN); P(x2 + 1, by, GREEN) end
    if prof then P(x1 - 1, by - 2, GREEN); P(x1 - 2, by - 1, GREEN) end
  end
  -- soft slug column: rows y0..y1, centre cxf(t), half width hwf(t), glossy left, shade right
  local function slug(y0, y1, cxf, hwf, gloss)
    for y = y0, y1 do
      local t = (y - y0) / max(1, y1 - y0)
      local cx, hw = cxf(t), hwf(t)
      for x = floor(cx - hw + 0.5), floor(cx + hw + 0.5) - 1 do
        local nx = (x + 0.5 - cx) / hw
        local c = SK.base
        if nx < -0.62 then c = SK.hi
        elseif nx > 0.84 then c = SK.deep
        elseif nx > 0.5 then c = SK.shade end
        P(x, y, c)
      end
      -- wet gloss streak: a broken cream line inside the lit edge
      if gloss and y - y0 >= gloss and y - y0 <= gloss + 3 then
        P(floor(cx - hw * 0.45 + 0.5), y, (y - y0 == gloss) and CREAM or SK.hi)
      end
    end
  end
  -- frilled foot skirt on the ground, ripple waves while walking
  local function skirt(cx, rx)
    -- a soft wavy-edged foot: rounded lip lit on top, darker sole where it meets the ground
    for y = 62, 70 do
      local ny = (y - 70.5) / 8.5
      local hw = rx * sqrt(max(0, 1 - ny * ny * ny * ny))
      local wav = ((y + wi) % 3 == 0) and 1 or 0
      for x = floor(cx - hw + 0.5) - wav, floor(cx + hw + 0.5) - 1 + wav do
        local c = SK.base
        local nx = (x + 0.5 - cx) / hw
        if y >= 70 then c = SK.shade
        elseif nx > 0.78 then c = SK.shade
        elseif nx < -0.8 then c = SK.hi end
        P(x, y, c)
      end
    end
    -- lit top lip of the foot
    for x = floor(cx - rx) + 1, floor(cx + rx) - 1 do
      for y = 62, 70 do
        if get(x, y) then
          if (x + 0.5 - cx) < rx * 0.5 then P(x, y, SK.hi) end
          break
        end
      end
    end
    if walking then
      for x = floor(cx - rx), floor(cx + rx) do
        if (x + wi * 2) % 6 == 0 and get(x, 68) and get(x + 1, 69) then P(x, 68, SK.shade); P(x + 1, 69, SK.shade) end
      end
    end
  end
  local function spots(list, dy)
    for _, p in ipairs(list) do
      local x, y = p[1], p[2] + dy
      if get(x, y) == SK.base then P(x, y, SK.shade) end
    end
  end
  -- soft glossy blob (head, body mound): lit upper-left, wet cream glint, shade lower-right
  local function blob(cx, cy, rx, ry, glint, wx, wy, soft)
    wx, wy = wx or 0.6, wy or 0.7
    ell(cx, cy, rx, ry, function(x, y, nx, ny)
      local sv = nx * wx + ny * wy
      if sv > 0.9 and not soft then return SK.deep end
      if sv > (soft and 0.62 or 0.5) then return SK.shade end
      if sv < (soft and -0.4 or -0.58) then return SK.hi end
      return SK.base
    end)
    if glint then
      local gx, gy = floor(cx - rx * 0.5), floor(cy - ry * 0.55)
      P(gx, gy, CREAM); P(gx + 1, gy, SK.hi); P(gx, gy + 1, SK.hi)
    end
  end
  -- head blob with face (front): spaced out so muzzle glint, nose and mouth read separately at 1x
  local function face(cx, cy)
    local x = floor(cx)
    E(cx, cy + 3, 6.6, 3.9, SK.hi)               -- wide cream-ish muzzle
    P(x - 4, cy, CREAM); P(x - 3, cy, CREAM); P(x - 4, cy + 1, CREAM)  -- wet glint, upper left
    -- nose: 3 px plum bean with a 1 px drop
    P(x - 1, cy + 1, SHL.deep); P(x, cy + 1, SHL.deep); P(x + 1, cy + 1, SHL.deep); P(x, cy + 2, SHL.deep)
    -- open smile, 9 px wide, plum inside
    P(x - 4, cy + 3, K); P(x + 4, cy + 3, K)
    P(x - 3, cy + 4, K); P(x + 3, cy + 4, K)
    for i = -2, 2 do P(x + i, cy + 4, SHL.deep) end
    P(x, cy + 4, SHL.shade); P(x + 1, cy + 4, SHL.shade)
    for i = -2, 2 do P(x + i, cy + 5, K) end
    -- rosy cheeks, outside the mouth corners
    for _, dx in ipairs({-8, -7, 7, 8}) do P(x + dx, cy + 2, SHL.base); P(x + dx, cy + 3, SHL.base) end
    P(x - 8, cy + 2, STRAW.base); P(x + 7, cy + 2, STRAW.base)
  end
  -- smooth bell body from neck to foot: cylinder shading, no dark wall on the right
  local function bell(y0, y1, cxf, hwf)
    for y = y0, y1 do
      local t = (y - y0) / max(1, y1 - y0)
      local cx, hw = cxf(t), hwf(t)
      for x = floor(cx - hw + 0.5), floor(cx + hw + 0.5) - 1 do
        local nx = (x + 0.5 - cx) / hw
        local c = SK.base
        if nx < -0.62 then c = SK.hi elseif nx > 0.52 then c = SK.shade end
        P(x, y, c)
      end
      if t > 0.15 and t < 0.6 then P(floor(cx - hw * 0.45 + 0.5), y, (t < 0.25) and CREAM or SK.hi) end
    end
  end
  -- plum contour behind a hat part so the straw separates from the orange shell
  local function hatback(cx, by, brx, cw)
    ell(cx, by, brx + 1, 3.2, function() return SHL.deep end)
    local x1 = floor(cx - cw / 2 + 0.5)
    for y = by - 6, by - 1 do for x = x1 - 1, x1 + cw do P(x, y, SHL.deep) end end
  end

  local HY = 36 -- head centre row (body y 0)
  if view == "front" or view == "back" then
    local front = view == "front"
    local wide = (walking and b == 1) and 1 or 0
    ell(31.5, 67.5, 16.5, 3, function(x, y, nx, ny) return ny < -0.2 and SL or SD end)
    if front then
      local HY = 41
      local FX = 34
      -- big shell dome behind, set to the left, whorl turned toward us
      shell(25, 41 + b, 16, 2.5, 1, -4, -1)
      skirt(31.5, 17 + wide)
      -- one smooth bell from the neck down into the foot (replaces the stepped neck + mound)
      bell(HY + 5 + b, 66, function(t) return FX - 0.5 - 2.5 * t end, function(t) return 8.5 + (6.5 + wide) * t ^ 1.5 end)
      -- head
      blob(FX, HY + hd, 12, 8.5, false, 0.6, 0.7, true)
      face(FX, HY + hd - 1)
      for x = FX - 12, FX + 12 do if get(x, HY - 6 + hd) then P(x, HY - 6 + hd, SK.shade) end end
      -- kerchief knotted under the chin
      for j = 0, 4 do
        local w = 15 - j * 3
        if w < 2 then w = 2 end
        local x0 = floor(FX - w / 2 + 0.5)
        for x = x0, x0 + w - 1 do
          local c = GREEN
          if (x * 2 + j * 3) % 7 == 0 then c = SK.hi end
          if x == x0 + w - 1 and w > 2 then c = SK.shade end
          P(x, HY + 8 + j + b, c)
        end
      end
      -- cross-body mail strap from the far shoulder down to the satchel at the lower left
      line(FX + 9, HY + 9 + b, 18 + sway, 57 + b, SHL.deep)
      satchel(13, 56 + b)
      -- long eyestalks rising from the head behind the hat crown
      stalk(FX - 5, HY - 7 + hd, FX - 8 + aL, 15 + hd, false)
      stalk(FX + 4, HY - 7 + hd, FX + 6 + aR, 15 + hd, false)
      hatback(FX, HY - 7 + hd, 14, 9)
      hat(FX, HY - 7 + hd, 14, 9, false, false)
      bulb(FX - 8 + aL, 12 + hd, 0, false)
      bulb(FX + 7 + aR, 12 + hd, -1, false)
    else
      local HY = 40
      stalk(28, HY - 6 + hd, 25 + aL, 15 + hd, true)
      stalk(34, HY - 6 + hd, 37 + aR, 15 + hd, true)
      bulb(25 + aL, 12 + hd, nil, false)
      bulb(38 + aR, 12 + hd, nil, false)
      skirt(31.5, 17 + wide)
      bell(HY + 3 + b, 66, function(t) return 31.5 end, function(t) return 8 + (7 + wide) * t ^ 1.5 end)
      blob(31.5, HY + hd, 10.5, 7, false)
      for x = 22, 41 do if get(x, HY - 5 + hd) then P(x, HY - 5 + hd, SK.shade) end end
      shell(31.5, 50 + b, 16, 2.7, -1, 1, 0)
      -- scarf knot and tails draped over the shell top
      local t = sway
      for x = 25, 33 do P(x, 36 + b, GREEN) end
      rows(25, 37 + b, {"gg", "ggg", ".gg", ".gg", "..g"}, {g = GREEN})
      rows(29 + t, 37 + b, {"gg", "gg", "gg", "g.", "g."}, {g = GREEN})
      P(26, 38 + b, SK.hi); P(30 + t, 39 + b, SK.hi)
      -- strap across the dome to the satchel
      line(30, 39 + b, 40 + sway, 47 + b, SHL.deep)
      line(31, 39 + b, 41 + sway, 47 + b, SHL.deep)
      satchel(39, 46 + b)
      hatback(31.5, HY - 6 + hd, 13, 9)
      hat(31.5, HY - 6 + hd, 13, 9, true, false)
    end

  else -- side, facing right
    local stretch = walking and b == 0
    local L = stretch and 1 or 0
    local HY = 42
    ell(30, 67.5, 19, 3, function(x, y, nx, ny) return ny < -0.2 and SL or SD end)
    local hx = 45 + L
    -- far eyestalk behind everything
    stalk(hx - 1, HY - 6 + hd, hx + 1 + aL, 15 + hd, true)
    bulb(hx + 1 + aL, 12 + hd, 1, true)
    -- long foot: tapered tail left, rounded nose right
    local tip = 50 + L
    for x = 11, tip do
      local t = 62
      if x < 21 then t = 62 + (21 - x) // 2 end
      if x >= tip - 1 then t = 64 end
      if x == tip then t = 66 end
      local wv = (x + wi) % 5 == 0 and 1 or 0
      for y = t + wv, 70 do
        local c = SK.base
        if y == t + wv and x < 40 then c = SK.hi end
        if y >= 69 then c = SK.shade end
        P(x, y, c)
      end
    end
    if walking then
      for x = 12, tip - 3 do if (x + wi * 2) % 6 == 0 then P(x, 66, SK.shade); P(x + 1, 67, SK.shade) end end
    end
    -- short neck curving up and forward out of the foot
    local top = HY + 3 + b
    slug(top, 64, function(t) return 44 + L - 4 * t end, function(t) return 4.5 + 5.5 * t * t * t end, 2)
    -- mantle under the shell
    E(25, 60 + b, 13, 3.4, SK)
    -- head: round, snout forward
    blob(hx + 0.5, HY + hd, 7, 6.2, true)
    local sx = hx
    local sy = HY + hd
    -- muzzle, nose, smile, cheek
    for x = sx + 3, sx + 6 do P(x, sy + 1, SK.hi); P(x, sy + 2, SK.hi) end
    P(sx + 6, sy, SHL.deep); P(sx + 7, sy, SHL.deep); P(sx + 6, sy, CREAM)
    P(sx + 2, sy + 3, K); P(sx + 3, sy + 4, K); P(sx + 4, sy + 4, K); P(sx + 5, sy + 4, K); P(sx + 6, sy + 3, K)
    P(sx - 1, sy + 1, SHL.base); P(sx, sy + 1, SHL.base)
    for x = 36, 53 do if get(x, sy - 5) then P(x, sy - 5, SK.shade) end end
    -- big shell on the back, spiral facing us
    shell(25, 46 + b, 14.5, 2.5, 1, 0, 0)
    -- strap from the neck to the satchel on the shell flank
    line(40, HY + 7 + b, 17 + sway, 53 + b, SHL.deep)
    satchel(11, 53 + b)
    -- scarf at the neck, tail streaming back over the shell
    for y = HY + 6, HY + 8 do
      local yy = y + b
      local t = (yy - top) / (64 - top)
      local cx, hw = 44 + L - 4 * t, 4.5 + 5.5 * t * t * t
      for x = floor(cx - hw + 0.5), floor(cx + hw + 0.5) - 1 do
        P(x, yy, y == HY + 8 and SK.deep or ((y == HY + 7 and x % 4 == 1) and SK.hi or GREEN))
      end
    end
    local tw = (wi >= 1 and wi % 2 == 0) and 1 or 0
    rows(32, HY + 5 + b + tw, {"..ggggg", ".gggg..", "gg.g...", "g......"}, {g = GREEN})
    P(35, HY + 6 + b + tw, SK.hi)
    hatback(hx - 1.5, sy - 5, 8, 7)
    hat(hx - 1.5, sy - 5, 9, 7, false, true)
    -- near eyestalk leaning forward, eye looking ahead
    stalk(sx + 2, sy - 5, sx + 4 + aL, 15 + hd, false)
    bulb(sx + 4 + aL, 12 + hd, 1, false)
  end
  for k, c in pairs(G) do img:putPixel(k % 64, k // 64, c) end
  N.outline(img, K)
end
return S
