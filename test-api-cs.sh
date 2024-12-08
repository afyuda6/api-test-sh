#!/bin/bash

CS_BASE_URL="http://localhost:6005"

test_endpoint() {
    local method=$1
    local endpoint=$2
    local expected_status=$3
    local expected_body=$4
    local name=$5
    local id=$6

    if [[ "$method" == "GET" ]]; then
        response=$(curl -s -w "HTTPSTATUS:%{http_code}" --request GET "$CS_BASE_URL$endpoint")
    elif [[ "$method" == "POST" ]]; then
        if [[ -z "$name" ]]; then
            response=$(curl -s -w "HTTPSTATUS:%{http_code}" --request POST "$CS_BASE_URL$endpoint" \
                --header 'Content-Type: application/x-www-form-urlencoded')
        else
            response=$(curl -s -w "HTTPSTATUS:%{http_code}" --request POST "$CS_BASE_URL$endpoint" \
                --header 'Content-Type: application/x-www-form-urlencoded' \
                --data-urlencode "name=$name")
        fi
    elif [[ "$method" == "PUT" ]]; then
        curl_data=()
        [[ -n "$id" ]] && curl_data+=(--data-urlencode "id=$id")
        [[ -n "$name" ]] && curl_data+=(--data-urlencode "name=$name")

        response=$(curl -s -w "HTTPSTATUS:%{http_code}" --request PUT "$CS_BASE_URL$endpoint" \
            --header 'Content-Type: application/x-www-form-urlencoded' "${curl_data[@]}")
    elif [[ "$method" == "DELETE" ]]; then
        if [[ -z "$id" ]]; then
            response=$(curl -s -w "HTTPSTATUS:%{http_code}" --request DELETE "$CS_BASE_URL$endpoint" \
                --header 'Content-Type: application/x-www-form-urlencoded')
        else
            response=$(curl -s -w "HTTPSTATUS:%{http_code}" --request DELETE "$CS_BASE_URL$endpoint" \
                --header 'Content-Type: application/x-www-form-urlencoded' \
                --data-urlencode "id=$id")
        fi
    elif [[ "$method" == "PATCH" ]]; then
        response=$(curl -s -w "HTTPSTATUS:%{http_code}" --request PATCH "$CS_BASE_URL$endpoint" \
            --header 'Content-Type: application/x-www-form-urlencoded' \
            --data-urlencode "id=$id" --data-urlencode "name=$name")
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

# test_endpoint "GET" "/users" 200 '{"status":"OK","code":200,"data":[]}'
# test_endpoint "POST" "/users" 201 '{"status":"Created","code":201}' "Yuda" ""
# test_endpoint "GET" "/users" 200 '{"status":"OK","code":200,"data":[{"id":1,"name":"Yuda"}]}'
# test_endpoint "PUT" "/users" 200 '{"status":"OK","code":200}' "Fajar" "1"
# test_endpoint "GET" "/users" 200 '{"status":"OK","code":200,"data":[{"id":1,"name":"Fajar"}]}'
# test_endpoint "DELETE" "/users" 200 '{"status":"OK","code":200}' "" "1"
# test_endpoint "GET" "/users" 200 '{"status":"OK","code":200,"data":[]}'

# test_endpoint "GET" "/users?" 200 '{"status":"OK","code":200,"data":[]}'
# test_endpoint "POST" "/users?" 201 '{"status":"Created","code":201}' "Yuda" ""
# test_endpoint "GET" "/users?" 200 '{"status":"OK","code":200,"data":[{"id":1,"name":"Yuda"}]}'
# test_endpoint "PUT" "/users?" 200 '{"status":"OK","code":200}' "Fajar" "1"
# test_endpoint "GET" "/users?" 200 '{"status":"OK","code":200,"data":[{"id":1,"name":"Fajar"}]}'
# test_endpoint "DELETE" "/users?" 200 '{"status":"OK","code":200}' "" "1"
# test_endpoint "GET" "/users?" 200 '{"status":"OK","code":200,"data":[]}'

# test_endpoint "GET" "/users/" 200 '{"status":"OK","code":200,"data":[]}'
# test_endpoint "POST" "/users/" 201 '{"status":"Created","code":201}' "Yuda" ""
# test_endpoint "GET" "/users/" 200 '{"status":"OK","code":200,"data":[{"id":1,"name":"Yuda"}]}'
# test_endpoint "PUT" "/users/" 200 '{"status":"OK","code":200}' "Fajar" "1"
# test_endpoint "GET" "/users/" 200 '{"status":"OK","code":200,"data":[{"id":1,"name":"Fajar"}]}'
# test_endpoint "DELETE" "/users/" 200 '{"status":"OK","code":200}' "" "1"
# test_endpoint "GET" "/users/" 200 '{"status":"OK","code":200,"data":[]}'

# test_endpoint "PATCH" "/users" 405 '{"status":"Method Not Allowed","code":405}'

# test_endpoint "GET" "/user" 404 '{"status":"Not Found","code":404}'
# test_endpoint "POST" "/user" 404 '{"status":"Not Found","code":404}' "Yuda" ""
# test_endpoint "PUT" "/user" 404 '{"status":"Not Found","code":404}' "Fajar" "1"
# test_endpoint "DELETE" "/user" 404 '{"status":"Not Found","code":404}' "" "1"
# test_endpoint "PATCH" "/user" 404 '{"status":"Not Found","code":404}' "Fajar" "1"

# test_endpoint "GET" "/users1" 404 '{"status":"Not Found","code":404}'
# test_endpoint "POST" "/users1" 404 '{"status":"Not Found","code":404}' "Yuda" ""
# test_endpoint "PUT" "/users1" 404 '{"status":"Not Found","code":404}' "Fajar" "1"
# test_endpoint "DELETE" "/users1" 404 '{"status":"Not Found","code":404}' "" "1"
# test_endpoint "PATCH" "/users1" 404 '{"status":"Not Found","code":404}' "Fajar" "1"

# test_endpoint "GET" "/users/users" 404 '{"status":"Not Found","code":404}'
# test_endpoint "POST" "/users/users" 404 '{"status":"Not Found","code":404}' "Yuda" ""
# test_endpoint "PUT" "/users/users" 404 '{"status":"Not Found","code":404}' "Fajar" "1"
# test_endpoint "DELETE" "/users/users" 404 '{"status":"Not Found","code":404}' "" "1"
# test_endpoint "PATCH" "/users/users" 404 '{"status":"Not Found","code":404}' "Fajar" "1"

test_endpoint "POST" "/users" 400 '{"status":"Bad Request","code":400, "errors":"Missing '\''name'\'' parameter"}' "" ""
test_endpoint "PUT" "/users" 400 '{"status":"Bad Request","code":400, "errors":"Missing '\''id'\'' or '\''name'\'' parameter"}' "Fajar" ""
test_endpoint "PUT" "/users" 400 '{"status":"Bad Request","code":400, "errors":"Missing '\''id'\'' or '\''name'\'' parameter"}' "" "1"
test_endpoint "DELETE" "/users" 400 '{"status":"Bad Request","code":400, "errors":"Missing '\''id'\'' parameter"}' "" ""