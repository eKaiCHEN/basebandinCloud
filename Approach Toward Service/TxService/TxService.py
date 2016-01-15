#!/usr/bin/env python
import pika

connection = pika.BlockingConnection(pika.ConnectionParameters(
        host='192.168.56.101'))
channel = connection.channel()

channel.queue_declare(queue='Txjobs')

print ' [*] Waiting for messages. To exit press CTRL+C'

def callback(ch, method, properties, body):
    print " [x] Received %r" % (body,)
    #excute the TX task script locally
    os.system("./Tasktransmiter.sh")

channel.basic_consume(callback,
                      queue='Txjobs',
                      no_ack=True)

channel.start_consuming()
