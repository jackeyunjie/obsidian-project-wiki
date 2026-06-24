const { Plugin, ItemView, WorkspaceLeaf, Notice, TFile } = require("obsidian");

const VIEW_TYPE = "agent-dashboard-view";

class AgentDashboardView extends ItemView {
  constructor(leaf, plugin) {
    super(leaf);
    this.plugin = plugin;
    this.isRefreshing = false;
  }

  getViewType() {
    return VIEW_TYPE;
  }

  getDisplayText() {
    return "Agent Dashboard";
  }

  async onOpen() {
    await this.render();
  }

  async render() {
    const root = this.containerEl.children[1];
    root.empty();
    root.addClass("agent-dashboard-root");

    const health = await this.plugin.readHealth();
    const recent = this.plugin.getRecentFiles();
    const stats = this.plugin.getVaultStats();

    const header = root.createDiv({ cls: "agent-dashboard-header" });
    header.createEl("h2", { text: "Project Wiki Dashboard" });
    const refreshButton = header.createEl("button", {
      cls: "agent-dashboard-refresh",
      text: this.isRefreshing ? "Refreshing..." : "Refresh",
    });
    refreshButton.disabled = this.isRefreshing;
    refreshButton.addEventListener("click", async () => {
      await this.refresh();
    });

    const top = root.createDiv({ cls: "agent-dashboard-grid" });
    this.card(top, "Health score", String(health.health_score ?? "N/A"));
    this.card(top, "Inbox files", String(stats.inboxCount));
    this.card(top, "Wiki pages", String(stats.wikiCount));
    this.card(top, "Raw files", String(stats.rawCount));

    const actions = root.createDiv({ cls: "agent-dashboard-panel" });
    actions.createEl("h3", { text: "Runbook" });
    ["1. Run ingest.sh", "2. Run update.sh", "3. Ask agent to organize wiki", "4. Run check.sh --json", "5. Sync to Git"].forEach((text) => {
      actions.createEl("p", { text });
    });

    const metrics = root.createDiv({ cls: "agent-dashboard-panel" });
    metrics.createEl("h3", { text: "Health metrics" });
    Object.entries(health.metrics || {}).forEach(([key, value]) => {
      metrics.createEl("p", { text: `${key}: ${value}` });
    });

    const recentPanel = root.createDiv({ cls: "agent-dashboard-panel" });
    recentPanel.createEl("h3", { text: "Recent files" });
    if (recent.length === 0) {
      recentPanel.createEl("p", { text: "No markdown files found." });
    } else {
      recent.forEach((file) => recentPanel.createEl("p", { text: file.path }));
    }
  }

  async refresh() {
    if (this.isRefreshing) {
      return;
    }
    this.isRefreshing = true;
    try {
      await this.render();
      new Notice("Agent Dashboard refreshed.");
    } finally {
      this.isRefreshing = false;
      await this.render();
    }
  }

  card(parent, label, value) {
    const el = parent.createDiv({ cls: "agent-dashboard-card" });
    el.createEl("small", { text: label });
    el.createEl("strong", { text: value });
  }
}

module.exports = class AgentDashboardPlugin extends Plugin {
  async onload() {
    this.registerView(VIEW_TYPE, (leaf) => new AgentDashboardView(leaf, this));
    this.addCommand({
      id: "open-agent-dashboard",
      name: "Open Agent Dashboard",
      callback: async () => {
        const leaf = this.app.workspace.getRightLeaf(false) || this.app.workspace.getLeaf(true);
        await leaf.setViewState({ type: VIEW_TYPE, active: true });
        this.app.workspace.revealLeaf(leaf);
      },
    });
    this.addRibbonIcon("layout-dashboard", "Open Agent Dashboard", async () => {
      const leaf = this.app.workspace.getRightLeaf(false) || this.app.workspace.getLeaf(true);
      await leaf.setViewState({ type: VIEW_TYPE, active: true });
    });
  }

  onunload() {
    this.app.workspace.detachLeavesOfType(VIEW_TYPE);
  }

  async readHealth() {
    const file = this.app.vault.getAbstractFileByPath("outputs/wiki-health.json");
    if (!(file instanceof TFile)) {
      return { metrics: {} };
    }
    try {
      const raw = await this.app.vault.read(file);
      return JSON.parse(raw);
    } catch (error) {
      new Notice(`Failed to read wiki-health.json: ${error.message}`);
      return { metrics: {} };
    }
  }

  getRecentFiles() {
    return this.app.vault
      .getMarkdownFiles()
      .sort((a, b) => b.stat.mtime - a.stat.mtime)
      .slice(0, 8);
  }

  getVaultStats() {
    const files = this.app.vault.getMarkdownFiles();
    const inboxCount = files.filter((file) => file.path.startsWith("raw/inbox/")).length;
    const wikiCount = files.filter((file) => file.path.startsWith("wiki/")).length;
    const rawCount = files.filter((file) => file.path.startsWith("raw/")).length;
    return { inboxCount, wikiCount, rawCount };
  }
};
