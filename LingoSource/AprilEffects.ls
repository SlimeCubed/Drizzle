global vertRepeater, r, gEEprops, solidMtrx, gLEprops, colr, colrDetail, colrInd, gdLayer, gdDetailLayer, gdIndLayer, gLOProps, gLevel, gEffectProps, gRenderCameraTilePos, effectSeed, lrSup, chOp, fatOp, gradAf, effectIn3D, gAnyDecals, gRotOp, slimeFxt, DRDarkSlimeFix, DRWhite, DRPxl, DRPxlRect, colrIntensity, skyRootsFix


on applyGrapeRoots me, q, c, eftc
  q2 = q + gRenderCameraTilePos.locH
  c2 = c + gRenderCameraTilePos.locV
  case lrSup of--["All", "1", "2", "3", "1:st and 2:nd", "2:nd and 3:rd"]
    "All":
      d = random(30)-1
    "1":
      d = random(10)-1
    "2":
      d = random(10)-1 + 10
    "3":
      d = random(10)-1 + 20
    "1:st and 2:nd":
      d = random(20)-1
    "2:nd and 3:rd":
      d = random(20)-1 + 10
    otherwise:
      d = random(30)-1
  end case
  lr = 1+(d>9)+(d>19)
  
  quadsToDraw = []
  
  if (gLEprops.matrix[q2][c2][lr][1]=0)then
    mdPnt = giveMiddleOfTile(point(q,c))
    headPos = mdPnt+point(-11+random(21), -11+random(21))
    pnt = point(headPos.locH, headPos.locV)
    lftBorder = mdPnt.locH-10
    rgthBorder =  mdPnt.locH+10
    grape=[]
    layerd = member("layer"&string(d)).image
    repeat while pnt.locV+gRenderCameraTilePos.locV*20 > -100
      lstPos = pnt
      pnt = pnt + degToVec(-45+random(90))*(2+random(6))
      pnt.locH = restrict(pnt.locH, lftBorder, rgthBorder)
      dir = moveToPoint(pnt, lstPos, 1.0)
      crossDir = giveDirFor90degrToLine(-dir, dir)
      qd = [pnt-crossDir, pnt+crossDir, lstPos+crossDir, lstPos-crossDir]
      
      
      if skyRootsFix then
        quadsToDraw.add(qd)
      else
        layerd.copyPixels(DRPxl, qd, DRPxlRect, {#color: color(255,0,0)})
      end if
      
      if solidAfaMv(giveGridPos(lstPos) + gRenderCameraTilePos, lr) = 1 then
        exit repeat
      end if
      
      if skyRootsFix and withinBoundsOfLevel(giveGridPos(lstPos) + gRenderCameraTilePos) = 0 then
        exit
      end if
      
      if random (10 ) =1 then grape.append (pnt)
    end repeat
    
    if skyRootsFix then
      repeat with qdd in quadsToDraw
        layerd.copyPixels(DRPxl, qdd, DRPxlRect, {#color:color(255,0,0)})
      end repeat
    end if
    
    grapegraf = member("grapegraf").image
    repeat with i=1 to grape.count then 
      pt=grape[i]
      rand = random (4) 
      if random (2) = 1 then 
        pt=pt-point(6-rand,0)
      else
        pt=pt-point(-6+rand,0)
      end if
      qd= rect(pt,pt) +rect(-6,-6,6,6)
      grapeSprite=rect(12*(rand-1),0,12*rand-1,11)
      layerd.copyPixels(grapegraf, qd, grapeSprite, {#color:colr,#ink:36})
      if i > grape.count-3 then
        copyPixelsToEffectColor (gdLayer, d, qd, "grapegrad", grapeSprite, 0.5, 0.1)
      else 
        copyPixelsToEffectColor (gdLayer, d, qd, "grapegrad", grapeSprite, 0.5, 1-i/grape.count.float)
      end if
    end  repeat
  end if
end

on applyHandGrowers me, q, c, eftc
  q2 = q + gRenderCameraTilePos.locH
  c2 = c + gRenderCameraTilePos.locV
  frontWall = 0
  backWall = 29
  
  case lrSup of--["All", "1", "2", "3", "1:st and 2:nd", "2:nd and 3:rd"]
    "All":
      d = random(30)-1
      dmin=1
      dmax=29
    "1":
      d = random(10)-1
      dmin=1
      
      dmax=9
    "2":
      d = random(10)-1 + 10
      dmin=10
      dmax=19
    "3":
      d = random(10)-1 + 20
      dmin=20
      dmax=29
    "1:st and 2:nd":
      d = random(20)-1
      dmin = 1
      dmax = 19
    "2:nd and 3:rd":
      
      d = random(20)-1 + 10
      dmin = 20
      dmax = 29
    otherwise:
      d = random(30)-1
      dmin=1
      dmax=29
  end case
  
  --for anyone unfortunite enough to read this know that this code is not very good, far too complicated and busy, do not do what i do here
  --but basically it makes a list of points to generate on, then it places a stump along that list, then it draws the actual "stem", then it gets the head & determins 5 like crown spots and draws a bez towards them
  --this was my first real effect attempt, and despite me coming back and improving it later, i wouldnt have been able to do it without the help of hootis, alduris, and especially my love cactus, thank you.
  lr = 1+(d>9)+(d>19)
  if (gLEprops.matrix[q2][c2][lr][1]=0)then
    layerd = member("layer"&string(d)).image
    mdPnt = giveMiddleOfTile(point(q,c))
    headPos = mdPnt+point(-11+random(21), -11+random(21))
    pnt = point(headPos.locH, headPos.locV)
    points=[] 
    t=0.0
    mog=0 
    
    --generate array of q, c points until you stop
    repeat while pnt.locV<30000
      mog=mog+1
      pnt.locV=pnt.locV+1
      pnt.locH=pnt.locH -2 + random(3)
      points.add(point(pnt.locH, pnt.locV))
      
      tlPos = giveGridPos(point(pnt.locH, pnt.locV)) + gRenderCameraTilePos
      if tlPos.inside(rect(1,1,gLOprops.size.loch+1,gLOprops.size.locv+1)) = 0 then
        exit repeat
      else if solidAfaMv(tlPos, lr) = 1 then
        exit repeat
      end if
      
    end repeat
    
    thickness=restrict(lerp(points.count/5, 1, 0.8), 1, 80)
    
    --generate lump
    
    
    lumpdir = random(2)
    if lumpdir=2 then
      lumpdir=-1
    end if
    if  random(3) = 1 then
      a = points.count/2 - (random(points.count/3))
      a = a.integer
      -- -1 or +1 cuz director rand is strange and odd
      intensityLerp = lerp(80.0,0.01, a/points.count.float)
      intensityLerp=intensityLerp/100
      thicknessL=restrict(lerp(thickness*2, thickness/2, (1-power(1-(a/points.count.float), 5))), 4, thickness*2).float
      
      lumpqd=point(points[a].locH+(thicknessL*2*lumpdir), points[a].locV)
      lumpqd= rect(lumpqd, lumpqd)
      
      rand = random(6)
      
      lumpSprite=rect(30*(rand-1),0,30*rand-1,29)
      
      member("layer"&string(restrict(d, dmin, dmax))).image.copyPixels(member("oglumpgraf").image, lumpqd+rect(-thickness*2,-thickness*2 ,thickness*2 ,thickness*2 ), lumpSprite, {#color:colr,#ink:36})
      copyPixelsToEffectColor(gdLayer, restrict(d, dmin, dmax), lumpqd+rect(-thickness*2,-thickness*2 ,thickness*2 ,thickness*2 ), "oglumpgrad", lumpSprite, 0.5,  intensityLerp)
      
      member("layer"&string(restrict(d-1, dmin, dmax))).image.copyPixels(member("oglumpgraf").image, lumpqd+rect(-thickness,-thickness ,thickness ,thickness), lumpSprite,{#color:colr,#ink:36})
      copyPixelsToEffectColor(gdLayer, restrict(d-1, dmin, dmax), lumpqd+rect(-thickness,-thickness ,thickness ,thickness), "oglumpgrad", lumpSprite, 0.5,  intensityLerp)
    end if
    
    repeat with a = 1 to points.count then
      
      --ease out lerp for stem thickness, regular lerp for effect intensit
      lerp(thickness*2, thickness/2, (1-power(1-(a/points.count.float), 5)))
      thicknessL=restrict(lerp(thickness*2, thickness/2, (1-power(1-(a/points.count.float), 5))), 4, thickness*2).float
      thicknessL2=restrict(thicknessL/2, 1, thicknessL*2)
      intensityLerp = lerp(80.0,0.01, a/points.count.float)
      intensityLerp=intensityLerp/100
      pnt2 = points[a]
      qd = rect(pnt2-thicknessL, pnt2+thicknessL)
      qd2 = rect(pnt2-thicknessL2, pnt2+thicknessL2)
      
      
      --draw da stem
      member("layer"&string(d)).image.copyPixels(member("blob").image, qd, member("blob").rect, {#color:colr, #ink:36})
      member("layer"&string(restrict(d-1, dmin, dmax))).image.copyPixels(member("blob").image, qd2, member("blob").rect, {#color:colr, #ink:36})
      copyPixelsToEffectColor(gdLayer, d, qd+rect(-thicknessL, -thicknessL, thicknessL, thicknessL), "softBrush1", member("softBrush1").rect, 0.5, intensityLerp)
      copyPixelsToEffectColor(gdLayer, restrict(d-1, dmin, dmax), qd2+rect(-thicknessL2, -thicknessL2, thicknessL2, thicknessL2), "softBrush1", member("softBrush1").rect, 0.5, intensityLerp)
    end repeat
    
    
    --generate the crown, 5 times for 5 stems!!!
    i=1
    
    --mog mog :))
    --v is how many sprites will draw along each crown
    v=restrict(mog/10, 30, mog)
    mog=restrict(mog/2, 45, mog/2)
    
    startPnt = headPos
    repeat with i = 1 to 5 
      --determin end points, goes along a circle in pi/eights
      endPnt = point(mog, 0)
      ang=((i+1)*pi)/8.0
      ang=ang+pi
      tempEndX = endPnt.locH
      tempEndY = endPnt.locV
      endPnt.locH = (tempEndX)*cos(ang) - (tempEndY)*sin(ang)
      endPnt.locV = (tempEndY)*cos(ang) + (tempEndX)*sin(ang)
      endPnt=endPnt + startPnt
      midPnt=lerpVector(startPnt, endPnt, 0.5)
      widthPnt=gEEprops.effects[r].mtrx[q2][c2]/2.0 
      ctrl= point(midPnt.locH+(widthPnt*cos(ang)),midPnt.locV)
      prevPnt=point(0,0)
      endPnt.locV=endPnt.locV
      endPnt.locH=endPnt.locH+(((-mog/2.0)+random(mog))/2.0)
      t=0.0
      
      depthDir = 1
      depthAmount = random(10)
      if random(2) = 1 then 
        depthDir = -1  
      end if
      depthLerp = 0
      repeat while t<v
        timePercent=t/v
        t=t+1
        currentPnt=me.Bezpoint(startPnt, endPnt, ctrl, timePercent)
        pxlSize  = restrict(lerp(thickness, thickness/2, timePercent.float), 4, thickness)
        if t <> 0  then
          --Determin rect along bez
          rand = random(6)
          lumpSprite=rect(30*(rand-1),0,30*rand-1,29)
          
          ang2= lookAtpoint(currentPnt, prevPnt)
          
          alongBez = (prevPnt+currentPnt)/2.0
          alongBez = rect(alongBez, alongBez) + rect(-pxlSize, -pxlSize, pxlSize, pxlSize)
          
          --draw crown while lerping from 0 to random 5 depth
          
          if t<0 or t>1 then
            
            depthLerp=lerp(0,depthAmount, timePercent.float) * depthDir
            member("layer"&string(restrict(d+depthLerp.integer, dmin, dmax))).image.copypixels(member("oglumpgraf").image, alongbez, lumpSprite, {#color:colr, #ink:36})
          end if
        end if
        --lerp from 80 to zero along crown
        
        intensityLerp= lerp(80.0, 0.01, timePercent)
        intensityLerp=intensityLerp/100
        
        --super bright at the ends!!!! this doesnt work half the time but lowkey i cant be assed lmao
        if timePercent.float>0.95 then
          member("layer"&string(restrict(d+depthLerp.integer, dmin, dmax))).image.copypixels(member("destructiveMeltDestroy").image, alongbez + rect(-pxlSize, -pxlSize, pxlSize, pxlSize), member("destructiveMeltDestroy").image.rect, {#color:colr, #ink:36})
          copyPixelsToEffectColor(gdLayer, restrict(d+(depthLerp.integer), dmin, dmax), alongbez+rect(-thickness, -thickness, thickness, thickness), "softBrush1", member("softBrush1").rect, 0.5, 1)
        end if
        --those who apply color along crown
        copyPixelsToEffectColor(gdLayer, restrict(d+depthLerp.integer, dmin, dmax), alongbez, "blob", member("blob").rect, 0.5, intensityLerp)
        
        prevPnt=currentPnt
      end repeat
    end repeat
  end if
end

on applySpindle me, q, c, eftc
  q2 = q + gRenderCameraTilePos.locH
  c2 = c + gRenderCameraTilePos.locV
  case lrSup of--["All", "1", "2", "3", "1:st and 2:nd", "2:nd and 3:rd"]
    "All":
      lr = random(3)
      dmin = 6
      dmax = 29
    "1":
      lr= 1
      dmin = 6
      dmax = 9
    "2":
      lr= 2
      dmin = 10
      dmax = 19
    "3":
      lr= 3
      dmin = 20
      dmax = 29
    "1:st and 2:nd":
      lr = random(2)
      dmin = 6
      dmax = 19
    "2:nd and 3:rd":
      lr = random(2)+1
      dmin = 10
      dmax = 29
    otherwise:
      lr = random(3)
      dmin = 6
      dmax = 29
  end case
  currentLr = ((lr-1)*10) + random(9) - 1
  
  
  
  if (gLEprops.matrix[q2][c2][lr][1]=0)then
    dUp = (solidAfaMv(point(q2,c2-1), lr)=1)
    dDn = (solidAfaMv(point(q2,c2+1), lr)=1)
    dLf = (solidAfaMv(point(q2-1,c2), lr)=1)
    dRg = (solidAfaMv(point(q2+1,c2), lr)=1)
    
    if dUp = 1 or dDn = 1 or dLf = 1 or dRg = 1 then 
      mdPnt = giveMiddleOfTile(point(q,c))
      startBez = []
      if dUp = 1 then
        headPos = mdPnt+point(random(21)-11, -10)
        startBez = [2, 3, 5, 6]
      end if
      if dDn = 1 then
        headPos = mdPnt+point(random(21)-11, 10)
        startBez = [1, 4, 7, 8]
      end if
      if dLf = 1 then
        headPos = mdPnt+point(-10, random(21)-11)
        startBez = [1, 2, 6, 7]
      end if
      if dRg =1 then
        headPos = mdPnt+point(10, random(21)-11)
        startBez = [3, 4, 5, 8]
      end if
      
      bezDir = startBez[random(startBez.count)]
      --dictionary of potential bez directions the spindle can go based on where it is, i wrote this out but its hard to explain via lingo comment sorry
      
      spindleDic = [[1, 7, 2], [2, 3, 6], [3, 5, 4], [4, 8, 1], [5, 3, 6], [6, 2, 7], [7, 1, 8], [8, 4, 5]]
      --big dictionary of bez points a, ca, b, cb because I dont feel like making some kinda equasion for this 
      --basically 1,2,3,4 is a circle going clockwise starting at the top right and 5,6,7,8 is a circle going counterclockwise starting topright
      
      bezDic = [[point(0,0), point(0, -5), point(10, -10), point(5,-10)] , [point(0, 0), point(5, 0), point(10, 10), point(10, 5)] ,[point(0,0), point(0, 5), point(-10, 10), point(-5, 10)] , [point(0,0), point(-5, 0), point(-10, -10), point(-10, -5)] ,[point(0,0), point(-5, 0), point(-10, 10), point(-10, 5)] ,[point(0, 0), point(0, 5), point(10, 10), point(5, 10)] , [point(0,0), point(5, 0), point(10, -10), point(10, -5)]  ,[point(0,0), point(0, -5), point(-10, -10), point(-5, -10)]]     
      --pnt, lr, bezdir
      points=[]
      currentPnt = point(0 ,0)
      --start generating points, 50 is temp value
      repeat with branch = 1 to 50
        if bezDir > 10 then
          bezDir = bezDir-10
        end if
        
        --currentPnt = point(0 ,0)
        bezDir = spindleDic[bezDir][random(3)]
        tempPoints=[]
        
        --collision check looks through possible points and picks points that arent touching wall
        repeat with collisionCheck = 1 to 3
          tempPnt = CurrentPnt+bezDic[ spindleDic[bezDir][collisionCheck] ][3]
          tempPnt = tempPnt+headPos
          
          --(afaMvLvlEdit(giveGridPos(pos)+gRenderCameraTilePos, ((lstLayer/10.0)-0.4999).integer+1-1)=1)
          if afaMvLvlEdit(giveGridPos(tempPnt)+gRenderCameraTilePos, Lr) = 0 and branch > 5 then
            
            tempPoints.add(spindleDic[bezDir][collisionCheck])
          end if
          
        end repeat
        
        if  tempPoints.count <> 0 then
          bezDir = tempPoints[random(tempPoints.count)]
        else
          exit repeat
        end if
        
        --check  for too  many repititions
        if points.count <> 0 then
          if points[points.count][3] = bezDir then
            
            repeatCount = repeatCount + 1
            if repeatCount = 2 then
              
              bezDir = spindleDic[bezDir][random(2)+1]
              repeatCount = 0
            end if
          end if
        end if
        currentPnt = CurrentPnt+bezDic[bezDir][3]
        points.add([currentPnt+headPos, currentLr, bezDir])
        
        --random chance to add loop
        if random (8)= 1 then
          repeat with i = 1 to 4 then
            if i = 5 then
              exit repeat
            end if
            
            if bezDir > 4 then
              --fuck you, what the fuck
              loopArray = [5, 6, 7, 8, 5, 6, 7, 8, 5]
              --TODO: remove 10 as its a test value to make sure its in loop
              currentPnt = currentPnt+bezDic[loopArray[bezDir+i-4]][3]
              points.add([currentPnt+headPos, currentLr, 10+ loopArray[bezDir+i-4]])
            else
              loopArray=[1, 2, 3, 4, 1, 2, 3, 4, 1]
              
              currentPnt = currentPnt+bezDic[loopArray[bezDir+i]][3]
              points.add([currentPnt+headPos, currentLr, loopArray[bezDir+i]+10])
            end if
            if random(2)=1 then
              currentLr = restrict(currentLr-1, dmin, dmax)
            else
              currentLr = restrict(currentLr+1, dmin, dmax)
            end if
          end repeat
          --makes the bezier draw in a "loop"
          if bezDir >4 then
            bezDir=loopArray[bezDir+i-4]
          else
            bezDir=loopArray[bezDir+i]
          end if
        end if
        
        -- depth
        repeat with a=2 to points.count then
          if [points[a][1], points[a][2]] = [ points[points.count][1], points[points.count][2]]then
            if random(2)=1 then
              currentLr = restrict(currentLr-1, dmin, dmax)
            else
              currentLr = restrict(currentLr+1, dmin, dmax)
            end if
          end if
          
        end repeat
        
      end repeat
      --draw points
      direc=[]
      inV = 50*points.count
      inI = 0
      repeat with a = 2 to points.count then
        v = 50
        
        direc.add(points[a][3])
        
        repeat with t = 1 to v
          
          timePercent = t/v.float
          --test to check if bezdir was in a loop
          if points[a][3] > 10 then
            bezDir=points[a][3]-10
          else
            bezDir = points[a][3]
          end if
          inI = inI+1
          lerpIntensity=lerp(0 , 1 , inI/inV.float)
          qd = bezier( point(0,0) , bezDic[ bezDir ][2], bezDic[bezDir][3], bezDic[bezDir][4], timePercent)+points[a-1][1]
          qd = rect(qd, qd)+rect(-1, -1, 1, 1)
          
          member("layer"&string(points[a][2])).image.copypixels(member("pxl").image, qd, rect(0,0,1,1), {#color:colr, #ink:36})
          copyPixelsToEffectColor(gdLayer, points[a][2], qd, "pxl", rect(0,0,1,1), 0.5, lerpIntensity)
        end repeat
      end repeat
    end if  
  end if
end

--determines current point along bezier at time T
--for hand grower, rendereffect grows longer by the day :JEEPERS:, also thank you cactus for helping me with this
on BezPoint me, startPT, endPT, ctrlPT, T
  xVal = (1-T) * ((1-T) * startPT.locH + t * ctrlPT.locH) + T * ((1-T) * ctrlPT.locH + T * endPT.locH)
  yVal = (1-T) * ((1-T) * startPT.locV + t * ctrlPT.locV) + T * ((1-T) * ctrlPT.locV + T * endPT.locV)
  output = point(xVal, yVal)
  return output
end


on applyWireBunch me, q, c, eftc 
  q2 = q + gRenderCameraTilePos.locH
  c2 = c + gRenderCameraTilePos.locV
  
  case lrSup of
    "All":
      lsL = [1,2,3]
    "1":
      lsL = [1]
    "2":
      lsL = [2]
    "3":
      lsL = [3]
    "1:st and 2:nd":
      lsL = [1,2]
    "2:nd and 3:rd":
      lsL = [2,3]
    otherwise:
      lsL = [1,2,3]
  end case
  layer = lsL[random(lsL.count)]
  --collision detection for if it is next to a wall
  dUp = (solidMtrx[q2][c2][layer]<>1) and (solidAfaMv(point(q2,c2-1), layer) = 1)
  dDn = (solidMtrx[q2][c2][layer]<>1) and (solidAfaMv(point(q2,c2+1), layer) = 1)
  dLf = (solidMtrx[q2][c2][layer]<>1) and (solidAfaMv(point(q2-1,c2), layer) = 1)
  dRg = (solidMtrx[q2][c2][layer]<>1) and (solidAfaMv(point(q2+1,c2), layer) = 1)
  layer = ((lsL[random(lsL.count)]-1)*10) + random(9) - 1
  mdPnt = giveMiddleOfTile(point(q,c))
  
  if dDn or dLf or dRg or dUp then
    mdPnt = giveMiddleOfTile(point(q,c))
    lengthA = gEEprops.effects[r].mtrx[q2][c2]*2 + random(gEEprops.effects[r].mtrx[q2][c2]*3)
    lengthB = gEEprops.effects[r].mtrx[q2][c2]*2 + random(gEEprops.effects[r].mtrx[q2][c2]*3)
    repeat with wirenum = 1 to 3
      case random(3) of
        1:
          colr = color(0, 255, 0)
        2:
          colr = color(0, 0, 255)
        3:
          colr = color(255, 0, 0)
        otherwise:
          colr = color(0, 255, 0)
      end case
      -- set the  area of headpos based on what wall it will touch
      layer = ((lsL[random(lsL.count)]-1)*10) + random(9) - 1
      lengthA = lengthA/2
      lengthB = lengthB/2
      if dUp = 1 then
        headPos = mdPnt + point(random(21) - 11, -12)
        angl = 180 + random(90) - 45
        
      end if
      if dDn = 1 then
        headPos = mdPnt + point(random(21) - 11, 12)
        angl = 0 + random(90) - 45
        
      end if
      if dLf = 1 then
        headPos = mdPnt + point(-12, random(21) - 11)
        angl = 90 + random(90) - 45
      end if
      if dRg = 1 then
        headPos = mdPnt + point(12, random(21) - 11)
        angl = 270 + random(90) - 45
      end if
      
      --determin control points
      
      ctrlPntA = angl - 45 - random(15)
      ctrlPntB = angl + 45 + random(15)
      
      --degree to angle 
      --gEEprops.effects[r].mtrx[q2][c2] is intensity
      ctrlPntA = degToVec(ctrlPntA) * lengthA
      ctrlPntB = degToVec(ctrlPntB) * lengthB
      ctrlPntA = ctrlPntA + headPos
      ctrlPntB = ctrlPntB + headPos
      thickness = restrict(random(3) - wirenum, 1, 4)
      --draw bez
      v = lengthA + lengthB / 2
      repeat with t = 1 to v then
        timePercent = t / v.float  
        qd = bezier(headPos, ctrlPntA, headPos, ctrlPntB, timePercent)
        qd = rect(qd, qd) + rect(thickness * -1, thickness * -1, thickness, thickness)
        member("layer"&string(layer)).image.copyPixels(member("blob").image, qd, member("blob").image.rect, {#color:colr, #ink:36})
      end repeat
    end repeat
  end if
end


on ApplyJoarFW me, q, c, eftc
  q2 = q + gRenderCameraTilePos.locH
  c2 = c + gRenderCameraTilePos.locV
  case lrSup of
    "All":
      lsL = [1,2,3]
    "1":
      lsL = [1]
    "2":
      lsL = [2]
    "3":
      lsL = [3]
    "1:st and 2:nd":
      lsL = [1,2]
    "2:nd and 3:rd":
      lsL = [2,3]
    otherwise:
      lsL = [1,2,3]
  end case
  layer = ((lsL[random(lsL.count)] - 1) * 10) + random(9)
  if (solidMtrx[q2][c2][lsL[random(lsL.count)]]<>1) and (solidAfaMv(point(q2,c2+1), lsL[random(lsL.count)]) = 1) then
    intensity =gEEprops.effects[r].mtrx[q2][c2]
    mdPnt = giveMiddleOfTile(point(q,c))
    headPos = mdPnt + point(random(21) - 11, 12)
    
    qd = headPos 
    joarSegmentTotal = restrict(intensity/10, 3, intensity/10)
    points = [[headPos, 90]]
    pnt = headPos
    boxHeight = random(10) + 10
    --basically how many beziers there are gonna be 
    repeat with joarSegment = 1 to joarSegmentTotal
      
      angl = (random(lerp(180,90, joarSegment/joarSegmentTotal.float))-lerp(90, 45, joarSegment/joarSegmentTotal.float))
      --intensityLerp = lerp(intensity.float, intensity.float/4, joarSegment/joarSegmentTotal.float)
      intensityLerp = lerp(boxHeight, 6, joarSegment/joarSegmentTotal.float)
      pnt = pnt + (degToVec(angl) * intensitylerp)
      points.add([pnt, angl])
    end repeat
    
    --draw points
    totalT = 1
    totalV = 0
    repeat with t = 2 to points.count
      v=sqrt(power(points[t][1].locH - points[t - 1][1].locH, 2) + power(points[t][1].locV - points[t - 1][1].locV, 2)).integer
      v = v* 5
      totalV = totalV+v
    end repeat
    
    repeat with t = 2 to points.count
      v=sqrt(power(points[t][1].locH - points[t - 1][1].locH, 2) + power(points[t][1].locV - points[t - 1][1].locV, 2)).integer
      qd2 = points[t][1]
      -- qd2 = rect(qd, qd) + rect(-2, -2, 2, 2)
      qd = points[t-1][1]
      --qd = rect(qd2, qd2) + rect(-2, -2, 2, 2)
      
      --determine control points for beziers
      if t mod 2 = 0 then 
        bezAng = points[t-1][2] + 90  
      else
        bezAng = points[t-1][2] - 90
      end if
      
      ctrlPntA = points[t-1][1] + points[t][1]
      ctrlPntA = ctrlPntA / 2
      --TODO: replace 30 with some arbitrary value
      
      bezFactor = v/t + random(10)
      ctrlPntA = ctrlPntA + (degToVec(bezAng) * bezFactor)
      ctrlPntB = ctrlPntA
      ctrlPntA = ctrlPntA + (degToVec(bezAng-90) * bezFactor)
      ctrlPntB = ctrlPntB + (degToVec(bezAng+90) * bezFactor)
      
      --determine where to buldge lerp
      rand = random(100)
      sizeLerp = rand.float/100
      baseThickness = random(2) + 1
      targetThickness = random(4) + 2
      v=v*5
      --draw beziers
      repeat with t2 = 1 to v
        totalT = totalT + 1
        --to determine which direction the bez goes 
        if t mod 2 = 0 then
          bezQd = bezier(qd, ctrlPntB, qd2, ctrlPntA, t2/v.float)
        else 
          bezQd = bezier(qd, ctrlPntA, qd2, ctrlPntB, t2/v.float)
        end if
        
        --lerp from base to target, then back to base :face_orange_biting_nails:
        if t2/v.float < sizeLerp then
          yurp =( (t2/v.float)/sizeLerp)
          --ease in lerp
          thickness = lerp(baseThickness, targetThickness, 1 - sqrt(1 - power(yurp, 2)))
        else 
          thickness = lerp(targetThickness, baseThickness, ((t2 / v.float) - sizeLerp) / sizeLerp)
        end if
        
        bezQd = rect(bezQd, bezQd) + rect(-thickness,-thickness,thickness,thickness)
        member("layer"&string(layer)).image.copyPixels(member("blob").image, bezQd, member ("blob").image.rect, {#color:colr, #ink:36})
        effectLerp = lerp(0, 0.8, totalT / totalV.float)
        copyPixelsToEffectColor (gdLayer, layer, bezQd, "blob", member("blob").image.rect, 0.5, effectLerp)
      end repeat
    end repeat
    
    --draw head 
    qd = rect(-targetThickness * 6, -targetThickness *  2, targetThickness * 6, targetThickness * 2) + rect(points[points.count][1].locH,points[points.count][1].locV,points[points.count][1].locH, points[points.count][1].locV)
    qd = rotateToQuad(qd, points[points.count][2]+90)
    repeat with dep = 1 to random(3)
      
      if dep = 1 then 
        member("layer"&string(layer)).image.copyPixels(member("BoxGrubGraf1").image, qd, member ("BoxGrubGraf1").image.rect, {#color:colr, #ink:36})
        copyPixelsToEffectColor (gdLayer, layer, qd, "BoxGrubGrad2", member("BoxGrubGrad2").image.rect, 0.5, 1)
      else 
        dmin = (((lsL[1] - 1) * 10))
        dmax = (((lsL[lsL.count] - 1) * 10) + 9 )
        
        if layer < 10 and layer > 5 then 
          dmin = 5  
        end if
        
        member("layer"&string(restrict(layer - dep, dmin, dmax))).image.copyPixels(member("BoxGrubGraf2").image, qd, member ("BoxGrubGraf2").image.rect, {#color:colr, #ink:36})
        --erase hole 
        
        copyPixelsToEffectColor (gdLayer, restrict(layer - dep, dmin, dmax), qd, "BoxGrubGrad2", member("BoxGrubGrad2").image.rect, 0.5, 1)
      end if
      
      
    end repeat
  end if
  
end


--my little HBlings, inspired by the Odradek from death stranding
on applyOrblings me, q, c
  q2 = q + gRenderCameraTilePos.locH
  c2 = c + gRenderCameraTilePos.locV
  case lrSup of
    "All":
      lsL = [1,2,3]
    "1":
      lsL = [1]
    "2":
      lsL = [2]
    "3":
      lsL = [3]
    "1:st and 2:nd":
      lsL = [1,2]
    "2:nd and 3:rd":
      lsL = [2,3]
    otherwise:
      lsL = [1,2,3]
  end case
  lsL = lsL[random(lsL.count)]
  layer = ((lsL-1)*10) + random(9) - 1
  if layer = 5 then 
    layer = layer + 1
  end if
  
  
  if (gLEprops.matrix[q2][c2][lsL][1]=0)then
    midPoint = giveMiddleOfTile(point(q, c))
    midPoint = midPoint + point(lerp(-10, 10, random(100).float/100), lerp(-10, 10, random(100).float/100))
    repeatFlag = true
    qd = midPoint
    points = []
    points.add(qd)
    orbAngle = lerp(135, 225, random(100).float/100)
    repeat while repeatFlag then
      
      qd = qd + degToVecFac2(orbAngle, 20, 20)
      orbAngle = lerp(135, 225, random(100).float/100)
      points.add(qd)
      if withinBoundsOfLevel(giveGridPos(qd) + gRenderCameraTilePos) = 0 then
        if skyRootsFix then
          exit 
        end if
        repeatFlag = false
      end if
      
      if afaMvLvlEdit(giveGridPos(qd) + gRenderCameraTilePos, lsL) = 1 then
        repeatFlag = false
      end if
      
    end repeat
    --get total dist for lerp
    totalDist = 0
    totalT = 1
    repeat with t = 2 to points.count
      totalDist = totalDist + sqrt(power(points[t].locV - points[t-1].locV, 2) + power(points[t].locH - points[t-1].locH, 2))  
      
    end repeat
    randomIntensity = lerp(0.5, 0.7, random(100).float/100)
    --render points
    repeat with t = 1 to points.count then
      --draw head
      if t = 1 then
        --stupid easter egg
        if random(15) = 1 then
          qd = rect(points[t].locH-5, points[t].locV - 7, points[t].locH + 5, points[t].locV + 7)
          member("layer"&string(layer)).image.copyPixels(member("orblingGraf").image, qd, member("orblingGraf").image.rect, {#color:colr, #ink:36})
        else
          qd = rect(points[t].locH-5, points[t].locV - 5, points[t].locH + 5, points[t].locV + 5)
          member("layer"&string(layer)).image.copyPixels(member("blob").image, qd, member("blob").image.rect, {#color:colr, #ink:36})
        end if
        qd = rect(points[t].locH-10, points[t].locV - 10, points[t].locH + 10, points[t].locV + 10)
        copyPixelsToEffectColor (gdLayer, layer, qd, "softBrush1", member("softBrush1").image.rect, 0, 1)
      end if
      
      if t > 1 then
        dist  = sqrt(power(points[t].locV - points[t-1].locV, 2) + power(points[t].locH - points[t-1].locH, 2))
        
        
        repeat with t2 = 1 to dist then
          lerpPercent = (totalT).float/totalDist
          qdSize = lerp(1, lerp(2, 4, gEEprops.effects[r].mtrx[q2][c2].float/100), lerpPercent)
          intensityLerp = lerp(randomIntensity, 0, lerpPercent).float
          qdSize = restrict( qdSize + lerp(-2, 2, random(100).float/100), 1, 6)
          qd = lerpPnt(points[t-1], points[t], t2.float/dist)
          qd = rect(qd.locH-qdSize, qd.locV - qdSize, qd.locH + qdSize, qd.locV + qdSize)
          member("layer"&string(layer)).image.copyPixels(member("blob").image, qd, member ("blob").image.rect, {#color:colr, #ink:36})
          copyPixelsToEffectColor (gdLayer, layer, qd, "blob", member("blob").image.rect, 0, intensityLerp)
          --"joints"
          if t2 = 1 then
            qd = lerpPnt(points[t-1], points[t], t2.float/dist)
            qd = rect(qd.locH-qdSize*1.5, qd.locV - qdSize*1.5, qd.locH + qdSize*1.5, qd.locV + qdSize*1.5)
            
            if t=2 then
              qdSize = restrict(qdSize, 1, 2)
              qd = lerpPnt(points[t-1], points[t], t2.float/dist)
              qd = rect(qd.locH-qdSize*2, qd.locV - qdSize*2, qd.locH + qdSize*2, qd.locV + qdSize*2)
              if random(2) = 1 then
                member("layer"&string(restrict(layer-1, 0, 29))).image.copyPixels(member("blob").image, qd, member ("blob").image.rect, {#color:colr, #ink:36})
              end if
            else 
              member("layer"&string(restrict(layer-1, 0, 29))).image.copyPixels(member("blob").image, qd, member ("blob").image.rect, {#color:colr, #ink:36})
              copyPixelsToEffectColor (gdLayer, restrict(layer-1, 0, 29), qd, "blob", member("blob").image.rect, 0.5, lerp(0.3, 0, lerpPercent))
            end if
          end if
          totalT = totalT + 1
        end repeat
        
      end if
    end repeat
  end if
end

on applyMamaOrblings me, q, c
  q2 = q + gRenderCameraTilePos.locH
  c2 = c + gRenderCameraTilePos.locV
  case lrSup of
    "All":
      lsL = [1,2,3]
    "1":
      lsL = [1]
    "2":
      lsL = [2]
    "3":
      lsL = [3]
    "1:st and 2:nd":
      lsL = [1,2]
    "2:nd and 3:rd":
      lsL = [2,3]
    otherwise:
      lsL = [1,2,3]
  end case
  lsL = lsL[random(lsL.count)]
  layer = ((lsL-1)*10) + random(9) - 1
  if layer = 5 then 
    layer = layer + 2
  else if layer = 6 then
    layer = layer + 1
  end if
  
  --determine points
  if (gLEprops.matrix[q2][c2][lsL][1]=0)then
    midPoint = giveMiddleOfTile(point(q, c))
    midPoint = midPoint + point(lerp(-10, 10, random(100).float/100), lerp(-10, 10, random(100).float/100))
    repeatFlag = true
    qd = midPoint
    points = []
    points.add(qd)
    orbAngle = lerp(135, 225, random(100).float/100)
    lerpGradual = 0
    repeat while repeatFlag then
      distLerp = lerp(40, 60, lerpGradual)
      lerpGradual = restrict(lerpGradual + 0.1, 0, 1)
      qd = qd + degToVecFac2(orbAngle, distLerp, distLerp)
      orbAngle = lerp(135, 225, random(100).float/100)
      points.add(qd)
      if withinBoundsOfLevel(giveGridPos(qd) + gRenderCameraTilePos) = 0 then
        if skyRootsFix then
          exit 
        end if
        repeatFlag = false
      end if
      
      if afaMvLvlEdit(giveGridPos(qd) + gRenderCameraTilePos, lsL) = 1 then
        repeatFlag = false
      end if
      
    end repeat
    --now draw from points
    totalDist = 0
    totalT = 0
    repeat with t = 2 to points.count
      totalDist = totalDist + sqrt(power(points[t].locV - points[t-1].locV, 2) + power(points[t].locH - points[t-1].locH, 2))  
      
    end repeat
    
    repeat with i = 1 to points.count then
      --draw "head"
      if i = 1 then
        headCount = lerp(3, 5, random(100).float/100).integer
        headAngleAmount = 360 / headcount
        baseAngle = (vectoradLB(dirVecLB(points[i], points[i+1])) * 180) / pi
        baseAngle = baseAngle + 45
        rand = random(100).float/100
        repeat with j = 1 to headCount then
          
          headAngle = ((headAngleAmount * j) + baseAngle) mod 360
          
          dist = lerp(70, 40, rand).integer
          qd = points[1] + degToVecFac2(headAngle, dist, dist)
          --make branches from points[1] to qd
          repeat with k = 1 to dist/4 then
            percent = k / (dist/4).float
            qd2 = lerpPnt(points[1], qd, percent)
            --easeInOutCubic
            if percent < 0.5 then
              thicknessPercent = 4 * percent * percent  * percent 
            else
              thicknessPercent = 1 - power(-2 * percent + 2, 3) / 2
            end if
            thicknessMax = lerp(8, 5, rand)
            thicknessMin = lerp(4, 2, rand)
            thickness = lerp(thicknessMax, thicknessMin, thicknessPercent)
            thickness = restrict(thickness + lerp(-3, 3, random(100).float/100), 2, 20)
            thickness2 = sphereDepth(thickness, thickness - (thickness/5))
            qd3 = rect(qd2.locH - thickness, qd2.locV - thickness, qd2.locH + thickness, qd2.locV + thickness)
            qd3 = rotateToQuad(qd3, random(360))
            member("layer"&string(layer)).image.copyPixels(member("blob").image, qd3, member ("blob").image.rect, {#color:colr, #ink:36}) 
            copyPixelsToEffectColor (gdLayer, restrict(layer, 0, 29), qd3, "blob", member("blob").image.rect, 0, lerp(0, 0.6, percent))
            
            if thickness2 > 1 then
              qd3 = rect(qd2.locH - thickness2, qd2.locV - thickness2, qd2.locH + thickness2, qd2.locV + thickness2)
              member("layer"&string(restrict(layer - 1, 0, 29))).image.copyPixels(member("blob").image, qd3, member ("blob").image.rect, {#color:colr, #ink:36})
              qd3 = rect(qd2.locH - thickness, qd2.locV - thickness, qd2.locH + thickness, qd2.locV + thickness)
              copyPixelsToEffectColor (gdLayer, restrict(layer-1, 0, 29), qd3, "blob", member("blob").image.rect, 0, lerp(0, 0.6, percent) * 0.9)
            end if
          end repeat
          --head ends
          thickness = lerp(10, 6, rand)
          qd2 = rect(qd.locH - thickness, qd.locV - thickness, qd.locH + thickness, qd.locV + thickness)
          qd2 = rotateToQuadFix(qd2, random(360))
          member("layer"&string(restrict(layer - 2, 0, 29))).image.copyPixels(member("blob").image, qd2, member ("blob").image.rect, {#color:colr, #ink:36})
          qd2 = rect(qd.locH - 20, qd.locV - 20, qd.locH + 20, qd.locV + 20)
          qd2 = rotateToQuadFix(qd2, random(360))
          copyPixelsToEffectColor (gdLayer, restrict(layer - 2, 0, 29), qd2, "softBrush1", member("softBrush1").image.rect, 0, 1)
        end repeat
      else
        --draw stems
        
        dist  = sqrt(power(points[i].locV - points[i-1].locV, 2) + power(points[i].locH - points[i-1].locH, 2))
        thicknessPercent = i.float / points.count
        --draw between stem
        repeat with j = 1 to dist then
          percent = j / dist.float
          totalPercent = totalT.float / totalDist
          if totalPercent < 0.2 then
            yurp = totalPercent / 0.2
            intensity = lerp(0.001, 0.6, yurp)
          else
            intensity = lerp(0.6, 0.001,  (totalPercent - 0.2).float / 0.7)
          end if
          
          --fuck this line and fuck you
          --scales between each node, but also from the last node to the next one along the thing
          thickness = lerp(lerp(2, 8, (i-1).float / points.count), lerp( 2, 8, i.float / points.count), 1-percent)
          thickness = thickness + lerp(-2, 2, random(100).float/100)
          if percent > 0.95 or percent < 0.05 then
            thickness = thickness * 1.5  
          end if
          thickness2 = sphereDepth(thickness, thickness - thickness/4)
          qd = lerpPnt(points[i-1], points[i], percent)
          qd2 = rect(qd.locH-thickness2, qd.locV-thickness2, qd.locH+thickness2, qd.locV+thickness2)
          qd = rect(qd.locH-thickness, qd.locV-thickness, qd.locH+thickness, qd.locV+thickness)
          qd = rotateToQuadFix(qd, random(360))
          member("layer"&string(layer)).image.copyPixels(member("blob").image, qd, member ("blob").image.rect, {#color:colr, #ink:36})
          
          member("layer"&string(restrict(layer - 1, 0, 29))).image.copyPixels(member("blob").image, qd2, member ("blob").image.rect, {#color:colr, #ink:36})
          copyPixelsToEffectColor (gdLayer, restrict(layer, 0, 29), qd, "blob", member("blob").image.rect, 0, intensity)
          copyPixelsToEffectColor (gdLayer, restrict(layer - 1, 0, 29), qd, "blob", member("blob").image.rect, 0, intensity * 0.9)
          totalT = totalT + 1
        end repeat
        --draw joints
        thickness = lerp(4, 10, (i-1).float / points.count)
        thickness = thickness + lerp(-2, 3, random(100).float/100)
        qd = rect(points[i - 1].locH-thickness, points[i - 1].locV-thickness, points[i - 1].locH + thickness, points[i - 1].locV + thickness)
        qd = rotateToQuadFix(qd, random(360))
        member("layer"&string(restrict(layer - 2, 0, 29))).image.copyPixels(member("blob").image, qd, member ("blob").image.rect, {#color:colr, #ink:36})
        thickness = thickness * 2
        qd = rect(points[i - 1].locH-thickness, points[i - 1].locV-thickness, points[i - 1].locH + thickness, points[i - 1].locV + thickness)
        qd = rotateToQuadFix(qd, random(360))
        copyPixelsToEffectColor (gdLayer, restrict(layer - 2, 0, 29), qd, "softBrush1", member("softBrush1").image.rect, 0, lerp(0.5, 0.3, i.float/points.count))
      end if
      
    end repeat
  end if
end





