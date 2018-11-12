#!/usr/bin/env python

import json
import os
import re
import shutil
import sys

from subprocess import check_output

node_list_file = 'node-list.json'
output_directory = 'my-node-scripts'

def format_script(address, ip, host, boot_node_ip, prvkey, vals):
    output = """\
#!/usr/bin/env sh
# Address: {0}
# IP: {1}
NODE_HOST="{2}" \\
  BOOT_NODE_IP="{3}" \\
  blockstanbulPrivateKey="{4}" \\
  seqDebugMode="${{seqDebugMode:-true}}" \\
  blockstanbul="${{blockstanbul:-true}}" \\
  validators='{5}' \\
  ./strato""" \
            .format(address, ip, host.strip(), boot_node_ip.strip() if boot_node_ip else '', prvkey, json.dumps(vals, separators=(',', ':')))
    # Single node deployment workaround - remove BOOT_NODE_IP line
    if not boot_node_ip:
        output = re.sub(".*BOOT_NODE_IP=.*\n?","",output)
    return output


def get_strato_image_name():
    if 'STRATO_IMAGE' in os.environ:
        strato_image = os.environ['STRATO_IMAGE']
    else:
        try:
            strato_img_dc_line = next(line for line in open("docker-compose.yml") if 'STRATO_IMAGE' in line)
            strato_image = re.search(':-(.*)}', strato_img_dc_line).group(1)
        except:
            print(
                'Error: Unable to read strato image name from docker-compose.yml - provide STRATO_IMAGE env var or a valid docker-compose.yml to proceed')
            sys.exit(1)
    print('STRATO image used: {0}'.format(strato_image))
    return strato_image


if __name__ == "__main__":
    # TODO: try-catch json load
    try:
        with open(node_list_file) as file:
            nodes = json.load(file)
    except:
        print('Error: Unable to parse JSON in {0}'.format(node_list_file))
        sys.exit(2)
    if not nodes:
        print('ERROR: no nodes found in {0}'.format(node_list_file))
        sys.exit(3)
    num_hosts = len(nodes)
    common_boot_ip = nodes[0]['ip'] if num_hosts > 1 else None
    other_boot_ip = nodes[1]['ip'] if num_hosts > 1 else None
    strato_image = get_strato_image_name()
    keys_bytes = check_output(["docker", "run", "--entrypoint=keygen", strato_image, "--count={0}".format(num_hosts)])
    print(keys_bytes.decode('utf-8'))
    keys_json = json.loads(keys_bytes.decode('utf-8'))

    validators = keys_json['all_validators']

    if os.path.exists(output_directory) and len(os.listdir(output_directory)):
        print("Output directory {0}/ exists and not empty.\nAre you sure you want to remove it? (y/n):".format(output_directory))
        choice = raw_input().lower()
        if choice in {'yes','y'}:
            shutil.rmtree(output_directory)
        else:
            print('Error: Output directory {0}/ is not empty and removal was not confirmed by the user'.format(output_directory))
            sys.exit(2)
    os.makedirs(output_directory)

    for (node, key_address_pair) in zip(nodes, keys_json['key_address_pairs']):
        with open(os.path.join(output_directory, '{0}_run.sh'.format(node['ip'].strip())), 'w') as file:
            file.write(
                format_script(
                    key_address_pair['address'],
                    node['ip'],
                    node['host'],
                    common_boot_ip if node['ip'] != common_boot_ip else other_boot_ip,
                    key_address_pair['private_key'],
                    validators
                )
            )

    print('Successfully finished. Check {0}/ directory for scripts'.format(output_directory))
