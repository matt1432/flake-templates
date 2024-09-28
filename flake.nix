{
  description = "My flake templates";

  outputs = {self, ...}: {
    templates = {
      full.path = ./full;
      clang.path = ./clang;
      rust.path = ./rust;

      default = self.templates.full;
    };
  };
}
