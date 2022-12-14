-- AnimationSetterUpper v1.0 (13 Aug 2022)
-- by kloi34

---------------------------------------------------------------------------------------------------
-- Plugin Info ------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

-- Setup note keyframes

---------------------------------------------------------------------------------------------------
-- Global Constants -------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

SAMELINE_SPACING = 5               -- value determining spacing between GUI items on the same row
DEFAULT_WIDGET_HEIGHT = 26         -- value determining the height of GUI widgets
DEFAULT_WIDGET_WIDTH = 120         -- value determining the width of GUI widgets
PADDING_WIDTH = 8                  -- value determining window and frame padding
PLUGIN_WINDOW_SIZE = {500, 600}    -- dimensions of the plugin window
LANE_BUTTON_SIZE = {30, 30}        -- dimensions of the lane button

---------------------------------------------------------------------------------------------------
-- Plugin -----------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

-- Creates the plugin window
function draw()
    setPluginAppearance()
    imgui.SetNextWindowSize(PLUGIN_WINDOW_SIZE)
    imgui.Begin("AnimationSetterUpper", imgui_window_flags.AlwaysAutoResize)
    state.IsWindowHovered = imgui.IsWindowHovered()
    createMenu()
    imgui.End()
end
-- Configures GUI styles (colors and appearance)
function setPluginAppearance()
    -- Plugin Styles
    local rounding = 5 -- determines how rounded corners are
    imgui.PushStyleVar( imgui_style_var.WindowPadding,      { PADDING_WIDTH, 8 } )
    imgui.PushStyleVar( imgui_style_var.FramePadding,       { PADDING_WIDTH, 5 } )
    imgui.PushStyleVar( imgui_style_var.ItemSpacing,        { DEFAULT_WIDGET_HEIGHT / 2 - 1, 4 } )
    imgui.PushStyleVar( imgui_style_var.ItemInnerSpacing,   { SAMELINE_SPACING, 6 } )
    imgui.PushStyleVar( imgui_style_var.WindowBorderSize,   0        )
    imgui.PushStyleVar( imgui_style_var.WindowRounding,     rounding )
    imgui.PushStyleVar( imgui_style_var.ChildRounding,      rounding )
    imgui.PushStyleVar( imgui_style_var.FrameRounding,      rounding )
    imgui.PushStyleVar( imgui_style_var.GrabRounding,       rounding )
    
    -- Plugin Colors
    imgui.PushStyleColor( imgui_col.WindowBg,               { 0.00, 0.00, 0.00, 1.00 } )
    imgui.PushStyleColor( imgui_col.FrameBg,                { 0.28, 0.14, 0.24, 1.00 } )
    imgui.PushStyleColor( imgui_col.FrameBgHovered,         { 0.38, 0.24, 0.34, 1.00 } )
    imgui.PushStyleColor( imgui_col.FrameBgActive,          { 0.43, 0.29, 0.39, 1.00 } )
    imgui.PushStyleColor( imgui_col.TitleBg,                { 0.65, 0.41, 0.48, 1.00 } )
    imgui.PushStyleColor( imgui_col.TitleBgActive,          { 0.75, 0.51, 0.58, 1.00 } )
    imgui.PushStyleColor( imgui_col.TitleBgCollapsed,       { 0.75, 0.51, 0.58, 0.50 } )
    imgui.PushStyleColor( imgui_col.CheckMark,              { 1.00, 0.81, 0.88, 1.00 } )
    imgui.PushStyleColor( imgui_col.SliderGrab,             { 0.75, 0.56, 0.63, 1.00 } )
    imgui.PushStyleColor( imgui_col.SliderGrabActive,       { 0.80, 0.61, 0.68, 1.00 } )
    imgui.PushStyleColor( imgui_col.Button,                 { 0.50, 0.31, 0.38, 1.00 } )
    imgui.PushStyleColor( imgui_col.ButtonHovered,          { 0.60, 0.41, 0.48, 1.00 } )
    imgui.PushStyleColor( imgui_col.ButtonActive,           { 0.70, 0.51, 0.58, 1.00 } )
    imgui.PushStyleColor( imgui_col.Header,                 { 1.00, 0.81, 0.88, 0.40 } )
    imgui.PushStyleColor( imgui_col.HeaderHovered,          { 1.00, 0.81, 0.88, 0.50 } )
    imgui.PushStyleColor( imgui_col.HeaderActive,           { 1.00, 0.81, 0.88, 0.54 } )
    imgui.PushStyleColor( imgui_col.Separator,              { 1.00, 0.81, 0.88, 0.30 } )
    imgui.PushStyleColor( imgui_col.TextSelectedBg,         { 1.00, 0.81, 0.88, 0.40 } )
