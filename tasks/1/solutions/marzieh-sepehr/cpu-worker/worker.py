import time
import math

def cpu_intensive_task(duration=2):
    """
    Cpu worker
    """
    end_time = time.time() + duration
    count = 0
    
    while time.time() < end_time:
        
        _ = math.sqrt(count)
        _ = math.factorial(20)
        count += 1
    
    return count

def main():
    print("[CPU-WORKER] Started")
    
    while True:
        print(f"[CPU-WORKER] Working... ", end='', flush=True)
        operations = cpu_intensive_task(duration=2)
        print(f"Done ({operations} operations)")
        
        print("[CPU-WORKER] Resting...")
        time.sleep(3)

if __name__ == "__main__":
    main()