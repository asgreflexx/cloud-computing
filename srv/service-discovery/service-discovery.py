import sys
import exoscale
import json
import pathlib

#API Key
print(sys.argv[1])
#API Secret
print(sys.argv[2])
#print(sys.argv[3])

#exo = exoscale.Exoscale(config_file="/Users/michaelsvoboda/IdeaProjects/cloud-computing/srv/service-discovery/profile.toml")
exo = exoscale.Exoscale(api_key=sys.argv[1], api_secret=sys.argv[2])

zone_at= exo.compute.get_zone("at-vie-1")

data = []

for instance in exo.compute.list_instances(zone_at):
    print("{name} {zone} {ip}".format(
        name=instance.name,
        zone=instance.zone.name,
        ip=instance.ipv4_address,
    ))
    data.append({
        'targets': ["{ip}".format(ip=instance.ipv4_address)]
    })

with open('targets.json', 'w') as outfile:
    json.dump(data, outfile)
