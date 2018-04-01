package main

import (
	"fmt"
	"log"
	"net/http"
)

// HelloWorldHandler Handles Everything
func HelloWorldHandler(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "Hello World!! (%s)", r.URL.Path)
}

func main() {
	http.HandleFunc("/", HelloWorldHandler)

	log.Fatal(http.ListenAndServe(":8080", nil))
}
