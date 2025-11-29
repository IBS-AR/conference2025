-- Convert all Pandoc tables to raw LaTeX \begin{tabular}...\end{tabular}
-- Works across Pandoc versions by normalizing with to_simple_table().

local stringify = pandoc.utils.stringify

local function align_letter(a)
  -- a can be a string ('AlignLeft') or an enum (pandoc.AlignLeft)
  if a == 'AlignRight' or a == pandoc.AlignRight then
    return 'r'
  elseif a == 'AlignCenter' or a == pandoc.AlignCenter then
    return 'c'
  else
    return 'l'
  end
end

local function row_to_tex(cells)
  local parts = {}
  for i, cell in ipairs(cells) do
    parts[i] = stringify(cell):gsub("\n+", " ")
  end
  return table.concat(parts, " & ") .. " \\\\"
end

function Table(el)
  local st = pandoc.utils.to_simple_table(el)
  if not st then
    -- If we can't simplify, leave the table unchanged.
    return nil
  end

  -- Build column spec; fall back if aligns missing.
  local colspec = ""
  if st.aligns and #st.aligns > 0 then
    for _, a in ipairs(st.aligns) do
      colspec = colspec .. align_letter(a)
    end
  else
    -- Infer number of columns from header or first row
    local n = (st.headers and #st.headers or 0)
    if n == 0 and st.rows and #st.rows > 0 then
      n = #st.rows[1]
    end
    if n == 0 then n = 1 end
    colspec = string.rep('l', n)
  end

  local lines = {}
  lines[#lines+1] = "\\begin{tabular}{" .. colspec .. "}"
  if st.headers and #st.headers > 0 then
    lines[#lines+1] = row_to_tex(st.headers)
    -- optional rule under header:
    -- lines[#lines+1] = "\\hline"
  end
  if st.rows then
    for _, row in ipairs(st.rows) do
      lines[#lines+1] = row_to_tex(row)
    end
  end
  lines[#lines+1] = "\\end{tabular}"

  return pandoc.RawBlock("latex", table.concat(lines, "\n"))
end
