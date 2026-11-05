-- wattle-fence-end (lean P1b_O18)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, max, min, sin, cos, pi, sqrt = math.floor, math.abs, math.max, math.min, math.sin, math.cos, math.pi, math.sqrt
local function cl(i, n) return max(1, min(n, i)) end
local NAME = "wattle-fence-end"
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
c:groundShadow(32, 52, 26, 4)
local X0, Y0, H, W = 14, 26, 24, 35
local ext = { 5, 2, 4, 1, 5, 3 }
for x = X0 - 6, X0 + W do
  local u = x - X0
  local k, uu = floor(u / PER), u % PER
  for y = Y0 - 6, Y0 + H - 1 do
    local v = y - Y0
    if v >= 0 then
      if u >= 0 then local col, tk = weave(u, v, 0, H) c:put(x, y, col, tk)
      else
        local r, yy = floor(v / RH), v % RH
        local e = ext[r + 1]
        if -u <= e then
          local col = rodc(yy, 0, u, v)
          if -u == e and yy > 0 and yy < 3 then col = ROD[6] elseif -u == e then col = ROD[4] end
          c:put(x, y, col, tR)
        end
      end
    elseif u >= 0 then
      local col = stakeTop(k, uu, v, 0) if col then c:put(x, y, col, tS) end
    end
  end
end
post(49, 12, 52, STK)
c:fillMask(c:ellipse(52, 10, 3, 2), STK[5]) c:px(51, 9, STK[6]) c:px(54, 11, STK[3]) c:px(53, 12, STK[2])
twine(49, 55, 38)
twine(49, 55, 46)
bow(52, 25, { { -2, 7 }, { 1, 9 } })
-- charm cluster hung from the post: hoop + feather + bead
for d = 0, 3 do c:px(47, 28 + d, "#e8d8a8") end
local ring = c:ellipse(47, 35, 3, 3):cut(c:ellipse(47, 35, 1, 1))
ring:each(function(x, y) c:put(x, y, (x + y < 82) and "#ffd860" or "#a86a1c", tX) end)
c:px(45, 33, "#fff6c0")
for d = 0, 7 do c:px(47, 39 + d, d < 5 and "#7ad0c8" or "#3a8f8c") c:px(48, 39 + d, d % 2 == 0 and "#b8f0e6" or "#4aa89c") c:px(46, 40 + d, d % 3 == 0 and "#3a8f8c" or "#b8f0e6") end
c:fillMask(c:rect(44, 30, 45, 31), "#3a78d8") c:px(44, 30, "#b8e4ff")
-- grass tufts
for _, g in ipairs{ {16, 50}, {40, 51} } do
  c:px(g[1], g[2], "#2f7a34") c:px(g[1] + 1, g[2] - 1, "#52b040") c:px(g[1] + 1, g[2], "#2f7a34") c:px(g[1] - 1, g[2] - 1, "#86d850") c:px(g[1] + 2, g[2] - 2, "#86d850")
end
G.save(c, NAME)
