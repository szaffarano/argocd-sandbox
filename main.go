package main

import (
	"flag"
	"fmt"
	"os"

	"github.com/labstack/echo/v4"
	"github.com/labstack/echo/v4/middleware"

	"github.com/szaffarano/argocd-sandbox/routes"
	v "github.com/szaffarano/argocd-sandbox/version"
)

var (
	showVersion bool
	host        string
	port        int

	// version
	version string = "dev"
	commit  string = "none"
)

// var AppVersion .Version

func init() {
	flag.BoolVar(&showVersion, "version", false, "Show version and exit")
	flag.BoolVar(&showVersion, "v", false, "Show version and exit (shorthand)")
	flag.StringVar(&host, "host", "localhost", "Hostname to listen on")
	flag.IntVar(&port, "port", 8080, "Port to listen on")

	flag.Parse()

	if showVersion {
		// print version to stdout and exit
		fmt.Fprintf(os.Stdout, "Version: %+v\n", v.Version{Version: version, Commit: commit})
		os.Exit(0)
	}
}

func main() {
	e := echo.New()

	e.Use(middleware.Logger())
	e.Use(middleware.Recover())

	e.GET("/", routes.Hello)
	e.GET("/health", routes.Health)
	e.GET("/version", routes.Version(v.Version{Version: version, Commit: commit}))

	httpPort := os.Getenv("PORT")
	if httpPort == "" {
		httpPort = fmt.Sprintf("%d", port)
	}

	e.Logger.Fatal(e.Start(fmt.Sprintf("%s:%s", host, httpPort)))
}
