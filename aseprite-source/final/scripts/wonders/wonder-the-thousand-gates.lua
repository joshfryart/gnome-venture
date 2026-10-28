-- wonder-the-thousand-gates.lua : red torii gates march up a misty hillside at dawn; a bowl shines at the last gate.
local REPO = "/home/user/gnome-venture/"
local L = dofile(REPO .. "aseprite-source/final/scripts/wonders/lmlib.lua")
local GV, c, W, H = L.GV, L.new(), L.W, L.H
local SLUG = "wonder-the-thousand-gates"

L.sky(c, "dawn", 78)
-- sun rising behind the summit
c:fill(c:ellipse(150, 52, 17, 17), "#fbe0a8"); c:fill(c:ellipse(150, 52, 12, 12), "#fff1c8")
L.cloud(c, 50, 30, 18, "#f0aa98", "#d49ab8"); L.cloud(c, 205, 24, 16, "#f8c890", "#d49ab8"); L.cloud(c, 100, 46, 12, "#fbe0a8", "#f0aa98")
for _, g in ipairs({ {30,52},{40,48},{210,46},{222,40} }) do
  c:px(g[1], g[2], "#2a1a10"); c:px(g[1]+1, g[2]+1, "#2a1a10"); c:px(g[1]+2, g[2], "#2a1a10"); c:px(g[1]+3, g[2]+1, "#2a1a10"); c:px(g[1]+4, g[2], "#2a1a10")
end
-- far mountains (misty lavender, flat)
local function ridge(base, amp, ph, col)
  local m = L.below(c, function(x) return base - amp * math.sin(x / 19 + ph) - amp * 0.5 * math.sin(x / 7 + ph * 2) end)
  c:fill(m, col)
end
ridge(72, 7, 0.5, "#a48ac0"); ridge(80, 6, 2.0, "#8c80b8")

-- main hill
local function hillf(x) return 52 + math.abs(x - 150) * 0.42 + (x < 150 and 0 or 0.1 * (x - 150)) end
local hill = L.below(c, hillf)
c:part(hill, GV.ramp("#4f9a45"), { cres = 6, deep = 9, outline = false, gloss = false })
-- back hills right and left (foothills)
local rr = L.below(c, function(x) return 100 - 8 * math.sin(x / 15) end)
rr:clip(c:rect(0, 0, 70, H)); c:fill(rr, "#3f8a3f")
local rr2 = L.below(c, function(x) return 96 - 6 * math.sin(x / 13 + 1) end)
rr2:clip(c:rect(205, 0, W, H)); c:fill(rr2, "#3f8a3f")

-- maple and pine blobs on the hill
local function tree(x, y, r, col, trunk)
  c:fill(c:rect(x - 1, y, x, y + r), "#4a2c1a")
  c:part(c:ellipse(x, y - 1, r, r * 0.85), GV.ramp(col), { cres = 3, deep = 5, gloss = false, outline = false })
end
for _, t in ipairs({ {100,66,5,"#d6322b"},{112,60,4,"#e0501f"},{196,68,5,"#f08a24"},{208,76,6,"#d6322b"},{185,60,4,"#e8a317"},
  {82,80,6,"#2f5a2a"},{70,92,7,"#4f9a45"},{214,92,6,"#2f5a2a"},{228,84,5,"#d6322b"},{40,104,7,"#e0501f"},{18,98,6,"#2f5a2a"},{124,76,4,"#f08a24"} }) do
  tree(t[1], t[2], t[3], t[4])
end

-- stone path (stair ribbon) winding up to the summit
local pts = { {112,134},{92,116},{122,100},{104,86},{136,74},{146,64},{150,55} }
local function lerp(t)
  local n = #pts - 1; local f = t * n; local i = math.min(n, math.floor(f)); local u = f - i
  local a, b = pts[i + 1], pts[i + 2]
  return a[1] + (b[1] - a[1]) * u, a[2] + (b[2] - a[2]) * u
