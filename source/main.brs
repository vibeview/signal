' Signal - a small podcast guide for Roku.
' Entry point: shows the SignalScene and waits until the channel is closed.

sub Main()
    screen = CreateObject("roSGScreen")
    port = CreateObject("roMessagePort")
    screen.setMessagePort(port)
    screen.CreateScene("SignalScene")
    screen.show()

    while true
        msg = wait(0, port)
        if type(msg) = "roSGScreenEvent" then
            if msg.isScreenClosed() then return
        end if
    end while
end sub
