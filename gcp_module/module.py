class Module:
    def __init__(self, source_dir: str, **kwargs):
        self.source_dir = source_dir

    def initialize(self):
        """Initialize a module in an application
        """

    def compile(self):
        """Compile a module to prepare terraform apply
        """

    def clean(self):
        """Clean Task after terraform apply
        """

