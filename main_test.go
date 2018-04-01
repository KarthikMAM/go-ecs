package main

import (
	"net/http"
	"net/http/httptest"
	"testing"
)

func TestHandler(t *testing.T) {
	req, err := http.NewRequest("GET", "/hello-world", nil)
	if err != nil {
		t.Fatal(err)
	}

	recorder := httptest.NewRecorder()
	handler := http.HandlerFunc(HelloWorldHandler)

	handler.ServeHTTP(recorder, req)

	if status := recorder.Code; status != http.StatusOK {
		t.Errorf("Unexpected Code: Expected %v but got %v", http.StatusOK, status)
	}

	if body := recorder.Body.String(); body != "Hello World!! (/hello-world)" {
		t.Errorf("Unexpected Response: Expected `%s` but got `%s`", "Hello World!! (/hello-world)", body)
	}

	t.Logf("Response:`%s` Code:`%v`", recorder.Body.String(), recorder.Code)
}
