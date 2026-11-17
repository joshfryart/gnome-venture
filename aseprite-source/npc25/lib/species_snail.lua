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
      if gloss and t > 0.08 and t < 0.75 and (y % 5 ~= 0) then
        P(floor(cx - hw * 0.5 + 0.5), y, (y % 5 == 1) and CREAM or SK.hi)
      end
    end
  end
  -- frilled foot skirt on the ground, ripple waves while walking
  local function skirt(cx, rx, x0, x1)
    for y = 63, 70 do
      local ny = (y - 70.5) / 7.5
      local hw = rx * sqrt(max(0, 1 - ny * ny * ny * ny))
      for x = max(x0, floor(cx - hw + 0.5)), min(x1, floor(cx + hw + 0.5) - 1) do
        local c = SK.base
        local nx = (x + 0.5 - cx) / hw
        if y >= 70 then c = SK.deep
        elseif y == 69 then c = SK.shade
        elseif nx > 0.82 then c = SK.shade
        elseif y == floor(70.5 - 7.5 * sqrt(sqrt(max(0, 1 - nx * nx)))) + 1 and nx < 0.4 then c = SK.hi end
        P(x, y, c)
      end
    end
    -- frill scallops along the rim
    for x = floor(cx - rx) + 2, floor(cx + rx) - 2, 4 do
      if get(x, 69) then P(x, 68, SK.shade) end
    end
    if walking then
      for x = floor(cx - rx), floor(cx + rx) do
        if (x + wi * 2) % 6 == 0 and get(x, 67) and get(x + 1, 68) then P(x, 67, SK.shade); P(x + 1, 68, SK.shade) end
      end
    end
  end
  local function spots(list, dy)
    for _, p in ipairs(list) do
      local x, y = p[1], p[2] + dy
      if get(x, y) == SK.base then P(x, y, SK.shade) end
    end
  end

  if view == "front" or view == "back" then
    local front = view == "front"
    local wide = (walking and b == 1) and 1 or 0
    ell(32, 67.5, 17, 3, function(x, y, nx, ny) return ny < -0.2 and SL or SD end)
    if front then
      -- big shell behind the body on the left, whorl turned toward us
      shell(23, 44 + b, 13.5, 2.3, 1, -3, -1)
      skirt(32, 18 + wide, 13, 50)
      -- pear-shaped soft body leaning right, flowing into the foot
      local top = 33 + b
      slug(top, 65, function(t) return 33.5 - 1.5 * t end, function(t) return 6.5 + 8 * t * t + wide * 0.5 end, true)
      spots({{36, 46}, {39, 52}, {34, 56}, {41, 58}, {30, 60}}, b)
      -- head: round soft blob
      E(33.5, 27 + hd, 10.5, 8.2, SK)
      -- face
      E(33.5, 30.5 + hd, 4.2, 2.2, SK.hi)
      P(33, 29 + hd, SHL.deep); P(34, 29 + hd, SHL.deep); P(33, 29 + hd, CREAM)
      P(31, 32 + hd, K); P(32, 33 + hd, K); P(33, 33 + hd, K); P(34, 33 + hd, K); P(35, 33 + hd, K); P(36, 32 + hd, K)
      P(26, 30 + hd, SHL.base); P(27, 30 + hd, SHL.base); P(40, 30 + hd, SHL.base); P(41, 30 + hd, SHL.base)
      for x = 24, 43 do if get(x, 22 + hd) then P(x, 22 + hd, SK.shade) end end
      -- green spotted kerchief knotted under the chin
      for j = 0, 5 do
        local w = 16 - j * 3
        if w < 2 then w = 2 end
        local x0 = floor(33.5 - w / 2 + 0.5)
        for x = x0, x0 + w - 1 do
          local c = GREEN
          if (x * 2 + j * 3) % 7 == 0 then c = SK.hi end
          if j == 0 then c = SK.deep elseif x == x0 + w - 1 and w > 2 then c = SK.shade end
          P(x, 35 + j + b, c)
        end
      end
      -- satchel strap from the far shoulder down to the satchel on the shell
      line(40, 36 + b, 17 + sway, 51 + b, SHL.deep)
      satchel(10, 50 + b)
      hat(33.5, 21 + hd, 9, 7, false, false)
      -- eyestalks rising from the head through the brim
      stalk(29, 22 + hd, 27 + aL, 14 + hd, false)
      stalk(37, 22 + hd, 39 + aR, 14 + hd, false)
      bulb(27 + aL, 12 + hd, 0, false)
      bulb(40 + aR, 12 + hd, -1, false)
    else
      -- back: stalks behind the hat, body hidden by the big shell dome
      stalk(27, 22 + hd, 25 + aL, 14 + hd, true)
      stalk(35, 22 + hd, 37 + aR, 14 + hd, true)
      bulb(25 + aL, 12 + hd, nil, false)
      bulb(38 + aR, 12 + hd, nil, false)
      skirt(31.5, 18 + wide, 13, 50)
      local top = 33 + b
      slug(top, 65, function(t) return 31.5 end, function(t) return 6.5 + 8 * t * t + wide * 0.5 end, true)
      E(31.5, 27 + hd, 10.5, 8.2, SK)
      for x = 22, 41 do if get(x, 22 + hd) then P(x, 22 + hd, SK.shade) end end
      -- scarf band round the neck
      for x = 24, 39 do P(x, 34 + b, GREEN); P(x, 35 + b, (x % 4 == 0) and SK.hi or GREEN) end
      shell(31.5, 48 + b, 15.5, 2.6, -1, 1, 0)
      -- scarf tails over the shell top
      local t = sway
      rows(25, 36 + b, {"gg", "ggg", ".gg", ".gg", "..g"}, {g = GREEN})
      rows(28 + t, 36 + b, {"gg", "gg", "gg", "g.", "g."}, {g = GREEN})
      P(26, 37 + b, SK.hi); P(29 + t, 38 + b, SK.hi)
      -- strap across the dome to the satchel
      line(21, 39 + b, 37 + sway, 54 + b, SHL.deep)
      line(22, 39 + b, 38 + sway, 54 + b, SHL.deep)
      satchel(36, 53 + b)
      hat(31.5, 21 + hd, 9, 7, true, false)
    end

  else -- side, facing right
    local stretch = walking and b == 0
    local L = stretch and 1 or 0
    ell(31, 67.5, 19, 3, function(x, y, nx, ny) return ny < -0.2 and SL or SD end)
    -- far eyestalk behind everything
    local hx = 44 + L
    stalk(hx, 21 + hd, hx + 1 + aL, 14 + hd, true)
    bulb(hx + 2 + aL, 12 + hd, 1, true)
    -- long foot: tapered tail left, rounded nose right
    local tip = 51 + L
    for x = 11, tip do
      local t = 62
      if x < 22 then t = 62 + (22 - x) // 2 end
      if x >= tip - 1 then t = 64 end
      if x == tip then t = 66 end
      for y = t, 70 do
        local c = SK.base
        if y == t and x < 40 then c = SK.hi end
        if y >= 69 then c = SK.shade end
        if y == 70 and x > 12 and x < tip then c = SK.deep end
        P(x, y, c)
      end
      if x % 4 == 1 and x > 13 and x < tip - 1 then P(x, 68, SK.shade) end
    end
    if walking then
      for x = 14, tip - 3 do if (x + wi * 2) % 6 == 0 then P(x, 66, SK.shade); P(x + 1, 67, SK.shade) end end
    end
    -- neck: soft and curving forward and up out of the foot
    local top = 32 + b
    slug(top, 64, function(t) return 46 + L - 4 * t end, function(t) return 5 + 4 * t * t end, true)
    spots({{44, 44}, {47, 50}, {43, 55}, {48, 58}}, b)
    -- mantle under the shell
    E(27, 60 + b, 13, 3.4, SK)
    -- head: round, snout forward
    ell(hx + 0.5, 26.5 + hd, 7.2, 7, function(x, y, nx, ny)
      local sv = nx * 0.5 + ny * 0.85
      if sv > 0.72 then return SK.shade end
      if sv < -0.55 then return SK.hi end
      return SK.base
    end)
    local sx = hx
    for y = 27, 30 do for x = sx + 4, sx + 8 do
      if not (y == 30 and x == sx + 8) and not (y == 27 and x == sx + 8) then
        P(x, y + hd, y == 27 and SK.hi or ((y == 30 or x == sx + 8) and SK.shade or SK.hi))
      end
    end end
    P(sx + 7, 28 + hd, SHL.deep); P(sx + 8, 28 + hd, SHL.deep); P(sx + 7, 28 + hd, CREAM)
    P(sx + 3, 31 + hd, K); P(sx + 4, 32 + hd, K); P(sx + 5, 32 + hd, K); P(sx + 6, 31 + hd, K)
    P(sx + 1, 29 + hd, SHL.base); P(sx + 2, 29 + hd, SHL.base)
    for x = 36, 53 do if get(x, 22 + hd) then P(x, 22 + hd, SK.shade) end end
    -- big shell on the back, spiral facing us
    shell(25.5, 45 + b, 14.5, 2.5, 1, 0, 0)
    -- strap from the neck to the satchel on the shell flank
    line(42, 36 + b, 19 + sway, 52 + b, SHL.deep)
    satchel(13, 52 + b)
    -- scarf at the neck, tail streaming back over the shell
    for y = 34, 36 do
      local yy = y + b
      local t = (yy - top) / (64 - top)
      local cx, hw = 46 + L - 4 * t, 5 + 4 * t * t
      for x = floor(cx - hw + 0.5), floor(cx + hw + 0.5) - 1 do
        P(x, yy, y == 36 and SK.deep or ((y == 35 and x % 4 == 1) and SK.hi or GREEN))
      end
    end
    local tw = (wi >= 1 and wi % 2 == 0) and 1 or 0
    rows(33, 33 + b + tw, {"..ggggg", ".gggg..", "gg.g...", "g......"}, {g = GREEN})
    P(36, 34 + b + tw, SK.hi)
    hat(hx - 0.5, 21 + hd, 8, 6, false, true)
    -- near eyestalk leaning forward, eye looking ahead
    stalk(sx + 3, 21 + hd, sx + 4 + aL, 14 + hd, false)
    bulb(sx + 5 + aL, 12 + hd, 1, false)
  end
  for k, c in pairs(G) do img:putPixel(k % 64, k // 64, c) end
  N.outline(img, K)
end
return S
