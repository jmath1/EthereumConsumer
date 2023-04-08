import json
import os

import boto3
from web3 import Web3

web3 = Web3(Web3.HTTPProvider(os.getenv("ETHEREUM_NODE")))

region_name = os.getenv("AWS_REGION", 'us-west-2')

kinesis = boto3.client('kinesis', region_name=region_name)

# Define a callback function to handle incoming blocks
def handle_block(block):
    block_data = {
        'block_number': block.number,
        'timestamp': block.timestamp,
        'transactions': []
    }

    # Iterate over the transactions in the block and add them to the block data
    for tx_hash in block.transactions:
        try:
            tx = web3.eth.getTransaction(tx_hash)
            tx_data = {
                'hash': tx.hash.hex(),
                'from': tx['from'],
                'to': tx['to'],
                'value': tx.value,
                'gas': tx.gas,
                'gas_price': tx.gasPrice,
                'input': tx.input
            }
            block_data['transactions'].append(tx_data)
        except Exception as e:
            print(f"""
                    Error with latest block: {block.number}
                  """)
            print(e)
            

    response = kinesis.put_record(
        StreamName=os.getenv("CONSUMER_STREAM_NAME"),
        Data=json.dumps(block_data),
        PartitionKey='0'
    )
    print(f"Sent block {block.number} to Kinesis stream")


latest_block_number = None
while True:
    latest_block = web3.eth.get_block("latest")
    if latest_block.number != latest_block_number:
        latest_block_number = latest_block.number
        handle_block(latest_block)
    continue