#!/usr/bin/env python3
"""
EASM CLI - Unified command-line interface for EASM project
"""
import sys
import argparse
from pathlib import Path

# Add project root to path
PROJECT_ROOT = Path(__file__).parent.parent
sys.path.insert(0, str(PROJECT_ROOT))

from cli.commands import dev, deploy, db, scan, k8s, docker, config
from cli.utils.output import print_banner, print_error, print_success


VERSION = "0.1.0"


def create_parser():
    """Create argument parser with all commands"""
    parser = argparse.ArgumentParser(
        prog='easm',
        description='EASM Project CLI - External Attack Surface Management',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  easm dev start              Start development environment
  easm deploy start --mode prod    Deploy to production
  easm db seed --quick        Quick seed database
  easm scan list              List all scans
  easm k8s status             Check Kubernetes status

For more information: https://github.com/your-org/easm-rnd
        """
    )

    parser.add_argument('--version', action='version', version=f'%(prog)s {VERSION}')
    parser.add_argument('--verbose', '-v', action='store_true', help='Verbose output')
    parser.add_argument('--quiet', '-q', action='store_true', help='Quiet mode')

    subparsers = parser.add_subparsers(dest='command', help='Available commands')

    # Development commands
    dev_parser = subparsers.add_parser('dev', help='Development commands')
    dev.register_commands(dev_parser)

    # Deployment commands
    deploy_parser = subparsers.add_parser('deploy', help='Deployment commands')
    deploy.register_commands(deploy_parser)

    # Database commands
    db_parser = subparsers.add_parser('db', help='Database commands')
    db.register_commands(db_parser)

    # Scanner commands
    scan_parser = subparsers.add_parser('scan', help='Scanner operations')
    scan.register_commands(scan_parser)

    # Kubernetes commands
    k8s_parser = subparsers.add_parser('k8s', help='Kubernetes operations')
    k8s.register_commands(k8s_parser)

    # Docker commands
    docker_parser = subparsers.add_parser('docker', help='Docker operations')
    docker.register_commands(docker_parser)

    # Configuration commands
    config_parser = subparsers.add_parser('config', help='Configuration management')
    config.register_commands(config_parser)

    return parser


def main():
    """Main CLI entry point"""
    parser = create_parser()
    args = parser.parse_args()

    if not args.command:
        print_banner()
        parser.print_help()
        return 0

    try:
        # Execute command
        if args.command == 'dev':
            return dev.execute(args)
        elif args.command == 'deploy':
            return deploy.execute(args)
        elif args.command == 'db':
            return db.execute(args)
        elif args.command == 'scan':
            return scan.execute(args)
        elif args.command == 'k8s':
            return k8s.execute(args)
        elif args.command == 'docker':
            return docker.execute(args)
        elif args.command == 'config':
            return config.execute(args)
        else:
            parser.print_help()
            return 1

    except KeyboardInterrupt:
        print_error("\n[!] Interrupted by user")
        return 130
    except Exception as e:
        if args.verbose:
            import traceback
            traceback.print_exc()
        else:
            print_error(f"[ERROR] {str(e)}")
        return 1


if __name__ == '__main__':
    sys.exit(main())
