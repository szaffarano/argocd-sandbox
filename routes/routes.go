package routes

import (
	"net/http"

	"github.com/labstack/echo/v4"
	v "github.com/szaffarano/argocd-sandbox/version"
)

func Health(c echo.Context) error {
	return c.JSON(http.StatusOK, struct{ Status string }{Status: "OK"})
}

func Hello(c echo.Context) error {
	return c.HTML(http.StatusOK, "Hello, World!")
}

func Version(version v.Version) echo.HandlerFunc {
	return func(c echo.Context) error {
		return c.JSON(http.StatusOK, version)
	}
}
