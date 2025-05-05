global gLOprops, gEEprops, gAnyDecals, gTiles, gTEprops, gLEprops, gRenderCameraTilePos, DRLastMatImp, DRLastSlpImp, DRLastFlrImP, DRLastTexImp, DRCustomMatList, DRLastTL, DRLastTrshImp, DRLastPipeImp, DRPxl, DRPxlRect, DRWhite

on LCheckIfATileIsSolidAndSameMaterial(tl, lr, matName)
  tl = point(restrict(tl.locH, 1, gLOprops.size.loch), restrict(tl.locV, 1, gLOprops.size.locv))
  if (gLEprops.matrix[tl.locH][tl.locV][lr][1] = 1) then
    matTile = gTEprops.tlMatrix[tl.locH][tl.locV][lr]
    if (matTile.tp = "material") then
      if (matTile.data = matName) then
        return 1
      end if
    else if (matTile.tp = "default") then
      if (gTEprops.defaultMaterial = matName) then
        return 1
      end if
    end if 
  end if
  return 0
end

on LIsMyTileSetOpenToThisTile(matName, tl, l)
  if (tl.inside(rect(1, 1, gLOprops.size.loch + 1, gLOprops.size.locv + 1))) then
    if ([1, 2, 3, 4, 5].getPos(gLEProps.matrix[tl.locH][tl.locV][l][1]) > 0) then
      tile = gTEprops.tlMatrix[tl.locH][tl.locV][l]
      if (tile.tp = "material") then
        if (tile.data = matName) then
          return 1
        end if
      else if (tile.tp = "default") then
        if (gTEprops.defaultMaterial = matName) then
          return 1
        end if
      end if
    end if
  else if (gTEprops.defaultMaterial = matName) then
    return 1
  end if
  return 0
end

