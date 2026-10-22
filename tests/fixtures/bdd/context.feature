Feature: A fresh context per scenario

  Scenario: The first scenario touches the context
    Given the context is fresh
    When I touch the context
    Then a passing step

  Scenario: The second scenario sees a fresh context
    Given the context is fresh
    When I touch the context
    Then a passing step
