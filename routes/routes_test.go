package routes

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/labstack/echo/v4"
	"github.com/stretchr/testify/assert"
	v "github.com/szaffarano/argocd-sandbox/version"
)

func TestHelloHandler(t *testing.T) {
	e := echo.New()

	req := httptest.NewRequest(http.MethodGet, "/hello", nil)
	rec := httptest.NewRecorder()

	c := e.NewContext(req, rec)

	err := Hello(c)

	assert.NoError(t, err)
	assert.Equal(t, http.StatusOK, rec.Code)
	assert.Equal(t, "Hello, World!", rec.Body.String())
}

func TestVersionHandler(t *testing.T) {
	e := echo.New()

	req := httptest.NewRequest(http.MethodGet, "/version", nil)
	rec := httptest.NewRecorder()

	c := e.NewContext(req, rec)

	err := Version(v.Version{Version: "v1", Commit: "c1"})(c)

	assert.NoError(t, err)
	assert.Equal(t, http.StatusOK, rec.Code)

	var got v.Version
	if err := json.Unmarshal(rec.Body.Bytes(), &got); err != nil {
		t.Fail()
	}
	assert.Equal(t, "v1", got.Version)
	assert.Equal(t, "c1", got.Commit)
}
