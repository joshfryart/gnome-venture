-- flowers/basket: wicker straw basket, two layers. Back = shadow + wrapped handle + dark inside of the rim;
-- front = woven body (over-under basket weave) and a braided rim, handle lugs pinned with gold buttons.
-- Grid 100x75 written at 2x (200x150). SVG (X,Y) -> grid (X/2, (Y+30)/2); mouth centre (49.5, 23).
local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/flowers-pixel/"

local function bez(out, p0, p1, p2, p3, n)
  for i = 1, n do
    local t = i / n; local u = 1 - t
    out[#out+1] = { u^3*p0[1] + 3*u*u*t*p1[1] + 3*u*t*t*p2[1] + t^3*p3[1],
                    u^3*p0[2] + 3*u*u*t*p1[2] + 3*u*t*t*p2[2] + t^3*p3[2] }
  end
  return out
end
local function sym(left)
  local pts = {}
  for _, p in ipairs(left) do pts[#pts+1] = p end
  for i = #left, 1, -1 do pts[#pts+1] = { 99 - left[i][1], left[i][2] } end
  return pts
end
local function canvas() return GV.canvas{ w = 100, h = 75, out = 2, mode = "sticker", halo = 0, close = 0, margin = 0 } end

-- straw (soil family #c9a96e/#9a6b3f, borrowed for wicker) : body, rim braid and the darker handle cane
local straw = GV.ramp("#c9954f", { gloss = "#ffe2a8", dot = "#fff4d8", rim = "#e1b373", shade = "#a8582f", deep = "#5e2f1e", bounce = "#b0623a" })
local braid = GV.ramp("#d9a660", { gloss = "#ffe2a8", dot = "#fff4d8", rim = "#ecc58a", shade = "#8f6232", deep = "#5e2f1e", bounce = "#a8582f" })
local cane  = GV.ramp("#b07a45", { gloss = "#ecc58a", rim = "#d9a660", shade = "#8a4f2a", deep = "#5e2f1e", bounce = "#a8582f" })
local LADDER = { "#ffe2a8", "#e1b373", "#c9954f", "#a8582f", "#8a4f2a", "#5e2f1e" } -- light -> dark
local IDX = {}; for i, v in ipairs(LADDER) do IDX[v] = i end
IDX["#b0623a"] = 4
local function step(c, x, y, d) -- move a pixel d steps along the straw ladder
  local v = c:get(x, y); local i = v and IDX[v]
  if i then c:px(x, y, LADDER[math.max(1, math.min(#LADDER, i + d))]) end
end
local RIM  = { 49.5, 23, 31, 5 }
local HOLE = { 49.5, 22.5, 27.5, 3.5 }

------------------------------------------------------------------ back
do
  local c = canvas()
  -- the handle: one wrapped cane arching behind the flowers
  local arc = {}
  bez(arc, {22, 31}, {19, 1}, {80, 1}, {77, 31}, 60)
  local handle = c:line(arc, 4)
  c:part(handle, cane, { gloss = false, bounce = false, cres = 2, deep = 0 })
  -- wrap: a diagonal dark binding every 5 px along the cane
  for i = 1, #arc, 1 do
    local p = arc[i]
    if i % 5 == 0 then
      local x, y = math.floor(p[1] + 0.5), math.floor(p[2] + 0.5)
      for d = -1, 2 do if handle:has(x + d, y - d + 1) then c:px(x + d, y - d + 1, cane.shade) end end
    end
  end
  for i = 3, #arc - 2 do -- lit top edge of the cane
    local x, y = math.floor(arc[i][1] + 0.5), math.floor(arc[i][2] + 0.5)
    if handle:has(x, y - 1) and not handle:has(x, y - 2) and c:get(x, y - 1) ~= cane.shade then c:px(x, y - 1, cane.rim) end
  end
  -- far rim and the dark inside of the basket
  c:part(c:ellipse(table.unpack(RIM)), braid, { gloss = false, bounce = false, cres = 3 })
  local hole = c:ellipse(table.unpack(HOLE))
  c:fill(hole, "#5e2f1e")
  hole:each(function(x, y)
    if not hole:has(x, y - 1) then c:px(x, y, "#8a4f2a")                 -- lit lip of the far wall
    elseif (x % 6 == 0) and y < 24 then c:px(x, y, "#4e2a16") end         -- inner stakes
  end)
  for x = 26, 74 do if (x + 23) % 4 == 0 then c:px(x, 20, braid.shade) end end -- braid twist on the far rim
  c:ground(49.5, 71, 32, 2.5)
  local t = c:save(O .. "aseprite/basket-back.aseprite", O .. "png/basket-back.png")
  print("basket-back: " .. GV.report(t))
end

------------------------------------------------------------------ front
do
  local c = canvas()
  local L = { {19.5, 26} }
  L[#L+1] = {25.5, 64}
  bez(L, {25.5, 64}, {26.5, 69}, {29.5, 71}, {34.5, 71}, 6)
  local body = c:poly(sym(L))
  local hole = c:ellipse(table.unpack(HOLE))
  local rim = c:ellipse(table.unpack(RIM)):clip(c:rect(0, 22, 99, 74)):cut(hole)
  rim:add(c:rrect(18, 24, 81, 28, 2))
  rim:cut(hole)
  body:cut(rim)
  c:build{
    { "body", body, straw, { gloss = false, light = body:copy():add(rim) } },
    { "rim",  rim,  braid, { gloss = false, contact = true } },
  }
  -- over-under weave: weaver rows 4 px tall that follow the basket's curve, stakes every 6 px
  local function bow(x) local t = (x - 49.5) / 30 return math.floor(2.5 * (1 - t * t) + 0.5) end
  body:each(function(x, y)
    local v = y - 29 - bow(x)
    if v < 0 then return end
    local row, ry = v // 4, v % 4
    local shift = (row % 2) * 3
    local col, cx = (x + shift) // 6, (x + shift) % 6
    local over = (row + col) % 2 == 0
    if ry == 3 then step(c, x, y, 2)                    -- gap between weaver rows
    elseif not over then
      if cx == 0 or cx == 5 then step(c, x, y, 2) else step(c, x, y, 1) end  -- weaver dips under a stake
    elseif ry == 0 and cx > 0 and cx < 5 then step(c, x, y, -1) end          -- lit top of the over strand
  end)
  -- braided rim: twist marks slanting with the light
  rim:each(function(x, y)
    if (x + y) % 4 == 0 and rim:has(x, y - 1) and rim:has(x, y + 1) then c:px(x, y, braid.shade) end
    if (x + y) % 4 == 1 and not rim:has(x, y - 1) and x < 60 then c:px(x, y, braid.rim) end
  end)
  -- enamel gloss on the rim's lit end and a soft sheen down the lit flank
  c:paint({ ".gg", "gd." }, 23, 25, { g = braid.gloss, d = braid.dot })
  for y = 33, 52 do if (y % 4) ~= 0 then c:px(24 + (y - 33) // 10, y, "#e1b373") end end
  -- handle lugs pinned to the rim with gold buttons (natural join)
  c:button(23, 24); c:button(73, 24)
  -- open mouth: keep a 1 px inner lip line only
  c:finish()
  hole:each(function(x, y) if not rim:has(x, y + 1) then c.pix[c:key(x, y)] = nil end end)
  local t = c:save(O .. "aseprite/basket-front.aseprite", O .. "png/basket-front.png")
  print("basket-front: " .. GV.report(t))
end