on LRenderTileMaterial(l: number, nm: string, frntImg)
  -- Random machines and chaotic stone-like materials (made by Alduris)
  if (DRCustomMatList.count >= 1) then
    matTl = DRCustomMatList[DRLastTL]
    if (matTl.nm <> nm) then
      repeat with inti = 1 to DRCustomMatList.count
        if (DRCustomMatList[inti].nm = nm) then
          matTl = DRCustomMatList[inti]
          DRLastTL = inti
          exit repeat
        end if
      end repeat
    end if
    if (matTl.nm = nm) then
      matPickInfo = matTl.autofit
      pickCats: list = []
      pickTiles: list = []
      pickIgnore: list = []
      savSeed = the randomSeed
      the randomSeed = gLOprops.tileSeed + l
      
      if matPickInfo.findPos(#categories) then
        pickCats = matPickInfo.categories
      end if
      if matPickInfo.findPos(#tiles) then
        pickTiles = matPickInfo.tiles
      end if
      if matPickInfo.findPos(#ignoreTiles) then
        pickIgnore = matPickInfo.ignoreTiles
      end if
      
      -- Find tiles with our material
      tlsOrdered = []
      repeat with q = 1 to gLOprops.size.loch
        repeat with c = 1 to gLOprops.size.locv
          LEPropqc = gLEProps.matrix[q][c][l][1]
          if (LEPropqc <> 0) then
            addMe: number = 0
            TEPropqc = gTEprops.tlMatrix[q][c][l]
            if(TEPropqc.tp = "material") then
              if(TEPropqc.data = matTl.nm) then
                addMe = 1
              end if
            else if (gTEprops.defaultMaterial = matTl.nm)then
              if (TEPropqc.tp = "default")then
                addMe = 1
              end if
            end if
            
            if(addMe)then
              tlsOrdered.add([random(gLOprops.size.loch + gLOprops.size.locV), point(q, c)])
            end if
          end if
        end repeat
      end repeat
      
      tlsOrdered.sort()
      delL = [:]
      tls = []
      repeat with q = 1 to tlsOrdered.count
        tls.add(tlsOrdered[q][2])
      end repeat
      
      -- Figure out which tiles the user wants
      tileSelection = []
      repeat with tlGrp in gTiles then
        repeat with tl in tlGrp.tls then
          if (pickCats.getPos(tlGrp.nm) <> 0 and pickIgnore.getPos(tl.nm) = 0) or (pickTiles.getPos(tl.nm) <> 0) then
            --tileSelection.add(tl)
            -- Only select tiles with some solid bits
            repeat with spec in tl.specs then
              if spec > 0 then
                tileSelection.add(tl)
                exit repeat
              end if
            end repeat
          end if
        end repeat
      end repeat
      
      -- Draw the material
      if pickTiles.count > 0 then
         -- this is slightly different than comms code but will fix that later (in comms because comms version has bugs)
        repeat with tl in tls then
          the randomSeed = seedForTile(tl, gLOprops.tileSeed + l)
          if delL.findPos(tl)=void then
            -- Shuffle tiles
            randomTiles = []
            repeat with thisTl in tileSelection then
              randomTiles.append([random(1000), thisTl])
            end repeat
            randomTiles.sort()
            
            -- Find a tile to place
            repeat with t = 1 to randomTiles.count then
              testTile = randomTiles[t][2]
              
              -- Determine legality of placement
              legalToPlace: number = true
              repeat with a = 0 to testTile.sz.locH-1 then
                repeat with b = 0 to testTile.sz.locV-1 then
                  testPoint = tl + point(a,b)
                  spec = testTile.specs[(b+1) + (a*testTile.sz.locV)]
                  
                  if spec <= 0 then next repeat -- ignore air and buffer
                  
                  if (tls.getPos(testPoint) = 0) then -- areas where material is not placed
                    legalToPlace = false
                    exit repeat
                  end if
                  
                  geoSpec = afaMvLvlEdit(testPoint, l)
                  if (geoSpec <> spec) then
                    -- spec does not match on non-solid tile
                    legalToPlace = false
                    exit repeat
                  end if

                  if (delL.findPos(testPoint)<>void) then -- tile has been placed here previously
                    legalToPlace = false
                    exit repeat
                  end if

                end repeat
                if (not legalToPlace) then exit repeat
              end repeat
              
              if legalToPlace then
                -- Place tile
                rootPos: point = tl + point(((testTile.sz.locH.float/2.0) + 0.4999).integer-1, ((testTile.sz.locV.float/2.0) + 0.4999).integer-1)
                if(rootPos.inside(rect(gRenderCameraTilePos, gRenderCameraTilePos+point(100, 60))))then
                  frntImg = drawATileTile(rootPos.loch,rootPos.locV,l,testTile, frntImg, []) -- array argument required for chain holders. do not remove it!
                end if
                
                -- Remove tile ref
                repeat with a = 0 to testTile.sz.locH-1 then
                  repeat with b = 0 to testTile.sz.locV-1 then
                    testPoint = tl + point(a,b)
                    spec = testTile.specs[(b+1) + (a*testTile.sz.locV)]
                    if (spec > -1) then
                      delL[testPoint] = 1
                    end if
                  end repeat
                end repeat
                exit repeat
              end if
            end repeat
          end if
        end repeat
        the randomSeed = savSeed
      end if
    end if
  end if
  return frntImg
end


on LDrawATileMaterial(q, c, l, nm) --frntImg,
  if (DRCustomMatList.count >= 1) then
    matTl = DRCustomMatList[DRLastTL]
    if (matTl.nm <> nm) then
      repeat with inti = 1 to DRCustomMatList.count
        if (DRCustomMatList[inti].nm = nm) then
          matTl = DRCustomMatList[inti]
          DRLastTL = inti
          exit repeat
        end if
      end repeat
    end if
    if (matTl.nm = nm) then
      case l of
        1: 
          dp = 0
        2: 
          dp = 10
        otherwise:
          dp = 20
      end case
      qcp = point(q, c)
      LEMatrixT = gLEProps.matrix[q][c][l][1]
      
      if (matTl.findPos(#texture) <> VOID) then
        -- Unified texture materials (made by LB)
        mText = matTl.texture
        matFile = member("MatTexImport")
        if (DRLastTexImp <> nm) then
          member("MatTexImport").importFileInto("Materials" & the dirSeparator & nm & "Texture.png")
          matFile.name = "MatTexImport"
          DRLastTexImp = nm
        end if
        matImg = matFile.image
        colored = (mText.tags.getPos("colored") > 0)
        if (colored) then
          gAnyDecals = 1
        end if
        effectColorA = (mText.tags.getPos("effectColorA") > 0)
        effectColorB = (mText.tags.getPos("effectColorB") > 0)
        size = mText.sz
        bsRect = rect((q mod size.locH) * 20, (c mod size.locV) * 20 + 1, ((q mod size.locH) + 1) * 20, ((c mod size.locV) + 1) * 20 + 1)
        if (colored) or (effectColorA) or (effectColorB) then
          gradRect = rect(size.locH * 20, 0, size.locH * 20, 0)
        end if
        pstRect = rect((q - 1) * 20, (c - 1) * 20, q * 20, c * 20) - rect(gRenderCameraTilePos, gRenderCameraTilePos) * 20
        case LEMatrixT of
          1:
            d = -1
            repeat with ps = 1 to mText.repeatL.count
              gtRect = bsRect + rect(0, size.locV * 20 * (ps - 1), 0, size.locV * 20 * (ps - 1))
              repeat with ps2 = 1 to mText.repeatL[ps]
                d = d + 1 
                if (d + dp > 29) then
                  exit repeat
                else
                  lstr = string(d + dp)
                  member("layer" & lstr).image.copyPixels(matImg, pstRect, gtRect, {#ink:36})
                  if (colored) then
                    if (effectColorA = 0) and (effectColorB = 0) then
                      member("layer" & lstr & "dc").image.copyPixels(matImg, pstRect, gtRect + gradRect, {#ink:36})
                    end if
                  end if
                  if (effectColorA) then
                    member("gradientA" & lstr).image.copyPixels(matImg, pstRect, gtRect + gradRect, {#ink:39})
                  end if
                  if (effectColorB) then
                    member("gradientB" & lstr).image.copyPixels(matImg, pstRect, gtRect + gradRect, {#ink:39})
                  end if
                end if
              end repeat
            end repeat
          2, 3, 4, 5:
            rct = rect((q - 1) * 20, (c - 1) * 20, q * 20, c * 20)
            case LEMatrixT of
              5:
                rct = [point(rct.left, rct.top), point(rct.left, rct.top), point(rct.right, rct.bottom), point(rct.left, rct.bottom)]  
              4:
                rct = [point(rct.right, rct.top), point(rct.right, rct.top), point(rct.left, rct.bottom), point(rct.right, rct.bottom)]
              3:
                rct = [point(rct.left, rct.bottom), point(rct.left, rct.bottom), point(rct.right, rct.top), point(rct.left, rct.top)]
              2:
                rct = [point(rct.right, rct.bottom), point(rct.right, rct.bottom), point(rct.left, rct.top), point(rct.right, rct.top)]
            end case
            rct = rct - [gRenderCameraTilePos, gRenderCameraTilePos, gRenderCameraTilePos, gRenderCameraTilePos] * 20
            d = -1
            repeat with ps = 1 to mText.repeatL.count
              gtRect = bsRect + rect(0, size.locV * 20 * (ps - 1), 0, size.locV * 20 * (ps - 1))
              repeat with ps2 = 1 to mText.repeatL[ps]
                d = d + 1 
                if (d + dp > 29) then
                  exit repeat
                else
                  lstr = string(d + dp)
                  lri = member("layer" & lstr).image
                  lri.copyPixels(matImg, pstRect, gtRect, {#ink:36})
                  lri.copyPixels(DRPxl, rct, DRPxlRect, {#color:DRWhite})
                  if (colored) then
                    if (effectColorA = 0) and (effectColorB = 0) then
                      lri = member("layer" & lstr & "dc").image
                      lri.copyPixels(matImg, pstRect, gtRect + gradRect, {#ink:36})
                      lri.copyPixels(DRPxl, rct, DRPxlRect, {#color:DRWhite})
                    end if
                  end if
                  if (effectColorA) then
                    lri = member("gradientA" & lstr).image
                    lri.copyPixels(matImg, pstRect, gtRect + gradRect, {#ink:39})
                    lri.copyPixels(DRPxl, rct, DRPxlRect, {#color:DRWhite})
                  end if
                  if (effectColorB) then
                    lri = member("gradientB" & lstr).image
                    lri.copyPixels(matImg, pstRect, gtRect + gradRect, {#ink:39})
                    lri.copyPixels(DRPxl, rct, DRPxlRect, {#color:DRWhite})
                  end if
                end if
              end repeat
            end repeat
          6:
            if (mText.tags.getPos("textureOnFloor") > 0) then
              rct = rect((q - 1) * 20, (c - 1) * 20 + 10, q * 20, c * 20) - rect(gRenderCameraTilePos, gRenderCameraTilePos) * 20
              d = -1
              repeat with ps = 1 to mText.repeatL.count
                gtRect = bsRect + rect(0, size.locV * 20 * (ps - 1), 0, size.locV * 20 * (ps - 1))
                repeat with ps2 = 1 to mText.repeatL[ps]
                  d = d + 1 
                  if (d + dp > 29) then
                    exit repeat
                  else
                    lstr = string(d + dp)
                    lri = member("layer" & lstr).image
                    lri.copyPixels(matImg, pstRect, gtRect, {#ink:36})
                    lri.copyPixels(DRPxl, rct, DRPxlRect, {#color:DRWhite})
                    if (colored) then
                      if (effectColorA = 0) and (effectColorB = 0) then
                        lri = member("layer" & lstr & "dc").image
                        lri.copyPixels(matImg, pstRect, gtRect + gradRect, {#ink:36})
                        lri.copyPixels(DRPxl, rct, DRPxlRect, {#color:DRWhite})
                      end if
                    end if
                    if (effectColorA) then
                      lri = member("gradientA" & lstr).image
                      lri.copyPixels(matImg, pstRect, gtRect + gradRect, {#ink:39})
                      lri.copyPixels(DRPxl, rct, DRPxlRect, {#color:DRWhite})
                    end if
                    if (effectColorB) then
                      lri = member("gradientB" & lstr).image
                      lri.copyPixels(matImg, pstRect, gtRect + gradRect, {#ink:39})
                      lri.copyPixels(DRPxl, rct, DRPxlRect, {#color:DRWhite})
                    end if
                  end if
                end repeat
              end repeat
            end if
        end case
      end if
      case LEMatrixT of
        1:
          if (matTl.findPos(#block) <> VOID) then
            fl = matTl.block
            rct2 = rect((q - 1) * 20 - 5, (c - 1) * 20 - 5, q * 20 + 5, c * 20 + 5) - rect(gRenderCameraTilePos, gRenderCameraTilePos) * 20
            colored = (fl.tags.getPos("colored") > 0)
            if (colored) then
              gAnyDecals = 1
            end if
            effectColorA = (fl.tags.getPos("effectColorA") > 0)
            effectColorB = (fl.tags.getPos("effectColorB") > 0)
            tlRnd = fl.rnd
            rnd = random(tlRnd) - 1
            matFile = member("MatImport")
            if (DRLastMatImp <> nm) then
              member("MatImport").importFileInto("Materials" & the dirSeparator & nm & ".png")
              matFile.name = "MatImport"
              DRLastMatImp = nm
            end if
            matImg = matFile.image
            repeat with f = 1 to 4
              case f of
                1:
                  profL = [point(-1, 0), point(0, -1)]
                  gtAtV = 2
                  pstRect = rct2 + rect(0, 0, -10, -10)
                2:
                  profL = [point(1, 0), point(0, -1)]
                  gtAtV = 4
                  pstRect = rct2 + rect(10, 0, 0, -10)
                3:
                  profL = [point(1, 0), point(0, 1)]
                  gtAtV = 6
                  pstRect = rct2 + rect(10, 10, 0, 0)
                otherwise:
                  profL = [point(-1, 0), point(0, 1)]
                  gtAtV = 8
                  pstRect = rct2 + rect(0, 10, -10, 0)
              end case
              ID = ""
              repeat with dr in profL
                ID = ID & string(LIsMyTileSetOpenToThisTile(nm, qcp + dr, l))
              end repeat
              if (ID = "11") then
                if ([1,2,3,4,5].getPos(LIsMyTileSetOpenToThisTile(nm, qcp + profL[1] + profL[2], l)) > 0) then
                  gtAtH = 10
                  gtAtV = 2
                else
                  gtAtH = 8
                end if
              else
                gtAtH = [0, "00", 0, "01", 0, "10"].getPos(ID)
              end if
              if (gtAtH = 4) then
                if (gtAtV = 6) then
                  gtAtV = 4
                else if (gtAtV = 8) then
                  gtAtV = 2
                end if
              else if (gtAtH = 6) then
                if (gtAtV = 4) or (gtAtV = 8) then
                  gtAtV = gtAtV - 2
                end if
              end if
              bsRect = rect((gtAtH - 1) * 10 - 5 + 100 * rnd, (gtAtV - 1) * 10 - 5, gtAtH * 10 + 5 + 100 * rnd, gtAtV * 10 + 5)
              --frntImg.copyPixels(matImg, pstRect, bsRect, {#ink:36})
              if (colored) or (effectColorA) or (effectColorB) then
                gradRect = rect(100 * tlRnd, 0, 100 * tlRnd, 0)
              end if
              d = -1
              repeat with ps = 1 to fl.repeatL.count
                gtRect = bsRect + rect(0, 80 * (ps - 1), 0, 80 * (ps - 1))
                repeat with ps2 = 1 to fl.repeatL[ps]
                  d = d + 1 
                  if (d + dp > 29) then
                    exit repeat
                  else
                    lstr = string(d + dp)
                    member("layer" & lstr).image.copyPixels(matImg, pstRect, gtRect, {#ink:36})
                    if (colored) then
                      if (effectColorA = 0) and (effectColorB = 0) then
                        member("layer" & lstr & "dc").image.copyPixels(matImg, pstRect, gtRect + gradRect, {#ink:36})
                      end if
                    end if
                    if (effectColorA) then
                      member("gradientA" & lstr).image.copyPixels(matImg, pstRect, gtRect + gradRect, {#ink:39})
                    end if
                    if (effectColorB) then
                      member("gradientB" & lstr).image.copyPixels(matImg, pstRect, gtRect + gradRect, {#ink:39})
                    end if
                  end if
                end repeat
              end repeat
            end repeat
          end if
        2,3,4,5:
          if (matTl.findPos(#slope) <> VOID) then
            matFile = member("MatSlpImport")
            if (DRLastSlpImp <> nm) then
              member("MatSlpImport").importFileInto("Materials" & the dirSeparator & nm & "Slopes.png")
              matFile.name = "MatSlpImport"
              DRLastSlpImp = nm
            end if
            fl = matTl.slope
            matImg = matFile.image
            tlRnd = fl.rnd
            rnd = random(tlRnd) - 1
            colored = (fl.tags.getPos("colored") > 0)
            if (colored) then
              gAnyDecals = 1
            end if
            effectColorA = (fl.tags.getPos("effectColorA") > 0)
            effectColorB = (fl.tags.getPos("effectColorB") > 0)
            slp = gLEProps.matrix[q][c][l][1]
            askDirs = [0, [point(-1, 0), point(0, 1)], [point(0, 1), point(1, 0)], [point(-1, 0), point(0, -1)], [point(0, -1), point(1, 0)]]
            myAskDirs = askDirs[slp]
            pstRect = rect((q - 1) * 20 - 5, (c - 1) * 20 - 5, q * 20 + 5, c * 20 + 5) - rect(gRenderCameraTilePos, gRenderCameraTilePos) * 20
            if (colored) or (effectColorA) or (effectColorB) then
              gradRect = rect(120 * tlRnd, 0, 120 * tlRnd, 0)
            end if
            repeat with ad = 1 to myAskDirs.count
              bsRect = rect(5 + 60 * (ad = 2) + 120 * rnd, 5 + 30 * (slp - 2), 35 + 60 * (ad = 2) + 120 * rnd, 35 + 30 * (slp - 2))
              if (LIsMyTileSetOpenToThisTile(nm, qcp + myAskDirs[ad], l)) then
                bsRect = bsRect + rect(30, 0, 30, 0)
              end if
              d = -1
              repeat with ps = 1 to fl.repeatL.count
                gtRect = bsRect + rect(0, 130 * (ps - 1), 0, 130 * (ps - 1))
                repeat with ps2 = 1 to fl.repeatL[ps]
                  d = d + 1 
                  if (d + dp > 29) then
                    exit repeat
                  else
                    lstr = string(d + dp)
                    member("layer" & lstr).image.copyPixels(matImg, pstRect, gtRect, {#ink:36})
                    if (colored) then
                      if (effectColorA = 0) and (effectColorB = 0) then
                        member("layer" & lstr & "dc").image.copyPixels(matImg, pstRect, gtRect + gradRect, {#ink:36})
                      end if
                    end if
                    if (effectColorA) then
                      member("gradientA" & lstr).image.copyPixels(matImg, pstRect, gtRect + gradRect, {#ink:39})
                    end if
                    if (effectColorB) then
                      member("gradientB" & lstr).image.copyPixels(matImg, pstRect, gtRect + gradRect, {#ink:39})
                    end if
                  end if
                end repeat
              end repeat
            end repeat
          end if
        6:
          if (matTl.findPos(#floor) <> VOID) then
            matFile = member("MatFlrImport")
            if (DRLastFlrImp <> nm) then
              member("MatFlrImport").importFileInto("Materials" & the dirSeparator & nm & "Floor.png")
              matFile.name = "MatFlrImport"
              DRLastFlrImp = nm
            end if
            fl = matTl.floor
            matImg = matFile.image
            tlRnd = fl.rnd
            rnd = random(tlRnd) - 1
            colored = (fl.tags.getPos("colored") > 0)
            if (colored) then
              gAnyDecals = 1
            end if
            effectColorA = (fl.tags.getPos("effectColorA") > 0)
            effectColorB = (fl.tags.getPos("effectColorB") > 0)
            vbf = 20 * fl.bfTiles
            pstRect = rect((q - 1) * 20 - vbf, (c - 1) * 20 - vbf, q * 20 + vbf, c * 20 + vbf) - rect(gRenderCameraTilePos, gRenderCameraTilePos) * 20
            bfCal = 20 + 40 * fl.bfTiles
            bsRect = rect(0, 1, bfCal, bfCal + 1)
            bsRect = bsRect + rect(bsRect.width * rnd, 0, bsRect.width * rnd, 0)
            if (colored) or (effectColorA) or (effectColorB) then
              gradRect = rect(bfCal * tlRnd, 0, bfCal * tlRnd, 0)
            end if
            d = -1
            repeat with ps = 1 to fl.repeatL.count
              gtRect = bsRect + rect(0, bfCal * (ps - 1), 0, bfCal * (ps - 1))
              repeat with ps2 = 1 to fl.repeatL[ps]
                d = d + 1 
                if (d + dp > 29) then
                  exit repeat
                else
                  lstr = string(d + dp)
                  member("layer" & lstr).image.copyPixels(matImg, pstRect, gtRect, {#ink:36})
                  if (colored) then
                    if (effectColorA = 0) and (effectColorB = 0) then
                      member("layer" & lstr & "dc").image.copyPixels(matImg, pstRect, gtRect + gradRect, {#ink:36})
                    end if
                  end if
                  if (effectColorA) then
                    member("gradientA" & lstr).image.copyPixels(matImg, pstRect, gtRect + gradRect, {#ink:39})
                  end if
                  if (effectColorB) then
                    member("gradientB" & lstr).image.copyPixels(matImg, pstRect, gtRect + gradRect, {#ink:39})
                  end if
                end if
              end repeat
            end repeat
          end if
      end case
      
      if (matTl.findPos(#pipelike) <> VOID) then
        -- Pipe-like materials (made by LudoCrypt)
        matPipes = matTl.pipelike
        randCount = matPipes.rnd
        if (matPipes.findPos(#depths) <> VOID) then
          pipeDepths = matPipes.depths
        else
          pipeDepths = [2, 3, 6, 7]
        end if
        matFile = member("MatPipelikeImport")
        if (DRLastPipeImp <> nm) then
          member("MatPipelikeImport").importFileInto("Materials" & the dirSeparator & nm & "Pipes.png")
          matFile.name = "MatPipelikeImport"
          DRLastPipeImp = nm
        end if
        matImg = matFile.image
        effectColorA = (matPipes.tags.getPos("effectColorA") > 0)
        effectColorB = (matPipes.tags.getPos("effectColorB") > 0)
        colored = (matPipes.tags.getPos("colored") > 0)
        if (colored) then
          gAnyDecals = 1
        end if
        savSeed = the randomSeed
        the randomSeed = seedForTile(qcp, gLOprops.tileSeed + l)
        gtPos = point(0, 0)
        case LEMatrixT of
          1:
            nbrs = ""
            repeat with dir in [point(-1, 0), point(0, -1), point(1, 0), point(0, 1)]
              if (random(2) = 1) and (afaMvLvlEdit(qcp + dir, l) = 1) then
                nbrs = nbrs & "1"
              else
                nbrs = nbrs & string(LIsMyTileSetOpenToThisTile(nm, qcp + dir, l))
              end if
            end repeat
            case nbrs of
              "0101":
                gtPos = point(2, 2)
              "1010":
                gtPos = point(4, 2)
              "1111":
                gtPos = point(6, 2)
              "0111":
                gtPos = point(8, 2)
              "1101":
                gtPos = point(10, 2)
              "1110":
                gtPos = point(12, 2)
              "1011":
                gtPos = point(14, 2)
              "0011":
                gtPos = point(16, 2)
              "1001":
                gtPos = point(18, 2)
              "1100":
                gtPos = point(20, 2)
              "0110":
                gtPos = point(22, 2)
              "1000":
                gtPos = point(24, 2)
              "0010":
                gtPos = point(26, 2)
              "0100":
                gtPos = point(28, 2)
              "0001":
                gtPos = point(30, 2)
              "0000":
                gtPos = point(40, 2)
            end case
          3:
            gtPos = point(32, 2)
          2:
            gtPos = point(34, 2)
          4:
            gtPos = point(36, 2)
          5:
            gtPos = point(38, 2)
          6:
            gtPos = point(42, 2)   
        end case
        lrm110 = (l - 1) * 10
        gtPos.locV = random(randCount) * 2
        repeat with d = lrm110 to lrm110 + 9
          if (pipeDepths.getPos(d - lrm110) > 0) then
            rct = rect((gtPos.locH - 1) * 20 - 10, (gtPos.locV - 1) * 20 - 9, gtPos.locH * 20 + 10, gtPos.locV * 20 + 11)
            realRect = rect((q - 1 - gRenderCameraTilePos.locH) * 20 - 10, (c - 1 - gRenderCameraTilePos.locV) * 20 - 10, (q - gRenderCameraTilePos.locH) * 20 + 10, (c - gRenderCameraTilePos.locV) * 20 + 10)
            member("layer" & string(d)).image.copyPixels(matImg, realRect, rct, {#ink:36})
            if (effectColorA) then
              member("gradientA" & string(d)).image.copyPixels(matImg, realRect, rct + rect(840, 0, 840, 0), {#ink:39})
            end if
            if (effectColorB) then
              member("gradientB" & string(d)).image.copyPixels(matImg, realRect, rct + rect(840, 0, 840, 0), {#ink:39})
            end if
            if (colored) then
              if (effectColorA = FALSE) then
                if (effectColorB = FALSE) then
                  member("layer" & string(d) & "dc").image.copyPixels(matImg, realRect, rct + rect(840, 0, 840, 0), {#ink:36})
                end if 
              end if
            end if
          else
            gtPos.locV = random(randCount) * 2
          end if
        end repeat
        the randomSeed = savSeed
      end if
      
      if (matTl.findPos(#trash) <> VOID) then
        -- Trash-like materials (made by LudoCrypt)
        matTrash = matTl.trash
        trashRnd = matTrash.rnd
        trashSz = matTrash.pixelSize
        if (matTrash.findPos(#density) <> VOID) then
          trashDensity = matTrash.density
        else
          trashDensity = 1
        end if
        if (matTrash.findPos(#depths) <> VOID) then
          trashDepths = matTrash.depths
        else
          trashDepths = [1, 2, 3, 4, 5, 6, 7, 8, 9]
        end if
        matFile = member("MatTrshImport")
        if (DRLastTrshImp <> nm) then
          member("MatTrshImport").importFileInto("Materials" & the dirSeparator & nm & "Trash.png")
          matFile.name = "MatTrshImport"
          DRLastTrshImp = nm
        end if
        matTexImg = matFile.image
        if (trashRnd > 0) then
          savSeed = the randomSeed
          the randomSeed = gLOprops.tileSeed + l + q + c * gLEprops.matrix.count
          clrs = [color(255, 0, 0), color(0, 255, 0), color(0, 0, 255)]
          trashLr = [0, 10, 20][l]
          midTlTr = giveMiddleOfTile(qcp - gRenderCameraTilePos)
          repeat with q = 1 to (2 + (random(trashDensity * 2) - 1) + trashDensity)
            layerOfTrash = random(10) - 1
            if (trashDepths.getPos(layerOfTrash) > 0) then
              gtR = random(trashRnd)
              pntRct = midTlTr - point(11, 11) + point(random(21), random(21))
              trashSzDiv2 = trashSz / 2.0
              member("layer" & string(trashLr + layerOfTrash)).image.copyPixels(matTexImg, rotateToQuadLB(rect(pntRct - trashSzDiv2, pntRct + trashSzDiv2), degToVec(random(360))),  rect(trashSz.locH * (gtR - 1), 1, trashSz.locH * gtR, trashSz.locV + 1), {#color:clrs[random(3)], #ink:36})
            end if
          end repeat
          the randomSeed = savSeed
        end if
      end if
      
      if (matTl.findPos(#autofit)) then
        -- You should not be here, see LRenderTileMaterial instead
      end if
      
      -- note to future people: this is where more material types go
    end if
  end if
  --return frntImg
end
