{
  description = "My flake templates";

  outputs = {self}: {
    templates = {
      full = {
        path = ./full;
      };

      default = self.templates.full;
    };
  };
}
