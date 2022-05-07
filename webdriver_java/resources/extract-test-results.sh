#!/usr/bin/env bash

###################################################################################################
#     This is extracting the values for each test suite description.                              #
#     It uses awk to print the value between two quotes.                                          #
#     The columns printed is based on the following example string:                               #
#     <testng-results ignored="0" total="23" passed="22" failed="1" skipped="0">                  #
###################################################################################################

TEST_RESULTS_LOCATION="${1:-/home/runner/work/selenium-webdriver-java-course/selenium-webdriver-java-course/webdriver_java/target/surefire-reports}"
TEST_RESULTS_STRING=$(cat "${TEST_RESULTS_LOCATION}/testng-results.xml" | grep "<testng-results")
IGNORED_TESTS=$(awk -F'"' '{ print $2 }' <<< $TEST_RESULTS_STRING)
TOTAL_TESTS=$(awk -F'"' '{ print $4 }' <<< $TEST_RESULTS_STRING)
PASSED_TESTS=$(awk -F'"' '{ print $6 }' <<< $TEST_RESULTS_STRING)
FAILED_TESTS=$(awk -F'"' '{ print $8 }' <<< $TEST_RESULTS_STRING)
SKIPPED_TESTS=$(awk -F'"' '{ print $10 }' <<< $TEST_RESULTS_STRING)

cat <<EOF | curl --data-binary @- ${PROMETHEUS_SERVER_ADDRESS}/metrics/job/gh_actions
gh_actions_tests_ignored $IGNORED_TESTS
gh_actions_tests_total $TOTAL_TESTS
gh_actions_tests_passed $PASSED_TESTS
gh_actions_tests_failed $FAILED_TESTS
gh_actions_tests_skipped $SKIPPED_TESTS
# TYPE gh_actions_tests gauge
gh_actions_tests{count_type="ignored"} $IGNORED_TESTS
gh_actions_tests{count_type="total"} $TOTAL_TESTS
gh_actions_tests{count_type="passed"} $PASSED_TESTS
gh_actions_tests{count_type="failed"} $FAILED_TESTS
gh_actions_tests{count_type="skipped"} $SKIPPED_TESTS
# TYPE gh_actions_tests_by_ref gauge
gh_actions_tests_by_ref{repo="${GITHUB_REPOSITORY}", git_ref="${GITHUB_REF}", count_type="ignored"} $IGNORED_TESTS
gh_actions_tests_by_ref{repo="${GITHUB_REPOSITORY}", git_ref="${GITHUB_REF}", count_type="total"} $TOTAL_TESTS
gh_actions_tests_by_ref{repo="${GITHUB_REPOSITORY}", git_ref="${GITHUB_REF}", count_type="passed"} $PASSED_TESTS
gh_actions_tests_by_ref{repo="${GITHUB_REPOSITORY}", git_ref="${GITHUB_REF}", count_type="failed"} $FAILED_TESTS
gh_actions_tests_by_ref{repo="${GITHUB_REPOSITORY}", git_ref="${GITHUB_REF}", count_type="skipped"} $SKIPPED_TESTS
# TYPE gh_actions_tests_by_run_id gauge
gh_actions_tests_by_run_id{repo="${GITHUB_REPOSITORY}", git_ref="${GITHUB_REF}", git_run_id="${GITHUB_RUN_ID}", count_type="ignored"} $IGNORED_TESTS
gh_actions_tests_by_run_id{repo="${GITHUB_REPOSITORY}", git_ref="${GITHUB_REF}", git_run_id="${GITHUB_RUN_ID}", count_type="total"} $TOTAL_TESTS
gh_actions_tests_by_run_id{repo="${GITHUB_REPOSITORY}", git_ref="${GITHUB_REF}", git_run_id="${GITHUB_RUN_ID}", count_type="passed"} $PASSED_TESTS
gh_actions_tests_by_run_id{repo="${GITHUB_REPOSITORY}", git_ref="${GITHUB_REF}", git_run_id="${GITHUB_RUN_ID}", count_type="failed"} $FAILED_TESTS
gh_actions_tests_by_run_id{repo="${GITHUB_REPOSITORY}", git_ref="${GITHUB_REF}", git_run_id="${GITHUB_RUN_ID}", count_type="skipped"} $SKIPPED_TESTS
EOF