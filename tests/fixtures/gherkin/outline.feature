Feature: Outlines

  Scenario Outline: Reading <value> is shown
    Given a sensor that reported <value>
      """
      reading=<value> unit=<unit>
      """
    When the operator opens the dashboard
      | field | shown   |
      | value | <value> |
    Then the dashboard shows <value> <unit>

    Examples: Celsius
      | value | unit |
      | 21.5  | C    |
      | -3    | C    |

    Examples: Fahrenheit
      | value | unit |
      | 70    | F    |
