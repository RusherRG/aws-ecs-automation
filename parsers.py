import click
import sys
from subprocess import check_output
import string
import random
import yaml
letters = string.ascii_lowercase


@click.group()
def cli():
    pass


@click.command()
@click.option('--job', '-j', help='Script to run', required=False,
              default="create_ec2_instance.sh")
@click.option('--aws', '-a', help='Instance Flavour', required=False, default="t3.micro")
@click.option('--docker', '-d', help='Docker Image', required=True)
@click.option('--entrypoint_args', '-e', help='Entry Point', required=True)
def run(job, aws, docker, entrypoint_args):
    cmd_args = list(["bash", job, "entry_point=%s" % entrypoint_args.split()])
    cluster = ''.join(random.choice(letters) for i in range(10)) + '-cluster'
    policy = ''.join(random.choice(letters) for i in range(10)) + '-policy'
    config = ''.join(random.choice(letters) for i in range(10)) + '-config'
    instance = aws
    create_docker_compose(docker, entrypoint_args)

    cmd_args.append("cluster=%s" % cluster)
    cmd_args.append("policy=%s" % policy)
    cmd_args.append("config=%s" % config)
    cmd_args.append("instance=%s" % instance)

    try:
        print("Command: %s" % ' '.join(cmd_args))
        output = str(check_output(cmd_args), 'utf-8')
        for out in output.split('\n'):
            print(out)
    except Exception as e:
        print("Some exception occured due to error %s" % str(e))


def create_docker_compose(docker, entrypoint):
    entrypoint = entrypoint.split()
    compose = {
        'version': "1",
        'services': {
            'cli': {
                'image': docker,
                'command': entrypoint
            }
        }
    }

    with open('docker-compose.yml', 'w') as compose_file:
        yaml.dump(compose, compose_file)


cli.add_command(run)

if __name__ == "__main__":
    cli()
