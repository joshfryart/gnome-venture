-- flood-boots-lined: Lined rank of the Flood Boots (Opus second pass, batch3). 64x64.
-- Base: game ph/flood-boots.png (read only). Same green wellies, same splash quirk.
-- Lined = both turned-down cuffs are now thick curly sheepskin: tufted top edge, cream
-- curls lit from the upper left, tufts spilling over the shaft with a contact shadow.
-- quirk kept from base: blue water splash at the toe.
local O = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_o2.lua")
local img = O.load(O.PH .. "flood-boots.png")

-- back boot cuff (painted first, the front boot overlaps it)
local back = O.rectSet(23, 8, 40, 8)
O.rectSet(22, 9, 40, 14, back)
for _, x in ipairs({ 24, 25, 26, 30, 31, 32, 35, 36, 37 }) do back[7 * 64 + x] = true; O.px(img, x, 6, O.INK) end
O.wool(img, back, { shadeFrom = 37, phase = 1, yLight = 9, yDark = 13 })
-- tufts of the back cuff spilling over the dark mouth row
O.paint(img, 31, 15, { "abb.abb.a" }, { a = O.WOOL.shade, b = O.WOOL.deep })

-- front boot cuff, x9..31 from y10
local rows = {
  "...###..###...###......", -- 10
  "..#www##www#.#www#.....", -- 11
  ".#wwwwwwwwwwwwwwwwwww#.", -- 12
  ".#wwwwwwwwwwwwwwwwwww#.", -- 13
  ".#wwwwwwwwwwwwwwwwwww#.", -- 14
  ".#wwwwwwwwwwwwwwwwwww#.", -- 15
  ".#wwwwwwwwwwwwwwwwwww#.", -- 16
  ".#wwwwwwwwwwwwwwwwwww#.", -- 17
  ".#wwwwwwwwwwwwwwwwwww#.", -- 18
  ".#wwwwwwwwwwwwwwwwwww#.", -- 19
  "..#wwwwwwwwwwwwwwwww#..", -- 20
  "....www..www...www.....", -- 21 tufts over the shaft
}
local front = O.marks(9, 10, rows, "w")
O.paint(img, 9, 10, rows, { w = O.WOOL.base })
O.wool(img, front, { shadeFrom = 26, yLight = 14, yDark = 18 })
-- contact shadow under the tufts on the green shaft
O.paint(img, 12, 21, { "j...j..jj..j...j" }, { j = "#22503f" })
O.paint(img, 13, 22, { "iii..iii...iii" }, { i = "#22503f" })
O.reink(img)
O.save(img, "flood-boots-lined")