end
for t = 0, 1, 0.01 do
  local x, y = lerp(t); local w = 1 + (1 - t) * 6
  c:fill(c:rect(math.floor(x - w), math.floor(y), math.floor(x + w), math.floor(y) + 1), (math.floor(t * 100) % 4 < 2) and "#e8dcc0" or "#c9b890")
end
-- steps as short dark dashes
for t = 0.04, 1, 0.045 do
  local x, y = lerp(t); local w = 1 + (1 - t) * 6
  c:fill(c:rect(math.floor(x - w), math.floor(y), math.floor(x + w), math.floor(y)), "#a89868")
end

-- torii gates, far to near
local function gate(x, y, h)
  local pw = (h >= 18) and 3 or ((h >= 9) and 2 or 1)
  local gw = math.max(2, math.floor(h * 0.55))
  local top = y - h
  if h < 8 then
    c:fill(c:rect(x - gw, top, x + gw, top + 1), "#a8241f")
    c:fill(c:rect(x - gw + 1, top + 2, x - gw + 1 + pw - 1, y), "#d6322b"); c:fill(c:rect(x + gw - pw, top + 2, x + gw - 1, y), "#d6322b")
    return
  end
  local function pillar(px)
    c:part(c:rect(px, top + 2, px + pw - 1, y), "red", { cres = math.max(1, pw - 1), deep = pw, gloss = false, outline = (h >= 14) })
  end
  pillar(x - gw + 1); pillar(x + gw - pw)
  local ny = top + math.floor(h * 0.3)
  c:part(c:rect(x - gw, ny, x + gw - 1, ny + math.max(1, pw - 1)), "red", { cres = 1, deep = 2, gloss = false, outline = false, contour = "#4a2c1a" })
  local kt = (h >= 14) and 3 or 2
  local kas = c:poly({ {x - gw - 2, top - 1}, {x + gw + 2, top - 1}, {x + gw, top + kt}, {x - gw, top + kt} })
  c:part(kas, GV.ramp("#2a2230"), { cres = 1, deep = 2, gloss = false, outline = false, contour = false })
  c:fill(c:rect(x - gw, top + kt, x + gw - 1, top + kt + (h >= 14 and 1 or 0)), "#d6322b")
