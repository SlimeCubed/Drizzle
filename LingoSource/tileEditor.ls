global gTEprops, gLEProps, gTiles, gLOProps, gDirectionKeys, gEnvEditorProps, specialRectPoint, showControls, gFSLastTm, gFSFlag


on exitFrame me
  if (showControls) then
    sprite(23).blend = 100
  else
    sprite(23).blend = 0
  end if
  
  if dontRunStuff() then
    gFSLastTm = _system.milliseconds
    go the frame
    return
  end if
  
  gFSFlag = false
  if _system.milliseconds - gFSLastTm > 10 then
    gFSFlag = true
    gFSLastTm = _system.milliseconds
  end if
  
  msTile = (_mouse.mouseLoc/point(16.0, 16.0))+point(0.4999, 0.4999)
  msTile = point(msTile.loch.integer, msTile.locV.integer)+point(-1, -1)+gLEprops.camPos
  
  repeat with q = 1 to 4 then
    if (me.getDirection(q)) then
      if gFSFlag then
        if (gDirectionKeys[q] = 0) or (gDirectionKeys[q] > 20 and (gDirectionKeys[q] mod 2) = 0) then
          fast = checkCustomKeybind(#MoveFast, 83)
          faster = checkCustomKeybind(#MoveFaster, 85)
          gLEProps.camPos = gLEProps.camPos + [point(-1, 0), point(0,-1), point(1,0), point(0,1)][q] * (1 + 9 * fast + 34 * faster)
          if not checkCustomKeybind(#MoveOutside, 92) then
            if gLEProps.camPos.loch < -1 then
              gLEProps.camPos.loch = -1
            end if
            if gLEProps.camPos.locv < -1 then
              gLEProps.camPos.locv = -1
            end if  
            if gLEProps.camPos.loch > gLEprops.matrix.count-51 then
              gLEProps.camPos.loch = gLEprops.matrix.count-51
            end if
            if gLEProps.camPos.locv > gLEprops.matrix[1].count-39 then
              gLEProps.camPos.locv = gLEprops.matrix[1].count-39
            end if
          end if
          repeat with l = 1 to 3 then
            lvlEditDraw(rect(1,1,gLOprops.size.loch,gLOprops.size.locv), l)
            TEdraw(rect(1,1,gLOprops.size.loch,gLOprops.size.locv), l)
          end repeat
          drawShortCutsImg(rect(1,1,gLOprops.size.loch,gLOprops.size.locv), 16, 1)
        end if
        gDirectionKeys[q] = gDirectionKeys[q] + 1
      end if
    else
      gDirectionKeys[q] = 0
    end if
  end repeat
  
  
  rct = rect(0,0,gLOprops.size.loch, gLOprops.size.locv) + rect(gLOProps.extraTiles[1], gLOProps.extraTiles[2], -gLOProps.extraTiles[3], -gLOProps.extraTiles[4]) - rect(gLEProps.camPos, gLEProps.camPos)
  sprite(71).rect = (rct.intersect(rect(0,0,52,40))+rect(1, 1, 1, 1))*rect(16,16,16,16)
  
  if me.checkKey("Q") then
    PickUpTile(msTile)
  end if
  
  if me.checkKey("L") then
    gTEprops.workLayer = gTEprops.workLayer +1
    if gTEprops.workLayer > 3 then
      gTEprops.workLayer = 1
    end if
    writeMaterial(msTile)
    
    ChangeLayer()
    
    
  end if
  
  actn = 0
  actn2 = 0
  
  gTEprops.keys.m1 = _mouse.mouseDown
  if (gTEprops.keys.m1)and(gTEprops.lastKeys.m1=0) then
    actn = 1
  end if
  gTEprops.lastKeys.m1 = gTEprops.keys.m1
  gTEprops.keys.m2 = _mouse.rightmouseDown
  if (gTEprops.keys.m2)and(gTEprops.lastKeys.m2=0) then
    actn2 = 1
  end if
  gTEprops.lastKeys.m2 = gTEprops.keys.m2
  if msTile <> gTEprops.lstMsPs then
    writeMaterial(msTile)
    
    actn = gTEprops.keys.m1
    --  if gTEprops.toolType = "material" then
    actn2 = gTEprops.keys.m2
    
    --end if
    
    isTilePositionLegal(msTile)
    
  end if
  gTEprops.lstMsPs = msTile
  
  if gTEprops.specialEdit <> 0 then
    -- gTEprops.specialEdit
    sprite(19).visibility = 1
    member("default material").text = "SPECIAL EDIT:" && string(gTEprops.specialEdit)
    
    if actn then
      specialAction(msTile)
    end if
    if actn2 then
      gTEprops.specialEdit = 0
    end if
    
    sprite(19).visibility = (gTEprops.specialEdit <> 0)
  else
    if actn then
      action(msTile)
    end if
    if actn2 then
      deleteTile(msTile)
    end if
  end if
  
  if me.checkKey("W") then
    updateTileMenu(point(0, -1))
  end if
  if me.checkKey("S") then
    updateTileMenu(point(0, 1))
  end if
  if me.checkKey("A") then
    updateTileMenu(point(-1, 0))
  end if
  if me.checkKey("D") then
    updateTileMenu(point(1, 0))
  end if
  
  if gTEprops.toolType = "material" then
    if checkCustomKeybind(#TileBigBrush, "F") then
      sprite(88).rect = rect(msTile*16, (msTile+point(1,1))*16) + rect(-16,-16,16,16) - rect(gLEprops.camPos*16, gLEprops.camPos*16)
    else if checkCustomKeybind(#TileBiggerBrush, "V") then
      sprite(88).rect = rect(msTile*16, (msTile+point(1,1))*16) + rect(-32,-32,32,32) - rect(gLEprops.camPos*16, gLEprops.camPos*16)
    else
      sprite(88).rect = rect(msTile*16, (msTile+point(1,1))*16) - rect(gLEprops.camPos*16, gLEprops.camPos*16)
    end if
    sprite(13).loc = point(-2000, -2000)
  else if gTEprops.toolType = "special" then
    
    sprite(88).color = gTiles[gTEprops.tmPos.locH].tls[gTEprops.tmPos.locV].color
    
    case (gTiles[gTEprops.tmPos.locH].tls[gTEprops.tmPos.locV].placeMethod) of
      "rect":
        if(specialRectPoint = void)then
          sprite(88).rect = rect(msTile*16, (msTile+point(1,1))*16) - rect(gLEprops.camPos*16, gLEprops.camPos*16)
          if(actn) and (_mouse.mouseLoc.inside(rect(16, 17, 848, 657))) then
            specialRectPoint = msTile
          end if
        else
          rct = rect(specialRectPoint, specialRectPoint+point(1,1)).union(rect(msTile, msTile+point(1,1)))
          sprite(88).rect = rct*16 - rect(gLEprops.camPos*16, gLEprops.camPos*16)
          if(actn2) and (_mouse.mouseLoc.inside(rect(16, 17, 848, 657)))then
            specialRectPoint = void
          else  if(actn) and (_mouse.mouseLoc.inside(rect(16, 17, 848, 657)))then
            specialRectPoint = void
            SpecialRectPlacement(rct+rect(0,0,-1,-1))
          end if
        end if
    end case
    
    
    
    
    
    sprite(13).loc = point(-2000, -2000)
  else
    sprite(88).rect = rect(-5,-5,-5,-5)
    mdPnt = point(((gTiles[gTEprops.tmPos.locH].tls[gTEprops.tmPos.locV].sz.locH*0.5)+0.4999).integer,((gTiles[gTEprops.tmPos.locH].tls[gTEprops.tmPos.locV].sz.locV*0.5)+0.4999).integer)
    --offst = point(3,3)-mdPnt
    sprite(13).loc = (msTile+point(1,1)-mdPnt-gLEprops.camPos)*16
    
  end if
  
  if checkCustomKeybind(#TileDefaultMaterial, "E") then
    updateTileMenu(point(0,0))
  end if
  
  if checkCustomKeybind(#ClearAllTiles, ["C","X",48]) then
    me.deleteAllTiles()
  end if
  
  
  if gEnvEditorProps.waterLevel = -1 then
    sprite(9).rect = rect(0,0,0,0)
  else
    rct = rect(0, gLOprops.size.locv-gEnvEditorProps.waterLevel-gLOProps.extraTiles[4], gLOprops.size.loch, gLOprops.size.locv) - rect(gLEProps.camPos, gLEProps.camPos)
    sprite(9).rect = ((rct.intersect(rect(0,0,52,40))+rect(1, 1, 1, 1))*rect(16,16,16,16))+rect(0, -8, 0, 0)
  end if
  
  
  script("levelOverview").goToEditor()
  tile = gTiles[gTEprops.tmPos.locH].tls[gTEprops.tmPos.locV]
  ttgs = tile[#tags]
  go the frame
end


on deleteAllTiles()
  global gLOprops
  gTEprops.tlMatrix = []
  repeat with q = 1 to gLOprops.size.loch then
    l = []
    repeat with c = 1 to gLOprops.size.locv then
      l.add([[#tp:"default", #data:0], [#tp:"default", #data:0], [#tp:"default", #data:0]])
    end repeat
    gTEprops.tlMatrix.add(l)
  end repeat
  
  repeat with q = 1 to 3 then
    TEdraw(rect(1,1,gLOprops.size.loch,gLOprops.size.locv), q)
  end repeat
end


on getDirection me, q
  -- check order: left, up, right, down
  k = [#MoveLeft, #MoveUp, #MoveRight, #MoveDown][q]
  orig = [86, 91, 88, 84][q]
  return checkCustomKeybind(k, orig)
end

on checkKey me, key
  rtrn = 0
  
  kb = VOID
  hasFastScroll = false
  fastScrollRate = 4
  case key of
    "W":
      kb = #TileSelectUp
      hasFastScroll = true
    "S":
      kb = #TileSelectDown
      hasFastScroll = true
    "A":
      kb = #TileCategoryPrev
      hasFastScroll = true
      fastScrollRate = 8
    "D":
      kb = #TileCategoryNext
      hasFastScroll = true
      fastScrollRate = 8
    "Q":
      kb = #TileSample
    "L":
      kb = #TileChangeLayer
  end case
  
  rslt = checkCustomKeybind(kb, key) and not dontRunStuff()
  if hasFastScroll then
    -- fast scroll
    if rslt then
      if gFSFlag then
        gTEProps.keys[symbol(key)] = gTEProps.keys[symbol(key)] + 1
      end if
    else
      gTEProps.keys[symbol(key)] = 0
    end if
    
    if (gTEProps.keys[symbol(key)] = 1) or ((gTEProps.keys[symbol(key)] > 20) and ((gTEProps.keys[symbol(key)] mod fastScrollRate) = 0)) then
      rtrn = gFSFlag
    end if
  else
    -- no fast scroll
    gTEProps.keys[symbol(key)] = rslt
    if (gTEProps.keys[symbol(key)])and(gTEProps.lastKeys[symbol(key)]=0) then
      rtrn = 1
    end if
  end if
  gTEProps.lastKeys[symbol(key)] = gTEProps.keys[symbol(key)]
  return rtrn
end



on writeMaterial(msTile)
  global gLoprops
  sprite(8).visibility = 0
  if msTile.inside(rect(1,1,gLOprops.size.loch+1,gLOprops.size.locv+1)) then
    txt = ""
    if (_mouse.mouseLoc.inside(rect(16, 17, 848, 657))) then
      case gLEProps.matrix[msTile.locH][msTile.locV][gTEprops.workLayer][1] of
        1:
          txt = "Wall"
        2:
          txt = "Eastward Slope"
        3:
          txt = "Westward Slope"
        4:
          txt = "Ceiling Slope"
        5:
          txt = "Ceiling Slope"
        6:
          txt = "Floor"
        7:
          txt = "Short Cut Entrance"
          sprite(8).visibility = 1
        8:
          txt = "Lizard's Hole"
        9:
          txt = "Glass"
      end case
    else 
      txt = ""
    end if
    if txt <> "" then
      case gTEprops.tlMatrix[msTile.locH][msTile.locV][gTEprops.workLayer].tp of
        "material":
          put " - Material:" && string(gTEprops.tlMatrix[msTile.locH][msTile.locV][gTEprops.workLayer].data) after txt
        "tileHead":
          put " - Tile:" && gTEprops.tlMatrix[msTile.locH][msTile.locV][gTEprops.workLayer].data[2] after txt
          if gTEprops.tlMatrix[msTile.locH][msTile.locV][gTEprops.workLayer].data.count > 2 then
            put " :: Additional Data:" && gTEprops.tlMatrix[msTile.locH][msTile.locV][gTEprops.workLayer].data[3] after txt
          end if
        "tileBody":
          dt = gTEprops.tlMatrix[msTile.locH][msTile.locV][gTEprops.workLayer].data
          if dt[1].locH > 0 and dt[1].locV > 0 and dt[1].locH < gLOprops.size.loch+1 and dt[1].locV < gLOprops.size.locv+1 then
            if gTEprops.tlMatrix[dt[1].locH][dt[1].locV][dt[2]].tp = "tileHead" then
              put " - Tile:" && gTEprops.tlMatrix[dt[1].locH][dt[1].locV][dt[2]].data[2] after txt
            else
              put " - Stray Tile Fragment" after txt
            end if
          else
            put " - Stray Tile Fragment" after txt
          end if
      end case
    end if
    member("editor1tool").text = txt
  else
    member("editor1tool").text = ""
  end if
end



on updateTileMenu(mv)
  if(mv = void)or(mv = script("tileEditor"))then
    mv = point(0,0)
  end if
  
  gTEprops.tmPos = gTEprops.tmPos + mv
  if mv.locH <> 0 then
    if gTEprops.tmPos.locH < 1 then
      gTEprops.tmPos.locH = gTiles.count
    else if gTEprops.tmPos.locH > gTiles.count then
      gTEprops.tmPos.locH = 1
    end if 
    gTEprops.tmPos.locV = gTEprops.tmSavPosL[gTEprops.tmPos.locH]
  else if mv.locV <> 0 then
    if gTEprops.tmPos.locV < 1 then
      gTEprops.tmPos.locV = gTiles[gTEprops.tmPos.locH].tls.count
    else if gTEprops.tmPos.locV > gTiles[gTEprops.tmPos.locH].tls.count then
      gTEprops.tmPos.locV = 1
    end if
    gTEprops.tmSavPosL[gTEprops.tmPos.locH] = gTEprops.tmPos.locV
  end if
  
  gTEprops.tmPos.locH = restrict(gTEprops.tmPos.locH, 1, gTiles.count)
  gTEprops.tmPos.locV = restrict(gTEprops.tmPos.locV, 1, gTiles[gTEprops.tmPos.locH].tls.count)
  
  txt = ""
  put "[" && gTiles[gTEprops.tmPos.locH].nm && "]" after txt
  put RETURN after txt
  
  repeat with tl = 1 to gTiles[gTEprops.tmPos.locH].tls.count then
    if gTEprops.tmPos.locV <= gTiles[gTEprops.tmPos.locH].tls.count and gTEprops.tmPos.locV - 20 - tl > 0 then
      next repeat
    end if
    if tl = gTEprops.tmPos.locV then
      put "-" && gTiles[gTEprops.tmPos.locH].tls[tl].nm && "-" && RETURN after txt
    else
      put gTiles[gTEprops.tmPos.locH].tls[tl].nm && RETURN after txt
    end if
  end repeat
  
  member("tileMenu").text = txt
  --CAT CHANGE
  if (gTEprops.tmPos.locH <= getLastMatCat()) then
    sprite(19).visibility = 1
    gTEprops.toolType = "material"
    gTEprops.toolData = gTiles[gTEprops.tmPos.locH].tls[gTEprops.tmPos.locV].nm
    member("tilePreview").image = image(1,1,1)
    if _key.keyPressed("E") and _movie.window.sizeState <> #minimized then
      if  gTEprops.defaultMaterial <> gTiles[gTEprops.tmPos.locH].tls[gTEprops.tmPos.locV].nm then
        gTEprops.defaultMaterial = gTiles[gTEprops.tmPos.locH].tls[gTEprops.tmPos.locV].nm
        --  put "set" &&     gTEprops.defaultMaterial && "as default material"
        member("default material").text = "Default material:" && gTEprops.defaultMaterial && "(Press 'E' to change)"
      end if
    end if
  else if gTiles[gTEprops.tmPos.locH].nm = "special" then
    gTEprops.toolType = "special"
    gTEprops.toolData = gTiles[gTEprops.tmPos.locH].tls[gTEprops.tmPos.locV].nm
    member("tilePreview").image = image(1,1,1)
  else if gTiles[gTEprops.tmPos.locH].tls[gTEprops.tmPos.locV].tp = "autotile" then
    gTEprops.toolType = "special"
    gTEprops.toolData = gTiles[gTEprops.tmPos.locH].tls[gTEprops.tmPos.locV].nm
    member("tilePreview").image = image(1,1,1)
  else
    if gTEprops.specialEdit = 0 then
      sprite(19).visibility = 0
    end if
    gTEprops.toolType = "tile"
    gTEprops.toolData = "TILE"--gTEprops.tmPos--gTiles[gTEprops.tmPos.locH].tls[gTEprops.tmPos.locV]
    drawTilePreview()
  end if
  
  isTilePositionLegal(gTEprops.lstMsPs)
  ChangeLayerText()
end


on action(msTile)
  if dontRunStuff() then
    return
  end if
  
  if msTile.inside(rect(1,1,gLOprops.size.loch+1,gLOprops.size.locv+1)) and (_mouse.mouseLoc.inside(rect(16, 17, 848, 657)))then
    case gTEprops.toolType of
      "material":
        -- Figure out where to place
        l = [msTile]
        if checkCustomKeybind(#TileBigBrush, "F") then
          l = [msTile, msTile+point(1,0),msTile+point(-1,0),msTile+point(0,1),msTile+point(0,-1),msTile+point(-1,-1),msTile+point(-1,1),msTile+point(1,1),msTile+point(1,-1)]
        else if checkCustomKeybind(#TileBiggerBrush, "V") then
          l = [msTile, msTile+point(1,0),msTile+point(-1,0),msTile+point(0,1),msTile+point(0,-1),msTile+point(-1,-1),msTile+point(-1,1),msTile+point(1,1),msTile+point(1,-1),msTile+point(0,-2),msTile+point(1,-2),msTile+point(2,-2),msTile+point(-1,-2),msTile+point(-2,-2),msTile+point(0,2),msTile+point(1,2),msTile+point(2,2),msTile+point(-1,2),msTile+point(-2,2),msTile+point(-2,0),msTile+point(-2,1),msTile+point(-2,-1),msTile+point(2,0),msTile+point(2,1),msTile+point(2,-1)]
        end if
        
        -- Place materials
        forceAdaptTerrain = checkCustomKeybind(#TileForceGeometry, "G")
        repeat with q in l then
          if q.inside(rect(1,1,gLOprops.size.loch+1,gLOprops.size.locv+1)) then
            if ["tileHead", "tileBody"].getPos(gTEprops.tlMatrix[q.locH][q.locV][gTEprops.workLayer].tp) = 0 then
              gTEprops.tlMatrix[q.locH][q.locV][gTEprops.workLayer].tp = "material"
              gTEprops.tlMatrix[q.locH][q.locV][gTEprops.workLayer].data = gTEprops.toolData
              
              if forceAdaptTerrain then
                gLEProps.Matrix[q.locH][q.locV][gTEprops.workLayer][1] = 1
              end if
            end if
            TEdraw(rect(q,q), gTEprops.workLayer)
          end if
        end repeat
        
        -- Redraw geometry
        if(forceAdaptTerrain)then
          lvlEditDraw(rect(msTile-point(2,2), msTile+point(2,2)), gTEprops.workLayer)
        end if
      "tile":
        if ((isTilePositionLegal(msTile))or(checkCustomKeybind(#TileBigBrush, "F"))or(checkCustomKeybind(#TileBiggerBrush, "V"))or(checkCustomKeybind(#TileForcePlace, "F"))or(checkCustomKeybind(#TileForceGeometry, "G"))) then
          placeTile(msTile, gTEprops.tmPos)
          --  TEdraw(rect(msTile+point(-4, -4),msTile+point(4, 4)), 1)
          -- TEdraw(rect(msTile+point(-4, -4),msTile+point(4, 4)), 2)
        end if
    end case
  end if
end


on deleteTile(msTile)
  if dontRunStuff() then
    return
  end if
  
  global gLOprops
  if msTile.inside(rect(1,1,gLOprops.size.loch+1,gLOprops.size.locv+1)) and (_mouse.mouseLoc.inside(rect(16, 17, 848, 657)))then
    case gTEprops.tlMatrix[msTile.locH][msTile.locV][gTEprops.workLayer].tp of
      "material":
        -- Figure out area size to remove from
        F = 0
        F1 = 0
        if checkCustomKeybind(#TileBigBrush, "F")  then
          F = -1
          F1 = 1
        else if checkCustomKeybind(#TileBiggerBrush, "V") then
          F = -2
          F1 = 2
        end if
        
        -- Actually remove
        forceAdaptTerrain = checkCustomKeybind(#TileForceGeometry, "G")
        repeat with F2 = F to F1 then
          repeat with F3 = F to F1 then
            if msTile.locH+F2 > 0 and msTile.locV+F3 > 0 and msTile.locH+F2 < gLOprops.size.loch+1 and msTile.locV+F3 < gLOprops.size.locv+1 then
              gTEprops.tlMatrix[msTile.locH+F2][msTile.locV+F3][gTEprops.workLayer].tp = "default"
              gTEprops.tlMatrix[msTile.locH+F2][msTile.locV+F3][gTEprops.workLayer].data = 0
              
              if forceAdaptTerrain then
                gLEProps.Matrix[msTile.locH+F2][msTile.locV+F3][gTEprops.workLayer][1] = 0
              end if
            end if
          end repeat
        end repeat
        
        -- Redraw
        TEdraw(rect(msTile+F,msTile+F1), gTEprops.workLayer)
        
        if(forceAdaptTerrain)then
          lvlEditDraw(rect(msTile-point(2,2), msTile+point(2,2)), gTEprops.workLayer)
        end if
        
      "tileHead":
        deleteTileTile(msTile, gTEprops.workLayer)
        -- TEdraw(rect(msTile+point(-5, -5),msTile+point(5,5)), 1)
        -- TEdraw(rect(msTile+point(-5, -5),msTile+point(5,5)), 2)
      "tileBody":
        dt = gTEprops.tlMatrix[msTile.locH][msTile.locV][gTEprops.workLayer].data
        if dt[1].locH > 0 and dt[1].locV > 0 and dt[1].locH < gLOprops.size.loch+1 and dt[1].locV < gLOprops.size.locv+1 then
          if gTEprops.tlMatrix[dt[1].locH][dt[1].locV][dt[2]].tp = "tileHead" then
            deleteTileTile(dt[1], dt[2])
          else
            gTEprops.tlMatrix[msTile.locH][msTile.locV][gTEprops.workLayer].tp = "default"
            gTEprops.tlMatrix[msTile.locH][msTile.locV][gTEprops.workLayer].data = 0
            TEdraw(rect(msTile,msTile), gTEprops.workLayer)
          end if
        else
          gTEprops.tlMatrix[msTile.locH][msTile.locV][gTEprops.workLayer].tp = "default"
          gTEprops.tlMatrix[msTile.locH][msTile.locV][gTEprops.workLayer].data = 0
          TEdraw(rect(msTile,msTile), gTEprops.workLayer)
        end if
        -- TEdraw(rect(dt[1]+point(-5, -5),dt[1]+point(5,5)), 1)
        -- TEdraw(rect(dt[1]+point(-5, -5),dt[1]+point(5,5)), 2)
    end case
  end if
end




on drawTilePreview()
  member("tilePreview").image = image(85*5, 85*5, 16)
  tl = gTiles[gTEprops.tmPos.locH].tls[gTEprops.tmPos.locV]--gTEprops.toolData
  --  offst = point(1,1)
  
  mdPnt = point(((tl.sz.locH*0.5)+0.4999).integer,((tl.sz.locV*0.5)+0.4999).integer)
  offst = point(3*5,3*5)-mdPnt
  
  if tl.specs2 <> void then
    n = 1
    repeat with q = 1 to tl.sz.locH then
      repeat with c = 1 to tl.sz.locV then
        if tl.specs2[n] <> -1 then
          member("tilePreview").image.copyPixels(member("prvw"&string(tl.specs2[n])).image, rect((q-1+offst.locH)*16, (c-1+offst.locV)*16, (q+offst.locH)*16, (c+offst.locV)*16)\
          +rect(5,0, 5, 0),  member("prvw"&string(tl.specs2[n])).image.rect, {#ink:36, #color:color(50, 50, 50)})
        end if
        n = n + 1
      end repeat
    end repeat
  end if
  
  
  n = 1
  repeat with q = 1 to tl.sz.locH then
    repeat with c = 1 to tl.sz.locV then
      if tl.specs[n] <> -1 then
        cl = color(150, 150, 150)
        --        if (q=mdPnt.locH)and(c=mdPnt.locV) then
        --          cl = color(255, 0, 0)
        --        end if
        member("tilePreview").image.copyPixels(member("prvw"&string(tl.specs[n])).image, rect((q-1+offst.locH)*16, (c-1+offst.locV)*16, (q+offst.locH)*16, (c+offst.locV)*16)\
        +rect(0,5, 0, 5),  member("prvw"&string(tl.specs[n])).image.rect, {#ink:36, #color:cl})
      end if
      n = n + 1
    end repeat
  end repeat
  
  -- Import the tile preview if needed
  tryAddToPreview(tl)
  
  -- Draw the tile preview at mouse position
  member("tileMouse").image = image(tl.sz.locH*16, tl.sz.locV*16, 16)
  if (tl.ptPos > 60000) and (getBoolConfig("More tile previews")) then
    drps = tl.ptPos - 60000
    member("tileMouse").image.copyPixels(member("previewTilesDR").image, member("tileMouse").image.rect, rect(drps, 0, drps+(tl.sz.locH*16), tl.sz.locV*16), {#ink:36, #color:color(150, 150, 150)})
  else
    member("tileMouse").image.copyPixels(member("previewTiles").image, member("tileMouse").image.rect, rect(tl.ptPos, 0, tl.ptPos+(tl.sz.locH*16), tl.sz.locV*16), {#ink:36, #color:color(150, 150, 150)})
  end if
  member("tileMouse").regPoint = point(0,0)
end




on isTilePositionLegal(msTile)
  
  rtrn = 1
  if (msTile.inside(rect(1,1,gLOprops.size.loch+1,gLOprops.size.locv+1)) = false) or (_mouse.mouseLoc.inside(rect(16, 17, 848, 657)) = false)then
    rtrn = 0
  end if
  if  gTEprops.toolType = "tile" then
    tl = gTiles[gTEprops.tmPos.locH].tls[gTEprops.tmPos.locV]--gTEprops.toolData
    mdPnt = point(((tl.sz.locH*0.5)+0.4999).integer,((tl.sz.locV*0.5)+0.4999).integer)
    strt = msTile-mdPnt+point(1,1)
    
    
    if (tl.specs2 <> void)and(gTEprops.worklayer<3) then
      n = 1
      repeat with q = strt.locH to strt.locH + tl.sz.locH-1 then
        repeat with c = strt.locV to strt.locV + tl.sz.locV-1 then
          if (tl.specs2[n] <> -1)and(point(q,c).inside(rect(1,1,gLOprops.size.loch+1,gLOprops.size.locv+1)))and (_mouse.mouseLoc.inside(rect(16, 17, 848, 657)))and(gTEprops.worklayer<3) then
            if (afaMvLvlEdit(point(q,c), gTEprops.worklayer+1) <> tl.specs2[n])or(["tileHead", "tileBody"].getPos(gTEprops.tlMatrix[q][c][gTEprops.worklayer+1].tp) > 0) then
              rtrn = 0
              --  put point(q,c) && afaMvLvlEdit(point(q,c), gTEprops.worklayer) && "2"
              exit repeat
            end if
          end if
          n = n + 1
        end repeat
        if rtrn = 0 then
          exit repeat
        end if
      end repeat
      
    end if
    
    
    if rtrn = 1 then
      n = 1
      repeat with q = strt.locH to strt.locH + tl.sz.locH-1 then
        repeat with c = strt.locV to strt.locV + tl.sz.locV-1 then
          --          if (tl.tp = "wvStruct") then
          --            varfa = afaMvLvlEdit(point(q, c), gTEprops.worklayer)
          --            if (varfa = 0) or (varfa = 7) or (varfa = 8) then
          --              rtrn = 0
          --            end if
          --          else 
          if (tl.specs[n] <> -1)and(point(q,c).inside(rect(1,1,gLOprops.size.loch+1,gLOprops.size.locv+1))) and (_mouse.mouseLoc.inside(rect(16, 17, 848, 657)))then
            if (afaMvLvlEdit(point(q,c), gTEprops.worklayer) <> tl.specs[n])or(["tileHead", "tileBody"].getPos(gTEprops.tlMatrix[q][c][gTEprops.workLayer].tp) > 0) then
              rtrn = 0
              -- put point(q,c) && afaMvLvlEdit(point(q,c), gTEprops.worklayer) && "1"
              exit repeat
            end if
          end if
          n = n + 1
        end repeat
        if rtrn = 0 then
          exit repeat
        end if
      end repeat
      
    end if
    
  end if
  sprite(88).color = color(255, 255*rtrn, 255*rtrn)
  sprite(13).color = color(255, 255*rtrn, 255*rtrn)
  
  return rtrn
end


--CAT CHANGE
on PickUpTile(msTile)
  if (msTile.inside(rect(1,1,gLOprops.size.loch+1,gLOprops.size.locv+1))) and (_mouse.mouseLoc.inside(rect(16, 17, 848, 657)))then
    case gTEprops.tlMatrix[msTile.locH][msTile.locV][gTEprops.workLayer].tp of
      "material":
        -- put string(gTEprops.tlMatrix[msTile.locH][msTile.locV][gTEprops.workLayer].data)
        repeat with nc = 1 to getLastMatCat()
          repeat with q = 1 to gTiles[nc].tls.count then
            -- put gTiles[1].tls[q].nm && gTEprops.tlMatrix[msTile.locH][msTile.locV][gTEprops.workLayer].data
            if(gTiles[nc].tls[q].nm = gTEprops.tlMatrix[msTile.locH][msTile.locV][gTEprops.workLayer].data) then
              gTEprops.tmPos = point(nc, q)
              updateTileMenu(point(0,0))
              exit repeat
            end if
          end repeat
        end repeat
      "tileHead":
        -- put " - Tile:" && gTEprops.tlMatrix[msTile.locH][msTile.locV][gTEprops.workLayer].data 
        gTEprops.tmPos = gTEprops.tlMatrix[msTile.locH][msTile.locV][gTEprops.workLayer].data[1]
        updateTileMenu(point(0,0))
      "tileBody":
        dt = gTEprops.tlMatrix[msTile.locH][msTile.locV][gTEprops.workLayer].data
        if gTEprops.tlMatrix[dt[1].locH][dt[1].locV][dt[2]].tp = "tileHead" then
          --   put " - Tile:" && gTEprops.tlMatrix[dt[1].locH][dt[1].locV][dt[2]].data
          gTEprops.tmPos = gTEprops.tlMatrix[dt[1].locH][dt[1].locV][dt[2]].data[1]
          updateTileMenu(point(0,0))
          --   else
          --  put " - Stray Tile Fragment"
        end if
    end case
  end if
end 

on getTileMidpointOffset(tl)
  return point(((tl.sz.locH*0.5)+0.4999).integer,((tl.sz.locV*0.5)+0.4999).integer)
end

on placeTile(plcTile, tmPos)
  if dontRunStuff() then
    return
  end if
  
  if(plcTile.locH < 1)or(plcTile.locV < 1)or(plcTile.locH > gTEprops.tlMatrix.count)or(plcTile.locV > gTEprops.tlMatrix[1].count)then
    return void
  end if
  
  forceAdaptTerrain = checkCustomKeybind(#TileForceGeometry, "G")
  
  tl = gTiles[tmPos.locH].tls[tmPos.locV]
  mdPnt = getTileMidpointOffset(tl)
  strt = plcTile-mdPnt+point(1,1)
  
  
  gTEprops.tlMatrix[plcTile.locH][plcTile.locV][gTEprops.workLayer].tp = "tileHead"
  gTEprops.tlMatrix[plcTile.locH][plcTile.locV][gTEprops.workLayer].data = [tmPos, tl.nm]--gTEprops.toolData
  if tl.nm = "Chain Holder" then
    gTEprops.tlMatrix[plcTile.locH][plcTile.locV][gTEprops.workLayer].data.add("NONE")
    gTEprops.specialEdit = ["Attatch Chain", plcTile, gTEprops.workLayer]
  end if
  
  
  TEdraw(rect(plcTile.locH,plcTile.locV,plcTile.locH,plcTile.locV), gTEprops.worklayer)
  
  if (tl.specs2 <> void)and(gTEprops.workLayer<3) then
    n = 1
    repeat with q = strt.locH to strt.locH + tl.sz.locH-1 then
      repeat with c = strt.locV to strt.locV + tl.sz.locV-1 then
        if (tl.specs2[n] <> -1)and(point(q,c).inside(rect(1,1,gLOprops.size.loch+1,gLOprops.size.locv+1))) and (_mouse.mouseLoc.inside(rect(16, 17, 848, 657)))then
          gTEprops.tlMatrix[q][c][gTEprops.workLayer+1].tp = "tileBody"
          gTEprops.tlMatrix[q][c][gTEprops.workLayer+1].data = [plcTile, gTEprops.worklayer]
          TEdraw(rect(q,c,q,c), gTEprops.worklayer+1)
          if(forceAdaptTerrain)then
            gLEProps.Matrix[q][c][gTEprops.workLayer+1][1] = tl.specs2[n]
          end if
        end if
        n = n + 1
      end repeat
    end repeat
  end if
  
  n = 1
  repeat with q = strt.locH to strt.locH + tl.sz.locH-1 then
    repeat with c = strt.locV to strt.locV + tl.sz.locV-1 then
      if (tl.specs[n] <> -1)and(point(q,c).inside(rect(1,1,gLOprops.size.loch+1,gLOprops.size.locv+1))) and (_mouse.mouseLoc.inside(rect(16, 17, 848, 657)))then
        if(point(q,c)<>plcTile)then
          gTEprops.tlMatrix[q][c][gTEprops.workLayer].tp = "tileBody"
          gTEprops.tlMatrix[q][c][gTEprops.workLayer].data = [plcTile, gTEprops.worklayer]
          TEdraw(rect(q,c,q,c), gTEprops.worklayer)
        end if
        if(forceAdaptTerrain)then
          gLEProps.Matrix[q][c][gTEprops.workLayer][1] = tl.specs[n]
        end if
      end if
      n = n + 1
    end repeat
  end repeat
  
  if(forceAdaptTerrain)then
    lvlEditDraw(rect(strt, strt+tl.sz), 1)
    lvlEditDraw(rect(strt, strt+tl.sz), 2)
    lvlEditDraw(rect(strt, strt+tl.sz), 3)
  end if
  
end


on deleteTileTile(ps, lr)
  tl = gTEprops.tlMatrix[ps.locH][ps.locV][lr].data[1]
  tl = gTiles[tl.locH].tls[tl.locV]
  mdPnt = point(((tl.sz.locH*0.5)+0.4999).integer,((tl.sz.locV*0.5)+0.4999).integer)
  strt = ps-mdPnt+point(1,1)
  ramp = tl.tags.getPos("ramp") > 0
  forceAdaptTerrain = checkCustomKeybind(#TileForceGeometry, "G")
  
  if (tl.specs2 <> 0)and(lr<3) then
    n = 1
    repeat with q = strt.locH to strt.locH + tl.sz.locH-1 then
      repeat with c = strt.locV to strt.locV + tl.sz.locV-1 then
        if (tl.specs2[n] <> -1 or ramp)and(point(q,c).inside(rect(1,1,gLOprops.size.loch+1,gLOprops.size.locv+1)))and (_mouse.mouseLoc.inside(rect(16, 17, 848, 657)))then
          gTEprops.tlMatrix[q][c][lr+1].tp = "default"
          gTEprops.tlMatrix[q][c][lr+1].data = 0
          
          rct = rect((q-1)*16, (c-1)*16, q*16, c*16) - rect(gLEprops.camPos*16, gLEprops.camPos*16)
          member("TEimg"&string(2)).image.copyPixels(member("pxl").image, rct, member("pxl").image.rect, {color:color(255, 255, 255)})
          
          if forceAdaptTerrain then
            gLEProps.Matrix[q][c][lr+1][1] = 0
          end if
        end if
        n = n + 1
      end repeat
    end repeat
  end if
  
  n = 1
  repeat with q = strt.locH to strt.locH + tl.sz.locH-1 then
    repeat with c = strt.locV to strt.locV + tl.sz.locV-1 then
      if (tl.specs[n] <> -1 or ramp) and(point(q,c).inside(rect(1,1,gLOprops.size.loch+1,gLOprops.size.locv+1)))and (_mouse.mouseLoc.inside(rect(16, 17, 848, 657)))then
        gTEprops.tlMatrix[q][c][lr].tp = "default"
        gTEprops.tlMatrix[q][c][lr].data = 0
        
        rct = rect((q-1)*16, (c-1)*16, q*16, c*16) - rect(gLEprops.camPos*16, gLEprops.camPos*16)
        member("TEimg"&string(lr)).image.copyPixels(member("pxl").image, rct, member("pxl").image.rect, {color:color(255, 255, 255)})
        
        if forceAdaptTerrain then
          gLEProps.Matrix[q][c][lr][1] = 0
        end if
      end if
      n = n + 1
    end repeat
  end repeat
  
  -- Redraw geometry
  if(forceAdaptTerrain)then
    lvlEditDraw(rect(strt, strt+tl.sz), 1)
    lvlEditDraw(rect(strt, strt+tl.sz), 2)
    lvlEditDraw(rect(strt, strt+tl.sz), 3)
  end if
end


on specialAction(tl)
  --gTEprops.specialEdit
  if(_mouse.mouseLoc.inside(rect(16, 17, 848, 657)))then
    case gTEprops.specialEdit[1] of
      "Attatch Chain":
        gTEprops.tlMatrix[gTEprops.specialEdit[2].locH][gTEprops.specialEdit[2].locV][gTEprops.specialEdit[3]].data[3] = tl--.add(tl)
        gTEprops.specialEdit = 0
    end case
  end if
end

on changeLayer()
  if gTEprops.workLayer = 2 then
    --gTEprops.workLayer = 2
    sprite(1).blend = 10
    sprite(2).blend = 10
    
    sprite(3).blend = 90
    sprite(4).blend = 100
    sprite(5).blend = 70
    sprite(6).blend = 0
  else if gTEprops.workLayer = 1 then
    -- gTEprops.workLayer = 1
    sprite(1).blend = 10
    sprite(2).blend = 10
    sprite(3).blend = 60
    sprite(4).blend = 10
    sprite(5).blend = 70
    sprite(6).blend = 100
  else
    sprite(1).blend = 100
    sprite(2).blend = 100
    sprite(3).blend = 60
    sprite(4).blend = 10
    sprite(5).blend = 60
    sprite(6).blend = 10
  end if
  ChangeLayerText()
  
  pos = 2 - gTEprops.workLayer
  sprite(1).loc = point(432, 336) + point(pos+1,-pos-1)*3
  sprite(2).loc = point(432, 336) + point(pos+1,-pos-1)*3
  sprite(3).loc = point(432, 336) + point(pos,-pos)*3
  sprite(4).loc = point(432, 336) + point(pos,-pos)*3
  sprite(5).loc = point(432, 336) + point(pos-1,-pos+1)*3
  sprite(6).loc = point(432, 336) + point(pos-1,-pos+1)*3
end

on ChangeLayerText()
  txt = "Work Layer:" && string(gTEprops.workLayer)
  tl = gTiles[gTEprops.tmPos.locH].tls[gTEprops.tmPos.locV]
  if tl.findPos(#author) then
    txt = txt & RETURN & "Author:" && tl[#author]
  end if
  member("layerText").text = txt
end


on SpecialRectPlacement(rct)
  case gTiles[gTEprops.tmPos.locH].tls[gTEprops.tmPos.locV].nm of
    "Rect Clear":
      repeat with px = rct.left  to rct.right  then
        repeat with py = rct.top  to rct.bottom  then
          deleteTile(point(px, py))
        end repeat
      end repeat
      
      --CAT CHANGE
    "SH pattern box", "SH grate box", "Alt Grate Box":
      inum = getFirstTileCat()
      repeat with q = getFirstTileCat() to gTiles.count
        if(gTiles[q].nm = "SU patterns")then
          inum = q
          exit repeat
        end if
      end repeat
      placeTile(point(rct.left, rct.top), point(inum, 5))
      placeTile(point(rct.right, rct.top), point(inum, 6) )
      placeTile(point(rct.right, rct.bottom), point(inum, 7)  )
      placeTile(point(rct.left, rct.bottom), point(inum, 8)   )
      repeat with px = rct.left + 1 to rct.right -1 then
        placeTile(point(px, rct.top), point(inum, 1)) 
        placeTile(point(px, rct.bottom), point(inum, 3))  
      end repeat
      repeat with py = rct.top + 1 to rct.bottom -1 then
        placeTile(point(rct.left, py), point(inum, 4)) 
        placeTile(point(rct.right, py), point(inum, 2))  
      end repeat
      
      lookForTileCat = "SU patterns"
      stringLength = 10
      if gTiles[gTEprops.tmPos.locH].tls[gTEprops.tmPos.locV].nm = "SH grate box" then
        lookForTileCat = "SU grates"
        stringLength = 8
      else if gTiles[gTEprops.tmPos.locH].tls[gTEprops.tmPos.locV].nm = "Alt Grate Box" then
        lookForTileCat = "LB Alt Grates"
        stringLength = 9
      end if 
      inum = getFirstTileCat()
      repeat with q = getFirstTileCat() to gTiles.count then
        if(gTiles[q].nm = lookForTileCat)then
          inum = q
          exit repeat
        end if
      end repeat
      
      patterns = []
      patterns.add([#tiles:["A"], #upper:"dense", #lower:"dense", #tall:1, #freq:5])
      patterns.add([#tiles:["B1"], #upper:"espaced", #lower:"dense", #tall:1, #freq:5])
      patterns.add([#tiles:["B2"], #upper:"dense", #lower:"espaced", #tall:1, #freq:5])
      patterns.add([#tiles:["B3"], #upper:"ospaced", #lower:"dense", #tall:1, #freq:5])
      patterns.add([#tiles:["B4"], #upper:"dense", #lower:"ospaced", #tall:1, #freq:5])
      patterns.add([#tiles:["C1"], #upper:"espaced", #lower:"espaced", #tall:1, #freq:5])
      patterns.add([#tiles:["C2"], #upper:"ospaced", #lower:"ospaced", #tall:1, #freq:5])
      patterns.add([#tiles:["E1"], #upper:"ospaced", #lower:"espaced", #tall:1, #freq:5])
      patterns.add([#tiles:["E2"], #upper:"espaced", #lower:"ospaced", #tall:1, #freq:5])
      patterns.add([#tiles:["F1"], #upper:"dense", #lower:"dense", #tall:2, #freq:1])
      patterns.add([#tiles:["F2"], #upper:"dense", #lower:"dense", #tall:2, #freq:1])
      patterns.add([#tiles:["F1", "F2"], #upper:"dense", #lower:"dense", #tall:2, #freq:5])
      patterns.add([#tiles:["F3"], #upper:"dense", #lower:"dense", #tall:2, #freq:5])
      patterns.add([#tiles:["F4"], #upper:"dense", #lower:"dense", #tall:2, #freq:5])
      patterns.add([#tiles:["G1", "G2"], #upper:"dense", #lower:"ospaced", #tall:2, #freq:5])
      patterns.add([#tiles:["I"], #upper:"espaced", #lower:"dense", #tall:1, #freq:4])
      patterns.add([#tiles:["J1"], #upper:"ospaced", #lower:"ospaced", #tall:2, #freq:1])
      patterns.add([#tiles:["J2"], #upper:"ospaced", #lower:"ospaced", #tall:2, #freq:1])
      patterns.add([#tiles:["J1", "J2"], #upper:"ospaced", #lower:"ospaced", #tall:2, #freq:2])
      patterns.add([#tiles:["J3"], #upper:"espaced", #lower:"espaced", #tall:2, #freq:1])
      patterns.add([#tiles:["J4"], #upper:"espaced", #lower:"espaced", #tall:2, #freq:1])
      patterns.add([#tiles:["J3", "J4"], #upper:"espaced", #lower:"espaced", #tall:2, #freq:2])
      patterns.add([#tiles:["B1", "I"], #upper:"espaced", #lower:"dense", #tall:1, #freq:2])
      
      repeat with q = 1 to patterns.count then
        repeat with a = 1 to patterns[q].tiles.count then
          repeat with b = 1 to gTiles[inum].tls.count then
            if(patterns[q].tiles[a] = chars(gTiles[inum].tls[b].nm, stringLength, gTiles[inum].tls[b].nm.length))then
              patterns[q].tiles[a] = b
            end if
          end repeat
        end repeat
      end repeat
      
      py = rct.top + 1
      currentPattern = patterns[random(patterns.count)]
      
      repeat while py < rct.bottom then
        possiblePatterns = []
        repeat with q = 1 to patterns.count then
          if(patterns[q].upper = currentPattern.lower)and(py + patterns[q].tall < rct.bottom+1)then
            repeat with a = 1 to patterns[q].freq then
              possiblePatterns.add(q)
            end repeat
          end if
        end repeat
        
        currentPattern = patterns[possiblePatterns[random(possiblePatterns.count)]]
        tl = random(currentPattern.tiles.count)
        
        repeat with px = rct.left + 1 to rct.right -1 then
          tl = tl + 1
          if(tl > currentPattern.tiles.count)then
            tl = 1
          end if
          placeTile(point(px, py), point(inum, currentPattern.tiles[tl])) 
        end repeat
        
        py = py + currentPattern.tall
      end repeat
      
    "Ventbox Rect", "Ventbox Perforated Rect":
      -- Edge case
      if (rct.right - rct.left < 4) or (rct.bottom - rct.top < 4) then
        return
      end if
      
      -- Find the tiles
      tileList = ["Ventbox", "Ventbox N", "Ventbox E", "Ventbox S", "Ventbox W", "Ventbox NW", "Ventbox NE", "Ventbox SE", "Ventbox SW"]
      if gTiles[gTEprops.tmPos.locH].tls[gTEprops.tmPos.locV].nm = "Ventbox Perforated Rect" then
        tileList = ["Ventbox Perforated", "Ventbox Perforated N", "Ventbox Perforated E", "Ventbox Perforated S", "Ventbox Perforated W", "Ventbox Perforated NW", "Ventbox Perforated NE", "Ventbox Perforated SE", "Ventbox Perforated SW"]
      end if
      found = 0
      tilePositions = [VOID, VOID, VOID, VOID, VOID, VOID, VOID, VOID, VOID]
      repeat with q = getFirstTileCat() to gTiles.count
        repeat with a = 1 to gTiles[q].tls.count
          thisPos = tileList.getPos(gTiles[q].tls[a].nm)
          if thisPos > 0 then
            found = found + 1
            tilePositions[thisPos] = point(q,a)
            if found = 9 then exit repeat
          end if
        end repeat
        if found = 9 then exit repeat
      end repeat
      if found <> 9 then return
      
      -- Place the corners
      placeTile(point(rct.left, rct.bottom-1), tilePositions[9])
      placeTile(point(rct.right-1, rct.bottom-1), tilePositions[8])
      placeTile(point(rct.right-1, rct.top), tilePositions[7])
      placeTile(point(rct.left, rct.top), tilePositions[6])
      
      -- Place the walls
      repeat with a = rct.left + 2 to rct.right - 2 then
        placeTile(point(a, rct.bottom-1), tilePositions[4])
        placeTile(point(a, rct.top), tilePositions[2])
      end repeat
      repeat with b = rct.top + 2 to rct.bottom - 2 then
        placeTile(point(rct.left, b), tilePositions[5])
        placeTile(point(rct.right-1, b), tilePositions[3])
      end repeat
      
      -- Place the innards
      repeat with a = rct.left + 2 to rct.right - 2 then
        repeat with b = rct.top + 2 to rct.bottom - 2 then
          placeTile(point(a, b), tilePositions[1])
        end repeat
      end repeat
      
    "Random machine rect":
      -- Find missing machines category
      missingMachineList = ["Small Machine Slope NE", "Small Machine Slope NW", "Small Machine Slope SW", "Small Machine Slope SE", "Small Machine Floor"]
      repeat with missingMachineTileCat = getFirstTileCat() to gTiles.count then
        if(gTiles[missingMachineTileCat].nm = "LB Missing Machine")then
          exit repeat
        end if
      end repeat
      
      -- Fill slopes and floors and cache solid tiles
      tls = []
      repeat with a = rct.left to rct.right then
        repeat with b = rct.top to rct.bottom then
          case (gLEProps.Matrix[a][b][gTEprops.workLayer][1]) of
            2:
              placeTile(point(a,b), point(missingMachineTileCat, 1))
            3:
              placeTile(point(a,b), point(missingMachineTileCat, 2))
            4:
              placeTile(point(a,b), point(missingMachineTileCat, 4))
            5:
              placeTile(point(a,b), point(missingMachineTileCat, 3))
            6:
              placeTile(point(a,b), point(missingMachineTileCat, 5))
            1:
              case (gTEprops.tlMatrix[a][b][gTEprops.workLayer].tp) of
                "tileHead", "tileBody":
                  -- do nothing
                otherwise:
                  tls.add(point(a,b))
              end case
          end case
        end repeat
      end repeat
      tls.sort()
      cnt = tls.count
      
      -- Get all valid random machines we can place
      randomMachines = []
      repeat with w = 1 to 8 then
        lst = []
        repeat with h = 1 to 8 then
          lst.add([])
        end repeat
        randomMachines.add(lst)
      end repeat
      
      global RandomMachines_grabTiles, RandomMachines_forbidden
      repeat with a = 1 to RandomMachines_grabTiles.count then
        repeat with q = 1 to gTiles.count then
          if(gTiles.getAt(q).nm = RandomMachines_grabTiles.getAt(a))then
            repeat with t = 1 to gTiles.getAt(q).tls.count then
              theTile = gTiles.getAt(q).tls.getAt(t)
              if(theTile.sz.locH <= 8)and(theTile.sz.locV <= 8)and(theTile.specs2 = 0)and(RandomMachines_forbidden.getPos(theTile.nm) = 0)then
                randomMachines.getAt(theTile.sz.locH).getAt(theTile.sz.locV).add(point(q,t))
              end if
            end repeat
          end if
        end repeat
      end repeat
      
      -- Actually place things
      delL = [:]
      delL.sort()
      tlsBlock = [:]
      tlsBlock.sort()
      repeat with tl in tls then
        tlsBlock.setaProp(tl, 1)
      end repeat
      repeat with tl in tls then
        if delL.findPos(tl)=void then
          
          randomOrderList = []
          repeat with w = 1 to randomMachines.count then
            randomMachinesW = randomMachines.getAt(w)
            repeat with h = 1 to randomMachinesW.count then
              randomMachinesH = randomMachinesW.getAt(h)
              repeat with t = 1 to randomMachinesH.count then
                randomOrderList.add([random(1000), randomMachinesH.getAt(t)])
              end repeat
            end repeat
          end repeat
          randomOrderList.sort()
          
          repeat with q = 1 to randomOrderList.count then
            testTileIndex = randomOrderList.getAt(q).getAt(2)
            testTile = gTiles[testTileIndex.locH].tls[testTileIndex.locV]
            
            legalToPlace = true
            repeat with a = 0 to testTile.sz.locH-1 then
              repeat with b = 0 to testTile.sz.locV-1 then
                testPoint = tl + point(a,b)
                spec = testTile.specs[(b+1) + (a*testTile.sz.locV)]
                
                if(tlsBlock.findPos(testPoint)=void)then
                  legalToPlace = false
                  exit repeat
                end if
                
                if(spec > -1)then
                  if(delL.findPos(testPoint)<>void)then
                    legalToPlace = false
                    exit repeat
                  end if
                  if(gLEProps.Matrix[testPoint.locH][testPoint.locV][gTEprops.workLayer][1] <> spec)then
                    legalToPlace = false
                    exit repeat
                  end if
                end if
              end repeat
              if(legalToPlace = false)then
                exit repeat
              end if
            end repeat
            
            if(legalToPlace)then
              rootPos = tl + point(((testTile.sz.locH.float/2.0) + 0.4999).integer-1, ((testTile.sz.locV.float/2.0) + 0.4999).integer-1)
              placeTile(rootPos, testTileIndex)
              repeat with a = 0 to testTile.sz.locH-1 then
                repeat with b = 0 to testTile.sz.locV-1 then
                  spec = testTile.specs[(b+1) + (a*testTile.sz.locV)]
                  if(spec > -1)then
                    delL.setAProp(tl+point(a,b), 1)
                  end if
                end repeat
              end repeat
              exit repeat
            end if
          end repeat
        end if
        
      end repeat
      
    "Anything goes":
      -- Fill slopes and floors and cache solid tiles
      tls = []
      repeat with a = rct.left to rct.right then
        repeat with b = rct.top to rct.bottom then
          if gLEProps.Matrix[a][b][gTEprops.workLayer][1] > 0 then
            case (gTEprops.tlMatrix[a][b][gTEprops.workLayer].tp) of
              "tileHead", "tileBody":
                -- do nothing
              otherwise:
                tls.add(point(a,b))
            end case
          end if
        end repeat
      end repeat
      tls.sort()
      cnt = tls.count
      
      -- Get all valid random machines we can place (though we limit tile size a bit)
      randomTiles = []
      maxSize = 40 -- despite being limited, this is still an extremely generous amount
      maxSize = min(maxSize, max(rct.width, rct.height))
      repeat with w = 1 to maxSize then
        lst = []
        repeat with h = 1 to maxSize then
          lst.add([])
        end repeat
        randomTiles.add(lst)
      end repeat
      
      repeat with q = getFirstTileCat() to gTiles.count then
        repeat with t = 1 to gTiles.getAt(q).tls.count then
          theTile = gTiles.getAt(q).tls.getAt(t)
          if (theTile.sz.locH <= maxSize) and (theTile.sz.locV <= maxSize) and (theTile.specs2 = 0) then
            foundSolid = 0
            -- check that there is at least one solid tile
            repeat with a = 1 to theTile.specs.count then
              if theTile.specs[a] > 0 then
                foundSolid = 1
                exit repeat
              end if
            end repeat
            if foundSolid then
              randomTiles.getAt(theTile.sz.locH).getAt(theTile.sz.locV).add(point(q,t))
            end if
          end if
        end repeat
      end repeat
      
      -- Actually place things
      delL = [:]
      delL.sort()
      tlsBlock = [:]
      tlsBlock.sort()
      repeat with tl in tls then
        tlsBlock.setaProp(tl, 1)
      end repeat
      repeat with tl in tls then
        if delL.findPos(tl)=void then
          
          randomOrderList = []
          repeat with w = 1 to randomTiles.count then
            randomTilesW = randomTiles.getAt(w)
            repeat with h = 1 to randomTilesW.count then
              randomTilesH = randomTilesW.getAt(h)
              repeat with t = 1 to randomTilesH.count then
                randomOrderList.add([random(32767), randomTilesH.getAt(t)])
              end repeat
            end repeat
          end repeat
          randomOrderList.sort()
          
          repeat with q = 1 to randomOrderList.count then
            testTileIndex = randomOrderList.getAt(q).getAt(2)
            testTile = gTiles[testTileIndex.locH].tls[testTileIndex.locV]
            
            legalToPlace = true
            repeat with a = 0 to testTile.sz.locH-1 then
              repeat with b = 0 to testTile.sz.locV-1 then
                testPoint = tl + point(a,b)
                spec = testTile.specs[(b+1) + (a*testTile.sz.locV)]
                
                if(tlsBlock.findPos(testPoint)=void)then
                  legalToPlace = false
                  exit repeat
                end if
                
                if(spec > -1)then
                  if(delL.findPos(testPoint)<>void)then
                    legalToPlace = false
                    exit repeat
                  end if
                  if(gLEProps.Matrix[testPoint.locH][testPoint.locV][gTEprops.workLayer][1] <> spec)then
                    legalToPlace = false
                    exit repeat
                  end if
                end if
              end repeat
              if(legalToPlace = false)then
                exit repeat
              end if
            end repeat
            
            if(legalToPlace)then
              rootPos = tl + point(((testTile.sz.locH.float/2.0) + 0.4999).integer-1, ((testTile.sz.locV.float/2.0) + 0.4999).integer-1)
              placeTile(rootPos, testTileIndex)
              repeat with a = 0 to testTile.sz.locH-1 then
                repeat with b = 0 to testTile.sz.locV-1 then
                  spec = testTile.specs[(b+1) + (a*testTile.sz.locV)]
                  if(spec > -1)then
                    delL.setAProp(tl+point(a,b), 1)
                  end if
                end repeat
              end repeat
              exit repeat
            end if
          end repeat
        end if
        
      end repeat
      
    otherwise:
      -- Custom init rect-type autotilers, like Ventbox Rect
      autotileDef = gTiles[gTEprops.tmPos.locH].tls[gTEprops.tmPos.locV]
      
      -- Find the tiles
      tileList = [autotileDef.middle, autotileDef.top, autotileDef.right, autotileDef.bottom, autotileDef.left, \
                  autotileDef.topLeft, autotileDef.topRight, autotileDef.bottomRight, autotileDef.bottomLeft]
      found = 0
      tileLocs = [VOID, VOID, VOID, VOID, VOID, VOID, VOID, VOID, VOID]
      tileDefs = [VOID, VOID, VOID, VOID, VOID, VOID, VOID, VOID, VOID]
      tileMids = [VOID, VOID, VOID, VOID, VOID, VOID, VOID, VOID, VOID]
      repeat with q = getFirstTileCat() to gTiles.count
        repeat with a = 1 to gTiles[q].tls.count
          repeat with b = 1 to 9 then
            if tileList[b] = gTiles[q].tls[a].nm then
              found = found + 1
              tileLocs[b] = point(q,a)
              tileDefs[b] = gTiles[q].tls[a]
              tileMids[b] = getTileMidpointOffset(gTiles[q].tls[a]) - point(1,1)
              if found = 9 then exit repeat
            end if
          end repeat
          if found = 9 then exit repeat
        end repeat
        if found = 9 then exit repeat
      end repeat
      if found <> 9 then
        errorString = "Could not find all tiles in autotiler! Found " & found & " of 9. (Missing: "
        placeCommas = false
        repeat with q = 1 to 9 then
          if tileLocs[q] = VOID then
            if placeCommas then
              errorString = errorString & ", " & tileList[q]
            else
              errorString = errorString & tileList[q]
            end if
            placeCommas = true
          end if
        end repeat
        errorString = errorString & ")"
        writeException("Custom Rect Autotiler", errorString)
        return
      end if
      
      -- Handle edge cases
      if (rct.right - rct.left < tileDefs[6].sz.locH + tileDefs[7].sz.locH) or (rct.bottom - rct.top < tileDefs[6].sz.locV + tileDefs[9].sz.locV) then
        -- Too small of a rectangle
        writeMessage("Custom Rect Autotiler : rectangle too small")
        return
      end if
      
      -- Placement time! I place this in an order so as to preserve tile bodies in a good way
      
      -- Place the innards
      cntrX = 0
      repeat with a = rct.left + tileDefs[6].sz.locH to rct.right - tileDefs[8].sz.locH then
        if cntrX = 0 then
          cntrY = 0
          repeat with b = rct.top + tileDefs[6].sz.locV to rct.bottom - tileDefs[8].sz.locV then
            if cntrY = 0 then
              placeTile(point(a, b) + tileMids[1], tileLocs[1])
            end if
            cntrY = cntrY + 1
            if cntrY >= tileDefs[1].sz.locV then cntrY = 0
          end repeat
        end if
        cntrX = cntrX + 1
        if cntrX >= tileDefs[1].sz.locH then cntrX = 0
      end repeat
      
      -- Place the top and bottom walls
      cntr = 0
      repeat with a = rct.left + tileDefs[6].sz.locH to rct.right - tileDefs[7].sz.locH then
        if cntr = 0 then
          placeTile(point(a, rct.top) + tileMids[2], tileLocs[2]) -- top
          placeTile(point(a, rct.bottom-tileDefs[4].sz.locV+1) + tileMids[4], tileLocs[4]) -- bottom
        end if
        cntr = cntr + 1
        if cntr >= tileDefs[2].sz.locH then cntr = 0
      end repeat
      
      -- Place the left and right walls
      cntr = 0
      repeat with b = rct.top + tileDefs[6].sz.locV to rct.bottom - tileDefs[9].sz.locV then
        if cntr = 0 then
          placeTile(point(rct.left, b) + tileMids[5], tileLocs[5]) -- left
          placeTile(point(rct.right-tileDefs[3].sz.locH+1, b) + tileMids[3], tileLocs[3]) -- right
        end if
        cntr = cntr + 1
        if cntr >= tileDefs[3].sz.locV then cntr = 0
      end repeat
      
      -- Place the corners
      placeTile(point(rct.left, rct.top) + tileMids[6], tileLocs[6]) -- top left
      placeTile(point(rct.right-tileDefs[7].sz.locH+1, rct.top) + tileMids[7], tileLocs[7]) -- top right
      placeTile(point(rct.right-tileDefs[8].sz.locH+1, rct.bottom-tileDefs[8].sz.locV+1) + tileMids[8], tileLocs[8]) -- bottom right
      placeTile(point(rct.left, rct.bottom-tileDefs[9].sz.locV+1) + tileMids[9], tileLocs[9]) -- bottom left
  end case
end 







































