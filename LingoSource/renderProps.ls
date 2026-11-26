global gViewRender, c, gPEprops, keepLooping, gRenderCameraTilePos, gLastImported, gLastImportedImage, gProps, afterEffects, gAnyDecals, gRenderTrashProps, gCurrentlyRenderingTrash, gESoftProp, softProp, propsToRender, altGrafLG, DRPxl, DRRopeVari, DRBevelColors

on exitFrame(me)
  if (checkMinimize()) then
    _player.appMinimize()
  end if
  if (checkExit()) then
    _player.quit()
  end if
  if (gViewRender) then
    if (checkExitRender()) then
      _movie.go(9)
    end if
    me.newFrame()
    if (keepLooping) then
      go the frame
    end if
  else
    repeat while keepLooping
      me.newFrame()
    end repeat
  end if
end

on newFrame(me)
  type qd: list
  type propData: list
  if (softProp <> VOID) then
    if (gESoftProp < 1) then
      renderSoftProp()
    else
      renderESoftProp()
    end if
  else
    if (gCurrentlyRenderingTrash) then
      if (c > gRenderTrashProps.count) then
        gCurrentlyRenderingTrash = FALSE
        if (propsToRender.count > 0) then
          c = 1
          propData = propsToRender[c]
        else
          keepLooping = FALSE
          exit
        end if
      else
        propData = gRenderTrashProps[c]
      end if
    else
      if (c > propsToRender.count) then
        keepLooping = 0
        exit
      end if
      propData = propsToRender[c]
    end if
    dt3 = propData[3]
    prop = gProps[dt3.locH].prps[dt3.locV]
    prpSets = propData[5].settings
    if (ShouldThisPropRender(prop, propData[4], prpSets)) then
      me.updateText()
      qd = propData[4]
      dp = -propData[1]
      if (gCurrentlyRenderingTrash = FALSE) then
        qd = qd * (20.0 / 16.0)
      end if
      mdPoint: point = (qd[1] + qd[2] + qd[3] + qd[4]) / 4.0
      savSeed: number = the randomSeed
      global gLOprops
      the randomSeed = seedForTile(giveGridPos(mdPoint), prpSets.seed)
      if (gCurrentlyRenderingTrash = FALSE) then
        camPos20 = gRenderCameraTilePos * 20
        qd = qd - [camPos20, camPos20, camPos20, camPos20]
      end if
      if (gCurrentlyRenderingTrash) then
        data = []
      else
        data = propsToRender[c][5]
      end if
      renderProp(prop, dp, qd, mdPoint, data)
      the randomSeed = savSeed
    end if
    c = c + 1
  end if
end

on ShouldThisPropRender(prop, qd: list, settings)
  type return: number
  if (settings.renderTime <> afterEffects) then
    return FALSE
  end if
  if (gCurrentlyRenderingTrash = FALSE) then
    qd = qd * (20.0 / 16.0)
    camPos20 = gRenderCameraTilePos * 20
    qd = qd - [camPos20, camPos20, camPos20, camPos20]
  end if
  mdPoint: point = (qd[1] + qd[2] + qd[3] + qd[4]) / 4.0
  dig: number = 0
  repeat with q = 1 to 4
    if (DiagWI(mdPoint, qd[q], dig) = FALSE) then
      dig = Diag(mdPoint, qd[q])
    end if
  end repeat
  return diag(mdPoint, closestPntInRect(rect(-50, -100, 2050, 1100), mdPoint)) <= dig
end

on updateText(me)
  txt = "<RENDERING PROPS>" & RETURN
  viewProp: number = c
  if (softProp <> VOID) then
    viewProp: number = c - 1
  end if
  if (gCurrentlyRenderingTrash) then
    put "Trash props -   " & string(c) & " / " & string(gRenderTrashProps.count) & RETURN after txt
  else
    linesBefore = 0
    linesToAdd = []
    repeat with prp = 1 to propsToRender.count
      renderPrp = propsToRender[prp]
      propAddress: point = renderPrp[3]
      if (ShouldThisPropRender(gProps[propAddress.loch].prps[propAddress.locV], renderPrp[4], renderPrp[5].settings)) then
        if prp < viewProp then
          linesBefore = linesBefore + 1
        end if
        if (prp = viewProp) then
          linesToAdd.append(string(prp) & ". ->" & renderPrp[2])
        else
          linesToAdd.append(string(prp) & ". " & renderPrp[2])
        end if
      end if
    end repeat
    repeat with prpLine = 1 to linesToAdd.count 
      if linesBefore - 20 - prpLine <= 0 then
        put linesToAdd[prpLine] & RETURN after txt
      end if
    end repeat
  end if
  member("effectsL").text = txt
end

on renderProp(prop, dp: number, qd: list, mdPoint: point, data: object)
  type propImage: image
  if (gLastImported <> prop.nm) then
    tileAsProp: number = (prop.tags.getPos("Tile") > 0)
    if (tileAsProp) then
      path = "Graphics/" & prop.nm & ".png"
    else if (prop.tp = "customRope") then
      path = "Props/" & prop.nm & "Segment.png"
    else if (prop.tp = "customLong") then
      path = "Props/" & prop.nm & "Segment.png"
    else
      path = "Props/" & prop.nm & ".png"
    end if
    propImage = cacheLoadImage(path)
    gLastImported = prop.nm
    gLastImportedImage = propImage
  else
    propImage = gLastImportedImage
  end if
  --INTERNAL
  if (checkDRInternal(prop.nm)) then
    propImage = member(prop.nm).image
  end if
  case (prop.tp) of
    "standard", "variedStandard":
      renderVoxelProp(prop, dp, qd, mdPoint, data, propImage)
    "simpleDecal", "variedDecal":
      gAnyDecals = 1
      renderDecal(prop, dp, qd, mdPoint, data, propImage)
    "rope", "customRope":
      renderRope(prop, propsToRender[c][5], dp)
    "soft", "variedSoft", "antimatter", "coloredSoft":
      gESoftProp = 0
      initRenderSoftProp(prop, qd, data, dp, propImage)
    "softEffect":
      gESoftProp = 1
      initRenderSoftProp(prop, qd, data, dp, propImage)
    "long", "customLong":
      renderLongProp(qd, prop, propsToRender[c][5], dp)
    "fezTree":
      renderFezTree(prop, propsToRender[c][5], dp, data)
    "mosaicPlant":
      renderMosaicPlant(qd, mdPoint, prop, propsToRender[c][5].settings, dp, data)
  end case
  DoPropTags(prop, dp, qd)
end

