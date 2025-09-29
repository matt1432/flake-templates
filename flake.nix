{
  description = "My flake templates";

  outputs = {self, ...}: {
    templates = {
      full.path = ./full;
      clang.path = ./clang;
      cpp.path = ./cpp;
      rust.path = ./rust;

      default = self.templates.full;
    };
  };
}
