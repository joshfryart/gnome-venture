-- fence READY only: a goat (and a hen) wait at the fence. 72x56, anchor (36,46).
local L = dofile("/tmp/ase/states2/lib_tb.lua")
local P, HP = L.P, L.HP
local out = app.params.out or "/tmp/ase/states2/fence/"
local c
local px, R, E = L.px, L.R, L.E
local lerp = L.lerp
local W, H = 72, 56
local X, Y = 36, 46
local CR = { hi = P.cream, base = lerp(P.cream, P.stone.hi, .45), shade = P.stone.hi, deep = P.stone.base }

local function fenceBase()
  local x, y = X, Y
  -- cast shadow: a band right-under and a wedge to the right of each post
  local sh = HP.mask()
  for j = 1, 2 do for xx = x - 17 + j, x + 21 + j do sh:set(xx, y + j) end end
  for xx = x - 17, x + 17, 11 do for yy = y - 14, y do for k = 1, 3 do sh:set(xx + 3 + k + (y - yy) // 5, yy + 1) end end end
  L.shadow(sh, HP.mask():add(c:rect(x - 16, y + 1, x + 21, y + 1)))
  local rail1 = c:rect(x - 17, y - 12, x + 19, y - 10)
  local rail2 = c:rect(x - 17, y - 5, x + 19, y - 3)
  local posts, pside = HP.mask(), HP.mask()
  for xx = x - 17, x + 17, 11 do posts:add(c:rect(xx, y - 16, xx + 2, y)) pside:add(c:rect(xx + 3, y - 17, xx + 3, y - 1)) end
  L.ink(rail1, rail2, posts, pside)
  for _, ry in ipairs{ y - 12, y - 5 } do
    R(x - 17, ry, x + 19, ry, P.wood.hi) R(x - 17, ry + 1, x + 19, ry + 1, P.wood.base) R(x - 17, ry + 2, x + 19, ry + 2, P.wood.shade)
  end
  for xx = x - 15, x + 15, 5 do L.dk(xx, y - 11, "wood") L.dk(xx + 2, y - 4, "wood") end
  for xx = x - 17, x + 17, 11 do
    R(xx, y - 16, xx + 2, y, P.wood.base) R(xx, y - 16, xx, y, P.wood.hi) R(xx + 3, y - 17, xx + 3, y - 1, P.wood.shade)
    R(xx, y - 16, xx + 3, y - 16, P.wood.hi) px(xx + 3, y - 17, P.wood.base) px(xx + 2, y - 13, P.wood.shade) px(xx + 1, y, P.wood.shade) R(xx, y, xx + 2, y, P.wood.shade)
    px(xx + 1, y - 9, P.wood.shade) px(xx, y - 8, P.wood.shade)
  end
end

local function hen(dy)
  local x, y = X, Y
  local h = E(x - 13, y - 7, 4, 3)
  local comb = HP.mask():set(x - 16, y - 12 + dy):set(x - 15, y - 12 + dy):set(x - 16, y - 11 + dy):set(x - 15, y - 11 + dy)
  local head = c:rect(x - 17, y - 11 + dy, x - 14, y - 9)
  c:rim(h:copy():add(head):add(comb), P.ink)
  L.ball(h, x - 13, y - 7, 4, 3, P.ember)
  c:fillMask(head, P.ember.base) R(x - 17, y - 11 + dy, x - 17, y - 10 + dy, P.ember.hi)
  c:fillMask(comb, P.ember.shade) px(x - 16, y - 12 + dy, P.ember.hi)
  px(x - 16, y - 10 + dy, P.ink)                                   -- eye
  px(x - 18, y - 10 + dy, P.gold.hi) px(x - 18, y - 9 + dy, P.gold.base)   -- beak
  px(x - 10, y - 8, P.ember.shade) px(x - 10, y - 9, P.ember.base)          -- tail tuft
  R(x - 14, y - 4, x - 14, y - 3, P.gold.shade) R(x - 11, y - 4, x - 11, y - 3, P.gold.shade)   -- legs
end

local function goat(b, flick, tail)
  local x, y = X + 2, Y
  local body = c:rect(x - 3, y - 12 + b, x + 5, y - 6 + b)
  local rump = c:rect(x - 4, y - 11 + b, x - 4, y - 8 + b)
  local neck = c:rect(x + 4, y - 15 + b, x + 7, y - 10 + b)
  local head = c:rect(x + 5, y - 17 + b, x + 10, y - 12 + b)
  local snout = c:rect(x + 11, y - 14 + b, x + 11, y - 12 + b)
  local legs = c:rect(x - 3, y - 5 + b, x - 2, y - 1):add(c:rect(x + 3, y - 5 + b, x + 4, y - 1)):add(c:rect(x - 1, y - 5 + b, x - 1, y - 2)):add(c:rect(x + 5, y - 5 + b, x + 5, y - 2))
  local horns = HP.mask():set(x + 6, y - 19 + b):set(x + 6, y - 18 + b):set(x + 5, y - 20 + b):set(x + 9, y - 19 + b):set(x + 10, y - 20 + b)
  local ear = c:rect(x + 3, y - 16 + b + flick, x + 4, y - 15 + b + flick)
  local beard = HP.mask():set(x + 10, y - 11 + b):set(x + 10, y - 10 + b):set(x + 11, y - 11 + b)
  local tl = HP.mask():set(x - 5, y - 12 + b + tail):set(x - 5, y - 13 + b + tail)
  c:rim(body:copy():add(rump):add(neck):add(head):add(snout):add(legs):add(horns):add(ear):add(beard):add(tl), P.ink)
  c:fillMask(legs, CR.shade)
  for _, lx in ipairs{ x - 3, x + 3 } do R(lx, y - 1, lx + 1, y - 1, P.wood.deep) end
  c:fillMask(body, CR.base) c:fillMask(rump, CR.base) c:fillMask(neck, CR.base) c:fillMask(head, CR.base) c:fillMask(snout, CR.shade)
  R(x - 3, y - 12 + b, x + 4, y - 12 + b, P.cream) R(x - 3, y - 12 + b, x - 3, y - 7 + b, P.cream)      -- lit top and left
  R(x - 2, y - 6 + b, x + 5, y - 6 + b, CR.shade) R(x + 5, y - 10 + b, x + 5, y - 6 + b, CR.shade) px(x + 4, y - 6 + b, CR.deep)
  R(x + 2, y - 9 + b, x + 3, y - 8 + b, CR.shade)                                       -- belly fold / shoulder
  R(x + 5, y - 17 + b, x + 9, y - 17 + b, P.cream) R(x + 5, y - 17 + b, x + 5, y - 13 + b, P.cream)
  R(x + 7, y - 12 + b, x + 10, y - 12 + b, CR.shade)
  c:fillMask(horns, P.gold.shade) px(x + 6, y - 19 + b, P.gold.base) px(x + 5, y - 20 + b, P.gold.base)
  c:fillMask(ear, CR.shade) px(x + 3, y - 16 + b + flick, P.petal.base)
  c:fillMask(beard, P.cream) px(x + 10, y - 10 + b, CR.shade)
  c:fillMask(tl, P.cream)
  px(x + 9, y - 15 + b, P.ink) px(x + 9, y - 14 + b, P.ink)                       -- eye
  px(x + 11, y - 13 + b, P.ink)                                                   -- nostril
  px(x + 8, y - 14 + b, P.petal.hi)                                               -- cheek
end

local BOBG = { 0, -1, 0, -1 }
local FLICK = { 0, 0, 1, 0 }
local TAIL = { 0, 1, 0, 1 }
local HEN = { 0, 0, 1, 0 }
local BADGE = { 0, -1, 0, 1 }
local SPARK = { { 52, 25 }, { 60, 30 }, { 54, 36 }, { 48, 24 } }

local frames = {}
for k = 1, 4 do
  c = L.new(W, H)
  fenceBase()
  hen(HEN[k])
  goat(BOBG[k], FLICK[k], TAIL[k])
  c:sparkle(SPARK[k][1], SPARK[k][2])
  L.badge(BADGE[k])
  frames[k] = c
end
L.saveAll("fence", out, W, H, nil, nil, nil, nil, frames)