on renderMosaicPlant(qd, mdPoint, prop, data, lr, propData)
  lr = min(lr, 28)
  -- Init
  case data.effectColor of
    "Color1":
      mpEffColor = "A"
      colr = color(255,0,255)
    "Dead":
      mpEffColor = "C"
      colr = color(0,255,0)
    otherwise:
      mpEffColor = "B"
      colr = color(0,255,255)
  end case
  
  case data.flowerColor of
    "Color2":
      mpFloColor = "B"
      colrDetail = color(0,255,255)
    "Dead":
      mpFloColor = "C"
      colrDetail = color(0,255,0)
    otherwise:
      mpFloColor = "A"
      colrDetail = color(255,0,255)
  end case
  
  case data.colorIntensity of
    "High":
      maxblnd = 0.8
    "Medium":
      maxblnd = 0.5
    "Low":
      maxblnd = 0.2
    "Random":
      maxblnd = random(3) * 0.3 - 0.1
    "None":
      maxblnd = 0
    otherwise:
      maxblnd = 0.5
  end case
  
  hasFlowers = data.hasFlowers > 0
  
  -- Figure out start point
  startPt = mdPoint - gRenderCameraTilePos*20
  sz = diag(qd[1], qd[2]) / 2.0
  
  -- Figure out leaf locations
  leaves = []
  maxIter = random(1500) + 500
  ofst = random(360.0)
  pt = startPt
  i = 1
  repeat while (diag(startPt, pt) < sz) or (i < 10 + random(6)) then
    ds = sqrt(i) * 0.3 * 20.0
    ang = i * PI * (3.0 - sqrt(5.0)) -- golden angle
    pt = startPt + point(cos(ang + ofst) * ds, sin(ang + ofst) * ds)
    
    leaves.append(pt)
    i = i + 1
  end repeat
  
  -- Filter out further out leaves
  oldL = leaves.count
  repeat with i = oldL down to 1 then
    if random(oldL) < i - 8 then
      leaves.deleteAt(i)
    end if
  end repeat
  
  -- FINALLY we get to draw the leaves :3
  grafSz = point(3, 6.5) -- mult by 2 to get actual size
  
  repeat with i = leaves.count down to 1 then -- reverse order for drawing reasons (outwards-in)
    leafPt = leaves[i]
    -- stem
    tl = (startPt + leafPt) / 2.0
    sz = point(1, (diag(startPt, leafPt)).integer) / 2.0
    qd = rotateToQuadFix(rect(tl, tl) + rect(-sz, sz), lookAtPoint(leafPt, startPt))
    member("layer"&string(lr+1)).image.copypixels(member("pxl").image, qd, rect(0,0,1,1), {#color:color(255,0,0), #ink:36})
    -- leaf
    tl = leafPt
    qd = rotateToQuadFix(rect(tl, tl) + rect(-grafSz, grafSz), lookAtPoint(leafPt, startPt))
    member("layer"&string(lr)).image.copypixels(member("mosaicLeafGraf").image, qd, rect(0,0,6,11), {#color:colr, #ink:36})
    if data.colorIntensity <> "None" then
      copyPixelsToEffectColor(mpEffColor, lr, qd, "mosaicLeafGraf", rect(6, 0, 12, 11), 0.5, maxblnd * (1 - (i.float / leaves.count.float) * 0.5))
    end if
  end repeat
  
  -- Guess what: flowers
  repeat with i = 1 to (leaves.count / 50.0).integer + 1 then
    if hasFlowers and random(3) = 1 then
      ds = random(diag(startPt, leaves[leaves.count])) * 0.45
      ang = random(360) / PI
      tl = startPt + point(cos(ang) * ds, sin(ang) * ds)
      
      ang = random(360/PI)
      amt = random(3) + 3
      flLr = restrict(lr-1, 0, 29)
      repeat with j = 1 to amt then
        tl2 = tl + (point(cos(ang), sin(ang)) * 6.5)
        qd = rotateToQuadFix(rect(tl2, tl2) + rect(-grafSz, grafSz), lookAtPoint(tl2, tl))
        member("layer"&string(flLr)).image.copypixels(member("mosaicLeafGraf").image, qd, rect(0,0,6,11), {#color:colrDetail, #ink:36})
        copyPixelsToEffectColor(mpFloColor, flLr, qd, "mosaicLeafGraf", rect(6, 0, 12, 11), 0.5, (random(10) + 90.0) / 100.0)
        ang = ang + (2 * PI / amt)
      end repeat
    end if
  end repeat
end

on renderFezTree(prop, data, dp: number, propData)
  writeMessage(data)
  treeParams = data.treeParameters
  treeBasePos = treeParams.trunkPos - gRenderCameraTilePos*20
  treeBaseAngle = treeParams.trunkAngle
  
  treeLeavesPos = treeParams.leafPos - gRenderCameraTilePos*20
  treeLeavesSize = treeParams.leafSize
  treeLeavesAngle = treeParams.leafAngle
  
  treeLeavesDensity = propData.settings.leafdensity
  
  treeLayer = clamp(dp + 8, 3, 25)
  --on drawFezTreeAtPosition treeBasePos, treeBaseAngle, treeLeavesPos, treeLeavesSize, treeLeavesAngle, treeLayer, effectLayer, leafDensity
  
  treeColorAsNumber = propData.settings.effectColor
  treeColor = "C"
  if treeColorAsNumber = 1 then 
    treeColor = "A"
  else if treeColorAsNumber = 2 then
    treeColor = "B"
  end if
  
  drawFezTreeAtPosition(treeBasePos, treeBaseAngle, treeLeavesPos, treeLeavesSize, treeLeavesAngle, treeLayer, treeColor, treeLeavesDensity)
end


on renderVoxelProp(prop, dp: number, qd: list, mdPoint: point, propData, propImage)
  type var: number
  type ps: number
  type colored: number
  type gtRect: rect
  type dumpImg: image
  type inverseImg: image
  type layerDpImg: image
  type a: list
  type variedStandard: number

  var = 0
  variedStandard = (prop.tp = "variedStandard")
  if (variedStandard) then
    var = propData.settings.variation - 1
  end if
  rockType = (prop.tags.getPos("rockType") > 0)
  ps = 0
  sav2 = member("previewImprt")
  --INTERNAL
  if (checkDRInternal(prop.nm)) then
    propImage = member(prop.nm).image
  end if
  sav2Img = sav2.image
  colored = (prop.tags.getPos("colored") > 0)
  if (colored) then
    gAnyDecals = 1
  end if
  effectColorA = (prop.tags.getPos("effectColorA") > 0)
  effectColorB = (prop.tags.getPos("effectColorB") > 0)
  repeat with q = 1 to prop.repeatL.count
    gtRect = rect(0, 1, prop.sz.locH * 20, prop.sz.locV * 20 + 1) 
    gtRect = gtRect + rect(gtRect.width * var, gtRect.height * ps, gtRect.width * var, gtRect.height * ps)
    repeat with q2 = 1 to prop.repeatL[q]
      if rockType and variedStandard and [12, 8, 4].getPos(q2) then
        -- Random variation in rock types
        var = random(prop.vars)
        gtRect = rect(0, 1, prop.sz.locH * 20, prop.sz.locV * 20 + 1) 
        gtRect = gtRect + rect(gtRect.width * var, gtRect.height * ps, gtRect.width * var, gtRect.height * ps)
      end if
      layerDpImg = member("layer" & string(dp)).image
      case (prop.colorTreatment) of
        "standard":
          layerDpImg.copyPixels(propImage, qd, gtRect, {#ink:36})
          if (effectColorA) then
            if (variedStandard) then
              member("gradientA" & string(dp)).image.copyPixels(propImage, qd, gtRect + rect(prop.sz.locH * 20 * prop.vars, 0, prop.sz.locH * 20 * prop.vars, 0), {#ink:39})
            else
              member("gradientA" & string(dp)).image.copyPixels(propImage, qd, gtRect + rect(prop.sz.locH * 20, 0, prop.sz.locH * 20, 0), {#ink:39})
            end if
          end if
          if (effectColorB) then
            if (variedStandard) then
              member("gradientB" & string(dp)).image.copyPixels(propImage, qd, gtRect + rect(prop.sz.locH * 20 * prop.vars, 0, prop.sz.locH * 20 * prop.vars, 0), {#ink:39})
            else
              member("gradientB" & string(dp)).image.copyPixels(propImage, qd, gtRect + rect(prop.sz.locH * 20, 0, prop.sz.locH * 20, 0), {#ink:39})
            end if
          end if
        "bevel":
          dumpImg = image(gtRect.width, gtRect.height, 1)
          dumpImg.copyPixels(propImage, dumpImg.rect, gtRect)
          inverseImg = makeSilhoutteFromImg(dumpImg, 1)
          dumpImg = image(layerDpImg.width, layerDpImg.height, 32)
          dumpImg.copyPixels(DRPxl, qd, rect(0, 0, 1, 1), {#color:color(0, 255, 0)})
          repeat with b = 1 to prop.bevel
            repeat with a in DRBevelColors
              a2mb = a[2] * b
              dumpImg.copyPixels(inverseImg, qd + [a2mb, a2mb, a2mb, a2mb], inverseImg.rect, {#color:a[1], #ink:36})
            end repeat
          end repeat
          dumpImg.copyPixels(inverseImg, qd, inverseImg.rect, {#color:color(255, 255, 255), #ink:36})
          inverseImg = image(dumpImg.width, dumpImg.height, 1)
          inverseImg.copyPixels(DRPxl, inverseImg.rect, rect(0, 0, 1, 1))
          inverseImg.copyPixels(DRPxl, qd, rect(0, 0, 1, 1), {#color:color(255, 255, 255)})
          dumpImg.copyPixels(inverseImg, dumpImg.rect, inverseImg.rect, {#color:color(255, 255, 255), #ink:36})
          layerDpImg.copyPixels(dumpImg, dumpImg.rect, dumpImg.rect, {#ink:36})
      end case
      if (colored) then
        if (effectColorA = FALSE) then
          if (effectColorB = FALSE) then
            if (variedStandard) then
              member("layer" & string(dp) & "dc").image.copyPixels(propImage, qd, gtRect + rect(prop.sz.locH * 20 * prop.vars, 0, prop.sz.locH * 20 * prop.vars, 0), {#ink:36})
            else
              member("layer" & string(dp) & "dc").image.copyPixels(propImage, qd, gtRect + rect(prop.sz.locH * 20, 0, prop.sz.locH * 20, 0), {#ink:36})
            end if
          end if
        end if
      end if
      dp = dp + 1
      if (dp > 29) then
        exit repeat
      end if
    end repeat
    if (dp > 29) then
      exit repeat
    end if
    ps = ps + 1
  end repeat
end


on renderDecal(prop, dp: number, qd: list, mdPoint: point, data, propImage: image)
  type rnd: number
  type ps: number
  type depthzero: number
  type dirq: list
  type actualDepth: number
  type averagesz: number
  type getrect: rect
  type clr: color
  rnd = 1
  ps = 1
  --INTERNAL
  if (checkDRInternal(prop.nm)) then
    propImage = member(prop.nm).image
  end if
  -- put "render decal"
  depthZero = dp
  repeat with testDp in [0, 10, 20] then
    if(dp <= testDp)and(dp + prop.depth > testDp)then
      depthZero = testDp
      exit repeat
    end if
  end repeat
  
  dirq = directionsQuad()
  
  actualDepth = prop.depth
  if(dp + prop.depth > 29)then
    actualDepth = 29 - dp
  end if
  
  averageSz = (Diag(qd[1], qd[2]) + Diag(qd[2], qd[3]) + Diag(qd[3], qd[4]) + Diag(qd[4], qd[1]))/4.0
  averageSz = (averageSz + 80.0)/2.0
  averageSz = averageSz / 12.0
  averageSz = averageSz / ((4.0 + actualDepth)/5.0)
  dirq = dirq * averageSz
  
  getRect = propImage.rect
  if(prop.tp = "variedDecal")then
    getRect = rect(prop.pxlSize.locH * (data.settings.variation-1), 0, prop.pxlSize.locH * data.settings.variation, prop.pxlSize.locV)+rect(0,1,0,1)
  end if
  
  clr = color(0,0,0)
  if(data.settings.findPos(#color) <> void) then
    if(data.settings.color > 0)then
      global gPEcolors
      clr = gPEcolors[data.settings.color][2]
    end if
  end if
  
  repeat with q = 1 to data.settings.customDepth then
    member("layer"&string(dp)&"dc").image.copyPixels(propImage, qd+(dirq*(dp-depthZero)), getRect, {#ink:36, #color:clr})
    dp = dp + 1
    if(dp > 29)then
      exit repeat
    end if
  end repeat
end

--used by renderDecal
on directionsQuad()
  type return: list
  type qDirs: list
  type frst: point
  type l1: list
  --  seed =  the randomSeed
  --  the randomSeed = gLOprops.tileSeed
  qDirs = []
  frst = degToVec(random(360))
  l1 = [[random(100), frst], [random(100), -frst], [random(100), degToVec(random(360))], [random(100), degToVec(random(360))]]
  l1.sort()
  repeat with q = 1 to 4 then
    qDirs.add(l1[q][2])
  end repeat
  
  return qDirs
  --  
  --  newImg = member(mem).image.duplicate()
  --  qd = [point(0,0), point(newImg.width, 0), point(newImg.width, newImg.height), point(0,newImg.height)]
  --  qd = qd + qDirs*fac
  --  member(mem).image.copypixels(newImg, qd, newImg.rect)
  --  
  --  the randomSeed = seed
end



on renderRope(prop, data, dp: number)
  type lastpos: point
  type lastdir: point
  type lastperp: point
  type pos: point
  type dir: point
  type perp: point

  lastPos = data.points[1]
  lastDir = MoveToPoint(lastPos, data.points[2], 1.0)
  lastPerp = CorrectPerp(lastDir)
  if (prop.tp = "customRope") then
    diffSeg = (prop.pixelSize.locV - prop.segmentLength) * 0.5
    if (prop.random) then
      DRRopeVari = random(prop.vars) - 1
    else
      DRRopeVari = 0
    end if
    repeat with q = 1 to data.points.count
      pos = data.points[q]
      if (q < data.points.count) then
        dir = dirVecLB(pos, data.points[q + 1])
      else
        dir = lastDir
      end if
      perp = CorrectPerp(dir)
      renderCustomRopeSegment(q, prop, data, dp, pos, dir, perp, lastPos, lastDir, lastPerp, diffSeg)
      lastPos = pos
      lastDir = dir
      lastPerp = perp
    end repeat
  else if (prop.nm = "Small Chain") or (prop.nm = "Fat Chain") then
    renderChainEffectProp(prop, data, dp)
  else
    repeat with q = 1 to data.points.count
      pos = data.points[q]
      if (q < data.points.count) then
        dir = MoveToPoint(pos, data.points[q + 1], 1.0)
      else
        dir = lastDir
      end if
      perp = CorrectPerp(dir)
      renderRopeSegment(q, prop, data, dp, pos, dir, perp, lastPos, lastDir, lastPerp)
      lastPos = pos
      lastDir = dir
      lastPerp = perp
    end repeat
  end if
end

on renderChainEffectProp(prop, data, dp)
  fat = (prop.nm = "Fat Chain")
  if fat then
    spacing = 16
    graf = "bigChainSegment"
  else
    spacing = 8
    graf = "chainSegment"
  end if
  
  -- Calculate length
  len = 0
  repeat with q = 1 to data.points.count - 1 then
    len = len + diag(data.points[q], data.points[q+1])
  end repeat
  numSegs = (len / spacing + 0.4999).integer
  if numSegs < 2 then numSegs = 2
  
  -- Draw segments
  repeat with q = 1 to numSegs then
    -- Sizes
    if (q mod 2) = 1 then
      grab = rect(0,0,6,10)
      place = rect(-3,-5,3,5)
      if fat then
        grab = grab * 2
        place = place * 2
      end if
    else
      grab = rect(7,0,8,10)
      place = rect(-1,-5,1,5)
      if fat then
        grab = rect(13,0,16,20)
        place = place * 2
      end if
    end if
    p = 1
    dst = q * spacing
    repeat with i = 1 to data.points.count - 1 then
      dst = dst - diag(data.points[i], data.points[i+1])
      if dst <= 0 then
        p = i + 1 + (dst / diag(data.points[i], data.points[i+1]))
        exit repeat
      end if
    end repeat
    pl = (p - 0.4999).integer
    pn = (p + 0.4999).integer
    lrp = p - pl
    if pl = pn then next repeat
    
    -- Draw
    lastPos = data.points[pl]
    nextPos = data.points[pn]
    pt = point(lerp(lastPos.locH, nextPos.locH, lrp), lerp(lastPos.locV, nextPos.locV, lrp)) - gRenderCameraTilePos*20
    dir = lookAtpoint(lastPos, nextPos)
    
    member("layer"&string(dp)).image.copyPixels(member(graf).image, rotateToQuadFix(rect(pt,pt)+place, dir), grab, {#color:color(255,0,0)})
  end repeat
end

on CorrectPerp(dir)
  --  if(dir = point(0, -1))then
  --    return point(1, 0)
  --  else if (dir = point(1, 0))then
  --    return point(1, 0)
  --  else if (dir = point(0, 1))then
  --    return point(0, 1)
  --  else if (dir = point(-1, 0))then
  --    return point(-1, 0)
  --  else
  return giveDirFor90degrToLine(-dir+point(0.001, -0.001), dir)
  -- end if
end

on renderBigChainSegment(ropePointIndex, ropeDepth, segmentStartPos, segmentEndPos)
  segmentDirection = MoveToPoint(segmentEndPos, segmentStartPos, 1.0)
  segmentPerpendicularDirection = point(segmentDirection.locV, -segmentDirection.locH)
  
  -- chains alternate between thick and thin segments.
  isThickChainSegment = ((ropePointIndex mod 2) = 0)
  isThinChainSegment = not isThickChainSegment
  
  if (isThickChainSegment) then
    wdth = 20
  else
    wdth = 7
  end if
  
  -- calculating the start and end pos for the chain sprite
  -- different from the segmentStartPos / segmentEndPos, for some reason.
  pntA = segmentStartPos + segmentDirection * 11
  pntB = segmentEndPos   - segmentDirection * 11
  
  -- box defining where the chain is drawn on the screen
  drawBox = [pntA - segmentPerpendicularDirection * wdth, pntA + segmentPerpendicularDirection * wdth, pntB + segmentPerpendicularDirection * wdth, pntB - segmentPerpendicularDirection * wdth]
  -- get it into camera space
  drawBox = drawBox - [gRenderCameraTilePos*20, gRenderCameraTilePos*20, gRenderCameraTilePos*20, gRenderCameraTilePos*20]
  
  highlightOffset = [point(-2,-2), point(-2,-2), point(-2,-2), point(-2,-2)]
  
  spriteHeight = 100
  thickSpriteWidth = 40
  thinSpriteWidth = 14
  
  repeat with graphicLayer = 0 to 5 then
    
    layerDepth = restrict(ropeDepth + graphicLayer, 0, 29)
    
    spriteRect = rect(0, 1 + (graphicLayer * spriteHeight), thickSpriteWidth, 1 + ((graphicLayer+1) * spriteHeight))
    if (isThinChainSegment) then
      spriteRect = spriteRect + rect(thickSpriteWidth, 0, thinSpriteWidth, 0)
    end if
    
    member("layer" & layerDepth).image.copyPixels(member("bigChainGraf").image, drawBox, spriteRect, {#ink:36})
    member("layer" & layerDepth).image.copyPixels(member("bigChainGrafHighLight").image, drawBox + highlightOffset, spriteRect, {#ink:36})
    
    -- draws the back side of the chain
    layerDepth = restrict(ropeDepth + 4 + graphicLayer, 0, 29)
    reverseGraphicLayer = 5 - graphicLayer
    
    spriteRect = rect(0, 1 + (reverseGraphicLayer * spriteHeight), thickSpriteWidth, 1 + ((reverseGraphicLayer+1) * spriteHeight))
    if (isThinChainSegment) then
      spriteRect = spriteRect + rect(thickSpriteWidth, 0, thinSpriteWidth, 0)
    end if
    
    member("layer" & layerDepth).image.copyPixels(member("bigChainGraf").image, drawBox, spriteRect, {#ink:36})
    member("layer" & layerDepth).image.copyPixels(member("bigChainGrafHighLight").image, drawBox + highlightOffset, spriteRect, {#ink:36})
  end repeat
end

on renderCustomRopeSegment(num, prop, data, dp, pos, dir, perp, lastPos, lastDir, lastPerp, diffSeg)
  dr = dirVecLB(pos, lastPos) * diffSeg
  wdth = prop.pixelSize.locH * 0.5
  if (num = 1) then
    pntA = lastPos + (dr + lastDir * wdth) * 0.5
    pntB = pos - 1.5 * dr - lastDir * wdth
  else
    pntA = lastPos + dr
    pntB = pos - dr
  end if
  pastQd = [pntA - lastPerp * wdth, pntA + lastPerp * wdth, pntB + lastPerp * wdth, pntB - lastPerp * wdth]
  renderCamMul = gRenderCameraTilePos * 20
  pastQd = pastQd - [renderCamMul, renderCamMul, renderCamMul, renderCamMul]
  sav2 = member("previewImprt")
  colored = (prop.tags.getPos("colored") > 0)
  if (colored) then
    gAnyDecals = 1
  end if
  effectColorA = (prop.tags.getPos("effectColorA") > 0)
  effectColorB = (prop.tags.getPos("effectColorB") > 0)
  ps = 0
  repeat with q = 1 to prop.repeatL.count
    gtRect = rect(0, 1, prop.pixelSize.locH, prop.pixelSize.locV + 1)
    gtRect = gtRect + rect(gtRect.width * DRRopeVari, gtRect.height * ps, gtRect.width * DRRopeVari, gtRect.height * ps)
    repeat with q2 = 1 to prop.repeatL[q]
      layerImg = member("layer" & string(dp)).image
      case (prop.colorTreatment) of
        "standard":
          layerImg.copyPixels(sav2.image, pastQd, gtRect, {#ink:36})
          if (effectColorA) then
            member("gradientA" & string(dp)).image.copyPixels(sav2.image, pastQd, gtRect + rect(prop.pixelSize.locH * prop.vars, 0, prop.pixelSize.locH * prop.vars, 0), {#ink:39})
          end if
          if (effectColorB) then
            member("gradientB" & string(dp)).image.copyPixels(sav2.image, pastQd, gtRect + rect(prop.pixelSize.locH * prop.vars, 0, prop.pixelSize.locH * prop.vars, 0), {#ink:39})
          end if
        "bevel":
          dumpImg = image(gtRect.width,  gtRect.height, 1)
          dumpImg.copyPixels(sav2.image, dumpImg.rect, gtRect)
          inverseImg = makeSilhoutteFromImg(dumpImg, 1)
          dumpImg = image(layerImg.width, layerImg.height, 32)
          dumpImg.copyPixels(DRPxl, pastQd, rect(0, 0, 1, 1), {#color:color(0, 255, 0)})
          repeat with bbvl = 1 to prop.bevel
            repeat with abvl in DRBevelColors
              a2mb = abvl[2] * bbvl
              dumpImg.copyPixels(inverseImg, pastQd + [a2mb, a2mb, a2mb, a2mb], inverseImg.rect, {#color:abvl[1], #ink:36})
            end repeat
          end repeat
          dumpImg.copyPixels(inverseImg, pastQd, inverseImg.rect, {#color:color(255, 255, 255), #ink:36})
          inverseImg = image(dumpImg.width, dumpImg.height, 1)
          inverseImg.copyPixels(DRPxl, inverseImg.rect, rect(0, 0, 1, 1))
          inverseImg.copyPixels(DRPxl, pastQd, rect(0, 0, 1, 1), {#color:color(255, 255, 255)})
          dumpImg.copyPixels(inverseImg, dumpImg.rect, inverseImg.rect, {#color:color(255, 255, 255), #ink:36})
          layerImg.copyPixels(dumpImg, dumpImg.rect, dumpImg.rect, {#ink:36})
      end case
      if (colored) then
        if (effectColorA = FALSE) then
          if (effectColorB = FALSE) then
            member("layer" & string(dp) & "dc").image.copyPixels(sav2.image, pastQd, gtRect + rect(prop.pixelSize.locH * prop.vars, 0, prop.pixelSize.locH * prop.vars, 0), {#ink:36})
          end if
        end if
      end if
      dp = dp + 1
      if (dp > 29) then
        exit repeat
      end if
    end repeat
    if (dp > 29) then
      exit repeat
    end if
    ps = ps + 1
  end repeat
  if (prop.random) then
    DRRopeVari = random(prop.vars) - 1
  else
    DRRopeVari = DRRopeVari + 1
    if (DRRopeVari >= prop.vars) then
      DRRopeVari = 0
    end if
  end if
end

on renderRopeSegment(num: number, prop, data, dp: number, pos: point, dir: point, perp: point, lastPos: point, lastDir: point, lastPerp: point)
  case prop.nm of
    "wire", "Zero-G Wire":
      wdth = data.settings.thickness/2.0
      
      pastQd = [pos - perp*wdth, pos + perp*wdth, lastPos + lastPerp*wdth, lastPos - lastPerp*wdth]
      pastQd = pastQd - [gRenderCameraTilePos*20, gRenderCameraTilePos*20, gRenderCameraTilePos*20, gRenderCameraTilePos*20]
      
      member("layer"&string(dp)).image.copyPixels(member("pxl").image, pastQd, rect(0,0,1,1), {#color:color(255, 0,0)})
      
    "Christmas Wire":
      wdth = 8.5
      pastQd = [pos + perp*wdth, pos - perp*wdth, lastPos - lastPerp*wdth, lastPos + lastPerp*wdth]
      pastQd = pastQd - [gRenderCameraTilePos*20, gRenderCameraTilePos*20, gRenderCameraTilePos*20, gRenderCameraTilePos*20]
      
      member("layer"&string(dp)).image.copyPixels(member("christmasWireGraf"&altGrafLG).image, pastQd, rect(0,1,17,25), {#ink:36})
      member("gradientA"&string(dp)).image.copyPixels(member("christmasWireGrad").image, pastQd, rect(0,1,17,25), {#ink:39})
      member("gradientB"&string(dp)).image.copyPixels(member("christmasWireGrad").image, pastQd, rect(0,1,17,25), {#ink:39})
      if altGrafLG = "1" then
        altGrafLG = "2"
      else
        altGrafLG = "1"
      end if
      
    "Ornate Wire":
      wdth = 8.5
      pastQd = [pos + perp*wdth, pos - perp*wdth, lastPos - lastPerp*wdth, lastPos + lastPerp*wdth]
      pastQd = pastQd - [gRenderCameraTilePos*20, gRenderCameraTilePos*20, gRenderCameraTilePos*20, gRenderCameraTilePos*20]
      
      rcTc = rect(0,1,17,25)
      member("layer"&string(dp)).image.copyPixels(member("tangledWireGraf").image, pastQd, rcTc, {#ink:36})
      member("gradientA"&string(dp)).image.copyPixels(member("tangledWireGrad").image, pastQd, rcTc, {#ink:39})
      member("gradientB"&string(dp)).image.copyPixels(member("tangledWireGrad").image, pastQd, rcTc, {#ink:39})
      
    "tube":
      wdth = 5.0
      
      pastQd = [pos - perp*wdth, pos + perp*wdth, lastPos + lastPerp*wdth, lastPos - lastPerp*wdth]
      pastQd = pastQd - [gRenderCameraTilePos*20, gRenderCameraTilePos*20, gRenderCameraTilePos*20, gRenderCameraTilePos*20]
      
      repeat with a = 1 to 4 then
        if(dp + a <= 30)then
          member("layer"&string(dp + a - 1)).image.copyPixels(member("tubeGraf").image, pastQd, rect(0,(a-1)*10,10,a*10), {#ink:36})
        else 
          exit repeat
        end if
      end repeat
      
      
    "ThickWire":
      wdth = 2
      pastQd = [pos - perp*wdth, pos + perp*wdth, lastPos + lastPerp*wdth, lastPos - lastPerp*wdth]
      pastQd = pastQd - [gRenderCameraTilePos*20, gRenderCameraTilePos*20, gRenderCameraTilePos*20, gRenderCameraTilePos*20]
      
      repeat with a = 1 to 3 then
        if(dp + a <= 30)then
          member("layer"&string(dp + a - 1)).image.copyPixels(member("thickWireGraf").image, pastQd, rect(0,(a-1)*4,4,a*4), {#ink:36})
        else 
          exit repeat
        end if
      end repeat
      
      
    "RidgedTube":
      wdth = 5
      pastQd = [pos - perp*wdth, pos + perp*wdth, lastPos + lastPerp*wdth, lastPos - lastPerp*wdth]
      pastQd = pastQd - [gRenderCameraTilePos*20, gRenderCameraTilePos*20, gRenderCameraTilePos*20, gRenderCameraTilePos*20]
      
      repeat with a = 1 to 4 then
        if(dp + a <= 30)then
          member("layer"&string(dp + a - 1)).image.copyPixels(member("ridgedTubeGraf").image, pastQd, rect(0,(a-1)*10,5,a*10), {#ink:36})
        else 
          exit repeat
        end if
      end repeat
      
      
    "Fuel Hose", "Zero-G Tube":
      wdth = 7
      jointSize = 6
      col = 0
      if(prop.nm = "Zero-G Tube")then
        wdth = 6
        jointSize = 4
        if(data.settings.applyColor = 1)then
          col = 1
          gAnyDecals = 1
        end if
      end if
      myPerp = lastPerp
      pastQd = [pos - myPerp*wdth, pos + myPerp*wdth, lastPos + myPerp*wdth, lastPos - myPerp*wdth]
      pastQd = pastQd - [gRenderCameraTilePos*20, gRenderCameraTilePos*20, gRenderCameraTilePos*20, gRenderCameraTilePos*20]
      
      
      repeat with a = 1 to 5 then
        if(dp + a <= 30)then
          member("layer"&string(dp + a - 1)).image.copyPixels(member("fuelHoseGraf").image, pastQd, rect(0,1+(a-1)*16,14,1+a*16), {#ink:36})
          if(col = 1)then
            member("layer"&string(dp + a - 1)&"dc").image.copyPixels(member("fuelHoseCol").image, pastQd, rect(0,1+(a-1)*16,14,1+a*16), {#ink:36})
          end if
        else 
          exit repeat
        end if
      end repeat
      
      repeat with a = 1 to 4 then
        if(dp + a <= 29)then
          member("layer"&string(dp + a)).image.copyPixels(member("fuelHoseJoint").image, rect(pos, pos)+rect(-jointSize,-jointSize,jointSize,jointSize)-rect(gRenderCameraTilePos*20,gRenderCameraTilePos*20), rect(0,1+(a-1)*12,12,1+a*12), {#ink:36})
        else 
          exit repeat
        end if
      end repeat
      
    "Broken Fuel Hose":
      
      dr = MoveToPoint(pos, lastPos, 1.0)
      dst = diag(pos, lastPos)
      
      repeat with b = 0 to 2 then
        wdth = 5
        
        pntA = pos + dr*(dst/3.0)*b
        pntB = pos + dr*(dst/3.0)*(b+1)
        
        Aprp = MoveToPoint(point(0,0), point( lerp(lastPerp.loch, perp.loch, b/3.0), lerp(lastPerp.locv, perp.locv, b/3.0)), 1.0)
        Bprp = MoveToPoint(point(0,0), point( lerp(lastPerp.loch, perp.loch, (b+1)/3.0), lerp(lastPerp.locv, perp.locv, (b+1)/3.0)), 1.0)
        
        pastQd = [pntA - Aprp*wdth, pntA + Aprp*wdth, pntB + Bprp*wdth, pntB - Bprp*wdth]
        pastQd = pastQd - [gRenderCameraTilePos*20, gRenderCameraTilePos*20, gRenderCameraTilePos*20, gRenderCameraTilePos*20]
        
        
        repeat with a = 2 to 5 then
          if(dp + a <= 29)then
            member("layer"&string(dp + a)).image.copyPixels(member("ridgedTubeGraf").image, pastQd, rect(0,(a-1)*10,5,a*10), {#ink:36})
          else 
            exit repeat
          end if
        end repeat
      end repeat
      
      
      if(random(5)<4)then
        wdth = 7
        myPerp = lastPerp
        pastQd = [pos - myPerp*wdth, pos + myPerp*wdth, lastPos + myPerp*wdth, lastPos - myPerp*wdth]
        pastQd = pastQd - [gRenderCameraTilePos*20, gRenderCameraTilePos*20, gRenderCameraTilePos*20, gRenderCameraTilePos*20]
        
        repeat with a = 1 to 5 then
          if(dp + a <= 30)then
            member("layer"&string(dp + a - 1)).image.copyPixels(member("fuelHoseGraf").image, pastQd, rect(0,1+(a-1)*16,14,1+a*16), {#ink:36})
          else 
            exit repeat
          end if
        end repeat
        
        repeat with a = 1 to 4 then
          if(dp + a <= 29)then
            member("layer"&string(dp + a)).image.copyPixels(member("fuelHoseJoint").image, rect(pos, pos)+rect(-6,-6,6,6)-rect(gRenderCameraTilePos*20,gRenderCameraTilePos*20), rect(0,1+(a-1)*12,12,1+a*12), {#ink:36})
          else 
            exit repeat
          end if
        end repeat
      end if
      
    "Large Chain", "Large Chain 2":
      dr = MoveToPoint(pos, lastPos, 1.0)
      dst = diag(pos, lastPos)
      if((num mod 2)=0)then
        wdth = 10
      else
        wdth = 3.5
      end if
      
      pntA = lastPos + dr*11
      pntB = pos - dr*11
      
      pastQd = [pntA - lastPerp*wdth, pntA + lastPerp*wdth, pntB + lastPerp*wdth, pntB - lastPerp*wdth]
      pastQd = pastQd - [gRenderCameraTilePos*20, gRenderCameraTilePos*20, gRenderCameraTilePos*20, gRenderCameraTilePos*20]
      
      if(prop.nm = "Large Chain")then
        repeat with a = 0 to 5 then
          pstDp = restrict(dp + a, 0, 29)
          member("layer"&string(pstDp)).image.copyPixels(member("largeChainGraf").image, pastQd, rect(((num mod 2)=1)*20,1+a*50,20 + ((num mod 2)=1)*7,1+(a+1)*50), {#ink:36})
          member("layer"&string(pstDp)).image.copyPixels(member("largeChainGrafHighLight").image, pastQd + [point(-2,-2), point(-2,-2), point(-2,-2), point(-2,-2)], rect(((num mod 2)=1)*20,1+a*50,20 + ((num mod 2)=1)*7,1+(a+1)*50), {#ink:36})
          
          pstDp = restrict(dp + 4 + a, 0, 29)
          b = 5 - a
          member("layer"&string(pstDp)).image.copyPixels(member("largeChainGraf").image, pastQd, rect(((num mod 2)=1)*20,1+b*50,20 + ((num mod 2)=1)*7,1+(b+1)*50), {#ink:36})
          member("layer"&string(pstDp)).image.copyPixels(member("largeChainGrafHighLight").image, pastQd + [point(-2,-2), point(-2,-2), point(-2,-2), point(-2,-2)], rect(((num mod 2)=1)*20,1+b*50,20 + ((num mod 2)=1)*7,1+(b+1)*50), {#ink:36})
        end repeat
      else
        repeat with a = 0 to 5 then
          pstDp = restrict(dp + a, 0, 29)
          member("layer"&string(pstDp)).image.copyPixels(member("largeChainGraf2").image, pastQd, rect(((num mod 2)=1)*20,1+a*50,20 + ((num mod 2)=1)*7,1+(a+1)*50), {#ink:36})
          member("layer"&string(pstDp)).image.copyPixels(member("largeChainGraf2HighLight").image, pastQd + [point(-2,-2), point(-2,-2), point(-2,-2), point(-2,-2)], rect(((num mod 2)=1)*20,1+a*50,20 + ((num mod 2)=1)*7,1+(a+1)*50), {#ink:36})
          
          pstDp = restrict(dp + 4 + a, 0, 29)
          b = 5 - a
          member("layer"&string(pstDp)).image.copyPixels(member("largeChainGraf2").image, pastQd, rect(((num mod 2)=1)*20,1+b*50,20 + ((num mod 2)=1)*7,1+(b+1)*50), {#ink:36})
          member("layer"&string(pstDp)).image.copyPixels(member("largeChainGraf2HighLight").image, pastQd + [point(-2,-2), point(-2,-2), point(-2,-2), point(-2,-2)], rect(((num mod 2)=1)*20,1+b*50,20 + ((num mod 2)=1)*7,1+(b+1)*50), {#ink:36})
        end repeat
      end if
      
    "Big Chain", "Chunky Chain":
      renderBigChainSegment(num, dp, lastPos, pos)
      
    "Bike Chain":
      dr = MoveToPoint(pos, lastPos, 1.0)
      dst = diag(pos, lastPos)
      wdth = 17
      
      pntA = lastPos + dr*17
      pntB = pos - dr*17
      
      pastQd = [pntA - lastPerp*wdth, pntA + lastPerp*wdth, pntB + lastPerp*wdth, pntB - lastPerp*wdth]
      pastQd = pastQd - [gRenderCameraTilePos*20, gRenderCameraTilePos*20, gRenderCameraTilePos*20, gRenderCameraTilePos*20]
      
      renderBeveledImage(member("BikeChainBolt").image, dp, [lastPos + point(-8,-8), lastPos + point(8,-8), lastPos + point(8,8), lastPos + point(-8,8)] - [gRenderCameraTilePos*20, gRenderCameraTilePos*20, gRenderCameraTilePos*20, gRenderCameraTilePos*20], 2)
      
      repeat with a = 1 to 9 then
        pstDp = restrict(dp + a, 0, 29)
        member("layer"&string(pstDp)).image.copyPixels(member("BikeChainBolt").image, rect(lastPos, lastPos) + rect(-8,-8,8,8)-rect(gRenderCameraTilePos*20, gRenderCameraTilePos*20), member("BikeChainBolt").image.rect, {#ink:36, #color:color(0, 255, 0)})
      end repeat
      
      if((num mod 2)=0)then
        pstDp = restrict(dp + 1, 0, 29)
        renderBeveledImage(member("BikeChainSegment").image, pstDp, pastQd, 1)
        pstDp = restrict(dp + 2, 0, 29)
        member("layer"&string(pstDp)).image.copyPixels(member("BikeChainSegment").image, pastQd, member("BikeChainSegment").image.rect, {#ink:36, #color:color(0,255,0)})
        
        pstDp = restrict(dp + 8, 0, 29)
        renderBeveledImage(member("BikeChainSegment").image, pstDp, pastQd, 1)
        pstDp = restrict(dp + 9, 0, 29)
        member("layer"&string(pstDp)).image.copyPixels(member("BikeChainSegment").image, pastQd, member("BikeChainSegment").image.rect, {#ink:36, #color:color(0,255,0)})
      else
        pstDp = restrict(dp + 3, 0, 29)
        renderBeveledImage(member("BikeChainSegment").image, pstDp, pastQd, 1)
        pstDp = restrict(dp + 4, 0, 29)
        member("layer"&string(pstDp)).image.copyPixels(member("BikeChainSegment").image, pastQd, member("BikeChainSegment").image.rect, {#ink:36, #color:color(0,255,0)})
        
        pstDp = restrict(dp + 6, 0, 29)
        renderBeveledImage(member("BikeChainSegment").image, pstDp, pastQd, 1)
        pstDp = restrict(dp + 7, 0, 29)
        member("layer"&string(pstDp)).image.copyPixels(member("BikeChainSegment").image, pastQd, member("BikeChainSegment").image.rect, {#ink:36, #color:color(0,255,0)})
      end if
      
    "Big Bike Chain":
      dr = MoveToPoint(pos, lastPos, 1.0)
      dst = diag(pos, lastPos)
      wdth = 34
      
      pntA = lastPos + dr*34
      pntB = pos - dr*34
      
      pastQd = [pntA - lastPerp*wdth, pntA + lastPerp*wdth, pntB + lastPerp*wdth, pntB - lastPerp*wdth]
      pastQd = pastQd - [gRenderCameraTilePos*20, gRenderCameraTilePos*20, gRenderCameraTilePos*20, gRenderCameraTilePos*20]
      
      renderBeveledImage(member("BigBikeChainBolt").image, dp, [lastPos + point(-16,-16), lastPos + point(16,-16), lastPos + point(16,16), lastPos + point(-16,16)] - [gRenderCameraTilePos*20, gRenderCameraTilePos*20, gRenderCameraTilePos*20, gRenderCameraTilePos*20], 2)
      if (num = 1) then
        return
      end if
      
      repeat with a = 1 to 9 then
        pstDp = restrict(dp + a, 0, 58)
        member("layer"&string(pstDp)).image.copyPixels(member("BigBikeChainBolt").image, rect(lastPos, lastPos) + rect(-16,-16,16,16)-rect(gRenderCameraTilePos*20, gRenderCameraTilePos*20), member("BigBikeChainBolt").image.rect, {#ink:36, #color:color(0, 255, 0)})
      end repeat
      
      if((num mod 2)=0)then
        pstDp = restrict(dp + 1, 0, 58)
        renderBeveledImage(member("BigBikeChainSegment").image, pstDp, pastQd, 1)
        pstDp = restrict(dp + 2, 0, 58)
        member("layer"&string(pstDp)).image.copyPixels(member("BigBikeChainSegment").image, pastQd, member("BigBikeChainSegment").image.rect, {#ink:36, #color:color(0,255,0)})
        
        pstDp = restrict(dp + 8, 0, 58)
        renderBeveledImage(member("BigBikeChainSegment").image, pstDp, pastQd, 1)
        pstDp = restrict(dp + 9, 0, 58)
        member("layer"&string(pstDp)).image.copyPixels(member("BigBikeChainSegment").image, pastQd, member("BigBikeChainSegment").image.rect, {#ink:36, #color:color(0,255,0)})
      else
        pstDp = restrict(dp + 3, 0, 58)
        renderBeveledImage(member("BigBikeChainSegment").image, pstDp, pastQd, 1)
        pstDp = restrict(dp + 4, 0, 58)
        member("layer"&string(pstDp)).image.copyPixels(member("BigBikeChainSegment").image, pastQd, member("BigBikeChainSegment").image.rect, {#ink:36, #color:color(0,255,0)})
        
        pstDp = restrict(dp + 6, 0, 58)
        renderBeveledImage(member("BigBikeChainSegment").image, pstDp, pastQd, 1)
        pstDp = restrict(dp + 7, 0, 58)
        member("layer"&string(pstDp)).image.copyPixels(member("BigBikeChainSegment").image, pastQd, member("BigBikeChainSegment").image.rect, {#ink:36, #color:color(0,255,0)})
      end if
      
    "Huge Bike Chain":
      dr = MoveToPoint(pos, lastPos, 1.0)
      dst = diag(pos, lastPos)
      wdth = 68
      
      pntA = lastPos + dr*68
      pntB = pos - dr*68
      
      pastQd = [pntA - lastPerp*wdth, pntA + lastPerp*wdth, pntB + lastPerp*wdth, pntB - lastPerp*wdth]
      pastQd = pastQd - [gRenderCameraTilePos*20, gRenderCameraTilePos*20, gRenderCameraTilePos*20, gRenderCameraTilePos*20]
      
      renderBeveledImage(member("HugeBikeChainBolt").image, dp, [lastPos + point(-32,-32), lastPos + point(32,-32), lastPos + point(32,32), lastPos + point(-32,32)] - [gRenderCameraTilePos*20, gRenderCameraTilePos*20, gRenderCameraTilePos*20, gRenderCameraTilePos*20], 2)
      if (num = 1) then
        return
      end if
      repeat with a = 1 to 9 then
        pstDp = restrict(dp + a, 0, 116)
        member("layer"&string(pstDp)).image.copyPixels(member("HugeBikeChainBolt").image, rect(lastPos, lastPos) + rect(-32,-32,32,32)-rect(gRenderCameraTilePos*20, gRenderCameraTilePos*20), member("HugeBikeChainBolt").image.rect, {#ink:36, #color:color(0, 255, 0)})
      end repeat
      
      if((num mod 2)=0)then
        pstDp = restrict(dp + 1, 0, 116)
        renderBeveledImage(member("HugeBikeChainSegment").image, pstDp, pastQd, 1)
        pstDp = restrict(dp + 2, 0, 116)
        member("layer"&string(pstDp)).image.copyPixels(member("HugeBikeChainSegment").image, pastQd, member("HugeBikeChainSegment").image.rect, {#ink:36, #color:color(0,255,0)})
        
        pstDp = restrict(dp + 8, 0, 116)
        renderBeveledImage(member("HugeBikeChainSegment").image, pstDp, pastQd, 1)
        pstDp = restrict(dp + 9, 0, 116)
        member("layer"&string(pstDp)).image.copyPixels(member("HugeBikeChainSegment").image, pastQd, member("HugeBikeChainSegment").image.rect, {#ink:36, #color:color(0,255,0)})
      else
        pstDp = restrict(dp + 3, 0, 116)
        renderBeveledImage(member("HugeBikeChainSegment").image, pstDp, pastQd, 1)
        pstDp = restrict(dp + 4, 0, 116)
        member("layer"&string(pstDp)).image.copyPixels(member("HugeBikeChainSegment").image, pastQd, member("HugeBikeChainSegment").image.rect, {#ink:36, #color:color(0,255,0)})
        
        pstDp = restrict(dp + 6, 0, 116)
        renderBeveledImage(member("HugeBikeChainSegment").image, pstDp, pastQd, 1)
        pstDp = restrict(dp + 7, 0, 116)
        member("layer"&string(pstDp)).image.copyPixels(member("HugeBikeChainSegment").image, pastQd, member("HugeBikeChainSegment").image.rect, {#ink:36, #color:color(0,255,0)})
      end if
      
    "Fat Hose":
      wdth = 20
      pastQd = [pos - perp*wdth, pos + perp*wdth, lastPos + lastPerp*wdth, lastPos - lastPerp*wdth]
      pastQd = pastQd - [gRenderCameraTilePos*20, gRenderCameraTilePos*20, gRenderCameraTilePos*20, gRenderCameraTilePos*20]
      
      repeat with a = 0 to 4 then
        if(dp + a + 1 <= 29)then
          member("layer"&string(dp + a + 1)).image.copyPixels(member("fatHoseGraf").image, pastQd, rect(40,a*40,80,(a+1)*40), {#ink:36})
        else 
          exit repeat
        end if
      end repeat
      
      pastQd = [pos - perp*wdth - dir*5, pos + perp*wdth - dir*5, pos + perp*wdth + dir*5, pos - perp*wdth + dir*5]
      pastQd = pastQd - [gRenderCameraTilePos*20, gRenderCameraTilePos*20, gRenderCameraTilePos*20, gRenderCameraTilePos*20]
      
      repeat with a = 0 to 5 then
        if(dp + a <= 29)then
          member("layer"&string(dp + a)).image.copyPixels(member("fatHoseGraf").image, pastQd, rect(0,a*10,40,(a+1)*10), {#ink:36})
        else 
          exit repeat
        end if
      end repeat
      
      mdPnt = (pos + lastPos)/2
      mdPnt = mdPnt - gRenderCameraTilePos*20
      member("layer"&string(dp)).image.copyPixels(member("fatHoseGraf").image, rect(mdPnt,mdPnt)+rect(-5,-5,5,5), rect(80,0,90,10), {#ink:36})
      
    "Wire Bunch", "Wire Bunch 2":
      if((num mod 2) = 0)or(num = data.points.count) then
        
        dr = MoveToPoint(pos, lastPos, 1.0)
        
        
        global wireBunchSav
        
        
        if wireBunchSav = void then
          wireBunchSav = []
          wireBunchSav.add([lastPos, lastDir])
          repeat with i = 1 to 19 then
            wireBunchSav.add(DegToVec(random(360)))
          end repeat
        end if
        
        possiblePositions = []
        repeat with i = 1 to 10 then
          possiblePositions.add(DegToVec((i.float / 10.0) * 360))
        end repeat
        repeat with i = 1 to 6 then
          possiblePositions.add(DegToVec((i.float / 6.0) * 360)*0.75)
        end repeat
        repeat with i = 1 to 3 then
          possiblePositions.add(DegToVec((i.float / 3.0) * 360)*0.5)
        end repeat
        useLastPos = wireBunchSav[1][1]
        useLastDir = wireBunchSav[1][2]
        useLastPerp = giveDirFor90degrToLine(-useLastDir, useLastDir)
        
        repeat with i = 1 to 19 then
          aPoint = wireBunchSav[i+1]
          indx = random(possiblePositions.count)
          bPoint = possiblePositions[indx]
          possiblePositions.deleteAt(indx)
          
          aPos = useLastPos + useLastPerp*aPoint.locH*18
          
          aDp = (dp + 2.5 + aPoint.locV*2.5).integer + 1
          
          bPos = pos + perp*bPoint.locH*18
          bDp = (dp + 2.5 + bPoint.locV*2.5).integer + 1
          
          aHandle = aPos + useLastDir * lerp(Diag(aPos, bPos)/2.0, (40+random(40)).float, 0.5)
          bHandle = bPos - dir * lerp(Diag(aPos, bPos)/2.0, (40+random(40)).float, 0.5)
          
          c2 = LerpVector(aPoint, bPoint, 0.5)
          cPos = lastPos + lastPerp*c2.locH*18
          aHandle = lerpVector(aHandle, cPos, 0.5)
          bHandle = lerpVector(bHandle, cPos, 0.5)
          
          if(random(35) = 1)then
            bPos = aPos + useLastDir * 60.0 + DegToVec(random(360))*random(60)
            bHandle = lerpVector(bHandle, bPos + DegToVec(random(360))*random(30), 0.5)
          else  if(random(35) = 1)then
            aPos = bPos - dir * 60.0 + DegToVec(random(360))*random(60)
            aHandle = lerpVector(aHandle, aPos + DegToVec(random(360))*random(30), 0.5)
          end if
          
          DrawBezierWire(lastDir, aPos, aHandle, bPos, bHandle, aDp, bDp)
          
          
          
          wireBunchSav[i+1] = bPoint
        end repeat
        wireBunchSav[1][1] = pos
        wireBunchSav[1][2] = dir
      end if
      
      
      
      wdth = 20
      pastQd = [pos -dr*3.5 - perp*wdth, pos -dr*3.5 + perp*wdth, pos + dr*3.5 + perp*wdth, pos +dr*3.5 - perp*wdth]
      pastQd = pastQd - [gRenderCameraTilePos*20, gRenderCameraTilePos*20, gRenderCameraTilePos*20, gRenderCameraTilePos*20]
      mnClamp = 0
      if(dp>=6)then
        mnClamp = 6
      end if
      repeat with a2 = 0 to 10 then
        a = 10-a2
        if(prop.nm = "Wire Bunch")then
          member("layer"&string(restrict(dp + a - 1, mnClamp, 29))).image.copyPixels(member("wireBunchGraf").image, pastQd, rect(0,1+a*7,42,1+(a+1)*7), {#ink:36})
        else
          member("layer"&string(restrict(dp + a - 1, mnClamp, 29))).image.copyPixels(member("wireBunchGraf2").image, pastQd, rect(0,a*7,42,(a+1)*7), {#ink:36})
        end if
      end repeat
      
      
      
      if(num = data.points.count)then
        wireBunchSav = void
      end if
      
    "Big Big Pipe":
      wdth = 20
      pastQd = [pos - perp*wdth, pos + perp*wdth, lastPos + lastPerp*wdth, lastPos - lastPerp*wdth]
      pastQd = pastQd - [gRenderCameraTilePos*20, gRenderCameraTilePos*20, gRenderCameraTilePos*20, gRenderCameraTilePos*20]
      
      repeat with a = 0 to 4 then
        if(dp + a + 1 <= 29)then
          member("layer"&string(dp + a + 1)).image.copyPixels(member("bigBigPipeGraf").image, pastQd, rect(40,a*40,80,(a+1)*40), {#ink:36})
        else 
          exit repeat
        end if
      end repeat
      
      pastQd = [pos - perp*wdth - dir*5, pos + perp*wdth - dir*5, pos + perp*wdth + dir*5, pos - perp*wdth + dir*5]
      pastQd = pastQd - [gRenderCameraTilePos*20, gRenderCameraTilePos*20, gRenderCameraTilePos*20, gRenderCameraTilePos*20]
      
      repeat with a = 0 to 5 then
        if(dp + a <= 29)then
          member("layer"&string(dp + a)).image.copyPixels(member("bigBigPipeGraf").image, pastQd, rect(0,a*10,40,(a+1)*10), {#ink:36})
        else 
          exit repeat
        end if
      end repeat
      
      mdPnt = (pos + lastPos)/2
      mdPnt = mdPnt - gRenderCameraTilePos*20
      member("layer"&string(dp)).image.copyPixels(member("bigBigPipeGraf").image, rect(mdPnt,mdPnt)+rect(-5,-5,5,5), rect(80,0,90,10), {#ink:36})
      
    "Ring Chain":
      wdth = 20
      pastQd = [pos - perp*wdth, pos + perp*wdth, lastPos + lastPerp*wdth, lastPos - lastPerp*wdth]
      pastQd = pastQd - [gRenderCameraTilePos*20, gRenderCameraTilePos*20, gRenderCameraTilePos*20, gRenderCameraTilePos*20]
      
      repeat with a = 0 to 4 then
        if(dp + a <= 29)then
          member("layer"&string(dp + a)).image.copyPixels(member("ringChainGraf").image, pastQd, rect(40,a*40,80,(a+1)*40), {#ink:36})
        else 
          exit repeat
        end if
      end repeat
      
      pastQd = [pos - perp*wdth - dir*5, pos + perp*wdth - dir*5, pos + perp*wdth + dir*5, pos - perp*wdth + dir*5]
      pastQd = pastQd - [gRenderCameraTilePos*20, gRenderCameraTilePos*20, gRenderCameraTilePos*20, gRenderCameraTilePos*20]
      
      repeat with a = 0 to 4 then
        if(dp + a <= 29)then
          member("layer"&string(dp + a)).image.copyPixels(member("ringChainGraf").image, pastQd, rect(0-19,a*10,40-19,(a+1)*10), {#ink:36})
        else 
          exit repeat
        end if
      end repeat
      
      mdPnt = (pos + lastPos)/2
      mdPnt = mdPnt - gRenderCameraTilePos*20
      member("layer"&string(dp)).image.copyPixels(member("ringChainGraf").image, rect(mdPnt,mdPnt)+rect(-5,-5,5,5), rect(80,0,90,10), {#ink:36})
      
      
    "Small Vents":
      wdth = 17
      pastQd = [pos - perp*wdth, pos + perp*wdth, lastPos + lastPerp*wdth, lastPos - lastPerp*wdth]
      pastQd = pastQd - [gRenderCameraTilePos*20, gRenderCameraTilePos*20, gRenderCameraTilePos*20, gRenderCameraTilePos*20]
      
      repeat with a = 0 to 4 then
        if(dp + a + 1 <= 29)then
          member("layer"&string(dp + a + 1)).image.copyPixels(member("smallVentGraf").image, pastQd, rect(36,a*48,66,(a+1)*48), {#ink:36})
        else 
          exit repeat
        end if
      end repeat
      
      pastQd = [pos - perp*wdth - dir*5, pos + perp*wdth - dir*5, pos + perp*wdth + dir*5, pos - perp*wdth + dir*5]
      pastQd = pastQd - [gRenderCameraTilePos*20, gRenderCameraTilePos*20, gRenderCameraTilePos*20, gRenderCameraTilePos*20]
      
      repeat with a = 0 to 5 then
        if(dp + a <= 29)then
          member("layer"&string(dp + a)).image.copyPixels(member("smallVentGraf").image, pastQd, rect(0,a*11,34,(a+1)*11), {#ink:36})
        else 
          exit repeat
        end if
      end repeat
      
    "Reinforced Duct":
      wdth = 53
      pastQd = [pos - perp*wdth, pos + perp*wdth, lastPos + lastPerp*wdth, lastPos - lastPerp*wdth]
      pastQd = pastQd - [gRenderCameraTilePos*20, gRenderCameraTilePos*20, gRenderCameraTilePos*20, gRenderCameraTilePos*20]
      
      repeat with a = 0 to 9 then
        if(dp + a + 1 <= 29)then
          member("layer"&string(dp + a + 1)).image.copyPixels(member("reinforcedDuctGraf").image, pastQd, rect(106,a*104,212,(a+1)*104), {#ink:36})
        else 
          exit repeat
        end if
      end repeat
      
      pastQd = [pos - perp*wdth - dir*5, pos + perp*wdth - dir*5, pos + perp*wdth + dir*5, pos - perp*wdth + dir*5]
      pastQd = pastQd - [gRenderCameraTilePos*20, gRenderCameraTilePos*20, gRenderCameraTilePos*20, gRenderCameraTilePos*20]
      
      repeat with a = 0 to 9 then
        if(dp + a <= 29)then
          member("layer"&string(dp + a)).image.copyPixels(member("reinforcedDuctGraf").image, pastQd, rect(0,a*12,106,(a+1)*12), {#ink:36})
        else 
          exit repeat
        end if
      end repeat
      
  end case
end

global wireBunchSav

on DrawBezierWire(startDir: point, A: point, aHandle: point, B: point, bHandle: point, aDp: number, bDp: number)
  type repeats: number
  type lastdir: point
  type lastpos: point
  type lastperp: point
  type pos: point
  type dir: point
  type perp: point
  type wdth: number
  type pastqd: list
  type mydp: number

  repeats = (Diag(A, B) / 5.0).integer
  lastDir = startDir
  lastPos = A - startDir
  lastPerp = giveDirFor90degrToLine(lastPos, A)
  
  repeat with i = 1 to repeats then
    pos = Bezier(A, aHandle, B, bHandle, i.float / repeats.float)
    dir = MoveToPoint(lastPos, pos, 1.0)
    perp = giveDirFor90degrToLine(lastPos, pos)
    
    wdth = 2
    pastQd = [pos - perp*wdth + dir, pos + perp*wdth + dir, lastPos + lastPerp*wdth - lastDir, lastPos - lastPerp*wdth - lastDir]
    pastQd = pastQd - [gRenderCameraTilePos*20, gRenderCameraTilePos*20, gRenderCameraTilePos*20, gRenderCameraTilePos*20]
    
    myDp = lerp(aDp, bDp, i.float / repeats.float).integer
    
    repeat with i2 = 1 to 3 then
      if(myDp + i2 <= 30)then
        member("layer"&string(myDp + i2 - 1)).image.copyPixels(member("thickWireGraf").image, pastQd, rect(0,(i2-1)*4,4,i2*4), {#ink:36})
      else 
        exit repeat
      end if
    end repeat
    
    lastPos = pos
    lastDir = dir
    lastPerp = perp
  end repeat
  
  
end



on initRenderSoftProp(prop, qd: list, propData, dp, propImage: image)
  type lft: number
  type tp: number
  type rght: number
  type bttm: number
  type p: point
  type pasterect: rect
  type offsetPnt: point
  type getrect: rect

  lft = qd[1].locH
  tp = qd[1].locV
  rght = qd[1].locH
  bttm = qd[1].locV
  
  repeat with p in qd then
    if(p.locH < lft) then
      lft = p.locH
    end if
    if(p.locH > rght) then
      rght = p.locH
    end if
    if(p.locV < tp) then
      tp = p.locV
    end if
    if(p.locV > bttm) then
      bttm = p.locV
    end if
  end repeat
  
  pasteRect = rect(lft, tp, rght, bttm)
  offsetPnt = point(lft, tp)
  member("softPropRender").image = image(pasteRect.width, pasteRect.height, 32)
  
  getRect = propImage.rect
  if(prop.tp = "variedSoft")then
    getRect = rect((propData.settings.variation-1)*prop.pxlSize.locH, 0, propData.settings.variation*prop.pxlSize.locH, prop.pxlSize.locV) + rect(0,1,0,1)
  end if
  
  if(prop.tp = "coloredSoft")then
    getRect = rect(0, 0, prop.pxlSize.locH, prop.pxlSize.locV) + rect(0,1,0,1)
  end if
  
  member("softPropRender").image.copyPixels(propImage, qd-[offsetPnt, offsetPnt, offsetPnt, offsetPnt], getRect)
  
  if(prop.tp = "variedSoft") or (prop.tp = "coloredSoft")then
    if(prop.colorize = 1)then
      if(propData.settings.applyColor)then
        gAnyDecals = true
        member("softPropColor").image = image(pasteRect.width, pasteRect.height, 32)
        member("softPropColor").image.copyPixels(propImage, qd-[offsetPnt, offsetPnt, offsetPnt, offsetPnt], getRect+rect(0, getRect.height, 0, getRect.height))
      end if
    end if
  end if
  
  if(prop.tags.GetPos("effectColorA") > 0 or prop.tags.GetPos("effectColorB") > 0)then
    member("softPropGrad").image = image(pasteRect.width, pasteRect.height, 32)
    member("softPropGrad").image.copyPixels(propImage, qd-[offsetPnt, offsetPnt, offsetPnt, offsetPnt], getRect+rect(0, getRect.height, 0, getRect.height))
  end if
  
  clr = 0
  if(propData.settings.findPos(#color) <> void) then
    if(propData.settings.color > 0)then
      global gPEcolors
      clr = gPEcolors[propData.settings.color][2]
      gAnyDecals = 1
    end if
  end if
  
  softProp = [#c:0, #pasteRect:pasteRect, #prop:prop, #propData:propData, #dp:dp, #clr:clr]
  
  repeat with q = 0 to 29 then
    sprite(50-q).color = color(0,0,0)
  end repeat
end

on renderSoftProp()
  type clr: color
  type dpth: number
  type renderfrom: number
  type renderto: number
  type painted: number
  type dp: number
  type colornumstruct: list
  type dir: point
  type palcol: color
  type ang: number
  type pnt: point
  type dpthremove: number
  type clrzclr: color
  type val: number

  effectColorA = (softProp.prop.tags.GetPos("effectColorA") > 0)
  effectColorB = (softProp.prop.tags.GetPos("effectColorB") > 0)
  
  repeat with q2 = 0 to softProp.pasteRect.width-1 then
    clr = member("softPropRender").image.getPixel(q2, softProp.c)
    if(clr <> color(255, 255, 255)) and ((clr.green > 0) or (softProp.prop.tp = "antimatter")) then
      dpth = clr.green/255.0
      
      if(softProp.prop.tp = "antimatter")then
        renderFrom = softProp.dp
        renderTo = restrict((softProp.dp + softProp.propData.settings.customDepth*(1.0-dpth)).integer, 0, 29)
        painted = false
        repeat with d = renderFrom to renderTo then
          dp = restrict(renderTo - d + renderFrom, 0, 29)
          
          if member("layer"&dp).image.getPixel(q2+softProp.pasteRect.left, softProp.c+softProp.pasteRect.top) <> color(255, 255, 255) then
            member("layer"&dp).image.setPixel(q2+softProp.pasteRect.left, softProp.c+softProp.pasteRect.top, color(255, 255, 255))
            if(painted = false) then
              repeat with clrList in [[color(255, 0, 0), -1], [color(0, 0, 255), 1]] then
                repeat with dir in [point(1,0), point(1,-1), point(0,1), point(2,0), point(2,-2), point(0,2)]then
                  if member("layer"&dp).image.getPixel(q2+softProp.pasteRect.left+dir.locH*clrList[2], softProp.c+softProp.pasteRect.top+dir.locV*clrList[2]) <> color(255, 255, 255) then
                    member("layer"&dp).image.setPixel(q2+softProp.pasteRect.left+dir.locH*clrList[2], softProp.c+softProp.pasteRect.top+dir.locV*clrList[2], clrList[1])
                  end if
                end repeat
              end repeat
              painted = true
            end if
          end if
        end repeat
        
      else
        if (effectColorA) then
          palCol = color(255,0,255)
        else if (effectColorB) then
          palCol = color(0,255,255)
        else
          palCol = color(0,255,0)
        end if
        
        if (softProp.prop.selfShade = 0)then
          if (effectColorA) then
            if(clr.blue > (255.0/3.0)*2.0) then
              palCol = color(255,150,255)
            else if(clr.blue < 255.0/3.0) then
              palCol = color(150,0,150)
            end if
          else if (effectColorB) then
            if(clr.blue > (255.0/3.0)*2.0) then
              palCol = color(150,255,255)
            else if(clr.blue < 255.0/3.0) then
              palCol = color(0,150,150)
            end if
          else
            if(clr.blue > (255.0/3.0)*2.0) then
              palCol = color(0,0,255)
            else if(clr.blue < 255.0/3.0) then
              palCol = color(255,0,0)
            end if
          end if
        else
          
          ang = 0.0
          repeat with a = 1 to softProp.prop.smoothShading then
            repeat with pnt in [point(1, 0), point(1,1), point(0,1)]then
              --  put dpth & " " & ang & " " & softPropDepth(point(q2, softProp.c)-pnt*a) & " " & softPropDepth(point(q2, softProp.c)+pnt*a)
              ang = ang + (dpth - softPropDepth(point(q2, softProp.c)-pnt*a)) + (softPropDepth(point(q2, softProp.c)+pnt*a) - dpth)
            end repeat
          end repeat
          ang = ang / (softProp.prop.smoothShading.float*3.0)
          
          ang = ang * (1.0-clr.red/255.0)
          
          if(ang*10.0*power(dpth, softProp.prop.depthAffectHilites) > softProp.prop.highLightBorder)then
            if (effectColorA) then
              palCol = color(255,150,255)
            else if (effectColorB) then
              palCol = color(150,255,255)
            else
              palCol = color(0,0,255)
            end if
          else if(-ang*10.0 > softProp.prop.shadowBorder) then
            if (effectColorA) then
              palCol = color(150,0,150)
            else if (effectColorB) then
              palCol = color(0,150,150)
            else
              palCol = color(255,0,0)
            end if
          end if
        end if
        
        
        dpth = 1.0-dpth
        dpth = power(dpth, softProp.prop.contourExp)
        
        dpthRemove = (dpth * softProp.propData.settings.customDepth)
        
        renderFrom = 0
        renderTo = 0
        
        if(softProp.prop.round)then
          renderFrom =  softProp.dp + (dpthRemove/2.0)
          renderTo = softProp.dp + softProp.propData.settings.customDepth - (dpthRemove/2.0)
        else
          renderFrom = softProp.dp + dpthRemove
          renderTo = softProp.dp + softProp.propData.settings.customDepth
        end if
        
        renderFrom = lerp(renderFrom, softProp.dp + dpthRemove, clr.red/255.0)
        renderTo = lerp(renderTo, softProp.dp + dpthRemove, clr.red/255.0)
        
        repeat with dp = restrict(renderFrom.integer, 0, 29) to restrict(renderTo.integer, 0, 29)then
          member("layer"&dp).image.setPixel(q2+softProp.pasteRect.left, softProp.c+softProp.pasteRect.top, palCol)
        end repeat
        
        clrzClr = color(255, 255, 255)
        
        if(softProp.clr <> 0)then
          clrzClr = softProp.clr
        else  if(softProp.prop.tp = "variedSoft")then
          if(softProp.prop.colorize = 1)then
            if(softProp.propData.settings.applyColor)then
              clrzClr = member("softPropColor").image.getPixel(q2, softProp.c)
            end if
          end if
        else if(softProp.prop.tp = "coloredSoft")then
          if(softProp.prop.colorize = 1)then
            if(softProp.propData.settings.applyColor)then
              clrzClr = member("softPropColor").image.getPixel(q2, softProp.c)
            end if
          end if
        end if
        
        if(clrzClr <> color(255, 255, 255))then
          repeat with dp = restrict(renderFrom.integer, 0, 29) to restrict(renderTo.integer, 0, 29)then
            member("layer"&dp&"dc").image.setPixel(q2+softProp.pasteRect.left, softProp.c+softProp.pasteRect.top, clrzClr)
          end repeat
        end if
        
        
        gradOp = color(255, 255, 255)
        
        if(effectColorA or effectColorB)then
          gradOp = member("softPropGrad").image.getPixel(q2, softProp.c)
        end if
        
        if(effectColorA and gradOp <> color(255, 255, 255))then
          repeat with dp = restrict(renderFrom.integer, 0, 29) to restrict(renderTo.integer, 0, 29)then
            member("gradientA"&dp).image.setPixel(q2+softProp.pasteRect.left, softProp.c+softProp.pasteRect.top, gradOp)
          end repeat
        else if(effectColorB and gradOp <> color(255, 255, 255))then
          repeat with dp = restrict(renderFrom.integer, 0, 29) to restrict(renderTo.integer, 0, 29)then
            member("gradientB"&dp).image.setPixel(q2+softProp.pasteRect.left, softProp.c+softProp.pasteRect.top, gradOp)
          end repeat
        end if
        
      end if
    end if
  end repeat
  
  softProp.c = softProp.c + 1
  if(softProp.c >= softProp.pasteRect.height)then
    repeat with q = 0 to 29 then
      val = (q.float+1.0)/30.0
      sprite(50-q).color = color(val*255, val*255, val*255)
    end repeat
    softProp = void
  end if
end

on softPropDepth(pxl: point)
  type return: number
  type clr: color

  clr = member("softPropRender").image.getPixel(pxl.locH, pxl.locV)
  if(clr = color(255, 255, 255)) or (clr = 0) then
    return 0.0
  end if
  
  return clr.green/255.0
end

on renderESoftProp()
  
  repeat with q2 = 0 to softProp.pasteRect.width-1 then
    clr = member("softPropRender").image.getPixel(q2, softProp.c)
    if(clr <> color(255, 255, 255)) then
      if (clr.green > 0)then
        dpth = clr.green/255.0
      else if (clr.blue > 0)then
        dpth = clr.blue/255.0
      else
        dpth = clr.red/255.0
      end if
      
      palCol = color(0,255,0)
      
      ang = 0.0
      repeat with a = 1 to softProp.prop.smoothShading then
        repeat with pnt in [point(1, 0), point(1,1), point(0,1)]then
          --  put dpth & " " & ang & " " & softPropDepth(point(q2, softProp.c)-pnt*a) & " " & softPropDepth(point(q2, softProp.c)+pnt*a)
          ang = ang + (dpth - EsoftPropDepth(point(q2, softProp.c)-pnt*a)) + (EsoftPropDepth(point(q2, softProp.c)+pnt*a) - dpth)
        end repeat
      end repeat
      ang = ang / (softProp.prop.smoothShading.float*3.0)
      
      ang = ang * (1.0/255.0)
      
      if(ang*10.0*power(dpth, softProp.prop.depthAffectHilites) > softProp.prop.highLightBorder)then
        palCol = color(0,0,255)
      else if(-ang*10.0 > softProp.prop.shadowBorder) then
        palCol = color(255, 0,0)
      end if
      
      dpth = 1.0-dpth
      dpth = power(dpth, softProp.prop.contourExp)
      
      dpthRemove = (dpth * softProp.propData.settings.customDepth)
      
      renderFrom = 0
      renderTo = 0
      
      if(softProp.prop.round)then
        renderFrom =  softProp.dp + (dpthRemove/2.0)
        renderTo = softProp.dp + softProp.propData.settings.customDepth - (dpthRemove/2.0)
      else
        renderFrom = softProp.dp + dpthRemove
        renderTo = softProp.dp + softProp.propData.settings.customDepth
      end if
      
      renderFrom = lerp(renderFrom, softProp.dp + dpthRemove, clr.red/255.0)
      renderTo = lerp(renderTo, softProp.dp + dpthRemove, clr.red/255.0)
      
      repeat with dp = restrict(renderFrom.integer, 0, 29) to restrict(renderTo.integer, 0, 29)then
        member("layer"&dp).image.setPixel(q2+softProp.pasteRect.left, softProp.c+softProp.pasteRect.top, palCol)
      end repeat
      
      clrzClr = color(255, 255, 255)
      
      if(softProp.clr <> 0)then
        clrzClr = softProp.clr
      else  if(softProp.prop.tp = "variedSoft")then
        if(softProp.prop.colorize = 1)then
          if(softProp.propData.settings.applyColor)then
            clrzClr = member("softPropColor").image.getPixel(q2, softProp.c)
          end if
        end if
      else  if(softProp.prop.tp = "coloredSoft")then
        if(softProp.prop.colorize = 1)then
          if(softProp.propData.settings.applyColor)then
            clrzClr = member("softPropColor").image.getPixel(q2, softProp.c)
          end if
        end if
      end if
      
      if(clrzClr <> color(255, 255, 255))then
        if (clr.blue > 0)then
          clrzClr.green = 1
        else if (clr.red > 0)then
          clrzClr.green = 2
        end if
        repeat with dp = restrict(renderFrom.integer, 0, 29) to restrict(renderTo.integer, 0, 29)then
          member("layer"&dp&"dc").image.setPixel(q2+softProp.pasteRect.left, softProp.c+softProp.pasteRect.top, clrzClr)
        end repeat
      end if
      
    end if
  end repeat
  
  softProp.c = softProp.c + 1
  if(softProp.c >= softProp.pasteRect.height)then
    repeat with q = 0 to 29 then
      val = (q.float+1.0)/30.0
      sprite(50-q).color = color(val*255, val*255, val*255)
    end repeat
    softProp = void
  end if
end

on EsoftPropDepth(pxl)
  clr = member("softPropRender").image.getPixel(pxl.locH, pxl.locV)
  if(clr = color(255, 255, 255)) or (clr = 0) then
    return 0.0
  end if
  if (clr.green > 0)then
    return clr.green/255.0
  else if (clr.blue > 0)then
    return clr.blue/255.0
  else
    return clr.red/255.0
  end if
end




on renderLongProp(qd, prop, data, dp)
  A = (qd[1] + qd[4]) / 2.0
  B = (qd[2] + qd[3]) / 2.0
  
  dir: point = MoveToPoint(A, B, 1.0)
  perp = CorrectPerp(dir)
  dist: number = Diag(A, B)
  
  
  if (prop.tp = "customLong") then
    lgt = prop.segmentLength
    steps = ((dist / lgt) + 0.4999).integer
    diffSeg = ((prop.pixelSize.locV - lgt) + prop.pixelSize.locH) * 0.5
    sav2 = member("previewImprt")
    colored = (prop.tags.getPos("colored") > 0)
    if (colored) then
      gAnyDecals = 1
    end if
    effectColorA = (prop.tags.getPos("effectColorA") > 0)
    effectColorB = (prop.tags.getPos("effectColorB") > 0)
    baseDp = dp
    if (prop.random) then
      vari = random(prop.vars) - 1
    else
      vari = 0
    end if
    prlAng = vecToRadLB(dir)
    cosAng = diffSeg * cos(prlAng)
    sinAng = diffSeg * sin(prlAng)
    repeat with n = 1 to steps
      ps = 0
      dp = baseDp
      posProp = A + (dir * lgt * n)
      pastQd = rotateToQuadLB(rect(posProp, posProp) + rect(-prop.pixelSize.locH * 0.5 - cosAng, -prop.pixelSize.locV * 0.5 - sinAng, prop.pixelSize.locH * 0.5 - cosAng, prop.pixelSize.locV * 0.5 - sinAng), dir)
      repeat with q = 1 to prop.repeatL.count
        gtRect = rect(0, 1, prop.pixelSize.locH, prop.pixelSize.locV + 1)
        gtRect = gtRect + rect(gtRect.width * vari, gtRect.height * ps, gtRect.width * vari, gtRect.height * ps)
        repeat with q2 = 1 to prop.repeatL[q]
          layerImg = member("layer" & string(dp)).image
          case (prop.colorTreatment) of
            "standard":
              layerImg.copyPixels(sav2.image, pastQd, gtRect, {#ink:36})
              if (effectColorA) then
                member("gradientA" & string(dp)).image.copyPixels(sav2.image, pastQd, gtRect + rect(prop.pixelSize.locH * prop.vars, 0, prop.pixelSize.locH * prop.vars, 0), {#ink:39})
              end if
              if (effectColorB) then
                member("gradientB" & string(dp)).image.copyPixels(sav2.image, pastQd, gtRect + rect(prop.pixelSize.locH * prop.vars, 0, prop.pixelSize.locH * prop.vars, 0), {#ink:39})
              end if
            "bevel":
              dumpImg = image(gtRect.width,  gtRect.height, 1)
              dumpImg.copyPixels(sav2.image, dumpImg.rect, gtRect)
              inverseImg = makeSilhoutteFromImg(dumpImg, 1)
              dumpImg = image(layerImg.width, layerImg.height, 32)
              dumpImg.copyPixels(DRPxl, pastQd, rect(0, 0, 1, 1), {#color:color(0, 255, 0)})
              repeat with bbvl = 1 to prop.bevel
                repeat with abvl in DRBevelColors
                  a2mb = abvl[2] * bbvl
                  dumpImg.copyPixels(inverseImg, pastQd + [a2mb, a2mb, a2mb, a2mb], inverseImg.rect, {#color:abvl[1], #ink:36})
                end repeat
              end repeat
              dumpImg.copyPixels(inverseImg, pastQd, inverseImg.rect, {#color:color(255, 255, 255), #ink:36})
              inverseImg = image(dumpImg.width, dumpImg.height, 1)
              inverseImg.copyPixels(DRPxl, inverseImg.rect, rect(0, 0, 1, 1))
              inverseImg.copyPixels(DRPxl, pastQd, rect(0, 0, 1, 1), {#color:color(255, 255, 255)})
              dumpImg.copyPixels(inverseImg, dumpImg.rect, inverseImg.rect, {#color:color(255, 255, 255), #ink:36})
              layerImg.copyPixels(dumpImg, dumpImg.rect, dumpImg.rect, {#ink:36})
          end case
          if (colored) then
            if (effectColorA = FALSE) then
              if (effectColorB = FALSE) then
                member("layer" & string(dp) & "dc").image.copyPixels(sav2.image, pastQd, gtRect + rect(prop.pixelSize.locH * prop.vars, 0, prop.pixelSize.locH * prop.vars, 0), {#ink:36})
              end if
            end if
          end if
          dp = dp + 1
          if (dp > 29) then
            exit repeat
          end if
        end repeat
        if (dp > 29) then
          exit repeat
        end if
        ps = ps + 1
      end repeat
      if (prop.random) then
        vari = random(prop.vars) - 1
      else
        vari = vari + 1
        if (vari >= prop.vars) then
          vari = 0
        end if
      end if
    end repeat
  else
    case (prop.nm) of
      "Cabinet Clamp":
        mem = member("clampSegmentGraf")
        totalSegments = ((dist/mem.image.height)-0.5).integer
        buffer = dist - (totalSegments * mem.image.height)
        
        qd2 = [A - (perp*mem.image.width*0.5) + (dir*buffer*0.5), A + (perp*mem.image.width*0.5) + (dir*buffer*0.5), A + (perp*mem.image.width*0.5), (A - perp*mem.image.width*0.5)]
        member("layer" & dp).image.copyPixels(member("pxl").image, qd2, rect(0,0,1,1), {#color:color(0, 255, 0)})
        qd2 = [B - (perp*mem.image.width*0.5) - (dir*buffer*0.5), B + (perp*mem.image.width*0.5) - (dir*buffer*0.5), B + (perp*mem.image.width*0.5), (B - perp*mem.image.width*0.5)]
        member("layer" & dp).image.copyPixels(member("pxl").image, qd2, rect(0,0,1,1), {#color:color(0, 255, 0)})
        
        d = buffer/2.0
        
        repeat with q = 1 to totalSegments then
          
          pnt = A + d*dir
          qd2 = [pnt - (perp*mem.image.width*0.5) + (dir*mem.image.height), pnt + (perp*mem.image.width*0.5) + (dir*mem.image.height), pnt + (perp*mem.image.width*0.5), (pnt - perp*mem.image.width*0.5)]
          member("layer" & dp).image.copyPixels(mem.image, qd2, mem.image.rect, {#color:color(0, 255, 0), #ink:36})
          
          d = d + mem.image.height
        end repeat
        
        mem = member("clampBoltGraf")
        member("layer" & dp).image.copyPixels(mem.image, rect(A,A) + rect(-mem.image.width/2, -mem.image.height/2, mem.image.width/2, mem.image.height/2), mem.image.rect, {#ink:36})
        member("layer" & dp).image.copyPixels(mem.image, rect(B,B) + rect(-mem.image.width/2, -mem.image.height/2, mem.image.width/2, mem.image.height/2), mem.image.rect, {#ink:36})
        
      "Stretched Pipe":
        
        steps = ((diag(A, B)/20.0)+0.4999).integer
        degDir = lookatpoint(A, B)
        stp = random(100)*0.01
        repeat with q = 1 to steps then
          pos = A+(dir*20.0*(q-stp))
          rct = rect(pos,pos)+rect(-10,-11,10,11)
          member("layer"&string(restrict(dp, 0, 29))).image.copypixels(member("stretchedPipeGraf").image, rotateToQuad(rct, degDir), rect(0, 0, 20, 22), {#ink:36})
        end repeat
        
      "Stretched Wire":
        
        steps = ((diag(A, B)/2.0)+0.4999).integer
        degDir = lookatpoint(A, B)
        stp = random(100)*0.01
        repeat with q = 1 to steps then
          pos = A+(dir*2.0*(q-stp))
          rct = rect(pos,pos)+rect(-1,-2,1,2)
          member("layer"&string(restrict(dp, 0, 29))).image.copypixels(member("stretchedWireGraf").image, rotateToQuad(rct, degDir), rect(0, 0, 2, 4), {#ink:36})
        end repeat
        
      "Long Barbed Wire":
        steps = ((diag(A, B) / 20.0) + 0.4999).integer
        degDir = lookatpoint(A, B)
        stp = random(100) * 0.01
        repeat with q = 1 to steps
          pos = A + (dir * 20.0 * (q - stp))
          rct = rect(pos, pos) + rect(-2.5, -10.0, 2.5, 10.0)
          member("layer" & string(restrict(dp, 0, 29))).image.copypixels(member("barbedWireGraf").image, rotateToQuad(rct, degDir), rect(0, 0, 5, 20), {#ink:36})
        end repeat
        
      "Twisted Thread":
        
        steps = ((diag(A, B)/8.0)+0.4999).integer
        degDir = lookatpoint(A, B)
        stp = random(100)*0.01
        repeat with q = 1 to steps then
          pos = A+(dir*8.0*(q-stp))
          rct = rect(pos,pos)+rect(-4,-4,4,4)
          member("layer"&string(restrict(dp, 0, 29))).image.copypixels(member("twistedThreadGraf").image, rotateToQuad(rct, degDir), rect(0, 0, 8, 8), {#ink:36})
        end repeat
        
      "Thick Chain":
        
        steps = ((diag(A, B)/12.0)+0.4999).integer
        ornt = random(2)-1
        degDir = lookatpoint(A, B)
        stp = random(100)*0.01
        repeat with q = 1 to steps then
          pos = A+(dir*12*(q-stp))
          if ornt then
            --   pos = (pnt+lastPnt)*0.5
            rct = rect(pos,pos)+rect(-6,-10,6,10)
            gtRect = rect(0,0,12,20)
            ornt = 0
          else
            -- pos = (pnt+lastPnt)*0.5
            rct = rect(pos,pos)+rect(-2,-10,2,10)
            gtRect = rect(13,0,16,20)
            ornt = 1
          end if
          -- put rct
          member("layer"&string(dp)).image.copypixels(member("bigChainSegment").image, rotateToQuad(rct, degDir), gtRect, {#color:color(255, 0, 5), #ink:36})
          -- member("layer"&string(dp)).image.copypixels(member("bigChainSegment").image, rct, member("bigChainSegment").image.rect, {#color:color(255,0,0), #ink:36})
        end repeat
        
      "Drill Suspender":
        thirdDist = dist/4.0
        
        repeat with q = 1 to 2 then
          ps = A
          dr = dir
          if(q = 2) then
            ps = B
            dr = -dir
          end if
          
          QD = [ps - perp, ps + perp, ps + dr*thirdDist + perp, ps + dr*thirdDist - perp]
          member("layer" & restrict(dp+3, 0, 29)).image.copyPixels(member("pxl").image, QD, rect(0,0,1,1), {#ink:36, #color:color(0, 255, 0)})
          
          QD = [ps - perp*2, ps + perp*2, ps + dr*10.0 + perp*2, ps + dr*10.0 - perp*2]
          member("layer" & restrict(dp+3, 0, 29)).image.copyPixels(member("pxl").image, QD, rect(0,0,1,1), {#ink:36, #color:color(0, 255, 0)})
          
          rodWidth = 18.0
          QD =  [ps + dr*thirdDist - perp*rodWidth, ps + dr*thirdDist + perp*rodWidth, ps + dr*(thirdDist - 2.5) + perp*rodWidth, ps + dr*(thirdDist - 2.5) - perp*rodWidth]
          member("layer" & restrict(dp+3, 0, 29)).image.copyPixels(member("pxl").image, QD, rect(0,0,1,1), {#ink:36, #color:color(0, 255, 0)})
          
          QD =  [ps + dr*thirdDist - perp*3, ps + dr*thirdDist + perp*3, ps + dr*thirdDist - perp*3 - dr*28, ps + dr*thirdDist + perp*3 - dr*28]
          QD = QD + [dr*2, dr*2, dr*2, dr*2]
          repeat with e = 0 to 2 then
            member("layer" & restrict(dp+2+e, 0, 29)).image.copyPixels(member("DrillSuspenderClamp").image, QD, rect(0, restrict(e, 0, 1)*28, 6, (restrict(e, 0, 1)+1)*28), {#ink:36})
          end repeat
          
          member("layer" & restrict(dp+2, 0, 29)).image.copyPixels(member("DrillSuspenderBolt").image, rect(ps,ps)+rect(-3,-3,3,3), rect(0,0,6,6), {#ink:36})
          repeat with e = 3 to 4 then
            member("layer" & restrict(dp+e, 0, 29)).image.copyPixels(member("DrillSuspenderBolt").image, rect(ps,ps)+rect(-4,-4,4,4), rect(0,6,8,14), {#ink:36})
          end repeat
        end repeat
        
        repeat with q = 1 to 2 then
          perpOffset = -10.0
          if(q = 2)then
            perpOffset = 10.0
          end if
          
          rodWidth = 0.65
          
          QD = [A + dir*thirdDist - perp*(-rodWidth + perpOffset), A + dir*thirdDist - perp*(rodWidth + perpOffset), B - dir*thirdDist - perp*(rodWidth + perpOffset), B - dir*thirdDist - perp*(-rodWidth + perpOffset)]
          member("layer" & restrict(dp+3, 0, 29)).image.copyPixels(member("pxl").image, QD, rect(0,0,1,1), {#ink:36, #color:color(0, 255, 0)})
          
          repeat with e = 1 to 2 then
            pos = A + dir*thirdDist - perp*perpOffset
            if(e = 2)then
              pos = B - dir*thirdDist - perp*perpOffset
            end if
            
            repeat with d = 0 to 5 then
              sz = 3.0 + 7.0*sin((d/5.0)*PI)
              QD = [pos+dir*sz-perp, pos+dir*sz+perp, pos-dir*sz+perp, pos-dir*sz-perp]
              member("layer" & restrict(dp+d, 0, 29)).image.copyPixels(member("pxl").image, QD, rect(0,0,1,1), {#ink:36, #color:color(0, 255, 0)})
            end repeat
            
          end repeat
        end repeat
        
        
      "Drill":
        
        steps = ((diag(A, B)/20.0)+0.4999).integer
        degDir = lookatpoint(A, B)
        stp = random(100)*0.01
        repeat with q = 1 to steps then
          pos = A+(dir*20.0*(q-stp))
          rct = rect(pos,pos)+rect(-10,-10,10,10)
          
          repeat with e = 0 to 9 then
            member("layer"&string(restrict(dp+e, 0, 29))).image.copypixels(member("DrillGraf").image, rotateToQuad(rct, degDir), rect(0, e*20, 20, (e+1)*20), {#ink:36})
          end repeat
        end repeat
        
      "Piston":
        dr = dir
        repeat with d = 0 to 2 then
          wdth = 3 + d
          QD = [A - perp * wdth, A + perp * wdth, B + perp * wdth, B - perp * wdth]
          member("layer" & restrict(dp+d+1, 0, 29)).image.copyPixels(member("pxl").image, QD, rect(0,0,1,1), {#ink:36, #color:color(0, 255, 0)})
          
          member("layer" & restrict(dp+d+1, 0, 29)).image.copyPixels(member("pistonHead").image, rect(A.locH - 5, A.locV - 5, A.locH + 5, A.locV + 5), member("pistonHead").image.rect, {#ink:36})
        end repeat
        wdth = 1
        QD = [A + dir - perp * wdth, A + dir + perp * wdth, B - dir + perp * wdth, B - dir - perp * wdth] + [point(-1,-1), point(-1,-1), point(-1,-1), point(-1,-1)]
        member("layer" & restrict(dp+1, 0, 29)).image.copyPixels(member("pxl").image, QD, rect(0,0,1,1), {#ink:36, #color:color(0, 0, 255)})
        
        A2 = A
        if(diag(a,b) > 200) then
          A2 = B + MoveToPoint(b, a, 200.0)
        end if
        repeat with d = 0 to 4 then
          wdth = 5 + d + (d > 0)
          QD = [A2 - perp * wdth, A2 + perp * wdth, B + perp * wdth, B - perp * wdth]
          member("layer" & restrict(dp+d, 0, 29)).image.copyPixels(member("pxl").image, QD, rect(0,0,1,1), {#ink:36, #color:color(0, 255, 0)})
          
          if(d = 0)then
            wdth = 3
            QD = [A2 + dir*2 - perp * wdth, A2 + dir*2 + perp * wdth, B - dir*2 + perp * wdth, B - dir*2 - perp * wdth] + [point(-2,-2), point(-2,-2), point(-2,-2), point(-2,-2)]
            member("layer" & restrict(dp, 0, 29)).image.copyPixels(member("pxl").image, QD, rect(0,0,1,1), {#ink:36, #color:color(0, 0, 255)})
          end if
          
          QD = [A2 - perp * wdth, A2 + perp * wdth, A2 + dir * 2 + perp * wdth, A2 + dir * 2 - perp * wdth]
          member("layer" & restrict(dp+d, 0, 29)).image.copyPixels(member("pxl").image, QD, rect(0,0,1,1), {#ink:36, #color:color(255, 0, 0)})
        end repeat
        
        -- April
      "Moss Drop", "Moss Drop A", "Moss Drop B":
        --dir = normalized vector    
        --calculate distance and width of moss
        dist = sqrt(power(A.locV - B.locV, 2) + power(A.locH - B.locH, 2))
        dist = dist / 8
        mossWidth = restrict(dist, 20, 30)
        depthOffset = 0
        
        --iterating through list  of points to prevent feedback with collision code.
        points = []
        repeat with t = 1 to dist.integer
          --lerps to go from the top of the long to the bottom. 1 is the top
          percent = t / dist.float
          qd = lerpPnt(B, A, percent)
          --depth shenanigins, will try to hang "in front of" a block if its within the range and the point at which it's gonna place isnt white
          depthRange = restrict(dp, 0, 29)
          points.add([qd, restrict(depthRange - depthOffset, 0, 29)])
          depthCheck = true
          
          repeat while depthCheck then
            if restrict(depthRange - depthOffset, 0, 29) = 0 then
              depthCheck = false
            else if member("layer" & restrict(depthRange - (depthOffset + 1), 0, 29)).image.getPixel(qd) <> color(255, 255, 255) then
              points.add([qd, depthRange - depthOffset])
              depthOffset = depthOffset + 1
            else 
              depthCheck = false
            end if
          end repeat
        end repeat 
        
        
        --iterate through points list & draw on dat thang
        repeat with t = 1 to points.count then 
          
          --funny hee hoo lerp stuff
          repeat with i = 0 to 2
            percent = t / points.count.float
            if i = 0 then
              intensityPercent = lerp(1 , 0.1, percent)
            else if  i = 1 then
              intensityPercent = lerp(0.8, 0.1, percent)
            else 
              intensityPercent = lerp(0.6, 0.1, percent).float
            end if 
            
            widthLerp = point(lerp(mossWidth, 30, percent), lerp(mossWidth, 30, percent))
            widthLerp = point(sphereDepth(widthLerp.locH, i+1 * 10), sphereDepth(widthLerp.locV, i+1 * 10))
            if percent < 0.1  and i = 2 then
              mossSize = 2
            else if percent > 0.9 then
              mossSize = 4
            else 
              mossSize = restrict(lerp(1, 3, percent) + i, 1, 3)
            end if
            mossSize = mossSize.integer * 50
            mossVar = random(6) * 30
            spriteRect = rect(mossVar - 30, mossSize - 50, mossVar, mossSize)
            qd2 = rect(points[t][1].locH - widthLerp.locH, points[t][1].locV - widthLerp.locV, points[t][1].locH + widthLerp.locH, points[t][1].locV + widthLerp.locV)
            qd2 = rotateToQuad (qd2, random(360))
            
            canRender = true
            if percent > 0.75 and i = 2 then
              canRender = false
            end if
            if percent > 0.9 and i <> 0 then
              canRender = false
            end if
            
            if canRender then 
              if prop.nm = "Moss Drop A" then
                member("layer" & restrict(points[t][2] - i, 0, 29) ).image.copyPixels(member("MossDropGraf").image, qd2, spriteRect, {#ink:36, #color:color(255,0,255)})
                copyPixelsToEffectColor("A", restrict(points[t][2] - i, 0, 29), qd2, "MossDropGrad", spriteRect, 0.5, intensityPercent)
              else if prop.nm = "Moss Drop B" then
                
                member("layer" & restrict(points[t][2] - i, 0, 29) ).image.copyPixels(member("MossDropGraf").image, qd2, spriteRect, {#ink:36, #color:color(0,255,255)})
                copyPixelsToEffectColor("B", restrict(points[t][2] - i, 0, 29), qd2, "MossDropGrad", spriteRect, 0.5, intensityPercent)
              else
                member("layer" & restrict(points[t][2] - i, 0, 29) ).image.copyPixels(member("MossDropGraf").image, qd2, spriteRect, {#ink:36, #color:color(0,255,0)})
              end if
            end if
          end repeat
        end repeat
        
      "Moss Hang", "Moss Hang A", "Moss Hang B":
        dist = sqrt(power(A.locV - B.locV, 2) + power(A.locH - B.locH, 2))
        dist = dist / 20
        depthOffset = 0
        mossLength = lerp(60, 120, random(100).float/100)
        targetSize = dist / 5
        points = []
        
        repeat with t = 1 to dist.integer then
          --lerps to go from the top of the long to the bottom. 1 is the top
          percent = (t / dist).float
          qd = lerpPnt(B, A, percent)
          
          mossLength = mossLength + lerp(-dist, dist, random(100).float/100)
          mossLength = restrict(mossLength, 10, dist * 5)
          points2 = []
          depthCheck = true
          depthRange = restrict(dp, 0, 29)
          repeat with t2 = 1 to (mossLength).integer / 2 then
            
            percent2 = (t2 / (mossLength / 2)).float
            --qd2 = lerp(qd, point(qd.locH, qd.locV + mossLength), percent2)
            qd2 = lerpPnt(qd, point(qd.locH, qd.locV + mossLength), percent2)
            depthCheck = true
            points2.add([qd2, depthRange - depthOffset])
            repeat while depthCheck then
              
              if restrict(depthRange - depthOffset, 0, 29) = 0 then
                if member("layer" & restrict(depthRange - (depthOffset), 0, 29)).image.getPixel(qd2) = color(255, 255, 255) then
                  depthOffset = depthOffset - 3
                end if
                depthCheck = false
              else if member("layer" & restrict(depthRange - (depthOffset + 1), 0, 29)).image.getPixel(qd2) <> color(255, 255, 255) then
                points2.add([qd2, depthRange - depthOffset])
                depthOffset = depthOffset + 1
              else 
                depthCheck = false
              end if
            end repeat
            
          end repeat
          points.add(points2)
          
        end repeat
        --poor mans drawSprites
        totalT = 1
        totalPoints = 0
        totalPoints = points.count
        totalLine = lerp(0.3, 0.7, random(100).float/100)
        if prop.nm = "Moss Hang A" then 
          eftc = "A"
          colr = color(255, 0, 255)
        else if prop.nm = "Moss Hang B" then 
          eftc = "B"
          colr = color(0, 255, 255)
        else
          eftc = 0
          colr = color(0, 255, 0)
        end if
        
        repeat with t = 1 to points.count then
          repeat with t2 = 1 to points[t].count then
            if t2 mod 2 = 0 then
              percent = t2.float / points[t].count.float
              totalPercent = totalT / totalPoints.float
              if totalPercent < totalLine then
                yurp = totalPercent / totalLine
                totalLerp = lerp(0, 1, yurp)
              else
                totalLerp = lerp(1, 0, (totalPercent - totalLine) / totalLine)
              end if
              intensityLerp1 = lerp(restrict(totalLerp , 0,1), 0.2, percent)
              mossSize = lerp(1, 2, totalLerp)
              mossSize = mossSize.integer * 50
              mossVar = random(6) * 30
              spriteRect = rect(mossVar - 30, mossSize - 50, mossVar, mossSize)
              widthLerp = 15
              qdOffset = lerp(-30, 30, random(100).float/100)
              qd2 = rect(points[t][t2][1].locH - 15, points[t][t2][1].locV - 30, points[t][t2][1].locH + 15, points[t][t2][1].locV + 30)
              qd2 = rotateToQuad(qd2, random(360))
              member("layer"& restrict(points[t][t2][2] , 0, 29)).image.copyPixels(member("MossDropGraf").image, qd2, spriteRect, {#ink:36, #color:colr})
              if eftc <> 0 then
                copyPixelsToEffectColor(eftc, restrict(points[t][t2][2], 0, 29), qd2, "MossDropGrad", spriteRect, 0.5, intensityLerp1)
              end if
              
              if percent < 0.75 then
                mossSize = lerp(2, 3, totalLerp)
                mossSize = mossSize.integer * 50
                mossVar = random(6) * 30
                spriteRect = rect(mossVar - 30, mossSize - 50, mossVar, mossSize)
                
                member("layer"& restrict(points[t][t2][2] - 1 , 0, 29)).image.copyPixels(member("MossDropGraf").image, qd2, spriteRect, {#ink:36, #color:colr})
                if eftc <> 0 then
                  copyPixelsToEffectColor(eftc, restrict(points[t][t2][2] - 1, 0, 29), qd2, "MossDropGrad", spriteRect, 0.5, intensityLerp1)
                end if
              end if
              
              if percent < 0.6 then
                mossSize = lerp(2, 4, totalLerp)
                mossSize = mossSize.integer * 50
                mossVar = random(6) * 30
                spriteRect = rect(mossVar - 30, mossSize - 50, mossVar, mossSize)
                
                member("layer"& restrict(points[t][t2][2] - 2 , 0, 29)).image.copyPixels(member("MossDropGraf").image, qd2 + rect(qdOffset, 0, qdOffset, 0), spriteRect, {#ink:36, #color:colr})
                if eftc <> 0 then
                  copyPixelsToEffectColor(eftc, restrict(points[t][t2][2] - 2, 0, 29), qd2 + rect(qdOffset, 0, qdOffset, 0), "MossDropGrad", spriteRect, 0.5, intensityLerp1)
                end if
                
              end if
              
              
            end if
          end repeat
          totalT = totalT+1
        end repeat
    end case
  end if
end




on DoPropTags(prop, dp, qd)
  repeat with i = 1 to prop.tags.count then
    case prop.tags[i] of
      "Circular Sign":
        -- put "CIRCLE SIGN"
        
        img = image(120,120,1)
        rnd = random(14)
        img.copyPixels(member("circularSigns").image, rect(0,0,120, 120), rect((rnd-1)*120, 1 + 240, rnd*120, 1 + 240 + 120), {#ink:36, #color:color(0,0,0)})
        
        
        mdPnt = (qd[1] + qd[2] + qd[3] + qd[4])/4.0
        
        repeat with r in [[point(-1,-1), color(0,0,255)], [point(-0,-1), color(0,0,255)], [point(-1,-0), color(0,0,255)], [point(-2,-2), color(0,0,255)], [point(1,1), color(255,0,0)],[point(0,1), color(255,0,0)],[point(1,0), color(255,0,0)],[point(2,2), color(255,0,0)],[point(0,0), color(0,255,0)]] then
          
          member("layer" & string(restrict(dp, 0, 29))).image.copyPixels(img, rect(-60,-60,60,60)+rect(mdPnt,mdPnt)+rect(r[1],r[1]), rect(0,0,120,120), {#ink:36, #color:r[2]})
          
        end repeat
        
        member("layer" & string(dp)).image.copyPixels(member("circularSigns").image, rect(-60,-60,60,60)+rect(mdPnt,mdPnt), rect((rnd-1)*120, 1+120, rnd*120, 1 + 240), {#ink:36, #color:color(0,255,0)})
        member("layer" & string(dp)).image.copyPixels(member("circularSigns").image, rect(-60,-60,60,60)+rect(mdPnt,mdPnt), rect((rnd-1)*120, 1, rnd*120, 1 + 120), {#ink:36, #color:color(255,0,255)})
        
        copyPixelsToEffectColor("A", dp, rect(mdPnt+point(-60,-60),mdPnt+point(60,60)), "circleSignGrad", rect(0, 1, 120, 121), 0.5, 1)
        
      "Circular Sign B":
        -- put "CIRCLE SIGN"
        
        img = image(120,120,1)
        rnd = random(14)
        img.copyPixels(member("circularSigns").image, rect(0,0,120, 120), rect((rnd-1)*120, 1 + 240, rnd*120, 1 + 240 + 120), {#ink:36, #color:color(0,0,0)})
        
        
        mdPnt = (qd[1] + qd[2] + qd[3] + qd[4])/4.0
        
        repeat with r in [[point(-1,-1), color(0,0,255)], [point(-0,-1), color(0,0,255)], [point(-1,-0), color(0,0,255)], [point(-2,-2), color(0,0,255)], [point(1,1), color(255,0,0)],[point(0,1), color(255,0,0)],[point(1,0), color(255,0,0)],[point(2,2), color(255,0,0)],[point(0,0), color(0,255,0)]] then
          
          member("layer" & string(restrict(dp, 0, 29))).image.copyPixels(img, rect(-60,-60,60,60)+rect(mdPnt,mdPnt)+rect(r[1],r[1]), rect(0,0,120,120), {#ink:36, #color:r[2]})
          
        end repeat
        
        member("layer" & string(dp)).image.copyPixels(member("circularSigns").image, rect(-60,-60,60,60)+rect(mdPnt,mdPnt), rect((rnd-1)*120, 1+120, rnd*120, 1 + 240), {#ink:36, #color:color(0,255,0)})
        member("layer" & string(dp)).image.copyPixels(member("circularSigns").image, rect(-60,-60,60,60)+rect(mdPnt,mdPnt), rect((rnd-1)*120, 1, rnd*120, 1 + 120), {#ink:36, #color:color(0,255,255)})
        
        copyPixelsToEffectColor("B", dp, rect(mdPnt+point(-60,-60),mdPnt+point(60,60)), "circleSignGrad", rect(0, 1, 120, 121), 0.5, 1)   
        
        
      "Circular Sign Off":
        img = image(120,120,1)
        rnd = random(14)
        img.copyPixels(member("circularSigns").image, rect(0,0,120, 120), rect((rnd-1)*120, 1 + 240, rnd*120, 1 + 240 + 120), {#ink:36, #color:color(0,0,0)})
        
        mdPnt = (qd[1] + qd[2] + qd[3] + qd[4])/4.0
        
        repeat with r in [[point(-1,-1), color(0,0,255)], [point(-0,-1), color(0,0,255)], [point(-1,-0), color(0,0,255)], [point(-2,-2), color(0,0,255)], [point(1,1), color(255,0,0)],[point(0,1), color(255,0,0)],[point(1,0), color(255,0,0)],[point(2,2), color(255,0,0)],[point(0,0), color(0,255,0)]] then
          
          member("layer" & string(restrict(dp, 0, 29))).image.copyPixels(img, rect(-60,-60,60,60)+rect(mdPnt,mdPnt)+rect(r[1],r[1]), rect(0,0,120,120), {#ink:36, #color:r[2]})
          
        end repeat
        
        member("layer" & string(dp)).image.copyPixels(member("circularSigns").image, rect(-60,-60,60,60)+rect(mdPnt,mdPnt), rect((rnd-1)*120, 1+120, rnd*120, 1 + 240), {#ink:36, #color:color(0,255,0)})
        member("layer" & string(dp)).image.copyPixels(member("circularSigns").image, rect(-60,-60,60,60)+rect(mdPnt,mdPnt), rect((rnd-1)*120, 1, rnd*120, 1 + 120), {#ink:36, #color:color(255,0,0)})
        
        
      "Larger Sign":
        -- put "BIG SIGN"
        img = image(80+6,100+6,1)
        rnd = random(14)
        rct = rect(3,3,83,103)
        img.copyPixels(member("largerSigns").image, rct, rect((rnd-1)*80, 0, rnd*80, 100), {#ink:36, #color:color(0,0, 0)})
        
        mdPnt = (qd[1] + qd[2] + qd[3] + qd[4])/4.0
        
        repeat with r in [[point(-4,-4), color(0,0,255)],[point(-3,-3), color(0,0,255)],[point(3,3), color(255,0,0)],[point(4,4), color(255,0,0)], [point(-2,-2), color(0,255,0)], [point(-1,-1), color(0,255,0)], [point(0,0), color(0,255,0)], [point(1,1), color(0,255,0)], [point(2,2), color(0,255,0)], [point(2,2), color(0,255,0)]] then
          repeat with d = 0 to 1 then
            member("layer" & string(restrict(dp + d, 0, 29))).image.copyPixels(img, rect(-43,-53,43,53)+rect(mdPnt,mdPnt)+rect(r[1],r[1]), rect(0,0,86,106), {#ink:36, #color:r[2]})
          end repeat
        end repeat
        
        
        member("layer" & string(dp)).image.copyPixels(img, rect(-43,-53,43,53)+rect(mdPnt,mdPnt), rect(0,0,86,106), {#ink:36, #color:color(255,255,255)})
        member("layer" & string(restrict(dp + 1, 0, 29))).image.copyPixels(img, rect(-43,-53,43,53)+rect(mdPnt,mdPnt), rect(0,0,86,106), {#ink:36, #color:color(255,0,255)})
        
        member("largeSignGrad2").image.copyPixels(member("largeSignGrad").image, rect(0,0,80,100), rect(0,0,80,100))
        
        repeat with a = 0 to 6 then
          repeat with b = 0 to 13 then
            rct = rect((a*16)-6, (b*8)-1, ((a+1)*16)-6, ((b+1)*8)-1) --+ rect(0,0,-1,-1)
            if(random(7)=1)then
              blnd = random(random(100))
              member("largeSignGrad2").image.copyPixels(member("pxl").image, rct+rect(0,0,1,1), rect(0,0,1,1), {#color:color(255, 255, 255), #blend:blnd/2})
              member("largeSignGrad2").image.copyPixels(member("pxl").image, rct+rect(1,1,0,0), rect(0,0,1,1), {#color:color(255, 255, 255), #blend:blnd/2})
            else if(random(7)=1)then
              member("largeSignGrad2").image.copyPixels(member("pxl").image, rct+rect(1,1,0,0), rect(0,0,1,1), {#color:color(0, 0, 0), #blend:random(random(60))})
            end if
            member("largeSignGrad2").image.copyPixels(member("pxl").image, rect(rct.left, rct.top, rct.right, rct.top+1), rect(0,0,1,1), {#color:color(255, 255, 255), #blend:20})
            member("largeSignGrad2").image.copyPixels(member("pxl").image, rect(rct.left, rct.top+1, rct.left+1, rct.bottom), rect(0,0,1,1), {#color:color(255, 255, 255), #blend:20})
            
            
          end repeat
        end repeat
        
        copyPixelsToEffectColor("A", restrict(dp + 1, 0, 29), rect(mdPnt+point(-43,-53),mdPnt+point(43,53)), "largeSignGrad2", rect(0, 0, 86, 106), 1, 1.0)
        
      "Larger Sign B":
        -- put "BIG SIGN"
        img = image(80+6,100+6,1)
        rnd = random(14)
        rct = rect(3,3,83,103)
        img.copyPixels(member("largerSigns").image, rct, rect((rnd-1)*80, 0, rnd*80, 100), {#ink:36, #color:color(0,0, 0)})
        
        mdPnt = (qd[1] + qd[2] + qd[3] + qd[4])/4.0
        
        repeat with r in [[point(-4,-4), color(0,0,255)],[point(-3,-3), color(0,0,255)],[point(3,3), color(255,0,0)],[point(4,4), color(255,0,0)], [point(-2,-2), color(0,255,0)], [point(-1,-1), color(0,255,0)], [point(0,0), color(0,255,0)], [point(1,1), color(0,255,0)], [point(2,2), color(0,255,0)], [point(2,2), color(0,255,0)]] then
          repeat with d = 0 to 1 then
            member("layer" & string(restrict(dp + d, 0, 29))).image.copyPixels(img, rect(-43,-53,43,53)+rect(mdPnt,mdPnt)+rect(r[1],r[1]), rect(0,0,86,106), {#ink:36, #color:r[2]})
          end repeat
        end repeat
        
        
        member("layer" & string(dp)).image.copyPixels(img, rect(-43,-53,43,53)+rect(mdPnt,mdPnt), rect(0,0,86,106), {#ink:36, #color:color(255,255,255)})
        member("layer" & string(restrict(dp + 1, 0, 29))).image.copyPixels(img, rect(-43,-53,43,53)+rect(mdPnt,mdPnt), rect(0,0,86,106), {#ink:36, #color:color(0,255,255)})
        
        member("largeSignGrad2").image.copyPixels(member("largeSignGrad").image, rect(0,0,80,100), rect(0,0,80,100))
        
        repeat with a = 0 to 6 then
          repeat with b = 0 to 13 then
            rct = rect((a*16)-6, (b*8)-1, ((a+1)*16)-6, ((b+1)*8)-1) --+ rect(0,0,-1,-1)
            if(random(7)=1)then
              blnd = random(random(100))
              member("largeSignGrad2").image.copyPixels(member("pxl").image, rct+rect(0,0,1,1), rect(0,0,1,1), {#color:color(255, 255, 255), #blend:blnd/2})
              member("largeSignGrad2").image.copyPixels(member("pxl").image, rct+rect(1,1,0,0), rect(0,0,1,1), {#color:color(255, 255, 255), #blend:blnd/2})
            else if(random(7)=1)then
              member("largeSignGrad2").image.copyPixels(member("pxl").image, rct+rect(1,1,0,0), rect(0,0,1,1), {#color:color(0, 0, 0), #blend:random(random(60))})
            end if
            member("largeSignGrad2").image.copyPixels(member("pxl").image, rect(rct.left, rct.top, rct.right, rct.top+1), rect(0,0,1,1), {#color:color(255, 255, 255), #blend:20})
            member("largeSignGrad2").image.copyPixels(member("pxl").image, rect(rct.left, rct.top+1, rct.left+1, rct.bottom), rect(0,0,1,1), {#color:color(255, 255, 255), #blend:20})
            
            
          end repeat
        end repeat
        
        copyPixelsToEffectColor("B", restrict(dp + 1, 0, 29), rect(mdPnt+point(-43,-53),mdPnt+point(43,53)), "largeSignGrad2", rect(0, 0, 86, 106), 1, 1.0)
    end case
  type img: image
  type rnd: number
  type mdpnt: point
  type r: list
  type qd: list
  end repeat
end














