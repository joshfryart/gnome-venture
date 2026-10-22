# ph/wattle-fence-corner
- canvas: 64x64, mode sticker, 1x.
- subject: Corner piece of woven-willow wattle fence: two woven rails meeting in an L with a round post at the bend.
- must-read-at-16px: brown L shape (bar going right, bar going down) with a dark round knob at the corner.
- distinct: the only L-shaped asset; diagonal weave ticks and a round corner post make it unlike straight fences.
- parts (back to front):
  1. horizontal rail: rect x32..61, y28..36, wood #a5663a (wood #a8582f)
  2. vertical rail: rect x28..36, y32..61, same wood (keep 3 px margin from the frame)
  3. weave dark ticks: 4px diagonals #5e2f1e every 6 px, e.g. (40,29)->(43,35), (52,29)->(55,35); (29,40)->(35,43), (29,52)->(35,55)
  4. weave light ticks: 1px diagonals #dcb06a (wood rim #d9a660) between the dark ones
  5. corner post: disc centre (32,32) r5, #44281c (wood deep #5e2f1e); inner dot (31,31) r2 #a5663a
- joins: none (wood; no stitch).
- face: none.
- notes: bars at least 8 px thick; gloss on top-left of the corner post; 1 px contact shadow under bars.
