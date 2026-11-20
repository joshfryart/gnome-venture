local HP = dofile("/home/user/gnome-venture/aseprite-source/v3/lib/hp.lua")
local P = HP.P
local floor, sqrt, sin = math.floor, math.sqrt, math.sin
local out = app.params.out or "./"
local c
local CW, CH = 56, 56
local function newc() c = HP.canvas{ w = CW, h = CH, scale = 1, name = "state" } return c end
local R = function(x0, y0, x1, y1, hex) c:fillMask(c:rect(x0, y0, x1, y1), hex) end
local E = function(cx, cy, rx, ry) return c:ellipse(cx, cy, rx, ry) end
local px = function(x, y, hex) c:px(x, y, hex) end
local DUSKSH = "#5a4660"
local WIN = { hi = P.sky.hi, base = P.sea.hi, shade = P.sea.base, deep = P.sea.shade }
