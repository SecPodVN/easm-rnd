"""
Deployment commands for EASM platform
Supports multiple deployment targets: compose, k8s, microk8s, argocd
"""

import os
import subprocess
import sys


def register_commands(parser):
    """Register deploy subcommands"""
    subparsers = parser.add_subparsers(
        dest='subcommand',
        help='Deploy subcommands'
    )

    # Deploy command
    deploy_parser = subparsers.add_parser(
        'apply',
        help='Deploy application to target environment'
    )
    deploy_parser.add_argument(
        '--target',
        choices=['compose', 'k8s', 'microk8s', 'argocd'],
        default='compose',
        help='Deployment target (default: compose)'
    )
    deploy_parser.add_argument(
        '--namespace',
        default='easm-platform',
        help='Kubernetes namespace (default: easm-platform)'
    )
    deploy_parser.add_argument(
        '--registry',
        default='localhost:32000',
        help='Container registry (default: localhost:32000 for MicroK8s)'
    )
    deploy_parser.add_argument(
        '--build',
        action='store_true',
        help='Build and push images before deploying'
    )

    # Status command
    status_parser = subparsers.add_parser(
        'status',
        help='Show deployment status'
    )
    status_parser.add_argument(
        '--target',
        choices=['compose', 'k8s', 'microk8s', 'argocd'],
        help='Show status for specific target'
    )
    status_parser.add_argument(
        '--namespace',
        default='easm-platform',
        help='Kubernetes namespace (default: easm-platform)'
    )

    # Delete command
    delete_parser = subparsers.add_parser(
        'delete',
        help='Delete deployment'
    )
    delete_parser.add_argument(
        '--target',
        choices=['compose', 'k8s', 'microk8s', 'argocd'],
        required=True,
        help='Deployment target to delete'
    )
    delete_parser.add_argument(
        '--namespace',
        default='easm-platform',
        help='Kubernetes namespace (default: easm-platform)'
    )
    delete_parser.add_argument(
        '--force',
        action='store_true',
        help='Force deletion without confirmation'
    )


def execute(args):
    """Execute deploy command"""
    from utils.output import print_info, print_success, print_error, print_warning

    if args.subcommand == 'apply':
        return deploy_apply(args)
    elif args.subcommand == 'status':
        return deploy_status(args)
    elif args.subcommand == 'delete':
        return deploy_delete(args)
    else:
        print_error(f"Unknown subcommand: {args.subcommand}")
        return 1


def deploy_apply(args):
    """Deploy application to target environment"""
    from utils.output import print_info, print_success, print_error

    print_info(f"Deploying to {args.target} environment...")

    # Get project root (3 levels up from this file)
    project_root = os.path.abspath(os.path.join(os.path.dirname(__file__), '../../..'))

    if args.target == 'compose':
        return deploy_compose(project_root, args)
    elif args.target in ['k8s', 'microk8s']:
        return deploy_kubernetes(project_root, args)
    elif args.target == 'argocd':
        return deploy_argocd(project_root, args)
    else:
        print_error(f"Unsupported target: {args.target}")
        return 1


def deploy_compose(project_root, args):
    """Deploy using Docker Compose"""
    from utils.output import print_info, print_success, print_error

    compose_file = os.path.join(project_root, 'docker-compose.yml')

    if not os.path.exists(compose_file):
        print_error(f"Docker Compose file not found: {compose_file}")
        return 1

    print_info("Starting Docker Compose deployment...")

    try:
        subprocess.run(
            ['docker', 'compose', 'up', '-d'],
            cwd=project_root,
            check=True
        )
        print_success("Docker Compose deployment started")
        return 0
    except subprocess.CalledProcessError as e:
        print_error(f"Docker Compose deployment failed: {e}")
        return 1


