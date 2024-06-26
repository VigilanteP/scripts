#!/usr/bin/python3
import socket
import argparse


def resolve_hostname(hostname):
    """Resolves a hostname to an IP address using the system resolver.

    Args:
        hostname: The hostname to resolve (e.g., 'google.com').

    Returns:
        A string with the resolved IP address, or None if resolution fails.
    """
    try:
        ip_address = socket.gethostbyname(hostname)
        return ip_address
    except socket.gaierror as e:
        print(f"Error resolving {hostname}: {e}")
        return None


def discover_hostname(ipaddress):
    """Find the hostname associated with an IP address

    Args:
        ipadress: The IP to look up.

    Returns:
        A string with the hostname, or None if resolution fails.
    """
    try:
        hostname = socket.gethostbyaddr(ipaddress)
        return hostname[0]
    except socket.gaierror as e:
        print(f"Error resolving {ipaddress}: {e}")
        return None


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description='Resolve hostname/IP pairs via native socket.')
    parser.add_argument('identifier', type=str,
                        help='hostname or ip address to resolve')
    parser.add_argument('-x', '--reverse',
                        action='store_true', help='reverse lookup')
    parser.add_argument('-v', '--verbose', action='store_true')
    args = parser.parse_args()

    if args.reverse:
        result = discover_hostname(args.identifier)
    else:
        result = resolve_hostname(args.identifier)

    if result:
        if args.verbose:
            print(f"{args.identifier} resolves to {result}")
        else:
            print(result)