end
-- Creates the main menu
function createMenu()
    local vars = {
        numKeyframes = 2,
        keyframeNotes = {},
        laneCounts = zeros(map.GetKeyCount()),
        selectedKeyframeNote = 1,
        currentKeyframe = 1,
        keyframeDistance = 10000,
        noteInfoTextDump = "",
        dumpInfo = false,
        noteInfoImport = "",
        debugText = "I'm debuggy"
    }
    imgui.PushItemWidth(150)
    retrieveStateVariables(vars)
    chooseNumKeyframes(vars)
    chooseKeyframeDistance(vars)
    addSeparator()
    addKeyframeNotes(vars)
    imgui.SameLine()
    resetNotesButton(vars, false)
    displayLaneNoteCounts(vars)
    imgui.Columns(2, "notes", false)
    displayKeyframeNotes(vars)
    imgui.NextColumn()
    imgui.PushItemWidth(150)
    displayNoteInfo(vars)
    imgui.NextColumn()
    navigateKeyframes(vars)
    drawKeyframe(vars)
    addSeparator()
    buttonThatDoesThing(vars)
    imgui.TextWrapped(vars.debugText)
    noteInfoDump(vars)
    saveStateVariables(vars)
end

---------------------------------------------------------------------------------------------------
-- Calculation/helper functions
---------------------------------------------------------------------------------------------------

-- Retrieves variables from the state
-- Parameters
--    variables : list of variables and values (Table)
function retrieveStateVariables(variables)
    for key, value in pairs(variables) do
        variables[key] = state.GetValue(key) or value
    end
end
-- Saves variables to the state
-- Parameters
--    variables : list of variables and values (Table)
function saveStateVariables(variables)
    for key, value in pairs(variables) do
        state.SetValue(key, value)
    end
end
-- Adds vertical blank space/padding on the GUI
function addPadding()
    imgui.Dummy({0, 0})
end
-- Draws a horizontal line separator on the GUI
function addSeparator()
    addPadding()
    imgui.Separator()
    addPadding()
end
-- Finds unique offsets of all notes currently selected in the Quaver map editor
-- Returns a list of unique offsets (in increasing order) of selected notes [Table]
function uniqueSelectedNoteOffsets()
    local offsets = {}
    for i, hitObject in pairs(state.SelectedHitObjects) do
        offsets[i] = hitObject.StartTime
    end
    offsets = removeDuplicateValues(offsets)
    offsets = table.sort(offsets, function(a, b) return a < b end)
    return offsets
