global vertRepeater, r, gEEprops, solidMtrx, gLEprops, colr, colrDetail, colrInd, gdLayer, gdDetailLayer, gdIndLayer, gLOProps, gLevel, gEffectProps, gRenderCameraTilePos, effectSeed, lrSup, chOp, fatOp, gradAf, effectIn3D, gAnyDecals, gRotOp, effSide, gCustomEffects, gEffects, gLastImported, skyRootsFix, DRWhite

-- Effect applying hub thingy
on ApplyCustomEffect(me, q, c, effectr, efname)
  q2 = q + gRenderCameraTilePos.locH
  c2 = c + gRenderCameraTilePos.locV
  mtrx = effectr.mtrx
  
  -- Find the effect
  cEff = VOID
  if (gCustomEffects.getPos(efname) > 0) then
    repeat with i = 1 to gEffects.count
      iefs = gEffects[i].efs
      repeat with j = 1 to iefs.count
        jef = iefs[j]
        if (jef.nm = efname) then
          cEff = jef
          exit repeat
        end if
      end repeat
      if (cEff <> VOID) then exit repeat
    end repeat
  end if
  
  -- Draw the effect
  if (cEff <> VOID) then
    effGraf = member("previewImprt")
    if (gLastImported <> cEff.nm) then
      member("previewImprt").importFileInto("Effects/" & cEff.nm & ".png")
      effGraf.name = "previewImprt"
      gLastImported = cEff.nm
    end if
    effGraf = effGraf.image
    
    -- Get what layers
    repeatL = [1]
    if (cEff.findPos("repeatL") > 0) then
      repeatL = cEff["repeatL"]
    end if
    totalLayers = 0
    repeat with num in repeatL
      totalLayers = totalLayers + num
    end repeat
    totalImageLayers = repeatL.count
    currentImageLayer = 0
    
    -- Switch statement for type
    case cEff.tp of
      "standardPlant", "standardHanger", "standardClinger": -- standard plant effect
        ApplyCustomStandardPlant(q, c, effectr, cEff, effGraf, repeatL, totalLayers)
        
      "grower", "hanger", "clinger": -- grower effect and its extended family 
        ApplyCustomGrower(q, c, effectr, cEff, effGraf, repeatL, totalLayers)
        
      "individual", "individualHanger", "individualClinger": -- individual plant effect
        ApplyCustomIndividual(q, c, effectr, cEff, effGraf, repeatL, totalLayers)
        
      "wall": -- things that get placed on wall
        ApplyCustomWall(q, c, effectr, cEff, effGraf, repeatL, totalLayers)
        
      "texture": --things that add textures to the wall
        ApplyCustomEffTexture(q, c, effectr, cEff, effGraf)
        
        -- todo: maybe corruption-like?
    end case
  end if
end


