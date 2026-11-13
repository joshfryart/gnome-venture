-- badges.lua : badge-<size>-<lock|star|flip|eye|land>   (strip 11x11, hand 18x18)
local D = debug.getinfo(1, "S").source:match("@(.*/)")
local L = dofile(D .. "lib47.lua")
local B = {}
local BG = { lock = 0x5b4128, star = 0x5b4128, flip = 0x3f6f8f, eye = 0xe0574a, land = 0x9aa6b5 }
local C, K, Y, E = L.CREAM, L.INK, L.GOLD, 0x2a1a10

local function plate(n, bg)
  local p = L.cv(n, n)
  p:rect(0, 0, n - 1, n - 1, K); p:rect(1, 1, n - 2, n - 2, bg)
  p:set(0, 0, nil); p:set(n - 1, 0, nil); p:set(0, n - 1, nil); p:set(n - 1, n - 1, nil)
  p:set(1, 1, K); p:set(n - 2, 1, K); p:set(1, n - 2, K); p:set(n - 2, n - 2, K)
  return p
end

local STRIP = {
  lock = { "bbbbbbbbb", "bbbcccbbb", "bbcbbbcbb", "bbcbbbcbb", "bcccccccb", "bcccKcccb", "bcccKcccb", "bcccccccb", "bbbbbbbbb" },
  star = { "bbbbybbbb", "bbbyyybbb", "yyyyyyyyy", "byyyyyyyb", "bbyyyyybb", "bbyyyyybb", "byyyyyyyb", "byyybyyyb", "byybbbyyb" },
  flip = { "bbbbbbbbb", "bbbbbcbbb", "bcccccccb", "bbbbbcbbb", "bbbbbbbbb", "bbbcbbbbb", "bbcccccccb", "bbbcbbbbb", "bbbbbbbbb" },
  land = { "bbbbbbbbb", "bbbbKbbbb", "bbbKKKbbb", "bbKKKKKbb", "bKKKKKKKb", "KKKKKKKKK", "bbbbbbbbb", "bbbbbbbbb", "bbbbbbbbb" },
}
STRIP.flip = { "bbbbbbbbb", "bbbbbcbbb", "bcccccccb", "bbbbbcbbb", "bbbbbbbbb", "bbbcbbbbb", "bbcccccccb", "bbbcbbbbb", "bbbbbbbbb" }
for k, r in pairs(STRIP.flip) do STRIP.flip[k] = r:sub(1, 9) end

local EYE = { ".ccc.", "cckkc", "ckkkc", "ckkkc", ".ccc." }

local function strip(name)
  local p = plate(11, BG[name])
  local leg = { c = C, K = K, y = Y }
  if name == "eye" then
    p:ascii(EYE, 3, 3, { c = C, k = E })
  else
    p:ascii(STRIP[name], 1, 1, leg)
  end
  return p
end

local function hand(name)
  local n = 18
  local p = plate(n, BG[name])
  local g = L.cv(n, n)
  if name == "lock" then
    g:disc(9, 6.6, 5.2, C); g:disc(9, 6.6, 2.8, BG.lock); g:rect(3, 9, 14, 9, nil)
    g:rect(3, 8, 5, 10, nil)
    g:rect(4, 9, 13, 15, C); g:rect(8, 11, 9, 13, K); g:rect(8, 14, 9, 14, K)
    g:rect(4, 15, 13, 15, L.CREAMSH)
    for y = 0, n - 1 do for x = 0, n - 1 do if g:get(x, y) == nil and ((x - 9) ^ 2 + (y - 6.6) ^ 2) < 2.8 ^ 2 then g:set(x, y, BG.lock) end end end
  elseif name == "star" then
    local pts, cx, cy = {}, 9, 9.6
    for i = 0, 9 do local a = -math.pi / 2 + i * math.pi / 5; local r = (i % 2 == 0) and 7.4 or 3.1; pts[#pts + 1] = { cx + r * math.cos(a), cy + r * math.sin(a) } end
    g:poly(pts, Y)
    g:disc(cx - 1.2, cy - 1.0, 1.2, 0xfff1c8)
  elseif name == "flip" then
    g:rect(3, 4, 11, 5, C); g:poly({ { 10, 2 }, { 15, 5 }, { 10, 8 } }, C)
    g:rect(6, 12, 14, 13, C); g:poly({ { 7, 10 }, { 2, 13 }, { 7, 16 } }, C)
  elseif name == "eye" then
    for j, r in ipairs(EYE) do for i = 1, #r do
      local ch = r:sub(i, i)
      if ch ~= "." then g:rect(4 + (i - 1) * 2, 4 + (j - 1) * 2, 4 + (i - 1) * 2 + 1, 4 + (j - 1) * 2 + 1, ch == "c" and C or E) end
    end end
    g:rect(6, 6, 7, 7, C)  -- the 1 px glint scaled with the eye
  else
    g:poly({ { 1, 15 }, { 7, 5 }, { 10, 10 }, { 13, 4 }, { 17, 15 } }, K)
    g:poly({ { 12, 7 }, { 13, 4 }, { 14, 7 } }, C)
    g:disc(4.5, 4, 1.8, C)
  end
  p:blit(g, 0, 0)
  return p
end

function B.build(c, name)
  local p = (c.name == "strip") and strip(name) or hand(name)
  L.save(D .. "../" .. c.name .. "/badge-" .. c.name .. "-" .. name, p.w, p.h, { { name = "plate+glyph", cv = p } })
end
return B
