@wip @manual
# temporary comment
Feature: My user dashboard

  Background: Signed in as admin
    Given I successfully sign in as admin

  Scenario: Generate a report
    When I look up a invalid hwf reference
    Then I should see the reference number is not recognised

  Scenario: View offices
    When I click on view office
    Then I am taken to the offices page

  Scenario: Total responses
    Then I should see all the responses by type

  Scenario: Time of day
    Then I should see checks by time of day
    