import requests
import subprocess
import os
if not os.path.exists(".git"):
    print("❌ This folder is not a Git repository. Run this script from inside your Git repo.")
    exit(1)
else:
    print("✅ Git repository detected. Proceeding...")
# Step 1: Generate the git graph
try:
    graph_output = subprocess.check_output(
        ["git", "log", "--graph", "--oneline", "--all", "--decorate"],
        text=True
    )
except subprocess.CalledProcessError as e:
    print("❌ Git command failed:")
    print(e.output)
    exit(1)

# Step 2: Truncate if too long for Discord (max 2000 characters)
MAX_LEN = 1900
if len(graph_output) > MAX_LEN:
    graph_output = graph_output[:MAX_LEN] + "\n...(truncated)"

# Step 3: Send to Discord webhook
webhook_url = 'https://discord.com/api/webhooks/1395244567095152780/iEbEk8SAtNzQ5KnPvr51bIBOs2wMQ5LeBdV4ctIoULpg4smPUWC7xasy8nUFw1u7y0T5'

payload = {
    "content": f"```bash\n{graph_output}\n```"
}

response = requests.post(webhook_url, json=payload)

if response.status_code == 204:
    print("✅ Graph sent to Discord.")
else:
    print(f"❌ Failed to send: {response.status_code} — {response.text}")
