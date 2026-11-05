-- opening-day-bunting (lean P1b_O5)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c
local function gline(cc, pts, col, w) cc:fillMask(cc:line(pts, w or 1), col) end
local function solid(m, rp, R, o) local n = X.pillow(m, R) local _, v = G.toneN(c, m, n, rp, o) return n, v end
local function cylN(m, cx, cy, r, horiz) local n = {} m:each(function(x, y) local t = horiz and (y - cy) / r or (x - cx) / r t = max(-0.97, min(0.97, t)) if horiz then n[K(x, y)] = { -0.35, t, sqrt(1 - t*t) } else n[K(x, y)] = { t, -0.35, sqrt(1 - t*t) } end end) return n end
local NAME = "nav-tasks"
c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local WOOD = { "#4a2a1c", "#6e4126", "#96602f", "#bc8240", "#dba856", "#f2cf80" }
local NAME = "opening-day-bunting"
c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local ROPE = { "#3a2418", "#6e4a2c", "#a0763e", "#d2a860" }
local FL = {
  { "#5a0f22", "#9a1c34", "#d2344a", "#f06a68", "#ffa088", "#ffd0b8" },
  { "#6a4408", "#b07a10", "#e8b020", "#ffd848", "#fff08a", "#fffcc8" },
  { "#0e3a48", "#1a6a80", "#2aa0b4", "#5ccad0", "#9aeee4", "#d0fff6" },
  { "#4a1a5e", "#7a2c92", "#a84cc0", "#cc7ede", "#e8aaf2", "#f8dcff" },
  { "#14405a", "#2468a0", "#3c96d8", "#6cc0f0", "#a4e0fc", "#dcf6ff" },
}
local function sag(x) local t = (x - 6) / 52 return 12 + 14 * 4 * t * (1 - t) end
c:groundShadow(32, 56, 16, 2)
-- flags first (behind rope)
local xs = { 10, 20, 30, 40, 50 }
for i, x in ipairs(xs) do
  local y0 = sag(x)
  local yl, yr = floor(sag(x - 4) + 0.5), floor(sag(x + 4) + 0.5)
  local tip = floor(y0 + 17 + (i % 2) * 3)
  local m = c:poly{ {x - 4, yl + 1}, {x + 4, yr + 1}, {x, tip} }
  local n = X.pillow(m, 7)
  G.toneN(c, m, n, FL[i], { amb = 0.12 })
  -- stripe: contrasting band near the top
  m:each(function(px, py) if py >= yl + 4 and py <= yl + 5 and (i % 2 == 1) then c:px(px, py, FL[i][6]) end end)
  -- dot / star motif
  c:px(x, yl + 9, FL[i][6]) c:px(x - 1, yl + 8, FL[i][5]) c:px(x, yl + 8, FL[i][5])
  -- right-side shade seam
  for yy = yl + 2, tip - 3 do if m:has(x + 3, yy) then c:px(x + 3, yy, FL[i][2]) end end
end
-- rope with twist, drawn over flag tops
local prev
for x = 6, 58 do
  local y = floor(sag(x) + 0.5)
  c:px(x, y, (x % 3 == 0) and ROPE[2] or ROPE[3]) c:px(x, y - 1, ROPE[4]) c:px(x, y + 1, ROPE[1])
end
-- end loops tied to pegs (quirk: left end has a bow)
c:fillMask(c:rect(4, 8, 6, 14), ROPE[3]) c:fillMask(c:rect(4, 8, 4, 14), ROPE[4]) c:fillMask(c:rect(6, 8, 6, 14), ROPE[1])
c:fillMask(c:rect(58, 8, 60, 14), ROPE[3]) c:fillMask(c:rect(58, 8, 58, 14), ROPE[4]) c:fillMask(c:rect(60, 8, 60, 14), ROPE[1])
c:px(5, 12, "#e8404c") c:px(3, 11, "#e8404c") c:px(3, 13, "#a02a3a") c:px(4, 12, "#ff8a80") c:px(5, 13, "#a02a3a") c:px(2, 12, "#a02a3a")
G.save(c, NAME)
