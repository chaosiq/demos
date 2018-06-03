import cherrypy
import requests

class Root:
    @cherrypy.expose
    def index(self):
        r = requests.get("http://localhost:7091/")
        return r.text


if __name__ == '__main__':
    cherrypy.config.update({'server.socket_port': 7090})
    cherrypy.quickstart(Root())