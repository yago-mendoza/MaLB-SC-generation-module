from datetime import datetime

def hline(title: str, filler: str = '#') -> None:
    current_time = datetime.now().strftime("%H:%M:%S")
    line = f"[{title}][{current_time}] "
    filler_line = '\n' + filler * len(line)
    print(filler_line)
    print(line)