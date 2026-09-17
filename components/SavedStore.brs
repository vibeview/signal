' Saved shows live in the Roku registry so they survive navigation.
' Registry section "signal", key "saved": comma-separated show ids.

function savedIds() as object
    ids = []
    section = CreateObject("roRegistrySection", "signal")
    if section.Exists("saved") then
        raw = section.Read("saved")
        if raw <> "" then
            for each id in raw.Split(",")
                ids.push(id)
            end for
        end if
    end if
    return ids
end function

sub writeSavedIds(ids as object)
    section = CreateObject("roRegistrySection", "signal")
    section.Write("saved", ids.Join(","))
    section.Flush()
end sub

function isSaved(id as string) as boolean
    for each saved in savedIds()
        if saved = id then return true
    end for
    return false
end function

' Adds the id when absent, removes it when present. Returns the new state.
function toggleSaved(id as string) as boolean
    kept = []
    found = false
    for each saved in savedIds()
        if saved = id then
            found = true
        else
            kept.push(saved)
        end if
    end for
    if not found then kept.push(id)
    writeSavedIds(kept)
    return not found
end function
