import cherrypy
import requests

class Root:
    @cherrypy.expose
    def index(self):
        return "Bonjour from the French"


if __name__ == '__main__':
    cherrypy.config.update({'server.socket_port': 7092})
    cherrypy.quickstart(Root())