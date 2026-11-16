-- _patch.lua: shared helper for the cut-b icons. Loads the plain (cut a) game icon and sews a cloth patch on it.
-- A stitched patch, not a gem: flat woven cloth (two close tones, no bevel, no pop), a darker raw edge, cream thread
-- dashes (2 on, 1 off) running round just inside the edge, clipped corners. No highlight, no outline of its own.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local W = dofile(DIR .. "/../../gnome-wear/_gw.lua")
local M = { W = W, HP = W.HP }
M.OUT = app.params.out or (DIR .. "/")
M.GAME = DIR .. "/../../../../game/assets/img/ph/"

function M.start(name, base)
  local c = W.HP.canvas{ w = 64, h = 64, scale = 1, name = name }
  local img = Image{ fromFile = M.GAME .. base .. ".png" }
  for y = 0, 63 do for x = 0, 63 do
    local v = img:getPixel(x, y)
    if app.pixelColor.rgbaA(v) > 0 then
      c:px(x, y, string.format("#%02x%02x%02x", app.pixelColor.rgbaR(v), app.pixelColor.rgbaG(v), app.pixelColor.rgbaB(v)))
    end
  end end
  return c
end

-- patch at (x0,y0), w x h, ramp {edge, base, alt, thread}; tilt: optional row shear so it sits a touch crooked
function M.patch(c, x0, y0, w, h, col)
  local cell = {}
  local function inside(i, j) return i >= 0 and j >= 0 and i < w and j < h end
  local function corner(i, j) return (i == 0 or i == w - 1) and (j == 0 or j == h - 1) end
  for j = 0, h - 1 do for i = 0, w - 1 do
    if not corner(i, j) then
      local edge = (i == 0 or j == 0 or i == w - 1 or j == h - 1)
      cell[i .. "," .. j] = edge and col.edge or (((i + j) % 2 == 0) and col.base or col.alt)
    end
  end end
  -- thread path: the ring one pixel inside the edge, clockwise, corners skipped by the clip
  local path = {}
  for i = 1, w - 2 do path[#path + 1] = { i, 1 } end
  for j = 2, h - 2 do path[#path + 1] = { w - 2, j } end
  for i = w - 3, 1, -1 do path[#path + 1] = { i, h - 2 } end
  for j = h - 3, 2, -1 do path[#path + 1] = { 1, j } end
  for k, p in ipairs(path) do if (k - 1) % 3 ~= 2 then cell[p[1] .. "," .. p[2]] = col.thread end end
  -- a cross stitch in the middle (two thread pixels on a diagonal) so it reads as hand-sewn
  local cx, cy = w // 2, h // 2
  cell[(cx - 1) .. "," .. (cy)] = col.thread
  cell[(cx) .. "," .. (cy - 0)] = col.alt
  cell[(cx) .. "," .. (cy)] = col.thread
  for k, v in pairs(cell) do
    local i, j = k:match("(%d+),(%d+)")
    c:px(x0 + tonumber(i), y0 + tonumber(j), v)
  end
end

function M.save(c, name)
  W.HP.report(c) W.HP.assertClean(c)
  c:save{ aseprite = M.OUT .. name .. ".aseprite", png = M.OUT .. name .. ".png", scale = 1 }
end
return M
