#!/usr/bn/env python
import smtplib

server = smtplib.SMTP('smtp.gmail.com', 587)
server.starttls()
server.login("BSEL.TMS.Simulations@gmail.com", "BSELneuron")
subject = "Simulation Results"
text = "Simulation Complete"
message = 'Subject: {}\n\n{}'.format(subject, text)
server.sendmail("moritz.dannhauer@gmail.com", "wesley.lim1@gmail.com", message)
server.quit()
