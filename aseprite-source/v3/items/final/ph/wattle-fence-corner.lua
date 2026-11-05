-- wattle-fence-corner (lean P1b_O18)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, max, min, sin, cos, pi, sqrt = math.floor, math.abs, math.max, math.min, math.sin, math.cos, math.pi, math.sqrt
local function cl(i, n) return max(1, min(n, i)) end
local NAME = "wattle-fence-corner"
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local ROD = { "#6a5638", "#8f7650", "#b89c68", "#d9c28c", "#efdfa8", "#fcf2cc" }
local STK = { "#3f2f2c", "#5c4338", "#7e5e48", "#a07f5e", "#c3a47c", "#e2c9a0" }
local RIB = { "#5e1226", "#9c1f36", "#d63a48", "#ff7a80" }
local tR, tS, tX = { r = { name = "rod" } }, { r = { name = "stake" } }, { r = { name = "charm" } }
local PER, SW, RH = 8, 3, 4
local function rodc(yy, sh, u, v)
  local b = (yy == 0 and 5) or (yy == 1 and 4) or (yy == 2 and 3) or 2
  b = b + sh
  local h = X.hash(u, v, 3)
  if h > 0.9 then b = b - 1 elseif h < 0.05 and yy < 2 then b = b + 1 end
  return ROD[cl(b, 6)]
end
-- weave cell colour at panel coords (u>=0, v>=0)
local function weave(u, v, sh, H)
  local k, r = floor(u / PER), floor(v / RH)
  local uu, yy = u - k * PER, v - r * RH
  local over = (k + r) % 2 == 0
  local low = (v > H - 5) and -1 or 0
  if uu < SW and over then
    local b = (uu == 0 and 5) or (uu == 1 and 4) or 3
    if yy == 0 then b = b - 2 elseif yy == 3 then b = b - 1 end
    return STK[cl(b + sh + low, 6)], tS
  end
  local sh2 = sh + low
  if (uu == 7 and ((k + 1 + r) % 2 == 0)) or (uu == SW and over) then sh2 = sh2 - 1 end
  if uu < SW and not over and yy == 0 then sh2 = sh2 + 1 end
  return rodc(yy, sh2, u, v), tR
end
local function stakeTop(k, uu, v, sh)
  local th = 3 + floor(X.hash(k, 0, 9) * 3)
  if uu >= SW or v < -th or (v == -th and uu ~= 1) then return nil end
  local b = (uu == 0 and 5) or (uu == 1 and 4) or 3
  if v == -th then b = 6 end
  return STK[cl(b + sh, 6)]
end
local function post(x0, ytop, ybot, ramp)
  local prof = { 5, 6, 5, 4, 3, 2, 2 }
  for y = ytop, ybot do for i = 0, 6 do
    local x = x0 + i
    local skip = (y == ytop and (i < 2 or i > 4)) or (y == ytop + 1 and (i < 1 or i > 5))
    if not skip then
      local b = prof[i + 1]
      if y <= ytop + 2 then b = b + 1 end
      local h = X.hash(x, y, 7)
      if h > 0.9 then b = b - 1 elseif (y + i) % 5 == 0 and h > 0.5 then b = b - 1 end
      c:put(x, y, ramp[cl(b, 6)], tS)
    end
  end end
end
local function twine(x0, x1, y)
  for x = x0, x1 do for d = 0, 1 do c:put(x, y + d, ((x + d) % 2 == 0) and "#e8d8a8" or "#9a8458", tX) end end
end
local function bow(x, y, tails)
  c:fillMask(c:rect(x - 1, y - 1, x + 1, y + 1), RIB[3]) c:px(x - 1, y - 1, RIB[4]) c:px(x + 1, y + 1, RIB[2])
  c:px(x - 3, y - 1, RIB[3]) c:px(x - 3, y, RIB[2]) c:px(x - 2, y - 2, RIB[4]) c:px(x + 3, y - 1, RIB[3]) c:px(x + 3, y, RIB[2]) c:px(x + 2, y - 2, RIB[4])
  for _, tl in ipairs(tails) do
    local tx, len = tl[1], tl[2]
    for d = 1, len do
      c:put(x + tx, y + 1 + d, RIB[(d % 3 == 0) and 2 or 3], tX) c:put(x + tx + 1, y + 1 + d, RIB[2], tX)
    end
    c:put(x + tx, y + 2 + len, RIB[2], tX) c:put(x + tx + 1, y + 1 + len, RIB[1], tX)
  end
end
c:groundShadow(32, 52, 27, 4)
local Y0, H = 22, 28
local function panel(xa, xb, sh, offf, ux)
  for x = xa, xb do
    local off = offf(x)
    local u = ux(x)
    local k, uu = floor(u / PER), u % PER
    for y = Y0 + off - 6, Y0 + off + H - 1 do
      local v = y - Y0 - off
      if v >= 0 then local col, tk = weave(u, v, sh, H) c:put(x, y, col, tk)
      else local col = stakeTop(k, uu, v, sh) if col then c:put(x, y, col, tS) end end
    end
  end
end
panel(5, 28, 0, function(x) return -floor((28 - x) * 0.22 + 0.5) end, function(x) return x - 5 end)
panel(36, 59, -1, function(x) return -floor((x - 36) * 0.22 + 0.5) end, function(x) return x - 36 end)
post(29, 14, 52, STK)
twine(29, 35, 35)
twine(29, 35, 44)
bow(32, 25, { { -2, 6 }, { 1, 8 } })
-- charms: blue bead + feather on left panel, amber charm on right panel
for d = 0, 4 do c:px(13, 22 + d, "#e8d8a8") end
c:fillMask(c:rect(12, 27, 14, 29), "#3a78d8") c:px(12, 27, "#b8e4ff") c:px(14, 29, "#1c3a8a")
for d = 0, 5 do c:px(21, 26 + d, "#e8d8a8") end
for d = 0, 5 do c:px(21, 32 + d, d < 4 and "#7ad0c8" or "#3a8f8c") c:px(22, 32 + d, d % 2 == 0 and "#b8f0e6" or "#4aa89c") end
for d = 0, 4 do c:px(50, 20 + d, "#e8d8a8") end
c:fillMask(c:rect(49, 25, 51, 27), "#e8a830") c:px(49, 25, "#fff0a0") c:px(51, 27, "#8a4a14") c:px(50, 26, "#c87820")
G.save(c, NAME)
