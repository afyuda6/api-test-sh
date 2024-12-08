#!/bin/bash

RS_BASE_URL="http://localhost:6007"

test_endpoint() {
    local method=$1
    local endpoint=$2
    local expected_status=$3
    local expected_body=$4

    if [[ "$method" == "GET" ]]; then
        response=$(curl -s -w "HTTPSTATUS:%{http_code}" --request GET "$RS_BASE_URL$endpoint")
    elif [[ "$method" == "POST" ]]; then
        response=$(curl -s -w "HTTPSTATUS:%{http_code}" --request POST "$RS_BASE_URL$endpoint" \
            --header 'Content-Type: application/x-www-form-urlencoded' \
            --data-urlencode 'name=Yuda')
    elif [[ "$method" == "PUT" ]]; then
        response=$(curl -s -w "HTTPSTATUS:%{http_code}" --request PUT "$RS_BASE_URL$endpoint" \
            --header 'Content-Type: application/x-www-form-urlencoded' \
            --data-urlencode 'id=1' --data-urlencode 'name=Fajar')
    elif [[ "$method" == "DELETE" ]]; then
        response=$(curl -s -w "HTTPSTATUS:%{http_code}" --request DELETE "$RS_BASE_URL$endpoint" \
            --header 'Content-Type: application/x-www-form-urlencoded' \
            --data-urlencode 'id=1')
    fi

    http_status=$(echo "$response" | sed -e 's/.*HTTPSTATUS://')
    response_body=$(echo "$response" | sed -e 's/HTTPSTATUS:.*//')

    clean_response_body=$(echo "$response_body" | sed -e 's/[[:space:]]//g')
    clean_expected_body=$(echo "$expected_body" | sed -e 's/[[:space:]]//g')

    if [[ "$http_status" -ne "$expected_status" ]]; then
        echo "FAILED: $method $endpoint (Expected Status: $expected_status, Got: $http_status)"
        echo "Response Body: $response_body"
        return
    fi

    if [[ -n "$expected_body" ]]; then
        if [[ "$clean_response_body" == "$clean_expected_body" ]]; then
            echo "PASSED: $method $endpoint (Status: $http_status, Body Validation: Match)"
        else
            echo "FAILED: $method $endpoint (Body Validation Failed)"
            echo "Expected Body: $clean_expected_body"
            echo "Actual Response Body: $clean_response_body"
        fi
    else
        echo "PASSED: $method $endpoint (Status: $http_status)"
    fi
}

test_endpoint "GET" "/users" 200 '{"status":"OK","code":200,"data":[]}'
test_endpoint "POST" "/users" 201 '{"status":"Created","code":201}'
test_endpoint "GET" "/users" 200 '{"status":"OK","code":200,"data":[{"id":1,"name":"Yuda"}]}'
test_endpoint "PUT" "/users" 200 '{"status":"OK","code":200}'
test_endpoint "GET" "/users" 200 '{"status":"OK","code":200,"data":[{"id":1,"name":"Fajar"}]}'
test_endpoint "DELETE" "/users" 200 '{"status":"OK","code":200}'
test_endpoint "GET" "/users" 200 '{"status":"OK","code":200,"data":[]}'