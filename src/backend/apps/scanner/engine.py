"""Scanning engine for evaluating rules against resources."""
from .models import Resource, Rule, Finding


class ScanEngine:
    """Engine for scanning resources against rules."""

    @staticmethod
    def evaluate_rule(resource, rule):
        """
        Evaluate a single rule against a resource.

        Args:
            resource: Resource document dict
            rule: Rule document dict

        Returns:
            bool: True if rule matches (issue found), False otherwise
        """
        field = rule.get('field')
        op = rule.get('op')
        expected_value = rule.get('value')

        # Get the actual value from the resource
        actual_value = resource.get(field)

        # If field doesn't exist in resource, no match
        if actual_value is None:
            return False

        # Evaluate based on operator
        if op == 'eq':
            return str(actual_value) == str(expected_value)
        elif op == 'neq':
            return str(actual_value) != str(expected_value)
        elif op == 'gt':
            try:
                return float(actual_value) > float(expected_value)
            except (ValueError, TypeError):
                return False
        elif op == 'lt':
            try:
                return float(actual_value) < float(expected_value)
            except (ValueError, TypeError):
                return False
        elif op == 'gte':
            try:
                return float(actual_value) >= float(expected_value)
            except (ValueError, TypeError):
                return False
        elif op == 'lte':
            try:
                return float(actual_value) <= float(expected_value)
            except (ValueError, TypeError):
                return False
        elif op == 'contains':
            return str(expected_value).lower() in str(actual_value).lower()
        elif op == 'not_contains':
            return str(expected_value).lower() not in str(actual_value).lower()
        elif op == 'in':
            # Check if actual_value is in a list of expected values
            if isinstance(expected_value, list):
                return actual_value in expected_value
            return False
        elif op == 'not_in':
            if isinstance(expected_value, list):
                return actual_value not in expected_value
            return False

        return False

    @classmethod
    def scan_all_resources(cls):
        """
        Scan all resources against all rules and create findings.

        Returns:
            dict: Scan results with counts
        """
        # Clear existing findings
        Finding.clear_all()

        # Get all resources and rules
        resources_result = Resource.find_all(limit=10000)  # Get all resources
        resources = resources_result['data']
        rules = Rule.find_all()

        findings_created = 0
        resources_scanned = 0
        rules_evaluated = 0

        # Scan each resource against each rule
        for resource in resources:
            resources_scanned += 1

            for rule in rules:
                rules_evaluated += 1

                # Check if rule applies to this resource type
                rule_resource_type = rule.get('resource_type')
                if rule_resource_type and resource.get('resource_type') != rule_resource_type:
                    continue

                # Evaluate the rule
                if cls.evaluate_rule(resource, rule):
                    # Create a finding
                    finding_data = {
                        'resource_id': resource['_id'],
                        'resource_name': resource.get('name', 'Unknown'),
                        'resource_type': resource.get('resource_type', 'Unknown'),
                        'rule_name': rule.get('name', 'Unknown Rule'),
                        'rule_description': rule.get('description', ''),
                        'severity': rule.get('severity', 'MEDIUM'),
                        'field': rule.get('field'),
                        'actual_value': str(resource.get(rule.get('field'))),
                        'expected_value': str(rule.get('value')),
                        'operator': rule.get('op')
                    }
                    Finding.create(finding_data)
                    findings_created += 1

        return {
            'resources_scanned': resources_scanned,
            'rules_evaluated': rules_evaluated,
            'findings_created': findings_created
        }
