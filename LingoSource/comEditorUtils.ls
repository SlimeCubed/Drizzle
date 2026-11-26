global gLoadedName, INT_EXIT, INT_EXRD, DRInternalList, DRFirstTileCat, DRLastMatCat, RandomMetals_allowed, RandomMetals_grabTiles, ChaoticStone2_needed, DRRandomMetal_needed, SmallMachines_grabTiles, SmallMachines_forbidden, RandomMachines_forbidden, RandomMachines_grabTiles, RandomMachines2_forbidden, RandomMachines2_grabTiles, DRBevelColors, CommsDrizzle, gTiles, GL_ptPos, GL_drPos, GL_keyDict, gCustomKeybinds, gVersion

on clearLogs()
  --type fl: dynamic
  --type return: void
  member("logText").text = "Rain World Community Editor; " & gVersion & "; Editor exception log"
  member("DEBUGTR").text = "Rain World Community Editor; " & gVersion & "; Large trash log"
  fl = new xtra("fileio")
  fl.openFile(the moviePath & "editorExceptionLog.txt", 0)
  fl.delete()
  fl.createFile(the moviePath & "editorExceptionLog.txt")
  fl.openFile(the moviePath & "editorExceptionLog.txt", 0)
  fl.writeString(member("logText").text)
  fl.closeFile()
  fl.openFile(the moviePath & "largeTrashLog.txt", 0)
  fl.delete()
  fl.createFile(the moviePath & "largeTrashLog.txt")
  fl.openFile(the moviePath & "largeTrashLog.txt", 0)
  fl.writeString(member("DEBUGTR").text)
  fl.closeFile()
end

on prepareRelease(shouldHalt)
  member("logText").text = ""
  member("editorConfig").text = ""
  member("DEBUGTR").text = ""
  member("editorKeybinds").text = ""
  member("effectsInit").text = ""
  member("matInit").text = ""
  member("initImport").text = ""
  member("effectsL").text = "<EFFECTS>"
  member("editEffectName").text = ""
  member("effectOptions").text = "[ Layers ]: All"&RETURN&"All     1     - 2 -   3     1:st and 2:nd     2:nd and 3:rd     "
  member("level Name").text = "New Project"
  member("ProjectsL").text = ""
  member("tileMenu").text = ""
  member("propMenu").text = ""
  member("Prop Depth Text").text = ""
  member("rulerText").text = ""
  member("previewTiles").image = image(1, 1, 1)
  member("previewTilesDR").image = image(1, 1, 1)
  member("previewImprt").image = image(1, 1, 1)
  member("activeLightImage").image = image(1, 1, 1)
  member("propsImage").image = image(52*16, 40*16, 16)
  member("TEimg1").image = image(52*16, 40*16, 16)
  member("TEimg2").image = image(52*16, 40*16, 16)
  member("TEimg3").image = image(52*16, 40*16, 16)
  member("tilePreview").image = image(1, 1, 1)
  member("dpImage").image = image(1, 1, 1)
  member("finalImage").image = image(1, 1, 1)
  member("fogImage").image = image(1, 1, 1)
  member("shadowImage").image = image(1, 1, 1)
  member("horiImg").image = image(1, 1, 1)
  member("vertImg").image = image(1, 1, 1)
  member("flattenedGradientA").image = image(1, 1, 1)
  member("flattenedGradientB").image = image(1, 1, 1)
  member("previewTiles").image = image(1, 1, 1)
  
  repeat with q = 1 to 1000
    (member q of castLib 2).erase() -- customMems
  end repeat
  
  go the frame
  if shouldHalt then _movie.halt()
end

