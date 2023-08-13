package routes

import (
	"net/http"

	"github.com/labstack/echo/v4"
	v "github.com/szaffarano/argocd-sandbox/version"
)

// Health shows the health of the application
func Health(c echo.Context) error {
	return c.JSON(http.StatusOK, struct{ Status string }{Status: "OK"})
}

// Hello shows a Hello World message
func Hello(c echo.Context) error {
	return c.HTML(http.StatusOK, "Hello, World!")
}

// Version shows the version of the application
func Version(version v.Version) echo.HandlerFunc {
	return func(c echo.Context) error {
		return c.JSON(http.StatusOK, version)
	}
}
