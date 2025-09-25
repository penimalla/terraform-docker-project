import React, { useState, useRef, useEffect } from "react";
import { motion } from "framer-motion";
import { Copy, Download, Terminal, Play, CheckCircle, FileText } from "lucide-react";

// Default export - a single-file React component previewable in the canvas.
export default function App() {
  const MAIN_TF = `terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {}

resource "docker_image" "nginx_image" {
  name         = "nginx:latest"
  keep_locally = false
}

resource "docker_container" "nginx_container" {
  name  = "terraform-nginx"
  image = docker_image.nginx_image.latest

  ports {
    internal = 80
    external = 8080
  }
}
`;

  const COMMANDS = `# Initialize terraform
terraform init

# See what will change
terraform plan

# Apply (create container)
terraform apply

# Check state
terraform state list

# When finished
terraform destroy
`;

  const SAMPLE_LOGS = {
    init: `Initializing the backend...
Initializing provider plugins...
- Finding kreuzwerker/docker versions matching "~> 3.0"...
- Installing kreuzwerker/docker v3.0.2...
Terraform has been successfully initialized!`,

    plan: `Terraform will perform the following actions:

  # docker_image.nginx_image will be created
  + resource "docker_image" "nginx_image" {
      + name         = "nginx:latest"
    }

  # docker_container.nginx_container will be created
  + resource "docker_container" "nginx_container" {
      + name     = "terraform-nginx"
      + image    = "nginx:latest"
      + ports {
          + internal = 80
          + external = 8080
        }
    }

Plan: 2 to add, 0 to change, 0 to destroy.`,

    apply: `docker_image.nginx_image: Creating...
docker_image.nginx_image: Creation complete

docker_container.nginx_container: Creating...
docker_container.nginx_container: Creation complete

Apply complete! Resources: 2 added, 0 changed, 0 destroyed.`,

    dockerps: `CONTAINER ID   IMAGE          COMMAND                  STATUS         PORTS                  NAMES
abc123def456   nginx:latest   "/docker-entrypoint.…"   Up 5 seconds   0.0.0.0:8080->80/tcp   terraform-nginx`,

    destroy: `Destroying resources...
docker_container.nginx_container: Destroying... 
docker_container.nginx_container: Destruction complete

docker_image.nginx_image: Destroying... 
docker_image.nginx_image: Destruction complete

Destroy complete! Resources: 2 destroyed.`
  };

  const [terminalLines, setTerminalLines] = useState(["# Welcome to the Terraform + Docker guided terminal — use the controls to simulate steps."]);
  const [copied, setCopied] = useState(null);
  const [checked, setChecked] = useState({ 1: false, 2: false, 3: false, 4: false, 5: false });
  const termRef = useRef(null);

  useEffect(() => {
    // auto-scroll
    if (termRef.current) {
      termRef.current.scrollTop = termRef.current.scrollHeight;
    }
  }, [terminalLines]);

  const copyToClipboard = async (text, id) => {
    try {
      await navigator.clipboard.writeText(text);
      setCopied(id);
      setTimeout(() => setCopied(null), 1800);
    } catch (e) {
      alert("Copy failed. You can manually select and copy.");
    }
  };

  const downloadFile = (filename, text) => {
    const blob = new Blob([text], { type: "text/plain" });
    const url = URL.createObjectURL(blob);
    const a = document.createElement("a");
    a.href = url;
    a.download = filename;
    a.click();
    URL.revokeObjectURL(url);
  };

  const simulate = (key) => {
    if (!SAMPLE_LOGS[key]) return;
    const newLines = SAMPLE_LOGS[key].split("\n");
    setTerminalLines((p) => [...p, `\n$ ${key} output:`, ...newLines]);
  };

  const clearTerminal = () => setTerminalLines(["# Terminal cleared — simulate another step."]);

  const toggleCheck = (i) => setChecked((c) => ({ ...c, [i]: !c[i] }));

  return (
    <div className="min-h-screen bg-gradient-to-b from-slate-100 to-white p-6">
      <div className="max-w-7xl mx-auto">
        <header className="flex items-center justify-between mb-6">
          <div>
            <h1 className="text-3xl font-extrabold">Terraform + Docker — Interactive Guide</h1>
            <p className="text-slate-500 mt-1">Step-by-step, copyable code, simulated terminal, and export tools — all in one place.</p>
          </div>
          <div className="flex gap-3">
            <button
              onClick={() => downloadFile("main.tf", MAIN_TF)}
              className="flex items-center gap-2 bg-white py-2 px-4 rounded-2xl shadow-sm hover:shadow-md"
            >
              <FileText size={16} /> Download main.tf
            </button>
            <button
              onClick={() => window.print()}
              className="flex items-center gap-2 bg-slate-900 text-white py-2 px-4 rounded-2xl shadow-sm hover:shadow-md"
            >
              <Download size={16} /> Export / Print
            </button>
          </div>
        </header>

        <motion.div
          initial={{ opacity: 0, y: 8 }}
          animate={{ opacity: 1, y: 0 }}
          className="grid grid-cols-12 gap-6"
        >
          {/* Steps column */}
          <aside className="col-span-3 bg-white rounded-2xl p-4 shadow-md">
            <h3 className="font-semibold mb-3">Quick Steps</h3>
            <ol className="space-y-3">
              {["Install Docker & Terraform", "Create main.tf", "terraform init & plan", "terraform apply", "terraform destroy"].map((s, i) => (
                <li key={i} className="flex items-start gap-3">
                  <button onClick={() => toggleCheck(i + 1)} className="mt-1">
                    {checked[i + 1] ? (
                      <CheckCircle size={20} className="text-green-500" />
                    ) : (
                      <div className="w-5 h-5 rounded-full border border-slate-300" />
                    )}
                  </button>
                  <div>
                    <div className="font-medium">Step {i + 1}</div>
                    <div className="text-sm text-slate-500">{s}</div>
                  </div>
                </li>
              ))}
            </ol>

            <div className="mt-6">
              <h4 className="text-sm font-semibold">Project Checklist</h4>
              <ul className="text-sm text-slate-600 mt-2 space-y-1">
                <li>✅ main.tf file</li>
                <li>✅ terraform init/plan/apply logs</li>
                <li>✅ Docker container running</li>
                <li>✅ Screenshots for report</li>
              </ul>
            </div>

            <div className="mt-6 text-xs text-slate-500">Tip: Use the copy buttons to quickly paste commands into your terminal.</div>
          </aside>

          {/* Main content */}
          <main className="col-span-6">
            <section className="bg-white rounded-2xl p-5 shadow-md mb-6">
              <div className="flex items-start justify-between">
                <div>
                  <h2 className="text-xl font-semibold">main.tf (Terraform configuration)</h2>
                  <p className="text-slate-500 text-sm">This file provisions an nginx container using the docker provider.</p>
                </div>
                <div className="flex gap-2">
                  <button
                    onClick={() => copyToClipboard(MAIN_TF, "main_tf")}
                    className="flex items-center gap-2 border rounded-2xl px-3 py-2"
                  >
                    <Copy size={16} /> {copied === "main_tf" ? "Copied" : "Copy"}
                  </button>
                  <button
                    onClick={() => downloadFile("main.tf", MAIN_TF)}
                    className="flex items-center gap-2 border rounded-2xl px-3 py-2"
                  >
                    <Download size={16} /> Save
                  </button>
                </div>
              </div>

              <pre className="mt-4 overflow-auto p-4 rounded-lg bg-slate-950 text-white text-sm leading-relaxed max-h-64">
                <code>{MAIN_TF}</code>
              </pre>
            </section>

            <section className="bg-white rounded-2xl p-5 shadow-md">
              <div className="flex items-start justify-between">
                <div>
                  <h2 className="text-xl font-semibold">Commands & Execution</h2>
                  <p className="text-slate-500 text-sm">Run these commands in your project folder (where main.tf lives).</p>
                </div>
                <div>
                  <button onClick={() => copyToClipboard(COMMANDS, "cmds")} className="flex items-center gap-2 border rounded-2xl px-3 py-2">
                    <Copy size={16} /> {copied === "cmds" ? "Copied" : "Copy All"}
                  </button>
                </div>
              </div>

              <pre className="mt-4 overflow-auto p-4 rounded-lg bg-slate-900 text-white text-sm leading-relaxed max-h-48">
                <code>{COMMANDS}</code>
              </pre>

              <div className="flex gap-3 mt-4">
                <button
                  onClick={() => simulate("init")}
                  className="flex items-center gap-2 bg-white px-4 py-2 rounded-2xl shadow-sm"
                >
                  <Play size={16} /> Simulate init
                </button>
                <button onClick={() => simulate("plan")} className="flex items-center gap-2 bg-white px-4 py-2 rounded-2xl shadow-sm">
                  <Play size={16} /> Simulate plan
                </button>
                <button onClick={() => simulate("apply")} className="flex items-center gap-2 bg-white px-4 py-2 rounded-2xl shadow-sm">
                  <Play size={16} /> Simulate apply
                </button>
                <button onClick={() => simulate("dockerps")} className="flex items-center gap-2 bg-white px-4 py-2 rounded-2xl shadow-sm">
                  <Terminal size={16} /> Show docker ps
                </button>
                <button onClick={() => simulate("destroy")} className="flex items-center gap-2 bg-white px-4 py-2 rounded-2xl shadow-sm">
                  <Play size={16} /> Simulate destroy
                </button>
              </div>
            </section>
          </main>

          {/* Terminal column */}
          <aside className="col-span-3 bg-black text-white rounded-2xl p-4 shadow-md flex flex-col">
            <div className="flex items-center justify-between mb-3">
              <div className="flex items-center gap-2">
                <Terminal size={18} />
                <div className="font-semibold">Simulated Terminal</div>
              </div>
              <div className="flex gap-2">
                <button onClick={() => copyToClipboard(terminalLines.join("\n"), "term") } className="px-3 py-1 rounded-2xl bg-slate-800/60">
                  <Copy size={14} />
                </button>
                <button onClick={clearTerminal} className="px-3 py-1 rounded-2xl bg-slate-800/60">
                  Clear
                </button>
              </div>
            </div>

            <div ref={termRef} className="flex-1 overflow-auto text-xs font-mono p-3 rounded-lg bg-gradient-to-b from-slate-900 to-black">
              {terminalLines.map((l, i) => (
                <div key={i} className={`whitespace-pre-wrap ${l.startsWith("$") ? "text-emerald-300" : "text-slate-300"}`}>
                  {l}
                </div>
              ))}
            </div>

            <div className="mt-3 text-xs text-slate-400">Use the controls to add realistic logs to this terminal. Copy or save them to include in your report.</div>
          </aside>
        </motion.div>

        <footer className="mt-6 text-sm text-slate-600">
          <div className="bg-white rounded-2xl p-4 shadow-sm">
            <strong>What's inside:</strong> ready-to-copy `main.tf`, terminal simulation for logs, command list, download and export tools, checklist and step toggles. Use this interactive page while you run the commands locally — then paste real logs and screenshots into your final report.
          </div>
        </footer>
      </div>
    </div>
  );
}