def deploy_kubernetes(project_root, args):
    """Deploy to Kubernetes (native or MicroK8s)"""
    from utils.output import print_info, print_success, print_error, print_warning

    # Determine kubectl command
    kubectl = get_kubectl_command(args.target)

    # Build and push images if requested
    if args.build:
        print_info("Building and pushing Docker images...")
        if build_and_push_images(project_root, args.registry) != 0:
            print_error("Failed to build and push images")
            return 1

    # Deploy using Helm
    print_info(f"Deploying to namespace: {args.namespace}")

    charts_dir = os.path.join(project_root, 'src', 'charts')

    # Deploy API
    api_chart = os.path.join(charts_dir, 'easm-api')
    if deploy_helm_chart(kubectl, 'easm-api', api_chart, args.namespace, args.registry) != 0:
        return 1

    # Deploy Frontend
    frontend_chart = os.path.join(charts_dir, 'easm-frontend')
    if deploy_helm_chart(kubectl, 'easm-frontend', frontend_chart, args.namespace, args.registry) != 0:
        return 1

    print_success(f"Deployment to {args.target} completed")
    return 0


def deploy_argocd(project_root, args):
    """Deploy using ArgoCD"""
    from utils.output import print_info, print_success, print_error, print_warning

    # Check if ArgoCD is installed
    if not check_argocd_installed():
        print_error("ArgoCD is not installed or not accessible")
        print_info("Run: kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml")
        return 1

    # Build and push images if requested
    if args.build:
        print_info("Building and pushing Docker images...")
        if build_and_push_images(project_root, args.registry) != 0:
            print_error("Failed to build and push images")
            return 1

    # Apply ArgoCD applications
    argocd_dir = os.path.join(project_root, 'k8s', 'argocd')

    if not os.path.exists(argocd_dir):
        print_error(f"ArgoCD manifests not found: {argocd_dir}")
        return 1

    print_info("Applying ArgoCD applications...")

    try:
        # Use kustomize to apply all ArgoCD resources
        subprocess.run(
            ['kubectl', 'apply', '-k', argocd_dir],
            check=True
        )
        print_success("ArgoCD applications created")
        print_info("ArgoCD will now sync the applications automatically")
        print_info("Monitor progress with: argocd app list")
        return 0
    except subprocess.CalledProcessError as e:
        print_error(f"Failed to apply ArgoCD applications: {e}")
        return 1


def deploy_status(args):
    """Show deployment status"""
    from utils.output import print_info, print_success, print_error

    if args.target == 'compose':
        return status_compose()
    elif args.target in ['k8s', 'microk8s', None]:
        return status_kubernetes(args)
    elif args.target == 'argocd':
        return status_argocd(args)
    else:
        print_error(f"Unsupported target: {args.target}")
        return 1


def status_compose():
    """Show Docker Compose status"""
    from utils.output import print_info

    print_info("Docker Compose Status:")
    try:
        subprocess.run(['docker', 'compose', 'ps'], check=True)
        return 0
    except subprocess.CalledProcessError:
        return 1


def status_kubernetes(args):
    """Show Kubernetes deployment status"""
    from utils.output import print_info

    kubectl = get_kubectl_command(args.target) if args.target else 'kubectl'
    namespace = args.namespace

    print_info(f"Kubernetes Status (namespace: {namespace}):")

    try:
        # Show pods
        print_info("\nPods:")
        subprocess.run([kubectl, 'get', 'pods', '-n', namespace])

        # Show services
        print_info("\nServices:")
        subprocess.run([kubectl, 'get', 'svc', '-n', namespace])

        # Show ingress
        print_info("\nIngress:")
        subprocess.run([kubectl, 'get', 'ingress', '-n', namespace])

        return 0
    except subprocess.CalledProcessError:
        return 1


def status_argocd(args):
    """Show ArgoCD application status"""
    from utils.output import print_info, print_error

    if not check_argocd_installed():
        print_error("ArgoCD CLI not found")
        return 1

    print_info("ArgoCD Application Status:")
    try:
        subprocess.run(['argocd', 'app', 'list'], check=True)
        return 0
    except subprocess.CalledProcessError:
        return 1


def deploy_delete(args):
    """Delete deployment"""
    from utils.output import print_info, print_success, print_error, print_warning

    if not args.force:
        response = input(f"Are you sure you want to delete deployment from {args.target}? (yes/no): ")
        if response.lower() != 'yes':
            print_info("Deletion cancelled")
            return 0

    if args.target == 'compose':
        return delete_compose()
    elif args.target in ['k8s', 'microk8s']:
        return delete_kubernetes(args)
    elif args.target == 'argocd':
        return delete_argocd(args)
    else:
        print_error(f"Unsupported target: {args.target}")
        return 1


