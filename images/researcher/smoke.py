#!/usr/bin/env python
import json
import os
import pathlib

import torch

workspace = pathlib.Path("/workspace")
marker = workspace / "punch-researcher-smoke.json"
value = torch.tensor([19.0], device="cuda" if torch.cuda.is_available() else "cpu") * 2
receipt = {
    "schemaVersion": "punch.researcher-smoke.v1",
    "torchVersion": torch.__version__,
    "cudaAvailable": torch.cuda.is_available(),
    "cudaDeviceCount": torch.cuda.device_count(),
    "result": value.cpu().item(),
    "networkPolicy": os.environ.get("PUNCH_NETWORK_POLICY"),
}
marker.write_text(json.dumps(receipt, sort_keys=True) + "\n", encoding="utf-8")
print(json.dumps(receipt, sort_keys=True))
