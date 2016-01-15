#!/usr/bin/env python
import pika
import os

connection = pika.BlockingConnection(pika.ConnectionParameters(
        host='localhost'))
channel = connection.channel()

channel.queue_declare(queue='scan')

print ' [*] Waiting for messages. To exit press CTRL+C'

def callback(ch, method, properties, body):
	print " [x] Received Detected IP %r" % (body,)
	#TODO already register IP ? by socket to local agent, and see if any responese 
	#if not alreday register IP, ssh to this IP and install jobagent.py;Could also including install OS,configure systemd etc.later
	#TODO SSH server port open?
	
	#SSH to this ip and copy Service.py
	#TODO use RSA instead of password
	os.system("sshpass -p hellohello scp ../TxService/TxService.py hello@"+body+":~/")
	os.system("sshpass -p hellohello scp ../RxService/RxService.py hello@"+body+":~/")
	#START the service locally and kick off the ball...
	os.system("sshpass -p hellohello ssh hello@"+body+" python TxService.py")
	os.system("sshpass -p hellohello ssh hello@"+body+" python RxService.py")
	
		

channel.basic_consume(callback,
                      queue='scan',
                      no_ack=True)

channel.start_consuming()