def delete_compose():
    """Delete Docker Compose deployment"""
    from utils.output import print_info, print_success, print_error

    print_info("Stopping Docker Compose deployment...")
    try:
        subprocess.run(['docker', 'compose', 'down'], check=True)
        print_success("Docker Compose deployment stopped")
        return 0
    except subprocess.CalledProcessError as e:
        print_error(f"Failed to stop deployment: {e}")
        return 1


def delete_kubernetes(args):
    """Delete Kubernetes deployment"""
    from utils.output import print_info, print_success, print_error

    kubectl = get_kubectl_command(args.target)
    namespace = args.namespace

    print_info(f"Deleting deployment from namespace: {namespace}")

    try:
        # Delete Helm releases
        subprocess.run([kubectl, 'delete', 'all', '--all', '-n', namespace], check=True)
        print_success(f"Deployment deleted from {namespace}")
        return 0
    except subprocess.CalledProcessError as e:
        print_error(f"Failed to delete deployment: {e}")
        return 1


def delete_argocd(args):
    """Delete ArgoCD applications"""
    from utils.output import print_info, print_success, print_error

    print_info("Deleting ArgoCD applications...")

    try:
        subprocess.run(['argocd', 'app', 'delete', 'easm-api', '--yes'], check=True)
        subprocess.run(['argocd', 'app', 'delete', 'easm-frontend', '--yes'], check=True)
        print_success("ArgoCD applications deleted")
        return 0
    except subprocess.CalledProcessError as e:
        print_error(f"Failed to delete ArgoCD applications: {e}")
        return 1


# Helper functions

def get_kubectl_command(target):
    """Get appropriate kubectl command based on target"""
    if target == 'microk8s':
        return 'microk8s kubectl'
    return 'kubectl'


def check_argocd_installed():
    """Check if ArgoCD is installed and accessible"""
    try:
        subprocess.run(['argocd', 'version', '--client'],
                      capture_output=True, check=True)
        return True
    except (subprocess.CalledProcessError, FileNotFoundError):
        return False


def build_and_push_images(project_root, registry):
    """Build and push Docker images"""
    from utils.output import print_info, print_success, print_error

    # Build API image
    print_info("Building easm-api image...")
    api_dir = os.path.join(project_root, 'src', 'backend')
    api_image = f"{registry}/easm-api:latest"

    try:
        subprocess.run(
            ['docker', 'build', '-t', api_image, '.'],
            cwd=api_dir,
            check=True
        )
        subprocess.run(['docker', 'push', api_image], check=True)
        print_success(f"Built and pushed {api_image}")
    except subprocess.CalledProcessError as e:
        print_error(f"Failed to build/push API image: {e}")
        return 1

    # Build Frontend image
    print_info("Building easm-frontend image...")
    frontend_dir = os.path.join(project_root, 'src', 'frontend', 'EASM-portal')
    frontend_image = f"{registry}/easm-frontend:latest"

    try:
        subprocess.run(
            ['docker', 'build', '-t', frontend_image, '.'],
            cwd=frontend_dir,
            check=True
        )
        subprocess.run(['docker', 'push', frontend_image], check=True)
        print_success(f"Built and pushed {frontend_image}")
    except subprocess.CalledProcessError as e:
        print_error(f"Failed to build/push frontend image: {e}")
        return 1

    return 0


def deploy_helm_chart(kubectl, release_name, chart_path, namespace, registry):
    """Deploy a Helm chart"""
    from utils.output import print_info, print_success, print_error

    print_info(f"Deploying {release_name}...")

    # Prepare helm command
    helm_cmd = kubectl.replace('kubectl', 'helm') if 'microk8s' in kubectl else 'helm'

    try:
        subprocess.run([
            helm_cmd, 'upgrade', '--install',
            release_name,
            chart_path,
            '--namespace', namespace,
            '--create-namespace',
            '--set', f'image.repository={registry}/{release_name}',
            '--set', 'image.tag=latest',
            '--wait'
        ], check=True)
        print_success(f"{release_name} deployed successfully")
        return 0
    except subprocess.CalledProcessError as e:
        print_error(f"Failed to deploy {release_name}: {e}")
        return 1
