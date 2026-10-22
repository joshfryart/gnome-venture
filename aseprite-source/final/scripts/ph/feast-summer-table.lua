local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local function star(cx, cy, ro, ri)
  local pts = {}
  for i = 0, 9 do
    local a = math.rad(-90 + i * 36)
    local r = (i % 2 == 0) and ro or ri
    pts[#pts + 1] = { cx + math.cos(a) * r, cy + math.sin(a) * r }
  end
  return c:poly(pts)
end

local rim   = c:ellipse(31.5, 45, 21, 8)
local plate = c:ellipse(31.5, 43.5, 17, 5.5)
-- tented dome mound
local mound = c:ellipse(31.5, 42, 14, 16):cut(c:rect(0, 43, 63, 63))
mound:clip(c:poly({ { 31.5, 22 }, { 49, 46 }, { 14, 46 } }):grow(3))
local tomato = c:ellipse(24, 37, 4, 4)
local apple  = c:ellipse(39, 35, 4.5, 4.5)
local baub   = c:ellipse(31.5, 29.5, 3, 3)
local st     = star(31.5, 16.5, 7, 3.2)

local p = c:build{
  { "rim", rim, "#d6c9b6" },
  { "plate", plate, "#f4f0e0" },
  { "mound", mound, "#f08a24" },
  { "tomato", tomato, "#e0501f", { gloss = false } },
  { "apple", apple, "#7ab55c", { gloss = false } },
  { "baub", baub, "#e8a317", { gloss = false } },
  { "star", st, "gold" },
}
c:px(22, 35, "#ffc27a"); c:px(37, 33, "#c8d77a"); c:px(30, 28, "#fff1c8")
c:fill(c:rect(39, 29, 40, 30), GV.R.wood.deep)  -- apple stalk
-- seam on the plate rim, only where the plate is visible
local hidden = p.mound.m:copy():add(p.tomato.m):add(p.apple.m)
local run = {}
local function flush() if #run >= 2 then c:seam(run) end; run = {} end
for i = 0, 72 do
  local a = math.rad(i * 5)
  local x = math.floor(31.5 + math.cos(a) * 15 + 0.5)
  local y = math.floor(43.5 + math.sin(a) * 4 + 0.5)
  if hidden:grow(1):has(x, y) then flush() else run[#run + 1] = { x, y } end
end
flush()

local t = c:save(D .. "img-redraw-full/aseprite/ph/feast-summer-table.aseprite", D .. "img-redraw-full/png/ph/feast-summer-table.png")
print(GV.report(t))
