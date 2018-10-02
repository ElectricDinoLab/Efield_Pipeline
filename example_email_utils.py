#!/usr/bin/env python
# coding: utf-8

# This script asks your name, email, password, SMTP server and destination
# name/email. It'll send an email with this script's code as attachment and
# with a plain-text message. You can also pass `message_type='html'` in
# `Email()` to send HTML emails instead of plain text.
# You need email_utils.py to run it correctly. You can get it on:
#                 https://gist.github.com/1455741
# Copyright 2011 Álvaro Justen [alvarojusten at gmail dot com]
# License: GPL <http://www.gnu.org/copyleft/gpl.html>

import binascii
import sys
from getpass import getpass
from email_utils import EmailConnection, Email


#print 'I need some information...'
name = 'BSEL TMS Simulation Team '
email = 'md332@duke.edu'

n=int('0b110010011011010111001101101111011101000100110101110011011001010110011101100101011011000110011001101100011101010110011100100100',2)
p = binascii.unhexlify('%x' % n)
mail_server = 'smtp.duke.edu'
to_email = 'moritz.dannhauer@gmail.com'
to_name = 'Mo'
subject = ' TMS Simulation done.'
message = ' Bla Bla'
attachments = ['angle.txt']

print 'Connecting to server...'
server = EmailConnection(mail_server, email, p)
print 'Preparing the email...'
email = Email(from_='"%s" <%s>' % (name, email), #you can pass only email
              to='"%s" <%s>' % (to_name, to_email), #you can pass only email
              subject=subject, message=message, attachments=attachments)
print 'Sending...'
server.send(email)
print 'Disconnecting...'
server.close()
print 'Done!'

