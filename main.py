from client import kafka_class
import websockets
import asyncio
import json
from dotenv import load_dotenv
import os
import logging

load_dotenv()

fp = os.getenv("CONFIG_FILEPATH")
api_key = os.getenv("API_KEY")
kafka_class = kafka_class(fp)

async def stream_stock():
    url = "wss://socket.polygon.io/stocks"
    
    while True:
        try:
            async with websockets.connect(url) as ws:
                await ws.send(json.dumps({"action": "auth", "params": api_key}))
                await ws.send(json.dumps({"action": "subscribe", "params": "T.*"}))
                
                async for message in ws:
                    kafka_class.produce("stock", key="trade", value=json.dumps(message))
                    
        except Exception as e:
            print(f"⚠️ Connection lost: {e}. Reconnecting in 5s...")
            await asyncio.sleep(5)
            
async def main():
    asyncio.create_task(stream_stock())
    await asyncio.Future()

if __name__ == "__main__":
    asyncio.run(main())