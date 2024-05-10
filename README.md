# Help With Fees - Staff App
[![Code Climate](https://codeclimate.com/github/ministryofjustice/fr-staffapp/badges/gpa.svg)](https://codeclimate.com/github/ministryofjustice/fr-staffapp) [![Test Coverage](https://codeclimate.com/github/ministryofjustice/fr-staffapp/badges/coverage.svg)](https://codeclimate.com/github/ministryofjustice/fr-staffapp/coverage?sort=covered_percent&sort_direction=asc)

[![Build Status](https://dev.azure.com/HMCTS-PET/pet-azure-infrastructure/_apis/build/status/Help%20with%20Fees/hwf-staffapp?branchName=develop)](https://dev.azure.com/HMCTS-PET/pet-azure-infrastructure/_build/latest?definitionId=26&branchName=develop)

## Overview

This app is used by staff in the courts and tribunals to enter data regarding help with fees applications,
record the decision, and collect statistics.

## Project Standards

- Authentications via Devise / CanCanCan
- Rspec features, not cucumber
- Slim templating language
- JavaScript in preference to Coffeescript

## Feature switching
Model FeatureSwitching have following attributes:
feature_key, activation_time, office_id, enabled. When apply you can "schedule" a feature to be active from a certain date or for
specific office. Feature switching table is managed manually from a rails console for now.


## N+1 queries debugging
There is a gem called Bullet. If you want to check N+1 queries in development mode, you can uncomment
Bullet related lines in development.rb


## Delayed CRON Jobs (delayed_cron_job)
We need to keep an eye on the results of DWP checks. When the API is down the service will disable
benefit related applications. Then we re-run failed checks in 10 minutes intervals to see if the
API is back again. We are not using standard CRON table because Kubernetes have a bug. So we are using
delayed cron job that has the schedule in DB table. These tasks are checked by

```rake jobs:work```

that needs to run on the background, currently set up in rub.sh :
```rake jobs:work &```



## Delayed jobs for BenefitChecks
To set it up (if there is no record in DB) run this in rails console:
```BenefitCheckRerunJob.delay(cron: '*/10 * * * *').perform_now```

## Delayed jobs for DWP offline notification
Runs every 5 minutes
```DwpReportStatusJob.delay(cron: '*/5 * * * *').perform_now```

## Delayed jobs for HMRC data purge
Runs 10 minutes past midnight
```HmrcDataPurgeJob.delay(cron: '10 0 * * *').perform_now```

## Delayed jobs for Personal data purge
Runs every day at 1am
```PersonalDataPurgeJob.delay(cron: '0 1 * * *').perform_now```

## Delayed jobs for Abandoned Application data purge
Runs every day at 1am
```AbandonedApplicationPurgeJob.delay(cron: '0 1 * * *').perform_now```

## Delayed jobs for Old export file data purge
Runs every day at 2am
```OldFileExportPurgeJob.delay(cron: '0 2 * * *').perform_now```

## Pre-requisites
You will need to install govuk-frontend library
```
npm install --save govuk-frontend
```
Mimemagic gem has a dependency so you need to install this on your machine first
```brew install shared-mime-info.```

#### Creating initial user
There is a rake task that takes email, password and role

```
rake user:create
```

If you want to add any custom options, use the below as an example:

```
rake "user:create[user@hmcts.net, 12345678900, admin, name]"
```
__Note:__ the quotes around the task are important!

#### Run an applicants report for a finacial year

There is a rake task that creates the report

```
rake "reports:applicants[2021, 2022]"
```
this will generate a zip file applicants-2021-2022-fy.csv.zip

#### Run raw data extract for longer timescale

There is a rake task that creates the report

```
rake "reports:raw_data_extract[2021-01-01, 2022-12-31]"
```
this will generate a zip file raw_data-1-1-2021-31-12-2022.csv.zip


#### Run tests in parallel
Follow the [official guides](https://github.com/grosser/parallel_tests#setup-environment-from-scratch-create-db-and-loads-schema-useful-for-ci) to setup your local env


Run the specs in parallel
```
RAILS_ENV=test bundle exec rake parallel:spec
```

Run the cucumber features in parallel
```
CAPYBARA_SERVER_PORT=random bundle exec rake parallel:features
```

#### Cucumber test report
Cucumber report is enabled now. At the end of the test run you should see a link to a website.
When you run tests in parallel it will generate report per process so if you want to see one report only you should
run test directly without parallel functionality.

Deployment versions trigger: 2
