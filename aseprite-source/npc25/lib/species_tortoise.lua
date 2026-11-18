-- tortoise tables from specs/tortoise.md. Opus: replace draw_figure only.
local N = dofile((app.params.root or "npc25") .. "/lib/npc25.lua")
local D = dofile((app.params.root or "npc25") .. "/lib/draft_common.lua")
local S = {name = "tortoise", feet_y = 71, outline = "#2b1c26"}
S.ramps = {
  skin = {"#78b04e", "#93a666", "#667a52", "#434d4a"},
  shell = {"#b28c4e", "#c07d3c", "#8a5236", "#57343c"},
  hat = {"#e4c26c", "#dcbc72"}, band = "#78b04e", sprig = "#6a9a48",
  overalls = {"#6188bc", "#465c92", "#323c66"}, strap = "#dcbc72",
  pot = {"#d6693e", "#8a5236", "#57343c"}, sprout = "#78b04e", petal = "#f5809f",
}
S.palette_list = {"#2b1c26", "#78b04e", "#93a666", "#667a52", "#434d4a", "#b28c4e", "#c07d3c", "#8a5236",
  "#57343c", "#e4c26c", "#dcbc72", "#6a9a48", "#6188bc", "#465c92", "#323c66", "#d6693e", "#f5809f", "#fff4d6"}
S.idle = {{0, 0, 0, 0, 0, 0}, {-1, -1, 0, 0, 0, 0}}
S.walk = {{0, 0, 0, -2, 1, -1}, {-1, -1, 0, -1, 0, 0}, {-1, -1, -1, 0, -1, 1},
          {0, 0, -2, 0, -1, 1}, {-1, -1, 0, -1, 0, 0}, {-1, -1, -1, 0, 1, -1}}
local h = N.hex
S.c = {body = h"#c07d3c", bshade = h"#8a5236", bhi = h"#b28c4e", belly = h"#6188bc", arm = h"#93a666",
  head = h"#93a666", hat = h"#dcbc72", ink = h"#2b1c26", fbase = h"#93a666", fshade = h"#667a52",
  q = h"#d6693e", qhi = h"#78b04e"}
S.bw, S.top = 32, 11
S.quirk = {w = 4, h = 3, y = 33, x = {front = 44, back = 30, side = 28}}

