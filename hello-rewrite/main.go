package main

import (
	"io"
	"log"
	"net/http"

	restful "github.com/emicklei/go-restful/v3"
)

// This example shows the minimal code needed to get a restful.WebService working.
//https://github.com/emicklei/go-restful/blob/v3/examples/hello/restful-hello-world.go
func main() {
	ws := new(restful.WebService)
	ws.Route(ws.GET("/hello/{id}").To(welcome).Param(ws.PathParameter("id", "identifier").DataType("string")))
	ws.Route(ws.GET("/bye/{id}").To(bye).Param(ws.PathParameter("id", "identifier").DataType("string")))
	restful.Add(ws)
	log.Fatal(http.ListenAndServe(":12321", nil))
}
func welcome(req *restful.Request, resp *restful.Response) {
	id := req.PathParameter("id")
	io.WriteString(resp, "welcome "+id)
}

func bye(req *restful.Request, resp *restful.Response) {
	id := req.PathParameter("id")
	io.WriteString(resp, "bye "+id)
}
