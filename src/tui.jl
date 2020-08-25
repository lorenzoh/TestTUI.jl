STYLES = Dict(
    Initial => () -> TUI.Crayon(),
    Queued => () -> TUI.Crayon(),
    Running => () -> TUI.Crayon(foreground = :yellow),
    Passed => () -> TUI.Crayon(foreground = :green),
    Errored => () -> TUI.Crayon(foreground = :red),
    Failed => () -> TUI.Crayon(foreground = :red,),
)


function tuiloop(results; timeout = 3600, tsleep = 1/120)
    TUI.initialize()
    TUI.hide_cursor()
    terminal = TUI.Terminal()
    t = time()
    state = frame(terminal, results)
    while (time() - t) < timeout
        try
            state = frame(terminal, results, state)
        catch e
            if e isa InterruptException
                break
            else
                rethrow()
            end
        end
        sleep(tsleep)
    end
    TUI.cleanup()
    TUI.reset()
    TUI.disable_raw_mode()
end


function frame(terminal, results, state = (scroll = 1, selection = 1))
    scroll, selection = state
    w, h = TUI.terminal_size()

    # select list
    words = [TUI.Word(r.name, STYLES[r.state]()) for r in results]
    b1 = TUI.Block(title = "Packages")
    l_elem = TUI.SelectableList(
        b1,
        words,
        state.scroll,
        state.selection,
    )

    # test result box
    result = results[selection]
    #text = word.(split(results[selection].output))

    b2 = TUI.Block(title = "Test results")
    text_elem = Text(b2, resulttext(results[selection]))

    # layout and draw

    l_width = maximum(length.([r.name for r in results])) + 5
    l_rect = TUI.Rect(1, 1, l_width, h)
    TUI.draw(terminal, l_elem, l_rect)

    r2 = TUI.Rect(l_width + 3, 1, w - (l_width + 3), h - 1)
    TUI.draw(terminal, text_elem, r2)

    TUI.flush(terminal)

    # handle keyboard events
    c = TUI.get_event(terminal)
    if (c == 'q')
        throw(InterruptException())
    elseif (c == 'j')
        if selection < length(words)
            selection += 1
        end
    elseif (c == 'k')
        if selection > 1
            selection -= 1
        end
    end

    return (; scroll, selection)
end


function resulttext(result::TestResult)
    s = result.state
    if s === Running
        "Currently running..."
    elseif s === Queued
        "Queued and waiting to test"
    elseif s === Passed
        "TESTS PASSED\n\n" * result.output
    elseif s === Failed
        "TESTS FAILED\n\n" * result.output
    elseif s === Errored
        "TESTS ERRORED\n\n" * result.output
    elseif s === Initial
        "..."
    end
end