end
local gl = {}
for i = 0, 13 do
  local t = 1 - (i / 13) ^ 0.85 * 0.98
  gl[#gl + 1] = t
end
for _, t in ipairs({ 0.97, 0.92, 0.86, 0.8, 0.74, 0.68, 0.62, 0.56, 0.5, 0.44, 0.38, 0.32, 0.26, 0.2, 0.14, 0.08 }) do
  local x, y = lerp(t)
  local h = 4 + (1 - t) * 19
  gate(math.floor(x), math.floor(y) + 1, math.floor(h))
end
-- (the last gate is at the summit: small, with the bowl)
-- summit shrine bits: stone bowl on a plinth, shining
c:part(c:rect(146, 54, 154, 56), GV.ramp("#8b8f96"), { cres = 1, deep = 2, gloss = false, outline = false })
c:part(c:ellipse(150, 53, 4, 2), GV.ramp("#e8a317"), { cres = 1, deep = 2, gloss = false, outline = false })
for _, p in ipairs({ {150,47},{149,48},{151,48},{150,49},{150,50} }) do c:px(p[1], p[2], "#fff1c8") end
c:px(146, 49, "#fff1c8"); c:px(154, 49, "#fff1c8"); c:px(147, 50, "#f5cf6a"); c:px(153, 50, "#f5cf6a")

-- foreground: big first gate on the left, framing the view, with stone fox and lantern
local function bigGate(x, y, h, gw, pw)
  local top = y - h
  for _, px in ipairs({ x - gw, x + gw - pw }) do
    c:part(c:rect(px, top + 4, px + pw - 1, y), "red", { cres = 3, deep = 6 })
  end
  c:part(c:rect(x - gw - 1, top + 12, x + gw + 1, top + 16), "red", { cres = 2, deep = 4, outline = false, contour = "#4a2c1a" })
  c:part(c:poly({ {x - gw - 8, top - 1}, {x + gw + 8, top - 1}, {x + gw + 3, top + 6}, {x - gw - 3, top + 6} }), GV.ramp("#2a2230"), { cres = 2, deep = 3, gloss = false, outline = false, contour = false })
  c:part(c:rect(x - gw - 6, top - 5, x + gw + 6, top - 2), GV.ramp("#2a2230"), { cres = 2, deep = 3, gloss = false, outline = false, contour = false })
  c:fill(c:rect(x - gw - 1, top + 6, x + gw, top + 7), "#d6322b")
  -- plinth feet
  for _, px in ipairs({ x - gw - 1, x + gw - pw - 1 }) do c:part(c:rect(px, y - 4, px + pw + 1, y), GV.ramp("#2a2230"), { flat = true, gloss = false, outline = false }) end
end
-- foreground stone ground
local fg = c:poly({ {0,H},{0,112},{30,108},{60,114},{84,H} })
c:part(fg, GV.ramp("#c9b890"), { cres = 5, deep = 8, gloss = false })
local fg2 = c:poly({ {170,H},{196,112},{240,106},{240,H} })
c:part(fg2, GV.ramp("#7ab55c"), { cres = 5, deep = 8, gloss = false })
bigGate(34, 124, 76, 22, 6)
-- hanging paper lamp on the beam? small lantern string
-- stone fox guardian (right foreground), red bib
local FX, FY = 205, 120
c:part(c:ellipse(FX, FY, 10, 6), GV.ramp("#c9c5bc"), { cres = 4, deep = 6, gloss = false })
c:part(c:rect(FX - 7, FY - 12, FX - 3, FY + 4), GV.ramp("#c9c5bc"), { cres = 2, deep = 4, gloss = false })
c:part(c:rect(FX - 1, FY - 12, FX + 3, FY + 4), GV.ramp("#c9c5bc"), { cres = 2, deep = 4, gloss = false })
local head = c:ellipse(FX - 1, FY - 17, 9, 7)
c:part(head, GV.ramp("#c9c5bc"), { cres = 3, deep = 5, gloss = false })
c:part(c:poly({ {FX - 10, FY - 20}, {FX - 8, FY - 32}, {FX - 3, FY - 21} }), GV.ramp("#c9c5bc"), { cres = 2, deep = 3, gloss = false, flat = true })
c:part(c:poly({ {FX + 3, FY - 21}, {FX + 7, FY - 32}, {FX + 9, FY - 19} }), GV.ramp("#c9c5bc"), { cres = 2, deep = 3, gloss = false, flat = true })
c:part(c:ellipse(FX + 6, FY - 14, 5, 2), GV.ramp("#8b8f96"), { flat = true, gloss = false, outline = false })
c:eye(FX - 7, FY - 20); c:eye(FX + 1, FY - 20)
c:part(c:rect(FX - 9, FY - 9, FX + 6, FY - 6), "red", { cres = 1, deep = 2, gloss = false, outline = false, contour = "#4a2c1a" })
c:part(c:poly({ {FX + 8, FY + 2}, {FX + 20, FY - 14}, {FX + 24, FY - 4}, {FX + 18, FY + 4} }), GV.ramp("#c9c5bc"), { cres = 2, deep = 3, gloss = false, flat = true })
c:ground(FX, FY + 6, 14, 2)
-- a few fallen maple leaves on the path
for _, p in ipairs({ {70,120},{76,126},{20,118},{48,121},{184,126},{226,128} }) do
  c:part(c:rect(p[1], p[2], p[1] + 2, p[2] + 1), GV.ramp("#e0501f"), { flat = true, gloss = false, outline = false })
end

L.finish(c, SLUG)
