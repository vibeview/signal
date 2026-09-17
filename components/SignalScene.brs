' The scene owns navigation between the three views and the saved list.

sub init()
    m.top.backgroundURI = ""
    m.top.backgroundColor = "0x101318FF"

    m.home = m.top.findNode("home")
    m.detail = m.top.findNode("detail")
    m.search = m.top.findNode("search")
    m.origin = "home"

    m.shows = loadShows()
    m.home.shows = m.shows
    m.search.shows = m.shows
    m.home.savedCount = savedIds().count()

    m.home.observeField("selectedShow", "onHomeSelected")
    m.home.observeField("searchRequested", "onSearchRequested")
    m.detail.observeField("closeRequested", "onDetailClosed")
    m.detail.observeField("saveToggled", "onSaveToggled")
    m.search.observeField("selectedShow", "onSearchSelected")
    m.search.observeField("closeRequested", "onSearchClosed")

    m.home.focusRequest = "first"
end sub

function loadShows() as object
    raw = ReadAsciiFile("pkg:/data/shows.json")
    shows = ParseJson(raw)
    if shows = invalid then return []
    return shows
end function

sub openDetail(show as object, origin as string)
    m.origin = origin
    m.home.visible = false
    m.search.visible = false
    m.detail.show = show
    m.detail.saved = isSaved(show.id)
    m.detail.visible = true
    m.detail.focusRequest = "play"
end sub

sub onHomeSelected()
    openDetail(m.home.selectedShow, "home")
end sub

sub onSearchSelected()
    openDetail(m.search.selectedShow, "search")
end sub

sub onDetailClosed()
    m.detail.visible = false
    if m.origin = "search" then
        m.search.visible = true
        m.search.focusRequest = "current"
    else
        m.home.savedCount = savedIds().count()
        m.home.visible = true
        m.home.focusRequest = "current"
    end if
end sub

sub onSaveToggled()
    m.detail.saved = toggleSaved(m.detail.show.id)
end sub

sub onSearchRequested()
    m.home.visible = false
    m.search.visible = true
    m.search.focusRequest = "keyboard"
end sub

sub onSearchClosed()
    m.search.visible = false
    m.home.savedCount = savedIds().count()
    m.home.visible = true
    m.home.focusRequest = "search"
end sub
