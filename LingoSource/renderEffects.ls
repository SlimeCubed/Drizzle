global vertRepeater, r, gEEprops, solidMtrx, gLEprops, colr, colrDetail, colrInd, gdLayer, gdDetailLayer, gdIndLayer, gLOProps, gLevel, gEffectProps, gViewRender, keepLooping, gRenderCameraTilePos, effectSeed, lrSup, chOp, fatOp, gradAf, effectIn3D, gAnyDecals, gRotOp, slimeFxt, DRDarkSlimeFix, DRWhite, DRPxl, DRPxlRect, colrIntensity, fruitDensity, leafDensity, mshrSzW, mshrSz, hasFlowers, effSide, fingerLen, fingerSz, gCustomEffects, gEffects, gLastImported, skyRootsFix, lampColr, lampLayer, frondSz, gdFrondLayer, colrFrond, swSz
global blobSize, growOnWalls, needsAttach


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

-- Presenting: the mad ramblings of cappin

-- do this once per frame
on newFrame me
  -- we move onto the next row
  vertRepeater = vertRepeater + 1
  
  -- if there are no effects in the level, skip everything and move onto the next render stage.
  if (gEEprops.effects.count = 0)then
    keepLooping = 0
    exit
  else if (r=0) then -- r = 0 indicates this is the first frame. (0 would be an invalid effect index) if so,
    vertRepeater = 1 -- move to the first row to begin applying the effects. this is redundant i think but joarcode :P
    r = 1            -- set r = 1 so we can start rendering the first effect
    me.initEffect()  -- and initialize the effect.
  end if
  --  if we've rendered all the rows on this screen, and not moving onto the next screen, or we've reached the end of the screen,
  efcsc = gEEprops.effects[r].crossScreen
  if ( (vertRepeater > 60) and (efcsc = 0) ) or ( (vertRepeater > gLOprops.size.locV) and (efcsc = 1)) then
    me.exitEffect() -- then stop rendering this effect,
    r = r + 1       -- and move onto the next one
    
    if r > gEEprops.effects.count then -- if we've rendered all the effects, stop and move onto the next render stage.
      keepLooping = 0
      exit
    else -- otherwise,
      me.initEffect()  -- initialize the next effect
      vertRepeater = 1 -- and move back to the first row.
    end if
  end if
  
  effectr = gEEprops.effects[r]
  if (effectr.crossScreen = 0) then -- if we're not moving onto the next screen, (or maybe this just means we're not on the first screen?? no fucking clue. doesn't really matter anway.)
    sprite(59).locV = vertRepeater*20 - 216 -- i think this moves that big line across the screen that shows where the effect is being applied? no clue.
    
    -- render all of the tiles within this row.
    repeat with q = 1 to 100
      q2 = q + gRenderCameraTilePos.locH
      c2 = vertRepeater + gRenderCameraTilePos.locV
      if (q2 > 0) then
        if (q2 <= gLOprops.size.locH) then
          if (c2 > 0) then
            if (c2 <= gLOprops.size.locV) then
              me.effectOnTile(q, vertRepeater, q2, c2, effectr)
            end if
          end if
        end if
      end if
    end repeat
  else -- otherwise...
    -- uhh just do the same thing i guess??
    repmcam = vertRepeater - gRenderCameraTilePos.locV
    sprite(59).locV = repmcam * 20 - 216
    repeat with q2 = 1 to gLOprops.size.locH
      me.effectOnTile(q2 - gRenderCameraTilePos.locH, repmcam, q2, vertRepeater, effectr)
    end repeat
  end if
end

