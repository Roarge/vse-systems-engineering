Feature: Data tables

  Scenario: Cells unescape
    Given the cells
      | plain | pipe \| inside | back \\ slash | new \n line | tab \t kept |
      |  padded  | b | c | d | e |
      | \nedge | g | h | i | j | text after the last pipe is ignored
    When they are read
    Then each cell keeps its meaning
