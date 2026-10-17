<!-- Pull request template for the vse-systems-engineering plugin.
     Open the pull request as a draft and keep it in draft until it is
     believed final. -->

## Summary

<!-- What the change does and why it is needed, in a few sentences or
     bullets. Name any issue it closes, for example "Closes #42". -->

## Test-first evidence

<!-- Required when the change touches code: bash under hooks/, Python
     under templates/tools/ or tests/, or Makefile logic. For each code
     change, paste the failing test command and its first failing lines,
     captured before the code that made the test pass, and say in one
     line why that failure was the expected one. Example:

       $ bash tests/hooks/test-pre-commit.sh
       FAIL: range mode: the story committed on the branch stops the check

     A behaviour change starts with a new or changed scenario under
     tests/features/, so name the scenario too. A pure refactoring on a
     refactor/ branch says so, with the tests unchanged. A change that
     touches no code (skills, agents, commands, wiki, methodology,
     Markdown templates or CI YAML) writes "Not applicable: prose only"
     or "Not applicable: CI YAML, checked by Makefile parity". -->

## Test plan

<!-- The checks run and their results. `make all` covers every check
     that CI runs. Add any manual check, such as a skill or command
     exercised inside demo/smart-sensor/ with the branch installed as a
     local plugin. -->

- [ ] `make all` passes locally.
