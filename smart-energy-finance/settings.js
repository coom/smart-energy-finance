const path = require("path");
const fs = require("fs");
const crypto = require("crypto");

const ADMIN_CREDS_FILE = "/data/nodered_admin.json";
const ADMIN_USERNAME = "admin";

function loadOrCreateAdminHash() {
    try {
        const raw = fs.readFileSync(ADMIN_CREDS_FILE, "utf8");
        const data = JSON.parse(raw);
        if (data && typeof data.hash === "string" && data.hash.length > 0) {
            return data.hash;
        }
    } catch (_) { /* file missing or invalid → regenerate */ }

    const plaintext = crypto.randomBytes(15).toString("base64")
        .replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");
    const bcrypt = require("bcryptjs");
    const hash = bcrypt.hashSync(plaintext, 10);

    fs.writeFileSync(ADMIN_CREDS_FILE, JSON.stringify({
        username: ADMIN_USERNAME,
        hash,
        created_at: new Date().toISOString()
    }, null, 2), { mode: 0o600 });
    try { fs.chmodSync(ADMIN_CREDS_FILE, 0o600); } catch (_) {}

    const banner = "=".repeat(72);
    console.log("\n" + banner);
    console.log("Smart Energy Finance — Node-RED admin credentials generated");
    console.log("  URL:      http://<host>:1894");
    console.log("  Username: " + ADMIN_USERNAME);
    console.log("  Password: " + plaintext);
    console.log("  (hash stored in " + ADMIN_CREDS_FILE + "; plaintext shown once)");
    console.log("  To regenerate, delete that file and restart the add-on.");
    console.log(banner + "\n");

    return hash;
}

module.exports = {
    uiPort: process.env.PORT || 1894,
    uiHost: "0.0.0.0",

    flowFile: "flows.json",
    flowFilePretty: true,

    userDir: "/data",
    nodesDir: "/opt/node_modules",

    credentialSecret: false,

    adminAuth: {
        type: "credentials",
        users: [{
            username: ADMIN_USERNAME,
            password: loadOrCreateAdminHash(),
            permissions: "*"
        }]
    },

    mqttReconnectTime: 15000,
    serialReconnectTime: 15000,
    debugMaxLength: 1000,

    contextStorage: {
        default: "memory",
        memory: { module: "memory" },
        persistent: {
            module: "localfilesystem",
            config: {
                dir: path.join("/data", "context"),
                flushInterval: 30
            }
        }
    },

    functionGlobalContext: {
        fs: require("fs"),
        path: require("path"),
        os: require("os"),
        crypto: require("crypto")
    },

    exportGlobalContextKeys: false,

    logging: {
        console: {
            level: "info",
            metrics: false,
            audit: false
        }
    },

    editorTheme: {
        projects: {
            enabled: false
        }
    },

    diagnostics: {
        enabled: false,
        ui: false
    },

    runtimeState: {
        enabled: false,
        ui: false
    }
};
