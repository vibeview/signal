' Home: a Search button, two rows of tiles, and the saved count.
' Focus is SceneGraph focus on the tile/button nodes; this view only decides
' which node receives it for each remote press.

sub init()
    m.tileWidth = 272
    m.tileHeight = 153
    m.tileGap = 24
    m.rowNodes = [m.top.findNode("row.new"), m.top.findNode("row.talk")]
    m.tiles = [[], []]
    m.col = [0, 0]      ' remembered column per row
    m.row = 0
    m.zone = "rows"     ' "rows" or "search"
    m.searchButton = m.top.findNode("home.search")
    m.savedLabel = m.top.findNode("home.saved.count")
end sub

sub onShows()
    for r = 0 to 1
        node = m.rowNodes[r]
        node.removeChildrenIndex(node.getChildCount(), 0)
        m.tiles[r] = []
    end for
    for each show in m.top.shows
        r = 1
        if show.row = "new" then r = 0
        tile = m.rowNodes[r].createChild("ShowTile")
        tile.tileWidth = m.tileWidth
        tile.tileHeight = m.tileHeight
        tile.translation = [m.tiles[r].count() * (m.tileWidth + m.tileGap), 0]
        tile.show = show
        m.tiles[r].push(tile)
    end for
end sub

sub onSavedCount()
    n = m.top.savedCount
    if n = 1 then
        m.savedLabel.text = "Saved: 1 show"
    else
        m.savedLabel.text = "Saved: " + n.toStr() + " shows"
    end if
end sub

sub onFocusRequest()
    request = m.top.focusRequest
    if request = "search" then
        focusSearch()
    else if request = "first" then
        focusTile(0, 0)
    else if m.zone = "search" then
        focusSearch()
    else
        focusTile(m.row, m.col[m.row])
    end if
end sub

sub focusSearch()
    m.zone = "search"
    m.searchButton.setFocus(true)
end sub

sub focusTile(r as integer, c as integer)
    if m.tiles[r].count() = 0 then return
    if c < 0 then c = 0
    if c > m.tiles[r].count() - 1 then c = m.tiles[r].count() - 1
    m.zone = "rows"
    m.row = r
    m.col[r] = c
    m.tiles[r][c].setFocus(true)
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    if not press then return false
    if m.zone = "search" then
        if key = "down" then
            focusTile(0, m.col[0])
            return true
        else if key = "OK" then
            m.top.searchRequested = true
            return true
        end if
        return false
    end if

    if key = "left" then
        focusTile(m.row, m.col[m.row] - 1)
        return true
    else if key = "right" then
        focusTile(m.row, m.col[m.row] + 1)
        return true
    else if key = "down" then
        if m.row < 1 then focusTile(m.row + 1, m.col[m.row + 1])
        return true
    else if key = "up" then
        if m.row > 0 then
            focusTile(m.row - 1, m.col[m.row - 1])
        else
            focusSearch()
        end if
        return true
    else if key = "OK" then
        m.top.selectedShow = m.tiles[m.row][m.col[m.row]].show
        return true
    end if
    return false
end function
