import os
import sys
import exoscale
import json
import pathlib
import time

#Usage:
#docker run -v /Users/michaelsvoboda/IdeaProjects/cloud-computing/srv/service-discovery/config.json:/config.json -e EXOSCALE_KEY='' -e EXOSCALE_SECRET='' -e EXOSCALE_ZONE='at-vie-1' -e EXOSCALE_INSTANCEPOOL_ID='8c7795a6-3a9c-4904-8fa8-4dc07dcab100' -e TARGET_PORT='9100' asgreflexx/service-discovery_cc:latest
#print(sys.argv[1])
#API Secret
#print(sys.argv[2])
#print(sys.argv[3])

#exo = exoscale.Exoscale(config_file="/Users/michaelsvoboda/IdeaProjects/cloud-computing/srv/service-discovery/profile.toml")

def search_for_instances_in_instancepool():
    print("Checking for new instances.....")
    exo = exoscale.Exoscale(api_key=os.environ.get('EXOSCALE_KEY'), api_secret=os.environ.get('EXOSCALE_SECRET'))
    zone_at = exo.compute.get_zone(os.environ.get('EXOSCALE_ZONE'))
    data = []

    for instance in exo.compute.list_instances(zone_at):
        
        #print(instance.instance_pool)

        if(instance.instance_pool is not None and instance.instance_pool.id == os.environ.get('EXOSCALE_INSTANCEPOOL_ID')):
            print("Found instance....")
            print("{name} {zone} {ip}".format(
                name=instance.name,
                zone=instance.zone.name,
                ip=instance.ipv4_address,
            ))
            data.append({
                'targets': ["{ip}:{port}".format(ip=instance.ipv4_address,port=os.environ.get('TARGET_PORT'))]
            })

    with open('/srv/service-discovery/config.json', 'w') as outfile:
        json.dump(data, outfile)



if __name__ == '__main__':

    #For manual testing
    #os.environ.setdefault('EXOSCALE_KEY', '')
    #os.environ.setdefault('EXOSCALE_SECRET', '')
    #os.environ.setdefault('EXOSCALE_ZONE', 'at-vie-1')
    #os.environ.setdefault('EXOSCALE_INSTANCEPOOL_ID', 'dab1d953-d319-437e-1423-4e548fe6eb52')
    #os.environ.setdefault('TARGET_PORT', '9100')

    #API Key
    #print(os.environ.get('EXOSCALE_KEY'))
    #print(os.environ.get('EXOSCALE_SECRET'))
    #print(os.environ.get('EXOSCALE_ZONE'))
    #print(os.environ.get('EXOSCALE_INSTANCEPOOL_ID'))
    #print(os.environ.get('TARGET_PORT'))

    if os.environ.get('EXOSCALE_KEY') is None:
        print("EXOSCALE API KEY is missing")
        exit()

    if os.environ.get('EXOSCALE_SECRET') is None:
        print("EXOSCALE API KEY is missing")
        exit()

    if os.environ.get('EXOSCALE_ZONE') is None:
        print("EXOSCALE Zone is missing")
        exit()

    if os.environ.get('EXOSCALE_INSTANCEPOOL_ID') is None:
        print("EXOSCALE Instance Pool ID is missing")
        exit()

    if(os.environ.get('TARGET_PORT') is None):
        print("EXOSCALE Target Port is missing")
        exit()

    while True:
        search_for_instances_in_instancepool()
        time.sleep(10)
