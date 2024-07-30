{
  description = "My flake templates";

  outputs = {self, ...}: {
    templates = {
      full.path = ./full;
      rust.path = ./rust;

      default = self.templates.full;
    };
  };
}
