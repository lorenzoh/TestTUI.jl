using TerminalUserInterfaces: Block, Buffer, Rect, draw, inner, set, height

Base.@kwdef struct Text
    block::Block
    text::String
end


function TerminalUserInterfaces.draw(t::Text, rectouter::Rect, buf::Buffer)
    draw(t.block, rectouter, buf)
    rect = inner(t.block, rectouter)
    height(rect) < 1 && return

    col, row = rect.x, rect.y

    for char in t.text
        if char == '\n'
            row += 1
            col = rect.x
            continue
        end
        if col >= 200#(rect.x + rect.width - 1)
            row += 1
            col = rect.x
        end
        if row > (rect.y + rect.height)
            break
        end
        set(buf, col, row, char)
        col += 1
    end
end
