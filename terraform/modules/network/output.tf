output "vpcid" {
    value = aws_vpc.evgy_vpc.id
}

output "public_subnet_id"{
    value = aws_subnet.public.*.id
}

output "private_subnet_id"{
    value = aws_subnet.private.*.id
}