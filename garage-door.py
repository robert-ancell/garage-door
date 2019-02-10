#!/usr/bin/python3

from gpiozero import OutputDevice
from http import HTTPStatus
from http.server import HTTPServer, BaseHTTPRequestHandler
from time import sleep

RELAY_GPIO = 4
RELAY_DELAY = 0.3

root_html = open ('root.html').read ()
button_data = open ('button.png', 'rb').read ()

device = OutputDevice (RELAY_GPIO, active_high = False)

def toggle_relay ():
    device.on ()
    sleep (RELAY_DELAY)
    device.off ()

class GarageDoorHandler (BaseHTTPRequestHandler):
    def do_GET (self):
        print (self.path)

        if self.path == '/':
            self.send_response (HTTPStatus.OK)
            self.send_header ('Content-type', 'text/html')
            self.end_headers ()
            self.wfile.write (bytes (root_html, 'UTF-8'))
        elif self.path == '/button.png':
            self.send_response (HTTPStatus.OK)
            self.send_header ('Content-type', 'image/png')
            self.end_headers ()
            self.wfile.write (button_data)
        elif self.path == '/press-button':
            self.send_response (HTTPStatus.OK)
            self.end_headers ()
        else:
            self.send_response (HTTPStatus.NOT_FOUND)
            self.end_headers ()

s = HTTPServer (('', 8080), GarageDoorHandler)
s.serve_forever ()
