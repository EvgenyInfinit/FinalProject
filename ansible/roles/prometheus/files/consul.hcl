datacenter = "opsschool"
data_dir = "/opt/consul"
encrypt = "arn:aws:kms:us-east-2:015098999341:key/abff11de-9ee3-4c8f-8778-38cb45aef1fd"
retry_join = ["10.0.6.71", "10.0.7.35", "10.0.6.33"]
ports {
  grpc = 8502
}
