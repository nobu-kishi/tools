import ipaddress

def summarize_cidr(cidr):
    network = ipaddress.ip_network(cidr, strict=False)
    start_ip = network.network_address
    end_ip = network.broadcast_address
    total_ips = network.num_addresses
    return f"{cidr},{start_ip}〜{end_ip},{total_ips}"

# ファイルからCIDRリストを読み込む
with open("cidr_list.txt", "r") as file:
    cidr_inputs = [line.strip() for line in file if line.strip() and not line.startswith("#")]

for cidr in cidr_inputs:
    result = summarize_cidr(cidr)
    print(result)