' Detail: art, title, category and episode count, description, Play and Save.

sub init()
    m.art = m.top.findNode("detail.art")
    m.title = m.top.findNode("detail.title")
    m.meta = m.top.findNode("detail.meta")
    m.description = m.top.findNode("detail.description")
    m.play = m.top.findNode("detail.play")
    m.save = m.top.findNode("detail.save")
    m.timer = m.top.findNode("nowPlayingTimer")
    m.timer.observeField("fire", "hideNowPlaying")
    m.nowPlaying = invalid
end sub

sub onShow()
    show = m.top.show
    if show = invalid then return
    m.art.uri = "pkg:/images/shows/" + show.id + ".png"
    m.title.text = show.title
    m.meta.text = show.category + " · " + show.episodes.toStr() + " episodes"
    m.description.text = show.description
    hideNowPlaying()
end sub

sub onSaved()
    m.save.saved = m.top.saved
    if m.top.saved then
        m.save.text = "Saved"
    else
        m.save.text = "Save"
    end if
end sub

sub onFocusRequest()
    m.play.setFocus(true)
end sub

sub showNowPlaying()
    hideNowPlaying()
    label = CreateObject("roSGNode", "Label")
    label.id = "detail.nowplaying"
    label.text = "Now playing: " + m.top.show.title
    label.color = "0xF2A33AFF"
    label.translation = [880, 740]
    font = CreateObject("roSGNode", "Font")
    font.uri = "font:MediumBoldSystemFont"
    font.size = 30
    label.font = font
    m.top.appendChild(label)
    m.nowPlaying = label
    m.timer.control = "start"
end sub

sub hideNowPlaying()
    m.timer.control = "stop"
    if m.nowPlaying <> invalid then
        m.top.removeChild(m.nowPlaying)
        m.nowPlaying = invalid
    end if
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    if not press then return false
    if key = "back" then
        hideNowPlaying()
        m.top.closeRequested = true
        return true
    else if key = "right" then
        m.save.setFocus(true)
        return true
    else if key = "left" then
        m.play.setFocus(true)
        return true
    else if key = "OK" then
        if m.play.hasFocus() then
            showNowPlaying()
        else if m.save.hasFocus() then
            m.top.saveToggled = true
        end if
        return true
    end if
    return false
end function
