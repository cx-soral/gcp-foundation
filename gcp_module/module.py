import os
import sys
import shutil


class Module:
    module_name = "gcp-module"

    def __init__(self, source_dir: str = "", **kwargs):
        package_dir = os.path.dirname(os.path.abspath(sys.modules[self.__class__.__module__].__file__))
        self.source_dir = source_dir
        self.module_dir = os.path.join(package_dir, "templates", self.module_name, "module")

    def enable(self, module_dir: str = os.path.sep.join(["iac", "modules"])):
        """Enable a module in a foundation

        Args:
            module_dir (str): Target Terraform Module Directory
        """
        target_module_dir = os.path.sep.join([module_dir, self.module_name])
        shutil.copytree(self.module_dir, target_module_dir)

    def initialize(self):
        """Initialize a module in an application
        """

    def compile(self):
        """Compile a module to prepare terraform apply
        """

    def clean(self):
        """Clean Task after terraform apply
        """

