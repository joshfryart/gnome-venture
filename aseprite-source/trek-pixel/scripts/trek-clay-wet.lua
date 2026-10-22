-- trek-clay-wet: glossy orange clay, map-key colon (two stacked dots) and two slumped wavy bands (family 3)
local ROOT = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(ROOT .. "gvlib/gvlib.lua")
local OUT = ROOT .. "trek-pixel/"
local NAME = "trek-clay-wet"

local cl = { gloss = "#c0662c", rim = "#a85a28", base = "#944c1f", shade = "#6a3820" }
local soil300, soil900 = "#c9a96e", "#3d2a1c"
local glint = "#fff3c8" -- cr_gloss: the dot glint must be lighter than the cream dot

local c = GV.canvas{ w = 42, h = 42, mode = "scene" }
c:fill(c:rect(0, 0, 41, 41), cl.base)

-- Sheen pad x6..35, y6..35, corners cut 4 px, flat cl_rim, no outline
local pad = c:rect(6, 6, 35, 35)
pad:each(function(x, y)
  local dx = math.min(x - 6, 35 - x)
  local dy = math.min(y - 6, 35 - y)
  if dx + dy < 4 then pad:del(x, y) end
end)
c:fill(pad, cl.rim)

-- Slump bands: stepped wave, amplitude 2, period 8; 2 px cl_gloss + 1 px cl_shade under
local WAVE = { 0, 0, 0, 1, 2, 2, 2, 1 }
local function band(y0, phase)
  for x = 6, 35 do
    local o = WAVE[((x - 6 + phase) % 8) + 1]
    c:px(x, y0 + o, cl.gloss); c:px(x, y0 + o + 1, cl.gloss)
    c:px(x, y0 + o + 2, cl.shade)
  end
end
band(9, 0)   -- band A around y=10
band(30, 4)  -- band B around y=32, phase shifted 4 px

-- Gloss comma on the sheen
for x = 9, 11 do c:px(x, 17, cl.gloss) end
c:px(30, 22, cl.gloss)

-- Colon (map key): two 7x7 round dots, soil300 body, soil900 lower-right, glint upper-left
local function dot(x0, y0)
  local rows = { "..ooo..", ".ooooo.", "ooooooo", "ooooooo", "ooooooo", ".ooooo.", "..ooo.." }
  local m = c:ascii(rows, x0, y0)
  c:fill(m, soil300)
  m:each(function(x, y)
    if (not m:has(x + 1, y) or not m:has(x, y + 1)) and (x - x0) + (y - y0) >= 7 then c:px(x, y, soil900) end
  end)
  c:px(x0 + 2, y0 + 1, glint)
end
dot(18, 12)
dot(18, 24)

local t = c:save(OUT .. "aseprite/" .. NAME .. ".aseprite", OUT .. "png/" .. NAME .. ".png")
print(NAME .. ": " .. GV.report(t))
