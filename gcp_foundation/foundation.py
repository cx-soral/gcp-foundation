import re
import os
import subprocess
import importlib
import yaml


class Foundation:
    def __init__(self, config_dir: str = "config", **kwargs):
        self.config_dir = config_dir
        self.module_dir = os.path.sep.join(["iac", "modules"])
        self.landscape_yaml = os.path.sep.join([self.config_dir, "landscape.yaml"])
        self.application_yaml = os.path.sep.join([self.config_dir, "applications.yaml"])
        self.module_yaml = os.path.sep.join([self.config_dir, "modules.yaml"])

        # Temporary files
        self.requirements_txt = os.path.sep.join([self.config_dir, "requirements.txt"])
        self.package_pattern = re.compile(r'^[a-zA-Z0-9_-]+$')

    def bigbang(self, realm_project: str, realm_name: str = None):
        """Create the realm administration project"""
        with open(self.landscape_yaml, 'r') as file:
            landscape_dict = yaml.safe_load(file) or {}
        current_settings = landscape_dict.get("settings", {})
        current_realm_project = current_settings.get("realm_project", "")
        if not realm_project:
            raise ValueError("Realm project must be provided")
        if current_realm_project and current_realm_project != realm_project:
            raise ValueError("Realm project doesn't match configured landscape.yaml")
        realm_name = realm_project if not realm_name else realm_name
        check_project_cmd = f"gcloud projects list --filter='{realm_project}' --format='value(projectId)'"
        r = subprocess.run(check_project_cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, shell=True)
        if realm_project in r.stdout:
            print(f"Realm Project {realm_project} already exists")
        else:
            create_proj_cmd = f"gcloud projects create {realm_project} --name='{realm_name}'"
            r = subprocess.run(create_proj_cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, shell=True)
            if "ERROR" not in r.stderr:
                print(f"Realm Project {realm_project} create successfully")
                current_settings["realm_name"] = realm_name
                current_settings["realm_project"] = realm_project
                with open(self.landscape_yaml, 'w') as file:
                    yaml.dump(landscape_dict, file, default_flow_style=False, sort_keys=False)
            else:
                print(r.stderr)

    def create_backend(self, foundation_name: str):
        with open(self.landscape_yaml, 'r') as file:
            landscape_dict = yaml.safe_load(file) or {}
        current_settings = landscape_dict.get("settings", {})
        if not current_settings.get("realm_project", ""):
            raise ValueError("Realm project must be defined before")
        if not foundation_name:
            raise ValueError("Foundation name must be provided")
        bucket_name = current_settings["realm_project"] + "_" + foundation_name
        check_bucket_cmd = f"gsutil ls -b gs://{bucket_name}"
        r = subprocess.run(check_bucket_cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, shell=True)
        if "AccessDeniedException" not in r.stderr and "NotFound" not in r.stderr:
            print(f"Bucket {bucket_name} already exists")
        else:
            create_bucket_cmd = f"gsutil mb -p {current_settings['realm_project']} gs://{bucket_name}/"
            r = subprocess.run(create_bucket_cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, shell=True)
            if "ERROR" not in r.stderr:
                print(f"Bucket {bucket_name} create successfully")
                current_settings["foundation_name"] = foundation_name
                with open(self.landscape_yaml, 'w') as file:
                    yaml.dump(landscape_dict, file, default_flow_style=False, sort_keys=False)
            else:
                print(r.stderr)

    def terraform_init(self, env: str):
        with open(self.landscape_yaml, 'r') as file:
            landscape_dict = yaml.safe_load(file) or {}
        current_settings = landscape_dict.get("settings", {})
        bucket_name = current_settings["realm_project"] + "_" + current_settings["foundation_name"]
        tf_init_cmd = f'terraform -chdir=iac/environments/{env} init -backend-config="bucket={bucket_name}"'
        r = subprocess.run(tf_init_cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, shell=True)

    def birth(self, foundation_name: str):
        # self.create_backend(foundation_name)
        self.terraform_init('prd')
        """
        self.register_module("gcp-module-project", "Project")
        self.register_module("gcp-module-application", "Application")
        self.update_requirements()
        self.install_requirements()
        self.enable_modules()
        """

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

