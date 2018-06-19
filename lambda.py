"""Code from the AWS Lambda that uses Rekognition and triggers a rating response on the image fed to it. 
The closer to 100 the rating is the more hospitable the images of the home look for adoption.
The ML algorithm's criteria searches for "good labels" of objects recognized in the image.
"""
from __future__ import print_function
import boto3
from decimal import Decimal
import json
import urllib
rekognition = boto3.client('rekognition','us-east-2')
sqs = boto3.client('sqs')
sns = boto3.client('sns')
def lambda_handler(event, context):
    print(event)
    bucket = event['Records'][0]['s3']['bucket']['name']
    key = event['Records'][0]['s3']['object']['key']
    try:
        # Calls Amazon Rekognition IndexFaces API to detect faces in S3 object 
        # to index faces into specified collection
        response = rekognition.detect_labels(
            Image={
                'S3Object': {
                    'Bucket': bucket,
                    'Name': key
                }
            }
        )
        queue_url = 'https://sqs.us-east-2.amazonaws.com/040802760822/bestfriend'
        goodLabels = ["Flora", "Garden", "Yard", "House", "Plant", "Backyard", "Living Room", "Room", "Table", "Indoors", "Couch", "Coffee Table"]
        testArray = []
        test2Array = []        
        sum = 0
        avg = 0
        avg = len(response["Labels"])
        for x in response["Labels"]:
            if x["Name"] in goodLabels:
                sum += x["Confidence"]
        c = sum = sum/avg
       # print(response['MessageId'])
        # Send message to SQS queue
        sqsResponse = sqs.send_message(
            QueueUrl=queue_url,
            DelaySeconds=10,
            MessageBody=(str(c))
        )
        snsResponse = sns.publish(
            TopicArn='arn:aws:sns:us-east-2:040802760822:bestfriend',
            Message= str(c),
            Subject='BestFriend!!'
        )
        #print(curResponse)
        return (c)
    except Exception as e:
        print(e)
        raise e
