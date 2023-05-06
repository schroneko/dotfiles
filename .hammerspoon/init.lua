local simpleCmd = false
local map = hs.keycodes.map

local function kanaSwitchEvent(event)
    local c = event:getKeyCode()
    local f = event:getFlags()
    if event:getType() == hs.eventtap.event.types.keyDown then
        if f['cmd'] then
            simpleCmd = true
        end
    elseif event:getType() == hs.eventtap.event.types.flagsChanged then
        if not f['cmd'] then
            if simpleCmd == false then
                if c == map['cmd'] then
                    hs.keycodes.setMethod('Romaji')
                elseif c == map['rightcmd'] then
                    hs.keycodes.setMethod('Hiragana')
                end
            end
            simpleCmd = false
        end
    end
end

kanaSwitcher = hs.eventtap.new(
  {hs.eventtap.event.types.keyDown, hs.eventtap.event.types.flagsChanged},
  kanaSwitchEvent
)
kanaSwitcher:start()
