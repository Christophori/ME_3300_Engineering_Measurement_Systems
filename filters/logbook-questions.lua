-- logbook-questions.lua
-- Auto-numbers logbook questions in "Logbook Questions" callouts.
--
-- Usage in .qmd: start each question paragraph with **Q.**
-- (existing manually numbered **Q3.** labels are also renumbered).
-- Numbering is sequential within each document and restarts per file.

local n = 0

local function renumber(blocks)
  -- Quarto stores a Callout's content as a bare Block (not a Blocks list)
  -- when the callout has only a single paragraph; wrap it so :walk sees it.
  if blocks.t then
    blocks = pandoc.Blocks({ blocks })
  end
  return blocks:walk {
    Para = function(p)
      local first = p.content[1]
      if first and first.t == "Strong" then
        local label = pandoc.utils.stringify(first)
        if label:match("^Q%d*%.?$") then
          n = n + 1
          p.content[1] = pandoc.Strong({ pandoc.Str("Q" .. n .. ".") })
          return p
        end
      end
    end
  }
end

function Callout(el)
  local title = el.title and pandoc.utils.stringify(el.title) or ""
  if el.type == "important" and title == "Logbook Questions" then
    el.content = renumber(el.content)
    return el
  end
end