end
-- Combs through a list and locates unique values
-- Returns a list of only unique values (no duplicates) [Table]
-- Parameters
--    list : list of values [Table]
function removeDuplicateValues(list)
    local hash = {}
    local newList = {}
    for _, value in ipairs(list) do
        -- if the value is not already in the new list
        if (not hash[value]) then
            -- add the value to the new list
            newList[#newList + 1] = value
            hash[value] = true
        end
    end
    return newList
end

-- Creates a tooltip box when an IMGUI item is hovered over
-- Parameters
--    text : text to appear in the tooltip box [String]
function createToolTip(text)
    if imgui.IsItemHovered() then
        imgui.BeginTooltip()
        imgui.PushTextWrapPos(imgui.GetFontSize() * 20)
        imgui.Text(text)
        imgui.PopTextWrapPos()
        imgui.EndTooltip()
    end
end
-- Creates an inline, grayed-out '(?)' symbol that shows a tooltip box when hovered over
-- Parameters
--    text : text to appear in the tooltip box [String]
function createHelpMarker(text)
    imgui.SameLine()
    imgui.TextDisabled("(?)")
    createToolTip(text)
end

function zeros(n)
    local list = {}
    for i = 1, n do
        table.insert(list, 0)
    end
    return list
end

function chooseNumKeyframes(vars)
    _, vars.numKeyframes = imgui.InputInt("Total # of keyframes", vars.numKeyframes)
    vars.numKeyframes = clampToInterval(vars.numKeyframes, 1, 999)
end

function resetNotesButton(vars, resetAnyways)
    if not (imgui.Button("Clear/reset keyframe notes") or resetAnyways) then return end
    vars.keyframeNotes = {}
    vars.laneCounts = zeros(map.GetKeyCount())
    vars.selectedKeyframeNote = 1
end

function displayLaneNoteCounts(vars)
    imgui.Text("Total # of keyframe notes in pool: "..#vars.keyframeNotes)
    local laneCountText = "Lane counts: {"
    for i = 1, #vars.laneCounts do
        laneCountText = laneCountText.." "..vars.laneCounts[i].." "
    end
    laneCountText = laneCountText.."}"
    imgui.Text(laneCountText)
    addSeparator()
end

function displayKeyframeNotes(vars)
    imgui.Text("time | lane | keyframe | position")
    imgui.BeginChild("Notes", {180,200}, true)
    for i = 1, #vars.keyframeNotes do
        local note = vars.keyframeNotes[i]
        local text = note.time.." | "..note.lane.." | "..note.keyframe.." | "..note.position
        if imgui.Selectable(text, vars.selectedKeyframeNote == i) then
            vars.selectedKeyframeNote = i
        end
    end
    imgui.EndChild()
end

function addKeyframeNotes(vars)
    if not imgui.Button("Add selected notes to pool") then return end
    --[[
    for i, hitObject in pairs(state.SelectedHitObjects) do
       table.insert(vars.keyframeNotes, createKeyframeNote(hitObject.StartTime, hitObject.Lane, 1, 0))
    end
    vars.laneCounts = zeros(map.GetKeyCount())
    local hash = {}
    local noDuplicates = {}
    for i = 1, map.GetKeyCount() do
        table.insert(hash, {})
    end
    for i = 1, #vars.keyframeNotes do
        local note = vars.keyframeNotes[i]
        local lane = note.lane
        local time = note.time
        if (not hash[lane][time]) then
            hash[lane][time] = true
            vars.laneCounts[lane] = vars.laneCounts[lane] + 1
            table.insert(noDuplicates, note)
        end
    end
    vars.keyframeNotes = sortByTime(noDuplicates)
    --]]
    vars.laneCounts = zeros(map.GetKeyCount())
    local hash = {}
    for i = 1, map.GetKeyCount() do
        table.insert(hash, {})
    end
    for i = 1, #vars.keyframeNotes do
        local note = vars.keyframeNotes[i]
        local lane = note.lane
        local time = note.time
        hash[lane][time] = true
        vars.laneCounts[lane] = vars.laneCounts[lane] + 1
    end
    for i, hitObject in pairs(state.SelectedHitObjects) do
        local lane = hitObject.Lane
        local time = hitObject.StartTime
        if (not hash[lane][time]) then
            hash[lane][time] = true
            vars.laneCounts[lane] = vars.laneCounts[lane] + 1
            table.insert(vars.keyframeNotes, createKeyframeNote(time, lane, 1, 0))
        end
    end
    vars.keyframeNotes = sortByTime(vars.keyframeNotes)
end

function sortByTime(notes)
    return table.sort(notes, function(a, b) return a.time < b.time end)
end

function displayNoteInfo(vars)
    if #vars.keyframeNotes == 0 then return end
    local note = vars.keyframeNotes[vars.selectedKeyframeNote]
    _, note.keyframe = imgui.InputInt("Note keyframe", note.keyframe)
    note.keyframe = clampToInterval(note.keyframe, 1, vars.numKeyframes)
    _, note.position = imgui.InputInt("Note position", note.position)
end

function clampToInterval(x, lowerBound, upperBound)
    if x < lowerBound then return lowerBound end
    if x > upperBound then return upperBound end
    return x
end

function navigateKeyframes(vars)
    if imgui.ArrowButton("##left", imgui_dir.Left) then vars.currentKeyframe = vars.currentKeyframe - 1 end
    imgui.SameLine(35)
    if imgui.ArrowButton("##right", imgui_dir.Right) then vars.currentKeyframe = vars.currentKeyframe + 1 end
    vars.currentKeyframe = clampToInterval(vars.currentKeyframe, 1, vars.numKeyframes)
    imgui.SameLine()
    imgui.Text("Current frame: "..vars.currentKeyframe)
end

function chooseKeyframeDistance(vars)
    _, vars.keyframeDistance = imgui.InputInt("Distance between keyframes (msx)", vars.keyframeDistance)
    vars.keyframeDistance = clampToInterval(vars.keyframeDistance, 0, 999999)
end

function buttonThatDoesThing(vars)
    if #vars.keyframeNotes == 0 then return end
    if not imgui.Button("Do the thing", {200, 50}) then return end
    local lastKeyframe = vars.keyframeNotes[1].keyframe
    local lastPosition = vars.keyframeNotes[1].position
    local svs = {}
    for i = 2, #vars.keyframeNotes do
        local nextKeyframe = vars.keyframeNotes[i].keyframe
        local nextPosition = vars.keyframeNotes[i].position
        local keyframeDifference = nextKeyframe - lastKeyframe
        local positionDifference = nextPosition - lastPosition
        local totalDifference = keyframeDifference * vars.keyframeDistance + positionDifference
        local sv = 64 * totalDifference
        local lastTime = vars.keyframeNotes[i - 1].time
        local nextTime =  vars.keyframeNotes[i].time
        if lastTime ~= nextTime then
            addSVToList(svs, lastTime, sv)
            addSVToList(svs, (lastTime + 1/64), 0)
        end
        lastKeyframe = nextKeyframe
        lastPosition = nextPosition
    end
    vars.debugText = "Hi debuggy "
    actions.PlaceScrollVelocityBatch(svs)
end

function addSVToList(list, time, svValue)
    table.insert(list, utils.CreateScrollVelocity(time, svValue))
end

function noteInfoDump(vars)
    if #vars.keyframeNotes == 0 then return end
    _, vars.dumpInfo = imgui.Checkbox("show stuff", vars.dumpInfo)
    if not vars.dumpInfo then return end
    vars.noteInfoTextDump = ""
    for i = 1, #vars.keyframeNotes do
        local note = vars.keyframeNotes[i]
        vars.noteInfoTextDump = vars.noteInfoTextDump.."{ "..note.time.." | "..note.lane.." | "..note.keyframe.." | "..note.position.." }\n"
    end
    imgui.InputTextMultiline("infoDump", vars.noteInfoTextDump, 999999, {100, 100}, imgui_input_text_flags.ReadOnly)
    _, vars.noteInfoImport = imgui.InputTextMultiline("infoImport", vars.noteInfoImport, 999999, {100, 100})
    imgui.SameLine()
    if not imgui.Button("Parse", {100, 50}) then return end
    resetNotesButton(vars, true)
    local maxKeyframe = 1
    for noteInfo in string.gmatch(vars.noteInfoImport, "{.-}.-") do
        local regex = "%d+"
        local captures = {}
        for capture, _ in string.gmatch(noteInfo, regex) do
            table.insert(captures, tonumber(capture))
            --vars.debugText = vars.debugText.." "..tonumber(capture)
        end
        table.insert(vars.keyframeNotes, createKeyframeNote(captures[1], captures[2], captures[3], captures[4]))
        maxKeyframe = math.max(maxKeyframe, captures[3])
    end
    vars.numKeyframes = math.max(vars.numKeyframes, maxKeyframe)
end

function createKeyframeNote(time2, lane2, keyframe2, position2)
    local keyframeNote = {
        time = time2,
        lane = lane2,
        keyframe = keyframe2,
        position = position2
    }
    return keyframeNote
end

function rgbaToUint(r, g, b, a) return a*16^6 + b*16^4 + g*16^2 + r end
function coordsRelativeToWindow(x, y) return {x + imgui.GetWindowPos()[1], y + imgui.GetWindowPos()[2]} end
function drawKeyframe(vars)
    imgui.NextColumn()
    local drawlist = imgui.GetWindowDrawList()
    --local p1 = coordsRelativeToWindow(270, 410)
    --local p2 = coordsRelativeToWindow(470, 410)
    local whiteColor = rgbaToUint(255, 255, 255, 255)
    local blueColor = rgbaToUint(53, 200, 255, 255)
    local noteWidth = 180/map.GetKeyCount() 
    local noteHeight = 20
    for i = 1, #vars.keyframeNotes do
        local note = vars.keyframeNotes[i]
        if note.keyframe == vars.currentKeyframe then
            local x1 = 270 + (noteWidth + 5) * (note.lane - 1)
            local y1 = 410 - (note.position / 2)
            local x2 = x1 + noteWidth
            local y2 = y1 - noteHeight
            local p1 = coordsRelativeToWindow(x1, y1)
            local p2 = coordsRelativeToWindow(x2, y2)
            local color = (note.lane == 2 or note.lane == 3) and blueColor or whiteColor
            drawlist.AddRectFilled(p1, p2, color)
        end
    end
    imgui.NextColumn()
end