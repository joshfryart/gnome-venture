-- bits.lua: season bits, yarn balls (grey + 4 colours), robin frames
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local S = dofile(DIR .. "/sm.lua")
local H, L, part, px = S.H, S.L, S.part, S.px
local R = H.R
local floor, abs = S.floor, S.abs

local function art(name, rows, pal, ink)
  local w, h = #rows[1], #rows
  local c = S.new(w, h)
  for j, row in ipairs(rows) do for i = 1, w do
    local ch = row:sub(i, i)
    if ch ~= '.' then c:put(i - 1, j - 1, pal[ch] or ch, "detail") end
  end end
  if ink then c:outline() end
  c:save(H.OUT, name) print(name, w, h, c:colours())
end
local function artNoInk(name, rows, pal)
  local w, h = #rows[1], #rows
  local c = S.new(w, h)
  for j, row in ipairs(rows) do for i = 1, w do
    local ch = row:sub(i, i)
    if ch ~= '.' then c:put(i - 1, j - 1, pal[ch], "detail") end
  end end
  c:save(H.OUT, name) print(name, w, h, c:colours())
end

-- SEASON BITS ------------------------------------------------------------------------------------------------
local PP = { d = "#b8446e", p = "#e0608c", L = "#ffd0dc", P = "#c4446e", w = "#fff0f4" }
artNoInk("cf-season-petal", { ".dppd.", "dLwppd", "dLppPd", "dpppPd", ".dpPd.", "..dd.." }, PP)
artNoInk("cf-season-petal-b", { "..dpd.", ".dLppd", "dLwppd", "dpppPd", ".dppd.", "..dd.." }, PP)
local FF = { a = "#6a5a9e", d = "#3a5a2a", y = "#b8e040", g = "#f4ff90", m = "#7a9a30", n = "#a8c040" }
artNoInk("cf-season-firefly", { "a...a", ".a.a.", ".ddd.", "dyggd", "dygyd", ".ddd." }, FF)
artNoInk("cf-season-firefly-b", { "a...a", ".a.a.", ".ddd.", "dmnnd", "dmnmd", ".ddd." }, FF)
do   -- leaves: 9x9 with ink
  local function leaf(name, flip, R1)
    local c = S.new(9, 9)
    local p1, p2 = { 2, 6 }, { 6, 2 }
    local pts = flip and { { 6, 6 }, { 2, 2 } } or { p1, p2 }
    local m = H.leaf(pts, 2.4)
    part(c, m, R1, 1, 1)
    L.line({ pts[1], pts[2] }):each(function(x, y) if m:has(x, y) then c:put(x, y, R1.D, "detail") end end)
    local sx = flip and 7 or 1
    c:put(flip and 7 or 1, 7, R1.D, "detail") c:put(flip and 7 or 1, 7, R1.D, "detail")
    c:save(H.OUT, name) print(name, c:colours())
  end
  local O2 = R("#8f3a1f", "#c4532a", "#ee8a34", "#f6a94e", "#ffd27a", "#fff1c8")
  local O3 = R("#7a1f2a", "#b8353a", "#e0523f", "#f07a52", "#ff9d70", "#ffd0a8")
  leaf("cf-season-leaf", false, O2) leaf("cf-season-leaf-b", true, O3)
end
local FL = { w = "#ffffff", c = "#e4f6ff", v = "#c9b2f0", i = "#a8d4ff" }
artNoInk("cf-season-flake", { "c.cc.v", ".cwwc.", "cwwwwi", "cwwwwi", ".cwii.", "v.ii.v" }, FL)
artNoInk("cf-season-flake-small", { ".c.", "cwi", ".v." }, FL)

-- YARN BALLS ------------------------------------------------------------------------------------------------
local YA = R("#3d4a6e", "#6a82a8", "#8aa4c4", "#a8c0d8", "#c8dcec", "#f0f8ff")
local MINT = R("#1f5a4a", "#2f9078", "#4fc9a0", "#7ee0b8", "#a8f0d0", "#e0fff0")
local COLS = { grey = YA, rose = H.PINK, mint = MINT, violet = H.VIOLET, gold = H.GOLD }
for _, nm in ipairs({ "grey", "rose", "mint", "violet", "gold" }) do
  for f = 1, 4 do
    if nm == "grey" or f then
      local c = S.new(16, 16)
      local ramp = COLS[nm]
      local sh = L.ellipse(8, 14, 6, 1.2)
      for x = 3, 13 do c:put(x, 15, "#9a5e2e", "shadow", true) end
      for x = 5, 11 do c:put(x, 15, "#6a3a1e", "shadow", true) end
      S.ball(c, 8, 7, 6.4, ramp, { ph = (f - 1) * 0.85 })
      for _, p in ipairs({ { 3, 13 }, { 2, 14 }, { 1, 14 }, { 1, 13 } }) do c:put(p[1], p[2], ramp.m, "detail") end
      c:put(2, 14, ramp.l, "detail")
      -- ink around the ball + thread (not the shadow row)
      local obj = L.mask() for k in pairs(c.obj.s) do obj.s[k] = true end
      c:outline()
      local name = nm == "grey" and ("cf-yarn-" .. f) or ("cf-yarn-" .. f .. "-" .. nm)
      c:save(H.OUT, name) print(name, c:colours())
    end
  end
end

-- ROBIN: 12x10, perched / wing up / wing down ---------------------------------------------------------------
local BR = H.BROWN
local OR = R("#8f3a1f", "#c4532a", "#ee8a34", "#f6a94e", "#ffd27a", "#fff1c8")
local function robin(name, wing)
  local c = S.new(12, 10)
  local body = L.ellipse(5.6, 5.8, 4.2, 3.1)
  local head = L.ellipse(8, 3.6, 2.6, 2.4)
  local tail = L.poly({ { 2, 4 }, { 0, 8 }, { 3, 8 }, { 4, 6 } })
  if wing == "up" then tail = L.poly({ { 2, 5 }, { 0, 2 }, { 2, 3 }, { 4, 6 } }) end
  part(c, tail, BR, 1, 1)
  local all = body:copy():add(head)
  part(c, all, BR, 2, 1)
  local breast = all:filter(function(x, y) return x >= 7 and y >= 4 or (x >= 6 and y >= 6) end)
  part(c, breast, OR, 1, 1)
  for y = 5, 7 do for x = 8, 9 do if breast:has(x, y) then c:put(x, y, OR.m, "detail") end end end
  local wm
  if wing == "up" then wm = L.poly({ { 3, 5 }, { 1, 1 }, { 5, 3 }, { 7, 6 } })
  elseif wing == "down" then wm = L.poly({ { 3, 6 }, { 6, 6 }, { 7, 9 }, { 2, 9 } })
  else wm = L.poly({ { 3, 5 }, { 7, 5 }, { 8, 7 }, { 4, 8 } }) end
  part(c, wm, BR, 1, 1, { lift = -1 })
  c:put(9, 3, '#', "detail")
  c:put(10, 4, "#f0b030", "detail") c:put(11, 4, "#f0b030", "detail")
  if wing ~= "down" then c:put(11, 5, "#c47a22", "detail") end
  c:outline()
  c:save(H.OUT, name) print(name, c:colours())
end
robin("cf-bird-1", "fold") robin("cf-bird-2", "up") robin("cf-bird-3", "down")
