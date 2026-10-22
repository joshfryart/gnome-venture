local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local W, H = 120, 40
local c = GV.canvas{ w = W, h = H, mode = "scene", out = 2 }

-- filled region under a curve y = f(x), down to the bottom
local function under(f)
  local m = c:mask()
  for x = 0, W - 1 do
    local y0 = math.floor(f(x) + 0.5)
    for y = math.max(0, y0), H - 1 do m:set(x, y) end
  end
  return m
end
local function topline(m)
  local pts = {}
  for x = 0, W - 1 do
    for y = 0, H - 1 do if m:has(x, y) then pts[#pts + 1] = { x, y }; break end end
  end
  return pts
end

local sky = c:rect(0, 0, W - 1, H - 1)
local far = under(function(x) return 11 + 2 * math.sin(x / 7) + 1.2 * math.sin(x / 3.1) end)
local canopy = under(function(x)
  local d = math.abs(x - 60) / 60
  return 9 + 5 * d + 1.5 * math.sin(x / 4.3) + 0.8 * math.cos(x / 2.2)
end)
local mid = under(function(x) return 16 + 1.5 * math.sin(x / 6 + 1) + 0.8 * math.sin(x / 2.7) end)
local bands = {}
local bcol = { "#7ab55c", "#b0bc66", "#7ab55c", "#58a03e" }
for i, by in ipairs({ 22, 26, 30, 34 }) do
  bands[i] = under(function(x)
    local d = (x - 60) / 60
    return by - 3 * (1 - d * d) + 0.7 * math.sin(x / 5 + i * 1.7)
  end)
end

-- palm fan: pointed leaves radiating from a base
local function leaf(bx, by, ang, len, wd)
  local tx, ty = bx + len * math.cos(ang), by + len * math.sin(ang)
  local mx, my = bx + 0.55 * len * math.cos(ang), by + 0.55 * len * math.sin(ang)
  local nx, ny = -math.sin(ang) * wd, math.cos(ang) * wd
  return c:poly({ { bx, by }, { mx + nx, my + ny }, { tx, ty }, { mx - nx, my - ny } })
end
local function fan(bx, by, dir)
  local m = c:mask()
  local angs = { -0.15, -0.65, -1.15, -1.7, -2.3 }
  local lens = { 10, 13, 14, 12, 9 }
  for i, a in ipairs(angs) do
    local ang = (dir > 0) and a or (-math.pi - a)
    m:add(leaf(bx, by, ang, lens[i], 1.7))
  end
  m:add(c:line({ { bx, by }, { bx - dir, by + 6 } }, 2))
  return m
end

c:part(sky, GV.ramp("#d6c9b6"), { flat = true, outline = false, gloss = false })
c:part(far, GV.ramp("#b0bc66"), { flat = true, outline = false, gloss = false })
c:part(canopy, GV.ramp("#58a03e"), { gloss = false, contour = false })
c:part(mid, GV.ramp("#2e5a2c"), { gloss = false, contour = false })
for i = 1, 4 do
  c:part(bands[i], GV.ramp(bcol[i]), { gloss = false, contour = false, outline = false, rim = false })
end
-- ripple on each band top
for i = 1, 4 do
  local pts = topline(bands[i])
  local prevShade = (i == 1) and "#1f3e22" or GV.ramp(bcol[i - 1]).shade
  for j, p in ipairs(pts) do
    if p[2] > 0 then c:px(p[1], p[2] - 1, prevShade) end
    if ((j + i * 5) % 14) < 11 then c:px(p[1], p[2], "#a9d6ea") end
  end
end
local palmR = GV.ramp("#58a03e")
c:part(fan(5, 21, 1), palmR, { gloss = false })
c:part(fan(114, 21, -1), palmR, { gloss = false })

-- rain ticks (fewer in the calm centre)
local ticks = { {20,2},{27,6},{33,1},{38,9},{24,12},{45,4},{18,7},{30,16},{52,10},{41,14},
  {75,3},{82,8},{88,2},{94,11},{79,14},{98,5},{70,9},{86,17},{101,13},{63,2},{57,6},{92,20} }
for _, t in ipairs(ticks) do
  for k = 0, 2 do c:px(t[1] - k, t[2] + k, "#3f93b2") end
end

-- hem stitch top and bottom
c:seam({ { 0, 1 }, { W - 1, 1 } }, { free = true })
c:seam({ { 0, H - 2 }, { W - 1, H - 2 } }, { free = true })

-- vignette: darken corner pixels one step
local darker = {
  ["#d6c9b6"] = "#b8a894", ["#58a03e"] = "#3e7a30", ["#b0bc66"] = "#8a9a4a",
  ["#7ab55c"] = "#4a8a3e", ["#2e5a2c"] = "#1f3e22",
}
local function hex(px)
  if not px then return nil end
  if type(px) == "string" then return px:lower() end
  return string.format("#%02x%02x%02x", app.pixelColor.rgbaR(px), app.pixelColor.rgbaG(px), app.pixelColor.rgbaB(px))
end
for _, cr in ipairs({ { 0, 0, 1, 1 }, { W - 1, 0, -1, 1 }, { 0, H - 1, 1, -1 }, { W - 1, H - 1, -1, -1 } }) do
  for dx = 0, 3 do for dy = 0, 3 - dx do
    local x, y = cr[1] + dx * cr[3], cr[2] + dy * cr[4]
    local h = hex(c:get(x, y))
    if h and darker[h] then c:px(x, y, darker[h]) end
  end end
end

local t = c:save(O .. "aseprite/ph/banner-sea.aseprite", O .. "png/ph/banner-sea.png")
print(GV.report(t))