-- q and c are the positions of the tile in screen-space ( equivalent to (x - cameraPos.x, z - cameraPos.z) )
-- q2 and c2 are the positions of the tile in global-space ( equivalent to (x, z) )
on effectOnTile me, q, c, q2, c2, effectr
  if effectr.mtrx[q2][c2] > 0 then
    efname = effectr.nm
    
    -- get the seed.
    -- wtf is the "the" keyword?? huh
    -- Alduris: idk it's some Lingo thing for getting variables because it wanted code to look like English and then later learned that that fuckign sucks
    savSeed = the randomSeed
    the randomSeed = seedForTile(point(q2, c2), effectSeed)
    
    -- switch case for all of the effect names and then applying them.
    case efname of
        -- Standard effects
      "Slime", "Rust", "Barnacles", "Erode", "Melt", "Roughen", "SlimeX3", "Destructive Melt", "Super Melt", "Super Erode", "DecalsOnlySlime", "Ultra Super Erode", "Colored Barnacles", "Sand", "Impacts", "Fat Slime":
        script("StandardEffects").applyStandardErosion(q,c,0, efname, effectr)
      "Root Grass", "Cacti", "Rubble", "Rain Moss", "Dandelions", "Seed Pods", "Grass", "Horse Tails", "Circuit Plants", "Feather Plants", "Storm Plants", "Colored Rubble", "Reeds", "Lavenders", "Seed Grass", "Hyacinths", "Orb Plants", "Lollipop Mold", "Og Grass":
        script("StandardEffects").applyStandardPlant(q,c,0, efname)
      "Sprawlbush", "featherFern", "Fungus Tree", "Head Lamp":
        if effectr.mtrx[q2][c2] > 0 then
          script("StandardEffects").apply3Dsprawler(q,c, efname)
        end if
      "Sprawlroots", "Fungus Roots", "Ceiling Lamp":
        if effectr.mtrx[q2][c2] > 0 then
          script("StandardEffects").applyInverse3Dsprawler(q,c,efname)
        end if
        
        -- Joar effects
      "Growers":
        if (random(100)<effectr.mtrx[q2][c2]) and (random(2)=1) then
          script("JoarEffects").applyhugeflower(q,c,0)
        end if
      "Arm Growers":
        if (random(100)<effectr.mtrx[q2][c2]) and (random(2)=1) then
          script("JoarEffects").ApplyArmGrower(q,c,0)
        end if
      "Thorn Growers":
        if (random(100)<effectr.mtrx[q2][c2]) and (random(3)>1) then
          script("JoarEffects").ApplyThornGrower(q,c,0)
        end if
      "hang roots":
        repeat with r2 = 1 to 3 then
          if (random(100)<effectr.mtrx[q2][c2]) then
            script("JoarEffects").applyHangRoots(q,c,0)
          end if
        end repeat
      "Thick Roots":
        if (random(100)<effectr.mtrx[q2][c2]) then
          script("JoarEffects").applyThickRoots(q,c,0)
        end if
      "Rollers":
        if (random(100)<effectr.mtrx[q2][c2]) and (random(5)=1) then
          script("JoarEffects").ApplyRoller(q,c,0)
        end if
      "Garbage Spirals":
        if (random(100)<effectr.mtrx[q2][c2]) and (random(6)=1) then
          script("JoarEffects").ApplyGarbageSpiral(q,c,0)
        end if
      "Shadow Plants":
        if (random(100)<effectr.mtrx[q2][c2]) and (random(3)=1) then
          script("JoarEffects").applyShadowPlants(q,c,0)
        end if
        
      "Wires":
        if (random(100)<effectr.mtrx[q2][c2]) and (random(2)=1) then
          script("JoarEffects").applyWire(q,c,0)
        end if
      "Chains":
        if (random(100)<effectr.mtrx[q2][c2]) and (random(2)=1) then
          script("JoarEffects").applyChain(q,c,0)
        end if
        
      "Fungi Flowers":
        if effectr.mtrx[q2][c2] > 0 then
          script("JoarEffects").applyFungiFlower(q,c)
        end if
      "Lighthouse Flowers":
        if effectr.mtrx[q2][c2] > 0 then
          script("JoarEffects").applyLHFlower(q,c)
        end if
      "Fern", "Giant Mushroom":
        if effectr.mtrx[q2][c2] > 0 then
          script("JoarEffects").applyBigPlant(q,c)
        end if
        
      "BlackGoo":
        script("JoarEffects").applyBlackGoo(q,c,0)
      "DarkSlime":
        script("JoarEffects").applyDarkSlime(q,c, effectr)
      "Restore As Scaffolding", "Restore As Pipes":
        script("JoarEffects").applyRestoreEffect(q,c, q2, c2, efname)
      "DaddyCorruption":
        script("JoarEffects").applyDaddyCorruption(q,c,effectr.mtrx[q2][c2])
      "Corruption No Eye":
        script("JoarEffects").applyCorruptionNoEye(q,c,effectr.mtrx[q2][c2])
      "Slag":-->to support older projects
        script("JoarEffects").applyCorruptionNoEye(q,c,effectr.mtrx[q2][c2])
        
        -- Cappin effects
      "Fez Tree":
        if gEEprops.effects[r].mtrx[q2][c2] > 0 then
          script("CappinEffects").applyFezTree(q, c, 0)
        end if
      "Brain Growers":
        script("CappinEffects").applyBrainGrowers(q,c,gEEprops.effects[r].mtrx[q2][c2], false)
      "Upside Down Brain Growers":
        script("CappinEffects").applyBrainGrowers(q,c,gEEprops.effects[r].mtrx[q2][c2], true)
      "Meat Blobs":
        script("CappinEffects").applyMeatBlobs(q,c,gEEprops.effects[r].mtrx[q2][c2])
        
        -- LB effects
      "LSlime":
        DRFSlimeApply(q, c, effectr)
      "Dense Mold":
        script("LBEffects").applyWLPlant(q, c)
      "Mini Growers":
        if (random(100)<effectr.mtrx[q2][c2]) and (random(2)=1)then
          script("LBEffects").applyMiniGrowers(q,c,0)
        end if
      "Colored Fungi Flowers":
        if (gdLayer = "C") then
          if effectr.mtrx[q2][c2] > 0 then
            script("JoarEffects").applyFungiFlower(q,c)
          end if
        else
          if effectr.mtrx[q2][c2] > 0 then
            script("LBEffects").applyColoredFungiFlower(q,c)
          end if
        end if
      "Colored Lighthouse Flowers":
        if (gdLayer = "C") then
          if effectr.mtrx[q2][c2] > 0 then
            script("JoarEffects").applyLHFlower(q,c)
          end if
        else
          if effectr.mtrx[q2][c2] > 0 then
            script("LBEffects").applyColoredLHFlower(q,c)
          end if
        end if
      "Foliage":
        if effectr.mtrx[q2][c2] > 0 then
          script("LBEffects").applyFoliage(q,c)
        end if
      "Assorted Trash":
        if effectr.mtrx[q2][c2] > 0 then
          script("LBEffects").applyAssortedTrash(q,c)
        end if
      "High Grass":
        if effectr.mtrx[q2][c2] > 0 then
          script("LBEffects").applyHighGrass(q,c)
        end if
      "Small Springs":
        if effectr.mtrx[q2][c2] > 0 then
          script("LBEffects").applySmallSprings(q,c)
        end if
      "High Fern":
        if effectr.mtrx[q2][c2] > 0 then
          script("LBEffects").applyHighFern(q,c)
        end if
      "Mistletoe":
        if effectr.mtrx[q2][c2] > 0 then
          script("LBEffects").applyMistletoe(q,c)
        end if
      "Colored Hang Roots":
        if (gdLayer = "C") then
          repeat with r2 = 1 to 3 then
            if (random(100)<effectr.mtrx[q2][c2]) then
              script("JoarEffects").applyHangRoots(q,c,0)
            end if
          end repeat
        else
          repeat with r2 = 1 to 3 then
            if (random(100)<effectr.mtrx[q2][c2]) then
              script("LBEffects").applyColoredHangRoots(q,c,0)
            end if
          end repeat
        end if
      "Clovers":
        script("LBEffects").applyResRoots(q,c)
        script("StandardEffects").applyStandardErosion(q,c,0, efname, effectr)
        
      "Colored Wires":
        if (gdIndLayer = "C") then
          if (random(100)<effectr.mtrx[q2][c2]) and (random(2)=1) then
            script("JoarEffects").applyWire(q,c,0)
          end if
        else
          if (random(100)<effectr.mtrx[q2][c2]) and (random(2)=1) then
            script("LBEffects").applyColoredWires(q,c,0)
          end if
        end if
      "Colored Chains":
        if (gdIndLayer = "C") then
          if (random(100)<effectr.mtrx[q2][c2]) and (random(2)=1) then
            script("JoarEffects").applyChain(q,c,0)
          end if
        else
          if (random(100)<effectr.mtrx[q2][c2]) and (random(2)=1) then
            script("LBEffects").applyColoredChains(q,c,0)
          end if
        end if
      "Ring Chains":
        if (random(100)<effectr.mtrx[q2][c2]) and (random(2)=1) then
          script("LBEffects").applyRingChains(q,c,0)
        end if
        
      "Spinets":
        if (random(100)<effectr.mtrx[q2][c2]) and (random(3)>1) then
          script("LBEffects").ApplySpinets(q,c,0)
        end if
        
      "Colored Thick Roots":
        if (gdLayer = "C") then
          if (random(100)<effectr.mtrx[q2][c2]) then
            script("JoarEffects").applyThickRoots(q,c,0)
          end if
        else
          if (random(100)<effectr.mtrx[q2][c2]) then
            script("LBEffects").applyColoredThickRoots(q,c,0)
          end if
        end if
      "Colored Shadow Plants":
        if (gdLayer = "C") then
          if (random(100)<effectr.mtrx[q2][c2]) and (random(3)=1) then
            script("JoarEffects").applyShadowPlants(q,c,0)
          end if
        else
          if (random(100)<effectr.mtrx[q2][c2]) and (random(3)=1) then
            script("LBEffects").applyColoredShadowPlants(q,c,0)
          end if
        end if
      "Root Plants":
        if (random(100)<effectr.mtrx[q2][c2]) and (random(3)=1) then
          script("LBEffects").applyRootPlants(q,c,0)
        end if
        
      "Wastewater Mold":
        if (gdLayer = "C") then
          script("JoarEffects").applyCorruptionNoEye(q,c,effectr.mtrx[q2][c2])
        else
          script("LBEffects").applyWastewaterMold(q,c,effectr.mtrx[q2][c2])
        end if
      "Little Flowers":
        script("LBEffects").applyFlowers(q,c,effectr.mtrx[q2][c2])
        
        -- Leo
      "Ivy":
        repeat with r2 = 1 to 3 then
          if (random(100)<effectr.mtrx[q2][c2]) then
            script("MiscEffects").applyIvy(q,c,0)
          end if
        end repeat
        
        -- Dakras
      "Left Facing Kelp":
        if (random(100)<effectr.mtrx[q2][c2]) and (random(2)=1) then
          script("DakrasEffects").ApplySideKelp(q,c)
        end if
      "Right Facing Kelp":
        if (random(100)<effectr.mtrx[q2][c2]) and (random(2)=1) then
          script("DakrasEffects").ApplyFlipSideKelp(q,c)
        end if
      "Mixed Facing Kelp":
        if (random(100)<effectr.mtrx[q2][c2]) and (random(2)=1) then
          script("DakrasEffects").ApplyMixKelp(q,c)
        end if
      "Bubble Grower":
        if (random(100)<effectr.mtrx[q2][c2]) and (random(2)=1) then
          script("DakrasEffects").ApplyBubbleGrower(q,c)
        end if
      "Moss Wall":
        script("DakrasEffects").applyMossWall(q,c,effectr.mtrx[q2][c2])
      "Club Moss":
        script("DakrasEffects").applyClubMoss(q,c,effectr.mtrx[q2][c2])
        
        -- Nautillo
      "Horror Growers":
        if (random(100)<effectr.mtrx[q2][c2]) and (random(3)>1) then
          script("NautilloEffects").ApplyHorrorGrower(q,c,0)
        end if
      "Fuzzy Growers":
        if (random(100) < effectr.mtrx[q2][c2]) and (random(3) > 1) then
          script("NautilloEffects").ApplyFuzzyGrower(q, c)
        end if
      "Coral Growers":
        if (random(100)<effectr.mtrx[q2][c2]) and (random(3)>1) then
          script("NautilloEffects").ApplyCoralGrower(q,c,0)
        end if
      "Leaf Growers":
        if (random(100)<effectr.mtrx[q2][c2]) and (random(3)>1) then
          script("NautilloEffects").ApplyLeafGrower(q,c,0)
        end if
      "Meat Growers":
        if (random(100)<effectr.mtrx[q2][c2]) and (random(3)>1) then
          script("NautilloEffects").ApplyMeatGrower(q,c,0)
        end if
        
        -- Tronsx
      "Thunder Growers":
        if (random(100) < effectr.mtrx[q2][c2]) and (random(3) > 1) then
          script("MiscEffects").ApplyThunderGrower(q,c,0)
        end if
        
        -- Intrepid
      "Fancy Growers":
        if (random(100)<effectr.mtrx[q2][c2]) and (random(3)>1) then
          script("IntrepidEffects").ApplyFancyGrower(q,c,0)
        end if 
      "Ice Growers":
        if (random(100)<effectr.mtrx[q2][c2]) and (random(3)>1) then
          script("IntrepidEffects").ApplyIceGrower(q,c,0)
        end if
      "Grass Growers":
        if (random(100)<effectr.mtrx[q2][c2]) and (random(3)>1) then
          script("IntrepidEffects").ApplyGrassGrower(q,c,0)
        end if
        
        -- Ludocrypt
      "Mushroom Stubs":
        script("MiscEffects").applyMushroomStubs(q,c,effectr.mtrx[q2][c2])
        
        -- Alduris
      "Mosaic Plants":
        script("AldurisEffects").ApplyMosaicPlant(q, c)
      "Cobwebs":
        script("AldurisEffects").ApplyCobweb(q, c)
      "Fingers":
        script("AldurisEffects").ApplyFingers(q, c)
        
        -- April
      "Grape Roots":
        repeat with r2 = 1 to 3
          if (random(100) < effectr.mtrx[q2][c2]) then
            script("AprilEffects").applyGrapeRoots(q, c, 0)
          end if
        end repeat
      "Hand Growers":
        script("AprilEffects").applyHandGrowers(q, c, 0)
      "Spindles":
        script("AprilEffects").applySpindle(q,c,0)
      "Wire Bunches":
        script("AprilEffects").applyWireBunch(q,c,0)
      "Box Grubs":
        script("AprilEffects").applyJoarFW(q,c,0)
      "Orblings":
        if (random(100)<effectr.mtrx[q2][c2]) and random(3) = 1 then
          script("AprilEffects").applyOrblings(q, c)
        end if
      "Mama Orblings":
        script("AprilEffects").applyMamaOrblings(q, c)
        
        -- Addy
      "Ripcords":
        if (random(100) < effectr.mtrx[q2][c2]) and (random(3) > 1) then
          script("AddyEffects").ApplyRipcords(q,c)
        end if
      "Spud Buds":
        if (random(100) < effectr.mtrx[q2][c2]) and (random(3) > 1) then
          script("AddyEffects").ApplySpudBuds(q,c)
        end if
      "Cross Roses":
        if (random(100) < effectr.mtrx[q2][c2]) and (random(3) > 1) then
          script("AddyEffects").ApplyCrossRoses(q,c)
        end if
      "Smoke Weeds":
        script("AddyEffects").applySmokeWeed(q, c)
      "Mushroom Colonies":
        script("AddyEffects").applyMushroomColony(q, c)
        
        
      otherwise:
        -- Custom effects system
        if (gCustomEffects.getPos(efname) > 0) then
          script("InitEffects").ApplyCustomEffect(q, c, effectr, efname)
        end if
    end case
    the randomSeed = savSeed
  end if
