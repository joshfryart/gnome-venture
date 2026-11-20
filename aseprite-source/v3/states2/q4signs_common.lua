-- Shared helpers for the BUILD-sign craft pass of quail_coop, silk_shelf, tortoise_run, butterfly_bush (empty state only).
local K = dofile("/tmp/ase/states2/qs_common.lua")
local SF = dofile("/tmp/ase/states2/signfont.lua")
local HP, P = K.HP, K.P
local S = { K = K, HP = HP, P = P, SF = SF }
local lerp, hsh = K.lerp, K.hsh

S.EARTH = { hi = "#d2a774", base = "#b4835a", shade = "#946446", deep = "#6c4232" }
S.SHADOW = K.SHADOW

function S.new(w, h, name) S.c = K.newc(w, h, name) return S.c end
local function c() return S.c end
local function px(x, y, hex) S.c:px(x, y, hex) end
S.px = px
function S.R(x0, y0, x1, y1, hex) S.c:fillMask(S.c:rect(x0, y0, x1, y1), hex) end
function S.text(x, y, col, shadow) SF.text(px, x, y, col, shadow) end

-- cleared, flush ground: packed earth in 3 tones with a darker cut rim, irregular edge
-- (x0,y0)-(x1,y1) bbox; returns the mask
function S.plot(x0, y0, x1, y1, seed)
  seed = seed or 1
  local cv = S.c
  local cx, cy = (x0 + x1) / 2, (y0 + y1) / 2
  local rx, ry = (x1 - x0) / 2, (y1 - y0) / 2
  local m = HP.mask()
  for y = y0, y1 do for x = x0, x1 do
    -- superellipse (squarish oval) with a ragged edge
    local u, v = math.abs((x - cx) / (rx + .5)), math.abs((y - cy) / (ry + .5))
    local d = u ^ 3.2 + v ^ 2.6
    local j = (hsh(x * 7 + seed, y * 3 + seed) - 50) / 50 * .09
    if d < 1 + j then m:set(x, y) end
  end end
  local E = S.EARTH
  cv:fillMask(m, E.base)
  -- big soft tonal zones: lit back-left half, shaded front-right
  m:each(function(x, y)
    local t = (x - cx) / rx * .55 + (y - cy) / ry * .8
    local h = hsh(x // 3 + seed, y // 2 + seed * 3)
    if t < -.55 and h < 70 then px(x, y, E.hi)
    elseif t > .7 and h < 75 then px(x, y, E.shade) end
  end)
  -- crumbs: 2x1 lit clod with a shade pixel under its right end
  m:each(function(x, y)
    local h = hsh(x * 5 + seed * 11, y * 9 + seed)
    if h < 4 and m:has(x + 1, y + 1) and m:has(x + 2, y) then
      px(x, y, E.hi) px(x + 1, y, E.hi) px(x + 1, y + 1, E.shade)
    elseif h > 96 then px(x, y, E.shade) end
  end)
  -- darker cut rim, thicker on the far (top) lip where the cut face shows
  m:each(function(x, y)
    if not m:has(x, y + 1) or not m:has(x - 1, y) or not m:has(x + 1, y) then px(x, y, E.deep) end
    if not m:has(x, y - 1) then px(x, y, E.deep) if m:has(x, y + 1) then px(x, y + 1, E.shade) end end
  end)
  S.plotMask = m
  return m
end

-- grass tufts hanging over the cut edge to tie the plot to the lawn
function S.tuft(x, y)
  px(x, y, P.moss.shade) px(x + 1, y - 1, P.moss.base) px(x + 2, y, P.moss.shade) px(x + 1, y, P.moss.base) px(x + 2, y - 2, P.moss.hi)
end
function S.pebble(x, y, big)
  if big then K.sprite({ ".hb.", "hbbs", ".ss." }, x, y, { h = P.stone.hi, b = P.stone.base, s = P.stone.shade })
  else K.sprite({ "hb", "bs" }, x, y, { h = P.stone.hi, b = P.stone.base, s = P.stone.shade }) end
end
-- small flower: 5-px head, 2-px stem, optional leaf
function S.flower(x, y, col, centre, leafSide)
  local cv = S.c
  local head = HP.mask():set(x, y - 1):set(x - 1, y):set(x, y):set(x + 1, y):set(x, y + 1)
  local stem = cv:rect(x, y + 2, x, y + 3)
  local lf = HP.mask()
  if leafSide then lf:set(x + leafSide, y + 3) end
  cv:rim(HP.mask():add(head):add(stem):add(lf), P.ink)
  cv:fillMask(stem, P.moss.shade) cv:fillMask(lf, P.moss.base)
  cv:fillMask(head, col) px(x, y, centre or P.gold.hi)
end

-- corner stake (2 px wide, h tall, foot at y1), returns top y where string ties
function S.stake(x, y1, h)
  h = h or 5
  local cv = S.c
  local m = cv:rect(x, y1 - h + 1, x + 1, y1)
  K.ink(m)
  cv:fillMask(m, P.wood.base)
  S.R(x, y1 - h + 1, x, y1, P.wood.hi)
  S.R(x + 1, y1 - h + 2, x + 1, y1, P.wood.shade)
  px(x + 1, y1 - h + 1, P.wood.hi)       -- cut top
  px(x + 1, y1, P.wood.deep)
  return y1 - h + 2
end
-- string line (1 px, light) with a 1 px darker underside where it crosses soil
function S.string(pts)
  local cv = S.c
  for i = 1, #pts - 1 do cv:fillMask(cv:line({ pts[i], pts[i + 1] }, 1), P.cream) end
end
-- the full staked footprint: corners {bl, br, fl, fr} as {x, footY}; string ties near stake tops
function S.footprint(bx0, bx1, by, fx0, fx1, fy, h)
  h = h or 5
  -- stakes back first, string, then front stakes so the string passes behind them
  local tb = S.stake(bx0, by, h); S.stake(bx1, by, h)
  local tf = fy - h + 2
  S.string({ { bx0 + 1, tb }, { bx1, tb } })
  S.string({ { bx1 + 1, tb }, { fx1 + 1, tf } })
  S.string({ { fx0, tf }, { bx0, tb } })
  S.stake(fx0, fy, h); S.stake(fx1, fy, h)
  S.string({ { fx0 + 2, tf }, { fx1 - 1, tf } })
  -- knots
  px(bx0 + 2, tb, P.cream) px(fx1 - 1, tf + 1, P.cream)
end

function S.leaf(x, y, flip)
  local rows = flip and { "lm.", "mmm", ".ms" } or { ".ml", "mmm", "sm." }
  K.sprite(rows, x, y, { m = P.moss.base, l = P.moss.hi, s = P.moss.shade })
end

function S.saveStrip(out, name, frames, W, H)
  K.strip(out, name .. "-empty", frames, W, H, "empty")
end
return S
