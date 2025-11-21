"""
Kubernetes commands
"""


def register_commands(parser):
    """Register k8s subcommands"""
    subparsers = parser.add_subparsers(
        dest='subcommand',
        help='Kubernetes subcommands'
    )

    # Start command
    subparsers.add_parser('start', help='Start minikube')

    # Stop command
    subparsers.add_parser('stop', help='Stop minikube')

    # Status command
    subparsers.add_parser('status', help='Cluster status')

    # Pods command
    subparsers.add_parser('pods', help='List pods')

    # Services command
    subparsers.add_parser('services', help='List services')


def execute(args):
    """Execute k8s command"""
    from utils.output import print_info
    print_info(f"Kubernetes command: {args.subcommand} (not yet implemented)")
    return 0
