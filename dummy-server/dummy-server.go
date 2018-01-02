package main

import (
	"fmt"
	"log"
	"net/http"
	"os"
)

func helloHandler(hostname string) func(http.ResponseWriter, *http.Request) {
	return func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, "Hello from %s!", hostname)
	}
}

func main() {
	port := os.Getenv("DUMMY_SERVER_PORT")
	if port == "" {
		log.Fatal("Missing DUMMY_SERVER_PORT env")
	}

	hostname, err := os.Hostname()
	if err != nil {
		log.Fatal("Could not get hostname:", err)
	}

	http.HandleFunc("/", helloHandler(hostname))
	err = http.ListenAndServe(fmt.Sprintf(":%s", port), nil)
	if err != nil {
		log.Fatal("Error starting server:", err)
	}
}
