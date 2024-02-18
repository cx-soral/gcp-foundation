import os
import sys
import shutil


class Module:
    module_name = "gcp-module"

    def __init__(self, source_dir: str = "", **kwargs):
        package_dir = os.path.dirname(os.path.abspath(sys.modules[self.__class__.__module__].__file__))
        self.source_dir = source_dir
        self.module_dir = os.path.join(package_dir, "templates", self.module_name, "module")
        self.base_dir = os.path.join(package_dir, "templates", self.module_name, "base")
        self.base_file = os.path.join(self.base_dir, "main.tf")

    def enable(self, module_dir: str = os.path.sep.join(["iac", "modules"]),
               base_dir: str = os.path.sep.join(["iac", "environments", "base"])):
        """Enable a module in a foundation

        Args:
            module_dir (str): Target Terraform Module Directory
            base_dir (str): Target Terraform Base Directory
        """
        target_module_dir = os.path.sep.join([module_dir, self.module_name])
        if os.path.exists(target_module_dir):
            print(f"Found local module {self.module_name}")
        else:
            shutil.copytree(self.module_dir, target_module_dir)
        target_base_file = os.path.sep.join([base_dir, self.module_name.replace("-", "_") + ".tf"])
        if os.path.exists(target_base_file):
            print(f"Found local base file {target_base_file}")
        else:
            shutil.copy(self.base_file, target_base_file)

    def initialize(self):
        """Initialize a module in an application
        """

    def compile(self):
        """Compile a module to prepare terraform apply
        """

    def clean(self):
        """Clean Task after terraform apply
        """

