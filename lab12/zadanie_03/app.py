import platform

def main():
    system = platform.system()
    if system == "Windows":
        print("Witaj w systemie Windows!")
    elif system == "Linux":
        print("Witaj w systemie Linux!")
    else:
        print(f"Witaj w systemie {system}!")

if __name__ == "__main__":
    main()
