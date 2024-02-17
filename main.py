# main.py
import re
import os
import argparse
import subprocess
import importlib
import yaml


class Foundation:
    def __init__(self, config_dir: str = "config", **kwargs):
        self.config_dir = config_dir
        self.module_dir = os.path.sep.join(["iac", "modules"])
        self.application_yaml = os.path.sep.join([self.config_dir, "applications.yaml"])
        self.module_yaml = os.path.sep.join([self.config_dir, "modules.yaml"])

        # Temporary files
        self.requirements_txt = os.path.sep.join([self.config_dir, "requirements.txt"])
        self.package_pattern = re.compile(r'^[a-zA-Z0-9_-]+$')

    def bigbang(self):
        """Create the realm administration project"""
        print("Running 'bigbang' command.")

    def birth(self):
        self.register_module("gcp-module-project", "Project")
        self.register_module("gcp-module-application", "Application")
        self.update_requirements()
        self.install_requirements()
        self.enable_modules()

    def register_module(self, package: str, module_class: str):
        if not self.package_pattern.match(package):
            return ValueError("Package name doesn't meet the required pattern")

        with open(self.module_yaml, 'r') as file:
            package_dict = yaml.safe_load(file) or {}

        if package in package_dict:
            if module_class not in package_dict[package]:
                package_dict[package].update({module_class: {}})
                print(f"Module class {package}/{module_class} Registered")
        else:
            package_dict[package] = {module_class: {}}
            print(f"Package {package} created, Module class {module_class} Registered")

        with open(self.module_yaml, 'w') as file:
            yaml.dump(package_dict, file, default_flow_style=False, sort_keys=False)

    def update_requirements(self):
        with open(self.module_yaml, 'r') as file:
            package_dict = yaml.safe_load(file) or {}
        package_list = []
        for package_name in package_dict:
            module_name = package_name.replace("-", "_")
            if not os.path.exists(f"./{module_name}"):
                package_list.append(package_name)
            else:
                print(f"Found local package {package_name}")

        requirements_content = "\n".join(package_list)
        with open(self.requirements_txt, 'w') as file:
            file.write(requirements_content)

    def enable_modules(self):
        with open(self.module_yaml, 'r') as file:
            package_dict = yaml.safe_load(file) or {}
        for package_name, package_config in package_dict.items():
            module_obj = importlib.import_module(package_name.replace("-", "_"))
            for module_class_name in package_config:
                # Check if module file already exists
                module_class = getattr(module_obj, module_class_name)
                module_instance = module_class()
                if os.path.exists(os.path.join(self.module_dir, module_instance.module_name)):
                    print(f"Found local module {module_instance.module_name}")
                else:
                    module_instance.enable(self.module_dir)

    def install_requirements(self):
        subprocess.run(['pip', 'install', '-r', self.requirements_txt], check=True)

    def init_module(self, package: str, module_class: str):
        self.register_module(package, module_class)
        self.update_requirements()
        self.install_requirements()
        self.enable_modules()

    def create_app(self, app_name: str):
        print(f"Creating application: {app_name}")


def main():
    # Top level parser
    parser = argparse.ArgumentParser(description='Foundation tools')
    subparsers = parser.add_subparsers(dest='command', help='Available commands')

    # Create the parser for the "bigbang" command
    parser_bigbang = subparsers.add_parser('bigbang', help='Execute the Big Bang command')

    # Create the parser for the "birth" command
    parser_birth = subparsers.add_parser('birth', help='Create the current repo related foundation')
    parser_birth.add_argument('-b', '--tf_bucket', type=str, help='Bucket to hold tfstates file')
    parser_birth.add_argument('-n', '--tf_prefix', type=str, help='Prefix to hold tfstates file')
    parser_birth.add_argument('-p', '--project_prefix', type=str, help='Prefix of GCP Project')

    # Create the parser for the "init-module" command
    parser_install = subparsers.add_parser('init-module', help='Install a module')
    parser_install.add_argument('-m', '--module_class', type=str, help='Name of the module class to install')
    parser_install.add_argument('-p', '--package', type=str, help='Name of the package to install')

    # Create the parser for the "create-app" command
    parser_create = subparsers.add_parser('create-app', help='Create an application')
    parser_create.add_argument('-n', '--app_name', type=str, help='Name of the application to create')

    # Parse the arguments
    args = parser.parse_args()

    # Handle different commands
    foundation = Foundation()
    if args.command == 'bigbang':
        foundation.bigbang()
    elif args.command == 'init-module':
        foundation.init_module(package=args.package, module_class=args.module_class)
    elif args.command == 'create-app':
        foundation.create_app(app_name=args.app_name)
    else:
        # If no command is provided, show help
        parser.print_help()


if __name__ == "__main__":
    main()
