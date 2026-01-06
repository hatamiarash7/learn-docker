import logging
import time
from datetime import datetime

logging.basicConfig(
    level=logging.INFO,
    format='[%(levelname)s] producer alive %(message)s'
)

logger = logging.getLogger(__name__)

def main():
    while True:
        timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        logger.info(timestamp)
        time.sleep(3)

if __name__ == "__main__":
    main()