end

on initEffect me
  effectr = gEEprops.effects[r]
  efopts =  effectr.options
  effectSeed = 0
  repeat with a = 1 to efopts.count
    curop = efopts[a]
    if(curop[1] = "Seed")then
      effectSeed = curop[3]
      exit repeat
    end if
  end repeat
  
  effectIn3D = FALSE
  gRotOp = FALSE
  skyRootsFix = 0
  repeat with op in efopts
    case op[1] of 
      "Layers":
        lrSup = ["All", "1", "2", "3", "1:st and 2:nd", "2:nd and 3:rd"][["All", "1", "2", "3", "1:st and 2:nd", "2:nd and 3:rd"].getPos(op[3])]
      "Color":
        colr = [color(255, 0, 255), color(0, 255, 255), color(0, 255, 0)][["Color1", "Color2", "Dead"].getPos(op[3])]
        gdLayer = ["A", "B", "C"][["Color1", "Color2", "Dead"].getPos(op[3])]
      "Detail Color":
        colrDetail = [color(255, 0, 255), color(0, 255, 255), color(0, 255, 0)][["Color1", "Color2", "Dead"].getPos(op[3])]
        gdDetailLayer = ["A", "B", "C"][["Color1", "Color2", "Dead"].getPos(op[3])]
      "Effect Color":
        colrInd = [color(255, 0, 255), color(0, 255, 255), color(0, 255, 0)][["EffectColor1", "EffectColor2", "None"].getPos(op[3])]
        gdIndLayer = ["A", "B", "C"][["EffectColor1", "EffectColor2", "None"].getPos(op[3])]
      "Seed":
        the randomSeed = op[3]
      "3D":
        effectIn3D = (op[3] = "On")
      "Rotate":
        gRotOp = (op[3] = "On")
      "Fatness": 
        fatOp = ["1px", "2px", "3px", "random"][["1px", "2px", "3px", "random"].getPos(op[3])]
      "Size":
        chOp = ["Small", "FAT"][["Small", "FAT"].getPos(op[3])]
      "Affect Gradients and Decals":
        gradAf = (op[3] = "Yes")
      "Color Intensity":
        colrIntensity  = ["H","M","L","N","R"][["High","Medium","Low","None","Random"].getPos(op[3])]
      "Fruit Density":
        fruitDensity = ["H","M","L","N"][["High","Medium","Low","None"].getPos(op[3])]
      "Leaf Density":
        leafDensity = op[3]
      "Mushroom Size":
        mshrSz  = ["S", "M", "R"][["Small", "Medium", "Random"].getPos(op[3])]
      "Mushroom Width":
        mshrSzW  = ["S", "M", "L", "R"][["Small", "Medium", "Wide", "Random"].getPos(op[3])]
      "Flowers":
        hasFlowers = (op[3] = "On")
      "Side":
        effSide = ["?", "L", "R", "T", "B"][["Left", "Right", "Top", "Bottom"].getPos(op[3]) + 1]
      "Finger Thickness":
        fingerSz = ["?", "S", "M", "L"][["Small", "Medium", "FAT"].getPos(op[3]) + 1]
      "Finger Length":
        fingerLen = ["?", "S", "M", "L"][["Short", "Medium", "Tall"].getPos(op[3]) + 1]
      "Lamp Color":
        lampColr = [color(255, 0, 255), color(0, 255, 255), color(0, 255, 0)][["Color1", "Color2", "Dead"].getPos(op[3])]
        LampLayer = ["A", "B", "C"][["Color1", "Color2", "Dead"].getPos(op[3])]
      "Require In-Bounds":
        if (op[3] = "Yes") then
          skyRootsFix = 1
        end if
      "Blob Size":
        blobSize = [3, 2, 1][["Big", "Medium", "Small"].getPos(op[3])]
      "Should grow on layer behind":
        growOnWalls = (op[3] = "Yes")
      "Needs to be attached to walls":
        needsAttach = (op[3] = "Yes")
      "Frond Size":
        frondSz = ["N", "S", "L"][["None", "Small", "Large"].getPos(op[3])]
      "Frond Color":
        colrFrond = [color(255, 0, 255), color(0, 255, 255), color(0, 255, 0)][["Color1", "Color2", "Dead"].getPos(op[3])]
        gdFrondLayer = ["A", "B", "C"][["Color1", "Color2", "Dead"].getPos(op[3])]
    end case
  end repeat
  
  case effectr.nm of
    "BlackGoo":
      cols = 100
      rows = 60
      
      member("blackOutImg1").image = image(cols*20, rows*20, 32)
      blk1 = member("blackOutImg1").image
      blk1.copyPixels(DRPxl, rect(0,0,cols*20, rows*20), rect(0,0,1,1), {#color:255})
      member("blackOutImg2").image = image(cols*20, rows*20, 32)
      blk2 = member("blackOutImg2").image
      blk2.copyPixels(DRPxl, rect(0,0,cols*20, rows*20), rect(0,0,1,1), {#color:255})
      sprite(57).visibility = 1
      sprite(58).visibility = 1
      
      global gRenderCameraTilePos, gRenderCameraPixelPos
      
      repeat with q = 1 to 100
        repeat with c = 1 to 60
          q2 = q + gRenderCameraTilePos.locH
          c2 = c + gRenderCameraTilePos.locV
          if(q2 < 1)or(q2 > gLOprops.size.locH)or(c2 < 1)or(c2 > gLOprops.size.locV)then
            blk1.copyPixels(DRPxl, rect((q-1)*20, (c-1)*20, q*20, c*20), rect(0,0,1,1), {#color:color(255, 255, 255)})
            blk2.copyPixels(DRPxl, rect((q-1)*20, (c-1)*20, q*20, c*20), rect(0,0,1,1), {#color:color(255, 255, 255)})
          end if
        end repeat
      end repeat
      
      blobImg = member("blob").image
      rct = blobImg.rect
      repeat with q2 = 1 to cols then
        repeat with c2 = 1 to rows then
          if(q2+gRenderCameraTilePos.locH > 0)and(q2+gRenderCameraTilePos.locH <= gLOprops.size.locH)and(c2+gRenderCameraTilePos.locV > 0)and(c2+gRenderCameraTilePos.locV <= gLOprops.size.locV)then
            tile = point(q2,c2)+gRenderCameraTilePos
            
            if (effectr.mtrx[tile.locH][tile.locV] = 0) then
              sPnt = giveMiddleOfTile(point(q2,c2))+point(-10,-10)--+gRenderCameraPixelPos--gRenderCameraTilePos-gRenderCameraPixelPos
              
              repeat with d = 1 to 10
                repeat with e = 1 to 10
                  ps = point(sPnt.locH + d*2, sPnt.locV + e*2)
                  blk1.copyPixels(blobImg, rect(ps.locH-6-random(random(11)),ps.locV-6-random(random(11)),ps.locH+6+random(random(11)),ps.locV+6+random(random(11))), rct, {#color:0, #ink:36})
                  blk2.copyPixels(blobImg, rect(ps.locH-7-random(random(14)),ps.locV-7-random(random(14)),ps.locH+7+random(random(14)),ps.locV+7+random(random(14))), rct, {#color:0, #ink:36})
                  -- end if 
                end repeat
              end repeat
            else if ((gLEProps.matrix[tile.locH][tile.locV][1][2].getPos(5) > 0)or(gLEProps.matrix[tile.locH][tile.locV][1][2].getPos(4) > 0))and(gLEProps.matrix[tile.locH][tile.locV][2][1]=1) then
              ps = giveMiddleOfTile(point(q2,c2))--+gRenderCameraPixelPos--gRenderCameraTilePos-gRenderCameraPixelPos
              blk1.copyPixels(blobImg, rect(ps.locH-4-random(random(9)),ps.locV-4-random(random(9)),ps.locH+4+random(random(9)),ps.locV+4+random(random(9))), rct, {#color:0, #ink:36})
              blk2.copyPixels(blobImg, rect(ps.locH-7-random(random(9)),ps.locV-7-random(random(9)),ps.locH+7+random(random(9)),ps.locV+7+random(random(9))), rct, {#color:0, #ink:36})
              blk1.copyPixels(blobImg, rect(ps.locH-4-random(random(9)),ps.locV-4-random(random(9)),ps.locH+4+random(random(9)),ps.locV+4+random(random(9))), rct, {#color:0, #ink:36})
              blk2.copyPixels(blobImg, rect(ps.locH-7-random(random(9)),ps.locV-7-random(random(9)),ps.locH+7+random(random(9)),ps.locV+7+random(random(9))), rct, {#color:0, #ink:36})
            end if
          end if
        end repeat
      end repeat
      
    "Super BlackGoo":
      cols = 100
      rows = 60
      
      member("blackOutImg1").image = image(cols*20, rows*20, 32)
      blk1 = member("blackOutImg1").image
      member("blackOutImg1").image.copyPixels(DRPxl, rect(0,0,cols*20, rows*20), rect(0,0,1,1), {#color:255})
      member("blackOutImg2").image = image(cols*20, rows*20, 32)
      blk2 = member("blackOutImg2").image
      member("blackOutImg2").image.copyPixels(DRPxl, rect(0,0,cols*20, rows*20), rect(0,0,1,1), {#color:255})
      sprite(57).visibility = 1
      sprite(58).visibility = 1
      
      global gRenderCameraTilePos, gRenderCameraPixelPos
      
      repeat with q = 1 to 100
        repeat with c = 1 to 60
          q2 = q + gRenderCameraTilePos.locH
          c2 = c + gRenderCameraTilePos.locV
          if(q2 < 1)or(q2 > gLOprops.size.locH)or(c2 < 1)or(c2 > gLOprops.size.locV)then
            blk1.copyPixels(DRPxl, rect((q-1)*20, (c-1)*20, q*20, c*20), rect(0,0,1,1), {#color:color(255, 255, 255)})
            blk2.copyPixels(DRPxl, rect((q-1)*20, (c-1)*20, q*20, c*20), rect(0,0,1,1), {#color:color(255, 255, 255)})
          end if
        end repeat
      end repeat
      
      blobImg = member("blob").image
      rct = blobImg.rect
      repeat with q2 = 1 to cols
        repeat with c2 = 1 to rows
          if(q2+gRenderCameraTilePos.locH > 0)and(q2+gRenderCameraTilePos.locH <= gLOprops.size.locH)and(c2+gRenderCameraTilePos.locV > 0)and(c2+gRenderCameraTilePos.locV <= gLOprops.size.locV)then
            tile = point(q2,c2)+gRenderCameraTilePos
            
            if (gEEprops.effects[r].mtrx[tile.locH][tile.locV] = 0) then
              sPnt = giveMiddleOfTile(point(q2,c2))+point(-10,-10)--+gRenderCameraPixelPos--gRenderCameraTilePos-gRenderCameraPixelPos
              
              repeat with d = 1 to 10
                repeat with e = 1 to 10
                  ps = point(sPnt.locH + d*2, sPnt.locV + e*2)
                  -- if member("layer0").image.getPixel(ps) = color(255, 255, 255) then
                  blk1.copyPixels(blobImg, rect(ps.locH-6-random(random(11)),ps.locV-6-random(random(11)),ps.locH+6+random(random(11)),ps.locV+6+random(random(11))), rct, {#color:0, #ink:36})
                  blk2.copyPixels(blobImg, rect(ps.locH-7-random(random(14)),ps.locV-7-random(random(14)),ps.locH+7+random(random(14)),ps.locV+7+random(random(14))), rct, {#color:0, #ink:36})
                  -- end if 
                end repeat
              end repeat
            else if ((gLEProps.matrix[tile.locH][tile.locV][1][2].getPos(5) > 0)or(gLEProps.matrix[tile.locH][tile.locV][1][2].getPos(4) > 0))and(gLEProps.matrix[tile.locH][tile.locV][2][1]=1) then
              ps = giveMiddleOfTile(point(q2,c2))--+gRenderCameraPixelPos--gRenderCameraTilePos-gRenderCameraPixelPos
              blk1.copyPixels(blobImg, rect(ps.locH-4-random(random(9)),ps.locV-4-random(random(9)),ps.locH+4+random(random(9)),ps.locV+4+random(random(9))), rct, {#color:0, #ink:36})
              blk2.copyPixels(blobImg, rect(ps.locH-7-random(random(9)),ps.locV-7-random(random(9)),ps.locH+7+random(random(9)),ps.locV+7+random(random(9))), rct, {#color:0, #ink:36})
              blk1.copyPixels(blobImg, rect(ps.locH-4-random(random(9)),ps.locV-4-random(random(9)),ps.locH+4+random(random(9)),ps.locV+4+random(random(9))), rct, {#color:0, #ink:36})
              blk2.copyPixels(blobImg, rect(ps.locH-7-random(random(9)),ps.locV-7-random(random(9)),ps.locH+7+random(random(9)),ps.locV+7+random(random(9))), rct, {#color:0, #ink:36})
            end if
          end if
        end repeat
      end repeat
      
    "Fungi Flowers":
      
      l = [2,3,4,5]
      l2 = []
      repeat with a = 1 to 4 then
        val = l[random(l.count)]
        l2.add(val)
        l.deleteOne(val)
      end repeat
      gEffectProps = [#list:l2, #listPos:1]
      
    "Colored Fungi Flowers":
      
      l = [2,3,4,5]
      l2 = []
      repeat with a = 1 to 4 then
        val = l[random(l.count)]
        l2.add(val)
        l.deleteOne(val)
      end repeat
      gEffectProps = [#list:l2, #listPos:1]
      
    "Lighthouse Flowers":
      
      l = [1,2,3,4,5,6,7,8]
      l2 = []
      repeat with a = 1 to 8 then
        val = l[random(l.count)]
        l2.add(val)
        l.deleteOne(val)
      end repeat
      gEffectProps = [#list:l2, #listPos:1]
      
    "Colored Lighthouse Flowers":
      
      l = [1,2,3,4,5,6,7,8]
      l2 = []
      repeat with a = 1 to 8 then
        val = l[random(l.count)]
        l2.add(val)
        l.deleteOne(val)
      end repeat
      gEffectProps = [#list:l2, #listPos:1]
      
    "Foliage":
      
      l = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28]
      l2 = []
      repeat with a = 1 to 28 then
        val = l[random(l.count)]
        l2.add(val)
        l.deleteOne(val)
      end repeat
      gEffectProps = [#list:l2, #listPos:1]
      
    "Assorted Trash":
      
      l = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48]
      l2 = []
      repeat with a = 1 to 48 then
        val = l[random(l.count)]
        l2.add(val)
        l.deleteOne(val)
      end repeat
      gEffectProps = [#list:l2, #listPos:1]
      
    "High Grass":
      
      l = [1,2,3,4]
      l2 = []
      repeat with a = 1 to 4 then
        val = l[random(l.count)]
        l2.add(val)
        l.deleteOne(val)
      end repeat
      gEffectProps = [#list:l2, #listPos:1]
      
    "Small Springs":
      
      l = [1,2,3,4,5,6,7]
      l2 = []
      repeat with a = 1 to 7 then
        val = l[random(l.count)]
        l2.add(val)
        l.deleteOne(val)
      end repeat
      gEffectProps = [#list:l2, #listPos:1]
      
    "High Fern":
      
      l = [1,2]
      l2 = []
      repeat with a = 1 to 2 then
        val = l[random(l.count)]
        l2.add(val)
        l.deleteOne(val)
      end repeat
      gEffectProps = [#list:l2, #listPos:1]
      
    "Mistletoe":
      
      l = [1,2,3,4,5,6]
      l2 = []
      repeat with a = 1 to 6 then
        val = l[random(l.count)]
        l2.add(val)
        l.deleteOne(val)
      end repeat
      gEffectProps = [#list:l2, #listPos:1]
      
    "Fern", "Giant Mushroom", "Springs":
      l = [1,2,3,4,5,6,7]
      l2 = []
      repeat with a = 1 to 7 then
        val = l[random(l.count)]
        l2.add(val)
        l.deleteOne(val)
      end repeat
      gEffectProps = [#list:l2, #listPos:1]
      
    "DaddyCorruption":
      global daddyCorruptionHoles
      daddyCorruptionHoles = []
      
    "Mosaic Plants":
      global mosaicPlantStarts
      mosaicPlantStarts = []
      script("AldurisEffects").InitMosaicPlants()
  end case
  
  
  txt = ""
  put "<APPLYING EFFECTS>" after txt
  put RETURN after txt
  
  repeat with ef = 1 to gEEprops.effects.count then
    if r - 20 - ef > 0 then
      next repeat
    end if
    if ef = r then
      put string(ef)&". ->"&gEEprops.effects[ef].nm after txt
    else
      put string(ef)&". "&gEEprops.effects[ef].nm after txt
    end if
    put RETURN after txt
  end repeat
  
  member("effectsL").text = txt
end

on exitEffect me
  case gEEprops.effects[r].nm of
    "BlackGoo":
      
      lr0 = member("layer0").image
      lr0.copyPixels(member("blackOutImg1").image, rect(0,0,100*20, 60*20), rect(0,0,100*20, 60*20), {#ink:36, #color:color(0, 255, 0)})
      lr0.copyPixels(member("blackOutImg2").image, rect(0,0,100*20, 60*20), rect(0,0,100*20, 60*20), {#ink:36, #color:color(255, 0, 0)})
      
      
      member("blackOutImg1").image = image(1, 1, 1)
      -- member("blackOutImg2").image = image(1, 1, 1)
      sprite(58).visibility = 0
      sprite(57).visibility = 0
      
    "Super BlackGoo":
      
      lr0 = member("layer0").image
      lr0.copyPixels(member("blackOutImg1").image, rect(0,0,100*20, 60*20), rect(0,0,100*20, 60*20), {#ink:36, #color:color(0, 255, 0)})
      lr0.copyPixels(member("blackOutImg2").image, rect(0,0,100*20, 60*20), rect(0,0,100*20, 60*20), {#ink:36, #color:color(255, 0, 0)})
      
      
      member("blackOutImg1").image = image(1, 1, 1)
      -- member("blackOutImg2").image = image(1, 1, 1)
      sprite(58).visibility = 0
      sprite(57).visibility = 0
      
    "DaddyCorruption":
      global daddyCorruptionHoles
      repeat with i = 1 to daddyCorruptionHoles.count then
        qd = rotateToQuad(rect(daddyCorruptionHoles[i][1], daddyCorruptionHoles[i][1])+rect(-daddyCorruptionHoles[i][2],-daddyCorruptionHoles[i][2],daddyCorruptionHoles[i][2],daddyCorruptionHoles[i][2]), daddyCorruptionHoles[i][3])
        repeat with d = 0 to 1 then
          member("layer"&string(daddyCorruptionHoles[i][4]+d)).image.copyPixels(member("DaddyBulb").image, qd, rect(60, 1, 134, 74), {#color:color(255, 255, 255), #ink:36})
        end repeat
        if(random(2)=1)and(random(100)>daddyCorruptionHoles[i][5])then
          member("layer"&string(daddyCorruptionHoles[i][4]+2)).image.copyPixels(member("DaddyBulb").image, qd, rect(60, 1, 134, 74), {#color:color(255, 0, 0), #ink:36})
        else
          case gdLayer of
            "A":
              member("layer"&string(daddyCorruptionHoles[i][4]+2)).image.copyPixels(member("DaddyBulb").image, qd, rect(60, 1, 134, 74), {#color:color(255, 0, 255), #ink:36})
              copyPixelsToEffectColor("A", daddyCorruptionHoles[i][4]+2, rect(daddyCorruptionHoles[i][1], daddyCorruptionHoles[i][1])+rect(-daddyCorruptionHoles[i][2]*1.5,-daddyCorruptionHoles[i][2]*1.5,daddyCorruptionHoles[i][2]*1.5,daddyCorruptionHoles[i][2]*1.5), "softBrush1", member("softBrush1").rect, 0.5, lerp(random(50)*0.01, 1.0, random(daddyCorruptionHoles[i][5])*0.01))
            "B":
              member("layer"&string(daddyCorruptionHoles[i][4]+2)).image.copyPixels(member("DaddyBulb").image, qd, rect(60, 1, 134, 74), {#color:color(0, 255, 255), #ink:36})
              copyPixelsToEffectColor("B", daddyCorruptionHoles[i][4]+2, rect(daddyCorruptionHoles[i][1], daddyCorruptionHoles[i][1])+rect(-daddyCorruptionHoles[i][2]*1.5,-daddyCorruptionHoles[i][2]*1.5,daddyCorruptionHoles[i][2]*1.5,daddyCorruptionHoles[i][2]*1.5), "softBrush1", member("softBrush1").rect, 0.5, lerp(random(50)*0.01, 1.0, random(daddyCorruptionHoles[i][5])*0.01))
            otherwise:
              member("layer"&string(daddyCorruptionHoles[i][4]+2)).image.copyPixels(member("DaddyBulb").image, qd, rect(60, 1, 134, 74), {#color:color(0, 255, 255), #ink:36})
              copyPixelsToEffectColor("B", daddyCorruptionHoles[i][4]+2, rect(daddyCorruptionHoles[i][1], daddyCorruptionHoles[i][1])+rect(-daddyCorruptionHoles[i][2]*1.5,-daddyCorruptionHoles[i][2]*1.5,daddyCorruptionHoles[i][2]*1.5,daddyCorruptionHoles[i][2]*1.5), "softBrush1", member("softBrush1").rect, 0.5, lerp(random(50)*0.01, 1.0, random(daddyCorruptionHoles[i][5])*0.01))       
          end case
        end if
      end repeat
      daddyCorruptionHoles = []
      
  end case
end



