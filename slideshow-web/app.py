from flask import Flask, request, render_template, redirect, url_for
import subprocess
import os

app = Flask(__name__)
HOME = os.path.expanduser("~")
CONFIG_PATH = os.path.join(HOME, "picframe-master/.slideshow_config")
SYNC_SCRIPT = os.path.join(HOME, "picframe-master/sync_slideshow.sh")

def get_delay():
    if os.path.exists(CONFIG_PATH):
        with open(CONFIG_PATH) as f:
            return f.read().strip()
    return "10"

def get_available_networks():
    try:
        result = subprocess.check_output(["nmcli", "-t", "-f", "SSID", "dev", "wifi"], text=True)
        ssids = list(set([line.strip() for line in result.splitlines() if line.strip()]))
        return sorted(ssids)
    except Exception:
        return []

@app.route("/", methods=["GET", "POST"])
def index():
    message = ""
    if request.method == "POST":
        if "delay" in request.form:
            with open(CONFIG_PATH, "w") as f:
                f.write(request.form["delay"])
            message = "Delay saved."
        elif "sync" in request.form:
            subprocess.Popen([SYNC_SCRIPT])
            message = "Sync startett."
        return render_template("index.html", delay=get_delay(), message=message)
    return render_template("index.html", delay=get_delay(), message=message)

@app.route("/wifi", methods=["GET", "POST"])
def wifi():
    message = ""
    if request.method == "POST":
        ssid = request.form.get("ssid")
        password = request.form.get("password")
        if ssid:
            try:
                cmd = ["nmcli", "dev", "wifi", "connect", ssid]
                if password:
                    cmd += ["password", password]
                subprocess.run(cmd, check=True)
                message = "✅ Connected. Restarting..."
                subprocess.Popen(["reboot"])
            except subprocess.CalledProcessError:
                message = "❌ Connection Error."
    networks = get_available_networks()
    return render_template("wifi.html", networks=networks, message=message)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
