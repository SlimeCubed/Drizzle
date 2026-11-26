global gTEprops, gLEProps, gTiles, gEEProps, gEffects, lstSpace, gLOprops, gEnvEditorProps, gDirectionKeys, gPEProps, gProps, showControls, gCustomEffects, gFSLastTm, gFSFlag


on exitFrame me
  if (showControls) then
    sprite(241).blend = 100
  else
    sprite(241).blend = 0
  end if
  
  if dontRunStuff() then
    lstSpace = 0
    gFSLastTm = _system.milliseconds
    go the frame
    return
  end if
  
  gFSFlag = false
  if _system.milliseconds - gFSLastTm > 10 then
    gFSFlag = true
    gFSLastTm = _system.milliseconds
  end if
  
  
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
          drawShortCutsImg(rect(1,1,gLOprops.size.loch,gLOprops.size.locv), 16)
          if not getBoolConfig("Hide props in effects") then
            sprite(238).visibility = true
            sprite(239).visibility = true
            script("propEditor").renderPropsImage()
          else
            sprite(238).visibility = false
            sprite(239).visibility = false
          end if
          me.drawEfMtrx(gEEprops.editEffect) 
        end if
        gDirectionKeys[q] = gDirectionKeys[q] + 1
      end if
    else
      gDirectionKeys[q] = 0
    end if
  end repeat
  
  if gEnvEditorProps.waterLevel = -1 then
    sprite(220).rect = rect(0,0,0,0)
  else
    rct = rect(0, gLOprops.size.locv-gEnvEditorProps.waterLevel-gLOProps.extraTiles[4], gLOprops.size.loch, gLOprops.size.locv) - rect(gLEProps.camPos, gLEProps.camPos)
    sprite(220).rect = ((rct.intersect(rect(0,0,52,40))+rect(1, 1, 1, 1))*rect(16,16,16,16))+rect(0, -8, 0, 0)
  end if
  
  msTile: point = (_mouse.mouseLoc/point(16.0, 16.0))-point(0.4999, 0.4999)
  msTile = point(msTile.loch.integer, msTile.locV.integer) 
  msTile = msTile + gLEProps.camPos
  
  actn: number = 0
  actn2: number = 0
  
  gEEprops.keys.m1 = _mouse.mouseDown
  if (gEEprops.keys.m1)and(gEEprops.lastKeys.m1=0) then
    actn = 1
  end if
  gEEprops.lastKeys.m1 = gEEprops.keys.m1
  gEEprops.keys.m2 = _mouse.rightmouseDown
  if (gEEprops.keys.m2)and(gEEprops.lastKeys.m2=0) then
    actn2 = 1
  end if
  gEEprops.lastKeys.m2 = gEEprops.keys.m2
  if msTile <> gEEprops.lstMsPs then
    actn = gEEprops.keys.m1
    actn2 = gEEprops.keys.m2 
  end if
  gEEprops.lstMsPs = msTile
  if actn then
    me.useBrush(msTile, 1)
  end if
  if actn2 then
    me.useBrush(msTile, -1)
  end if
  
  if me.checkKey("N") then
    me.initMode("createNew")
  end if
  if gEEprops.editEffect <> void then
    if me.checkKey("E") then
      me.initMode("chooseEffect")
    end if
  end if
  
  case gEEprops.mode of 
    "createNew":
      if me.checkKey("W") then
        me.updateEffectsMenu(point(0, -1))
      end if
      if me.checkKey("S") then
        me.updateEffectsMenu(point(0, 1))
      end if
      if me.checkKey("A") then
        me.updateEffectsMenu(point(-1, 0))
      end if
      if me.checkKey("D") then
        me.updateEffectsMenu(point(1, 0))
      end if
      
      if checkCustomKeybind(#EffectSelect, " ") then
        me.newEffect()
        gEEprops.editEffect = gEEprops.effects.count
        gEEprops.selectEditEffect = gEEprops.effects.count
        me.initMode("editEffect")
      end if
      
      sprite(244).rect = rect(-100, -100, -100, -100)
    "chooseEffect":
      if me.checkKey("W") then
        me.updateEffectsL(-1)
      end if
      if me.checkKey("S") then
        me.updateEffectsL(1)
      end if
      if gEEprops.editEffect <> void then
        if (checkCustomKeybind(#EffectSelect, " "))and(lstSpace=0)then
          gEEprops.editEffect = gEEprops.selectEditEffect
          me.initMode("editEffect")
          me.updateEffectsL(0)
        end if
      end if
      sprite(244).rect = rect(-100, -100, -100, -100)
    "editEffect":
      if me.checkKey("r") then
        gEEprops.brushSize = restrict(gEEprops.brushSize + 1, 1, 10)
      end if
      if me.checkKey("f") then
        gEEprops.brushSize = restrict(gEEprops.brushSize - 1, 1, 10)
      end if
      
      if me.checkKey("W") then
        me.updateEditEffect(point(0, -1))
      end if
      if me.checkKey("S") then
        me.updateEditEffect(point(0, 1))
      end if
      if me.checkKey("A") then
        me.updateEditEffect(point(-1, 0))
      end if
      if me.checkKey("D") then
        me.updateEditEffect(point(1, 0))
      end if
      
      if gEEprops.effects[gEEprops.editEffect] <> void then
        if gEEprops.effects[gEEprops.editEffect].options[gEEprops.emPos.locV][1] = "seed" then
          me.changeOption()
        else if gEEprops.effects[gEEprops.editEffect].options[gEEprops.emPos.locV][1] = "Leaf Density" then
          me.changeOption()
        else
          if (checkCustomKeybind(#EffectSelect, " "))and(lstSpace=0)then
            me.changeOption()
          end if
        end if
      end if
      
      
      
      
      sizeAdd = rect(-gEEprops.brushSize+1, -gEEprops.brushSize+1, gEEprops.brushSize-1, gEEprops.brushSize-1) * rect(16,16,16,16)
      --   put sizeAdd
      sprite(244).rect = (rect(msTile-gLEProps.camPos, msTile-gLEProps.camPos) * rect(16,16,16,16)) + rect(0, 0, 16, 16) + sizeAdd
      
  end case
  type sizeAdd: rect
  
  sprite(243).rect = (rect(msTile-gLEProps.camPos, msTile-gLEProps.camPos) * rect(16,16,16,16)) + rect(0, 0, 16, 16)
  
  --put msTile
  
  lstSpace = checkCustomKeybind(#EffectSelect, " ")
  script("levelOverview").goToEditor()
  go the frame
end


on getDirection me, q
  -- check order: left, up, right, down
  k = [#MoveLeft, #MoveUp, #MoveRight, #MoveDown][q]
  orig = [86, 91, 88, 84][q]
  return checkCustomKeybind(k, orig)
end


on checkKey me, key
  type return: number
  rtrn: number = 0
  rtrn = 0
  
  kb = VOID
  hasFastScroll = false
  fastScrollRate = 6
  case key of
    "W":
      kb = #EffectSelectUp
      hasFastScroll = true
    "S":
      kb = #EffectSelectDown
      hasFastScroll = true
    "A":
      kb = #EffectCategoryPrev
      hasFastScroll = true
      fastScrollRate = 9
    "D":
      kb = #EffectCategoryNext
      hasFastScroll = true
      fastScrollRate = 9
    "N":
      kb = #EffectModeNew
    "E":
      kb = #EffectModeEdit
    "r":
      kb = #EffectBrushBigger
      hasFastScroll = true
      fastScrollRate = 12
    "f":
      kb = #EffectBrushSmaller
      hasFastScroll = true
      fastScrollRate = 12
  end case
  
  rslt = checkCustomKeybind(kb, key) and not dontRunStuff()
  if hasFastScroll then
    -- fast scroll
    if rslt then
      gEEprops.keys[symbol(key)] = gEEprops.keys[symbol(key)] + gFSFlag
    else
      gEEprops.keys[symbol(key)] = 0
    end if
    
    if (gEEprops.keys[symbol(key)] = 1) or ((gEEprops.keys[symbol(key)] > 20) and ((gEEprops.keys[symbol(key)] mod fastScrollRate) = 0)) then
      rtrn = gFSFlag
    end if
  else
    -- no fast scroll
    gEEprops.keys[symbol(key)] = rslt
    if (gEEprops.keys[symbol(key)])and(gEEprops.lastKeys[symbol(key)]=0) then
      rtrn = 1
    end if
  end if
  gEEprops.lastKeys[symbol(key)] = gEEprops.keys[symbol(key)]
  
  return rtrn
end



on updateEffectsMenu me, mv: point
  gEEprops.emPos = gEEprops.emPos + mv
  
  if gEEprops.emPos.locH < 1 then
    gEEprops.emPos.locH = gEffects.count
  else if gEEprops.emPos.locH > gEffects.count then
    gEEprops.emPos.locH = 1
  end if 
  
  if gEEprops.emPos.locV < 1 then
    gEEprops.emPos.locV = gEffects[gEEprops.emPos.locH].efs.count
  else if gEEprops.emPos.locV > gEffects[gEEprops.emPos.locH].efs.count then
    gEEprops.emPos.locV = 1
  end if
  
  txt: string = ""
  put "[" && gEffects[gEEprops.emPos.locH].nm && "]" after txt
  put RETURN after txt
  
  
  repeat with tl = 1 to gEffects[gEEprops.emPos.locH].efs.count then
    if tl = gEEprops.emPos.locV then
      put "-" && gEffects[gEEprops.emPos.locH].efs[tl].nm && "-" && RETURN after txt
    else
      put gEffects[gEEprops.emPos.locH].efs[tl].nm && RETURN after txt
    end if
  end repeat
  
  member("tileMenu").text = txt
  efn = gEffects[gEEprops.emPos.locH].efs[gEEprops.emPos.locV]
end


on updateEffectsL me, mv: number
  txt: string = ""
  if gEEprops.effects.count <> 0 then
    gEEprops.selectEditEffect = gEEprops.selectEditEffect + mv
    if gEEprops.selectEditEffect < 1 then
      gEEprops.selectEditEffect = gEEprops.effects.count
    else if gEEprops.selectEditEffect > gEEprops.effects.count then
      gEEprops.selectEditEffect = 1
    end if
    
    
    put "<EFFECTS>" after txt
    put RETURN after txt
    
    repeat with ef = 1 to gEEprops.effects.count then
      if gEEprops.selectEditEffect <= gEEprops.effects.count and gEEprops.selectEditEffect - 20 - ef > 0 then
        next repeat
      end if
      if ef = gEEprops.editEffect then
        put string(ef)&". *"&gEEprops.effects[ef].nm&"*" after txt
        member("editEffectName").text = gEEprops.effects[ef].nm && "("&string(ef)&")"
      else if ef = gEEprops.selectEditEffect then
        put string(ef)&". -"&gEEprops.effects[ef].nm&"-" after txt
      else
        put string(ef)&". "&gEEprops.effects[ef].nm after txt
      end if
      put RETURN after txt
    end repeat
    
    me.drawEfMtrx(gEEprops.selectEditEffect)
  else
    member("editEffectName").text = "No effects added"
    put "<EFFECTS>" after txt
    put RETURN after txt
    put "No effects added" after txt
  end if
  member("effectsL").text = txt
end


on newEffect me
  origEf = gEffects[gEEprops.emPos.locH].efs[gEEprops.emPos.locV]
  ef = [#nm:origEf.nm, #tp:"nn", #crossScreen:0, #mtrx:[], #options: [["Delete/Move", ["Delete", "Move Back", "Move Forth"], ""]] ]
  
  
  fillWith = 0
  
  case ef.nm of
    "Slime":
      ef.tp = "standardErosion"
      ef.addProp(#repeats, 130)
      ef.addProp(#affectOpenAreas, 0.5)
      ef.options.add(["Layers", ["All", "1", "2", "3", "1:st and 2:nd", "2:nd and 3:rd"], "All"])
      ef.options.add(["3D", ["Off", "On"], "Off"])
      ef.options.add(["Affect Gradients and Decals", ["Yes", "No"], "Yes"])
      
    "LSlime":
      ef.tp = "standardErosion"
      ef.addProp(#repeats, 130)
      ef.addProp(#affectOpenAreas, 0.5)
      ef.options.add(["3D", ["Off", "On"], "Off"])
      
    "Fat Slime":
      ef.tp = "standardErosion"
      ef.addProp(#repeats, 200)
      ef.addProp(#affectOpenAreas, 0.5)
      ef.options.add(["Layers", ["All", "1", "2", "3", "1:st and 2:nd", "2:nd and 3:rd"], "All"])
      ef.options.add(["3D", ["Off", "On"], "Off"])
      ef.options.add(["Affect Gradients and Decals", ["Yes", "No"], "Yes"])
      
    "Scales":
      ef.tp = "standardErosion"
      ef.addProp(#repeats, 200)
      ef.addProp(#affectOpenAreas, 0.05)
      ef.options.add(["Layers", ["All", "1", "2", "3", "1:st and 2:nd", "2:nd and 3:rd"], "All"])
      
    "SlimeX3":
      ef.tp = "standardErosion"
      ef.addProp(#repeats, 130*3)
      ef.addProp(#affectOpenAreas, 0.5)
      ef.options.add(["Layers", ["All", "1", "2", "3", "1:st and 2:nd", "2:nd and 3:rd"], "All"])
      ef.options.add(["3D", ["Off", "On"], "Off"])
      ef.options.add(["Affect Gradients and Decals", ["Yes", "No"], "Yes"])
      
    "DecalsOnlySlime":
      ef.tp = "standardErosion"
      ef.addProp(#repeats, 130)
      ef.addProp(#affectOpenAreas, 0.5)
      ef.options.add(["Layers", ["All", "1", "2", "3", "1:st and 2:nd", "2:nd and 3:rd"], "All"])
      
    "Melt":
      ef.tp = "standardErosion"
      ef.addProp(#repeats, 60)
      ef.addProp(#affectOpenAreas, 0.5)
      ef.options.add(["Layers", ["All", "1", "2", "3", "1:st and 2:nd", "2:nd and 3:rd"], "All"])
      ef.options.add(["Affect Gradients and Decals", ["Yes", "No"], "No"])
      
    "Rust":
      ef.tp = "standardErosion"
      ef.addProp(#repeats, 60)
      ef.addProp(#affectOpenAreas, 0.2)
      ef.options.add(["Layers", ["All", "1", "2", "3", "1:st and 2:nd", "2:nd and 3:rd"], "All"])
      ef.options.add(["3D", ["Off", "On"], "Off"])
      ef.options.add(["Affect Gradients and Decals", ["Yes", "No"], "No"])
      
    "Barnacles":
      ef.tp = "standardErosion"
      ef.addProp(#repeats, 60)
      ef.addProp(#affectOpenAreas, 0.3)
      ef.options.add(["Layers", ["All", "1", "2", "3", "1:st and 2:nd", "2:nd and 3:rd"], "All"])
      ef.options.add(["3D", ["Off", "On"], "Off"])
      ef.options.add(["Affect Gradients and Decals", ["Yes", "No"], "No"])
      
    "Colored Barnacles":
      ef.tp = "standardErosion"
      ef.addProp(#repeats, 60)
      ef.addProp(#affectOpenAreas, 0.3)
      ef.options.add(["Layers", ["All", "1", "2", "3", "1:st and 2:nd", "2:nd and 3:rd"], "All"])
      ef.options.add(["3D", ["Off", "On"], "Off"])
      ef.options.add(["Effect Color", ["EffectColor1", "EffectColor2", "None"], "EffectColor2"])
      
    "Clovers":
      ef.tp = "standardErosion"
      ef.addProp(#repeats, 20)
      ef.addProp(#affectOpenAreas, 0.2)
      ef.options.add(["Layers", ["All", "1", "2", "3", "1:st and 2:nd", "2:nd and 3:rd"], "All"])
      ef.options.add(["3D", ["Off", "On"], "Off"])
      ef.options.add(["Color", ["Color1", "Color2", "Dead"], "Color2"])
      
    "Ivy":
      ef.options.add(["Layers", ["All", "1", "2", "3", "1:st and 2:nd", "2:nd and 3:rd"], "All"])
      ef.options.add(["Color", ["Color1", "Color2", "Dead"], "Color2"])
      ef.options.add(["Color Intensity", ["High", "Medium", "Low", "None", "Random"], "Medium"])
      ef.options.add(["Fruit Density", ["High", "Medium", "Low", "None"], "None"])
      ef.options.add(["Leaf Density", [], random(100)])
      ef.options.add(["Require In-Bounds", ["Yes", "No"], ["No", "Yes"][getBoolConfig("Sky roots fix") + 1]])
      ef.crossScreen = 1
      
    "Little Flowers":
      ef.options.add(["Color", ["Color1", "Color2", "Dead"], "Color2"])
      ef.options.add(["Detail Color", ["Color1", "Color2", "Dead"], "Color2"])
      ef.options.add(["Layers", ["All", "1", "2", "3", "1:st and 2:nd", "2:nd and 3:rd"], "All"])
      ef.options.add(["Rotate", ["Off", "On"], "Off"])
      
    "Erode":
      ef.tp = "standardErosion"
      ef.addProp(#repeats, 80)
      ef.addProp(#affectOpenAreas, 0.5)
      ef.options.add(["Layers", ["All", "1", "2", "3", "1:st and 2:nd", "2:nd and 3:rd"], "All"])
      
    "Sand":
      ef.tp = "standardErosion"
      ef.addProp(#repeats, 80)
      ef.addProp(#affectOpenAreas, 0.5)
      ef.options.add(["Layers", ["All", "1", "2", "3", "1:st and 2:nd", "2:nd and 3:rd"], "All"])
      ef.options.add(["Effect Color", ["EffectColor1", "EffectColor2", "None"], "None"])
      
    "Super Erode":
      ef.tp = "standardErosion"
      ef.addProp(#repeats, 60)
      ef.addProp(#affectOpenAreas, 0.5)
      ef.options.add(["Layers", ["All", "1", "2", "3", "1:st and 2:nd", "2:nd and 3:rd"], "All"])
      
    "Ultra Super Erode":
      ef.tp = "standardErosion"
      ef.addProp(#repeats, 60)
      ef.addProp(#affectOpenAreas, 0.5)
      ef.options.add(["Layers", ["All", "1", "2", "3", "1:st and 2:nd", "2:nd and 3:rd"], "All"])
      
    "Roughen":
      ef.tp = "standardErosion"
      ef.addProp(#repeats, 30)
      ef.addProp(#affectOpenAreas, 0.05)
      ef.options.add(["Layers", ["All", "1", "2", "3", "1:st and 2:nd", "2:nd and 3:rd"], "All"])
      
    "Impacts":
      ef.tp = "standardErosion"
      ef.addProp(#repeats, 75)
      ef.addProp(#affectOpenAreas, 0.05)
      ef.options.add(["Layers", ["All", "1", "2", "3", "1:st and 2:nd", "2:nd and 3:rd"], "All"])
      
    "Super Melt":
      ef.tp = "standardErosion"
      ef.addProp(#repeats, 50)
      ef.addProp(#affectOpenAreas, 0.5)
      ef.options.add(["Layers", ["All", "1", "2", "3", "1:st and 2:nd", "2:nd and 3:rd"], "All"])
      ef.options.add(["3D", ["Off", "On"], "Off"])
      ef.options.add(["Affect Gradients and Decals", ["Yes", "No"], "No"])
      
    "Destructive Melt":
      ef.tp = "standardErosion"
      ef.addProp(#repeats, 50)
      ef.addProp(#affectOpenAreas, 0.5)
      ef.options.add(["Layers", ["All", "1", "2", "3", "1:st and 2:nd", "2:nd and 3:rd"], "All"])
      ef.options.add(["3D", ["Off", "On"], "Off"])
      ef.options.add(["Affect Gradients and Decals", ["Yes", "No"], "No"])
      
    "Rubble", "Wire Bunches":
      ef.options.add(["Layers", ["All", "1", "2", "3", "1:st and 2:nd", "2:nd and 3:rd"], "All"])
      
    "Colored Rubble":
      ef.options.add(["Layers", ["All", "1", "2", "3", "1:st and 2:nd", "2:nd and 3:rd"], "All"])
      ef.options.add(["Effect Color", ["EffectColor1", "EffectColor2", "None"], "EffectColor2"])
      
    "Fungi Flowers", "Lighthouse Flowers":
      ef.options.add(["Layers", ["All", "1", "2", "3", "1:st and 2:nd", "2:nd and 3:rd"], "1"])
      
    "Colored Fungi Flowers", "Colored Lighthouse Flowers":
      ef.options.add(["Layers", ["All", "1", "2", "3", "1:st and 2:nd", "2:nd and 3:rd"], "1"])
      ef.options.add(["Color", ["Color1", "Color2", "Dead"], "Color2"])
      
    "Foliage", "High Grass", "High Fern", "Mistletoe", "Reeds", "Lavenders", "Spindles", "Box Grubs":
      ef.options.add(["Layers", ["All", "1", "2", "3", "1:st and 2:nd", "2:nd and 3:rd"], "All"])
      ef.options.add(["Color", ["Color1", "Color2", "Dead"], "Color2"])
      
    "Ring Chains":
      ef.options.add(["Layers", ["All", "1", "2", "3", "1:st and 2:nd", "2:nd and 3:rd"], "All"])
      ef.options.add(["Effect Color", ["EffectColor1", "EffectColor2", "None"], "None"])
      
    "Assorted Trash":
      ef.options.add(["Layers", ["All", "1", "2", "3", "1:st and 2:nd", "2:nd and 3:rd"], "All"])
      ef.options.add(["Effect Color", ["EffectColor1", "EffectColor2", "None"], "None"])
      
      
    "Fez Tree":
      ef.options.add(["Layers", ["All", "1", "2", "3", "1:st and 2:nd", "2:nd and 3:rd"], "1"])
      ef.options.add(["Color", ["Color1", "Color2", "Dead"], "Color2"])
      ef.crossScreen = 1
      
    "Meat Blobs":
      ef.options.add(["Layers", ["All", "1", "2", "3", "1:st and 2:nd", "2:nd and 3:rd"], "All"])
      ef.options.add(["Blob Size", ["Big", "Medium", "Small"], "Big"])
      ef.options.add(["Should grow on layer behind", ["Yes", "No"], "No"])
      ef.options.add(["Needs to be attached to walls", ["Yes", "No"], "Yes"])
      
    "Brain Growers", "Upside Down Brain Growers":
      ef.options.add(["Layers", ["All", "1", "2", "3", "1:st and 2:nd", "2:nd and 3:rd"], "All"])
      ef.options.add(["Color", ["Color1", "Color2", "Dead"], "Dead"])
      ef.crossScreen = 1
      
      
    "Fern", "Giant Mushroom", "Sprawlbush", "featherFern", "Fungus Tree", "Sprawlroots", "Fungus Roots", "Mama Orblings", "Mushroom Colonies":
      ef.options.add(["Layers", ["All", "1", "2", "3", "1:st and 2:nd", "2:nd and 3:rd"], "1"])
      ef.options.add(["Color", ["Color1", "Color2", "Dead"], "Color2"])
      
    "Root Grass", "Growers", "Cacti", "Rain Moss", "Dense Mold", "Seed Pods", "Dandelions", "Grass", "Arm Growers", "Horse Tails", "Circuit Plants", "Storm Plants", "Feather Plants", "Mini Growers", "Left Facing Kelp", "Right Facing Kelp", "Club Moss", "Moss Wall", "Mixed Facing Kelp", "Bubble Grower", "Seed Grass", "Hyacinths", "Orb Plants", "Lollipop Mold", "Og Grass", "Orblings", "Ripcords", "Cross Roses":
      ef.options.add(["Layers", ["All", "1", "2", "3", "1:st and 2:nd", "2:nd and 3:rd"], "All"])
      ef.options.add(["Color", ["Color1", "Color2", "Dead"], "Color2"])
      
      if(["Arm Growers", "Growers", "Mini Growers", "Left Facing Kelp", "Right Facing Kelp", "Mixed Facing Kelp", "Bubble Grower", "Coral Growers", "Leaf Growers", "Meat Growers", "Orblings"].getPos( ef.nm ) > 0 )then
        ef.crossScreen = 1
        ef.options.add(["Require In-Bounds", ["Yes", "No"], ["No", "Yes"][getBoolConfig("Sky roots fix") + 1]])
      end if
      
    "Rollers", "Thorn Growers", "Horror Growers", "Garbage Spirals", "Spinets", "Small Springs", "Fuzzy Growers", "Coral Growers", "Leaf Growers", "Meat Growers", "Thunder Growers", "Ice Growers", "Grass Growers", "Fancy Growers":
      ef.options.add(["Layers", ["All", "1", "2", "3", "1:st and 2:nd", "2:nd and 3:rd"], "All"])
      ef.options.add(["Color", ["Color1", "Color2", "Dead"], "Color2"])
      ef.options.add(["Require In-Bounds", ["Yes", "No"], ["No", "Yes"][getBoolConfig("Sky roots fix") + 1]])
      ef.crossScreen = 1
      
    "Mosaic Plants":
      ef.options.add(["Layers", ["1", "2", "1:st and 2:nd"], "1"])
      ef.options.add(["Color", ["Color1", "Color2", "Dead"], "Color2"])
      ef.options.add(["Color Intensity", ["High", "Medium", "Low", "None", "Random"], "Medium"])
      ef.options.add(["Flowers", ["Off", "On"], "Off"])
      ef.options.add(["Detail Color", ["Color1", "Color2", "Dead"], "Color1"])
      ef.crossScreen = 1
      
    "Cobwebs":
      ef.options.add(["Layers", ["All", "1", "2", "3", "1:st and 2:nd", "2:nd and 3:rd"], "1"])
      ef.options.add(["Effect Color", ["EffectColor1", "EffectColor2", "None"], "None"])
      ef.options.add(["Color Intensity", ["High", "Medium", "Low", "None"], "Medium"])
      ef.crossScreen = 1
      
    "Fingers":
      ef.options.add(["Layers", ["All", "1", "2", "3", "1:st and 2:nd", "2:nd and 3:rd"], "All"])
      ef.options.add(["Color", ["Color1", "Color2", "Dead"], "Dead"])
      ef.options.add(["Finger Thickness", ["Small", "Medium", "FAT", "Random"], "Medium"])
      ef.options.add(["Finger Length", ["Short", "Medium", "Tall", "Random"], "Medium"])
      
    "Head Lamp", "Ceiling Lamp":
      ef.options.add(["Layers", ["All", "1", "2", "3", "1:st and 2:nd", "2:nd and 3:rd"], "All"])
      ef.options.add(["Color", ["Color1", "Color2", "Dead"], "Dead"])
      ef.options.add(["Lamp Color", ["Color1", "Color2", "Dead"], "Dead"])
      
    "Wires":
      ef.options.add(["Layers", ["All", "1", "2", "3", "1:st and 2:nd", "2:nd and 3:rd"], "All"])
      ef.options.add(["Fatness", ["1px", "2px", "3px", "random"], "2px"])
      crossScreen = 1
      
    "Chains":
      ef.options.add(["Layers", ["All", "1", "2", "3", "1:st and 2:nd", "2:nd and 3:rd"], "All"])
      ef.options.add(["Size", ["Small", "FAT"], "Small"])
      ef.crossScreen = 1
      
    "Colored Wires":
      ef.options.add(["Layers", ["All", "1", "2", "3", "1:st and 2:nd", "2:nd and 3:rd"], "All"])
      ef.options.add(["Fatness", ["1px", "2px", "3px", "random"], "2px"])
      ef.options.add(["Effect Color", ["EffectColor1", "EffectColor2", "None"], "EffectColor2"])
      crossScreen = 1
      
    "Colored Chains":
      ef.options.add(["Layers", ["All", "1", "2", "3", "1:st and 2:nd", "2:nd and 3:rd"], "All"])
      ef.options.add(["Size", ["Small", "FAT"], "Small"])
      ef.options.add(["Effect Color", ["EffectColor1", "EffectColor2", "None"], "EffectColor2"])
      ef.crossScreen = 1
      
    "Mushroom Stubs":
      ef.options.add(["Color", ["Color1", "Color2", "Dead"], "Color2"])
      ef.options.add(["Layers", ["All", "1", "2", "3", "1:st and 2:nd", "2:nd and 3:rd"], "All"])
      ef.options.add(["Mushroom Size", ["Small", "Medium", "Random"], "Medium"])
      ef.options.add(["Mushroom Width", ["Small", "Medium", "Wide", "Random"], "Medium"])
      
    "BlackGoo":
      fillWith = 100
      
    "Super BlackGoo":
      fillWith = 100
      
    "DarkSlime":
      ef.options.add(["Layers", ["All", "1", "2", "3", "1:st and 2:nd", "2:nd and 3:rd"], "All"])
      
    "Hang Roots", "Thick Roots", "Shadow Plants":
      ef.options.add(["Layers", ["All", "1", "2", "3", "1:st and 2:nd", "2:nd and 3:rd"], "All"])
      ef.options.add(["Require In-Bounds", ["Yes", "No"], ["No", "Yes"][getBoolConfig("Sky roots fix") + 1]])
      ef.crossScreen = 1
      
    "Colored Hang Roots", "Colored Thick Roots":
      ef.options.add(["Layers", ["All", "1", "2", "3", "1:st and 2:nd", "2:nd and 3:rd"], "All"])
      ef.options.add(["Color", ["Color1", "Color2", "Dead"], "Color2"])
      ef.options.add(["Require In-Bounds", ["Yes", "No"], ["No", "Yes"][getBoolConfig("Sky roots fix") + 1]])
      ef.crossScreen = 1
      
    "Colored Shadow Plants":
      ef.options.add(["Layers", ["All", "1", "2", "3", "1:st and 2:nd", "2:nd and 3:rd"], "All"])
      ef.options.add(["Color", ["Color1", "Color2", "Dead"], "Color2"])
      ef.options.add(["Require In-Bounds", ["Yes", "No"], ["No", "Yes"][getBoolConfig("Sky roots fix") + 1]])
      ef.crossScreen = 1
      
    "Root Plants":
      ef.options.add(["Layers", ["All", "1", "2", "3", "1:st and 2:nd", "2:nd and 3:rd"], "All"])
      ef.options.add(["Color", ["Color1", "Color2", "Dead"], "Color2"])
      ef.options.add(["Require In-Bounds", ["Yes", "No"], ["No", "Yes"][getBoolConfig("Sky roots fix") + 1]])
      ef.crossScreen = 1
      
    "Restore As Scaffolding":
      ef.options.add(["Layers", ["All", "1", "2", "3", "1:st and 2:nd", "2:nd and 3:rd"], "All"])
      
    "Restore As Pipes":
      ef.options.add(["Layers", ["All", "1", "2", "3", "1:st and 2:nd", "2:nd and 3:rd"], "All"])
      
    "Ceramic Chaos":
      ef.options.add(["Ceramic Color", ["None", "Colored"], "Colored"])
      ef.options.add(["Layers", ["All", "1", "2", "3", "1:st and 2:nd", "2:nd and 3:rd"], "All"])
      
    "DaddyCorruption":
      ef.options.add(["Color", ["Color1", "Color2", "Dead"], "Color2"])
      ef.options.add(["Layers", ["All", "1", "2", "3", "1:st and 2:nd", "2:nd and 3:rd"], "All"])
      
    "Wastewater Mold":
      ef.options.add(["Color", ["Color1", "Color2", "Dead"], "Color2"])
      ef.options.add(["Layers", ["All", "1", "2", "3", "1:st and 2:nd", "2:nd and 3:rd"], "All"])
      
    "Corruption No Eye", "Slag":
      ef.options.add(["Layers", ["All", "1", "2", "3", "1:st and 2:nd", "2:nd and 3:rd"], "All"])
      
    "Stained Glass Properties":
      ef.options.add(["Variation", ["1", "2", "3"], "1"])
      ef.options.add(["Color 1", ["EffectColor1", "EffectColor2", "None"], "EffectColor1"])
      ef.options.add(["Color 2", ["EffectColor1", "EffectColor2", "None"], "EffectColor2"])
      
    "Grape Roots", "Hand Growers":
      ef.options.add(["Layers", ["All", "1", "2", "3", "1:st and 2:nd", "2:nd and 3:rd"], "All"])
      ef.options.add(["Color", ["Color1", "Color2", "Dead"], "Color2"])
      ef.options.add(["Require In-Bounds", ["Yes", "No"], ["No", "Yes"][getBoolConfig("Sky roots fix") + 1]])
      ef.crossScreen = 1
      
    "Spud Buds":
      ef.options.add(["Layers", ["All", "1", "2", "3", "1:st and 2:nd", "2:nd and 3:rd"], "All"])
      ef.options.add(["Color", ["Color1", "Color2", "Dead"], "Dead"])
      ef.options.add(["Frond Size", ["None", "Small", "Large"], "Large"])
      ef.options.add(["Frond Color", ["Color1", "Color2", "Dead"], "Color2"])
      ef.options.add(["Require In-Bounds", ["Yes", "No"], ["No", "Yes"][getBoolConfig("Sky roots fix") + 1]])
      ef.crossScreen = 1
      
    "Cables":
      ef.options.add(["Layers", ["All", "1", "2", "3", "1:st and 2:nd", "2:nd and 3:rd"], "All"])
      ef.options.add(["Fatness", ["1px", "2px", "3px", "random"], "2px"])
      ef.options.add(["Effect Color", ["EffectColor1", "EffectColor2", "None"], "None"])
      crossScreen = 1
      
    "Smoke Weeds":
      ef.options.add(["Layers", ["All", "1", "2", "3", "1:st and 2:nd", "2:nd and 3:rd"], "1"])
      ef.options.add(["Color", ["Color1", "Color2", "Dead"], "Dead"])
      ef.options.add(["Head Size", ["Small", "Large", "GIANT"], "Large"])
      ef.options.add(["Flowers", ["Off", "On"], "Off"])
      ef.crossScreen = 1
      
    "Pattern Depth":
      ef.options.add(["Layer", ["1", "2", "3"], "2"])
      ef.options.add(["Mode", ["Increase", "Decrease"], "Increase"])

    "Pattern Chaos":
      ef.options.add(["Layers", ["All", "1", "2", "3", "1:st and 2:nd", "2:nd and 3:rd"], "All"])
      ef.options.add(["Noise Smoothness", ["1", "2", "3", "4"], "1"])
      
    otherwise:
      if gCustomEffects.getPos(ef.nm) > 0 then
        if origEf.tp = "individual" or origEf.tp = "individualHanger" or origEf.tp = "individualClinger" then
          ef.options.add(["Layers", ["All", "1", "2", "3", "1:st and 2:nd", "2:nd and 3:rd"], "1"])
        else
          ef.options.add(["Layers", ["All", "1", "2", "3", "1:st and 2:nd", "2:nd and 3:rd"], "All"])
        end if
        
        if origEf.findPos("pickColor") then
          if origEf.pickColor = 1 then
            ef.options.add(["Color", ["Color1", "Color2", "Dead"], "Color2"])
          end if
        end if
        
        if origEf.tp = "wall" and origEf.findPos("can3D") > 0 then
          if origEf.can3D = 2 then 
            ef.options.add(["3D", ["Off", "On"], "Off"])
          end if
        end if
        
        if origEf.tp = "clinger" or origEf.tp = "standardClinger" then
          ef.options.add(["Side", ["Left", "Right", "Random"], "Random"])
        end if
        
        if ["grower", "hanger", "clinger"].getPos(origEf.tp)>0 then
          ef.crossScreen = 1
          ef.options.add(["Require In-Bounds", ["Yes", "No"], ["No", "Yes"][getBoolConfig("Sky roots fix") + 1]])
        end if
        
      end if
  end case
  
  repeat with q = 1 to gLOprops.size.loch then
    ql = []
    repeat with c = 1 to gLOprops.size.locv then
      ql.add(fillWith)
    end repeat
    ef.mtrx.add(ql)
  end repeat
  
  ef.options.add(["Seed", [], random(500)])
  
  
  
  gEEprops.effects.add(ef)
  
  
  
  me.updateEffectsL(0)
end





on useBrush me, pnt, fac
  if  gEEprops.mode = "editEffect" then
    cEff = VOID
    efName = gEEprops.effects[gEEprops.editEffect].nm
    if gCustomEffects.getPos(efName) > 0 then
      repeat with i = 1 to gEffects.count
        iefs = gEffects[i].efs
        repeat with j = 1 to iefs.count
          ijef = iefs[j]
          if ijef.nm = efName then
            cEff = ijef
            exit repeat
          end if
        end repeat
        if cEff <> VOID then exit repeat
      end repeat
    end if
    strength = 10 + (90* checkCustomKeybind(#EffectBrushPowerful, "T"))
    if ["BlackGoo", "Fungi Flowers", "Lighthouse Flowers", "Colored Fungi Flowers", "Colored Lighthouse Flowers", "High Fern", "High Grass", "Fern", "Giant Mushroom", "Sprawlbush", "featherFern", "Fungus Tree", "Restore As Scaffolding", "Restore As Pipes", "Foliage", "Mistletoe", "Small Springs", "Super BlackGoo", "Stained Glass Properties", "Cobwebs", "Hand Growers", "Head Lamp", "Sprawlroots", "Fungus Roots", "Ceiling Lamp","Mama Orblings","Fez Tree","Smoke Weeds", "Mushroom Colonies"].getPos(efName)>0 then
      strength = 10000
      if (efName <> "BlackGoo") and (efName <> "Super BlackGoo") and (efName <> "Foliage" or fac > 0) and (efName <> "Mistletoe" or fac > 0) then
        gEEprops.brushSize = 1
      end if
    else if efName = "Box Grubs" then
      gEEprops.brushSize = 1
    else if cEff <> VOID then
      if cEff.tp = "individual" or cEff.tp = "individualHanger" or cEff.tp = "individualClinger" then
        strength = 10000
        gEEprops.brushSize = 1
      end if
    end if
    
    rct = rect(pnt, pnt)+rect(-gEEprops.brushSize, -gEEprops.brushSize, gEEprops.brushSize, gEEprops.brushSize)
    repeat with q = rct.left to rct.right then
      repeat with c = rct.top to rct.bottom then
        if point(q,c).inside(rect(1,1,gLOprops.size.loch+1,gLOprops.size.locv+1))then
          val = gEEprops.effects[gEEprops.editEffect].mtrx[q][c]
          digFac = 1.0-(diag(point(q,c), pnt).float/gEEprops.brushSize)
          if digFac > 0 then
            
            val = restrict(val + strength*digFac*fac, 0, 100)
            gEEprops.effects[gEEprops.editEffect].mtrx[q][c] = val
            
            me.updateEffectGraph(point(q,c), val)
            
          end if
        end if
      end repeat
    end repeat
  end if
end


on drawEfMtrx me, l
  if (gEEprops.effects.count > 0)and(l>0) then
    repeat with a = gLEProps.camPos.locH to gLEProps.camPos.locH + 52 then
      repeat with b = gLEProps.camPos.locV to gLEProps.camPos.locV + 40 then
        if(a > 0)and(a<=gLOprops.size.loch)and(b>0)and(b<=gLOprops.size.locV)then
          me.updateEffectGraph(point(a,b), gEEprops.effects[l].mtrx[a][b])
        else
          me.updateEffectGraph(point(a,b), -1)
        end if
      end repeat
    end repeat
  else
    member("effectsMatrix").image.copyPixels(member("pxl").image, member("effectsMatrix").image.rect, member("pxl").image.rect)
  end if
end 

on updateEffectGraph me, tile, strength
  if (strength = -1) then
    member("effectsMatrix").image.setPixel(tile.locH-gLEProps.camPos.locH-1, tile.locV-gLEProps.camPos.locV-1, color(0, 0, 0))
  else
    
    strength = strength / 100.0
    member("effectsMatrix").image.setPixel(tile.locH-gLEProps.camPos.locH-1, tile.locV-gLEProps.camPos.locV-1, color(255-strength*255, 255*strength, 255-strength*255))
  end if
end


on initMode me, md
  case md of
      
    "chooseEffect":
      if gEEprops.effects.count > 0 then
        gEEprops.selectEditEffect = gEEprops.editEffect
        --   me.updateEffectsL(0)
        sprite(229).rect = rect((53*16)+8, 10*16, 1366-8, 41*16)
        member("EEhelp").text = "Use W, S and the spacebar to select an effect to edit. Press N to return to the new effects menu."
      else
        --   me.updateEffectsL(0)
      end if
    "editEffect":
      -- me.updateEffectsL(0)
      sprite(229).rect = rect(8, 42*16, 1366-8, 768-8)
      member("EEhelp").text = "Edit effect: Use W, A, S, D to change the settings of the effect. Press the spacebar to activate the selected option. Use the left and right mouse buttons to change the effect matrix. Press T while clicking to increase the strength of the brush. Press E to edit effects added previously. Press N to return to the new effects menu."
      -- me.drawEfMtrx(rect(1,1,52,40), gEEprops.editEffect)
    "createNew":
      -- me.drawEfMtrx(rect(1,1,52,40), 0)
      sprite(229).rect = rect((53*16)+8, 8, 1366-8, 10*16)
      member("EEhelp").text = "Create new: Use the W, A, S, D keys and the spacebar to select an effect to add. Press E to edit effects added previously."
    otherwise:
      sprite(229).rect = rect(-1, -1, -1, -1)
      member("EEhelp").text = "---"    
  end case
  gEEprops.mode = md
  me.updateAllText()
end





on updateEditEffect me, mv
  
  if gEEprops.effects <> [] then
    if gEEprops.editEffect > gEEprops.effects.count then
      gEEprops.editEffect = gEEprops.effects.count
    end if
    
    gEEprops.emPos = gEEprops.emPos + mv
    if gEEprops.emPos.locV > gEEprops.effects[gEEprops.editEffect].options.count then
      gEEprops.emPos.locV = 1
    else  if gEEprops.emPos.locV < 1 then
      gEEprops.emPos.locV = gEEprops.effects[gEEprops.editEffect].options.count
    end if
    if gEEprops.emPos.locH > gEEprops.effects[gEEprops.editEffect].options[gEEprops.emPos.locV][2].count then
      gEEprops.emPos.locH = 1
    else  if gEEprops.emPos.locH < 1 then
      gEEprops.emPos.locH = gEEprops.effects[gEEprops.editEffect].options[gEEprops.emPos.locV][2].count
    end if
    
    txt = ""
    put "["&& gEEprops.effects[gEEprops.editEffect].options[gEEprops.emPos.locV][1] && "]:" && gEEprops.effects[gEEprops.editEffect].options[gEEprops.emPos.locV][3] after txt
    put RETURN after txt
    repeat with ef = 1 to gEEprops.effects[gEEprops.editEffect].options[gEEprops.emPos.locV][2].count then
      if ef = gEEprops.emPos.locH then
        put "-"&& gEEprops.effects[gEEprops.editEffect].options[gEEprops.emPos.locV][2][ef] && "-   " after txt
      else
        put gEEprops.effects[gEEprops.editEffect].options[gEEprops.emPos.locV][2][ef] && "    " after txt
      end if
    end repeat
    
    member("effectOptions").text = txt
  else
    member("effectOptions").text = ""
  end if
end 


on changeOption me
  -- put gEEprops.effects[gEEprops.editEffect].options[gEEprops.emPos.locV][1]
  -- put gEEprops.effects[gEEprops.editEffect].options[gEEprops.emPos.locV][gEEprops.emPos.locH]
  case gEEprops.effects[gEEprops.editEffect].options[gEEprops.emPos.locV][1] of
    "Delete/Move":
      case gEEprops.effects[gEEprops.editEffect].options[gEEprops.emPos.locV][2][gEEprops.emPos.locH] of
        "Delete":
          gEEprops.effects.deleteAt(gEEprops.editEffect)
          --  me.updateEffectsL(0)
          me.initMode("chooseEffect")
          gEEprops.editEffect = gEEprops.effects.count
          me.updateAllText()
        "Move Back":
          sv =  gEEprops.effects[gEEprops.editEffect].duplicate()
          gEEprops.effects.deleteAt(gEEprops.editEffect)
          gEEprops.editEffect = restrict(gEEprops.editEffect-1, 1, gEEprops.effects.count)
          gEEprops.effects.addAt(gEEprops.editEffect, sv)
          gEEprops.selectEditEffect =  gEEprops.editEffect
          me.updateEffectsL(0)
        "Move Forth":
          sv =  gEEprops.effects[gEEprops.editEffect].duplicate()
          gEEprops.effects.deleteAt(gEEprops.editEffect)
          gEEprops.editEffect = restrict(gEEprops.editEffect+1, 1, gEEprops.effects.count+1)
          gEEprops.effects.addAt(gEEprops.editEffect, sv)
          gEEprops.selectEditEffect =  gEEprops.editEffect
          me.updateEffectsL(0)
      end case
    "Seed":
      if checkCustomKeybind(#EffectCategoryPrev, "A") then
        gEEprops.effects[gEEprops.editEffect].options[gEEprops.emPos.locV][3] = gEEprops.effects[gEEprops.editEffect].options[gEEprops.emPos.locV][3] -1
      end if
      if checkCustomKeybind(#EffectCategoryNext, "D") then
        gEEprops.effects[gEEprops.editEffect].options[gEEprops.emPos.locV][3] = gEEprops.effects[gEEprops.editEffect].options[gEEprops.emPos.locV][3] +1
      end if
      gEEprops.effects[gEEprops.editEffect].options[gEEprops.emPos.locV][3] = restrict(gEEprops.effects[gEEprops.editEffect].options[gEEprops.emPos.locV][3], 1, 500)
    "Leaf Density":
      if checkCustomKeybind(#EffectCategoryPrev, "A") then
        gEEprops.effects[gEEprops.editEffect].options[gEEprops.emPos.locV][3] = gEEprops.effects[gEEprops.editEffect].options[gEEprops.emPos.locV][3] -1
      end if
      if checkCustomKeybind(#EffectCategoryNext, "D") then
        gEEprops.effects[gEEprops.editEffect].options[gEEprops.emPos.locV][3] = gEEprops.effects[gEEprops.editEffect].options[gEEprops.emPos.locV][3] +1
      end if
      gEEprops.effects[gEEprops.editEffect].options[gEEprops.emPos.locV][3] = restrict(gEEprops.effects[gEEprops.editEffect].options[gEEprops.emPos.locV][3], 1, 100)
      
      
    "Color", "Detail Color", "Fatness", "Size", "Layers", "3D", "Ceramic Color", "Effect Color", "Variation", "Color 1", "Color 2", "Affect Gradients and Decals", "Rotate", "Color Intensity", "Fruit Density", "Mushroom Size", "Mushroom Width", "Flowers", "Side", "Finger Thickness", "Finger Length", "Lamp Color", "Require In-Bounds", "Blob Size", "Should grow on layer behind", "Needs to be attached to walls", "Frond Color", "Frond Size", "Head Size":
      gEEprops.effects[gEEprops.editEffect].options[gEEprops.emPos.locV][3] = gEEprops.effects[gEEprops.editEffect].options[gEEprops.emPos.locV][2][gEEprops.emPos.locH]
      
      
      
  end case
  
  me.updateEditEffect(point(0,0))
end






on updateAllText me
  me.updateEffectsL(0)
  me.updateEditEffect(point(0,0))
  me.updateEffectsMenu(point(0,0))
  
end

























