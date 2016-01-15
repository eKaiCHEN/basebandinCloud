#!/usr/bin/env python
import pika

connection = pika.BlockingConnection(pika.ConnectionParameters(
        host='localhost'))
channel = connection.channel()

channel.queue_declare(queue='Rxjobs')

channel.basic_publish(exchange='',
                      routing_key='Rxjobs',
                      body='Rx')
print " [x] Sent Rx"
connection.close()
