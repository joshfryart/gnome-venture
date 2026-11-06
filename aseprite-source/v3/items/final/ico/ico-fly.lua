-- ico-fly (final pass, Opus). A greenbottle fly seen from above: big faceted red eyes, grey striped thorax,
-- slim metallic green abdomen, two veined glassy wings swept back in a V, six jointed legs.
-- Material: per-pixel light on every part (6-tone ramps), facet grid + glint on the eyes, metallic
-- specular streak and segment grooves on the abdomen, wings tinted where the body shows through them,
-- dark ambient rows at the neck and waist.
-- quirk: it is rubbing its front feet together, plotting something.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA4_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sqrt, max, min, abs = math.floor, math.sqrt, math.max, math.min, math.abs
local c = A.new("ico-fly")
local GREY  = { "#211f2c", "#363446", "#504e64", "#6c6a84", "#9290aa", "#c4c2d6" }
local EYE   = { "#5a1a2a", "#8e2030", "#c03030", "#e2503a", "#f58a5a", "#ffc4a0" }
local GREEN = { "#123038", "#18484a", "#1f6c5a", "#2c9468", "#58c07a", "#aeeaa0" }
local WING  = { "#6c8cb6", "#98b6d8", "#bad4ea", "#d4e8f6", "#e8f4fc", "#f6fbff" }
local WOVER = { "#2e4a62", "#3e6280", "#56809c", "#7aa2bc", "#9ec2d4", "#c6e0ea" }
local LEG, LEGH = "#2b2534", "#5a5470"

-- legs (behind everything): polylines, 2 px, lit pixel on the knee
local ltok = A.tok("leg")
local legs = {
  { { 29, 21 }, { 26, 13 }, { 30, 7 }, { 33, 5 } },   -- front left, reaching forward and crossing
  { { 35, 21 }, { 38, 13 }, { 34, 7 }, { 31, 5 } },   -- front right
  { { 27, 26 }, { 19, 22 }, { 13, 25 } },
  { { 37, 26 }, { 45, 22 }, { 51, 25 } },
  { { 29, 31 }, { 22, 41 }, { 21, 51 } },
  { { 35, 31 }, { 42, 41 }, { 43, 51 } },
}
for _, l in ipairs(legs) do
  local m = c:line(l, 2)
  c:fillMask(m, LEG)
  m:each(function(x, y) if not m:has(x - 1, y) and not m:has(x, y - 1) then c:put(x, y, LEGH) end end)
  local kx, ky = l[2][1], l[2][2]
  c:put(kx, ky, LEGH) c:put(kx - 1, ky, LEGH)
end
-- feet: the rubbing front feet are a little knot with a lit pixel
c:fillMask(HP.rect(31, 4, 33, 6), LEG) c:put(31, 4, LEGH) c:put(32, 4, LEGH)
-- re-own leg pixels so the outline goes round them
for k, _ in pairs(c.pix) do if c.own[k] == true then c.own[k] = ltok end end

-- abdomen: slim teardrop, metallic green
local ab = HP.mask()
for y = 30, 53 do
  local t = (y - 30) / 23
  local hw = 6.6 * sqrt(max(0, 1 - (2 * t - 0.75) ^ 2 / 1.6)) * (t < 0.8 and 1 or (1 - (t - 0.8) * 2.6))
  for x = 20, 44 do if abs(x + 0.5 - 32.5) <= hw then ab:set(x, y) end end
end
local atok = A.tok("abdomen")
local an = X.pillow(ab, 5)
local abias = {}
local aidx = A.shade(c, ab, an, GREEN, { amb = 0.05, wrap = 0.2, tilt = { 32, 40, 12, 0.1 }, bias = abias, tok = atok })
for _, gy in ipairs{ 37, 42, 47 } do
  ab:each(function(x, y)
    local off = floor(((x - 32.5) / 6) ^ 2 * 1.5 + 0.5)
    if y == gy - off then A.step(c, aidx, GREEN, x, y, -2, atok)
    elseif y == gy - off - 1 then A.step(c, aidx, GREEN, x, y, 1, atok) end
  end)
end
for _, p in ipairs{ { 29, 33 }, { 29, 34 }, { 28, 35 }, { 28, 39 }, { 28, 40 }, { 28, 44 } } do c:put(p[1], p[2], GREEN[6], atok) end
c:put(29, 33, A.CREAM, atok)
-- cool bounce on the lower-right of the abdomen
ab:edge():each(function(x, y) if x > 34 and y > 38 and y < 50 then c:put(x, y, "#3a5f8a", atok) end end)

