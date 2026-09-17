' Search: a MiniKeyboard, its text box, and a grid of matching tiles.

sub init()
    m.columns = 6
    m.tileWidth = 272
    m.tileHeight = 153
    m.gapX = 24
    m.gapY = 20
    m.keyboard = m.top.findNode("search.keyboard")
    m.keyboard.textEditBox.id = "search.input"
    m.keyboard.textEditBox.hintText = "Show title"
    m.keyboard.observeField("text", "filter")
    m.results = m.top.findNode("search.results")
    m.empty = m.top.findNode("search.empty")
    m.top.findNode("search.title").font.size = 64
    m.top.findNode("search.results.label").font.size = 30
    m.empty.font.size = 30
    m.tiles = []
    m.index = 0
    m.zone = "keyboard"
end sub

sub filter()
    query = LCase(m.keyboard.text)
    m.results.removeChildrenIndex(m.results.getChildCount(), 0)
    m.tiles = []
    for each show in m.top.shows
        if query = "" or LCase(show.title).Instr(query) >= 0 then
            i = m.tiles.count()
            tile = m.results.createChild("ShowTile")
            tile.tileWidth = m.tileWidth
            tile.tileHeight = m.tileHeight
            col = i mod m.columns
            line = i \ m.columns
            tile.translation = [col * (m.tileWidth + m.gapX), line * (m.tileHeight + m.gapY)]
            tile.show = show
            m.tiles.push(tile)
        end if
    end for
    m.empty.visible = (m.tiles.count() = 0)
    if m.index > m.tiles.count() - 1 then m.index = 0
    if m.zone = "results" then
        if m.tiles.count() = 0 then
            focusKeyboard()
        else
            focusResult(m.index)
        end if
    end if
end sub

sub onFocusRequest()
    if m.top.focusRequest = "keyboard" then
        focusKeyboard()
    else if m.zone = "results" and m.tiles.count() > 0 then
        focusResult(m.index)
    else
        focusKeyboard()
    end if
end sub

sub focusKeyboard()
    m.zone = "keyboard"
    m.keyboard.setFocus(true)
end sub

sub focusResult(i as integer)
    if m.tiles.count() = 0 then return
    if i < 0 then i = 0
    if i > m.tiles.count() - 1 then i = m.tiles.count() - 1
    m.zone = "results"
    m.index = i
    m.tiles[i].setFocus(true)
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    if not press then return false
    if key = "back" then
        m.top.closeRequested = true
        return true
    end if
    if m.zone = "keyboard" then
        if key = "down" and m.tiles.count() > 0 then
            focusResult(m.index)
            return true
        end if
        return false
    end if
    if key = "left" then
        focusResult(m.index - 1)
        return true
    else if key = "right" then
        focusResult(m.index + 1)
        return true
    else if key = "down" then
        if m.index + m.columns <= m.tiles.count() - 1 then focusResult(m.index + m.columns)
        return true
    else if key = "up" then
        if m.index - m.columns >= 0 then
            focusResult(m.index - m.columns)
        else
            focusKeyboard()
        end if
        return true
    else if key = "OK" then
        m.top.selectedShow = m.tiles[m.index].show
        return true
    end if
    return false
end function
