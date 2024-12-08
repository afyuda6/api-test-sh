#!/bin/bash

SCALA_BASE_URL="http://localhost:6010"

test_endpoint() {
    local method=$1
    local endpoint=$2
    local expected_status=$3
    local expected_body=$4

    if [[ "$method" == "GET" ]]; then
        response=$(curl -s -w "HTTPSTATUS:%{http_code}" --request GET "$SCALA_BASE_URL$endpoint")
    elif [[ "$method" == "POST" ]]; then
        response=$(curl -s -w "HTTPSTATUS:%{http_code}" --request POST "$SCALA_BASE_URL$endpoint" \
            --header 'Content-Type: application/x-www-form-urlencoded' \
            --data-urlencode 'name=Yuda')
    elif [[ "$method" == "PUT" ]]; then
        response=$(curl -s -w "HTTPSTATUS:%{http_code}" --request PUT "$SCALA_BASE_URL$endpoint" \
            --header 'Content-Type: application/x-www-form-urlencoded' \
            --data-urlencode 'id=1' --data-urlencode 'name=Fajar')
    elif [[ "$method" == "DELETE" ]]; then
        response=$(curl -s -w "HTTPSTATUS:%{http_code}" --request DELETE "$SCALA_BASE_URL$endpoint" \
            --header 'Content-Type: application/x-www-form-urlencoded' \
            --data-urlencode 'id=1')
    elif [[ "$method" == "PATCH" ]]; then
        response=$(curl -s -w "HTTPSTATUS:%{http_code}" --request PATCH "$CPP_BASE_URL$endpoint" \
            --header 'Content-Type: application/x-www-form-urlencoded' \
            --data-urlencode 'id=1' --data-urlencode 'name=Fajar')
    fi

    http_status=$(echo "$response" | sed -n 's/.*HTTPSTATUS:\([0-9]*\)$/\1/p')
    response_body=$(echo "$response" | sed -e 's/HTTPSTATUS:.*//')

    clean_response_body=$(echo "$response_body" | tr -d '[:space:]')
    clean_expected_body=$(echo "$expected_body" | tr -d '[:space:]')

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

test_endpoint "PATCH" "/users" 405 '{"status":"Method Not Allowed","code":405}'

test_endpoint "GET" "/user" 404 '{"status":"Not Found","code":404}'
test_endpoint "POST" "/user" 404 '{"status":"Not Found","code":404}'
test_endpoint "PUT" "/user" 404 '{"status":"Not Found","code":404}'
test_endpoint "DELETE" "/user" 404 '{"status":"Not Found","code":404}'
test_endpoint "PATCH" "/user" 404 '{"status":"Not Found","code":404}'