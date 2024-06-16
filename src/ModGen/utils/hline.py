from datetime import datetime

def hline(title: str, filler: str = '#') -> None:
    current_time = datetime.now().strftime("%H:%M:%S")
    line = f"[{current_time}][{title}] "
    print(line)