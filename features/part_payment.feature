Feature: Processing part payments

  Background: Processed application that rquires a part payment
    Given I am on a processed application that rquires a part payment
  
  Scenario: Successfully process part payment
    And the payment is ready to process
    When I complete processing
    And I open the processed part payment application
    Then I can see that the applicant has paid £40 towards the fee

  Scenario: Part payment is not ready to process
    When the payment is not ready to process
    Then I should see my reason on the part payments summary page
    And I can see that the applicant needs to make a new application
    When processing is complete I should see a letter template