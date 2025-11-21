"""
Scanner commands
"""


def register_commands(parser):
    """Register scan subcommands"""
    subparsers = parser.add_subparsers(
        dest='subcommand',
        help='Scanner subcommands'
    )

    # List command
    subparsers.add_parser('list', help='List scan resources')

    # Create command
    create_parser = subparsers.add_parser('create', help='Create scan')
    create_parser.add_argument('type', help='Scan type')

    # Run command
    run_parser = subparsers.add_parser('run', help='Run scan')
    run_parser.add_argument('id', help='Scan ID')

    # Status command
    status_parser = subparsers.add_parser('status', help='Check status')
    status_parser.add_argument('id', help='Scan ID')


def execute(args):
    """Execute scan command"""
    from utils.output import print_info
    print_info(f"Scanner command: {args.subcommand} (not yet implemented)")
    return 0
