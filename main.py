# main.py
import sys


def main():
    # Check if at least one command line argument is provided
    if len(sys.argv) < 2:
        print("No command provided.")
        return

    # The first argument is always the script name, so the command would be the second argument
    command = sys.argv[1]

    # Handle different commands
    if command == "bigbang":
        bigbang()
    elif command == "install-module" and len(sys.argv) == 3:
        install_module(sys.argv[2])
    elif command == "create-app" and len(sys.argv) == 3:
        create_app(sys.argv[2])
    else:
        print("Invalid command or missing arguments.")


def bigbang():
    print("Running 'bigbang' command.")


def install_module(module_name):
    print(f"Installing module: {module_name}")


def create_app(app_name):
    print(f"Creating application: {app_name}")

if __name__ == "__main__":
    main()
