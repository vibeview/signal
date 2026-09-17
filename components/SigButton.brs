sub init()
    m.bg = m.top.findNode("bg")
    m.label = m.top.findNode("label")
    m.top.focusable = true
    m.top.observeField("focusedChild", "render")
    layout()
end sub

sub layout()
    m.bg.width = m.top.buttonWidth
    m.bg.height = m.top.buttonHeight
    m.label.width = m.top.buttonWidth
    m.label.height = m.top.buttonHeight
end sub

sub render()
    m.label.text = m.top.text
    if m.top.hasFocus() then
        m.bg.color = "0xF2A33AFF"
        m.label.color = "0x101318FF"
    else if m.top.saved then
        m.bg.color = "0x3AA981FF"
        m.label.color = "0xF1EFE8FF"
    else
        m.bg.color = "0x1C2028FF"
        m.label.color = "0xF1EFE8FF"
    end if
end sub
