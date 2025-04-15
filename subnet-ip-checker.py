import boto3
from netaddr import IPNetwork
import sys

if len(sys.argv) != 2:
    print("Usage: python subnet-ip-checker.py <subnet-id>")
    sys.exit(1)

subnet_id = sys.argv[1]
ec2 = boto3.client('ec2')

subnet = ec2.describe_subnets(SubnetIds=[subnet_id])['Subnets'][0]

cidr = subnet['CidrBlock']
network = IPNetwork(cidr)

# AWS予約IP
reserved_ips = [
    str(network[0]),  # network address
    str(network[1]),  # VPC Router
    str(network[2]),  # DNS Server
    str(network[3]),  # future use
    str(network[-1])  # broadcast
]

# 現在使用中のIP
alloc_ips = []
eni_list = ec2.describe_network_interfaces(Filters=[{'Name': 'subnet-id', 'Values': [subnet_id]}])['NetworkInterfaces']
for eni in eni_list:
    for private_ip in eni['PrivateIpAddresses']:
        alloc_ips.append(private_ip['PrivateIpAddress'])

# 使用可能なIP
available_ips = [str(ip) for ip in network if str(ip) not in reserved_ips + alloc_ips]

print(available_ips)