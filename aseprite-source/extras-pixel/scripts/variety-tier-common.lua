-- variety-tier-common.lua : shared helpers for the stoptiers art (market / mill / inn, tiers 1-4).
-- Each variety-tier-<kind>.lua dofile()s this. Params: --script-param root=<repo> out=<dir> only=<tier>
local P = app.params
local M = {}
M.root = P.root or "/home/user/gnome-venture"
M.out = P.out or (M.root .. "/aseprite-source/extras-pixel/aseprite")
M.png = P.pngdir or (M.out .. "/png")
M.only = tonumber(P.only or "0")
M.GV = dofile(M.root .. "/aseprite-source/gvlib/gvlib.lua")
local GV = M.GV

-- 96x96 icon canvas (drawn at 96 directly; pens kept at icon weight)
function M.canvas() return GV.canvas{ w = 96, h = 96, mode = "icon", cres = 6, deep = 2, ol = 2, olx = 1 } end

local keys = { "gloss", "dot", "rim", "base", "shade", "deep", "bounce" }
-- repaint a masked area from one ramp's colours to another's (stripes without new parts)
function M.recolor(c, mask, from, to)
  local f, t = GV.ramp(from), GV.ramp(to)
  local map = {}
  for _, k in ipairs(keys) do map[f[k]] = t[k] end
  mask:each(function(x, y) local v = c:get(x, y); if v and map[v] then c:px(x, y, map[v]) end end)
end

-- vertical stripes: every other stripe (odd index) of width w starting at x0 recoloured from -> to
function M.stripes(c, mask, x0, w, from, to)
  local x1 = select(3, mask:bbox())
  local i = 0
  local x = x0
  while x <= x1 do
    if i % 2 == 1 then M.recolor(c, mask:copy():clip(c:rect(x, -50, x + w - 1, 200)), from, to) end
    x = x + w; i = i + 1
  end
end

-- plain filled rectangle in a hex colour, no shading (small details: doors, windows)
function M.box(c, x0, y0, x1, y1, hex) for y = y0, y1 do for x = x0, x1 do c:px(x, y, hex) end end end

-- window: dark umber frame, water-blue glass with a light cross bar and a glint
function M.window(c, x, y, w, h)
  M.box(c, x, y, x + w - 1, y + h - 1, "#5e2f1e")
  M.box(c, x + 1, y + 1, x + w - 2, y + h - 2, "#3f8fb0")
  M.box(c, x + 1, y + 1, x + 2, y + 2, "#c8ecdc")
  for yy = y + 1, y + h - 2 do c:px(x + w // 2, yy, "#5e2f1e") end
  for xx = x + 1, x + w - 2 do c:px(xx, y + h // 2, "#5e2f1e") end
end

-- warm lit window (inn): gold glass
function M.litwindow(c, x, y, w, h)
  M.box(c, x, y, x + w - 1, y + h - 1, "#5e2f1e")
  M.box(c, x + 1, y + 1, x + w - 2, y + h - 2, "#f5cf6a")
  M.box(c, x + 1, y + h - 3, x + w - 2, y + h - 2, "#e8a317")
  M.box(c, x + 1, y + 1, x + 2, y + 1, "#fff1c8")
  for yy = y + 1, y + h - 2 do c:px(x + w // 2, yy, "#8a4f2a") end
end

-- roof tile courses: a darker line every `step` rows inside mask (hard pixel shingles)
function M.courses(c, mask, step, hex, y0)
  mask:each(function(x, y)
    if (y - y0) % step == 0 and c:get(x, y) then
      if not mask:has(x - 1, y) then return end
      c:px(x, y, hex)
    end
  end)
end

-- save one tier: png + aseprite into out dir
function M.save(c, kind, tier)
  local t = c:save(M.out .. "/variety-tier-" .. kind .. "-" .. tier .. ".aseprite", M.png .. "/" .. kind .. "-" .. tier .. ".png")
  print(kind .. "-" .. tier .. " " .. GV.report(t))
  return t
end

function M.want(t) return M.only == 0 or M.only == t end
return M
