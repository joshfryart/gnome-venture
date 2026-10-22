-- Gnome Venture flower head: orchid (Stitched Toy, tintable).
-- Petals: neutral greys (runtime tint). Centre (column + anther), lip freckles and gold thread: fixed colours.
-- Outputs: png/orchid.png (full), png/orchid-petals.png, png/orchid-centre.png, aseprite/orchid.aseprite (2 layers).
local ROOT = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(ROOT .. "gvlib/gvlib.lua")
local OUT = ROOT .. "flowers-pixel/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker", halo = 0, margin = 0 }

-- SVG (64 viewBox) -> grid: scale S about x=32, svg y=29.6 -> grid y=31.5
local S, SY, GY = 0.87, 29.6, 31.5
local function rell(cx, cy, rx, ry, deg)
  local m = c:mask()
  local a = math.rad(deg or 0)
  local ca, sa = math.cos(a), math.sin(a)
  for j = -4, 67 do for i = -4, 67 do
    local sx = 32 + (i + 0.5 - 32) / S
    local sy = SY + (j + 0.5 - GY) / S
    local dx, dy = sx - cx, sy - cy
    local u = dx * ca + dy * sa
    local v = -dx * sa + dy * ca
    if (u / rx) ^ 2 + (v / ry) ^ 2 <= 1 then m:set(i, j) end
  end end
  return m
end
local function g(x, y) return math.floor(32 + (x - 32) * S), math.floor(GY + (y - SY) * S) end

-- neutral grey ramps (no hue), lightest on the lip, darkest on the back sepals
local function grey(base, rim, gloss, shade, deep, bounce)
  return { base = base, rim = rim, gloss = gloss, dot = "#f8f8f8", shade = shade, deep = deep, bounce = bounce, pale = false }
end
local LAT = grey("#cdcdcd", "#e2e2e2", "#f1f1f1", "#9a9a9a", "#6a6a6a", "#aaaaaa")
local DOR = grey("#d6d6d6", "#e8e8e8", "#f3f3f3", "#a2a2a2", "#707070", "#b2b2b2")
local LOW = grey("#bebebe", "#d4d4d4", "#ececec", "#8c8c8c", "#606060", "#9c9c9c")
local LIP = grey("#e2e2e2", "#efefef", "#f6f6f6", "#a8a8a8", "#767676", "#b8b8b8")
local COL = { base = "#f1ece0", rim = "#fff3c8", gloss = "#fff3c8", dot = "#fff8e0", shade = "#d8c49a", deep = "#b8661a", bounce = "#e6d4ac", pale = false }

-- lip: SVG ellipse plus a ruffled lower hem (three scallops) to make this orchid its own
local lip = rell(32, 42, 10, 9)
lip:add(rell(26.5, 49.5, 3.2, 2.6)):add(rell(32, 51, 3.4, 2.6)):add(rell(37.5, 49.5, 3.2, 2.6))
for _, nx in ipairs({ 28, 35 }) do -- notch between scallops: drop the lowest 2 px of that column
  local yb = -1
  for y = 0, 63 do if lip:has(nx, y) then yb = y end end
  if yb > 0 then lip:del(nx, yb); lip:del(nx, yb - 1) end
end

local P = c:build{
  { "dorsal", rell(32, 15, 8.5, 12.5),        DOR, { cres = 3 } },
  { "latL",   rell(15, 28, 15, 9.5, -18),     LAT, { cres = 3 } },
  { "latR",   rell(49, 28, 15, 9.5, 18),      LAT, { cres = 3 } },
  { "lowL",   rell(22, 46, 6, 12, 32),        LOW, { cres = 3 } },
  { "lowR",   rell(42, 46, 6, 12, -32),       LOW, { cres = 3 } },
  { "lip",    lip,                            LIP, { cres = 3 } },
  { "column", rell(32, 31, 4.9, 4.9),         COL, { gloss = false } },
}
local centreParts = { [P.column] = true }