on checkDebugKeybinds()
  if checkCustomKeybind(#ExportAssets, ["E","A",48]) then -- tab+e+a
    exportAll()
  else if checkCustomKeybind(#OutputInternalLog, ["I","L",48]) then -- tab+i+l
    outputInternalLog()
  else if checkCustomKeybind(#PrepareInternalsForRelease, ["P","I",48]) then -- tab+P+I
    prepareRelease(TRUE)
  else if checkCustomKeybind(#RestartComputer, [48,"X","C","P",36]) then -- thanks drycrycrystal for suggesting this
    _system.restart() -- restart computer lmao
  else if checkCustomKeybind(#ShutdownComputer, VOID) then
    _system.shutDown()
  end if
end

on writeException(tp: string, msg: dynamic)
  type fileOpener: dynamic
  type return: void
  member("logText").text = member("logText").text&RETURN&string(gLoadedName)&" ! "&string(tp)&" Exception : "&string(msg)
  fileOpener = new xtra("fileio")
  fileOpener.openFile(the moviePath & "editorExceptionLog.txt", 0)
  fileOpener.writeString(member("logText").text)
  fileOpener.writeReturn(#windows)
end

on writeMessage(msg: dynamic)
  type fileOpener: dynamic
  type return: void
  member("logText").text = member("logText").text&RETURN&string(gLoadedName)&" : "&string(msg)
  fileOpener = new xtra("fileio")
  fileOpener.openFile(the moviePath & "editorExceptionLog.txt", 0)
  fileOpener.writeString(member("logText").text)
  fileOpener.writeReturn(#windows)
end

on writeInfoMessage(msg: dynamic)
  type fileOpener: dynamic
  type return: void
  member("logText").text = member("logText").text&RETURN&"Info : "&string(msg)
  fileOpener = new xtra("fileio")
  fileOpener.openFile(the moviePath & "editorExceptionLog.txt", 0)
  fileOpener.writeString(member("logText").text)
  fileOpener.writeReturn(#windows)
end

on writeInternalMessage(msg: dynamic)
  type return: void
  member("logText").text = member("logText").text&RETURN&string(gLoadedName)&" : "&string(msg)
end

on outputInternalLog()
  type fileOpener: dynamic
  type return: void
  fileOpener = new xtra("fileio")
  fileOpener.openFile(the moviePath & "editorExceptionLog.txt", 0)
  fileOpener.writeString(member("logText").text)
  fileOpener.writeReturn(#windows)
end

on popupWarning(ttl, msg)
  if not checkIsDrizzleRendering() then
    _player.alert(ttl & ": " & msg)
  end if
  --if not checkIsDrizzleRendering() then
  --  alertObj = new xtra("MUI")
  --  alertArgs = [#buttons:#Ok, #icon:#caution, #title:ttl, #message:msg&RETURN&RETURN&"Press 'Ok' to dismiss.", #movable:TRUE]
  --  if objectp(alertObj) then
  --    Alert(alertObj, alertArgs)
  --  end if
  --end if
end

on exportAll()
  type pth: string
  type objFileio: dynamic
  type objImg: dynamic
  type return: void
  if getBoolConfigOrDefault("Strip assets on export", true) then
    prepareRelease(FALSE)
  end if
  pth = the moviePath & "Export/"
  objFileio = new xtra("fileio")
  objImg = new xtra("ImgXtra")
  i = 1
  repeat while i < 100 -- I hope there's not more than 100 cast libs in the future lol
    type c: dynamic
    type cname: string
    c = castLib(i)
    i = i + 1
    if c = void then exit repeat
    cname = c.name & "_"
    repeat with m in c.member
      type m: dynamic
      type fname: string
      if (m.name = VOID) then
        fname = pth & c.name & "_" & string(m.number)
      else
        fname = pth & c.name & "_" & string(m.number) & "_" & m.name
      end if
      if (m.type = #bitmap) then
        objImg.ix_saveImage(["image": m.image, "filename": fname & ".png", "format": "PNG"])
      else if (m.type = #script) then
        scriptNm = pth & m.name & ".ls"
        --if getBoolConfig("Include script category") then scriptNm = pth & c.name & "_" & m.name & ".ls"
        createFile(objFileio, scriptNm)
        objFileio.openFile(scriptNm, 2)
        objFileio.writeString(m.scriptText)
        objFileio.closeFile()
      else if (m.type = #text) then
        createFile(objFileio, fname & ".txt")
        objFileio.openFile(fname & ".txt", 2)
        objFileio.writeString(m.text)
        objFileio.closeFile()
      end if
    end repeat
  end repeat
  go the frame
  _movie.halt()
end

on getBoolConfig(str: string)
  type txt: string
  type return: number
  txt = member("editorConfig").text
  repeat with q = 1 to the number of lines in txt
    if (txt.line[q] = str & " : TRUE") then
      return true
    end if
  end repeat
  return false
end

on getBoolConfigOrDefault(str: string, def: number)
  type txt: string
  type return: number
  txt = member("editorConfig").text
  repeat with q = 1 to the number of lines in txt
    if (txt.line[q].char[1..(str.length)] = str) then
      return txt.line[q] = str & " : TRUE"
    end if
  end repeat
  return def
end

on getStringConfig(str: string)
  type txt: string
  type return: string
  txt = member("editorConfig").text
  repeat with q = 1 to the number of lines in txt
    if (txt.line[q] = str & " : DROUGHT") then
      return "DROUGHT"
    else if (txt.line[q] = str & " : DRY") then
      return "DRY"
    end if
  end repeat
  return "VANILLA"
end

on getStringConfigOrVoid(str: string)
  type txt: string
  type return: string
  txt = member("editorConfig").text
  repeat with q = 1 to the number of lines in txt
    if (txt.line[q].char[1..(str.length)] = str) then
      return str.char[(str.length+3)..txt.line[q].length]
    end if
  end repeat
  return VOID
end

on dontRunStuff()
  type return: number
  return (_movie.window.sizeState = #minimized)
end

on checkMinimize()
  type return: number
  if gCustomKeybinds then return checkCustomKeybind(#Minimize, [56, 48])
  
  if (_movie.window.sizeState <> #minimized) then
    if (_key.keyPressed(56)) then
      return (_key.keyPressed(48))
    end if
  end if
  return FALSE
end

on checkExitRender()
  type return: number
  if gCustomKeybinds then return checkCustomKeybind(#ExitRender, [48, "Z", "R"])
  
  if (_movie.window.sizeState <> #minimized) then
    if (_key.keyPressed(48)) then
      if (INT_EXRD = "DROUGHT") then
        if (_key.keyPressed("Z")) then
          return (_key.keyPressed("R"))
        end if
      else if (INT_EXRD = "DRY") then
        if (_key.keyPressed("X")) then
          return (_key.keyPressed("C"))
        end if
      else
        return TRUE
      end if
    end if
  end if
  return FALSE
end

on checkExit()
  type return: number
  if gCustomKeybinds then return checkCustomKeybind(#Close, [53, 56])
  
  if (_movie.window.sizeState <> #minimized) then
    if (INT_EXIT = "DROUGHT") then
      if (_key.keyPressed(56)) then
        return (_key.keyPressed(53))
      end if
    else if (INT_EXIT = "DRY") then
      if (_key.keyPressed(48)) then
        if (_key.keypressed(36)) then
          return (_key.keyPressed("X"))
        end if
      end if
    else
      return (_key.keyPressed(53))
    end if
  end if
  return FALSE
end

on checkDRInternal(nm: string)
  type return: number
  return DRInternalList.getPos(nm) > 0
end

on setFirstTileCat(num: number)
  type return: void
  DRFirstTileCat = num
end

on getFirstTileCat()
  type return: number
  return DRFirstTileCat
end

on setLastMatCat(num: number)
  type return: void
  DRLastMatCat = num
end

on getLastMatCat()
  type return: list
  return DRLastMatCat
end

on initDRInternal()
  type return: void
  DRInternalList = ["SGFL", "tileSetAsphaltFloor", "tileSetStandardFloor", "tileSetBigMetalFloor", "tileSetBricksFloor", "tileSetCliffFloor", "tileSetConcreteFloor",\
  "tileSetNon-Slip MetalFloor", "tileSetRainstoneFloor", "tileSetRough RockFloor", "tileSetScaffoldingDRFloor", "tileSetSteelFloor", "tileSetSuperStructure2Floor",\
  "tileSetSuperStructureFloor", "tileSetTiny SignsFloor", "tileSetElectricMetalFloor", "tileSetCageGrateFloor", "tileSetGrateFloor", "tileSetBulkMetalFloor",\
  "tileSetMassiveBulkMetalFloor", "4Mosaic Square", "4Mosaic Slope NE", "4Mosaic Slope SE", "4Mosaic Slope NW", "4Mosaic Slope SW", "4Mosaic Floor", "3DBrick Square",\
  "3DBrick Slope NE", "3DBrick Slope SE", "3DBrick Slope NW", "3DBrick Slope SW", "3DBrick Floor", "Small Stone Slope NE", "Small Stone Slope SE", "Small Stone Slope NW",\
  "Small Stone Slope SW", "Small Stone Floor", "Small Machine Slope NE", "Small Machine Slope SE", "Small Machine Slope NW", "Small Machine Slope SW", "Small Machine Floor",\
  "Missing Metal Slope NE", "Missing Metal Slope SE", "Missing Metal Slope NW", "Missing Metal Slope SW", "Missing Metal Floor", "Small Stone Marked", "Square Stone Marked",\
  "Small Metal Alt", "Small Metal Marked", "Small Metal X", "Metal Floor Alt", "Metal Wall", "Metal Wall Alt", "Square Metal Marked", "Square Metal X", "Wide Metal",\
  "Tall Metal", "Big Metal X", "Large Big Metal", "Large Big Metal Marked", "Large Big Metal X", "AltGrateA", "AltGrateB1", "AltGrateB2", "AltGrateB3", "AltGrateB4",\
  "AltGrateC1", "AltGrateC2", "AltGrateE1", "AltGrateE2", "AltGrateF1", "AltGrateF2", "AltGrateF3", "AltGrateF4", "AltGrateG1", "AltGrateG2", "AltGrateH", "AltGrateI",\
  "AltGrateF2", "AltGrateJ1", "AltGrateJ2", "AltGrateJ3", "AltGrateJ4", "AltGrateK1", "AltGrateK2", "AltGrateK3", "AltGrateK4", "AltGrateL", "AltGrateM", "AltGrateN",\
  "AltGrateO", "Big Big Pipe", "Ring Chain", "Stretched Pipe", "Stretched Wire", "Twisted Thread", "Christmas Wire", "Ornate Wire", "Dune Sand", "Big Chain", "Chunky Chain",\
  "Big Bike Chain", "Huge Bike Chain", "Long Barbed Wire", "Small Chain", "Fat Chain", "Moss Drop", "Moss Drop A", "Moss Drop B", "Moss Hang", "Moss Hang A", "Moss Hang B", \
  "Small Vents", "Reinforced Duct", "Mosaic Plant"]
  RandomMetals_grabTiles = ["Metal", "Metal construction", "Plate"]
  RandomMetals_allowed = ["Small Metal", "Metal Floor", "Square Metal", "Big Metal", "Big Metal Marked", "C Beam Horizontal AA", "C Beam Horizontal AB", "C Beam Vertical AA", "C Beam Vertical BA", "Plate 2"]
  ChaoticStone2_needed = ["Small Stone", "Square Stone", "Tall Stone", "Wide Stone", "Big Stone", "Big Stone Marked"]
  DRRandomMetal_needed = ["Small Metal", "Metal Floor", "Square Metal", "Big Metal", "Big Metal Marked", "Four Holes", "Cross Beam Intersection"]
  SmallMachines_grabTiles = ["Machinery", "Machinery2", "Small machine"]
  SmallMachines_forbidden = ["Feather Box - W", "Feather Box - E", "Piston Arm", "Vertical Conveyor Belt A", "Ventilation Box Empty", "Ventilation Box", "Big Fan",\
  "Giant Screw", "Compressor Segment", "Compressor R", "Compressor L", "Hub Machine", "Pole Holder", "Sky Box", "Conveyor Belt Wheel", "Piston Top", "Piston Segment Empty",\
  "Piston Head", "Piston Segment Filled", "Piston Bottom", "Piston Segment Horizontal A", "Piston Segment Horizontal B", "machine box C_E", "machine box C_W",\
  "machine box C_Sym", "Machine Box D", "machine box B", "Big Drill", "Elevator Track", "Conveyor Belt Covered", "Conveyor Belt L", "Conveyor Belt R",\
  "Conveyor Belt Segment", "Dyson Fan", "Metal Holes", "valve", "Tank Holder", "Drill Rim", "Door Holder R", "Door Holder L", "Drill B", "machine box A", "Machine Box E L",\
  "Machine Box E R", "Drill Shell A", "Drill Shell B", "Drill Shell Top", "Drill Shell Bottom", "Pipe Box R", "Pipe Box L"]
  RandomMachines_grabTiles = ["Machinery", "Machinery2", "Small machine", "LB Machinery", "Custom Random Machines"]
  RandomMachines_forbidden = ["Feather Box - W", "Feather Box - E", "Piston Arm", "Vertical Conveyor Belt A", "Piston Head No Cage", "Conveyor Belt Holder Only", "Conveyor Belt Wheel Only", "Drill Valve"]
  RandomMachines2_grabTiles = ["Machinery", "Machinery2", "Small machine"]
  RandomMachines2_forbidden = ["Feather Box - W", "Feather Box - E", "Piston Arm", "Vertical Conveyor Belt A", "Ventilation Box Empty", "Ventilation Box", "Big Fan",\
  "Giant Screw", "Compressor Segment", "Compressor R", "Compressor L", "Hub Machine", "Pole Holder", "Sky Box", "Conveyor Belt Wheel", "Piston Top", "Piston Segment Empty",\
  "Piston Head", "Piston Segment Filled", "Piston Bottom", "Piston Segment Horizontal A", "Piston Segment Horizontal B", "machine box C_E", "machine box C_W",\
  "machine box C_Sym", "Machine Box D", "machine box B", "Big Drill", "Elevator Track", "Conveyor Belt Covered", "Conveyor Belt L", "Conveyor Belt R", "Conveyor Belt Segment",\
  "Dyson Fan"]
  DRBevelColors = [[color(255, 0, 0), point(-1, -1)], [color(255, 0, 0), point(0, -1)], [color(255, 0, 0), point(-1, 0)], [color(0, 0, 255), point(1, 1)], [color(0, 0, 255), point(0, 1)], [color(0, 0, 255), point(1, 0)]]
end

on checkIsDrizzleRendering()
  -- For Drizzle to override to skip some initialization code that it shouldn't need to care about
  return TRUE
end

on cacheLoadImage(fileName)
  -- Drizzle has its own version of this that overrides it so we don't have to worry about that at least yay
  
  global gRenderFileCache
  if gRenderFileCache = void then
    gRenderFileCache = []
    gRenderFileCache.sort()
  end if
  
  memName = "cache" && fileName
  if gRenderFileCache.getPos(memName) = 0 then
    newMem = new(#bitmap, castLib "customMems")
    newMem.importFileInto(fileName)
    newMem.name = memName
    gRenderFileCache.add(memName)
    return newMem.image
  end if
  
  return member(memName).image
end

on clearRenderCache()
  global gRenderFileCache
  if gRenderFileCache <> void then
    repeat with memName in gRenderFileCache
      member(memName).erase()
    end repeat
  end if
  gRenderFileCache = []
  gRenderFileCache.sort()
end

--on freeImageNotFoundEx me
--  if (the moviePath & "FreeImage.dll" = void) then
--    member("logText").text = member("logText").text&RETURN&"File Not Found Exception : FreeImage.dll is missing. You must place it in the same folder as your editor executable."
--    fileOpener = new xtra("fileio")
--    fileOpener.openFile(the moviePath & "editorExceptionLog.txt", 0)
--    fileOpener.writeString(member("logText").text)
--    fileOpener.writeReturn(#windows)
--  end if
--end

on tryAddToPreview(ad: dynamic)
  type moreTilePreviews: number
  type prevw: image
  type drprevw: image
  type calculatedHeight: number
  type vertSZ: number
  type horiSZ: number
  type rct: rect

  if ad[#ptPos] <> 0 then return
  
  moreTilePreviews = getBoolConfig("More tile previews")
  prevw = member("previewTiles").image
  drprevw = member("previewTilesDR").image
  
  -- Import tile preview
  sav2 = member("previewImprt")
  member("previewImprt").importFileInto("Graphics/" & ad.nm & ".png")
  sav2.name = "previewImprt"
  --INTERNAL
  if (checkDRInternal(ad.nm)) then
    sav2.image = member(ad.nm).image
  end if
  calculatedHeight = sav2.image.rect.height
  vertSZ = 16 * ad.sz.locV
  horiSZ = 16 * ad.sz.locH
  if (ad.tp = "voxelStruct") then
    calculatedHeight = 1 + vertSZ + (20 * (ad.sz.locV + (ad.bfTiles * 2)) * ad.repeatL.count)
    if ad.tags.getPos("ramp") > 0 then
      calculatedHeight = 1 + vertSz + (20 * (ad.sz.locV * 2 + (ad.bfTiles * 2)) * ad.repeatL.count)
    end if
  end if
  rct = rect(0, calculatedHeight - vertSZ, horiSZ, calculatedHeight)
  if ((GL_ptPos + horiSZ + 1) > prevw.width) and (moreTilePreviews) then
    drprevw.copyPixels(sav2.image, rect(GL_drPos, 0, GL_drPos + horiSZ, vertSZ), rct)
    ad.ptPos = GL_drPos + 60000
    GL_drPos = GL_drPos + horiSZ + 1
  else
    prevw.copyPixels(sav2.image, rect(GL_ptPos, 0, GL_ptPos + horiSZ, vertSZ), rct)
    ad.ptPos = GL_ptPos
    GL_ptPos = GL_ptPos + horiSZ + 1  
  end if
end

on getKeybindStr(k, d)
  if k = VOID then
    return d
  end if
  
  v = GL_keyDict[k]
  if v = VOID then return d
  
  global GL_keyCodeList
  s = ""
  inv = False
  addPlus = False
  
  customStrCases = [["+", "plus"], ["-", "minus"], [",", "comma"], [".", "dot"], ["/", "slash"], ["\", "backslash"], [" ", "space"], ["`", "backtick"], ["~", "tilde"], \
["!", "exclamation mark"], ["@", "at"], ["#", "pound"], ["$", "dollar sign"], ["%", "percent"], ["^", "caret"], ["&", "ampersand"], ["*", "asterisk"], \
["(", "left parenthesis"], [")", "right parenthesis"], ["_", "underscore"], ["=", "equals"], ["|", "pipe"], ["'", "apostrophe"], [QUOTE, "quote"], [":", "colon"], \
[";", "semicolon"], ["?", "question mark"]]
  
  repeat with check in v then
    if inv then
      inv = False
      next repeat
    else if v = "NOT" then
      inv = True
      next repeat
    end if
    
    if addPlus then s = s & "+"
    addPlus = True
    
    if ilk(v, #string) then
      p = [v, v]
      repeat with pair in customStrCases then
        if pair[1] = v then
          p = pair
          exit repeat
        end if
      end repeat
      s = s & p[2]
    else
      str = "???"
      repeat with tuple in GL_keyCodeList then
        if tuple[2] = v then
          str = tuple[3]
          exit repeat
        end if
      end repeat
      s = s & str
    end if
  end repeat
  if s = "" then return d
  return s
end

on initCustomKeybindThings()
  global GL_keyCodeList, GL_allKeybinds
  gCustomKeybinds = 1
  
  GL_keyDict = [:]
  
  -- Exit button (close editor button)
  case getStringConfigOrVoid("Exit button") of
    "VANILLA":
      GL_keyDict[#close] = [53] -- Escape
    "DRY":
      GL_keyDict[#close] = [48, 36, "X"] -- Tab Shift X
    otherwise:
      -- DROUGHT or default
      GL_keyDict[#close] = ["Shift", 53] -- Shift Escape
  end case
  
  -- Minimize button
  GL_keyDict[#minimize] = ["Shift", 48] -- Shift Tab
  
  -- Exit render button
  case getStringConfigOrVoid("Exit render button") of
    "VANILLA":
      GL_keyDict[#exitrender] = [48] -- Tab
    "DRY":
      GL_keyDict[#exitrender] = [48, "X", "C"] -- Tab X C
    otherwise:
      -- DROUGHT or default
      GL_keyDict[#exitrender] = [48, "Z", "R"] -- Tab Z R
  end case
  
  GL_keyCodeList = [["ArrowLeft", 123, "Left"], ["ArrowRight", 124, "Right"], ["ArrowDown", 125, "Down"], ["ArrowUp", 126, "Up"], ["Numpad0", 82, "Numpad 0"],\
["Numpad1", 83, "Numpad 1"], ["Numpad2", 84, "Numpad 2"], ["Numpad3", 85, "Numpad 3"], ["Numpad4", 86, "Numpad 4"], ["Numpad5", 87, "Numpad 5"],\
["Numpad6", 88, "Numpad 6"], ["Numpad7", 89, "Numpad 7"], ["Numpad8", 91, "Numpad 8"], ["Numpad9", 92, "Numpad 9"], ["NumpadPlus", 78, "Numpad Plus"],\
["NumpadMinus", 70, "Numpad Minus"], ["NumpadTimes", 66, "Numpad Times"], ["NumpadDivide", 77, "Numpad Divide"], ["NumpadDot", 65, "Numpad Dot"],\
["NumpadEnter", 76, "Numpad Enter"], ["Enter", 36, "Enter"], ["ContextMenu", 127, "Context Menu"], ["Escape", 53, "Escape"], ["Tab", 48, "Tab"],\
["Space", " ", "Space"], ["Backspace", 51, "Backspace"], ["Insert", 114, "Insert"], ["Delete", 117, "Delete"], ["Home", 115, "Home"], ["End", 119, "End"],\
["PageUp", 116, "Page Up"], ["PageDown", 121, "Page Down"], ["Pause", 113, "Pause"], ["F1", 122, "F1"], ["F2", 120, "F2"], ["F3", 99, "F3"], ["F4", 118, "F4"],\
["F5", 96, "F5"], ["F6", 97, "F6"], ["F7", 98, "F7"], ["F8", 100, "F8"], ["F9", 101, "F9"], ["F10", 109, "F10"], ["F11", 103, "F11"], ["F12", 111, "F12"],\
["F13", 105, "F13"], ["F14", 107, "F14"], ["F15", 113, "F15"]]
end

on keyToKeyCode(nm)
  type return: dynamic

  global GL_keyCodeList
  repeat with tuple in GL_keyCodeList then
    if tuple[1] = nm then
      return tuple[2]
    end if
  end repeat
  
  if nm.length <> 1 and (nm <> "Control") and (nm <> "Shift") and (nm <> "Alt") and (nm <> "NOT") then
    writeException("Custom Keybinds", "Key code '" & nm & "' not recognized!")
    return nm
  end if
  
  return nm
end

on str2symbol(s: string)
  type i: number
  type return: symbol
  repeat while s contains " " then
    i = offset(" ", s)
    s = s.char[1..(i-1)] & s.char[(i+1)..(s.length)]
  end repeat
  return symbol(s)
end


on registerCustomKeybind(k, v)
  if (k = "") or (v = "") then
    return
  end if
  
  -- Ignore that this method is empty, it used to have more stuff
  
  -- Actually register (why symbols? they're *a lot* faster than strings lol)
  i = str2symbol(k)
  
  if (v = "NONE") then
    GL_keyDict[i] = [VOID]
    return
  end if
  
  a = []
  repeat while v contains " " then
    offst = offset(" ", v)
    if offst = 1 then
      v = v.char[2..(v.length)]
      --delete v[1]
    else if offset("--", v) = 1 then
      exit repeat
    else
      a.append(keyToKeyCode(v.char[1..(offst-1)]))
      v = v.char[(offst+1)..(v.length)]
      --delete v.char[1..offst]
    end if
  end repeat
  if (v <> "") and offset("--", v) <> 1 then a.append(keyToKeyCode(v)) -- the rest of everything else
  
  if a.count = 0 then
    GL_keyDict[i] = [VOID]
  else
    GL_keyDict[i] = a
  end if
end

on checkCustomKeybind(k, d)
  if dontRunStuff() then
    return False
  end if
  
  if gCustomKeybinds and k <> VOID then
    -- Try to retrieve the actual keybind
    v = GL_keyDict.getAProp(k)  --[k]
    if v <> VOID then
      control = 0
      shift = 0
      alt = 0
      inv = 0
      repeat with check in v then
        if check = VOID then
          return false
        else if check = "NOT" then
          inv = 1
          next repeat
        else if check = "Control" then
          control = 1
        else if check = "Shift" then
          shift = 1
        else if check = "Alt" then
          alt = 1
        else if inv=1 and _key.keyPressed(check) then
          return False
        else if inv=0 and not _key.keyPressed(check) then
          return False
        end if
        inv = 0
      end repeat
      
      if bitXor(_key.controlDown, control) then
        return false
      end if
      if bitXor(_key.shiftDown, shift) then
        return false
      end if
      if bitXor(_key.optionDown, alt) then
        return false
      end if
      return True
    end if
  end if
  
  -- Default case
  if ilk(d, #list) then
    inv = 0
    repeat with check in d then
      if check = VOID then
        return false
      else if check = "NOT" then
        inv = 1
        next repeat
      else if not _key.keyPressed(check) and inv=0 then
        return False
      else if _key.keyPressed(check) and inv=1 then
        return False
      end if
    end repeat
    return true
  else if d <> void then
    return _key.keyPressed(d)
  else
    return false
  end if
  return true
end


