sub init()
    m.ring = m.top.findNode("ring")
    m.art = m.top.findNode("art")
    m.top.focusable = true
    m.top.observeField("focusedChild", "onFocusChanged")
    layout()
end sub

sub layout()
    w = m.top.tileWidth
    h = m.top.tileHeight
    m.art.width = w
    m.art.height = h
    m.ring.width = w + 8
    m.ring.height = h + 8
    m.ring.translation = [-4, -4]
    m.top.scaleRotateCenter = [w / 2, h / 2]
end sub

sub onShow()
    show = m.top.show
    if show = invalid then return
    m.top.id = "tile." + show.id
    m.art.uri = "pkg:/images/shows/" + show.id + ".png"
end sub

sub onFocusChanged()
    focused = m.top.hasFocus()
    m.ring.visible = focused
    if focused then
        m.top.scale = [1.08, 1.08]
    else
        m.top.scale = [1.0, 1.0]
    end if
end sub
