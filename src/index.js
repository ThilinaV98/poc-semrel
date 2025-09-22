const express = require('express');
const fs = require('fs');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(express.json());

// Get version from package.json
const getVersion = () => {
  const packageJson = JSON.parse(
    fs.readFileSync(path.join(__dirname, '..', 'package.json'), 'utf8')
  );
  return packageJson.version;
};

// Routes
app.get('/', (req, res) => {
  res.json({
    message: 'Welcome to POC Semantic Release API',
    version: getVersion(),
    environment: process.env.NODE_ENV || 'development',
    timestamp: new Date().toISOString()
  });
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'healthy',
    version: getVersion(),
    uptime: process.uptime(),
    timestamp: new Date().toISOString()
  });
});

// Version endpoint
app.get('/version', (req, res) => {
  const version = getVersion();
  const buildInfo = {
    version,
    major: version.split('.')[0],
    minor: version.split('.')[1],
    patch: version.split('.')[2],
    build: process.env.BUILD_NUMBER || 'local',
    commit: process.env.COMMIT_SHA || 'unknown',
    branch: process.env.BRANCH_NAME || 'local',
    timestamp: new Date().toISOString()
  };

  res.json(buildInfo);
});

// Sample API endpoints
app.get('/api/users', (req, res) => {
  res.json({
    users: [
      { id: 1, name: 'John Doe', email: 'john@example.com' },
      { id: 2, name: 'Jane Smith', email: 'jane@example.com' }
    ],
    version: getVersion()
  });
});

app.post('/api/users', (req, res) => {
  const { name, email } = req.body;

  if (!name || !email) {
    return res.status(400).json({
      error: 'Name and email are required',
      version: getVersion()
    });
  }

  res.status(201).json({
    message: 'User created successfully',
    user: {
      id: Date.now(),
      name,
      email
    },
    version: getVersion()
  });
});

// Feature flag endpoint (demonstrates feature management)
app.get('/api/features', (req, res) => {
  const version = getVersion();
  const [major, minor] = version.split('.');

  res.json({
    features: {
      newDashboard: parseInt(major) >= 2,
      advancedAnalytics: parseInt(major) >= 2 && parseInt(minor) >= 1,
      betaFeatures: version.includes('beta') || version.includes('rc'),
      experimentalApi: version.includes('dev') || version.includes('feature')
    },
    version
  });
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({
    error: 'Something went wrong!',
    message: err.message,
    version: getVersion()
  });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    error: 'Not Found',
    path: req.path,
    version: getVersion()
  });
});

// Start server
const server = app.listen(PORT, () => {
  console.log(`🚀 Server running on http://localhost:${PORT}`);
  console.log(`📦 Version: ${getVersion()}`);
  console.log(`🌍 Environment: ${process.env.NODE_ENV || 'development'}`);
  console.log(`📅 Started: ${new Date().toISOString()}`);
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM received, shutting down gracefully...');
  server.close(() => {
    console.log('Server closed');
    process.exit(0);
  });
});

module.exports = app;