-- thorax: grey, three dark stripes, bristles
local th = HP.ellipse(32, 25, 6.5, 6)
local ttok = A.tok("thorax")
local tn = X.pillow(th, 4.5)
local tbias = {}
X.ao(abias, ab, th, 1, -2)
local tidx = A.shade(c, th, tn, GREY, { amb = 0.06, wrap = 0.25, tilt = { 32, 25, 7, 0.12 }, bias = tbias, tok = ttok })
for _, sx in ipairs{ 29, 32, 35 } do for y = 21, 29 do if th:has(sx, y) then A.step(c, tidx, GREY, sx, y, -2, ttok) end end end
for _, p in ipairs{ { 30, 20 }, { 33, 20 }, { 27, 24 }, { 37, 23 } } do if th:has(p[1], p[2]) then c:put(p[1], p[2], GREY[1], ttok) end end
c:put(30, 22, GREY[6], ttok) c:put(31, 22, GREY[6], ttok)
-- waist ambient: abdomen just below thorax gets a dark row
for x = 27, 37 do if ab:has(x, 31) and not th:has(x, 31) then c:put(x, 31, GREEN[1], atok) end end

-- head: dark face plate between two big compound eyes
local hd = HP.ellipse(32, 15, 7.5, 4.5)
local htok = A.tok("head")
A.shade(c, hd, X.pillow(hd, 3), GREY, { amb = 0.05, wrap = 0.2, tok = htok })
for x = 27, 37 do if th:has(x, 19) or th:has(x, 20) then
  local y = 19 while hd:has(x, y) do y = y + 1 end
  if th:has(x, y) then c:put(x, y, GREY[1], ttok) end end end
local etok = A.tok("eye")
for i, e in ipairs{ { 27.5, 14.5 }, { 36.5, 14.5 } } do
  local em = HP.ellipse(e[1], e[2], 4, 4.5)
  local en = X.sphere(e[1], e[2], 4.5, em)
  local eidx = A.shade(c, em, en, EYE, { amb = 0.08, wrap = 0.15, tok = etok, cuts = { 0.18, 0.34, 0.5, 0.66, 0.84 } })
  em:each(function(x, y) if x % 2 == 0 and y % 2 == 1 and eidx[K(x, y)] and eidx[K(x, y)] >= 3 then A.step(c, eidx, EYE, x, y, -1, etok) end end)
  local gx, gy = floor(e[1] - 2), floor(e[2] - 2)
  c:put(gx, gy, A.CREAM, etok) c:put(gx + 1, gy, EYE[6], etok) c:put(gx, gy + 1, EYE[6], etok)
end
-- dark seam between the eyes
for y = 11, 18 do if hd:has(32, y) then c:put(32, y, GREY[1], htok) end end

-- wings: swept back over the abdomen; glassy, tinted where the body shows through
local wtok = A.tok("wing")
local body = ab:copy():add(th):add(hd)
for side = -1, 1, 2 do
  local wm = A.rot(32 + side * 10.5, 34, 12, 4.6, side * 0.85)
  wm:cut(th):cut(hd)
  -- cut the root to start at the thorax shoulder
  wm:each(function(x, y) if (side < 0 and x > 30) or (side > 0 and x < 34) then wm.s[K(x, y)] = nil end end)
  local wn = X.pillow(wm, 2.5)
  local v = A.val(wn, { amb = 0.35, wrap = 0.4, tilt = { 32 + side * 10, 34, 12, 0.15 } })
  local cuts = { 0.3, 0.48, 0.64, 0.78, 0.9 }
  wm:each(function(x, y)
    local k = K(x, y)
    local i = 1 for j, t in ipairs(cuts) do if v[k] >= t then i = j + 1 end end
    if ab:has(x, y) then
      local bi = aidx[k] or 3
      c:put(x, y, WOVER[max(1, min(6, floor((i + bi) / 2) + 1))], wtok)
    else c:put(x, y, WING[i], wtok) end
  end)
  -- veins: three lines from the root fanning to the tip, plus a dark leading-edge vein
  local rx, ry = 32 + side * 3, 26
  local tipx, tipy = 32 + side * 19, 43
  for _, off in ipairs{ -2.2, 0.3, 2.6 } do
    local ln = c:line({ { rx, ry }, { tipx + off * 0.7 * side, tipy + off } }, 1)
    ln:each(function(x, y) if wm:has(x, y) then c:put(x, y, ab:has(x, y) and WOVER[1] or WING[1], wtok) end end)
  end
  wm:edge():each(function(x, y)
    if (side < 0 and y - 34 < (x - 21.5) * -1.1) or (side > 0 and y - 34 < (x - 42.5) * 1.1) then c:put(x, y, "#5a78a6", wtok) end
  end)
  -- glint near the root
  local gx = side < 0 and 25 or 37
  if wm:has(gx, 29) and wm:has(gx + 1, 29) then c:put(gx, 29, WING[6], wtok) c:put(gx + 1, 29, WING[6], wtok) end
end
A.save(c, "ico-fly")