-- Covers: standardPlant, standardHanger, standardClinger
on ApplyCustomStandardPlant (q, c, effectr, cEff, effGraf, repeatL, totalLayers)
  q2 = q + gRenderCameraTilePos.locH
  c2 = c + gRenderCameraTilePos.locV
  mtrx = effectr.mtrx
  totalImageLayers = repeatL.count
  currentImageLayer = 0
  
  -- Get potential layers
  case lrSup of
    "All":
      lsL = [1, 2, 3]
    "1":
      lsL = [1]
    "2":
      lsL = [2]
    "3":
      lsL = [3]
    "1:st and 2:nd":
      lsL = [1, 2]
    "2:nd and 3:rd":
      lsL = [2, 3]
    otherwise:
      lsL = [1, 2, 3]
  end case
  
  -- Get amount
  amount = 17
  if (cEff.findPos("placeAmt") > 0) then
    amount = cEff.placeAmt
  end if
  
  -- Now we place the effect
  repeat with layer in lsL
    solidCheck = solidAfaMv(point(q2,c2+1),layer) 
    if cEff.tp = "standardHanger" then
      solidCheck = solidAfaMv(point(q2,c2-1),layer)
    else if cEff.tp = "standardClinger" then
      solidCheck = solidAfaMv(point(q2-1,c2),layer) + solidAfaMv(point(q2+1,c2),layer)
    end if
    
    if solidMtrx[q2][c2][layer]=0 and solidCheck>=1 then
      repeat with i = 1 to mtrx[q2][c2] * 0.01 * amount then
        repeatLTemp = repeatL.duplicate()
        currentImageLayer = 0
        pnt = giveGroundPosCustom(q,c,layer, cEff.tp)
        clingerMult = (giveMiddleOfTile(point(q,c)).locH>pnt.locH)
        d = random(9) + ((layer-1)*10)
        
        var = random(cEff.vars)
        if cEff.findPos("strengthAffectVar") then var = random(restrict((cEff.vars*(mtrx[q2][c2]-11+random(21))*0.01).integer, 1, cEff.vars))
        rot = 0
        if cEff.findPos("randRot") then rot = random(cEff.randRot * 2 + 1) - cEff.randRot
        
        sz = (random(41) + 79) / 100.0 -- default range: 0.8 to 1.2 (inclusive)
        if cEff.findPos("szVar") then
          if cEff.szVar[1] = cEff.szVar[2] then
            sz = cEff.szVar[1]
          else if cEff.findPos("strengthAffectSize") then
            sz = cEff.szVar[1] * (1.0 - power(mtrx[q2][c2] / 100.0, 0.85)) + cEff.szVar[2] * power(mtrx[q2][c2] / 100.0, 0.85)
          else
            sz = (random((cEff.szVar[2] * 1000.0 - cEff.szVar[1] * 1000.0)) / 1000.0) + cEff.szVar[1]
          end if
        end if
        
        rot = 0
        if cEff.findPos("rotVar") then
          rot = random(cEff.rotVar * 2 + 1) - cEff.rotVar
        end if
        case cEff.tp of
          "standardHanger":
            rot = rot + 180
          "standardClinger":
            if clingerMult = 1 then
              rot = rot + 90
            else
              rot = rot + 270
            end if
        end case
        
        flp = 0
        if cEff.findPos("randomFlip") then
          if cEff.randomFlip then flp = random(2)-1
        end if
        rootAmt = 5
        if cEff.findPos("rootAmt") then rootAmt = cEff.rootAmt
        
        qd = rotateRectAroundPoint(rect(-(cEff.pxlSz.locH/2.0)*sz, -cEff.pxlSz.locV*sz, (cEff.pxlSz.locH/2.0)*sz, rootAmt), pnt, rot)
        if flp then qd = flipQuadH(qd)
        
        useEffCol = 0
        if cEff.findPos("pickColor") then
          if cEff.pickColor then useEffCol = 1
        end if
        
        repeat with dL = 0 to totalLayers-1
          if d + dL > 29 then exit repeat
          
          -- Draw
          grab = rect(cEff.pxlSz.locH * (var-1), 1 + cEff.pxlSz.locV*currentImageLayer, cEff.pxlSz.locH * var, 1+cEff.pxlSz.locV*(currentImageLayer+1))
          if useEffCol then
            member("layer"&string(d + dL)).image.copyPixels(effGraf, qd, grab, {#color:colr, #ink:36})
            if colr <> color(0,255,0) then
              if cEff.findPos("hasGrad") then
                if cEff.hasGrad then grab = grab + rect(0, cEff.pxlSz.locV * totalImageLayers, 0, cEff.pxlSz.locV * totalImageLayers)
              end if
              copyPixelsToEffectColor(gdLayer, d + dL, qd, "previewImprt", grab, 0.5, VOID)
            end if
          else
            member("layer"&string(d + dL)).image.copyPixels(effGraf, qd, grab, {#ink:36})
            if cEff.findPos("forceGrad") then
              if cEff.forceGrad then
                grab = grab + rect(0, cEff.pxlSz.locV * totalImageLayers, 0, cEff.pxlSz.locV * totalImageLayers)
                copyPixelsToEffectColor("A", d + dL, qd, "previewImprt", grab, 0.5, VOID)
                copyPixelsToEffectColor("B", d + dL, qd, "previewImprt", grab, 0.5, VOID)
              end if
            end if
          end if
          
          -- Update layer count
          repeatLTemp[1] = repeatLTemp[1] - 1
          if repeatLTemp[1] = 0 then
            repeatLTemp.deleteAt(1)
            currentImageLayer = currentImageLayer + 1
            if repeatLTemp.count = 0 then 
              exit repeat
            end if
          end if
        end repeat
      end repeat
    end if
  end repeat
end

on giveGroundPosCustom q, c, l, t
  q2 = q + gRenderCameraTilePos.locH
  c2 = c + gRenderCameraTilePos.locV
  mdPnt = giveMiddleOfTile(point(q,c))
  pnt = mdPnt
  case t of
    "standardPlant":
      pnt = mdPnt + point(-11+random(21), 10)
      if (gLEprops.matrix[q2][c2][l][1]=3) then
        pnt.locV = pnt.locv - (pnt.locH-mdPnt.locH) - 5
      else if (gLEprops.matrix[q2][c2][l][1]=2) then
        pnt.locV = pnt.locv - (mdPnt.locH-pnt.locH) - 5
      end if
      
    "standardHanger":
      pnt = mdPnt - point(-11+random(21), 10)
      if (gLEprops.matrix[q2][c2][l][1]=4) then
        pnt.locV = pnt.locv + (pnt.locH-mdPnt.locH) + 5
      else if (gLEprops.matrix[q2][c2][l][1]=5) then
        pnt.locV = pnt.locv + (mdPnt.locH-pnt.locH) + 5
      end if
      
    "standardClinger":
      case effSide of
        "L":
          side = 1
          pnt = mdPnt - point(10, -11+random(21))
        "R":
          side = 2
          pnt = mdPnt + point(10, -11+random(21))
        otherwise:
          side = random(2)
          pnt = mdPnt + point(10 * ((side - 1) * 2 - 1), -11+random(21))
      end case
      
      if (gLEprops.matrix[q2][c2][l][1]=(5-side)) then
        pnt.locH = pnt.locH + ((pnt.locV-mdPnt.locV) + 5) * ((side - 1) * 2 - 1)
      else if (gLEprops.matrix[q2][c2][l][1]=(4+side)) then
        pnt.locH = pnt.locH + ((mdPnt.locV-pnt.locV) + 5) * ((side - 1) * 2 - 1)
      end if
      
  end case
  return pnt
end


-- Used for: grower, hanger, clinger
on ApplyCustomGrower (q, c, effectr, cEff, effGraf, repeatL, totalLayers)
  q2 = q + gRenderCameraTilePos.locH
  c2 = c + gRenderCameraTilePos.locV
  mtrx = effectr.mtrx
  totalImageLayers = repeatL.count
  currentImageLayer = 0
  
  -- Get what layers but for the tip
  repeatLTip = [1]
  if (cEff.findPos("repeatLTip") > 0) then
    repeatL = cEff["repeatLTip"]
  end if
  totalLayersTip = 0
  repeat with num in repeatLTip
    totalLayersTip = totalLayersTip + num
  end repeat
  totalImageLayersTip = repeatL.count
  currentImageLayerTip = 0
  
  -- Now potentially draw
  if (random(100) < mtrx[q2][c2]) and (random(3) > 1) then
    
    case lrSup of
      "All":
        d = random(29)
      "1":
        d = random(9)
      "2":
        d = random(10) - 1 + 10
      "3":
        d = random(10) - 1 + 20
      "1:st and 2:nd":
        d = random(19)
      "2:nd and 3:rd":
        d = random(20) - 1 + 10
      otherwise:
        d = random(29)
    end case
    lr = 1 + (d > 9) + (d > 19)
    
    -- Figure out grow direction
    case cEff.tp of
      "grower": -- the normal kind.
        growDir = 180
      "hanger": -- growers but they grow upside down.
        growDir = 0
      "clinger": -- growers but they grow from the sides. how fancy!
        side = random(2)-1
        if effSide = "L" then side = 0
        else if effSide = "R" then side = 1
        if side = 1 then growDir = 90
        else growDir = 270
    end case
    
    -- Do we have a tip? If so, do setup
    doingTip = 0
    if cEff.findPos("tipGraf") then
      doingTip = 1
    end if
    
    -- Set up other variables
    sz = 1.0
    blnd = 1.0
    blnd2 = 1.0
    varBias = 0
    if cEff.findPos("heightAffectVar") > 0 then
      if cEff.heightAffectVar < 0 then
        varBias = 1
      end if
    end if
    mdPnt = giveMiddleOfTile(point(q,c))
    pnt = mdPnt + point(random(21)-11, random(21)-11)
    lastDir = growDir + random(cEff.initRotVar * 2 + 1) - cEff.initRotVar
    
    if cEff.findPos("szChange") then
      sz = cEff.szChange[1]
    end if
    
    -- Exit early if trying to place in a solid tile
    tlPos = giveGridPos(pnt) + gRenderCameraTilePos
    if solidAfaMv(tlPos, lr) then
      return
    end if
    
    -- Draw loop: as with every grower, draw from tip to ground (or void)
    partsToDraw = []
    drawQuad = 1-skyRootsFix
    repeat while (pnt.locV < gLOprops.size.locV * 20 + 3000) and (pnt.locV > -3000) and (pnt.locH < gLOprops.size.locH * 20 + 3000) and (pnt.locH > -3000) then
      if doingTip = 1 then
        pxlSz = cEff.tipPxlSz
        moveAmt = cEff.tipMoveAmt
      else
        pxlSz = cEff.pxlSz
        moveAmt = cEff.segmentMoveAmt
      end if
      
      -- Figure out grow direction and take a step in that direction. The area between the step is the segment.
      dir = growDir + random(cEff.segmentRotVar * 2 + 1) - cEff.segmentRotVar
      dir = lerp(lastDir, dir, cEff.segmentRotPull)
      lastPnt = pnt
      pnt = pnt + degToVec(dir) * moveAmt
      lastDir = dir
      
      -- Set up the quad
      qd = (lastPnt + pnt) / 2.0
      qd = rect(qd, qd) + rect(-pxlSz.locH*sz/2.0,-pxlSz.locV/2.0, pxlSz.locH*sz/2.0, pxlSz.locV/2.0)
      qd = rotateToQuadFix(qd, lookAtpoint(lastPnt, pnt))
      
      flp = 0
      if cEff.findPos("randomFlip") then
        if cEff.randomFlip then flp = random(2)-1
      end if
      if flp then
        qd = flipQuadH(qd)
      end if
      
      -- Push for later
      partAdded = [#qd:qd, #qd2:0, #doingTip:doingTip, #blnd:blnd, #blnd2:blnd2]
      partsToDraw.add(partAdded)
      
      -- Adjust per-segment variables
      if cEff.findPos("effectFadeOut") then
        blnd = blnd * cEff.effectFadeOut
      else
        blnd = blnd * 0.85
      end if
      
      if cEff.findPos("effectFadeOut2") then
        blnd2 = max(0.0, blnd2 - cEff.effectFadeOut2)
        qd = (lastPnt + pnt) / 2.0
        qd = rect(qd, qd) + rect(-pxlSz.locH*sz/1.6,-pxlSz.locV/1.6, pxlSz.locH*sz/1.6, pxlSz.locV/1.6)
        qd = rotateToQuadFix(qd, lookAtpoint(lastPnt, pnt))
        if flp then
          qd = flipQuadH(qd)
        end if
        partAdded.qd2 = qd
      end if
      
      if cEff.findPos("szChange") then
        sz = restrict(sz + random(1000)/1000.0 * cEff.szChange[3], min(cEff.szChange[1], cEff.szChange[2]), max(cEff.szChange[1], cEff.szChange[2]))
      end if
      
      -- Reset after tip
      doingTip = 0
      
      -- Stop once we hit solid ground
      tlPos = giveGridPos(pnt) + gRenderCameraTilePos
      
      if skyRootsFix and withinBoundsOfLevel(tlPos) = 0 then
        drawQuad = 0
        exit repeat
      end if
      
      if solidAfaMv(tlPos, lr) then
        drawQuad = 1
        exit repeat
      end if
    end repeat
    
    useEffCol = 0
    if cEff.findPos("pickColor") then
      if cEff.pickColor then
        useEffCol = 1
      end if
    end if
    
    if drawQuad then
      repeat with part in partsToDraw
        -- Setup
        if part.doingTip = 1 then
          vars = cEff.tipVars
          pxlSz = cEff.tipPxlSz
        else
          vars = cEff.vars
          pxlSz = cEff.pxlSz
        end if
        
        -- Load tip graphic if necessary
        if part.doingTip then
          effGraf = member("previewImprt")
          if gLastImported <> cEff.tipGraf then
            member("previewImprt").importFileInto("Effects/" & cEff.tipGraf & ".png")
            effGraf.name = "previewImprt"
            gLastImported = cEff.tipGraf
          end if
          effGraf = effGraf.image
        end if
        
        -- Pick a variation
        var = random(vars)
        if cEff.findPos("heightAffectVar") and (part.doingTip <> 1) then
          varBias = restrict(varBias + cEff.heightAffectVar, 0, 1)
          var = random(restrict((vars*varBias).integer, 1, vars))
        end if
        
        -- Duplicate layer info for reference
        tempLayers = totalLayers
        tempRepeatL = repeatL.duplicate()
        if part.doingTip then
          tempLayers = totalLayersTip
          tempRepeatL = repeatLTip.duplicate()
        end if
        currentImageLayer = 0
        tempImageLayers = tempRepeatL.count
        
        repeat with dL = 0 to tempLayers-1 then
          if d + dL > 29 then exit repeat
          
          -- Compute area to copy from
          grab = rect(pxlSz.locH * (var-1), 1 + pxlSz.locV*currentImageLayer, pxlSz.locH * var, 1 + pxlSz.locV*(currentImageLayer+1))
          
          -- Actually draw
          if useEffCol then
            member("layer"&string(d + dL)).image.copyPixels(effGraf, part.qd, grab, {#color:colr, #ink:36})
            if colr <> color(0,255,0) then
              grab = grab + rect(0, pxlSz.locV * tempImageLayers, 0, pxlSz.locV * tempImageLayers)
              copyPixelsToEffectColor(gdLayer, d + dL, part.qd, "previewImprt", grab, 0.5, part.blnd)
              
              if cEff.findPos("effectFadeOut2") and part.blnd2 > 0 and part.doingTip = 0 then
                copyPixelsToEffectColor(gdLayer, d + dL, part.qd2, "softBrush1", member("softBrush1").image.rect, 0.5, part.blnd2)
              end if
            end if
          else
            member("layer"&string(d + dL)).image.copyPixels(effGraf, part.qd, grab, {#ink:36})
            if cEff.findPos("forceGrad") then
              if cEff.forceGrad then
                grab = grab + rect(0, pxlSz.locV * tempImageLayers, 0, pxlSz.locV * tempImageLayers)
                copyPixelsToEffectColor("A", d + dL, part.qd, "previewImprt", grab, 0.5, part.blnd)
                copyPixelsToEffectColor("B", d + dL, part.qd, "previewImprt", grab, 0.5, part.blnd)
              end if
            end if
          end if
          
          -- Update layer tracking
          tempRepeatL[1] = tempRepeatL[1] - 1
          if tempRepeatL[1] = 0 then
            tempRepeatL.deleteAt(1)
            currentImageLayer = currentImageLayer + 1
            if tempRepeatL.count = 0 then 
              exit repeat
            end if
          end if
        end repeat
        
        -- Reset graphic if tip
        if part.doingTip then
          effGraf = member("previewImprt")
          if (gLastImported <> cEff.nm) then
            member("previewImprt").importFileInto("Effects/" & cEff.nm & ".png")
            effGraf.name = "previewImprt"
            gLastImported = cEff.nm
          end if
          effGraf = effGraf.image
        end if
      end repeat
    end if
    
  end if
end



-- Used for: individual, individualHanger, individualClinger
on ApplyCustomIndividual (q, c, effectr, cEff, effGraf, repeatL, totalLayers)
  q2 = q + gRenderCameraTilePos.locH
  c2 = c + gRenderCameraTilePos.locV
  mtrx = effectr.mtrx
  totalImageLayers = repeatL.count
  currentImageLayer = 0
  
  case lrSup of
    "All":
      d = random(29)
    "1":
      d = random(9)
    "2":
      d = random(10) - 1 + 10
    "3":
      d = random(10) - 1 + 20
    "1:st and 2:nd":
      d = random(19)
    "2:nd and 3:rd":
      d = random(20) - 1 + 10
    otherwise:
      d = random(29)
  end case
  lr = 1 + (d > 9) + (d > 19)
  
  solidCheck = solidAfaMv(point(q2,c2+1),lr) 
  if cEff.tp = "individualHanger" then
    solidCheck = solidAfaMv(point(q2,c2-1),lr)
  else if cEff.tp = "individualClinger" then
    solidCheck = solidAfaMv(point(q2-1,c2),lr) + solidAfaMv(point(q2+1,c2),lr)
  end if
  
  if solidMtrx[q2][c2][lr]=0 and solidCheck then
    -- Figure out variables
    mdPnt = giveMiddleOfTile(point(q,c))
    pnt = mdPnt + point(random(21)-11, 10)
    if cEff.tp = "individualHanger" then
      pnt = mdPnt + point(random(21)-11, -10)
    else if cEff.tp = "individualClinger" then
      clingerSide = -solidAfaMv(point(q2-1,c2),lr) + solidAfaMv(point(q2+1,c2),lr)
      pnt = mdPnt + point(10*clingerSide, random(21)-11)
    end if
    
    var = random(cEff.vars)
    if cEff.findPos("strengthAffectVar") then var = random(restrict((cEff.vars*(mtrx[q2][c2]-11+random(21))*0.01).integer, 1, cEff.vars))
    
    sz = (random(41) + 79) / 100.0 -- default range: 0.8 to 1.2 (inclusive)
    if cEff.findPos("szVar") then
      if cEff.szVar[1] = cEff.szVar[2] then
        sz = cEff.szVar[1]
      else 
        sz = (random((cEff.szVar[2] * 1000.0 - cEff.szVar[1] * 1000.0)) / 1000.0) + cEff.szVar[1]
      end if
    end if
    
    rot = 0
    if cEff.findPos("rotVar") then
      rot = random(cEff.rotVar * 2 + 1) - cEff.rotVar
    end if
    if cEff.tp = "individualHanger" then
      rot = rot + 180
    else if cEff.tp = "individualClinger" then
      rot = rot + 180 + 90 * clingerSide
    end if
    
    flp = 0
    if cEff.findPos("randomFlip") then
      if cEff.randomFlip then flp = random(2)-1
    end if
    rootAmt = 5
    if cEff.findPos("rootAmt") then rootAmt = cEff.rootAmt
    
    qd = rotateRectAroundPoint(rect(-(cEff.pxlSz.locH/2.0)*sz, -cEff.pxlSz.locV*sz, (cEff.pxlSz.locH/2.0)*sz, rootAmt), pnt, rot)
    if flp then qd = flipQuadH(qd)
    
    -- Draw the thing
    useEffCol = 0
    if cEff.findPos("pickColor") then
      if cEff.pickColor then useEffCol = 1
    end if
    
    repeat with dL = 0 to totalLayers-1
      -- Actually draw
      grab = rect(cEff.pxlSz.locH * (var-1), 1 + cEff.pxlSz.locV*currentImageLayer, cEff.pxlSz.locH * var, 1 + cEff.pxlSz.locV*(currentImageLayer+1))
      if useEffCol then
        member("layer"&string(d+dL)).image.copyPixels(effGraf, qd, grab, {#color:colr, #ink:36})
        if colr <> color(0,255,0) then
          if cEff.findPos("hasGrad") then
            if cEff.hasGrad then grab = grab + rect(0, cEff.pxlSz.locV * totalImageLayers, 0, cEff.pxlSz.locV * totalImageLayers)
          end if
          copyPixelsToEffectColor(gdLayer, d+dL, qd, "previewImprt", grab, 0.5, VOID)
        end if
      else
        member("layer"&string(d+dL)).image.copyPixels(effGraf, qd, grab, {#ink:36})
        if cEff.findPos("forceGrad") then
          if cEff.forceGrad then
            grab = grab + rect(0, cEff.pxlSz.locV * totalImageLayers, 0, cEff.pxlSz.locV * totalImageLayers)
            copyPixelsToEffectColor("A", d+dL, qd, "previewImprt", grab, 0.5, VOID)
            copyPixelsToEffectColor("B", d+dL, qd, "previewImprt", grab, 0.5, VOID)
          end if
        end if
      end if
      
      -- Update layer count
      repeatL[1] = repeatL[1] - 1
      if repeatL[1] = 0 then
        repeatL.deleteAt(1)
        currentImageLayer = currentImageLayer + 1
        if repeatL.count = 0 then 
          exit repeat
        end if
      end if
    end repeat
  end if
end



-- Used for: wall
on ApplyCustomWall(q, c, effectr, cEff, effGraf, repeatL, totalLayers)
  q2 = q + gRenderCameraTilePos.locH
  c2 = c + gRenderCameraTilePos.locV
  mtrx = effectr.mtrx
  totalImageLayers = repeatL.count
  currentImageLayer = 0
  
  case lrSup of
    "All":
      dmin = 0
      dmax = 29
    "1":
      dmin = 0
      dmax = 9
    "2":
      dmin = 10
      dmax = 19
    "3":
      dmin = 20
      dmax = 29
    "1:st and 2:nd":
      dmin = 0
      dmax = 19
    "2:nd and 3:rd":
      dmin = 10
      dmax = 29
    otherwise:
      dmin = 0
      dmax = 29
  end case
  
  mdPnt = giveMiddleOfTile(point(q,c))
  amount = 20
  if cEff.findPos("placeAmt") > 0 then
    amount = cEff.placeAmt
  end if
  
  repeat with k = 1 to max(1, (amount * mtrx[q2][c2] / 100.0).integer) then
    -- Figure out where and how big (we need ow big to figure out depth believe it or not)
    pnt = mdPnt + point(random(21)-11, random(21)-11)
    
    sz = (random(41) + 79) / 100.0 -- default range: 0.8 to 1.2 (inclusive)
    if cEff.findPos("szVar") then
      if cEff.szVar[1] = cEff.szVar[2] then
        sz = cEff.szVar[1]
      else if cEff.findPos("strengthAffectSize") then
        x = restrict(mtrx[q2][c2]-11+random(21),1,100)
        sz = cEff.szVar[1] * (1.0 - power(x / 100.0, 0.85)) + cEff.szVar[2] * power(x / 100.0, 0.85)
      else
        sz = (random((cEff.szVar[2] * 1000.0) - (cEff.szVar[1] * 1000.0)+1)-1) / 1000.0 + cEff.szVar[1]
      end if
    end if
    
    -- Figure out depth and if we can actually place it
    canPlace = 0
    d = -1
    lr = 0
    cl = color(255,255,255)
    repeat with dp = dmin to dmax then
      rad = sz/2.0
      repeat with dr in [point(0,0), point(-1,0), point(0,-1), point(0,1), point(1,0)] then
        tempPt = point((pnt.locH + dr.locH*rad).integer, (pnt.locV + dr.locV*rad).integer)
        if (member("layer"&string(dp)).getPixel(tempPt.locH, tempPt.locV) <> color(255,255,255)) then
          canPlace = 1
          cl = member("layer"&string(dp)).getPixel(tempPt.locH, tempPt.locV)
          if (cEff.findPos("can3D")>0) then
            if cEff.can3D = 1 or (cEff.can3D = 2 and effectIn3D) then
              d = max(0, dp - 2)
            else
              d = dp
            end if
          else
            d = dp
          end if
          lr = 1 + (d > 9) + (d > 19)
          exit repeat
        end if
      end repeat
      if canPlace = 1 then exit repeat
    end repeat
    
    if (canPlace=1) and (cEff.findPos("requireSolid") > 0) then
      if cEff.requireSolid = 1 then
        canPlace = solidAfaMv(point(q2,c2),lr)
      end if
    end if
    
    -- Now draw it if we can
    if canPlace = 1 and d > -1 then
      d = restrict(d - 1 + random(2), dmin, dmax)
      
      var = random(cEff.vars)
      if cEff.findPos("strengthAffectVar") then var = random(restrict((cEff.vars*(mtrx[q2][c2]-11+random(21))*0.01).integer, 1, cEff.vars))
      grab = rect(cEff.pxlSz.locH*(var-1), 1, cEff.pxlSz.locH*var, 1+cEff.pxlSz.locV)
      
      rot = 0
      if cEff.findPos("randomRotat") then
        if cEff.randomRotat then rot = random(361) - 1
      end if
      
      flp = 0
      if cEff.findPos("randomFlip") then
        if cEff.randomFlip then flp = random(2)-1
      end if
      
      qd = rect(pnt, pnt) + rect(-(cEff.pxlSz/2.0), cEff.pxlSz/2.0)
      qd = rotateToQuadFix(qd, rot)
      if flp then qd = flipQuadH(qd)
      
      useEffCol = 0
      if cEff.findPos("pickColor") then
        if cEff.pickColor then useEffCol = 1
      end if
      
      if cEff.findPos("outline") then -- outline, if wanted
        if cEff.outline then
          repeat with j in [[point(-1,-1), color(0,0,255)], [point(-0,-1), color(0,0,255)], [point(-1,-0), color(0,0,255)], [point(1,1), color(255,0,0)],[point(0,1), color(255,0,0)],[point(1,0), color(255,0,0)]] then
            oqd = [qd[1] + j[1], qd[2] + j[1], qd[3] + j[1], qd[4] + j[1]]
            member("layer"&string(d)).image.copyPixels(effGraf, oqd, grab, {#color:j[2], #ink:36})
          end repeat
        end if
      end if
      
      if useEffCol then -- actually drawing
        member("layer"&string(d)).image.copyPixels(effGraf, qd, grab, {#color:colr, #ink:36})
        if colr <> color(0,255,0) then
          if cEff.findPos("hasGrad") then
            if cEff.hasGrad then grab = grab + rect(0, cEff.pxlSz.locV, 0, cEff.pxlSz.locV)
          end if
          copyPixelsToEffectColor(gdLayer, d, qd, "previewImprt", grab, 0.5, VOID)
        end if
      else
        member("layer"&string(d)).image.copyPixels(effGraf, qd, grab, {#ink:36})
        if cEff.findPos("forceGrad") then
          if cEff.forceGrad then
            grab = grab + rect(0, cEff.pxlSz.locV, 0, cEff.pxlSz.locV)
            copyPixelsToEffectColor("A", d, qd, "previewImprt", grab, 0.5, VOID)
            copyPixelsToEffectColor("B", d, qd, "previewImprt", grab, 0.5, VOID)
          end if
        end if
      end if
    end if
  end repeat
end



-- Used for: texture
on ApplyCustomEffTexture(q, c, effectr, cEff, effGraf)
  q2 = q + gRenderCameraTilePos.locH
  c2 = c + gRenderCameraTilePos.locV
  mtrx = effectr.mtrx
  
  layerImages = []
  layerImagesA = []
  layerImagesB = []
  
  repeat with dldld = 0 to 29 then
    layerImages.add(member("layer"&string(dldld)).image)
    layerImagesA.add(member("gradientA"&string(dldld)).image)
    layerImagesB.add(member("gradientB"&string(dldld)).image)
  end repeat
  
  case lrSup of
    "All":
      dmin = 0
      dmax = 29
    "1":
      dmin = 0
      dmax = 9
    "2":
      dmin = 10
      dmax = 19
    "3":
      dmin = 20
      dmax = 29
    "1:st and 2:nd":
      dmin = 0
      dmax = 19
    "2:nd and 3:rd":
      dmin = 10
      dmax = 29
    otherwise:
      dmin = 0
      dmax = 29
  end case
  
  clrMask = 2
  
  if (cEff.findPos("clrMask")) then -- masking to specific colours, ie 'only apply this to green pixels'
    clrMask = cEff.clrMask
  end if
  
  maskRed = (bitAnd(clrMask, 1) = 1)
  maskGreen = (bitAnd(clrMask, 2) = 2)
  maskBlue = (bitAnd(clrMask, 4) = 4)
  maskEffA = (bitAnd(clrMask, 8) = 8)
  maskEffB = (bitAnd(clrMask, 16) = 16)
  
  bleed = 0
  
  useEffCol = 0
  if cEff.findPos("pickColor") then
    if cEff.pickColor then useEffCol = 1
  end if
  
  if (cEff.findPos("bleed")) then -- 'bleed' being if the texture can apply through layers
    bleed = cEff.bleed
  end if
  
  placeAmt = 20
  if (cEff.findPos("placeAmt")) then
    placeAmt = cEff.placeAmt
  end if
  
  affop = 0.05
  if (cEff.findPos("affectOpenAreas")) then
    affop = cEff.affectOpenAreas
  end if
  
  requireSolid = 0
  if (cEff.findPos("requireSolid")) then
    requireSolid = cEff.requireSolid
  end if
  
  fc = affop + (1.0-affop)* (1-((1-solidAfaMv(point(q2,c2), 3)) * requireSolid))
  
  repeat with dt = 1 to 30
    lr = 30-dt
    if (lr = 9) or (lr = 19) then
      lraddc = 1+(dt>9)+(dt>19)
      sld = (1-((1-solidMtrx[q2][c2][lraddc]) * requireSolid))
      fc = affop + (1.0 - affop) * (1-((1-solidAfaMv(point(q2,c2), lraddc)) * requireSolid))
    end if
    
    deepEffect = 0
    if (lr = 0) or (lr = 10) or (lr = 20) or (sld = 0) then
      deepEffect = 1
    end if
    
    effSt = mtrx[q2][c2]
    
    placeCount = effSt * (0.2 + (0.8 * deepEffect)) * 0.01 * placeAmt * fc
    
    if (lr >= dmin) and (lr <= dmax) then
      repeat with placed = 1 to placeCount then
        pnt = giveMiddleOfTile(point(q,c)) + point(random(21)-11, random(21)-11)
        
        if deepEffect then
          pnt = (point(q-1, c-1)*20)+point(random(20), random(20))
        else
          if random(2)=1 then
            pnt = (point(q-1, c-1)*20)+point(1 + 19*(random(2)-1), random(20))
          else 
            pnt = (point(q-1, c-1)*20)+point(random(20), 1 + 19*(random(2)-1))
          end if
        end if
        
        var = random(cEff.vars)
        
        if (cEff.findPos("strengthAffectVar")) then
          if cEff.strengthAffectVar then
            var = random(restrict((cEff.vars*(effSt-11+random(21))*0.01).integer, 1, cEff.vars))
          end if
        end if
        
        repeat with lch = 0 to (cEff.pxlSz.locH - 1) then
          repeat with lcv = 0 to (cEff.pxlSz.locV - 1) then
            gtCl = effGraf.getPixel(lch + (var - 1) * cEff.pxlSz.locH, lcv + 1)
            if (gtCl <> DRWhite) then
              repeat with lr2 = lr to restrict(lr + bleed, dmin, 29) then
                
                layerlr = layerImages[lr2 + 1]
                layerlrA = layerImagesA[lr2 + 1]
                layerlrB = layerImagesB[lr2 + 1]
                layerlrAB = [layerlrA, layerlrB]
                
                lrClr = layerlr.getPixel(pnt.locH - (cEff.pxlSz.locH / 2) + lch, pnt.locV - (cEff.pxlSz.locV / 2) + lcv)
                
                if doesColorFitMask(lrClr, maskRed, maskGreen, maskBlue, maskEffA, maskEffB) then
                  if useEffCol then
                    layerlr.setPixel(pnt.locH - (cEff.pxlSz.locH / 2) + lch, pnt.locV - (cEff.pxlSz.locV / 2) + lcv, colr)
                    if (cEff.findPos("hasGrad")) then
                      if cEff.hasGrad then
                        gradClr = effGraf.getPixel(lch + (var - 1) * cEff.pxlSz.locH, lcv + 1 + cEff.pxlSz.locV)
                        if (gdLayer <> "C") then
                          layerlrAB[(gdLayer = "A") + (gdLayer = "B") * 2].setPixel(pnt.locH - (cEff.pxlSz.locH / 2) + lch, pnt.locV - (cEff.pxlSz.locV / 2) + lcv, gradClr)
                        end if
                      end if
                    end if
                  else
                    layerlr.setPixel(pnt.locH - (cEff.pxlSz.locH / 2) + lch, pnt.locV - (cEff.pxlSz.locV / 2) + lcv, gtCl)
                    
                    if (cEff.findPos("forceGrad")) then
                      if (cEff.forceGrad) then
                        gradClr = effGraf.getPixel(lch + (var - 1) * cEff.pxlSz.locH, lcv + 1 + cEff.pxlSz.locV)
                        layerlrA.setPixel(pnt.locH - (cEff.pxlSz.locH / 2) + lch, pnt.locV - (cEff.pxlSz.locV / 2) + lcv, gradClr)
                        layerlrB.setPixel(pnt.locH - (cEff.pxlSz.locH / 2) + lch, pnt.locV - (cEff.pxlSz.locV / 2) + lcv, gradClr)
                      end if
                    end if
                  end if
                end if
              end repeat
            end if
          end repeat
        end repeat
      end repeat
    end if
  end repeat
end

on doesColorFitMask clr, maskRed, maskGreen, maskBlue, maskEffA, maskEffB -- if a color fits the mask specified
  if maskRed and clr = color(255, 0, 0) then
    return true
  end if
  
  if maskGreen and clr = color(0, 255, 0) then
    return true
  end if
  
  if maskBlue and clr = color(0, 0, 255) then
    return true
  end if
  
  if maskEffA then
    if maskRed and clr = color(150, 0, 150) then
      return true
    end if
    if maskGreen and clr = color(255, 0, 255) then
      return true
    end if
    if maskBlue and clr = color(255, 150, 255) then
      return true
    end if
  end if
  
  if maskEffB then
    if maskRed and clr = color(0, 150, 150) then
      return true
    end if
    if maskGreen and clr = color(0, 255, 255) then
      return true
    end if
    if maskBlue and clr = color(150, 255, 255) then
      return true
    end if
  end if
  
  return false
end


-- todo: maybe corruption-like?

