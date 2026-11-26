
global gLOProps, newSize, extraBufferTiles, gLEprops
on exitFrame me
  if dontRunStuff() then
    go the frame
    return
  end if
  
  -- This is probably the only place remaining exempt from custom keybinds
  if _key.keyPressed(36) then
    if (gLOprops.size <> point(newSize[1], newSize[2]))or(newSize[3]<>0)or(newSize[4]<>0) then
      if newSize[1] > 0 and newSize[2] > 0 and (-newSize[3] < newSize[1]) and (-newSize[4] < newSize[2])then
        resizeLevel(point(newSize[1], newSize[2]),newSize[3],newSize[4] )
      end if
    end if
    gLOProps.extraTiles = extraBufferTiles.duplicate()
    
    -- Fix possible issues with extra tiles hopefully
    repeat with i = 1 to gLOProps.extraTiles.count then
      if gLOProps.extraTiles[i] < 0 or gLOProps.extraTiles[i] = void or ilk(gLOProps.extraTiles[i]) <> #number then
        gLOProps.extraTiles[i] = 0
      end if
    end repeat
    
    -- Finally go back
    _movie.go(9)
  else if _key.keyPressed(56) then
    _movie.go(9)
  else
    go the frame
  end if
end