-- petal veins in a darker neutral grey (reads after any tint)
local VEIN = "#a6a6a6"
local function vein(m, pts)
  local l = c:line(pts, 1)
  l:each(function(x, y) if m:has(x, y) and not c.shd[c:key(x, y)] and not c.gl.s[c:key(x, y)] then c:px(x, y, VEIN) end end)
end
local ax, ay = g(21, 44) local bx, by = g(26, 53)  vein(P.lowL.m, { {ax, ay}, {bx, by} })
ax, ay = g(43, 44) bx, by = g(38, 53)             vein(P.lowR.m, { {ax, ay}, {bx, by} })
ax, ay = g(7, 31) bx, by = g(22, 27)              vein(P.latL.m, { {ax, ay}, {bx, by} })
ax, ay = g(57, 31) bx, by = g(42, 27)             vein(P.latR.m, { {ax, ay}, {bx, by} })

-- stitched-toy signature: thread-gold seam down the dorsal sepal (fixed colour)
local sx, sy0 = g(32, 5) local _, sy1 = g(32, 23)
c:seam({ { sx, sy0 }, { sx, sy1 } })

-- lip freckles (fixed deep ember, glazed) like the SVG's five dots
local FR, FRG = "#6b1b2c", "#ae2a2a"
for _, d in ipairs({ {28.5, 41.5}, {35, 42.5}, {32, 46}, {27, 46}, {37, 46.5} }) do
  local x, y = g(d[1], d[2])
  c:px(x, y, FRG); c:px(x + 1, y, FR); c:px(x, y + 1, FR); c:px(x + 1, y + 1, FR)
end

-- anther cap on the column: small gold disc with a glint (fixed)
local cx, cy = g(32, 31.5)
c:paint({ ".ab.", "abbc", "bbcc", ".cc." }, cx - 2, cy - 1, { a = "#fff1c8", b = "#e8a317", c = "#b8661a" })
c:px(cx - 2, cy - 4, "#fff3c8") -- column gloss pip
c:px(cx - 1, cy - 4, "#fff3c8")

-- full image, then split: centre = column part pixels + any fixed-colour pixel
local full = c:image()
local FIX = { ["#f5cf6a"]=1, ["#e8a317"]=1, ["#8a4a1c"]=1, ["#fff1c8"]=1, ["#b8661a"]=1, ["#6b1b2c"]=1, ["#ae2a2a"]=1, ["#fff3c8"]=1 }
local pc = app.pixelColor
local petals = Image(64, 64, ColorMode.RGB); petals:clear(pc.rgba(0,0,0,0))
local centre = Image(64, 64, ColorMode.RGB); centre:clear(pc.rgba(0,0,0,0))
for y = 0, 63 do for x = 0, 63 do
  local v = full:getPixel(x, y)
  if pc.rgbaA(v) > 0 then
    local k = c:key(x, y)
    local hex = c.pix[k]
    if (c.own[k] and centreParts[c.own[k]]) or FIX[hex] then centre:putPixel(x, y, v) else petals:putPixel(x, y, v) end
  end
end end

local spr = Sprite(64, 64, ColorMode.RGB)
spr.layers[1].name = "petals"
spr.cels[1].image = petals
local lc = spr:newLayer(); lc.name = "centre"
spr:newCel(lc, 1, centre, Point(0, 0))
app.fs.makeAllDirectories(OUT .. "png"); app.fs.makeAllDirectories(OUT .. "aseprite")
spr:saveAs(OUT .. "aseprite/orchid.aseprite")
spr:close()
full:saveAs(OUT .. "png/orchid.png")
petals:saveAs(OUT .. "png/orchid-petals.png")
centre:saveAs(OUT .. "png/orchid-centre.png")
print("full    " .. GV.report(GV.check(full)))
print("petals  " .. GV.report(GV.check(petals)))
print("centre  " .. GV.report(GV.check(centre)))
