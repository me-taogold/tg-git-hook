#!/usr/bin/env node

/**
 * GitHub Webhook Server for Auto-Deployment
 * This server listens for GitHub push events and triggers deployment
 *
 * Setup on Ubuntu:
 * 1. npm install express body-parser
 * 2. node webhook-server.js
 * 3. Configure GitHub webhook to point to: http://your-server-ip:3001/webhook
 * 4. Use PM2 to keep it running: pm2 start webhook-server.js --name webhook
 */

const express = require('express');
const bodyParser = require('body-parser');
const crypto = require('crypto');
const { exec } = require('child_process');
const fs = require('fs');

const app = express();
const PORT = process.env.WEBHOOK_PORT || 3001;
const WEBHOOK_SECRET = process.env.WEBHOOK_SECRET || 'your-webhook-secret';
const DEPLOY_PATH = process.env.DEPLOY_PATH || '/home/work/taogold/tg-fe';
const BRANCH = process.env.DEPLOY_BRANCH || 'main';

app.use(bodyParser.json());

// Verify GitHub webhook signature
function verifySignature(req) {
    const signature = req.headers['x-hub-signature-256'];
    if (!signature) {
        return false;
    }

    const hmac = crypto.createHmac('sha256', WEBHOOK_SECRET);
    const digest = 'sha256=' + hmac.update(JSON.stringify(req.body)).digest('hex');

    return crypto.timingSafeEqual(Buffer.from(signature), Buffer.from(digest));
}

// Webhook endpoint
app.post('/webhook', (req, res) => {
    console.log('\n[WEBHOOK] Received webhook request');
    console.log('[WEBHOOK] Time:', new Date().toISOString());

    // Verify signature
    if (!verifySignature(req)) {
        console.error('[WEBHOOK] Invalid signature');
        return res.status(401).send('Invalid signature');
    }

    const event = req.headers['x-github-event'];
    const payload = req.body;

    console.log('[WEBHOOK] Event type:', event);

    // Only handle push events
    if (event !== 'push') {
        console.log('[WEBHOOK] Ignoring non-push event');
        return res.status(200).send('Event ignored');
    }

    // Check if push is to the correct branch
    const pushedBranch = payload.ref.replace('refs/heads/', '');
    console.log('[WEBHOOK] Branch:', pushedBranch);

    if (pushedBranch !== BRANCH) {
        console.log(`[WEBHOOK] Ignoring push to ${pushedBranch}, waiting for ${BRANCH}`);
        return res.status(200).send('Branch ignored');
    }

    // Respond immediately to GitHub
    res.status(200).send('Deployment triggered');

    // Trigger deployment asynchronously
    console.log('[WEBHOOK] Starting deployment...');
    console.log('[WEBHOOK] Commit:', payload.head_commit?.id?.substring(0, 7));
    console.log('[WEBHOOK] Message:', payload.head_commit?.message);

    // Check if deployment directory exists
    if (!fs.existsSync(DEPLOY_PATH)) {
        console.error('[WEBHOOK] Deployment path not found:', DEPLOY_PATH);
        return;
    }

    // Deployment commands to run sequentially
    const commands = [
        `cd ${DEPLOY_PATH}`,
        `git pull`,
        'npm run build'
    ].join(' && ');

    console.log('[WEBHOOK] Executing:', commands);

    // Execute deployment commands
    exec(commands, { cwd: DEPLOY_PATH }, (error, stdout, stderr) => {
        if (error) {
            console.error('[WEBHOOK] Deployment failed:', error);
            console.error('[WEBHOOK] Error output:', stderr);
            return;
        }

        console.log('[WEBHOOK] Deployment output:');
        console.log(stdout);
        if (stderr) {
            console.log('[WEBHOOK] Deployment warnings:');
            console.log(stderr);
        }
        console.log('[WEBHOOK] Deployment completed successfully!');
    });
});

// Health check endpoint
app.get('/health', (req, res) => {
    res.status(200).json({
        status: 'ok',
        timestamp: new Date().toISOString(),
        branch: BRANCH,
        deployPath: DEPLOY_PATH
    });
});

// Start server
app.listen(PORT, () => {
    console.log('=====================================');
    console.log('GitHub Webhook Server Started');
    console.log('=====================================');
    console.log(`Listening on port: ${PORT}`);
    console.log(`Watching branch: ${BRANCH}`);
    console.log(`Deploy path: ${DEPLOY_PATH}`);
    console.log('Health check: http://localhost:' + PORT + '/health');
    console.log('Webhook URL: http://YOUR_SERVER_IP:' + PORT + '/webhook');
    console.log('=====================================');
});
