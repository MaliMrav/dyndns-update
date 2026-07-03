###############################################################################
# config.py
#
# Configuration loading and !secret resolution.
#
# Contributors:
#   Vladimir Lekic
#   ChatGPT (OpenAI)
###############################################################################

from __future__ import annotations

import os
from dataclasses import dataclass
from pathlib import Path

import yaml

DEFAULT_CONFIG_DIR = "/etc/dyndns-update"

CONFIG_DIR = Path(
    os.environ.get(
        "DYNDNS_UPDATE_CONFIG_DIR",
        DEFAULT_CONFIG_DIR,
    )
)

CONFIG_FILE = CONFIG_DIR / "config.yaml"

SECRETS_FILE = CONFIG_DIR / "secrets.yaml"


###############################################################################
# Dataclasses
###############################################################################

@dataclass(slots=True)
class Credentials:
    username: str
    password: str


@dataclass(slots=True)
class Network:
    timeout: int
    retries: int
    ipv4_services: list[str]
    ipv6_services: list[str]


@dataclass(slots=True)
class Dns:
    nameserver: str


@dataclass(slots=True)
class DynDns:
    url: str
    user_agent: str


@dataclass(slots=True)
class UpdateOptions:
    ipv4: bool
    ipv6: bool


@dataclass(slots=True)
class Host:
    hostname: str
    enabled: bool
    update: UpdateOptions


@dataclass(slots=True)
class Config:
    credentials: Credentials
    network: Network
    dns: Dns
    dyndns: DynDns
    hosts: list[Host]


###############################################################################
# Secret Loader
###############################################################################

_secrets: dict[str, str] = {}


class SecretLoader(yaml.SafeLoader):
    """YAML loader supporting Home Assistant style !secret tags."""


def secret_constructor(loader, node):

    key = loader.construct_scalar(node)

    if key not in _secrets:
        raise KeyError(f"Unknown secret '{key}'")

    return _secrets[key]


SecretLoader.add_constructor("!secret", secret_constructor)


###############################################################################
# Loading
###############################################################################

def _load_secrets() -> None:

    global _secrets

    if not SECRETS_FILE.exists():
        raise FileNotFoundError(
            f"Secrets file not found: {SECRETS_FILE}"
        )

    with SECRETS_FILE.open(encoding="utf-8") as f:
        _secrets = yaml.safe_load(f) or {}


from typing import Any

def _load_yaml(path: Path) -> dict[str, Any]:
    """Load a YAML document using the custom secret loader."""
    with path.open(encoding="utf-8") as f:
        return yaml.load(f, Loader=SecretLoader)


###############################################################################
# Public API
###############################################################################

def load_config() -> Config:

    _load_secrets()

    raw = _load_yaml(CONFIG_FILE)

    credentials = Credentials(**raw["credentials"])

    network = Network(**raw["network"])

    dns = Dns(**raw["dns"])

    dyndns = DynDns(**raw["dyndns"])

    hosts = []

    for item in raw["hosts"]:

        hosts.append(
            Host(
                hostname=item["hostname"],
                enabled=item.get("enabled", True),
                update=UpdateOptions(**item["update"])
            )
        )

    return Config(
        credentials=credentials,
        network=network,
        dns=dns,
        dyndns=dyndns,
        hosts=hosts,
    )