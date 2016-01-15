#!/usr/bin/env python
import pika

connection = pika.BlockingConnection(pika.ConnectionParameters(
        host='localhost'))
channel = connection.channel()

channel.queue_declare(queue='Txjobs')

channel.basic_publish(exchange='',
                      routing_key='Txjobs',
                      body='Tx')
print " [x] Sent Tx"
connection.close()
