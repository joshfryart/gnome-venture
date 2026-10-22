local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "scene" }

c:fill(c:rect(0, 0, 63, 63), "#d6c9b6")

local cols = {
  grey  = { base = "#968f96", shade = "#6f6670", lit = "#b8b2b6" },
  dark  = { base = "#6a6070", shade = "#463e4e", lit = "#8a8090" },
  cream = { base = "#f4f0e0", shade = "#cfc2a8", lit = "#fbf8ec" },
  tan   = { base = "#dcb06a", shade = "#b0804a", lit = "#ecc58a" },
}
local order = { "grey", "dark", "cream", "tan", "dark", "grey", "tan", "cream", "grey" }
local shapes = {
  [2] = { "##", "##" },
  [3] = { ".#.", "###", "##." , },
  [4] = { ".##.", "####", "####", ".##." },
}
shapes[3] = { "##.", "###", ".##" }

local function W(v) return v % 64 end

local function pebble(x0, y0, size, col)
  local rows = shapes[size]
  local set = {}
  for j, row in ipairs(rows) do
    for i = 1, #row do
      if row:sub(i, i) == "#" then set[(i - 1) .. "," .. (j - 1)] = true end
    end
  end
  local first = true
  for j, row in ipairs(rows) do
    for i = 1, #row do
      if row:sub(i, i) == "#" then
        local x, y = i - 1, j - 1
        local hex = col.base
        if not set[(x + 1) .. "," .. y] or not set[x .. "," .. (y + 1)] then hex = col.shade end
        if first then hex = col.lit; first = false end
        c:px(W(x0 + x), W(y0 + y), hex)
      end
    end
  end
end

-- jittered 6x6 grid of pebbles; wraps across all edges
math.randomseed(70)
local n = 0
for gy = 0, 5 do
  for gx = 0, 5 do
    n = n + 1
    if not (n % 7 == 0) then -- leave a few cells empty so it never looks gridded
      local cx = gx * 10.67 + math.random(0, 7) + ((gy % 2) * 5)
      local cy = gy * 10.67 + math.random(0, 7)
      local size = ({ 3, 3, 4, 4, 2, 3, 4 })[math.random(1, 7)]
      local col = cols[order[(n * 5) % #order + 1]]
      if col == cols.cream and size == 4 then size = 3 end
      pebble(math.floor(cx), math.floor(cy), size, col)
    end
  end
end
-- second, offset pass of small pebbles
for gy = 0, 4 do
  for gx = 0, 4 do
    local col = cols[order[(gx * 3 + gy * 2) % #order + 1]]
    pebble(math.floor(gx * 12.8 + 6 + math.random(0, 3)), math.floor(gy * 12.8 + 6 + math.random(0, 3)), ({ 2, 3 })[math.random(1, 2)], col)
  end
end
-- fine sand specks
for i = 1, 26 do
  c:px(math.random(0, 63), math.random(0, 63), (i % 2 == 0) and "#c4b49c" or "#e4dac8")
end

local t = c:save(O .. "aseprite/ph/tile-gravel-path.aseprite", O .. "png/ph/tile-gravel-path.png")
print(GV.report(t))
