package main

import (
	"embed"
	"flag"
	"fmt"
	"io/fs"
	"log"
	"net/http"
)

var port int

//go:embed assets
var assets embed.FS

func init() {
	flag.IntVar(&port, "port", 80, "http port")
}

func main() {
	flag.Parse()
	r := http.NewServeMux()
	md, _ := fs.Sub(assets, "assets")
	r.Handle("/", http.FileServer(http.FS(md)))
	s := http.Server{
		Addr:    fmt.Sprintf(":%d", port),
		Handler: r,
	}
	log.Printf("service listen @ port: %d\n", port)
	if err := s.ListenAndServe(); err != nil && err != http.ErrServerClosed {
		log.Fatal(err)
	}
}
