-- flowers/vase: blue-glazed ceramic vase, two layers (back = shadow + inner mouth, front = body).
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
local function sym(left) -- left edge top->bottom, mirrored about x = 49.5
  local pts = {}
  for _, p in ipairs(left) do pts[#pts+1] = p end
  for i = #left, 1, -1 do pts[#pts+1] = { 99 - left[i][1], left[i][2] } end
  return pts
end
local function canvas() return GV.canvas{ w = 100, h = 75, out = 2, mode = "sticker", halo = 0, close = 0, margin = 0 } end

-- cobalt glaze (water family, borrowed for ceramic blue) and a darker lip/foot glaze
local glaze = GV.ramp("#5b95bd", { gloss = "#c8ecdc", dot = "#eaf8e4", rim = "#8fcbd8", shade = "#2f6290", deep = "#2a3c6c", bounce = "#5a86b8" })
local lipR  = GV.ramp("#3f7599", { gloss = "#8fcbd8", dot = "#c8ecdc", rim = "#5b95bd", shade = "#2f5d7e", deep = "#2a3c6c", bounce = "#3f6a9a" })
local LIP  = { 49.5, 23, 15, 4.5 }   -- flared lip ellipse
local HOLE = { 49.5, 22.5, 12, 3 }   -- the opening

------------------------------------------------------------------ back
do
  local c = canvas()
  c:part(c:ellipse(table.unpack(LIP)), lipR, { gloss = false, bounce = false, cres = 3 })
  local hole = c:ellipse(table.unpack(HOLE))
  c:fill(hole, "#2a3c6c")
  hole:each(function(x, y) if y <= 21 then c:px(x, y, "#2f5d7e") end end) -- lit inner back wall
  hole:each(function(x, y) if y == 20 or (y == 21 and not hole:has(x, y-1)) then c:px(x, y, "#3f6a9a") end end)
  c:ground(49.5, 71, 25, 2.5)
  local t = c:save(O .. "aseprite/vase-back.aseprite", O .. "png/vase-back.png")
  print("vase-back: " .. GV.report(t))
end

------------------------------------------------------------------ front
do
  local c = canvas()
  local L = { {39.5, 25} }
  bez(L, {39.5, 25}, {40.5, 31}, {38, 33}, {32, 37}, 6)           -- pinched neck into the shoulder
  bez(L, {32, 37}, {26, 41}, {24.5, 46}, {24.5, 52}, 6)           -- shoulder to belly
  bez(L, {24.5, 52}, {24.5, 61}, {30, 66}, {38, 66}, 8)           -- belly to base
  local body = c:poly(sym(L))
  local foot = c:rrect(38, 64, 61, 70, 2)
  local hole = c:ellipse(table.unpack(HOLE))
  local collar = c:ellipse(table.unpack(LIP)):clip(c:rect(0, 23, 99, 74)):cut(hole)
  collar:add(c:rrect(37, 25, 62, 28, 1))                           -- lip roll
  c:build{
    { "body",   body,   glaze, { gloss = { 29, 40 } } },
    { "foot",   foot,   lipR,  { gloss = false, light = body:copy():add(foot) } },
    { "collar", collar, lipR,  { gloss = false, light = collar:copy():add(c:rect(37, 20, 62, 31)) } },
  }
  -- lip roll catches the light on its top edge
  for x = 37, 47 do if c:get(x, 25) == lipR.base then c:px(x, 25, lipR.rim) end end
  -- bold enamel comma on the lit shoulder, then a long glaze streak down the flank
  c:paint({ ".....gg", "....gg.", "...gg..", "..gg.d.", ".gg....", ".g.....", ".g....." }, 30, 38, { g = glaze.gloss, d = glaze.dot })
  for y = 46, 56 do c:px((y < 53) and 28 or 29, y, glaze.rim) end
  -- painted glaze diamonds on the lower belly, evenly spaced
  for _, dx in ipairs({ 35, 42, 56, 63 }) do
    c:paint({ ".r.", "rrr", ".r." }, dx - 1, 56, { r = (dx < 50) and glaze.rim or "#3f6a9a" })
  end
  c:paint({ ".r.", "rrr", ".r." }, 48, 57, { r = glaze.rim })
  -- belly band: gold thread seam with a button at the front
  local band = {}
  bez(band, {25.5, 46}, {38, 52}, {61, 52}, {73.5, 46}, 40)
  c:seam(band)
  c:button(48, 48)
  -- open mouth: keep the front outline only as a 1 px inner lip line, so the back's opening shows
  c:finish()
  hole:each(function(x, y) if not collar:has(x, y + 1) then c.pix[c:key(x, y)] = nil end end)
  local t = c:save(O .. "aseprite/vase-front.aseprite", O .. "png/vase-front.png")
  print("vase-front: " .. GV.report(t))
end
