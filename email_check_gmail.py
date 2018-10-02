import socket
import urllib2
import binascii
import imaplib
import smtplib
import email
import time
import sys, os
from email_utils import EmailConnection, Email
email_subject_keywords=['START_TMS_MODELING', 'Start TMS Modeling', 'Start TMS', 'TMS']
allowed_email_addresses=['moritz.dannhauer@duke.edu', 'simon.davis@duke.edu']
command = 'rundosingsim.sh '
path_to_subjs='/Users/BSEL/Desktop/WMT+TMS_Subjects/WMTMS_Anat/';
admin_email='md332@duke.edu';
email_service='imap.gmail.com';
connected_to_internet='http://www.gmail.com';

def internet_on():
    try:
        urllib2.urlopen(connected_to_internet, timeout=1)
        return True
    except urllib2.URLError as err:
        return False

def send_email(emailaddr, subj, msg, attachments):
    name = 'BSEL TMS Simulation Team '
    sim_email = admin_email;
    n=int('0b110010011011010111001101101111011101000100110101110011011001010110011101100101011011000110011001101100011101010110011100100100',2)
    p = binascii.unhexlify('%x' % n);
    mail_server = 'smtp.duke.edu'
    server = EmailConnection(mail_server, sim_email, p)
    to_name = ' Sender '
    subj = 'Re: ' + subj;
    if len(attachments)==1 and attachments[0]=='':
        email = Email(from_='"%s" <%s>' % (name, sim_email), #you can pass only email
              to='"%s" <%s>' % (to_name, emailaddr), #you can pass only email
              subject=subj, message=msg)
    else:
        email = Email(from_='"%s" <%s>' % (name, sim_email), #you can pass only email
                      to='"%s" <%s>' % (to_name, emailaddr), #you can pass only email
                      subject=subj, message=msg, attachments=attachments)
    server.send(email)
    server.close()

def get_first_text_block(email_message_instance):
        maintype = email_message_instance.get_content_maintype()
        if maintype == 'multipart':
            for part in email_message_instance.get_payload():
                if part.get_content_maintype() == 'text':
                    return part.get_payload()
        elif maintype == 'text':
            return email_message_instance.get_payload()

while True:
 if internet_on() == True:
    mail = imaplib.IMAP4_SSL(email_service);
    mail.login('BSEL.TMS.Simulations@gmail.com', 'BSELneuron');
    mail.select("Inbox")
    result, data = mail.search(None, "(UNSEEN)")
    ids = data[0]
    id_list = ids.split()
    if len(id_list) > 0:
        print('New Mail Found...\n')
        t = time.time()
        latest_email_id = id_list[-1] #get last email
        result, data = mail.fetch(latest_email_id, "(RFC822)")
        raw_email = data[0][1]
        email_message = email.message_from_string(raw_email)
        sender = email.utils.parseaddr(email_message['From'])
        subject = email_message['Subject']
        if subject in email_subject_keywords:
            if sender[1] in allowed_email_addresses:
                textbody = get_first_text_block(email_message)
                textbody = textbody[0:-2]
                msg= 'A TMS simulation process has been initiated related to your request: \n' + textbody + '\nIt will take take at least 12h and all results will be sent to you via email. \nYou will also be notified in case of a malfunction. \nThank you! \n \n';
                sub=subject + "  " + str(textbody[0:4]) + " started.";
                send_email(sender[1], sub, msg, ['']);
                print "Email acknowledgement sent!"
                finalcommand = command + textbody
                ## Put email command here
                print finalcommand
                os.system(finalcommand)
                elapsed = time.time() - t
                hours, rem = divmod(elapsed, 3600)
                minutes, seconds = divmod(rem, 60)
                print("Time Elapsed is {:0>2}:{:0>2}:{:05.2f}".format(int(hours),int(minutes),seconds))
                msg= 'Your TMS simulation request is complete: \n' + textbody + '\nSee resulting files attached. \n \n';
                sub= subject + "  " + str(textbody[0:4]) + " simulations completed!"
                attch=[path_to_subjs + str(textbody[0:4]) + '/DosingSim/DosingData/intensity.txt', path_to_subjs + str(textbody[0:4]) + '/m2m_'  +  str(textbody[0:4]) + '/skin.stl', path_to_subjs + str(textbody[0:4]) + '/ROIanalysis/angle.txt' ];
                if os.access(attch[0], os.F_OK) and os.access(attch[1], os.F_OK) and os.access(attch[2], os.F_OK):
                   print "Sending email to notify user on completed request + resulting file attachments!"
                   send_email(sender[1], sub, msg, attch);
                else:
                   print "Email attachments files were not found. Sending email to notify user on malfunction."
                   msg = 'Your TMS simulation request failed: \n' + textbody + '\nPlease see file log.txt for more details (attached to this email). \nThe BSEL TMS simulation team is CCed on this email and will contact you asap.\n';
                   sub= "Re: " + subject + "  " + str(textbody[0:4]) + " simulations failed !!!!";
                   attch=[ path_to_subjs + str(textbody[0:4]) + '/log.txt' ];
                   send_email(sender[1], sub, msg, attch);
                   send_email(str(admin_email), sub, msg, attch);
                   #server = smtplib.SMTP('smtp.gmail.com', 587)
                   #server.starttls()
                   #server.login("BSEL.TMS.Simulations@gmail.com", "BSELneuron")
                   #message = 'Subject: {}\n\n{}'.format(sub, msg)
                   #server.sendmail(str(admin_email), str(admin_email), message)
                   #server.sendmail(str(admin_email), sender[1], message)
                   #server.quit();
    else:
        print('No Mail Yet..\n')


    time.sleep(5)
 else:
     print(' NO INTERNET CONNECTION - WAITING FOR 5 MINUTES AND TRY TO RECONNECT');
     time.sleep(300)
