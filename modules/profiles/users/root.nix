{ pkgs, ... }: {
  users.users.root = {
    hashedPassword =
      "$6$uWdBBHFmu2RqXQYG$if2AOX1aSpykA4uzSB//vr0GHt.Kw00tJOHazAnZUEU5LNcIOF6UyMPDSfH97Fis4DJF6kBmUMmqqxXmMn9hp.";
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDjP4zPNw1dHe8a8KTOp/fxaLw9LxkX13dXPMnqHHmJzfpkHSYnrslwPME1ej/K6dxa11xfW8uBfQnWAXyCcJXdbsyBrpxmvKt+a7+wMolUIBWueVAenfc9EeEXkhr5sHNTjE6WMzhkCm7vVWj0QARAmKuT0ugQ6fWoFbP7kb/0+VEXJq82GAEjdut697VM6YSf+2rIFTpRyiGEImAi8Lt9Qyqm3cze1lQu0mdrIyyKDIJV/D+pJqZQL73nqI7OhWgPKiF4exZj7kas3sykr62Fmlr7RgfDSFrJQhBIiy1EK3dsO1ehFhtwpqtjyPMhKPOgii1q2JMvL5eHnw/x7oX1"
    ];
    shell = pkgs.fish;
  };
}
