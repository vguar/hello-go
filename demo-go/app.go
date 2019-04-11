package main

import (
	"log"
	"net/http"

	"github.com/prometheus/client_golang/prometheus/promhttp"
)

func main() {
	finish := make(chan bool)

	server8080 := http.NewServeMux()
	fs := http.FileServer(http.Dir("static"))
	server8080.Handle("/", fs)

	server8081 := http.NewServeMux()
	server8081.Handle("/metrics", promhttp.Handler())

	go func() {
		log.Println("Starting /metrics on port 8081")
		http.ListenAndServe(":8081", server8081)
	}()

	go func() {
		log.Println("Starting Hello Demo")
		http.ListenAndServe(":8080", server8080)
	}()

	<-finish
}