-- Stage 3 (Opus): hand-placed pixel art. Light from upper left, shade lower right.
-- Frame 7 lifts the L foot (step note "L lifting") so it differs from frame 4.
function S.draw_figure(img, view, frame, species)
  local o = N.offsets(species, frame)
  local b, hd = o.body, o.head
  local fL, fR = o.footL, o.footR
  if frame == 7 then fL, fR = -1, 0 end
  local K = h(species.outline)
  local SK = {hi = h"#78b04e", base = h"#93a666", shade = h"#667a52", deep = h"#434d4a"}
  local SH = {hi = h"#b28c4e", base = h"#c07d3c", shade = h"#8a5236", deep = h"#57343c"}
  local HAT, HATHI, BAND, SPRIG = h"#dcbc72", h"#e4c26c", h"#78b04e", h"#6a9a48"
  local OV = {base = h"#6188bc", shade = h"#465c92", deep = h"#323c66"}
  local STRAP = h"#dcbc72"
  local POT, POTS, POTD = h"#d6693e", h"#8a5236", h"#57343c"
  local CREAM, PINK = h"#fff4d6", h"#f5809f"
  local function P(x, y, c) N.px(img, x, y, c) end
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
  local sway = (frame == 5 or frame == 8) and 1 or 0
  -- flowerpot with sprout; (x,y) = top-left of the 6x5 pot (ink drawn in)
  local function pot(x, y)
    rows(x, y, {"KKKKKK", "KoohsK", ".KosK.", ".KdsK.", ".KKKK."},
      {K = K, o = POT, h = POT, s = POTS, d = POTS})
    P(x + 1, y + 1, h"#d6693e")
    P(x + 2, y - 1, SK.shade)
    P(x + 2 + sway, y - 2, SK.hi)
    P(x + 1 + sway, y - 2, SK.hi)
    P(x + 3 + sway, y - 3, SK.hi)
    P(x + 2 + sway, y - 3, SK.hi)
    P(x + 2 + sway, y - 4, PINK)
  end
  -- leg: column of skin from top y to sole row (70+lift); toes notched in ink
  local function leg(x, w, top, lift, ramp, dir)
    local sole = 70 + lift
    R(x, top, w, sole - top + 1, ramp.base)
    R(x + w - 2, top, 2, sole - top + 1, ramp.shade)
    P(x, top, ramp.hi); P(x, top + 1, ramp.hi)
    -- foot pad widens 1 px toward dir (0 = both)
    if dir >= 0 then P(x + w, sole, ramp.shade); P(x + w, sole - 1, ramp.shade) end
    if dir <= 0 then P(x - 1, sole, ramp.base); P(x - 1, sole - 1, ramp.base) end
    local cx = dir > 0 and x + 2 or (dir < 0 and x or x + 1)
    P(cx + 1, sole, K); P(cx + 3, sole, K)
  end

  if view == "front" then
    -- rear feet peeking behind (diagonal gait: rear-left lifts with front-right)
    leg(17, 4, 64, fR, {hi = SK.shade, base = SK.shade, shade = SK.deep}, -1)
    leg(43, 4, 64, fL, {hi = SK.shade, base = SK.shade, shade = SK.deep}, 1)
    -- shell behind body
    E(11, 30 + b, 42, 33, SH.deep)
    E(12, 30 + b, 40, 31, SH.shade)
    E(12, 30 + b, 38, 29, SH.hi)
    E(13, 31 + b, 37, 28, SH.base)
    -- scute seams on the visible sides
    for _, q in ipairs({{13, 40}, {14, 41}, {14, 49}, {13, 50}, {49, 40}, {48, 41}, {49, 49}, {50, 50}}) do
      P(q[1], q[2] + b, SH.shade)
    end
    -- front legs
    leg(22, 7, 58 + b, fL, SK, -1)
    leg(35, 7, 58 + b, fR, SK, 1)
    -- torso (skin chest) and overalls
    E(20, 32 + b, 24, 30, SK.base)
    R(37, 40 + b, 5, 18, SK.shade)
    R(21, 49 + b, 22, 11, OV.base)       -- trousers
    R(22, 41 + b, 20, 9, OV.base)        -- bib
    R(39, 41 + b, 3, 19, OV.shade)
    R(22, 59 + b, 21, 1, OV.deep)
    R(31, 52 + b, 1, 7, OV.shade)        -- leg seam
    R(27, 43 + b, 10, 1, OV.shade)       -- pocket top
    P(27, 44 + b, OV.shade); P(36, 44 + b, OV.shade)
    R(27, 47 + b, 10, 1, OV.shade)
    -- straps
    for y = 33, 40 do P(24, y + b, STRAP); P(25, y + b, STRAP); P(38, y + b, STRAP); P(39, y + b, HAT) end
    P(24, 41 + b, HATHI); P(39, 41 + b, HATHI)
    -- arms (swing shown as hand height)
    local function arm(x, ay, mirror)
      R(x, ay, 5, 11, SK.base)
      if mirror then R(x + 3, ay, 2, 11, SK.shade) else P(x, ay, SK.hi); P(x, ay + 1, SK.hi); P(x + 4, ay + 2, SK.shade) end
      R(x, ay + 11, 5, 3, mirror and SK.shade or SK.base)
      P(x + 1, ay + 13, K); P(x + 3, ay + 13, K)
      R(mirror and x - 1 or x + 5, ay + 1, 1, 9, K) -- inner edge against body
    end
    arm(15, 37 + b - o.armL, false)
    arm(44, 37 + b - o.armR, true)
    -- neck shadow
    R(27, 32 + hd, 10, 2, SK.shade)
    -- head
    E(21, 17 + hd, 22, 16, SK.shade)
    E(21, 17 + hd, 20, 15, SK.base)
    E(23, 19 + hd, 7, 4, SK.hi)
    R(22, 21 + hd, 20, 1, SK.deep)        -- brim shadow
    R(23, 22 + hd, 18, 1, SK.shade)
    -- eyes: cream with 2x3 ink pill and glint
    rows(25, 23 + hd, {"cKK", "cKc", "cKK"}, {c = CREAM, K = K})
    rows(36, 23 + hd, {"KKc", "cKc", "KKc"}, {c = CREAM, K = K})
    P(26, 23 + hd, CREAM); P(37, 23 + hd, CREAM)
    -- snout: nostrils
    P(30, 26 + hd, SK.deep); P(33, 26 + hd, SK.deep)
    -- cheeks
    R(23, 27 + hd, 2, 1, PINK); R(39, 27 + hd, 2, 1, PINK)
    -- smile
    R(28, 29 + hd, 8, 1, K); P(27, 28 + hd, K); P(36, 28 + hd, K)
    P(31, 30 + hd, SK.shade); P(32, 30 + hd, SK.shade)
    -- straw hat
    E(15, 15 + hd, 34, 7, HAT)
    R(17, 17 + hd, 30, 1, HATHI)
    R(19, 20 + hd, 26, 1, SH.hi)
    for x = 17, 46, 3 do P(x, 18 + hd, HATHI) end
    R(25, 11 + hd, 14, 6, HAT)
    R(26, 11 + hd, 6, 1, HATHI); R(25, 12 + hd, 2, 2, HATHI)
    R(25, 14 + hd, 14, 2, BAND)
    R(36, 14 + hd, 3, 2, SPRIG)
    -- leaf sprig on band
    rows(37, 11 + hd, {"..ll", ".lLl", "lL.."}, {l = SPRIG, L = BAND})
    -- flowerpot peeking above right shoulder
    pot(44, 30 + b)
    N.outline(img, K)
    -- round off crown corners
    P(25, 11 + hd, 0); P(38, 11 + hd, 0)
    P(25, 10 + hd, 0); P(38, 10 + hd, 0)
    P(25, 11 + hd, K); P(38, 11 + hd, K)

  elseif view == "back" then
    -- rear legs, feet pointing outward
    leg(19, 7, 58 + b, fL, SK, -1)
    leg(38, 7, 58 + b, fR, SK, 1)
    -- head back (mostly behind shell)
    E(22, 17 + hd, 20, 15, SK.shade)
    E(22, 17 + hd, 18, 14, SK.base)
    R(23, 21 + hd, 18, 1, SK.deep)
    -- arms peeking at the shell sides
    R(11, 41 + b - o.armL, 3, 9, SK.base)
    R(50, 41 + b - o.armR, 3, 9, SK.shade)
    -- shell dome
    E(12, 28 + b, 40, 36, SH.deep)
    E(12, 28 + b, 40, 33, SH.shade)
    E(12, 28 + b, 38, 32, SH.hi)
    E(13, 29 + b, 37, 31, SH.base)
    -- scutes: centre plate and 4 ring plates, seams in shade
    local cy = 44 + b
    rows(25, cy - 6, {
      "...SSSSSSSS...",
      "..S........S..",
      ".S..........S.",
      "S............S",
      "S............S",
      "S............S",
      "S............S",
      "S............S",
      ".S..........S.",
      "..S........S..",
      "...SSSSSSSS...",
    }, {S = SH.shade})
    -- radial seams from centre plate to rim
    for k = 0, 5 do P(25 - k, cy - 7 - k // 2, SH.shade); P(38 + k, cy - 7 - k // 2, SH.shade) end
    for k = 0, 6 do P(25 - k, cy + 5 + k // 2, SH.shade); P(38 + k, cy + 5 + k // 2, SH.shade) end
    R(26, cy - 5, 4, 1, SH.hi); R(26, cy - 4, 2, 2, SH.hi)
    -- rim band
    for x = 14, 49, 4 do P(x, 58 + b + (x < 20 and -2 or (x > 44 and -2 or 0)), SH.shade) end
    -- overall straps crossing over the shell
    for k = 0, 9 do
      P(25 + k, 30 + b + k, STRAP); P(26 + k, 30 + b + k, STRAP)
      P(38 - k, 30 + b + k, HAT); P(37 - k, 30 + b + k, HAT)
    end
    R(31, 34 + b, 2, 2, HATHI)
    -- straw hat from behind
    E(15, 15 + hd, 34, 7, HAT)
    R(17, 17 + hd, 30, 1, HATHI)
    for x = 18, 46, 3 do P(x, 19 + hd, HATHI) end
    R(25, 11 + hd, 14, 6, HAT)
    R(26, 11 + hd, 6, 1, HATHI); R(25, 12 + hd, 2, 2, HATHI)
    R(25, 14 + hd, 14, 2, BAND)
    rows(23, 11 + hd, {"ll..", "lLl.", "..Ll"}, {l = SPRIG, L = BAND})
    pot(34, 25 + b)
    N.outline(img, K)
    P(25, 10 + hd, 0); P(38, 10 + hd, 0)
    P(38, 11 + hd, K)

  else -- side, facing right
    local farS = {hi = SK.shade, base = SK.shade, shade = SK.deep}
    local function get(x, y) return img:getPixel(x, y) end
    local darker = {[SK.hi] = SK.base, [SK.base] = SK.shade, [SK.shade] = SK.deep,
      [OV.base] = OV.shade, [OV.shade] = OV.deep, [STRAP] = HAT}
    -- far leg (shade), opposite phase, peeks in front of the near leg
    leg(41 + o.armR, 5, 58 + b, fR, farS, 1)
    -- torso: rounded chest and belly; the back half is hidden by the shell
    local spans = {{31, 34, 42}, {32, 32, 44}, {33, 31, 44}, {34, 30, 45}, {42, 30, 46}, {56, 30, 45}, {58, 31, 44}, {59, nil}}
    for k = 1, #spans - 1 do
      local s = spans[k]
      for y = s[1], spans[k + 1][1] - 1 do R(s[2], y + b, s[3] - s[2] + 1, 1, SK.base) end
    end
    R(43, 33 + b, 2, 9, SK.shade)
    -- overalls: sloped bib top (front higher), wraps the body down to the hem
    for x = 30, 46 do
      local top = x < 34 and 39 or (x < 38 and 37 or 35)
      for y = top, 58 do
        if get(x, y + b) ~= 0 then P(x, y + b, OV.base) end
      end
    end
    R(45, 36 + b, 2, 20, OV.shade); R(38, 35 + b, 8, 1, OV.shade); R(44, 56 + b, 2, 2, OV.shade)
    R(31, 57 + b, 14, 1, OV.shade); R(31, 58 + b, 14, 1, OV.deep)
    R(33, 48 + b, 6, 1, OV.shade)                      -- waist seam
    -- strap over the shoulder to the bib corner, with a button
    -- neck: leans forward out of the collar, wrinkle ticks, jaw shadow
    for y = 23, 33 do
      local x1 = 46 - (y - 25) // 4
      R(34, y + hd, x1 - 33, 1, SK.base)
      P(x1, y + hd, SK.shade); P(x1 - 1, y + hd, SK.shade)
    end
    P(40, 29 + hd, SK.shade); P(41, 29 + hd, SK.shade); P(41, 31 + hd, SK.shade); P(42, 31 + hd, SK.shade)
    for k = 0, 5 do P(34 + k * 2 // 3, 30 + k + b, STRAP); P(35 + k * 2 // 3, 30 + k + b, HAT) end
    P(38, 35 + b, STRAP); P(39, 35 + b, HATHI); P(40, 35 + b, STRAP)
    -- shell: dome carried on the back, front lip wraps around the body
    local scx, scy, srx, sry = 25.5, 42 + b, 15.5, 18.5
    local function rimx(y) local t = (y - b - 42) / 18; return 31 + math.floor(6 * t * t + 0.5) end
    local function ell(x, y)
      local u, v = (x - scx) / srx, (y - scy) / sry
      return u, v, math.sqrt(u * u + v * v)
    end
    local function inside(x, y) local _, _, r = ell(x, y); return r <= 0.97 and x <= rimx(y) end
    local radial = {-100, -148, 165, 122, 80}
    local ticks = {-122, -170, 145, 100, 60, -78}
    local function seam(x, y)
      if not inside(x, y) or x >= rimx(y) - 2 then return false end
      local u, v, r = ell(x, y)
      if r < 0.01 then return false end
      local px = math.sqrt((u * srx) ^ 2 + (v * sry) ^ 2) / r   -- px radius along this direction
      if math.abs(r - 0.82) * px < 0.5 then return true end
      if math.abs(r - 0.40) * px < 0.5 then return true end
      local ang = math.deg(math.atan(v * sry, u * srx))
      local list = r > 0.82 and ticks or (r > 0.40 and radial or nil)
      if list then
        for _, a in ipairs(list) do
          local ca, sa = math.cos(math.rad(a)), math.sin(math.rad(a))
          local dx, dy = x - scx, y - scy
          if dx * ca + dy * sa > 0 and math.abs(dx * sa - dy * ca) < 0.55 then return true end
        end
      end
      return false
    end
    local step = {[SH.hi] = SH.base, [SH.base] = SH.shade, [SH.shade] = SH.deep, [SH.deep] = SH.deep}
    local up = {[SH.deep] = SH.shade, [SH.shade] = SH.base, [SH.base] = SH.hi, [SH.hi] = SH.hi}
    for y = 20 + b, 64 + b do
      for x = 8, 40 do
        if inside(x, y) then
          local u, v, r = ell(x, y)
          local lit = -0.6 * u - 0.8 * v
          local rx = rimx(y)
          local c
          if x >= rx - 1 then
            c = (v < 0.25) and SH.hi or SH.base               -- front lip (rim)
            if x == rx and v >= 0.25 then c = SH.shade end
          elseif x == rx - 2 then
            c = SH.deep
          elseif r > 0.82 then                                 -- marginal band
            c = lit > 0.45 and SH.base or (lit > -0.1 and SH.shade or SH.deep)
          else
            c = lit > 0.42 and SH.hi or (lit > -0.25 and SH.base or SH.shade)
          end
          if seam(x, y) then c = step[c]
          elseif r <= 0.82 and x < rx - 2 and (seam(x - 1, y) or seam(x, y - 1)) then c = up[c]
          end
          P(x, y, c)
        end
      end
    end
    -- highlight cluster on the upper-left plate
    P(17, 31 + b, HAT); P(18, 31 + b, HAT); P(16, 32 + b, HAT); P(17, 32 + b, HATHI)
    P(16, 34 + b, SH.hi)
    -- shadow the shell lip casts on the body
    for y = 24, 60 do
      local x = rimx(y + b) + 1
      local c = get(x, y + b)
      if darker[c] then P(x, y + b, darker[c]) end
    end
    -- head
    E(35, 14 + hd, 19, 15, SK.shade)
    E(35, 14 + hd, 18, 14, SK.base)
    R(49, 22 + hd, 6, 5, SK.base)           -- snout
    R(49, 26 + hd, 6, 1, SK.shade)
    P(54, 22 + hd, 0); P(54, 26 + hd, 0)
    E(37, 15 + hd, 6, 4, SK.hi)
    R(37, 19 + hd, 16, 1, SK.deep)
    R(38, 20 + hd, 14, 1, SK.shade)
    R(40, 27 + hd, 9, 1, SK.shade)           -- jaw shadow onto neck
    rows(45, 21 + hd, {"cKK", "cKc", "cKK"}, {c = CREAM, K = K})
    P(46, 21 + hd, CREAM)
    P(53, 23 + hd, SK.deep)                  -- nostril
    R(49, 27 + hd, 4, 1, K); P(48, 26 + hd, K) -- mouth
    R(43, 25 + hd, 2, 1, PINK)
    -- near arm (swings with armL), in front of the shell lip
    local ax = 38 + o.armL
    R(ax, 37 + b, 5, 13, SK.base)
    R(ax + 3, 38 + b, 2, 12, SK.shade)
    R(ax + 1, 36 + b, 3, 1, SK.base)
    P(ax + 1, 37 + b, SK.hi); P(ax, 38 + b, SK.hi)
    R(ax, 50 + b, 6, 3, SK.base)
    R(ax + 4, 50 + b, 2, 2, SK.shade)
    P(ax + 2, 52 + b, K); P(ax + 4, 52 + b, K)
    R(ax - 1, 39 + b, 1, 13, K)
    -- near leg, steps out from under the hem
    leg(33 + o.armL, 7, 59 + b, fL, SK, 1)
    R(33 + o.armL, 59 + b, 7, 1, SK.shade)
    -- hat profile
    E(30, 15 + hd, 24, 6, HAT)
    R(32, 17 + hd, 21, 1, HATHI)
    for x = 33, 52, 3 do P(x, 18 + hd, HATHI) end
    R(34, 20 + hd, 18, 1, SH.hi)
    R(37, 11 + hd, 12, 6, HAT)
    R(38, 11 + hd, 5, 1, HATHI); R(37, 12 + hd, 2, 2, HATHI)
    R(37, 14 + hd, 12, 2, BAND)
    rows(34, 11 + hd, {"ll..", "lLl.", "..Ll"}, {l = SPRIG, L = BAND})
    pot(22, 19 + b)
    N.outline(img, K)
    P(48, 10 + hd, 0); P(48, 11 + hd, K)
  end
end
return S
