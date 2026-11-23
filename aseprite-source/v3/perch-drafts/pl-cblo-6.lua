-- pl-cblo-6-perch : 36x36 chibi perch sprite (phase 4: SHADE)
local D = "C:/Users/hello/AppData/Local/Temp/ollama-art/pl-cblo-6-perch-20261120-172747/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local f = io.open(D .. "render-log.txt", "a")
local function log(s) if f then f:write(s .. "\n") end end
log("=== phase 4 SHADE ===")

local c = GV.canvas{ w = 36, h = 36, mode = "sticker", ol = 1, olx = 1 }

-- soft shadow ellipse under the perch
c:ground(17.5, 30.5, 9.5, 1.6, "#725977")

-- pal: red mushroom-capped creature with a cream face and a gold key-pin on top
local pin   = c:rrect(15, 4, 20, 6, 1)         -- key head (6 x 3, visible above the cap)
local stem  = c:rrect(17, 6, 18, 9, 1)         -- key stem, dips behind the cap
local legL  = c:rrect(13, 28, 14, 30, 1)       -- seat legs
local legR  = c:rrect(21, 28, 22, 30, 1)
local seat  = c:rrect(11, 24, 24, 28, 2)       -- wood stump seat
legL:add(legR)
seat:add(legL)
local face  = c:rrect(9, 15, 26, 24, 2)        -- pale face block, rests on the seat
local cap   = c:ellipse(17.5, 11.9, 12, 4.4)   -- flat wide mushroom cap over the face
cap:cut(c:rect(-8, 17, 43, 43))                 -- cap bottom edge ends at y17
local p = c:build{
  { "pin",   pin,   "#e0c090", { flat = true } },
  { "seat",  seat,  "wood",    {} },
  { "face",  face,  "#e0c090", { gloss = false } },
  { "cap",   cap,   "red",     { gloss = { 13, 9 } } },
}

-- face: big wide-set 5x5 round eyes, pink cheeks, tiny mouth
c:eye(10, 17)
c:eye(22, 17)
c:px(11, 18, "#2b1c26")                       -- pupil tint to spec plum (over umber)
for _, e in ipairs({ {10, 17}, {22, 17} }) do
  for j = 1, 3 do for i = 1, 3 do c:px(e[1] + i, e[2] + j, "#2b1c26") end end
  c:px(e[1] + 1, e[2] + 1, "#f2e4c0")          -- glint
end
c:paint({ "cc", "cc" }, 10, 21, { c = "#e2513f" })  -- left cheek
c:paint({ "cc", "cc" }, 25, 21, { c = "#e2513f" })  -- right cheek
c:px(17, 22, "#2b1c26"); c:px(18, 22, "#2b1c26")    -- tiny mouth

-- phase 5: TEXTURE - cap spots, tone-on-tone, 1 px dither at light/shade borders
-- (pal colour study first: dump x/pal.png map + legend to palinfo.txt for the next phase)
local pf = io.open(D .. "palinfo.txt", "w")
local ps = app.open(D .. "x/pal.png")
if ps then
  local pimg = Image(ps.spec); pimg:drawSprite(ps, 1)
  local pc = app.pixelColor
  local seen, chars, legend = {}, "123456789abcdefg", {}
  pf:write("pal legend+map\n")
  for y = 0, pimg.height - 1 do
    local row = {}
    for x = 0, pimg.width - 1 do
      local v = pimg:getPixel(x, y)
      if pc.rgbaA(v) == 0 then row[#row+1] = "."
      else
        local n = seen[v]
        if not n then n = #legend + 1; seen[v] = n
          legend[#legend+1] = string.format("%s=#%02x%02x%02x", chars:sub(n, n), pc.rgbaR(v), pc.rgbaG(v), pc.rgbaB(v))
        end
        row[#row+1] = chars:sub(n, n)
      end
    end
    pf:write(table.concat(row) .. "\n")
  end
  pf:write(table.concat(legend, " ") .. "\n")
  ps:close()
end
pf:close()

-- phase 6: DETAIL - amber eyes, key hole, gold sparkle + bead accent (spots removed: pal cap is unspotted)
c:px(12, 14, "#dd3a2a"); c:px(20, 15, "#dd3a2a")           -- 1 px dither at cap light/shade border
c:fill(c:rect(13, 26, 14, 26), "#8a4f2a")                 -- seat grain dash, lit half
c:fill(c:rect(17, 27, 18, 27), "#8a4f2a")                 -- seat grain dash, right of centre
c:px(11, 24, "#d9a660")                                    -- edge wear glint on seat corner
for _, e in ipairs({ {10, 17}, {22, 17} }) do               -- amber eye tint
  for j = 0, 4 do for i = 0, 4 do
    if not ((i == 0 or i == 4) and (j == 0 or j == 4)) then c:px(e[1] + i, e[2] + j, "#fbe39f") end
  end end
  for j = 1, 3 do for i = 1, 3 do c:px(e[1] + i, e[2] + j, "#2b1c26") end end
  c:px(e[1] + 1, e[2] + 1, "#f2e4c0")
end
c:px(17, 5, "#8f5a38")                                     -- key hole
c:px(4, 5, "#fbe39f"); c:px(4, 6, "#fbe39f"); c:px(4, 7, "#fbe39f")
c:px(3, 6, "#fbe39f"); c:px(5, 6, "#fbe39f")               -- gold sparkle, left of cap
c:fill(c:rect(30, 10, 31, 11), "#c03040"); c:px(30, 10, "#e2513f")  -- bead-chain accent, cap right

-- phase 7: CRITIQUE fixes
for x = 12, 21 do c:px(x, 23, "#cd834b") end                -- face bottom: face shade, not muddy deep
c:fill(c:rect(31, 10, 32, 11), "#c03040"); c:px(31, 10, "#e2513f")  -- bead moved 1px right, 1px gap from cap
c:px(15, 21, "#2b1c26"); c:px(19, 21, "#2b1c26")            -- smile arc ends

local t = c:save(D .. "out/pl-cblo-6-perch.aseprite", D .. "out/pl-cblo-6-perch.png")
local rep = GV.report(t)
log(rep)
print(rep)
assert(t.semi == 0 and t.bw == 0 and t.margin >= 1)
if f then f:close() end
