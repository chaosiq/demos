import cherrypy
import requests

class Root:
    @cherrypy.expose
    def index(self):
        return "Hello world"


if __name__ == '__main__':
    cherrypy.config.update({'server.socket_port': 7091})
    cherrypy.quickstart(Root())