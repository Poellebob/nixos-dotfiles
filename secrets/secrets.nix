let
  goonbox = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPoBp3cGMohQO+JdZyEiK4Ag/14BlmccQEkQeuQs8haA viggokh@goonbox-3000";
  framework13 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAoOyIvsIUwznoj71ZA9lFTixJis1s3ceTjF520uoWU/ viggokh@framework13";
in
{
  "cloudflared-token.age".publicKeys = [
    goonbox
    framework13
  ];
  "playit-secret.age".publicKeys = [
    goonbox
    framework13
  ];
  "windrose-env.age".publicKeys = [
    goonbox
    framework13
  ];
  "searxng.age".publicKeys = [
    goonbox
    framework13
  ];
  "cemu-keys.age".publicKeys = [
    goonbox
    framework13
  ];
  "goonbox-playit.age".publicKeys = [ goonbox ];
}
