"""
Docker commands
"""


def register_commands(parser):
    """Register docker subcommands"""
    subparsers = parser.add_subparsers(
        dest='subcommand',
        help='Docker subcommands'
    )

    # Build command
    subparsers.add_parser('build', help='Build images')

    # Push command
    subparsers.add_parser('push', help='Push to registry')

    # Clean command
    subparsers.add_parser('clean', help='Clean images/containers')

    # Logs command
    logs_parser = subparsers.add_parser('logs', help='View logs')
    logs_parser.add_argument('service', nargs='?', help='Service name')
    logs_parser.add_argument(
        '-f',
        '--follow',
        action='store_true',
        help='Follow logs'
    )


def execute(args):
    """Execute docker command"""
    from cli.utils.output import print_info
    print_info(f"Docker command: {args.subcommand} (not yet implemented)")
    return 0
