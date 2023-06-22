datacenter = "opsschool"
data_dir = "/opt/consul"
encrypt = "arn:aws:kms:us-east-2:015098999341:key/abff11de-9ee3-4c8f-8778-38cb45aef1fd"
bind_addr = "10.0.6.71"
advertise_addr = "10.0.6.79"
performance {
  raft_multiplier = 1
}

bootstrap_expect = 3
retry_join = ["10.0.6.71", "10.0.7.35", "10.0.6.33"]

ports {
  grpc = 8502
}



ubuntu@ip-10-0-6-112:/etc/consul.d$ consul agent -server -config-file=server.hcl
==> failed to parse server.hcl: 2 errors occurred:
        * invalid config key bind
        * invalid config key advertise


ubuntu@ip-10-0-6-112:/etc/consul.d$ sudo vim server.hcl
ubuntu@ip-10-0-6-112:/etc/consul.d$ consul agent -server -config-file=server.hcl
==> encrypt has invalid key: illegal base64 data at input byte 3