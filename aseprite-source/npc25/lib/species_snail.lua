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
  local SHL = {hi = h"#dab65c", base = h"#d48e3e", shade = h"#9e5c3c", deep = h"#5e3446"}
  local HAT, SCARF, CREAM = h"#dab65c", h"#5ca24c", h"#ecdab2"
  local SL, SD = h"#aaa9b8", h"#74758c"
  local function P(x, y, c) N.px(img, floor(x), floor(y), c) end
  local function R(x, y, w, hh, c) N.rect(img, x, y, w, hh, c) end
  local function E(x, y, w, hh, c) N.ellipse(img, x, y, w, hh, c) end
  local function rows(x0, y0, t, map)
    for j, row in ipairs(t) do
      for i = 1, #row do
        local c = map[row:sub(i, i)]
        if c then P(x0 + i - 1, y0 + j - 1, c) end
      end
    end
  end
  local function line(x0, y0, x1, y1, c)
    local n = math.max(abs(x1 - x0), abs(y1 - y0), 1)
    for i = 0, n do P(floor(x0 + (x1 - x0) * i / n + 0.5), floor(y0 + (y1 - y0) * i / n + 0.5), c) end
  end
  local walking = frame >= 3
  local stretch = walking and b == 0
  local wi = frame - 2

  -- spiral shell: lit upper-left, rim shade, 1 px deep groove with a shade lip
  local function shell(cx, cy, r, turns, dir)
    local sp = r / turns
    for y = floor(cy - r - 1), floor(cy + r + 1) do
      for x = floor(cx - r - 1), floor(cx + r + 1) do
        local dx, dy = x + 0.5 - cx, y + 0.5 - cy
        local d = sqrt(dx * dx + dy * dy)
        if d <= r then
          local s = (-0.6 * dx - 0.8 * dy) / r
          local c = SHL.base
          if s > 0.42 then c = SHL.hi elseif s < -0.3 then c = SHL.shade end
          if d > r - 1.3 and s < 0.25 then c = SHL.shade end
          local th = atan(dy, dir * dx) / (2 * math.pi)
          local u = d / sp + th
          local fr = u - floor(u)
          if d < r - 1.2 then
            if fr < 1.1 / sp then c = SHL.deep
            elseif fr < 2.1 / sp and s < 0.5 then c = SHL.shade end
          end
          if d < 1.2 then c = SHL.deep end
          P(x, y, c)
        end
      end
    end
  end
  -- quirk: mail satchel (brown bag, deep seams, gold clasp, cream letter peeking out)
  local sway = (frame == 4 or frame == 5) and 1 or ((frame == 7 or frame == 8) and -1 or 0)
  local function satchel(x, y)
    rows(x + sway, y, {
      ".cc..",
      "dqqqd",
      "dqhqd",
      "dqqqd",
      "ddddd",
    }, {c = CREAM, d = SHL.deep, q = SHL.shade, h = HAT})
  end
  -- eye on a stalk: 5x5 bulb, ink pupil looking (px,py), cream glint
  local function bulb(x, y, look, far)
    E(x, y, 5, 5, far and SK.shade or SK.base)
    if not far then P(x + 1, y + 1, SK.hi); P(x + 1, y, SK.hi) end
    if look then
      R(x + 1 + look, y + 1, 2, 3, K)
      P(x + 1 + look, y + 1, CREAM)
    end
  end
  local function stalk(x0, y0, x1, y1, far)
    line(x0, y0, x1, y1, far and SK.shade or SK.base)
    line(x0 + 1, y0, x1 + 1, y1, far and SK.deep or SK.shade)
  end
  local function dots(x0, y0, w, hh)
    for y = y0, y0 + hh - 1 do for x = x0, x0 + w - 1 do
      if (x * 3 + y * 5) % 13 == 0 then P(x, y, SK.shade) end
    end end
  end
  -- straw hat: brim + crown + green band, weave ticks
  local function hat(bx, by, bw, cx, cw, back)
    E(bx, by, bw, 6, SHL.shade)
    E(bx, by, bw, 5, HAT)
    R(bx + 3, by + 1, bw - 6, 1, SK.hi)
    for x = bx + 3, bx + bw - 4, 3 do P(x, by + 3, SHL.base) end
    R(cx, by - 4, cw, 5, HAT)
    R(cx + 1, by - 4, cw - 2, 1, SK.hi)
    R(cx + cw - 2, by - 3, 2, 4, SHL.base)
    R(cx, by - 1, cw, 2, SCARF)
    if back then P(cx + 2, by + 1, SCARF); P(cx + 3, by + 2, SCARF) end
  end

  -- ground shadow
  E(16, 65, 33, 6, SD)
  E(18, 65, 29, 4, SL)

  if view == "front" or view == "back" then
    local front = view == "front"
    local wide = (walking and b == 1) and 1 or 0
    -- foot skirt
    E(14 - wide, 61, 36 + 2 * wide, 10, SK.base)
    R(16, 61, 6, 1, SK.hi)
    for x = 14 - wide, 49 + wide do P(x, 69, SK.shade); P(x, 70, SK.shade) end
    R(20, 70, 24, 1, SK.deep)
    -- ripple moving along the sole
    if walking then
      for x = 16, 47 do if (x + wi * 2) % 6 == 0 then P(x, 67, SK.shade); P(x + 1, 68, SK.shade) end end
    end
    -- body column
    local top = 32 + b
    R(22 - wide, top, 20 + 2 * wide, 64 - top, SK.base)
    R(22 - wide, top, 2, 64 - top, SK.hi)
    R(39 + wide, top, 3, 64 - top, SK.shade)
    dots(24, top + 2, 15, 60 - top)
    R(23, 63, 18, 1, SK.shade)
    if front then
      -- shell peeking on the left, satchel on it, strap over the chest
      shell(20.5, 45.5 + b, 11, 2.2, 1)
      line(17 + sway, 47 + b, 40, 36 + b, SHL.deep)
      satchel(12, 46 + b)
      R(23, 40 + b, 2, 22, SK.hi)
    else
      shell(32, 46 + b, 13.5, 2.6, -1)
      line(21, 38 + b, 39 + sway, 50 + b, SHL.deep)
      line(21, 39 + b, 39 + sway, 51 + b, SHL.deep)
      satchel(37, 49 + b)
    end
    -- eyestalks (front view: lean = x shift)
    local function stalks(far)
      stalk(27, 22 + hd, 26 + aL, 13 + hd, far); stalk(35, 22 + hd, 36 + aR, 13 + hd, far)
      bulb(24 + aL, 9 + hd, front and 1 or nil, far)
      bulb(35 + aR, 9 + hd, front and 0 or nil, far)
    end
    -- head
    E(20, 19 + hd, 24, 18, SK.base)
    E(22, 21 + hd, 6, 8, SK.hi)
    E(23, 22 + hd, 6, 8, SK.base)
    for y = 24, 34 do P(42, y + hd, SK.shade); P(41, y + 1 + hd, SK.shade) end
    if front then
      R(22, 24 + hd, 20, 1, SK.shade)                 -- hat brim shadow
      E(27, 28 + hd, 10, 6, SK.hi)                    -- muzzle
      R(31, 29 + hd, 2, 1, K); P(31, 28 + hd, CREAM)  -- nose with glint
      P(29, 31 + hd, K); P(30, 32 + hd, K); P(31, 32 + hd, K); P(32, 32 + hd, K); P(33, 32 + hd, K); P(34, 31 + hd, K)
      R(24, 29 + hd, 2, 1, SHL.base); R(38, 29 + hd, 2, 1, SHL.base)   -- warm cheeks
      -- scarf: knotted triangle under the chin with light dots
      for j = 0, 7 do
        local w = 20 - j * 2
        R(32 - w // 2, 35 + j + b, w, 1, SCARF)
      end
      R(22, 35 + b, 20, 1, SK.deep)
      P(27, 37 + b, SK.hi); P(33, 37 + b, SK.hi); P(30, 39 + b, SK.hi); P(36, 36 + b, SK.hi); P(31, 41 + b, SK.hi)
      P(37, 37 + b, SK.deep); P(35, 39 + b, SK.deep); P(33, 41 + b, SK.deep)
      hat(17, 20 + hd, 30, 25, 14, false)
      stalks(false)
    else
      stalks(false)
      E(20, 19 + hd, 24, 16, SK.base)
      E(22, 21 + hd, 6, 8, SK.hi)
      E(23, 22 + hd, 6, 8, SK.base)
      R(22, 33 + hd, 20, 1, SK.shade)
      -- scarf wrap and two tails hanging over the shell
      R(23, 34 + b, 18, 2, SCARF)
      rows(36, 36 + b, {"gg.g", "gg.g", ".g.gg", ".gg.g", "..g..", }, {g = SCARF})
      hat(17, 20 + hd, 30, 25, 14, true)
    end

  else -- side, facing right
    -- long foot with tapered tail on the left, round tip on the right
    local tip = 50 + (stretch and 1 or 0)
    for x = 12, tip do
      local t = 61
      if x < 21 then t = 61 + (21 - x) // 2 + 1 end
      if x >= tip - 1 then t = 63 end
      if x == tip then t = 64 end
      R(x, t, 1, 71 - t, SK.base)
      P(x, 69, SK.shade); P(x, 70, SK.shade)
      if x > 14 and x < tip - 1 then P(x, 70, SK.deep) end
    end
    R(21, 61, 10, 1, SK.hi)
    if walking then
      for x = 14, tip - 3 do if (x + wi * 2) % 6 == 0 then P(x, 66, SK.shade); P(x + 1, 67, SK.shade) end end
    end
    -- neck and head column on the right
    local top = 30 + b
    R(36, top, 12, 64 - top, SK.base)
    R(36, top, 2, 64 - top, SK.hi)
    R(46, top, 2, 64 - top, SK.shade)
    dots(38, top + 4, 8, 60 - top - 4)
    -- shell on the back
    shell(23.5, 45.5 + b, 12, 2.4, 1)
    -- strap from neck to satchel
    line(37, 37 + b, 19 + sway, 49 + b, SHL.deep)
    satchel(14, 49 + b)
    -- far eyestalk behind
    stalk(41, 21 + hd, 40 + aL, 13 + hd, true)
    bulb(38 + aL, 9 + hd, 2, true)
    -- head
    E(33, 18 + hd, 17, 18, SK.base)
    E(35, 20 + hd, 6, 8, SK.hi)
    E(36, 21 + hd, 6, 8, SK.base)
    R(34, 23 + hd, 15, 1, SK.shade)                    -- brim shadow
    E(43, 27 + hd, 7, 6, SK.hi)                        -- muzzle
    P(49, 28 + hd, K); P(49, 29 + hd, K); P(48, 28 + hd, CREAM)
    P(45, 31 + hd, K); P(46, 32 + hd, K); P(47, 32 + hd, K); P(48, 31 + hd, K)
    R(40, 29 + hd, 2, 1, SHL.base)
    for y = 26, 34 do P(34, y + hd, SK.shade) end
    -- scarf around the neck, tail streaming back over the shell
    R(35, 35 + b, 13, 2, SCARF)
    R(35, 37 + b, 13, 1, SK.deep)
    rows(30, 35 + b, {"..ggggg", ".gggg..", "gg.g...", "g......"}, {g = SCARF})
    P(41, 35 + b, SK.hi); P(45, 36 + b, SK.hi)
    -- hat in profile
    hat(29, 19 + hd, 22, 35, 11, false)
    -- near eyestalk leaning forward
    stalk(44, 21 + hd, 45 + aL, 13 + hd, false)
    bulb(43 + aL, 9 + hd, 2, false)
  end
  N.outline(img, K)
end
return S
