let
  goonbox = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPoBp3cGMohQO+JdZyEiK4Ag/14BlmccQEkQeuQs8haA viggokh@goonbox-3000";
  homeserver = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOnGHIfOjqQDoH9iIc/+6e9ANLJKphkqcl6NORlXpNbR root@nixos";
in
{
  "cloudflared-token.age".publicKeys = [ goonbox homeserver ];
  "playit-secret.age".publicKeys = [ goonbox homeserver ];
  "windrose-env.age".publicKeys = [ goonbox homeserver ];

}
